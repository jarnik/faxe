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

    private var gFull:GridAligner;
    private var gEmpty:GridAligner;

    private var creditsFull:Array<ElementSprite>;
    private var creditsEmpty:Array<ElementSprite>;

	public function new ( isRootNode:Bool = false, full:Element, empty:Element, w:Float, count:Int ) 
	{
		super( isRootNode );

        ITEM_COUNT = count;

        creditsFull = [];
        creditsEmpty = [];
            
        var e:ElementSprite = null;
        for ( i in 0...ITEM_COUNT ) {
            e = empty.render( false, empty.fixedSize );
            creditsEmpty.push( e );

            e = full.render( false, full.fixedSize );
            creditsFull.push( e );
        }

        wrapperWidth = w;
        wrapperHeight = e.wrapperHeight;

        gFull = new GridAligner();
        gFull.name = "gridFull";
        gFull.initGrid( wrapperWidth, wrapperHeight, creditsFull, count, w / count );

        gEmpty = new GridAligner();
        gEmpty.name = "gridEmpty";
        gEmpty.initGrid( wrapperWidth, wrapperHeight, creditsEmpty, count, w / count );

        var content:Sprite = new Sprite();
        content.addChild( gEmpty );
        content.addChild( gFull );

        addContent( content );
    }

    public function setValue( credits:Int ):Void {
        for ( i in 0...ITEM_COUNT ) {
            creditsFull[ i ].visible = ( i < credits );
            creditsEmpty[ i ].visible = ( i >= credits );
        }
    }

}
