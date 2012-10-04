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

class Element
{
    public var transform:Matrix;
    public var color:ColorTransform;
    public var children:Array<Element>;
    public var name:String;
    public var s:Sprite;

	public function new () 
	{
        children = [];
        name = "";
        transform = new Matrix();
        transform.identity();
        color = new ColorTransform();
	}

    public function renderSelf():ElementSprite {
        return new ElementSprite();
    }

    public function move( x:Float, y:Float ):Void {
        transform.translate( x, y );
    }

    public function setAlpha( alpha:Float ):Void {
        color.alphaMultiplier = alpha;
    }

    public function toString():String {
        var out:String = "> "+name+" start\n";
        for ( c in children )
            out += c.toString()+"\n";
        out += "< "+name+" end\n";
        return out;
    }

    public function addChild( e:Element ):Void {
        children.push( e );
    }

    public function addChildAt( e:Element, index:Int ):Void {
        children.insert( index, e );
    }

    public function render( isRoot:Bool = false ):DisplayObjectContainer {
        var d:ElementSprite = new ElementSprite( false );
        
        var content:ElementSprite = renderSelf();        
        content.transform.matrix = transform;
        content.transform.colorTransform = color;
        var c:DisplayObject;
        for ( e in children ) {
            c = e.render();
            content.addChild( c );
        }
        //Debug.log(" x "+d.x+" "+d.rotation);

        d.addContent( content, !isRoot );
        return d;
    }

}
