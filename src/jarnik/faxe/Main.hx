package jarnik.faxe;

import nme.Assets;
import nme.display.Sprite;
import nme.display.Stage;
import nme.text.TextField;
import nme.text.Font;
import nme.text.TextFormat;
import nme.events.KeyboardEvent;

class Main extends Sprite 
{
    private static var inited:Bool;
    public static var w:Int;
    public static var h:Int;
    private static var state:State;
    private static var prevState:State;
    private static var states:Hash<State>;
    public static var upscale:Float;
    private static var stateLayer:Sprite;
    private static var debug:TextField;
    private static var buffer:String;
    private static var timeElapsed:Float;
    private static var prevFrameTime:Float;
    public static var font:Font;
    public static var format:TextFormat;
    private static var debugLayer:Sprite;
   
    public static function switchState( newState:States ):Void {
        prevState = state;
        Main.log("State: "+newState);
        if ( state != null ) {
            state.visible = false;
		    stateLayer.removeChild( state );
        }
        state = getState( newState );
        state.visible = true;
		stateLayer.addChild( state );
        state.scaleX = upscale;
        state.scaleY = upscale;
    }

    private static function getState( s:States ):State {
        if ( states == null )
            states = new Hash<State>();

        var state:State = states.get( Std.string(s) );
        if ( state != null ) {
            Main.log("got cached: "+state);
            return state;
        }
        
        switch ( s ) {
            case STATE_TITLE:
                state = new TitleState();
            default:
        }
        states.set( Std.string(s), state );
        Main.log("built new: "+state);
        return state;
    }

    private static function initLog():Void {
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;        

        stateLayer = new Sprite();
		Lib.current.addChild( stateLayer );

        font = Assets.getFont ("assets/fonts/nokiafc22.ttf");
        format = new TextFormat (font.fontName, 16, 0xFF0000);

        Lib.current.stage.addChild( debugLayer = new Sprite() );

        debug = new TextField(); 
        debug.defaultTextFormat = format;
        debug.height = 400;
        debug.width = 800;
        debug.selectable = false;
        debug.mouseEnabled = false;
        debug.embedFonts = true;
        debug.wordWrap = true;
        debug.x = 20;
        debug.y = 200;
        if ( buffer == null )
            buffer = "";
        debug.text = buffer;
        debugLayer.addChild(debug);
        //debugLayer.scaleX = upscale;
        //debugLayer.scaleY = upscale;

        debugLayer.mouseEnabled = false;
        debugLayer.visible = false;

        Lib.current.stage.addEventListener( Event.ENTER_FRAME, update );
        Lib.current.stage.addEventListener( KeyboardEvent.KEY_UP, keyHandler );
        prevFrameTime = Lib.getTimer() / 1000;

        //Lib.current.stage.addChild( new FPS( 10, 10, 0xffffff ) );
    }

    public static function showLog():Void {
        debugLayer.visible = true;
    }

	private static function update( e:Event ) {
        if ( !inited ) {
            init();
        }

        var now:Float = Lib.getTimer() / 1000;
        timeElapsed = (now - prevFrameTime);
        prevFrameTime = now;

        if ( state != null ) {
            state.update( timeElapsed );
        }
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
        
        switchState( STATE_PLAY );
    }

    public static function getPrevState():State {
        return prevState;
    }
	
    public static function keyHandler( e:KeyboardEvent ):Void {
        switch ( e.keyCode ) {
            case 219:
                debugLayer.visible = !debugLayer.visible;
            default:
        }
    }

    public static function log( msg:String ):Void {
        if ( buffer == null )
            buffer = "";
        if ( debug == null ) {
            buffer = msg+"\n"+buffer;
            return;
        }
        #if android
        trace( msg );
        #end

        debug.text = msg+"\n"+debug.text;
    }

}
