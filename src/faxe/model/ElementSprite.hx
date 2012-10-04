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

class ElementSprite extends Sprite
{
    public var isContentNode:Bool;
    public var content:ElementSprite;

	public function new ( isContentNode:Bool = true ) 
	{
        super();
        this.isContentNode = isContentNode;
	}
    
    public function addContent( _content:ElementSprite, allowResetOrigin:Bool = true ):Void {
        content = _content;
        addChild( content );

        if ( allowResetOrigin )
            resetOrigin();
    }
   
    private function resetOrigin():Void {
        //Debug.log(" ... content x "+content.x+" rot "+content.rotation);
        var r:Rectangle = content.getBounds( this );
        //Debug.log(" ... bounds "+r);

        x = r.x;
        y = r.y;
        content.x -= r.x;
        content.y -= r.y;

        //Debug.log(" ... aligned "+element.x+" "+element.y);
        //Debug.log(" ... content "+content.x+" "+content.y);
    }


}
