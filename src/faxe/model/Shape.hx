package faxe.model;

import nme.Assets;
import nme.display.Sprite;
import nme.display.DisplayObjectContainer;
import nme.display.Graphics;

import faxe.Main;
import jarnik.gaxe.Debug;

class Shape extends Element 
{
    public var graphics:Graphics;

	public function new () 
	{
        super();
        s = new Sprite();
        graphics = s.graphics;
	}

    override public function renderSelf():DisplayObjectContainer {        
        return s;
    }

}
