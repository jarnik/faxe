package faxe.model;

import nme.Assets;
import nme.display.Sprite;
import nme.display.DisplayObjectContainer;
import nme.display.Graphics;
import nme.text.TextField;
import nme.text.TextFormat;

import faxe.Main;

class Text extends Element 
{
    public var tf:TextField;
    public var format:TextFormat;

	public function new () 
	{
        super();
        s = new Sprite();
        s.addChild( tf = new TextField() );
        format = new TextFormat();
	}

    override public function renderSelf():DisplayObjectContainer {        
        return s;
    }

}
