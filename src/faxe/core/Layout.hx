package faxe.core;

import nme.Assets;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.geom.Rectangle;
import nme.display.DisplayObjectContainer;

import gaxe.Gaxe;
import gaxe.Debug;

import faxe.Main;
import faxe.model.Element;
import faxe.model.ElementSprite;
import faxe.model.Image;
import faxe.parser.IParser;
import faxe.parser.ParserSVG;
//import faxe.parser.ParserXCF;

class Layout 
{
    public var root:Element;
    public var d:ElementSprite;

	public function new (path:String) 
	{
        var p:IParser = new ParserSVG();
        //var p:IParser = new ParserXCF();
        root = p.parse( Assets.getBytes( path ) );
	}

    public function render( isRoot:Bool = true, path:String = null):ElementSprite {
        var e:Element = root;
        if ( path != null )  
            e = root.fetch( path );

        if ( e == null ) {
            Debug.log("path "+path+" not found!");
            return null;
        }

        var d:ElementSprite = e.render( isRoot, root.fixedSize );

        return d;
    }
}
