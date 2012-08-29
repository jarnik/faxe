package jarnik.faxe.model;

import nme.Assets;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObjectContainer;

import jarnik.faxe.Main;

class Image extends Element
{
    public var bitmapData:BitmapData;
    private var bitmap:Bitmap;

	public function new ( bmd:BitmapData ) 
	{
        super();
        bitmapData = bmd;
        bitmap = new Bitmap( bitmapData );
	}

    override public function renderSelf():DisplayObjectContainer {
        var d:DisplayObjectContainer = super.renderSelf();
        d.addChild( bitmap );
        return d;
    }

}
