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

    override public function renderContent():Sprite {        
        var _s:Sprite = super.renderContent();
        var _tf:TextField;
        _s.addChild( _tf = new TextField() );
        _tf.defaultTextFormat = format;
        _tf.multiline = tf.multiline;
        _tf.text = tf.text;
        _tf.alpha = tf.alpha;
        _tf.embedFonts = true;
        _tf.selectable = false;

        if ( !_tf.multiline ) {
            _tf.width = _tf.textWidth;
            _tf.height = _tf.textHeight;
            _tf.y -= _tf.textHeight - 5;
        } else { 
            _tf.width = tf.width;
            _tf.height = tf.height;
            _tf.y -= 5;
        }

        return _s;
    }

}
