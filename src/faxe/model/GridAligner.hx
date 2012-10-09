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

    private var cols:Int;
    private var stride:Float; // px center distances
    private var items:Array<ElementSprite>;
    private var fullWidth:Float;
    private var fullHeight:Float;

	public function new () 
	{
        super( false );
        name = "grid"+Math.round( Math.random()*1000 );
	}
    
    public function initGrid( 
        w:Float,
        h:Float,
        items:Array<ElementSprite>,
        cols:Int,
        stride:Float        
    ):Void {
        wrapperWidth = fullWidth = w;
        wrapperHeight = fullHeight = h;
        this.items = items;
        this.cols = cols;
        this.stride = stride;

        var e:ElementSprite;
        for ( i in 0...items.length ) {
            e = items[ i ];
            addChild( e );
            e.x = (i % cols)*stride - e.wrapperWidth / 2 + (w - (cols-1)*stride)/2;
            e.y = Math.floor(i / cols)*stride - e.wrapperHeight / 2 + (h - Math.floor(items.length / cols)*stride)/2;
        }
    }

    override public function align( r:Rectangle = null ):Void {

        var scale:Float = 1;
        if ( r.width < fullWidth || r.height < fullHeight ) {
            if ( fullWidth/fullHeight > r.width/r.height )
                scale = r.width / fullWidth;
            else
                scale = r.height / fullHeight;
        }

        if ( scaleX != scale ) {
            scaleX = scale;
            scaleY = scale;
            wrapperWidth = fullWidth*scale;
            wrapperHeight = fullHeight*scale;
        }

        super.align( r );
    }

}
