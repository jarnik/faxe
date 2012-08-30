package jarnik.faxe.model;

import nme.Assets;
import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.geom.Matrix;

import jarnik.faxe.Main;

class Element
{
    public var transform:Matrix;
    public var children:Array<Element>;
    public var name:String;

	public function new () 
	{
        children = [];
        name = "";
        transform = new Matrix();
        transform.identity();
	}

    public function renderSelf():DisplayObjectContainer{
        return new Sprite();
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

    public function render():DisplayObjectContainer {
        var d:DisplayObjectContainer = renderSelf();
        var c:DisplayObject;
        for ( e in children ) {
            c = e.render();
            d.addChild( c );
        }
        return d;
    }

}
