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
import gaxe.Debug;

class Shape extends Element 
{
    public var path:Path;
    public var extent:Rectangle;

	public function new () 
	{
        super();
        path = new Path();
        path.segments = [];
        path.fill = FillNone;
	}

    public function updateExtent():Void {
        var gfx:GfxExtent = new GfxExtent();
        var m:Matrix = transform.clone();
        var context:RenderContext = new RenderContext( m );
        for(segment in path.segments)
           segment.toGfx(gfx, context);
        this.extent = gfx.extent;
    }

    override public function renderContent():Sprite {        
        var s:Sprite = super.renderContent();
        var inPath:Path = path;

        if ( inPath.segments.length==0 )
           return s;

        var m:Matrix = s.transform.matrix.clone();
        m.identity();
        var gfx:GfxGraphics = new GfxGraphics( s.graphics );
        var context:RenderContext = new RenderContext( m );

        inPath.segments[0].toGfx(gfx, context);

        switch(inPath.fill)
        {
           case FillGrad(grad):
              grad.updateMatrix(m);
              gfx.beginGradientFill(grad);
           case FillSolid(colour):
              gfx.beginFill(colour,inPath.fill_alpha);
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
           style.alpha = inPath.stroke_alpha;//*inPath.fill_alpha;
           style.color = inPath.stroke_colour;
           style.capsStyle = inPath.stroke_caps;
           style.jointStyle = inPath.joint_style;
           style.miterLimit = inPath.miter_limit;
           gfx.lineStyle(style);
        }

        for(segment in inPath.segments)
           segment.toGfx(gfx, context);
 
        gfx.endFill();
        gfx.endLineStyle();

        return s;
    }

}
