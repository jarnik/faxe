package faxe.model;

import nme.Assets;
import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.geom.ColorTransform;
import nme.events.Event;
import nme.events.MouseEvent;

import faxe.Main;
import jarnik.gaxe.Debug;

class GridAligner extends ElementSprite
{

	public function new ( w:Float, h:Float ) 
	{
        super( false );
        wrapperWidth = w;
        wrapperHeight = h;
        alignment.h = ALIGN_H_RIGHT;
        alignment.v = ALIGN_V_TOP;
        name = "grdimaster";
	}
    
    public function initGrid( 
        items:Array<ElementSprite>
        
    ):Void {
        var i:Int = 0;
        for ( e in items ) {
            addChild( e );
            e.x = i * 60;
            e.y = 0; 
            i++;
        }
    }

    override public function align( r:Rectangle = null ):Void {
        super.align( r );
    }

}
