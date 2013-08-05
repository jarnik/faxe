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
    public var alpha:Float;

	public function new ( p:Path ) 
	{
        path = p;
        //trace("matrix "+p.matrix);
        updateExtent();
        alpha = 1;
	}

    private function updateExtent():Void {
        //trace("extent shape "+path+" matrix "+path.matrix );
               
        var gfx:GfxExtent = new GfxExtent();
        var context:RenderContext = new RenderContext( path.matrix.clone() );
            //mScaleRect,mScaleW,mScaleH);

        for(segment in path.segments) { 
            //trace("segment "+segment.x+" "+segment.y);
            segment.toGfx(gfx, context);
        }

        fixedSize = gfx.extent;
        //trace( "first " + gfx.extent );
        var dx:Float = -gfx.extent.x;
        var dy:Float = -gfx.extent.y;

        //trace("trimming by "+dx+" "+dy);

        path.matrix.translate( dx, dy );

        //trace( "trimmed " + gfx.extent );
        //trace( "trimmed fixedSize " + fixedSize );
    }

    public function render( isRoot:Bool = false ):DisplayNode {
        var s:Sprite = new Sprite();
        s.x = fixedSize.x;
        s.y = fixedSize.y;
        //trace("rendering shape at "+s.x+" "+s.y);

        var inPath:Path = path;
        var m:Matrix = inPath.matrix.clone();
        var mGfx:GfxGraphics = new GfxGraphics( s.graphics );
        var context:RenderContext = new RenderContext( m );

        // Move to avoid the case of:
        //  1. finish drawing line on last path
        //  2. set fill=something
        //  3. move (this draws in the fill)
        //  4. continue with "real" drawing
        inPath.segments[0].toGfx(mGfx, context);
 
        switch(inPath.fill)
        {
           case FillGrad(grad):
              grad.updateMatrix(m);
              mGfx.beginGradientFill(grad);
           case FillSolid(colour):
              mGfx.beginFill(colour,inPath.fill_alpha);
           case FillNone:
              //mGfx.endFill();
        }
 
 
        if (inPath.stroke_colour==null)
        {
           //mGfx.lineStyle();
        }
        else
        {
           var style = new format.gfx.LineStyle();
           var scale = Math.sqrt(m.a*m.a + m.c*m.c);
           style.thickness = inPath.stroke_width*scale;
           style.alpha = inPath.stroke_alpha;
           style.color = inPath.stroke_colour;
           style.capsStyle = inPath.stroke_caps;
           style.jointStyle = inPath.joint_style;
           style.miterLimit = inPath.miter_limit;
           mGfx.lineStyle(style);
        }

        for(segment in path.segments)           
            segment.toGfx(mGfx, context);

        mGfx.endFill();
        mGfx.endLineStyle();

        s.alpha = alpha;

        return NodeShape( s );
    }
    
}
