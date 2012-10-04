package faxe.core;

import nme.Assets;
import nme.display.Sprite;
import nme.display.DisplayObjectContainer;

import faxe.Main;
import faxe.model.Element;
import faxe.model.Image;
import faxe.parser.IParser;
import faxe.parser.ParserSVG;
import faxe.parser.ParserXCF;

class Layout 
{
    public var root:Element;

	public function new (path:String) 
	{
        var p:IParser = new ParserSVG();
        //var p:IParser = new ParserXCF();
        root = p.parse( Assets.getBytes( path ) );
	}

    public function render(path:String = null):DisplayObjectContainer {
        return root.render();
    }

}
