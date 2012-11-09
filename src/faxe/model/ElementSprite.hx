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
import jarnik.gaxe.Debug;

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
    v:ALIGN_V
}

class ElementSprite extends Sprite
{

    public var marginLeft:Float;
    public var marginRight:Float;
    public var marginTop:Float;
    public var marginBottom:Float;
    public var alignment:AlignConfig;
    public var wrapperWidth:Float;
    public var wrapperHeight:Float;

    public var content:Sprite;

    public var kids:Hash<ElementSprite>;

	public function new ( isRootNode:Bool = false ) 
	{
        super();
        
        marginLeft = 0;
        marginRight = 0;
        marginTop = 0;
        marginBottom = 0;

        kids = new Hash<ElementSprite>();

        alignment = { h: ALIGN_H_NONE, v: ALIGN_V_NONE };

        if ( isRootNode )
            addEventListener( Event.ADDED_TO_STAGE, onAddedToStage );
	}

    public function resetAlignment():Void {
        alignment.h = ALIGN_H_NONE;
        alignment.v = ALIGN_V_NONE;
    }

    public function align( r:Rectangle = null ):Void {
        // TODO when parent is transformed, alignment goes wild

        //Debug.log(name+" align CFG "+alignment+" margins "+marginLeft+" "+marginRight+" "+marginTop+" "+marginBottom);
        var w:Float = ( wrapperWidth > 0 ? wrapperWidth : 0 );
        var h:Float = ( wrapperHeight > 0 ? wrapperHeight : 0 );

        switch ( alignment.h ) {
            case ALIGN_H_LEFT:
                x = r.x + marginLeft;
            case ALIGN_H_RIGHT:
                x = r.x + r.width - w - marginRight;
            case ALIGN_H_CENTER:
                x = r.x + (r.width - w) / 2;
            case ALIGN_H_STRETCH:
                x = r.x;
                width = r.width;
            default:
        }

        switch ( alignment.v ) {
            case ALIGN_V_TOP:
                y = r.y + marginTop;
            case ALIGN_V_BOTTOM:
                y = r.y + r.height - h - marginBottom;
            case ALIGN_V_MIDDLE:
                y = r.y + (r.height - h) / 2;
            case ALIGN_V_STRETCH:
                y = r.y;
                height = r.height;
            default:                    
        }
        //Debug.log(name+" aligning myself to "+x+" "+y+" within "+r);        

        r.x = 0; r.y = 0;
        r.width = wrapperWidth < 0 ? r.width : wrapperWidth;
        r.height = wrapperHeight < 0 ? r.height : wrapperHeight;

        if ( content != null ) {
            r.x -= content.x;
            r.y -= content.y;
            //Debug.log(name+" aligning kids to "+r);
            for ( i in 0...content.numChildren ) {
                if ( Std.is( content.getChildAt( i ), ElementSprite ) )
                    cast( content.getChildAt( i ), ElementSprite ).align( r.clone() );
            }
        }
    }
    
    public function addSubElement( e:ElementSprite, ?x:Float, ?y:Float ):Void {
        if ( e.parent != null && e.parent.parent != null && Std.is( e.parent.parent, ElementSprite ) )
            cast(e.parent.parent,ElementSprite).removeSubElement( e );

        content.addChild( e );
        kids.set( e.name, e );
        if ( !Math.isNaN( x ) )
            e.x = x - content.x;
        if ( !Math.isNaN( y ) )
            e.y = y - content.y;
    }

    public function removeSubElement( e:ElementSprite ):Void {
        content.removeChild( e );
        kids.remove( e.name );
    }

    public function addContent( _content:Sprite, fixedSize:Rectangle = null ):Void {
        content = _content;
        addChild( content );

        var e:ElementSprite;
        for ( i in 0...content.numChildren ) {
            if ( Std.is( content.getChildAt( i ), ElementSprite ) ) {
                e = cast( content.getChildAt( i ), ElementSprite );
                kids.set( e.name, e );
            }
        }

        if ( fixedSize == null ) {
            //Debug.log(name +" pos "+x+" "+y+" content "+content.x+" "+content.y+" gonna measure bounds");
            var r:Rectangle = content.getBounds( this );
            x += r.x;
            y += r.y;
            content.x -= r.x;
            content.y -= r.y;
            wrapperWidth = r.width;
            wrapperHeight = r.height;
            //Debug.log(name +" my content is bounds "+r);
        } else {
            // negative size means inherit from parent
            wrapperWidth = -fixedSize.width;
            wrapperHeight = -fixedSize.height;
            //Debug.log(name + " wrapper shrinked to "+wrapperWidth+" "+wrapperHeight+" fixed "+fixedSize);
        }
        //Debug.log(name +" wrapper size "+wrapperWidth +" "+wrapperHeight+" pos "+x);

        // for all kids, set their respective border towards me
        for ( c in kids ) {
            c.marginLeft = c.x + content.x;
            c.marginTop = c.y + content.y;
            c.marginRight = Math.abs( wrapperWidth ) - (c.x + content.x + Math.abs(c.wrapperWidth));
            c.marginBottom = Math.abs( wrapperHeight ) - (c.y + content.y + Math.abs(c.wrapperHeight));
            //Debug.log(" > kid "+c.name+" margins "+c.marginLeft+" "+c.marginRight+" "+c.marginTop+" "+c.marginBottom);
            //Debug.log("wrapper "+wrapperWidth+" "+wrapperHeight+" c "+c.x+" "+c.y+" content "+content.x+" "+content.y+" c.wrapper "+c.wrapperWidth+" "+c.wrapperHeight);
        }
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
        if ( content != null && content.numChildren > 0 && 
            Std.is( content.getChildAt( 0 ), TextField )
        )
            cast( content.getChildAt( 0 ), TextField ).text = text;
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
        //Debug.log("Resizing "+name+" stage.stageWidth "+stage.stageWidth);
        align( new Rectangle( 0, 0, stage.stageWidth, stage.stageHeight ) );
    }

}
