///**********************************************************************************************************************************
///  NSShadow+Scaling.m
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

#import "NSShadow+Scaling.h"
#import "NSColor+DKAdditions.h"


@implementation NSShadow (DKAdditions)
#pragma mark As a NSShadow

- (void)		setAbsolute
{
	[self setAbsoluteFlipped:NO];
	
	//[self set];
}


- (void)		setAbsoluteFlipped:(BOOL) flipped
{
	CGContextRef		cc = [[NSGraphicsContext currentContext] graphicsPort];
	CGAffineTransform	ctm = CGContextGetCTM( cc );
	CGSize				unit = CGSizeApplyAffineTransform( CGSizeMake( 1, 1 ), ctm );
	
	NSSize				os = [self shadowOffset];
	
	if ( flipped )
		os.height = -os.height;
	
	CGSize				offset = CGSizeApplyAffineTransform(*(CGSize*)&os, ctm );
	float				blur = [self shadowBlurRadius] * unit.width;
	CGColorRef			colour = [[self shadowColor] quartzColor];
	
	CGContextSetShadowWithColor( cc, offset, blur, colour );
	CGColorRelease( colour );
}


#pragma mark -
- (void)		setShadowAngle:(float) radians distance:(float) dist
{
	NSSize	offset;
	
	offset.width = dist * cosf( radians );
	offset.height = dist * sinf( radians );
	
	[self setShadowOffset:offset];
}


- (void)		setShadowAngleInDegrees:(float) degrees distance:(float) dist
{
	[self setShadowAngle:( degrees * pi ) / 180.0f distance:dist];
}


- (float)		shadowAngle
{
	NSSize offset = [self shadowOffset];
	return atan2f( offset.height, offset.width );
}


- (float)		shadowAngleInDegrees
{
	return ([self shadowAngle] * 180.0f ) / pi;
}


- (float)		distance
{
	NSSize offset = [self shadowOffset];
	return hypotf( offset.width, offset.height );
}


- (float)		extraSpace
{
	// return the amount of additional space the shadow occupies beyond the edge of any object shadowed
	
	float es = 0.0;
	
	es = fabs( MAX([self shadowOffset].width, [self shadowOffset].height));
	es += [self shadowBlurRadius];
	
	return es;
}


- (void)		drawApproximateShadowWithPath:(NSBezierPath*) path operation:(DKShadowDrawingOperation) op strokeWidth:(int) sw
{
	// one problem with shadows is that they are expensive in rendering time terms. This may help - it draws a fake shadow for the path
	// using the current shadow parameters, but just block filling/stroking it. Call this *instead* of drawing the shadow (not as well as)
	// to get something approximating the shadow. Later you can use the real shadow for higher quality output.

	NSAssert( path != nil, @"path was nil when drawing fake shadow");
	NSAssert(![path isEmpty], @"path was empty when drawing fake shadow");
	
	[[self shadowColor] set];
	NSSize offset = [self shadowOffset];
	
	NSBezierPath* temp;
	NSAffineTransform* offsetTfm = [NSAffineTransform transform];
	[offsetTfm translateXBy:offset.width yBy:offset.height];
	temp = [offsetTfm transformBezierPath:path];
	
	if ( op & kDKShadowDrawFill )
		[temp fill];
	
	if ( op & kDKShadowDrawStroke )
	{
		[temp setLineWidth:sw];
		[temp stroke];
	}
}


@end
