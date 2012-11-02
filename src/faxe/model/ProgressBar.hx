package faxe.model;

import nme.Assets;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.geom.Matrix;
import nme.geom.ColorTransform;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.FPS;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.display.Stage;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.filters.GlowFilter;
import nme.geom.Rectangle;
import nme.Lib;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.text.TextFormatAlign;
import nme.events.KeyboardEvent;
import com.eclecticdesignstudio.motion.Actuate;

import jarnik.gaxe.Debug;
import faxe.model.ElementSprite;
import faxe.model.Element;
import faxe.model.GridAligner;

class ProgressBar extends ElementSprite 
{   
    private var ITEM_COUNT:Int;
    private static inline var ITEM_MAX_COUNT:Int = 9;

    private var gFull:GridAligner;
    private var gEmpty:GridAligner;

    private var creditsFull:Array<ElementSprite>;
    private var creditsEmpty:Array<ElementSprite>;

    private var w:Float;
    private var stride:Float;

	public function new ( isRootNode:Bool = false, full:Element, empty:Element, w:Float, count:Int, ?stride:Float ) 
	{
		super( isRootNode );

        creditsFull = [];
        creditsEmpty = [];
         
        this.w = w;
        this.stride = stride;

        gFull = new GridAligner();
        gFull.alignment.h = ALIGN_H_CENTER;
        gFull.name = "gridFull";
        gEmpty = new GridAligner();
        gEmpty.alignment.h = ALIGN_H_CENTER;
        gEmpty.name = "gridEmpty";
          
        addChild( gEmpty );
        addChild( gFull );

        var e:ElementSprite = null;
        for ( i in 0...ITEM_MAX_COUNT ) {
            e = empty.render( false, empty.fixedSize );
            creditsEmpty.push( e );

            e = full.render( false, full.fixedSize );
            creditsFull.push( e );
        }

        wrapperWidth = w;
        wrapperHeight = e.wrapperHeight;

        rebuild( count );

        wrapperWidth = w;
        wrapperHeight = e.wrapperHeight;

        setValue( 0 );
    }

    public function rebuild( count:Int ):Void {
        ITEM_COUNT = count;

        var s:Float = (Math.isNaN( stride ) ? w / count : stride );
        gFull.initGrid( w, wrapperHeight, creditsFull.slice( 0, count ), count, s );
        gEmpty.initGrid( w, wrapperHeight, creditsEmpty.slice( 0, count ), count, s );
    }

    public function setValue( credits:Int ):Void {
        //Debug.log("set value "+credits+" of "+ITEM_COUNT+" < "+ITEM_MAX_COUNT);
        for ( i in 0...ITEM_MAX_COUNT ) {
            creditsFull[ i ].visible = ( i < credits ) && ( i < ITEM_COUNT );
            creditsEmpty[ i ].visible = ( i >= credits ) && ( i < ITEM_COUNT );
        }
    }

    override public function align( r:Rectangle = null ):Void {
        super.align( r.clone() );

        r.x = ( r.width > wrapperWidth ? 0 : (wrapperWidth - r.width)/2 ); 
        r.y = 0;
        r.width = Math.min( r.width, wrapperWidth );
        r.height = Math.min( r.height, wrapperHeight );

        gFull.align( r.clone() );
        gEmpty.align( r.clone() );
    }

}
