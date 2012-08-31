package faxe.parser;

import nme.Assets;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObjectContainer;
import nme.utils.ByteArray;

import faxe.model.Element;

interface IParser
{

    function parse( file:ByteArray ):Element;

}
