package faxe.model;

import nme.Assets;
import nme.display.Sprite;
import nme.geom.Rectangle;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObjectContainer;

import faxe.Main;
import faxe.model.IElement;

class Image implements IElement
{
    public var bitmapData:BitmapData;
    public var fixedSize:Rectangle;

	public function new ( bmd:BitmapData ) 
	{
        bitmapData = bmd;
        fixedSize = new Rectangle( 0, 0, bitmapData.width, bitmapData.height );
	}

    public function render( isRoot:Bool = false ):DisplayNode {
        return NodeBitmap( new Bitmap( bitmapData ) );
    }

}
