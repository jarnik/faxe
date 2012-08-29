package jarnik.faxe;

import nme.Assets;

import jarnik.games.passengers.Main;


class TitleState extends State 
{

	public function new () 
	{
		super();
	}

    override private function create():Void {
         var layout:Layout = FaXe.load("assets/layout.xcf");
         var gui:Sprite = layout.render("player");
         addChild( gui ); 
    }

    override private function reset():Void {
    }

    override public function update( timeElapsed:Float ):Void {
    }

}
