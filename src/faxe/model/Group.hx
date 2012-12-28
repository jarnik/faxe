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
        alignment = { h: ALIGN_H_NONE, v: ALIGN_V_NONE, top: 0, bottom: 0, left: 0, right: 0 };
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
            //fixedSize = new Rectangle( 0, 0, 0, 0 );

            //trace( "gonna compute extent for kids of "+name );
            for ( kid in children ) {
                fixedSize.x = Math.min( fixedSize.x, kid.fixedSize.x );
                fixedSize.y = Math.min( fixedSize.y, kid.fixedSize.y );
                fixedSize.width = Math.max( fixedSize.width, kid.fixedSize.x + kid.fixedSize.width );
                fixedSize.height = Math.max( fixedSize.height, kid.fixedSize.y + kid.fixedSize.height );
            }
            fixedSize.width -= fixedSize.x;
            fixedSize.height -= fixedSize.y;
            for ( kid in children ) {
                //kid.moveOrigin( fixedSize.x, fixedSize.y );
                kid.fixedSize.x -= fixedSize.x;
                kid.fixedSize.y -= fixedSize.y;
            }
        }

        var g:Group;
        for ( kid in children ) {
            if ( Std.is( kid, Group )) {
                g = cast( kid, Group );

                g.alignment.left = g.fixedSize.x;
                g.alignment.top = g.fixedSize.y;
                g.alignment.right = fixedSize.width - (g.fixedSize.x + g.fixedSize.width);
                g.alignment.bottom = fixedSize.height - (g.fixedSize.y + g.fixedSize.height);
                //trace("kid "+g.fixedSize+" aligns "+g.alignment);                  
            }
        }

        //trace("group "+name+" extents "+fixedSize);
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

    public function render( autoAlign:Bool = false ):DisplayNode {
        var e:ElementSprite = new ElementSprite( autoAlign );
        e.name = name;
        e.element = this;
        e.x = fixedSize.x;
        e.y = fixedSize.y;
        e.alignment = alignment;

        for ( c in children ) {
            e.addSubElement( 
                c.render( false ) 
            );
        }

        return NodeElement( e );
    }

}
