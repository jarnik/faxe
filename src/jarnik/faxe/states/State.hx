package jarnik.faxe;

import nme.Assets;
import nme.events.Event;
import nme.events.MouseEvent;
import nme.geom.Point;
import nme.display.Bitmap;
import nme.display.FPS;
import nme.display.Graphics;
import nme.display.Sprite;
import nme.display.Stage;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.geom.Rectangle;
import nme.Lib;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.events.KeyboardEvent;
import nme.media.Sound;

enum States {
    STATE_TITLE;
}

class State extends Sprite 
{

    private var created:Bool;

    public function new() {
        super();
        created = false;

        addEventListener( Event.ADDED_TO_STAGE, onCreate );
    }

    private function onCreate( e:Event ):Void {
        if ( !created ) {
            created = true;
            create();
        }
        onReset();
    }

    private function create():Void {
    }

    private function onReset():Void {
        if ( !created )
            return;

        reset();
    }

    private function reset():Void {}
	
    public function log( msg:String ):Void {
        Main.log( msg );
    }

    public function update( elapsed:Float ):Void {
    }

}
