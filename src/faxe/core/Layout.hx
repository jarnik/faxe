package faxe.core;

import nme.Assets;
import nme.display.Sprite;
import nme.events.MouseEvent;
import nme.geom.Rectangle;
import nme.display.DisplayObjectContainer;

import jarnik.gaxe.Gaxe;
import jarnik.gaxe.Debug;

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

    public function render(path:String = null):ElementSprite {
        var d:ElementSprite = root.render( true );

        /*
        var e:ElementSprite = d.fetch("layer3.rect.rect3000");
        //e.alignment.h = ALIGN_H_LEFT;
        e.onClick( clickTest );
        Debug.log("fetched "+e);*/

        return d;
    }

    public function clickTest( e:MouseEvent = null ):Void {
        Debug.log("CLICKED!");
    }

}
