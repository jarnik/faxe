package faxe.model;

import nme.Assets;
import nme.display.Sprite;
import nme.display.DisplayObject;
import nme.display.DisplayObjectContainer;
import nme.geom.Matrix;
import nme.geom.Rectangle;
import nme.geom.ColorTransform;

import faxe.Main;
import faxe.model.ElementSprite;
//import gaxe.Debug;

class Element
{
    //public var transform:Matrix;
    //public var color:ColorTransform;
    public var children:Array<Element>;
    public var name:String;
    public var alignment:AlignConfig;
    public var fixedSize:Rectangle;
    //public var opacity:Float;

	public function new () 
	{
        children = [];
        name = "";
        //transform = new Matrix();
        //transform.identity();
        //color = new ColorTransform();
        alignment = { h: ALIGN_H_NONE, v: ALIGN_V_NONE };
        //opacity = 1;
	}

    public function addChild( e:Element ):Void {
        children.push( e );
    }

    public function addChildAt( e:Element, index:Int ):Void {
        children.insert( index, e );
    }

    public function updateExtent( forcedSize:Rectangle = null ):Void {
        if ( forcedSize != null ) {
            fixedSize = forcedSize.clone();
        } else {
            fixedSize = new Rectangle( Math.POSITIVE_INFINITY, Math.POSITIVE_INFINITY, 0, 0 );

            trace( "gonna compute extent for kids of "+name );
            for ( kid in children ) {
                fixedSize.x = Math.min( fixedSize.x, kid.fixedSize.x );
                fixedSize.y = Math.min( fixedSize.y, kid.fixedSize.y );
                fixedSize.width = Math.max( fixedSize.width, kid.fixedSize.x + kid.fixedSize.width );
                fixedSize.height = Math.max( fixedSize.height, kid.fixedSize.y + kid.fixedSize.height );
            }
            for ( kid in children ) {
                kid.moveOrigin( fixedSize.x, fixedSize.y );
            }
            fixedSize.width -= fixedSize.x;
            fixedSize.height -= fixedSize.y;
        }
        trace("group "+name+" extents "+fixedSize);
    }

    public function moveOrigin( x:Float, y:Float ):Void {
        fixedSize.x += x;
        fixedSize.y += y;
    }

    public function fetch( path:String ):Element {
        var pathElements:Array<String> = path.split("."); 
        //Debug.log("fetching kid "+pathElements[0]+"  ");

        for ( kid in children ) {
            //Debug.log("matching kid "+kid.name);
            if ( kid.name == pathElements[0] ) {
                if ( pathElements.length == 1 )
                    return kid;
                else
                    return kid.fetch( path.substr( path.indexOf(".")+1 ) );
            }
        }

        return null;
    }

    public function render( isRoot:Bool = false, _parentSize:Rectangle = null ):ElementSprite {
        /*
        if ( fixedSize != null && _parentSize != null )
            fixedSize = _parentSize;

        var e:ElementSprite = new ElementSprite( isRoot );
        e.name = name;
        e.element = this;
        e.alignment = { h:alignment.h, v:alignment.v };

        var c:Sprite = renderContent();

        for ( e in children ) {
            c.addChild( 
                e.render( false, fixedSize ) 
            );
        }

        e.addContent( c, fixedSize );
        */
        return null;
    }

    /*
    public function renderContent():Sprite {
        var s:Sprite = new Sprite();
        s.transform.matrix = transform;
        s.transform.colorTransform = color;
        s.alpha = opacity;
        return s;
    }


    public function setAlpha( alpha:Float ):Void {
        color.alphaMultiplier = alpha;
    }

    public function toString():String {
        var out:String = "> "+name+" start\n";
        for ( c in children )
            out += c.toString()+"\n";
        out += "< "+name+" end\n";
        return out;
    }

    public function render( isRoot:Bool = false, _parentSize:Rectangle = null ):ElementSprite {

        if ( fixedSize != null && _parentSize != null )
            fixedSize = _parentSize;

        var e:ElementSprite = new ElementSprite( isRoot );
        e.name = name;
        e.element = this;
        e.alignment = { h:alignment.h, v:alignment.v };

        var c:Sprite = renderContent();

        for ( e in children ) {
            c.addChild( 
                e.render( false, fixedSize ) 
            );
        }

        e.addContent( c, fixedSize );

        return e;
    }*/

}
