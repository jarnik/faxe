package jarnik.faxe.core;

import nme.Assets;
import nme.display.Sprite;
import nme.display.DisplayObjectContainer;

import jarnik.faxe.Main;
import jarnik.faxe.model.Element;
import jarnik.faxe.model.Image;
import jarnik.faxe.parser.IParser;
import jarnik.faxe.parser.ParserSVG;

class Layout 
{
    public var root:Element;

	public function new (path:String) 
	{
        var p:IParser = new ParserSVG();
        root = p.parse( Assets.getBytes( path ) );
	}

    public function render(path:String):DisplayObjectContainer {
        return root.render();
    }

}
