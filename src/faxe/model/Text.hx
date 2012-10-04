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
        tf = new TextField();
        format = new TextFormat();
	}

    override public function renderSelf():ElementSprite {        
        var _s:ElementSprite = new ElementSprite();
        var _tf:TextField;
        _s.addChild( _tf = new TextField() );
        _tf.defaultTextFormat = format;
        _tf.text = tf.text;
        return _s;
    }

}
