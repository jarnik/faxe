package faxe.parser;

import nme.Assets;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.DisplayObjectContainer;
import nme.utils.ByteArray;
import nme.geom.Rectangle;

import faxe.parser.IParser;
import faxe.model.IElement;
import faxe.model.ElementSprite;
import faxe.model.Image;
import faxe.model.Shape;
import faxe.model.Group;
import faxe.Main;

typedef XCF_HEADER = {
    magic:String,
    version:String,
    width:Int,
    height:Int,
    base_type:Int
}

class ParserXCF implements IParser
{
    private var head:XCF_HEADER;
    private var data:ByteArray;

    /*
    http://henning.makholm.net/xcftools/xcfspec-saved

    In general an XCF file describes a stack of _layers_ and _channels_ on
    a _canvas_, which is just an abstract rectangular viewport for the
    layers and channels.
    */

	public function new () {
    }

    private function readChars( chars:Int ):String {
        return data.readUTFBytes( chars );
    }

    private function readByte( ):Int {
        data.position++;
        return data[ data.position - 1 ];
    }

    private function readUWord():Int {
        return data.readUnsignedInt();
    }
    
    private function readWord():Int {
        return data.readInt();
    }

    private function readString():String {
        var length:Int = readUWord();
        var s:String = readChars( length - 1 );
        readChars( 1 ); // 0 ending
        return s;
    }

    private function parseHeader():XCF_HEADER {
        var magic:String = readChars( 9 ); // file type magic
        var version:String = readChars( 4 );
        readChars( 1 );
        var width:Int = readUWord();
        var height:Int = readUWord();
        var base_type:Int = readUWord();
        var header:XCF_HEADER = {
            magic: magic,
            version: version,
            width: width,
            height: height,
            base_type: base_type
        };
        return header;
    }

    private function parseProperties():Void {
        var prop_type:Int;
        var payload_length:Int;
        var counter:Int = 0;
        var s:String;

        prop_type = readUWord();        
        while ( counter < 150 ) {
            //Main.log("prop "+prop_type);
            payload_length = readUWord();
            switch( prop_type ) {
                case 17: //PROP_COMPRESSION
                    //Main.log("val "+readByte());
                    readByte();
                default:
                    readChars( payload_length );
                /*
                case 0:  //PROP_END
                case 1:  //PROP_COLORMAP
                case 18: //PROP_GUIDES
                case 19: //PROP_RESOLUTION
                case 21: //PROP_UNIT
                case 23: //PROP_PATHS
                case 24: //PROP_USER_UNIT 
                case 25: //PROP_VECTORS
                */
            }
            if ( prop_type == 0 ) {
                //Main.log(" > length "+payload_length);
                break;
            }
            //Main.log(" > length "+payload_length);
            prop_type = readUWord();        
            counter++;
        }
    }

    private function parseLayers():Group {
        //trace("NEW PARENT LAYER");
        var g:Group = new Group("layers");
        var layerAddresses:Array<Int> = [];
        var address:Int = 0;
        address = readUWord();
        //Main.log("first address "+address);
        while ( address != 0 ) {
            //Main.log("layer address "+address);
            layerAddresses.push( address );
            address = readUWord();
        };
        
        var e:IElement;
        for ( lptr in layerAddresses ) {
            e = parseLayer( lptr, g );
            //g.addChildAt( e, 0 );
            //trace(" >>> "+e+" is a kid of "+g.name );
        }
        recursiveUpdateExtent( g, new Rectangle( 0, 0, head.width, head.height ), 2 );
        return g;
    }

    private function recursiveUpdateExtent( g:Group, forcedSize:Rectangle = null, forcedSizeLevel:Int = 0 ):Void {
        for ( kid in g.children ) {
            if ( !Std.is( kid, Group ) )
                continue;
            recursiveUpdateExtent( cast( kid, Group ), forcedSizeLevel > 0 ? forcedSize : null, forcedSizeLevel - 1 );
        }
        g.updateExtent( forcedSize );
    }

