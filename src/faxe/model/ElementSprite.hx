package faxe.model;

import nme.Assets;
import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.text.TextField;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.geom.ColorTransform;
import nme.events.Event;
import nme.events.MouseEvent;

import faxe.Main;
import faxe.model.IElement;
//import gaxe.Debug;

enum ALIGN_H {
    ALIGN_H_NONE;
    ALIGN_H_LEFT;
    ALIGN_H_RIGHT;
    ALIGN_H_CENTER;
    ALIGN_H_STRETCH;
}

enum ALIGN_V {
    ALIGN_V_NONE;
    ALIGN_V_TOP;
    ALIGN_V_BOTTOM;
    ALIGN_V_MIDDLE;
    ALIGN_V_STRETCH;
}

typedef AlignConfig = {
    h:ALIGN_H,
    v:ALIGN_V,
    top:Float,
    bottom:Float,
    left:Float,
    right:Float
}

class ElementSprite extends Sprite
{

    public var element:IElement;
    public var alignment:AlignConfig;
    public var fixedSize:Rectangle;
    private var isLayer:Bool;

    public var kids:Hash<ElementSprite>;

	public function new ( autoAlign:Bool = false, isLayer:Bool = false ) 
	{
        super();
        
        this.isLayer = isLayer;
        kids = new Hash<ElementSprite>();

        resetAlignment();

        if ( autoAlign )
            addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
	}

    public function resetAlignment():Void {
        alignment = { h: ALIGN_H_NONE, v: ALIGN_V_NONE, top: 0, bottom: 0, left: 0, right: 0 };
    }

    public function align( r:Rectangle = null ):Void {
        //Debug.log(name+" align CFG "+alignment+" margins "+marginLeft+" "+marginRight+" "+marginTop+" "+marginBottom);
        var w:Float = fixedSize.width;
        var h:Float = fixedSize.height;

        switch ( alignment.h ) {
            case ALIGN_H_LEFT:
                x = r.x + alignment.left;
            case ALIGN_H_RIGHT:
                x = r.x + r.width - w - alignment.right;
                //trace("going right to "+r+" "+w+" ar "+alignment.right+" x "+x);
            case ALIGN_H_CENTER:
                x = r.x + (r.width - w) / 2;
            case ALIGN_H_STRETCH:
                x = r.x;
                width = r.width;
            default:
        }

        switch ( alignment.v ) {
            case ALIGN_V_TOP:
                y = r.y + alignment.top;
            case ALIGN_V_BOTTOM:
                y = r.y + r.height - h - alignment.bottom;
            case ALIGN_V_MIDDLE:
                y = r.y + (r.height - h) / 2;
            case ALIGN_V_STRETCH:
                y = r.y;
                height = r.height;
            default:                    
        }
        //trace(name+" aligning myself to "+x+" "+y+" within "+r+" by "+alignment);        

        r.x = 0; r.y = 0;
        r.width = isLayer ? r.width : w;
        r.height = isLayer ? r.height : h;

        for ( kid in kids )
            kid.align( r.clone() );
    }
    
    public function addSubElement( e:DisplayNode, ?x:Float, ?y:Float ):Void {
        var d:DisplayObject = null;
        switch ( e ) {
            case NodeElement( e ):
                kids.set( e.name, e );
                d = e;
                if ( d.parent != null && Std.is( d.parent, ElementSprite ) )
                    cast(d.parent,ElementSprite).removeSubElement( cast( d,ElementSprite ) );
            case NodeBitmap( b ):
                d = b;
            case NodeShape( s ):
                d = s;
            case NodeText( t ):
                d = t;
        }

        addChild( d );
    }

    public function removeSubElement( e:ElementSprite ):Void {
        removeChild( e );
        kids.remove( e.name );
    }

    public function fetch( path:String ):ElementSprite {
        var e:ElementSprite = null;

        var pathElements:Array<String> = path.split("."); 

        var kid:ElementSprite = kids.get( pathElements[0] );
                
        //Debug.log("fetching kid "+pathElements[0]+" > "+kid);

        if ( kid == null )
            return null;

        if ( pathElements.length == 1 )
            return kid;

        return kid.fetch( path.substr( path.indexOf(".")+1 ) );
    }

    public function onClick( _callback:Dynamic = null ):Void {
        buttonMode = true;
        mouseChildren = false;
        addEventListener( MouseEvent.CLICK, _callback );
    }

    public function onEvents( events:Array<String>, _callback:Dynamic = null ):Void {
        buttonMode = true;
        mouseChildren = false;
        for ( e in events )
            addEventListener( e, _callback );
    }

    public function setText( text:String ):Void {
        /*
        if ( content != null && content.numChildren > 0 && 
            Std.is( content.getChildAt( 0 ), TextField )
        )
            cast( content.getChildAt( 0 ), TextField ).text = text;
            */
    }
 
    public function copyPosition( e:ElementSprite ):Void {
        x = e.x;
        y = e.y;
    }

    private function onAddedToStage( e:Event ):Void {        
        //Debug.log("added to stage "+name);
        stage.addEventListener( Event.RESIZE, onResize );
        onResize();
    }

    private function onResize( e:Event = null ):Void {
        if ( stage == null )
            return;
        //trace("Resizing "+name+" stage.stageWidth "+stage.stageWidth);
        align( new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight ) );
    }

}
