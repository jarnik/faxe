package faxe.model;

import nme.Assets;
import nme.display.Sprite;
import nme.display.DisplayObjectContainer;
import nme.display.Graphics;

import faxe.Main;

class Shape extends Element 
{
    public var graphics:Graphics;
    private var s:Sprite;

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
