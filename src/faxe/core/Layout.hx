package faxe.core;

import nme.Assets;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.geom.Rectangle;
import nme.display.DisplayObjectContainer;

import faxe.Main;
import faxe.model.IElement;
import faxe.model.ElementSprite;
import faxe.model.Image;
import faxe.model.Group;
import faxe.parser.IParser;
//import faxe.parser.ParserSVG;
import faxe.parser.ParserSVG2;
import faxe.parser.ParserXCF;

class Layout 
{
    public var root:Group;
    public var d:ElementSprite;

	public function new (path:String) 
	{
        var extension:String = path.substr( path.lastIndexOf( "." )+1 ).toLowerCase();
        var p:IParser = null;
        switch ( extension ) {
            case "svg":
                p = new ParserSVG2();
            case "xcf":
                p = new ParserXCF();
            default:
                trace("format "+extension+" not supported!");
        }
        root = cast( p.parse( Assets.getBytes( path ) ), Group );
	}

    public function render( autoAlign:Bool = true, path:String = null ):ElementSprite {
        var g:Group = root;
        if ( path != null )  
            g = root.fetch( path );

        if ( g == null ) {
            //Debug.log("path "+path+" not found!");
            trace("path "+path+" not found!");
            return null;
        }

        var n:DisplayNode = g.render( autoAlign );
        switch ( n ) {
            case NodeElement( e ):
                return e;
            default:
                return null;
        }
    }
}
