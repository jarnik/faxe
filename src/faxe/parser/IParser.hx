package faxe.parser;

import nme.Assets;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.DisplayObjectContainer;
import nme.utils.ByteArray;

import faxe.model.IElement;
import faxe.model.ElementSprite;

class Parser {
    public static function parseAlign( id:String ):AlignConfig {
        var align:AlignConfig = { h: ALIGN_H_NONE, v: ALIGN_V_NONE, top: 0, bottom: 0, left: 0, right: 0 };

        var r:EReg = ~/.*\[([A-Za-z]*)\]/;
        if ( r.match( id ) ) {
            var cfg:String = r.matched(1).toUpperCase();
            //Debug.log("align: "+cfg);
            if ( cfg.indexOf("R") != -1 )
                align.h = ALIGN_H_RIGHT;
            if ( cfg.indexOf("L") != -1 )
                align.h = ALIGN_H_LEFT;
            if ( cfg.indexOf("C") != -1 )
                align.h = ALIGN_H_CENTER;
            if ( cfg.indexOf("T") != -1 )
                align.v = ALIGN_V_TOP;
            if ( cfg.indexOf("B") != -1 )
                align.v = ALIGN_V_BOTTOM;
            if ( cfg.indexOf("M") != -1 )
                align.v = ALIGN_V_MIDDLE;
            if ( cfg.indexOf("S") != -1 ) {
                align.v = ALIGN_V_STRETCH;
                align.h = ALIGN_H_STRETCH;
            }
        }

        return align;
    }

    public static function parseName( name:String ):String {
        var r:EReg = ~/([^\[]*)/;
        if ( !r.match( name ) )
            return name;
        return r.matched( 1 );
    }


}

interface IParser
{

    function parse( file:ByteArray ):IElement;

}
