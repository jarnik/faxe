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
    public var alpha:Float;

	public function new ( bmd:BitmapData ) 
	{
        bitmapData = bmd;
        fixedSize = new Rectangle( 0, 0, bitmapData.width, bitmapData.height );
        alpha = 1;
	}

    public function render( isRoot:Bool = false ):DisplayNode {
        var b:Bitmap = new Bitmap( bitmapData );
        b.alpha = alpha;
        return NodeBitmap( b );
    }

}
