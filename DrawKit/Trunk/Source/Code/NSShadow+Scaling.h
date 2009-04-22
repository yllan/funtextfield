///**********************************************************************************************************************************
///  NSShadow+Scaling.h
///  DrawKit
///
///  Created by graham on 22/06/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>

typedef enum
{
	kDKShadowDrawFill	= ( 1 << 0 ),
	kDKShadowDrawStroke	= ( 1 << 1 )
}
DKShadowDrawingOperation;


@interface NSShadow (DKAdditions)

- (void)		setAbsolute;
- (void)		setAbsoluteFlipped:(BOOL) flipped;

- (void)		setShadowAngle:(float) radians distance:(float) dist;
- (void)		setShadowAngleInDegrees:(float) degrees distance:(float) dist;
- (float)		shadowAngle;
- (float)		shadowAngleInDegrees;

- (float)		distance;
- (float)		extraSpace;

- (void)		drawApproximateShadowWithPath:(NSBezierPath*) path operation:(DKShadowDrawingOperation) op strokeWidth:(int) sw;

@end



/*

a big annoyance with NSShadow is that it ignores the current CTM when it is set, meaning that as a drawing is scaled,
the shadow stays fixed. This is a solution. Here, if you call setAbsolute instead of set, the parameters of the shadow are
used to set a different shadow that is scaled using the current CTM, so the original shadow appears to remain at the right size
as you scale.

*/
