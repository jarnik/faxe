package faxe.parser;

import nme.Assets;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.display.DisplayObjectContainer;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.utils.ByteArray;
import nme.events.MouseEvent;

import format.svg.PathSegment;
import format.gfx.GfxGraphics;
//import format.svg.Path;
import format.svg.Group;
import format.svg.PathParser;
import format.svg.RenderContext;

//import gaxe.Debug;

import faxe.parser.IParser;
import faxe.model.IElement;
import faxe.model.ElementSprite;
import faxe.model.Image;
import faxe.model.Shape;
import faxe.model.Text;

import format.svg.SVGData;

class ParserSVG2 implements IParser
{
    private var data:SVGData;

	public function new () {
    }

    public function parse( file:ByteArray ):IElement {
        data = new SVGData (Xml.parse ( file.toString() ));
        var root:IElement = parseElement( DisplayGroup( data ), 2 );
        return root;
    }

    private function parseElement( de:DisplayElement, forcedSizeLevel:Int = 0 ):IElement {
        var e:IElement = null;
        var forcedSize:Rectangle = null;
        switch ( de ) {
            case DisplayGroup( group ):
                //trace("group "+group.name);
                var align:AlignConfig = Parser.parseAlign( group.name );
                var g:faxe.model.Group = new faxe.model.Group( Parser.parseName( group.name ) );
                for ( kid in group.children )
                    g.addChild( parseElement( kid, forcedSizeLevel - 1 ) );
                if ( forcedSizeLevel > 0 ) {
                    forcedSize = new Rectangle( 0, 0, data.width, data.height );
                }
                g.updateExtent( forcedSize );
                g.alignment = align;
                e = g;
            case DisplayPath( p ): 
                //trace( "path "+p+" "+p.matrix );
                e = new Shape( p );
            case DisplayText( t ): 
                trace( "text not implemented yet, sorry :) " );
            default:
        }
        return e;
    }

