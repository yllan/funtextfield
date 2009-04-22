///**********************************************************************************************************************************
///  DKReshapableShape.h
///  DrawKit
///
///  Created by graham on 20/10/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKDrawableShape.h"


@interface DKReshapableShape : DKDrawableShape <NSCoding, NSCopying>
{
	SEL				m_shapeSelector;
	id				m_shapeProvider;
	id				m_optionalParam;
}


- (void)			setShapeProvider:(id) provider selector:(SEL) selector;
- (id)				shapeProvider;
- (SEL)				shapeSelector;

- (void)			setOptionalParameter:(id) objParam;
- (id)				optionalParameter;

- (NSBezierPath*)	providedShapeForRect:(NSRect) r;

@end

// the shape provider must have a method that conforms to the following prototype:
// - (NSBezierPath*)	someShapeInRect:(NSRect) r otherParameters:(id) object;
// this is actually called by a C function call internally, so the following is the real prototype:

typedef NSBezierPath* (*shapeProviderFunction)( id, SEL, NSRect, id );

// the <otherParameters> part is optional but must be an object - for example an NSValue, NSNumber or NSDictionary are all valid, but
// the provider and the providee need to informally agree on what to expect here.

/*

This subclass of DKDrawableShape implements a protocol for obtaining shapes dynamically from a shape provider. When
the user changes the shape's size, the shape provider is given the opportunity to supply a new path to fit the
shape's new size. This path is then automatically inversely transformed and stored as the shape's path.

The shape provider must return a bezier path to fit a rectangle that it is passed. This path is inversely transformed
to the internal path.

DKShapeFactory (instances) can be used as a shape provider.

While this looks like a bit of an awkward thing to use, it's actually very flexible and powerful. Many shapes can change
dramatically when they are resized in ways that mere scaling cannot begin to describe. This permits that type of
functionality to be set up pretty easily, especially in conjunction with DKDrawingTool.

Archiving works because the shape provider must comply with NSCoding. DKShapeFactory is compliant, even though in fact
it has no ivars. While the shared DKShapeFactory instance is often specified as a shape provider, private instances
that are owned by the individual objects come into being when dearchiving this kind of object. This is equivalent to
the shape just making its own path, rather than using a helper object, but as a user of this system you don't really need
to know or care about that - it's just a level of indirection that you can ignore. The point is that shape functionality can
be added to DKShapeFactory rather than having to make lots of individual subclasses of DKDrawableShape for each one.

*/