    private function parseLayer( address:Int, root:Group ):IElement {
        data.position = address;
        var w:Int = readUWord();
        var h:Int = readUWord();
        var img_type:Int = readUWord();
        var name:String = readString();
        //trace("=== layer "+w+"x"+h+" type "+img_type+" name "+name);
        var prop_type:Int = -1;
        var payload_length:Int = 0;
        var counter:Int = 0;
        var dx:Int = 0;
        var dy:Int = 0;
        var opacity:Int = 255;
        var isGroup:Bool = false;
        var parent:Group = root;//null;

        prop_type = readUWord();
        while ( counter < 150 ) {
            //Main.log("prop "+prop_type);
            payload_length = readUWord();
            switch( prop_type ) {
                case 6: //PROP_OPACITY
                    opacity = readWord();
                case 15: //PROP_OFFSETS
                    dx = readWord();
                    dy = readWord();
                case 29: // PROP_GROUP_ITEM
                    isGroup = true;
                    //Main.log("is a folder!");
                    readChars( payload_length );
                case 30: // PROP_ITEM_PATH
                    //trace("is a child "+payload_length);
                    parent = root;
                    var parentIndex:Int; 
                    while ( payload_length > 0 ) {
                        parentIndex = readUWord();
                        //trace("parentindex "+parentIndex);
                        //trace("parent "+parent.name+" children "+parent.children.length);
                        for ( i in 0...parent.children.length ) {
                            //trace("checking child "+i);
                            parentIndex--;
                            if ( parentIndex == -1 ) {
                                parent = cast( parent.children[ parent.children.length-i-1 ], Group );
                                //trace("lower parent "+parent.name);
                                break;
                            }
                        }
                        //parent = parent.children[ parent.children.length - parentIndex - 1 ];
                        payload_length -= 4;
                    }
                    //Main.log(" parent = "+parent );
                default:
                    readChars( payload_length );
            }
            if ( prop_type == 0 ) {
                //Main.log(" > length "+payload_length);
                break;
            }
            //Main.log(" > length "+payload_length);
            prop_type = readUWord();        
            counter++;
        }

        var e:IElement;
        if ( !isGroup ) {
            var hptr:Int = readUWord();
            var mptr:Int = readUWord();
            var bitmapData:BitmapData = parseHierarchy( hptr );
            e = new Image( bitmapData );
            //trace("NEW IMAGE layer "+name);
        } else {
            var alignment:AlignConfig = Parser.parseAlign( name );
            e = new Group( Parser.parseName( name ) );
            cast( e, Group ).alignment = alignment;
            //trace("NEW GROUP LAYER name "+name+" = "+alignment);
        }
        e.fixedSize.x += dx;
        e.fixedSize.y += dy;
        e.alpha = opacity / 255;

        if ( parent != null ) {
            //trace(" -> parent is "+parent.name);
            parent.addChildAt( e, 0 );             
        }
    
        return e;
    }

    private function parseHierarchy( hptr:Int ):BitmapData {
        data.position = hptr;
        var hw:Int = readUWord();
        var hh:Int = readUWord();
        var bpp:Int = readUWord();
        var lptr:Int = readUWord();

        // parse first level - others are not used
        data.position = lptr;
        var w:Int = readUWord();
        var h:Int = readUWord();
        //Main.log("level "+w+" x "+h+" bpp "+bpp);

        var tilePtrs:Array<Int> = [];
        var tptr:Int = -1;

        for ( i in 0...Math.ceil(w/64)*Math.ceil(h/64) ) {
            tptr = readUWord();
            tilePtrs.push( tptr );
            //Main.log("tptr "+tptr);
        }
        var marker:Int = readUWord();
        //Main.log("zero marker "+marker);
                
        var bmd:BitmapData = new BitmapData( w, h, true, 0xff000000 );
        var bytes:ByteArray = new ByteArray(); // ARGB sequence
        #if !android
        bytes.length = w*h*bpp;
        #end

        var index:Int = 0;
        var tw:Int;
        var th:Int;
        var columns:Int = Math.ceil(w / 64);
        var rows:Int = Math.ceil(h / 64);
        //var bytes:ByteArray;
        var rect:Rectangle = new Rectangle();
        for ( tptr in tilePtrs ) {
            tw = ((index+1) % columns == 0 ? w % 64 : 64 );
            th = ((index+1) % rows == 0 ? h % 64 : 64 );
            tw = ( tw == 0 ? 64 : tw );
            th = ( th == 0 ? 64 : th );
            bytes = parseTile( tptr, tw, th, bpp, bytes );
            bytes.position = 0;
            //Main.log("got tile bytes "+bytes.length+" 1 "+bytes.readUnsignedByte());
            rect.x = (index % columns) * 64;
            rect.y = Math.floor(index / columns) * 64;
            rect.width = tw;
            rect.height = th;
            bmd.setPixels( rect, bytes );
            index++;
        }
        return bmd;
    }

    private function parseTile( tptr:Int, w:Int, h:Int, bpp:Int, bytes:ByteArray ):ByteArray {
        //Main.log("tile "+w+" x "+h+" bpp "+bpp); 
        data.position = tptr;
        var compressed:Bool = true;
                
        var size:Int;
        var val:Int;
        var length:Int;
        var pos:Int = 0;
        // RLE is RGBA
        for ( s in 0...4 ) {
            pos = (s + 1) % 4;
            size = w*h;
            //Main.log("size "+size+" data pos "+data.position);
    
            if ( bpp == 3 && s == 3 )
                continue;

            while (size > 0) {
                length = readByte();
                if (length >= 128) {
                    length = 255 - (length - 1);
                    if (length == 128) {
                        length = (readByte() << 8) + readByte();
                    }
                    size -= length;
                    while (length-- > 0) {
                        bytes[ pos ] = readByte();
                        pos += 4;
                    }
                } else {
                    length += 1;
                    if (length == 128) {
                        length = (readByte() << 8) + readByte();
                    }
                    size -= length;
    
                    val = readByte();  
                    for ( j in 0...length) {
                        bytes[ pos ] = val;
                        pos += 4;
                    }
                }
            }
        }
        return bytes;
    }

    public function parse( file:ByteArray ):IElement {
        data = file;
        head = parseHeader();
        //Main.log("head: "+head);
        parseProperties();
        var g:Group = parseLayers();
        //var e:Element = new Element();
        return g;
    }

}
