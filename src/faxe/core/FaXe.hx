package faxe.core;

import nme.Assets;
import nme.display.Sprite;

import faxe.Main;

class FaXe 
{

    public static function load( url:String ):Layout {
        return new Layout( url );
    }

}
