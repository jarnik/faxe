package faxe.model;

import nme.Assets;
import nme.text.TextField;
import nme.display.Bitmap;
import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.geom.ColorTransform;

import faxe.Main;
import faxe.model.ElementSprite;

enum DisplayNode {
    NodeElement( e:ElementSprite );
    NodeBitmap( b:Bitmap );
    NodeShape( s:Sprite );
    NodeText( t:TextField );
}

interface IElement
{
    var fixedSize:Rectangle;
    var alpha:Float;

    function render( isRoot:Bool = false ):DisplayNode;
}


