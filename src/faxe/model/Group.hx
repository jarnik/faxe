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
import faxe.model.IElement;

class Group implements IElement
{
    public var children:Array<IElement>;
    public var name:String;
    public var alignment:AlignConfig;
    public var fixedSize:Rectangle;

	public function new ( name:String ) 
	{
        children = [];
        this.name = name;
        alignment = { h: ALIGN_H_NONE, v: ALIGN_V_NONE };
	}

    public function addChild( e:IElement ):Void {
        children.push( e );
    }

    public function addChildAt( e:IElement, index:Int ):Void {
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
                //kid.moveOrigin( fixedSize.x, fixedSize.y );
                kid.fixedSize.x += fixedSize.x;
                kid.fixedSize.y += fixedSize.y;
            }
            fixedSize.width -= fixedSize.x;
            fixedSize.height -= fixedSize.y;
        }
        trace("group "+name+" extents "+fixedSize);
    }

    /*
    public function moveOrigin( x:Float, y:Float ):Void {
        fixedSize.x += x;
        fixedSize.y += y;
    }*/

    public function fetch( path:String ):Group {
        var pathElements:Array<String> = path.split("."); 
        //Debug.log("fetching kid "+pathElements[0]+"  ");

        var g:Group;
        for ( kid in children ) {
            //Debug.log("matching kid "+kid.name);
            if ( !Std.is( kid, Group ) )
                continue;
            g = cast( kid, Group );
            if ( g.name == pathElements[0] ) {
                if ( pathElements.length == 1 )
                    return g;
                else
                    return g.fetch( path.substr( path.indexOf(".")+1 ) );
            }
        }

        return null;
    }

    public function render( isRoot:Bool = false ):DisplayNode {
        var e:ElementSprite = new ElementSprite( isRoot );
        e.name = name;
        e.element = this;
        //e.alignment = { h:alignment.h, v:alignment.v };

        for ( c in children ) {
            e.addSubElement( 
                c.render( false ) 
            );
        }

        return NodeElement( e );
    }

}