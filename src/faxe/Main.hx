package faxe;

import nme.Assets;
import nme.display.Sprite;
import nme.display.Stage;
import nme.display.DisplayObjectContainer;
import nme.text.TextField;
import nme.text.Font;
import nme.text.TextFormat;
import nme.Lib;
import nme.display.Stage;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.events.Event;
import nme.events.KeyboardEvent;

import faxe.core.Layout;
import faxe.core.FaXe;

class Main extends Sprite 
{
    private static var inited:Bool;
    public static var w:Int;
    public static var h:Int;
    public static var upscale:Float;
    private static var stateLayer:Sprite;
    private static var buffer:String;
    private static var timeElapsed:Float;
    private static var prevFrameTime:Float;
    public static var font:Font;
    public static var format:TextFormat;

    private static function initLog():Void {
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;        

        stateLayer = new Sprite();
		Lib.current.addChild( stateLayer );

        Lib.current.stage.addEventListener( Event.ENTER_FRAME, update );
        prevFrameTime = Lib.getTimer() / 1000;

        //Lib.current.stage.addChild( new FPS( 10, 10, 0xffffff ) );
    }

	private static function update( e:Event ) {
        if ( !inited ) {
            init();
        }

        var now:Float = Lib.getTimer() / 1000;
        timeElapsed = (now - prevFrameTime);
        prevFrameTime = now;
    }

	// Entry point
	public static function main() {
        inited = false;
        initLog();
	}

    private static function init():Void {
        inited = true;

        // image is 120x80
        // optimus is 480x320
        // flash 720x480
        w = 480;
        h = 320;       
        upscale = Lib.current.stage.stageWidth / w;
        
        test();
    }

    private static function test():Void {
        //var layout:Layout = FaXe.load("assets/layouts/layout.svg");
        //var layout:Layout = FaXe.load("assets/layouts/layout.xcf");

        var now:Float = Lib.getTimer() / 1000;
        //var layout:Layout = FaXe.load("assets/layouts/scene.xcf");
        var layout:Layout = FaXe.load("assets/layouts/layout.svg");
        //var layout:Layout = FaXe.load("assets/layouts/garage.xcf");


        var gui:DisplayObjectContainer = layout.render();
        stateLayer.addChild( gui ); 

        trace("gui "+gui.numChildren+" "+gui.x);
        trace("gui "+gui.getChildAt(0).name+" "+gui.getChildAt(0).x);
        trace("gui "+cast( gui.getChildAt(0), DisplayObjectContainer ).getChildAt(0).name+" "+cast( gui.getChildAt(0), DisplayObjectContainer ).getChildAt(0).x);

        /*
        var now2:Float = Lib.getTimer() / 1000;
        Main.log("parse done! "+( now2 - now) );
        */
        //Main.log( layout.toString("assets/layout.svg") );
        //layout.toString("assets/layouts/layout.svg");
    }

}
