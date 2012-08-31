package jarnik.faxe.parser;

import nme.Assets;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.DisplayObjectContainer;
import nme.utils.ByteArray;
import nme.geom.Rectangle;

import jarnik.faxe.model.Element;
import jarnik.faxe.model.Image;
import jarnik.faxe.model.Shape;
import jarnik.faxe.Main;

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

    private function parseLayers():Element {
        var e:Element = new Element();
        var layerAddresses:Array<Int> = [];
        var address:Int = 0;
        address = readUWord();
        //Main.log("first address "+address);
        while ( address != 0 ) {
            //Main.log("layer address "+address);
            layerAddresses.push( address );
            address = readUWord();
        };
        
        for ( lptr in layerAddresses ) {
            e.addChildAt( parseLayer( lptr ), 0 );
        }
        return e;
    }

    private function parseLayer( address:Int ):Element {
        data.position = address;
        var w:Int = readUWord();
        var h:Int = readUWord();
        var img_type:Int = readUWord();
        var name:String = readString();
        //Main.log("layer "+w+"x"+h+" type "+img_type+" name "+name);
        var prop_type:Int = -1;
        var payload_length:Int = 0;
        var counter:Int = 0;
        var dx:Int = 0;
        var dy:Int = 0;
        var opacity:Int = 255;

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

        var hptr:Int = readUWord();
        var mptr:Int = readUWord();

        var bitmapData:BitmapData = parseHierarchy( hptr );
        var e:Image = new Image( bitmapData );
        e.move( dx, dy );
        e.setAlpha( opacity / 255 );
    
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
                
        var bmd:BitmapData = new BitmapData( w, h, true, 0x00000000 );

        var index:Int = 0;
        var tw:Int;
        var th:Int;
        var columns:Int = Math.ceil(w / 64);
        var rows:Int = Math.ceil(h / 64);
        var bytes:ByteArray;
        var rect:Rectangle = new Rectangle();
        for ( tptr in tilePtrs ) {
            tw = ((index+1) % columns == 0 ? w % 64 : 64 );
            th = ((index+1) % rows == 0 ? h % 64 : 64 );
            tw = ( tw == 0 ? 64 : tw );
            th = ( th == 0 ? 64 : th );
            bytes = parseTile( tptr, tw, th, bpp );
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

    private function parseTile( tptr:Int, w:Int, h:Int, bpp:Int ):ByteArray {
        //Main.log("tile "+w+" x "+h+" bpp "+bpp); 
        data.position = tptr;
        var compressed:Bool = true;
                
        var bytes:ByteArray = new ByteArray(); // ARGB sequence
        bytes.length = w*h*bpp;
        var size:Int;
        var val:Int;
        var length:Int;
        var count:Int;
        var pos:Int = 0;
        // RLE is RGBA
        for ( s in 0...4 ) {
            //bytes.position = (s + 1) % 4;
            pos = (s + 1) % 4;
            size = w*h;
            //Main.log("size "+size+" data pos "+data.position);
            count = 0;
    
            while (size > 0) {
                /*
                if ( true ) {
                    bytes.writeByte( 255 );
                    bytes.position += 3;
                    size -= 1;
                    continue;
                }*/

                if ( bpp == 3 && s == 3 ) {
                    //bytes.writeByte( 255 );
                    //bytes.position += 3;
                    bytes[ pos ] = 255;
                    pos += 4;
                    size -= 1;
                    continue;
                }                    

                length = readByte();
                if (length >= 128) {
                    length = 255 - (length - 1);
                    if (length == 128) {
                        length = 256*readByte() + readByte();
                    }
                    size -= length;
                    count += length;
                    while (length-- > 0) {
                        //bytes.writeByte( readByte() );
                        //bytes.position += 3;
                        bytes[ pos ] = readByte();
                        pos += 4;
                    }
                } else {
                    length += 1;
                    if (length == 128) {
                        length = 256*readByte() + readByte();
                    }
                    size -= length;
                    count += length;
    
                    val = readByte();  
                    for ( j in 0...length) {
                        //bytes.writeByte( val );
                        //bytes.position += 3;
                        bytes[ pos ] = val;
                        pos += 4;
                    }
                }
            }
            //Main.log("final position "+bytes.position+" count "+count);
        }
        return bytes;
    }

    public function parse( file:ByteArray ):Element {
        data = file;
        head = parseHeader();
        //Main.log("head: "+head);
        parseProperties();
        var e:Element = parseLayers();
        //var e:Element = new Element();
        return e;
    }

}
