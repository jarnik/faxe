package jarnik.faxe.parser;

import nme.Assets;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.display.DisplayObjectContainer;
import nme.utils.ByteArray;

import jarnik.faxe.model.Element;
import jarnik.faxe.model.Image;
import jarnik.faxe.model.Shape;
import jarnik.faxe.Main;

class ParserSVG implements IParser
{
	public function new () {
    }

    public function parse( file:ByteArray ):Element {
        var xml:Xml = Xml.parse( file.toString() );
        var root:Xml = null;
        for ( ee in xml ) {
            if ( ee.nodeType == Xml.Element )
                root = ee;
        }

        //var e:Element = new Element();
        //e.name = "kokodac "+root.get("width")+" x "+root.get("height");

        return parseElement( root );
        //return e;
    }

    private function parseShapeStyle( g:Graphics, style:String ):Void {
        var paramSplit:Array<String> = style.split(";");
        var params:Hash<String> = new Hash<String>();
        var vals:Array<String> = null;
        for ( p in paramSplit ) {
            vals = p.split(":");
            params.set( vals[0], vals[1] );
        }
        g.beginFill(
            Std.parseInt( "0x"+params.get("fill").substr(1) )
            , 1
        );

    }

    private function parseElement( xml:Xml ):Element {        
        var element:Element = null;

        var image:Image;
        var shape:Shape;
        switch ( xml.nodeName ) {
            case "svg:g":
                element = new Element(); 
            case "svg:image":
                image = new Image( Assets.getBitmapData( "assets/"+xml.get("xlink:href") ) ); 
                element = image;
            case "svg:rect":
                Main.log("rect");
                shape = new Shape(); 
                parseShapeStyle( shape.graphics, xml.get("style") );
                shape.graphics.drawRect(
                    Std.parseFloat( xml.get("x") ),
                    Std.parseFloat( xml.get("y") ),
                    Std.parseFloat( xml.get("width") ),
                    Std.parseFloat( xml.get("height") )
                );
                element = shape;
            default:
                //Main.log("uninmplemented "+xml.nodeName);
                element = new Element(); 
        }
        element.name = xml.get("id");

        if ( element != null )
            for ( e in xml ) {
                if ( e.nodeType != Xml.Element )
                    continue;
                switch ( e.nodeName ) {
                    case "svg:g", "svg:image", "svg:rect":
                        element.addChild( parseElement( e ) );
                }
            }
        return element;
    }

}