    /*

    private function parseTransform( e:Element, xml:Xml ):Void {
        var m:Matrix = e.transform;

        m.tx = Std.parseFloat( xml.get("x") != null ? xml.get("x") : "0" );
        m.ty = Std.parseFloat( xml.get("y") != null ? xml.get("y") : "0" );

        if ( xml.nodeName.indexOf("flow") != -1 ) {
            m.tx = Std.parseFloat( xml.firstChild().firstChild().get("x") );
            m.ty = Std.parseFloat( xml.firstChild().firstChild().get("y") );
        }

        var t:String = xml.get("transform");
        if ( t != null ) {
            var r:EReg = ~/(matrix|translate|scale)\(([-0-9.,]*)\)/;
            if ( r.match( t ) ) {
                var values:Array<String> = r.matched(2).split(",");
                switch ( r.matched(1) ) {
                    case "matrix":
                        var tx:Float = m.tx;
                        var ty:Float = m.ty;
                        m.a = Std.parseFloat( values[ 0 ] );
                        m.b = Std.parseFloat( values[ 1 ] );
                        m.c = Std.parseFloat( values[ 2 ] );
                        m.d = Std.parseFloat( values[ 3 ] );
                        m.tx = Std.parseFloat(values[ 4 ] );
                        m.ty = Std.parseFloat(values[ 5 ] );
                        m.tx = tx * m.a + ty * m.c + m.tx;
                        m.ty = tx * m.b + ty * m.d + m.ty;            
                    case "translate":
                        m.tx = Std.parseFloat( values[ 0 ] ) + m.tx;
                        m.ty = Std.parseFloat( values[ 1 ] ) + m.ty;
                    case "scale":
                        m.a *= Std.parseFloat( values[ 0 ] );
                        m.d *= Std.parseFloat( values[ 1 ] );
                }
            } else {
                Debug.log("transform type not matched! "+t);
            }
        }
    }

    private function parseStyle( style:String ):Hash<String> {
        var hash:Hash<String> = new Hash<String>();
        var paramSplit:Array<String> = style.split(";");
        var vals:Array<String> = null;
        for ( p in paramSplit ) {
            vals = p.split(":");
            hash.set( vals[0], vals[1] );
        }
        return hash;
    }

    private function parseShapeStyle( e:Element, style:String ):Void {
        if ( style == null )
            return;

        var vals:Hash<String> = parseStyle( style );
        var opacity:Float = 1;
        var setFill:Bool = false;
        var fill:Int = 0x000000;
        var fill_opacity:Float = 1;

        var setStroke:Bool = false;
        var stroke:Int = 0x000000;
        var stroke_width:Float = 1;
        var stroke_opacity:Float = 1;
        
        var v:String;
        for ( k in vals.keys() ) {
            v = vals.get( k );
            switch ( k ) {
                case "opacity": opacity = Std.parseFloat( v );
                case "fill": setFill = ( v != "none" ); fill = Std.parseInt( "0x"+v.substr(1) );
                case "fill-opacity": fill_opacity = Std.parseFloat( v );
                case "stroke": setStroke = ( v != "none" ); stroke = Std.parseInt( "0x"+v.substr(1) );
                case "stroke-width": stroke_width = Std.parseFloat( v );
                case "stroke-opacity": stroke_opacity = Std.parseFloat( v );
            }
        }

        e.opacity = opacity;

        if ( Std.is( e, Shape ) ) {
            var shape:Shape;
            shape = cast( e, Shape );
            var p:Path = shape.path;
            if ( setFill ) {
                p.fill = FillSolid( fill );
                p.fill_alpha = fill_opacity;
            } else
                p.fill = FillNone;
    
            if ( setStroke ) {
                //g.lineStyle( stroke_width, stroke, stroke_opacity );
                p.stroke_width = stroke_width;
                p.stroke_colour = stroke;
                p.stroke_alpha = stroke_opacity;
            } else {
                //g.lineStyle( Math.NaN, 0 );
            }
        }
    }

    private function parseTextNode( xml:Xml ):Element {
        var e:Text = new Text();
        var tf:TextField = e.tf;
        var format:TextFormat = e.format;
    
        if ( xml.nodeName.indexOf("flow") != -1 ) {
            e.tf.multiline = true;
            e.tf.width = Std.parseFloat( xml.firstChild().firstChild().get("width") );
            e.tf.height = Std.parseFloat( xml.firstChild().firstChild().get("height") );
        }

        var text:String = "";
        for ( e in xml ) {
            if ( e.nodeType != Xml.Element )
                continue;
            switch ( e.nodeName ) {
                case "svg:tspan", "tspan", "svg:flowPara", "flowPara":
                    if ( e.firstChild() != null ) {
                        text += ( text != "" ? "\n": "" );
                        text += e.firstChild().toString();
                    }
            }
        }

        var vals:Hash<String> = parseStyle( xml.get("style") );

        var opacity:Float = 1;
        var fill:Int = 0x000000;
        var fill_opacity:Float = 1;

        var font_size:Float = 14;
        var font_family:String = "system";
        
        var v:String;
        for ( k in vals.keys() ) {
            v = vals.get( k );
            switch ( k ) {
                case "opacity": opacity = Std.parseFloat( v );
                case "fill": fill = Std.parseInt( "0x"+v.substr(1) );
                case "fill-opacity": fill_opacity = Std.parseFloat( v );
                case "font-size": font_size = Std.parseFloat( v.substr(0,-2) );
            }
        }
        
        format.size = font_size;
        format.color = fill;
        format.font = Assets.getFont("assets/fonts/nokiafc22.ttf").fontName;
        //Debug.log("text "+text+" fill "+fill);
        tf.alpha = opacity;        
        tf.text = text;

        return e;
    }

    private function parseName( name:String ):String {
        var r:EReg = ~/([^\[]*)/;
        if ( !r.match( name ) )
            return name;
        return r.matched( 1 );
    }



    private function parseSize( element:Element, xml:Xml ):Void {
        if ( 
            xml.nodeName == "svg" || xml.nodeName == "svg:svg" || 
            xml.get("inkscape:groupmode") == "layer"
        ) {
            //Debug.log(" setting fixed size for "+xml.get("id"));
            element.fixedSize = new Rectangle( 0, 0,
                Std.parseFloat( xml.get("width") ), Std.parseFloat( xml.get("height") )
            );
        }
    }
    
    private function parseRect( xml:Xml ):Element {
        var s:Shape = new Shape();
        parseShapeStyle( s, xml.get("style") );

        var inPath:Xml = xml;
        var path:Path = s.path;

        var x = 0;//inPath.exists ("x") ? Std.parseFloat (inPath.get ("x")) : 0;
        var y = 0;//inPath.exists ("y") ? Std.parseFloat (inPath.get ("y")) : 0;
        var w = Std.parseFloat (inPath.get ("width"));
        var h = Std.parseFloat (inPath.get ("height"));
        var rx = inPath.exists ("rx") ? Std.parseFloat (inPath.get ("rx")) : 0.0;
        var ry = inPath.exists ("ry") ? Std.parseFloat (inPath.get ("ry")) : 0.0;

        if (rx == 0 || ry == 0) {
            path.segments.push (new MoveSegment (x , y));
            path.segments.push (new DrawSegment (x + w, y));
            path.segments.push (new DrawSegment (x + w, y + h));
            path.segments.push (new DrawSegment (x, y + h));
            path.segments.push (new DrawSegment (x, y));

        } else {

            path.segments.push (new MoveSegment (x, y + ry));

            // top-left
            path.segments.push (new QuadraticSegment (x, y, x + rx, y));
            path.segments.push (new DrawSegment (x + w - rx, y));

            // top-right
            path.segments.push (new QuadraticSegment (x + w, y, x + w, y + rx));
            path.segments.push (new DrawSegment (x + w, y + h - ry));

            // bottom-right
            path.segments.push (new QuadraticSegment (x + w, y + h, x + w - rx, y + h));
            path.segments.push (new DrawSegment (x + rx, y + h));

            // bottom-left
            path.segments.push (new QuadraticSegment (x, y + h, x, y + h - ry));
            path.segments.push (new DrawSegment (x, y + ry));

        }
        s.updateExtent();

        return s;

    }

    private function parsePath( xml:Xml ):Element {        
        var s:Shape = new Shape();
        parseShapeStyle( s, xml.get("style") );
        
        //var data:Array<String> = xml.get("d").toLowerCase().split(" ");
        var pathData:String = xml.get("d");

        var pathParser:PathParser = new PathParser();
        //var segments:Array<PathSegment> = pathParser.parse( pathData, true );
        s.path.segments = pathParser.parse( pathData, true );
        s.updateExtent();
        
        return s;
    }

    private function parseElement( xml:Xml ):Element {        
        var element:Element = null;

        var image:Image;
        var shape:Shape;
        switch ( xml.nodeName ) {
            case "svg:g", "g":
                element = new Element(); 
                parseSize( element, xml );
                parseShapeStyle( element, xml.get("style") );
            case "svg:image", "image":
                image = new Image( Assets.getBitmapData( "assets/"+xml.get("xlink:href") ) ); 
                element = image;
            case "svg:rect", "rect":
                element = parseRect( xml );
            case "svg:text", "text", "svg:flowRoot", "flowRoot":
                element = parseTextNode( xml );                
            case "svg:svg", "svg":
                element = new Element();
                parseSize( element, xml );
            case "svg:path", "path":
                element = parsePath( xml );
            default:
                Debug.log("unimplemented "+xml.nodeName);
                element = new Element(); 
        }
        element.alignment = parseAlign( xml.get("id") );
        element.name = parseName( xml.get("id") );
        //Debug.log("parsed name "+xml.get("id")+" "+element.name);
        parseTransform( element, xml );

        if ( element != null )
            for ( e in xml ) {
                if ( e.nodeType != Xml.Element )
                    continue;
                switch ( e.nodeName ) {
                    case "svg:g", "svg:image", "svg:rect", "svg:text", "svg:path", "svg:flowRoot",
                         "g", "image", "rect", "text", "path", "flowRoot":
                        element.addChild( parseElement( e ) );
                    default:
                        //Debug.log("unimplemented child node "+e.nodeName);
                }
            }

        if ( Std.is( element, Shape ) ) { 
            var w:Float = cast( element, Shape ).extent.width;
            var h:Float = cast( element, Shape ).extent.height;
            //Debug.log( "shape "+w+"x"+h );
            var ww:Float = Math.abs(element.transform.a*w) + Math.abs(element.transform.c*h);
            var hh:Float = Math.abs(element.transform.b*w) + Math.abs(element.transform.d*h);
            //Debug.log( "shape transformed "+ww+" "+hh );
        }

        return element;
    }

    private function onClick(e:MouseEvent):Void {
        Debug.log("click "+e.target);
    }
    */

}
