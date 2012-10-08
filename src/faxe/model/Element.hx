package faxe.model;

import nme.Assets;
import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.geom.ColorTransform;

import faxe.Main;
import faxe.model.ElementSprite;
import jarnik.gaxe.Debug;

class Element
{
    public var transform:Matrix;
    public var color:ColorTransform;
    public var children:Array<Element>;
    public var name:String;
    public var alignment:AlignConfig;
    public var fixedSize:Rectangle;
    public var opacity:Float;

	public function new () 
	{
        children = [];
        name = "";
        transform = new Matrix();
        transform.identity();
        color = new ColorTransform();
        alignment = { h: ALIGN_H_NONE, v: ALIGN_V_NONE };
        opacity = 1;
	}

    public function renderContent():Sprite {
        var s:Sprite = new Sprite();
        s.transform.matrix = transform;
        s.transform.colorTransform = color;
        s.alpha = opacity;
        return s;
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

    public function render( isRoot:Bool = false, _parentSize:Rectangle = null ):ElementSprite {

        if ( fixedSize != null && _parentSize != null )
            fixedSize = _parentSize;

        var e:ElementSprite = new ElementSprite( isRoot );
        e.name = name;
        e.alignment = alignment;

        var c:Sprite = renderContent();

        for ( e in children ) {
            c.addChild( 
                e.render( false, fixedSize ) 
            );
        }

        e.addContent( c, fixedSize );

        return e;
    }

}
