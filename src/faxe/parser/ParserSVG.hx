package faxe.parser;

import nme.Assets;
import nme.display.Sprite;
import nme.display.Bitmap;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.geom.Matrix;
import nme.display.DisplayObjectContainer;
import nme.text.TextField;
import nme.text.TextFormat;
import nme.utils.ByteArray;
import nme.events.MouseEvent;

import jarnik.gaxe.Debug;

import faxe.model.Element;
import faxe.model.ElementSprite;
import faxe.model.Image;
import faxe.model.Shape;
import faxe.model.Text;

class ParserSVG implements IParser
{
	public function new () {
    }

    public function parse( file:ByteArray ):Element {
        var xml:Xml = Xml.parse( file.toString() );
        var root:Xml = null;
        for ( ee in xml ) {
            if ( ee.nodeType == Xml.Element )
                root = ee;
        }

        //var e:Element = new Element();
        //e.name = "kokodac "+root.get("width")+" x "+root.get("height");

        return parseElement( root );
        //return e;
    }

    private function parseTransform( e:Element, xml:Xml ):Void {
        var m:Matrix = e.transform;

        m.tx = Std.parseFloat( xml.get("x") != null ? xml.get("x") : "0" );
        m.ty = Std.parseFloat( xml.get("y") != null ? xml.get("y") : "0" );

        var t:String = xml.get("transform");
        if ( t != null ) {
            var tx:Float = m.tx;
            var ty:Float = m.ty;
            var values:Array<String> = t.substr( 7 ).split(",");
            m.a = Std.parseFloat( values[0] );
            m.b = Std.parseFloat( values[1] );
            m.c = Std.parseFloat( values[2] );
            m.d = Std.parseFloat( values[3] );
            m.tx = Std.parseFloat( values[4] );
            m.ty = Std.parseFloat( values[5] );

            m.tx = tx * m.a + ty * m.c + m.tx;
            m.ty = tx * m.b + ty * m.d + m.ty;
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

    private function parseShapeStyle( shape:Shape, style:String ):Void {
        var g:Graphics = shape.graphics;
        var s:Sprite = shape.s;

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
                case "fill": setFill = true; fill = Std.parseInt( "0x"+v.substr(1) );
                case "fill-opacity": fill_opacity = Std.parseFloat( v );
                case "stroke": setStroke = true; stroke = Std.parseInt( "0x"+v.substr(1) );
                case "stroke-width": stroke_width = Std.parseFloat( v );
                case "stroke-opacity": stroke_opacity = Std.parseFloat( v );
            }
        }

        s.alpha = opacity;

        if ( setFill )
            g.beginFill( fill, opacity );
        else
            g.beginFill( 0x000000, 0 );

        if ( setStroke )
            g.lineStyle( stroke_width, stroke, stroke_opacity );
        else
            g.lineStyle( Math.NaN, 0 );
    }

    private function parseTextNode( xml:Xml ):Element {
        var e:Text = new Text();
        var tf:TextField = e.tf;
        var format:TextFormat = e.format;
    
        e.transform.tx = Std.parseFloat( xml.get("x") );
        e.transform.ty = Std.parseFloat( xml.get("y") );

        var text:String = "";
        for ( e in xml ) {
            if ( e.nodeType != Xml.Element )
                continue;
            switch ( e.nodeName ) {
                case "svg:tspan":
                    text += e.firstChild().toString();
            }
        }

        var vals:Hash<String> = parseStyle( xml.get("style") );

        var opacity:Float = 1;
        var fill:Int = 0x000000;
        var fill_opacity:Float = 1;

        var font_size:Float = 14;
        
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
        tf.alpha = opacity;        

        tf.defaultTextFormat = format;
        
        tf.text = text;


        return e;
    }

    private function parseName( name:String ):String {
        var r:EReg = ~/([^\[]*)/;
        if ( !r.match( name ) )
            return name;
        return r.matched( 1 );
    }

    private function parseAlign( id:String ):AlignConfig {
        var align:AlignConfig = { h: ALIGN_H_NONE, v: ALIGN_V_NONE };

        var r:EReg = ~/.*\[([A-Za-z]*)\]/;
        if ( r.match( id ) ) {
            var cfg:String = r.matched(1).toUpperCase();
            Debug.log("align: "+cfg);
            if ( cfg.indexOf("R") != -1 )
                align.h = ALIGN_H_RIGHT;
            if ( cfg.indexOf("L") != -1 )
                align.h = ALIGN_H_LEFT;
            if ( cfg.indexOf("HC") != -1 )
                align.h = ALIGN_H_CENTER;
            if ( cfg.indexOf("T") != -1 )
                align.v = ALIGN_V_TOP;
            if ( cfg.indexOf("B") != -1 )
                align.v = ALIGN_V_BOTTOM;
            if ( cfg.indexOf("VC") != -1 )
                align.v = ALIGN_V_CENTER;
        }

        return align;
    }

    private function parseElement( xml:Xml ):Element {        
        var element:Element = null;

        var image:Image;
        var shape:Shape;
        switch ( xml.nodeName ) {
            case "svg:g", "g":
                element = new Element(); 
            case "svg:image", "image":
                image = new Image( Assets.getBitmapData( "assets/"+xml.get("xlink:href") ) ); 
                element = image;
            case "svg:rect", "rect":
                //Debug.log("rect");
                shape = new Shape(); 
                parseShapeStyle( shape, xml.get("style") );
                shape.graphics.drawRoundRect(
                    0,
                    0,
                    Std.parseFloat( xml.get("width") ),
                    Std.parseFloat( xml.get("height") ),
                    Std.parseFloat( xml.get("rx") )*2,
                    Std.parseFloat( xml.get("ry") )*2
                );
                shape.s.buttonMode = true;
                shape.s.addEventListener( MouseEvent.CLICK, onClick );
                element = shape;
            case "svg:text", "text":
                element = parseTextNode( xml );                
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
                    case "svg:g", "svg:image", "svg:rect", "svg:text", 
                         "g", "image", "rect", "text":
                        element.addChild( parseElement( e ) );
                    default:
                        //Debug.log("unimplemented child node "+e.nodeName);
                }
            }

        if ( Std.is( element, Shape ) ) { 
            var w:Float = cast( element, Shape ).s.width;
            var h:Float = cast( element, Shape ).s.height;
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

}
