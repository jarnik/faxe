package jarnik.faxe.core;

import nme.Assets;
import nme.display.Sprite;
import nme.display.DisplayObjectContainer;

import jarnik.faxe.Main;
import jarnik.faxe.model.Element;
import jarnik.faxe.model.Image;

class Layout 
{

	public function new () 
	{
	}

    public function render(path:String):DisplayObjectContainer {
        var e:Element;

        var img:Image = new Image( Assets.getBitmapData("assets/heart.png"));

        return img.render();
    }

}
