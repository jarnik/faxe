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
    public var s:Sprite;

	public function new () 
	{
        super();
        s = new Sprite();
        graphics = s.graphics;
	}

    override public function renderContent():Sprite {        
        /*
        var s:ElementSprite = super.renderSelf();
        s.graphics.copyFrom( graphics );
        return s;*/
        
        var s:Sprite = super.renderContent();
        s.graphics.copyFrom( graphics );
        return s;

    }

}
