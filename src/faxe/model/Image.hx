package faxe.model;

import nme.Assets;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObjectContainer;

import faxe.Main;

class Image extends Element
{
    public var bitmapData:BitmapData;

	public function new ( bmd:BitmapData ) 
	{
        super();
        bitmapData = bmd;
	}

    /*
    override public function renderContent():Sprite {
        var s:Sprite = super.renderContent();
        s.addChild( new Bitmap( bitmapData ) );
        return s;
    }*/

}
