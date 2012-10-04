package faxe.model;

import nme.Assets;
import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.geom.ColorTransform;

import faxe.Main;
import jarnik.gaxe.Debug;

enum ALIGN_H {
    ALIGN_H_NONE;
    ALIGN_H_LEFT;
    ALIGN_H_RIGHT;
    ALIGN_H_STRETCH;
}

enum ALIGN_V {
    ALIGN_V_NONE;
    ALIGN_V_TOP;
    ALIGN_V_BOTTOM;
    ALIGN_V_STRETCH;
}

class ElementSprite extends Sprite
{

    public var marginLeft:Float;
    public var marginRight:Float;
    public var marginTop:Float;
    public var marginBottom:Float;
    public var alignH:ALIGN_H;
    public var alignV:ALIGN_V;

    public var isContentNode:Bool;
    public var content:ElementSprite;

	public function new ( isContentNode:Bool = true ) 
	{
        super();
        
        marginLeft = 0;
        marginRight = 0;
        marginTop = 0;
        marginBottom = 0;

        alignH = ALIGN_H_NONE;
        alignV = ALIGN_V_NONE;

        this.isContentNode = isContentNode;
	}

    public function align( r:Rectangle = null ):Void {
        if ( isContentNode ) {
            r.x -= x;
            r.y -= y;
            Debug.log(name+" aligning kids to "+r);
            for ( i in 0...numChildren ) {
                if ( Std.is( getChildAt( i ), ElementSprite ) )
                    cast( getChildAt( i ), ElementSprite ).align( r.clone() );
            }
        } else {
            var dx:Float = (x - r.x);
            Debug.log(name+" aligning myself to "+0+" within "+r);
            r.width -= dx;
            x -= dx;
            //r = getBounds( parent );
            r.x = 0; r.y = 0;
            Debug.log(name+" sending to content area "+r);
            content.align( r );
        }
    }
    
    public function addContent( _content:ElementSprite, allowResetOrigin:Bool = true ):Void {
        content = _content;
        addChild( content );

        if ( allowResetOrigin )
            resetOrigin();
    }
   
    private function resetOrigin():Void {
        Debug.log(" resetting origin for content "+content.name+" within wrapper ");
        Debug.log(" ... content x "+content.x+" rot "+content.rotation);
        var r:Rectangle = content.getBounds( this );
        Debug.log(" ... bounds of content within wrapper "+r);

        x = r.x;
        y = r.y;
        content.x -= r.x;
        content.y -= r.y;

        Debug.log(" ... wrapper within ist parent will be "+x+" "+y);
        Debug.log(" ... content within wrapper will be "+content.x+" "+content.y);
    }

}
