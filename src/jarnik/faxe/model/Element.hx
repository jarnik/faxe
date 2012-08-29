package jarnik.faxe.model;

import nme.Assets;
import nme.display.Sprite;
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
	}

    public function render():DisplayObjectContainer {
        return null;
    }

}
