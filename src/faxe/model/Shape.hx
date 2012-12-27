package faxe.model;

import nme.Assets;
import nme.display.Sprite;
import nme.display.DisplayObjectContainer;
import nme.display.Graphics;
import nme.geom.Rectangle;
import nme.geom.Matrix;

import format.svg.PathSegment;
import format.gfx.GfxGraphics;
import format.gfx.GfxExtent;
import format.svg.PathParser;
import format.svg.Path;
import format.svg.RenderContext;

import faxe.Main;
import faxe.model.IElement;

class Shape implements IElement 
{
    private var path:Path;
    public var fixedSize:Rectangle;

	public function new ( p:Path ) 
	{
        path = p;
        updateExtent();
	}

    private function updateExtent():Void {
        trace("extent shape "+path);
               
        var gfx:GfxExtent = new GfxExtent();
        var context:RenderContext = new RenderContext( path.matrix );
            //mScaleRect,mScaleW,mScaleH);

        for(segment in path.segments)           
            segment.toGfx(gfx, context);

        fixedSize = gfx.extent;
        trace( "first " + gfx.extent );
        var dx:Float = -gfx.extent.x;
        var dy:Float = -gfx.extent.y;

        trace("trimming by "+dx+" "+dy);

        path.matrix.translate( dx, dy );

        trace( "trimmed " + gfx.extent );
        trace( "trimmed fixedSize " + fixedSize );
    }

    public function render( isRoot:Bool = false ):DisplayNode {
        return null;
    }
    
}
