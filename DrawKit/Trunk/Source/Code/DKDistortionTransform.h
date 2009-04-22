///**********************************************************************************************************************************
///  DKDistortionTransform.h
///  DrawKit
///
///  Created by graham on 27/10/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>


@interface DKDistortionTransform : NSObject <NSCoding, NSCopying>
{
	NSPoint		m_q[4];
	BOOL		m_inverted;
}

+ (DKDistortionTransform*)	transformWithInitialRect:(NSRect) rect;

- (id)				initWithRect:(NSRect) rect;
- (id)				initWithEnvelope:(NSPoint*) points;

- (void)			setEnvelopePoints:(NSPoint*) points;
- (void)			getEnvelopePoints:(NSPoint*) points;
- (NSRect)			bounds;

- (void)			offsetByX:(float) dx byY:(float) dy;
- (void)			shearHorizontallyBy:(float) dx;
- (void)			shearVerticallyBy:(float) dy;
- (void)			differentialPerspectiveBy:(float) delta;

- (void)			invert;

- (NSPoint)			transformPoint:(NSPoint) p fromRect:(NSRect) rect;
- (NSBezierPath*)	transformBezierPath:(NSBezierPath*) path;

@end



/*

This objects performs distortion transformations on points and paths. The four envelope points define a
quadrilateral in a clockwise direction starting at top,left. A point is mapped from its position relative
to a given rectangle to this quadrilateral.

This is a non-affine transformation which is why it's not a subclass of NSAffineTransform. However it
can be used in a similar way.


*/
