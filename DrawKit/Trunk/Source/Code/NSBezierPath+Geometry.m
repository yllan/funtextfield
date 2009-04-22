///**********************************************************************************************************************************
///  NSBezierPath-Geometry.m
///  DrawKit
///
///  Created by graham on 22/10/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "NSBezierPath+Geometry.h"
#import "DKDrawKitMacros.h"
#import "DKGeometryUtilities.h"
#import "DKRandom.h"
#import "LogEvent.h"
#import "NSBezierPath+Editing.h"
#import "NSBezierPath+GPC.h"
#import "NSShadow+Scaling.h"


#pragma mark Static Functions
static void		ConvertPathApplierFunction ( void *info, const CGPathElement *element );
static float	lengthOfBezier(const  NSPoint bez[4], float acceptableError);
static int		SortPointsHorizontally( id value1, id value2, void* context );

#pragma mark -
@implementation NSBezierPath (Geometry)
#pragma mark As an NSBezierPath

- (NSBezierPath*)		scaledPath:(float) scale
{
	// returns a copy of the receiver scaled by <scale>, with the path's origin assumed to be at the centre of its bounds rect.

	NSPoint	cp = [self centreOfBounds];
	return [self scaledPath:scale aboutPoint:cp];
}


- (NSBezierPath*)		scaledPath:(float) scale aboutPoint:(NSPoint) cp
{
	// This is like an inset or an outset operation. If scale is 1.0, a copy of the path is returned.
	
	NSBezierPath* copy = [self copy];
	
	if ( scale != 1.0 )
	{
		NSAffineTransform*	xfm = [NSAffineTransform transform];
		[xfm translateXBy:cp.x yBy:cp.y];
		[xfm scaleXBy:scale yBy:scale];
		[xfm translateXBy:-cp.x yBy:-cp.y];
		
		[copy transformUsingAffineTransform:xfm];
	}
	
	return [copy autorelease];
}


- (NSBezierPath*)		rotatedPath:(float) angle
{
	// return a rotated copy of the receiver. The origin is taken as the centre of the path bounds.
	// angle is a value in radians
	
	return [self rotatedPath:angle aboutPoint:[self centreOfBounds]];
}


- (NSBezierPath*)		rotatedPath:(float) angle aboutPoint:(NSPoint) cp
{
	// return a rotated copy of the receiver. The origin is taken as point <cp> relative to the original path.
	// angle is a value in radians

	NSBezierPath* copy = [self copy];
	
	if ( angle != 0.0 )
	{
		NSAffineTransform*	xfm = RotationTransform( angle, cp );
		[copy transformUsingAffineTransform:xfm];
	}
	
	return [copy autorelease];
}


- (NSBezierPath*)		insetPathBy:(float) amount
{
	// returns a scaled copy of the receiver, calculating the scale by adding <amount> to all edges of the bounds.
	// since this can scale differently in x and y directions, this doesn't call the scale function but works
	// very similarly.
	
	// note that due to the mathematics of bezier curves, this may not produce exactly perfect results for some
	// curves.
	
	// +ve values of <amount> inset (shrink) the path, -ve values outset (grow) the shape.
	
	NSRect	r = NSInsetRect([self bounds], amount, amount );
	float	xs, ys;
	
	xs = r.size.width / [self bounds].size.width;
	ys = r.size.height / [self bounds].size.height;
	
	NSBezierPath* copy = [self copy];
	
	if ( amount != 0.0 )
	{
		NSPoint		cp = [copy centreOfBounds];
		
		NSAffineTransform*	xfm = [NSAffineTransform transform];
		[xfm translateXBy:cp.x yBy:cp.y];
		[xfm scaleXBy:xs yBy:ys];
		[xfm translateXBy:-cp.x yBy:-cp.y];
		
		[copy transformUsingAffineTransform:xfm];
	}
	
	return [copy autorelease];
}


- (NSBezierPath*)		horizontallyFlippedPathAboutPoint:(NSPoint) cp
{
	NSBezierPath* copy = [self copy];
	
	NSAffineTransform*	xfm = [NSAffineTransform transform];
	[xfm translateXBy:cp.x yBy:cp.y];
	[xfm scaleXBy:-1.0 yBy:1.0];
	[xfm translateXBy:-cp.x yBy:-cp.y];
	
	[copy transformUsingAffineTransform:xfm];
	
	return [copy autorelease];
}


- (NSBezierPath*)		verticallyFlippedPathAboutPoint:(NSPoint) cp
{
	NSBezierPath* copy = [self copy];
	
	NSAffineTransform*	xfm = [NSAffineTransform transform];
	[xfm translateXBy:cp.x yBy:cp.y];
	[xfm scaleXBy:1.0 yBy:-1.0];
	[xfm translateXBy:-cp.x yBy:-cp.y];
	
	[copy transformUsingAffineTransform:xfm];
	
	return [copy autorelease];
}


- (NSBezierPath*)		horizontallyFlippedPath
{
	return [self horizontallyFlippedPathAboutPoint:[self centreOfBounds]];
}


- (NSBezierPath*)		verticallyFlippedPath
{
	return [self verticallyFlippedPathAboutPoint:[self centreOfBounds]];
}


#pragma mark -
- (NSPoint)				centreOfBounds
{
	return NSMakePoint( NSMidX([self bounds]), NSMidY([self bounds]));
}


#pragma mark -
- (NSBezierPath*)		paralleloidPathWithOffset:(float) delta
{
	// returns a copy of the receiver modified by offsetting all of its control points by <delta> in the direction of the
	// normal of the path at the location of the on-path control point. This will create a parallel-ish offset path that works
	// for most non-pathological paths. Given that there is no known mathematically correct way to do this, this works well enough in
	// many practical situations. Positive delta moves the path below or to the right, -ve is up and left.
	
	NSBezierPath* newPath = [NSBezierPath bezierPath];
	
	if( ![self isEmpty])
	{
		int						i, count = [self elementCount];
		NSPoint					ap[3], np[3], p0, p1;
		NSBezierPathElement		kind, nextKind;
		float					slope, dx, dy, pdx, pdy;
		
		pdx = pdy = 0;
		
		for( i = 0; i < count; ++i )
		{
			kind = [self elementAtIndex:i associatedPoints:ap];
			
			if ( i < count - 1 )
			{
				nextKind = [self elementAtIndex:i + 1 associatedPoints:np];
				
				// calculate the slope of the on-path point
				
				if ( kind != NSCurveToBezierPathElement )
				{
					p0 = ap[0];
					p1 = np[0];
				}
				else
				{
					p0 = ap[2];
					p1 = np[0];
				}
			}
			else
			{
				if ( kind == NSCurveToBezierPathElement )
				{
					p1 = ap[2];
					p0 = ap[1];
				}
				else
				{
					p1 = ap[0];
					
					nextKind = [self elementAtIndex:i - 1 associatedPoints:np];
				
					if ( nextKind != NSCurveToBezierPathElement )
						p0 = np[0];
					else
						p0 = np[2];
				}
			}
			
			slope = atan2f( p1.y - p0.y, p1.x - p0.x ) + ( pi * 0.5 );
			
			// calculate the position of the modified point
			
			dx = delta * cosf( slope );
			dy = delta * sinf( slope );
			
			switch( kind )
			{
				case NSMoveToBezierPathElement:
					ap[0].x += dx;
					ap[0].y += dy;
					[newPath moveToPoint:ap[0]];
					break;
					
				case NSLineToBezierPathElement:
					ap[0].x += dx;
					ap[0].y += dy;
					[newPath lineToPoint:ap[0]];
					break;
					
				case NSCurveToBezierPathElement:
					ap[0].x += pdx;
					ap[0].y += pdy;
					ap[1].x += dx;
					ap[1].y += dy;
					ap[2].x += dx;
					ap[2].y += dy;
					[newPath curveToPoint:ap[2] controlPoint1:ap[0] controlPoint2:ap[1]];
					break;
					
				case NSClosePathBezierPathElement:
					[newPath closePath];
					break;
					
				default:
					break;
			}
			
			pdx = dx;
			pdy = dy;
		}
	}

	return newPath;
}


- (NSBezierPath*)		paralleloidPathWithOffset2:(float) delta
{
	// similar to the above but works slightly differently - it first flattens the path, works out the parallel then
	// unflattens. When GPC is disabled, works exactly as above.
	
	NSBezierPath* temp = self;
#ifndef qUseGPC
 #pragma unused (delta)
#else
	temp = [temp bezierPathByFlatteningPath];
#endif
	temp = [temp paralleloidPathWithOffset:delta];
#ifdef qUseGPC
	temp = [temp bezierPathByUnflatteningPath];
#endif
	return temp;
}


- (NSBezierPath*)		offsetPathWithStartingOffset:(float) delta1 endingOffset:(float) delta2
{
	// similar to making a paralleloid path, but instead of a constant offset, each point has a different offset
	// applied as a linear function of the difference between delta1 and delta2. So the result has a similar curvature
	// to the original path, but also an additional ramp.
	
	NSBezierPath* newPath = [NSBezierPath bezierPath];
	
	if( ![self isEmpty])
	{
		int						i, count = [self elementCount];
		NSPoint					lp, ap[3], np[3], p0, p1, fp;
		NSBezierPathElement		kind, nextKind;
		float					del, length, slope, dx, dy, pdx, pdy;
		
		pdx = pdy = 0;
		length = [self length];
		
		for( i = 0; i < count; ++i )
		{
			del = ((( delta2 - delta1 ) * i ) / ( count - 1 )) + delta1;
			
		//	LogEvent_(kInfoEvent, @"segment %d, del = %f", i, del );
			
			kind = [self elementAtIndex:i associatedPoints:ap];
			
			if ( i < count - 1 )
			{
				nextKind = [self elementAtIndex:i + 1 associatedPoints:np];
				
				// calculate the slope of the on-path point
				
				if ( kind != NSCurveToBezierPathElement )
				{
					p0 = ap[0];
					p1 = np[0];
				}
				else
				{
					p0 = ap[2];
					p1 = np[0];
				}
			}
			else
			{
				if ( kind == NSCurveToBezierPathElement )
				{
					p1 = ap[2];
					p0 = ap[1];
				}
				else
				{
					p1 = ap[0];
					
					nextKind = [self elementAtIndex:i - 1 associatedPoints:np];
				
					if ( nextKind != NSCurveToBezierPathElement )
						p0 = np[0];
					else
						p0 = np[2];
				}
			}
			
			slope = atan2f( p1.y - p0.y, p1.x - p0.x ) + ( pi * 0.5 );
			
			// calculate the position of the modified point
			
			dx = del * cosf( slope );
			dy = del * sinf( slope );
			
			switch( kind )
			{
				case NSMoveToBezierPathElement:
					ap[0].x += dx;
					ap[0].y += dy;
					[newPath moveToPoint:ap[0]];
					fp = lp = ap[0];
					break;
					
				case NSLineToBezierPathElement:
					ap[0].x += dx;
					ap[0].y += dy;
					[newPath lineToPoint:ap[0]];
					lp = ap[0];
					break;
					
				case NSCurveToBezierPathElement:
				{
					ap[0].x += pdx;
					ap[0].y += pdy;
					ap[1].x += dx;
					ap[1].y += dy;
					ap[2].x += dx;
					ap[2].y += dy;
					[newPath curveToPoint:ap[2] controlPoint1:ap[0] controlPoint2:ap[1]];
					lp = ap[2];
				}
				break;
					
				case NSClosePathBezierPathElement:
					[newPath closePath];
					lp = fp;
					break;
					
				default:
					break;
			}
			
			pdx = dx;
			pdy = dy;
		}
	}

	return newPath;
}


- (NSBezierPath*)		offsetPathWithStartingOffset2:(float) delta1 endingOffset:(float) delta2
{
	// When GPC is disabled, works exactly as above.
	NSBezierPath* temp = self;
#ifndef qUseGPC
 #pragma unused (delta1, delta2)
#else
	temp = [temp bezierPathByFlatteningPath];
#endif
	temp = [temp offsetPathWithStartingOffset:delta1 endingOffset:delta2];
#ifdef qUseGPC
	temp = [temp bezierPathByUnflatteningPath];
#endif
	return temp;
}


#pragma mark -
- (NSBezierPath*)		bezierPathByRandomisingPoints:(float) maxAmount
{
	NSBezierPath* newPath = [self copy];
	
	if( ![self isEmpty])
	{
		if ( maxAmount == 0.0f )
			maxAmount = MIN( [self controlPointBounds].size.width, [self controlPointBounds].size.height ) / 24.0f;
		
		int						i, count = [self elementCount];
		NSPoint					ap[3];
		NSBezierPathElement		kind;
		float					dx, dy;
		
		[newPath removeAllPoints];
		
		for( i = 0; i < count; ++i )
		{
			kind = [self elementAtIndex:i associatedPoints:ap];
			
			dx = [DKRandom randomPositiveOrNegativeNumber] * maxAmount;
			dy = [DKRandom randomPositiveOrNegativeNumber] * maxAmount;
			
			//LogEvent_(kInfoEvent, @"random amount = {%f, %f}", dx, dy );
			
			switch( kind )
			{
				case NSMoveToBezierPathElement:
					[newPath moveToPoint:ap[0]];
					break;
					
				case NSLineToBezierPathElement:
					ap[0].x += dx;
					ap[0].y += dy;
					[newPath lineToPoint:ap[0]];
					break;
					
				case NSCurveToBezierPathElement:
					ap[0].x += dx;
					ap[0].y += dy;
					dx = [DKRandom randomPositiveOrNegativeNumber] * maxAmount;
					dy = [DKRandom randomPositiveOrNegativeNumber] * maxAmount;
					ap[1].x += dx;
					ap[1].y += dy;
					dx = [DKRandom randomPositiveOrNegativeNumber] * maxAmount;
					dy = [DKRandom randomPositiveOrNegativeNumber] * maxAmount;
					ap[2].x += dx;
					ap[2].y += dy;
					[newPath curveToPoint:ap[2] controlPoint1:ap[0] controlPoint2:ap[1]];
					break;
					
				case NSClosePathBezierPathElement:
					[newPath closePath];
					break;
					
				default:
					break;
			}
		}
	}

	return [newPath autorelease];
}


- (NSBezierPath*)		bezierPathWithRoughenedStrokeOutline:(float) amount
{
	// given the path, this returns the outline of the path stroke roughened by the given amount. Roughening works by first taking the stroke outline at the
	// current stroke width, inserting a large number of redundant points and then randomly offsetting each one by a small amount. The result is a path that, when
	// FILLED, will emulate a stroke drawn using a randomly varying width pen. This can be used to give a very naturalistic effect that precise strokes lack. 
	
	NSBezierPath* newPath = [self strokedPath];
	
	if ( newPath != nil && amount > 0.0 )
	{
		// work out the desired flatness by getting the average length of the elements and dividing that down:

		float flatness = 4.0 / ([newPath length] / [newPath elementCount]);
		
		//NSLog(@"flatness = %f", flatness);
		
		// break up existing line segments into short lengths:
		
		newPath = [newPath bezierPathWithFragmentedLineSegments:[self lineWidth] / 2.0 ];
		
		// flatten the path - this breaks up curve segments into short straight segments

		[[self class] setDefaultFlatness:flatness];
		newPath = [newPath bezierPathByFlatteningPath];
		
		// randomise the positions of the points
		
		newPath = [newPath bezierPathByRandomisingPoints:amount];
	}
	
	return newPath; //[newPath bezierPathByUnflatteningPath];
}


- (NSBezierPath*)		bezierPathWithFragmentedLineSegments:(float) flatness
{
	// this is only really useful as a step in the roughened stroke processing. It takes a path and for any line elements in the path, it breaks them up into
	// much shorter lengths by interpolation.
	
	NSBezierPath*			newPath = [NSBezierPath bezierPath];
	int						i, m, k, j;
	NSBezierPathElement		element;
	NSPoint					ap[3];
	NSPoint					fp, pp;
	float					len, t;
	
	fp = pp = NSZeroPoint;	// shut up, stupid warning
	
	m = [self elementCount];
	
	for( i = 0; i < m; ++ i )
	{
		element = [self elementAtIndex:i associatedPoints:ap];
		
		switch( element )
		{
			case NSMoveToBezierPathElement:
				fp = pp = ap[0];
				[newPath moveToPoint:fp];
				break;
				
			case NSLineToBezierPathElement:
				len = LineLength( pp, ap[0] );
				k = floor( len / flatness );
				
				//NSLog(@"inserting %d fragments", k );
				
				for( j = 0; j < k; ++j )
				{
					t = (( j + 1 ) * flatness ) / len;
					NSPoint np = Interpolate( pp, ap[0], t );
					[newPath lineToPoint:np];
				}
				pp = ap[0];
				break;
				
			case NSCurveToBezierPathElement:
				[newPath curveToPoint:ap[2] controlPoint1:ap[0] controlPoint2:ap[1]];
				pp = ap[2];
				break;
				
			case NSClosePathBezierPathElement:
				[newPath closePath];
				pp = fp;
				break;
				
			default:
				break;
		}
	}

	return newPath;
}



#pragma mark -
#pragma mark - zig-zags and waves
- (NSBezierPath*)		bezierPathWithZig:(float) zig zag:(float) zag
{
	// returns a zigzag based on the original path. The "zig" is the length along the path between each point, and the "zag" is the distance offset
	// normal to the path. By joining up the series of points so generated, an accurate zig-zag path is formed. Note that the returned path follows the
	// curvature of the original but it contains no curved segments itself.
	
	float			len, t = 0.0, slope;
	NSPoint			zp, np, fp;
	NSBezierPath*	newPath;
	BOOL			side = 0;		// are we zigging or zagging?
	BOOL			doneFirst = NO;
	
	len = [self length];
	newPath = [NSBezierPath bezierPath];
	fp = [self firstPoint];
	[newPath moveToPoint:fp];
	[newPath setWindingRule:[self windingRule]];
	
	while( t < len )
	{
		if (( t + zig ) > len )
		{
			if ([self isPathClosed])
				zp = [self pointOnPathAtLength:0.0 slope:&slope];
			else
				zp = [self pointOnPathAtLength:len slope:&slope];
		}
		else
			zp = [self pointOnPathAtLength:t slope:&slope];
	
		// calculate position of corner offset from the path
		
		if ( side )
			slope += ( pi / 2.0 );
		else
			slope -= ( pi / 2.0 );
	
		side = !side;
		
		np.x = zp.x + ( cosf( slope ) * zag );
		np.y = zp.y + ( sinf( slope ) * zag );
		
		if ( doneFirst )
			[newPath lineToPoint:np];
		else
		{
			[newPath moveToPoint:np];
			doneFirst = YES;
			fp = np;
		}
		
		t += zig;
	}
	
	if ([self isPathClosed])
		[newPath closePath];
		
	return newPath;
}


- (NSBezierPath*)		bezierPathWithWavelength:(float) lambda amplitude:(float) amp spread:(float) spread
{
	// similar effect to a zig-zag, but creates curved segments which smoothly oscillate about the master path. Wavelength is the distance between each peak
	// (note - this is half the actual "wavelength" in the strict sense) and amplitude is the distance from the path. Spread is a value indicating the
	// "roundness" of the peak, and is a value between 0 and 1. 0 is equivalent to a sharp zig-zag as above.
	
	if ( spread <= 0.0 )
		return [self bezierPathWithZig:lambda zag:amp];
	else
	{
		float			len, t = 0.0, slope, rad, lastSlope;
		NSPoint			zp, np, fp, cp1, cp2;
		NSBezierPath*	newPath;
		BOOL			side = 0;		// are we zigging or zagging?
		BOOL			doneFirst = NO;
		
		len = [self length];
		newPath = [NSBezierPath bezierPath];
		[newPath moveToPoint:fp = [self firstPoint]];
		[newPath setWindingRule:[self windingRule]];

		rad = amp * spread;
		
		lastSlope = [self slopeStartingPath];
		
		while( t <= len )
		{
			if (( t + lambda ) > len )
			{
				if ([self isPathClosed])
				{
					// if we are not in the same phase as the start of the path, need to insert an extra curve segment
					
					if ( side == 1 )
					{
						t = (t + len) / 2.0;
						zp = [self pointOnPathAtLength:t slope:&slope];
						lambda = len - t;
					}
					else
						zp = [self pointOnPathAtLength:0.0 slope:&slope];
				}
				else
					zp = [self pointOnPathAtLength:len slope:&slope];
			}
			else
				zp = [self pointOnPathAtLength:t slope:&slope];
		
			// calculate position of peak offset from the path
			
			float slp = slope;
			
			if ( side )
				slp += ( pi / 2.0 );
			else
				slp -= ( pi / 2.0 );
		
			side = !side;
			
			np.x = zp.x + ( cosf( slp ) * amp );
			np.y = zp.y + ( sinf( slp ) * amp );
			
			// calculate the control points
			
			cp1 = [newPath currentPoint];
			cp1.x += cosf( lastSlope ) * rad;
			cp1.y += sinf( lastSlope ) * rad;
			
			cp2 = np;
			cp2.x += cosf( slope - pi ) * rad;
			cp2.y += sinf( slope - pi ) * rad;
			
			if ( doneFirst )
				[newPath curveToPoint:np controlPoint1:cp1 controlPoint2:cp2];
			else
			{
				[newPath moveToPoint:np];
				doneFirst = YES;
			}
			
			lastSlope = slope;
			t += lambda;
		}
		
		if ([self isPathClosed])
		{
			
			
			
			
			[newPath closePath];
		}
		return newPath;
	}
}


#pragma mark -
#pragma mark - getting the outline of a stroked path
- (NSBezierPath*)		strokedPath
{
	// returns a path representing the stroked edge of the receiver, taking into account its current width and other
	// stroke settings. This works by converting to a quartz path and using the similar system function there.
	
	// this makes an offscreen window in order to obtain a reliable context for performing the operation
	
	[NSGraphicsContext saveGraphicsState];
	
	NSRect	wr = [self bounds];
	wr = NSInsetRect( wr, [self lineWidth] * -2, [self lineWidth] * -2);
	wr.origin = NSMakePoint( 8000, 8000 );
	
	NSWindow* offscreen = [[NSWindow alloc] initWithContentRect:wr styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
	NSGraphicsContext* ctx = [NSGraphicsContext graphicsContextWithWindow:offscreen];
	[NSGraphicsContext setCurrentContext:ctx];
	
	CGContextRef context = [self setQuartzPath];
	
	NSBezierPath* path = self;
	
	if ( context )
	{
		CGContextReplacePathWithStrokedPath( context );
		path = [NSBezierPath bezierPathWithPathFromContext:context];
	}
	
	[NSGraphicsContext restoreGraphicsState];
	[offscreen release];
	
	return path;
}


- (NSBezierPath*)		strokedPathWithStrokeWidth:(float) width
{
	[self setLineWidth:width];
	return [self strokedPath];
}


#pragma mark -
#pragma mark - breaking a path apart
- (NSArray*)			subPaths
{
	// returns an array of bezier paths, each derived from this path's subpaths.
	
	NSMutableArray*		sp = [[NSMutableArray alloc] init];
    int					i, numElements;
	NSBezierPath*		temp = nil;
	BOOL				added = NO;
 
    // If there are elements to draw, create a CGMutablePathRef and draw.

    numElements = [self elementCount];
	NSPoint	points[3];

	for (i = 0; i < numElements; i++)
	{
		switch ([self elementAtIndex:i associatedPoints:points])
		{
			case NSMoveToBezierPathElement:
				temp = [NSBezierPath bezierPath];
				[temp moveToPoint:points[0]];
				added = NO;
				break;

			case NSLineToBezierPathElement:
				[temp lineToPoint:points[0]];
				break;

			case NSCurveToBezierPathElement:
				[temp curveToPoint:points[2] controlPoint1:points[0] controlPoint2:points[1]];
				break;

			case NSClosePathBezierPathElement:
				[temp closePath];
				break;
				
			default:
				break;
		}
		
		if ( !added && [temp elementCount] > 1 )
		{
			[sp addObject:temp];
			added = YES;
		}
	}
	return [sp autorelease];
}


- (int)					countSubPaths
{
	// returns the number of moveTo ops in the path, though doesn't count a final moveTo as following a closepath
	
	int m, i, spc = 0;
	
    m = [self elementCount] - 1;

	for (i = 0; i < m; ++i)
	{
		if([self elementAtIndex:i] == NSMoveToBezierPathElement)
			++spc;
	}
	
	return spc;
}

#pragma mark -
#pragma mark - getting text layout rects for running text within a shape


static int				SortPointsHorizontally( id value1, id value2, void* context )
{
	#pragma unused(context)
	NSPoint a, b;
	
	a = [value1 pointValue];
	b = [value2 pointValue];
	
	if( a.x > b.x )
		return NSOrderedDescending;
	else if ( a.x < b.x )
		return NSOrderedAscending;
	else
		return NSOrderedSame;
}


- (NSArray*)			intersectingPointsWithHorizontalLineAtY:(float) yPosition
{
	// given a y value within the bounds, this returns an array of points (as NSValues) which are the intersection of
	// a horizontal line extending across the full width of the shape at y and the curve itself. This works by approximating the curve as a series
	// of straight lines and testing each one for intersection with the line at y. This is the primitive method used to determine line layout
	// rectangles - a series of calls to this is needed for each line (incrementing y by the lineheight) and then rects forming from the
	// resulting points. See -lineFragmentRectsForFixedLineheight:
	
	NSAssert( yPosition > 0.0, @"y value must be greater than 0");
	
	if([self isEmpty])
		return nil;		// nothing here, so bail
		
	NSRect br = [self bounds];
	
	// see if y is within the bounds - if not, there can't be any intersecting points so we can bail now.
	
	if( yPosition < NSMinY( br ) || yPosition > NSMaxY( br ))
		return nil;
		
	// set up the points for the horizontal line:
	
	br = NSInsetRect( br, -1, -1 );
	
	NSPoint hla, hlb;
	
	hla.y = hlb.y = yPosition;
	hla.x = NSMinX( br ) - 1;
	hlb.x = NSMaxX( br) + 1;
	
	// we can use a relatively coarse flatness for more speed - exact precision isn't needed for text layout.
	
	float savedFlatness = [self flatness];
	[self setFlatness:5.0];	
	NSBezierPath*	flatpath = [self bezierPathByFlatteningPath];
	[self setFlatness:savedFlatness];
	
	NSMutableArray*		result = [NSMutableArray array];
	int					i, m = [flatpath elementCount];
	NSBezierPathElement	lm;
	NSPoint				fp, lp, ap, ip;
	fp = lp = ap = ip = NSZeroPoint;
	
	for( i = 0; i < m; ++i )
	{
		lm = [flatpath elementAtIndex:i associatedPoints:&ap];
		
		if ( lm == NSMoveToBezierPathElement )
			fp = lp = ap;
		else
		{
			if( lm == NSClosePathBezierPathElement )
				ap = fp;
			
			ip = Intersection2( ap, lp, hla, hlb );
			lp = ap;
		
			// if the result is NaN, lines are parallel and don't intersect. The intersection point may also fall outside the bounds,
			// so we discard that result as well.
			
			//if( isnan( ip.x ) || isnan( ip.y ) || isinf( ip.x ) || isinf( ip.y ))
			if( NSEqualPoints( ip, NSMakePoint( -1, -1 )))
				continue;
				
			if ( NSPointInRect( ip, br ))
				[result addObject:[NSValue valueWithPoint:ip]];
		}
	}
	
	// if the result is not empty, sort the points into order horizontally
	
	if([result count] > 0 )
	{
		[result sortUsingFunction:SortPointsHorizontally context:NULL];
		
		// if the result is odd, it means that we don't have a closed path shape at the line position -
		// i.e. there's an open endpoint. So to ensure that we return an even number of items (or none),
		// delete the last item to make the result even.
		
		if(([result count] & 1) == 1)
		{
			[result removeLastObject];
			
			if([result count] == 0 )
				result = nil;
		}
	}
	else
		result = nil;	// nothing found, so just return nil
	
	return result;
}


- (NSArray*)			lineFragmentRectsForFixedLineheight:(float) lineHeight
{
	// given a lineheight value, this returns an array of rects (as NSValues) which are the ordered line layout rects from left to right and top to bottom
	// within the shape to layout text in. This is computationally intensive, so the result should probably be cached until the shape is actually changed.
	// This works with a fixed lineheight, where every line is the same.
	
	// Note that this method isn't really suitable for use with NSTextContainer or Cocoa's text system in general - for flowing text using NSLayoutManager use
	// DKBezierTextContainer which calls the -lineFragmentRectForProposedRect:remainingRect: method below.
	
	NSAssert( lineHeight > 0.0, @"lineheight must be positive and greater than 0");
	
	NSRect br = [self bounds];
	NSMutableArray*	result = [NSMutableArray array];
	
	// how many lines will fit in the shape?
	
	int lineCount = ( floor( NSHeight( br ) / lineHeight)) + 1;
	
	if( lineCount > 0 )
	{
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
		NSArray*		previousLine = nil;
		NSArray*		currentLine;
		int				i;
		float			linePosition = NSMinY( br );
		NSRect			lineRect;
		
		lineRect.size.height = lineHeight;
		
		for( i = 0; i < lineCount; ++i )
		{
			lineRect.origin.y = linePosition;
			
			if ( i == 0 )
				previousLine = [self intersectingPointsWithHorizontalLineAtY:linePosition + 1];
			else
			{
				linePosition = NSMinY( br ) + (i * lineHeight);
				currentLine = [self intersectingPointsWithHorizontalLineAtY:linePosition];
				
				if( currentLine != nil )
				{
					// go through the points of the previous line and this one, forming rects
					// by taking the inner points
					
					unsigned j, ur, lr, rectsOnLine;
					
					ur = [previousLine count];
					lr = [currentLine count];
					
					rectsOnLine = MAX( ur, lr );
					
					for( j = 0; j < rectsOnLine; ++j )
					{
						NSPoint upper, lower;
						
						upper = [[previousLine objectAtIndex:j % ur] pointValue];
						lower = [[currentLine objectAtIndex:j % lr] pointValue];
							
						// even values of j are left edges, odd values are right edges
						
						if(( j & 1 ) == 0 )
							lineRect.origin.x = MAX( upper.x, lower.x );
						else
						{
							lineRect.size.width = MIN( upper.x, lower.x ) - lineRect.origin.x;
							lineRect = NormalizedRect( lineRect );
							
							// if any corner of the rect is outside the path, chuck it

							NSRect tr = NSInsetRect( lineRect, 1, 1 );
							NSPoint tp = NSMakePoint( NSMinX( tr ), NSMinY( tr ));
							
							if(![self containsPoint:tp])
								continue;
								
							tp = NSMakePoint( NSMaxX( tr ), NSMinY( tr ));
							if(![self containsPoint:tp])
								continue;
							
							tp = NSMakePoint( NSMaxX( tr ), NSMaxY( tr ));
							if(![self containsPoint:tp])
								continue;
							
							tp = NSMakePoint( NSMinX( tr ), NSMaxY( tr ));
							if(![self containsPoint:tp])
								continue;

							[result addObject:[NSValue valueWithRect:lineRect]];
						}
					}
				
					previousLine = currentLine;
				}
			}
		}
		[pool release];
	}
	
	return result;
}


- (NSRect)				lineFragmentRectForProposedRect:(NSRect) aRect remainingRect:(NSRect*) rem
{
	return [self lineFragmentRectForProposedRect:aRect remainingRect:rem datumOffset:0];
}


- (NSRect)				lineFragmentRectForProposedRect:(NSRect) aRect remainingRect:(NSRect*) rem datumOffset:(float) dOffset
{
	// The datum offset is a value
	// between -0.5 and +0.5 that specifies where in the line's height is used to find the shape's intersections at that y value.
	// A value of 0 means use the centre of the line, -0.5 the top, and +0.5 the bottom. 
	
	// this offsets <proposedRect> to the right to the next even-numbered intersection point, setting its length to the difference
	// between that point and the next. That part is the return value. If there are any further points, the remainder is set to
	// the rest of the rect. This allows this method to be used directly by a NSTextContainer subclass
	
	float od = LIMIT( dOffset, -0.5, +0.5 ) + 0.5;
	
	NSRect result;
	
	result.origin.y = NSMinY( aRect );
	result.size.height = NSHeight( aRect );
	
	float y = NSMinY( aRect ) + ( od * NSHeight( aRect ));
	
	// find the intersection points - these are already sorted left to right
	
	NSArray*	thePoints = [self intersectingPointsWithHorizontalLineAtY:y];
	NSPoint		p1, p2;
	int			ptIndex, ptCount;
	
	ptCount = [thePoints count];
	
	// search for the next even-numbered intersection point starting at the left edge of proposed rect.
	
	for( ptIndex = 0; ptIndex < ptCount; ptIndex += 2 )
	{
		p1 = [[thePoints objectAtIndex:ptIndex] pointValue];
	
		// even, so it's a left edge
		
		if( p1.x >= aRect.origin.x )
		{
			// this is the main rect to return
			
			p2 = [[thePoints objectAtIndex:ptIndex + 1] pointValue];
		
			result.origin.x = p1.x;
			result.size.width = p2.x - p1.x;
			
			// and this is the remainder
			
			if( rem != nil )
			{
				aRect.origin.x = p2.x;
				*rem = aRect;
			}
			
			return result;
		}
	}
	
	// if we went through all the points and there were no more following the left edge of proposedRect, then there's no
	// more space on this line, so return zero rect.
	
	result = NSZeroRect;
	 if ( rem != nil )
		*rem = NSZeroRect;

	return result;
}



#pragma mark -
#pragma mark - converting to and from Core Graphics paths
- (CGPathRef)			quartzPath
{
	CGMutablePathRef mpath = [self mutableQuartzPath];
	CGPathRef		 path = CGPathCreateCopy(mpath);
    CGPathRelease(mpath);
	return path;
}


- (CGMutablePathRef)	mutableQuartzPath
{
    int i, numElements;
 
    // If there are elements to draw, create a CGMutablePathRef and draw.

    numElements = [self elementCount];
    if (numElements > 0)
    {
        CGMutablePathRef    path = CGPathCreateMutable();
        NSPoint             points[3];
 
        for (i = 0; i < numElements; i++)
        {
            switch ([self elementAtIndex:i associatedPoints:points])
            {
                case NSMoveToBezierPathElement:
                    CGPathMoveToPoint(path, NULL, points[0].x, points[0].y);
                    break;
 
                case NSLineToBezierPathElement:
                    CGPathAddLineToPoint(path, NULL, points[0].x, points[0].y);
                    break;
 
                case NSCurveToBezierPathElement:
                    CGPathAddCurveToPoint(path, NULL, points[0].x, points[0].y,
                                                points[1].x, points[1].y,
                                                points[2].x, points[2].y);
                    break;
 
                case NSClosePathBezierPathElement:
                    CGPathCloseSubpath(path);
                    break;
					
				default:
					break;
            }
        }
		
		return path;
    }
 
    return nil;
}


- (CGContextRef)		setQuartzPath
{
	// converts the path to a CGPath and adds it as the current context's path. It also copies the current line width
	// and join and cap styles, etc. to the context.
	
	CGContextRef	context = [[NSGraphicsContext currentContext] graphicsPort];
	
	NSAssert( context != nil, @"oops - no context for setQuartzPath");
	
//	LogEvent_(kStateEvent, @"set quartz path - context: %@", context );
	
	if ( context )
		[self setQuartzPathInContext:context isNewPath:YES];
	
	return context;
}


- (void)				setQuartzPathInContext:(CGContextRef) context isNewPath:(BOOL) np
{
	CGPathRef		cp = [self quartzPath];
	
	if ( np )
		CGContextBeginPath( context );
		
	CGContextAddPath( context, cp );
	CGPathRelease( cp );
	
	CGContextSetLineWidth( context, [self lineWidth]);
	CGContextSetLineCap( context, (CGLineCap)[self lineCapStyle]);
	CGContextSetLineJoin( context, (CGLineJoin)[self lineJoinStyle]);
	CGContextSetMiterLimit( context, [self miterLimit]);
	
	float	lengths[16];
	float	phase;
	int		count;
	
	[self getLineDash:lengths count:&count phase:&phase];
	CGContextSetLineDash( context, phase, lengths, count );
}


#pragma mark -
+ (NSBezierPath*)		bezierPathWithCGPath:(CGPathRef) path
{
	// given a CGPath, this converts it to the equivalent NSBezierPath by using a custom apply function
	
	NSBezierPath* newPath = [self bezierPath];
	CGPathApply( path, newPath, ConvertPathApplierFunction );
	return newPath;
}


+ (NSBezierPath*)		bezierPathWithPathFromContext:(CGContextRef) context
{
	// given a context, this converts its current path to an NSBezierPath, also setting the line width and styles from
	// the context. It is the inverse to the -setQuartzPath method.
	
	// NOTE: this uses an undocumented function in CG (CGContextCopyPath)
	
	CGPathRef cp = CGContextCopyPath( context );
	NSBezierPath* bp = [self bezierPathWithCGPath:cp];
	CGPathRelease( cp );
	
	return bp;
}


#pragma mark -
- (NSPoint)				pointOnPathAtLength:(float) length slope:(float*) slope
{
	// Given a length in terms of the distance from the path start, this returns the point and slope
	// of the path at that position. This works for any path made up of line or curve segments or combinations of them. This should be used with
	// paths that have no subpaths. If the path has less than two elements, the result is NSZeroPoint.
	
	NSPoint					p = NSZeroPoint;
	NSPoint					ap[3], lp[3];
	NSBezierPathElement		pre, elem;
	
	if ([self elementCount] < 2 )
		return p;
	
	if ( length <= 0.0 )
	{
		[self elementAtIndex:0 associatedPoints:ap];
		p = ap[0];
		
		[self elementAtIndex:1 associatedPoints:lp];
		
		if ( slope )
			*slope = Slope( ap[0], lp[0] );
	}
	else
	{
		NSBezierPath* temp = [self bezierPathByTrimmingToLength:length];
		
		// given the trimmed path, the desired point is at the end of the path.
		
		int			ec = [temp elementCount];
		float		slp = 1;
		
		if ( ec > 1 )
		{
			elem = [temp elementAtIndex:ec - 1 associatedPoints:ap];
			pre = [temp elementAtIndex:ec - 2 associatedPoints:lp];
			
			if ( pre == NSCurveToBezierPathElement )
				lp[0] = lp[2];
			
			if ( elem == NSCurveToBezierPathElement )
			{
				slp = Slope( ap[1], ap[2] );
				p = ap[2];
			}
			else
			{
				slp = Slope( lp[0], ap[0] );
				p = ap[0];
			}
		}

		if ( slope )
			*slope = slp;
	}
	return p;
}


- (float)				slopeStartingPath
{
	// returns the slope starting the path
	
	if ([self elementCount] > 1)
	{
		NSPoint	ap[3], lp[3];

		[self elementAtIndex:0 associatedPoints:ap];
		[self elementAtIndex:1 associatedPoints:lp];
		
		return Slope( ap[0], lp[0] );
	}
	else
		return 0;
}


#pragma mark -
#pragma mark - drawing text along a path
- (void)				drawTextOnPath:(NSAttributedString*) str yOffset:(float) dy
{
	NSBezierPath* textPath = [self bezierPathWithTextOnPath:str yOffset:dy];
	
	// render the text path using the foreground colour and shadow of the attributed string
	
	NSColor* textColour = [str attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:NULL];
	
	if ( textColour )
		[textColour set];
	else
		[[NSColor blackColor] set];
	
	// any shadow?
	
	NSShadow* textShadow = [str attribute:NSShadowAttributeName atIndex:0 effectiveRange:NULL];
	
	if ( textShadow )
		[textShadow setAbsoluteFlipped:YES];
	
	// draw it

	[textPath fill];
	
	// any stroke?
		
	NSDictionary*	attrs = [str attributesAtIndex:0 effectiveRange:NULL];
	
	if ([attrs objectForKey:NSStrokeWidthAttributeName] != nil )
	{
		float stroke = [[str attribute:NSStrokeWidthAttributeName atIndex:0 effectiveRange:NULL] floatValue];
		
		if ( stroke > 0 )
		{
			// !!! the value is in percent of font point size, not absolute stroke width
			
			NSFont* font = [str attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
			
			float strokeWidth = ([font pointSize] * stroke ) / 100.0;
			
			textColour = [str attribute:NSStrokeColorAttributeName atIndex:0 effectiveRange:NULL];
			if ( textColour )
				[textColour set];
				
			[textPath setLineWidth:strokeWidth];
			[textPath stroke];
		}
	}
}


- (void)				drawStringOnPath:(NSString*) str
{
	[self drawStringOnPath:str attributes:nil];
}


- (void)				drawStringOnPath:(NSString*) str attributes:(NSDictionary*) attrs;
{
	if ( attrs == nil )
	{
		NSFont *font = [NSFont fontWithName:@"Helvetica" size:12.0];
		attrs = [NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName];
	}
	
	NSAttributedString* as = [[NSAttributedString alloc] initWithString:str attributes:attrs];
	[self drawTextOnPath:as yOffset:0];
	[as release];
}


#pragma mark -
- (NSBezierPath*)		bezierPathWithTextOnPath:(NSAttributedString*) str yOffset:(float) dy
{
	// returns a new path consisting of the glyphs laid out along the current path from <str>
	
	if([self elementCount] < 2 || [str length] < 1 )
		return nil;	// nothing useful to do
		
	NSBezierPath*	newPath = [NSBezierPath bezierPath];
	NSPoint			start;
	
	[self elementAtIndex:0 associatedPoints:&start];
	[newPath moveToPoint:start];
	
	// init temporary text system
			
    NSTextStorage* ts = [[NSTextStorage alloc] initWithAttributedString:str];
    NSLayoutManager* lm = [[NSLayoutManager alloc] init];
    NSTextContainer* tc = [[NSTextContainer alloc] init];
    [lm addTextContainer:tc];
    [tc release];
    [ts addLayoutManager:lm];
    [lm release];
    [lm setUsesScreenFonts:NO]; 

	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	NSBezierPath*	temp, *glyphTemp;
	NSFont*			font = [str attribute:NSFontAttributeName atIndex:0 effectiveRange:NULL];
	
	unsigned glyphIndex;
	NSRect	gbr;
	
	gbr.size = NSMakeSize([self length], [lm defaultLineHeightForFont:font]);
	gbr.origin = NSZeroPoint;
	
	// set container size so that the width is the path's length - this will honour left/right/centre paragraphs setting
	// and truncate at the end of the last whole word that can be fitted.
	
	[tc setContainerSize:gbr.size];
	NSRange glyphRange = [lm glyphRangeForBoundingRect:gbr inTextContainer:tc];
	
	// lay down the glyphs along the path
	
    for (glyphIndex = glyphRange.location; glyphIndex < NSMaxRange(glyphRange); glyphIndex++)
	{
		NSRect lineFragmentRect = [lm lineFragmentRectForGlyphAtIndex:glyphIndex effectiveRange:NULL];
		NSPoint viewLocation, layoutLocation = [lm locationForGlyphAtIndex:glyphIndex];
		NSGlyph	glyph;
		
        layoutLocation.x += lineFragmentRect.origin.x;
        layoutLocation.y += lineFragmentRect.origin.y;
		
		gbr = [lm boundingRectForGlyphRange:NSMakeRange( glyphIndex, 1) inTextContainer:tc];
		float half = gbr.size.width * 0.5f;
		
		// if the character width is zero or -ve, skip it - some control glyphs appear to need  suppressing in this way
		
		if ( gbr.size.width > 0 )
		{
			// get a shortened path that starts at the character location
			
			temp = [self bezierPathByTrimmingFromLength:layoutLocation.x + half];
			
			// if no more room on path, stop laying glyphs (will not normally occur as glyph range is set to one line)
			
			if ([temp length] < half )
				break;
				
			[temp elementAtIndex:0 associatedPoints:&viewLocation];
			float angle = [temp slopeStartingPath];
			
			// view location needs to be projected back along the baseline tangent by half the character width to align
			// the character based on the middle of the glyph instead of the left edge
			
			viewLocation.x -= half * cosf( angle );
			viewLocation.y -= half * sinf( angle );
			
			NSAffineTransform *transform = [NSAffineTransform transform];
			[transform translateXBy:viewLocation.x yBy:viewLocation.y];
			[transform rotateByRadians:angle];
			[transform scaleXBy:1 yBy:-1];		// assumes destination is flipped
			
			glyph = [lm glyphAtIndex:glyphIndex];
			glyphTemp = [[NSBezierPath alloc] init];
			[glyphTemp moveToPoint:NSMakePoint( 0, dy )];
			[glyphTemp appendBezierPathWithGlyph:glyph inFont:font];
			[glyphTemp transformUsingAffineTransform:transform];
			
			[newPath appendBezierPath:glyphTemp];
			[glyphTemp release];
		}
    }
	[pool release];
	[ts release];
	
	return newPath;
}


- (NSBezierPath*)		bezierPathWithStringOnPath:(NSString*) str
{
	return [self bezierPathWithStringOnPath:str attributes:nil];
}


- (NSBezierPath*)		bezierPathWithStringOnPath:(NSString*) str attributes:(NSDictionary*) attrs
{
	NSAttributedString* as = [[NSAttributedString alloc] initWithString:str attributes:attrs];
	NSBezierPath*		np = [self bezierPathWithTextOnPath:as yOffset:0];
	[as release];
	return np;
}


#pragma mark -
#pragma mark - drawing/placing/moving anything along a path
- (NSArray*)			placeObjectsOnPathAtInterval:(float) interval factoryObject:(id) object userInfo:(void*) userInfo
{
	// at each <interval> of distance, calls <object> with the placeObjectAtPoint... method and adds its result to the array. This can be
	// used to place a series of other objects along the path at a linear spacing.
	
	if ([self elementCount] < 2 || interval <= 0 )
		return nil;
		
	NSMutableArray*		array = [[NSMutableArray alloc] init];
	NSPoint				p;
	float				slope, distance, length;
	id					placedObject;
	
	distance = 0;
	
	length = [self length];
	
	while( distance <= length )
	{
		p = [self pointOnPathAtLength:distance slope:&slope];
		
		placedObject = [object placeObjectAtPoint:p onPath:self position:distance slope:slope userInfo:userInfo];
		
		if ( placedObject )
			[array addObject:placedObject];
	
		distance += interval;
	}
	
	return [array autorelease];
}


- (NSBezierPath*)		bezierPathWithObjectsOnPathAtInterval:(float) interval factoryObject:(id) object userInfo:(void*) userInfo
{
	// as above, but where the returned objects are in themselves paths, they are appended into one general path and returned.
	
	if ([self elementCount] < 2 || interval <= 0 )
		return nil;

	NSBezierPath*	newPath = nil;
	NSArray*		placedObjects = [self placeObjectsOnPathAtInterval:interval factoryObject:object userInfo:userInfo];
	
	if ([placedObjects count] > 0 )
	{
		newPath = [NSBezierPath bezierPath];
		
		NSEnumerator*	iter = [placedObjects objectEnumerator];
		id				obj;
		
		while(( obj = [iter nextObject]))
		{
			if ([obj isKindOfClass:[NSBezierPath class]])
				[newPath appendBezierPath:obj];
		}
	}
	
	return newPath;
}


- (NSBezierPath*)		bezierPathWithPath:(NSBezierPath*) path atInterval:(float) interval
{
	// as above, but places copies of <path> along this path spaced at the interval <interval>. The path is rotated to match the slope of the
	// path at each point, but is not scaled. Each copy of the path is centred at the calculated location.
	
	if ([self elementCount] < 2 || interval <= 0 )
		return nil;

	NSBezierPath*		newPath = [NSBezierPath bezierPath];
	NSBezierPath*		temp;
	NSPoint				p, q;
	float				slope, distance, length;
	
	distance = 0;
	
	length = [self length];
	
	while( distance <= length )
	{
		p = [self pointOnPathAtLength:distance slope:&slope];
		
		temp = [path copy];
		
		// centre the path at <p> and rotate it to match <slope>
		
		q.x = NSMidX([temp bounds]);
		q.y = NSMidY([temp bounds]);
		
		NSAffineTransform* tfm = [NSAffineTransform transform];
		
		[tfm translateXBy:-q.x yBy:-q.y];
		[tfm rotateByRadians:slope];
		[tfm translateXBy:p.x yBy:p.y];
		
		[temp transformUsingAffineTransform:tfm];
		[newPath appendBezierPath:temp];
		[temp release];
	
		distance += interval;
	}
	
	return newPath;
}


#pragma mark -
#pragma mark - placing "chain links" along a path
- (NSArray*)			placeLinksOnPathWithLinkLength:(float) ll factoryObject:(id) object userInfo:(void*) userInfo
{
	return [self placeLinksOnPathWithEvenLinkLength:ll oddLinkLength:ll factoryObject:object userInfo:userInfo];
}


- (NSArray*)			placeLinksOnPathWithEvenLinkLength:(float) ell oddLinkLength:(float) oll factoryObject:(id) object userInfo:(void*) userInfo
{
	// similar to object placement, but treats the objects as "links" like in a chain, where a rigid link of a fixed length connects two points on the path.
	// The factory object is called with the pair of points computed, and returns a path representing the link between those two points. Non-nil results are
	// accumulated into the array returned. Even and odd links can have different lengths for added flexibility. Note that to keep this working quickly, the
	// link length is used as a path length to find the initial link pivot point, then the actual point is calculated by using the link radius in this direction.
	// The result can be that links will not exactly follow a very convoluted or curved path, but each link is guaranteed to be a fixed length and exactly
	// join to its neighbours.
	
	
	if ([self elementCount] < 2 || ell <= 0 || oll <= 0 )
		return nil;
		
	NSMutableArray*		array = [[NSMutableArray alloc] init];
	int					linkCount = 0;
	NSPoint				prevLink;
	NSPoint				p = NSZeroPoint;
	float				distance, length, angle, radius;
	id					placedObject;
	
	distance = 0;
	length = [self length];
	prevLink = [self firstPoint];
	
	while( distance <= length )
	{
		// find an initial point
		
		if ( linkCount & 1 )
			radius = oll;
		else
			radius = ell;
			
		distance += radius;
		
		if ( distance <= length )
		{
			p = [self pointOnPathAtLength:distance slope:NULL];
			
			// point to use will be in this general direction but ensure link length is correct:
			
			angle = atan2( p.y - prevLink.y, p.x - prevLink.x );
			p.x = prevLink.x + ( cosf( angle ) * radius );
			p.y = prevLink.y + ( sinf( angle ) * radius );
			
			placedObject = [object placeLinkFromPoint:prevLink toPoint:p onPath:self linkNumber:linkCount++ userInfo:userInfo];
					
			if ( placedObject )
				[array addObject:placedObject];
		}
		prevLink = p;
	}
	
	return [array autorelease];
}


#pragma mark -
#pragma mark - easy motion method
- (void)				moveObject:(id) object atSpeed:(float) speed loop:(BOOL) loop userInfo:(id) userInfo
{
	// moves an object along the path at the speed given, which is a value in pixels per second. The object must respond to the motion protocol.
	// This tries to maintain a 30 frames per second rate, calculating the distance moved using the actual time elapsed. This returns immediately
	// after starting the motion, which continues as the timer runs and there is remaining path to use, or if we are set to loop. The object being
	// moved can abort the motion at any time by returning NO.
	
	NSAssert( object != nil, @"can't move a nil object");
	
	if ([self elementCount] < 2 || speed <= 0 )
		return;

	if ( object )
	{
		// set the object's position to the start of the path initially
		
		NSPoint		where;
		float		slope;
		
		where = [self pointOnPathAtLength:0 slope:&slope];
		if([object moveObjectTo:where position:0 slope:slope userInfo:userInfo])
		{
			// set up a dictionary of parameters we can pass using the timer (allows many concurrent motions since there are no state variables
			// cached by the object)
			
			NSMutableDictionary*	parameters = [[NSMutableDictionary alloc] init];
			
			[parameters setObject:self forKey:@"path"];
			[parameters setObject:[NSNumber numberWithFloat:speed] forKey:@"speed"];
			
			if ( userInfo != nil )
				[parameters setObject:userInfo forKey:@"userinfo"];
			
			[parameters setObject:object forKey:@"target"];
			[parameters setObject:[NSNumber numberWithFloat:[self length]] forKey:@"path_length"];
			[parameters setObject:[NSNumber numberWithBool:loop] forKey:@"loop"];
			[parameters setObject:[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]] forKey:@"start_time"];
			
			NSTimer*	t = [NSTimer timerWithTimeInterval:1.0/30.0 target:self selector:@selector(motionCallback:) userInfo:parameters repeats:YES];
			
			[parameters release];
			[[NSRunLoop currentRunLoop] addTimer:t forMode:NSEventTrackingRunLoopMode];
		}
	}
}


- (void)				motionCallback:(NSTimer*) timer
{
	float			distance, speed, elapsedTime, length;
	BOOL			loop, shouldStop = NO;
	NSDictionary*	params = [timer userInfo];

	elapsedTime = [NSDate timeIntervalSinceReferenceDate] - [[params objectForKey:@"start_time"] floatValue];
	speed = [[params objectForKey:@"speed"] floatValue];
	
	distance = speed * elapsedTime;
	length = [[params objectForKey:@"path_length"] floatValue];
	loop = [[params objectForKey:@"loop"] boolValue];
	
	if ( !loop && distance > length )
	{
		distance = length;
		
		// reached the end of the path, so kill the timer if not looping
		
		shouldStop = YES;
	}
	else if ( loop )
		distance = fmodf( distance, length );
	
	// move the target object to the calculated point
	
	NSPoint		where;
	float		slope;
	id			obj = [params objectForKey:@"target"];

	where = [self pointOnPathAtLength:distance slope:&slope];
	shouldStop |= ![obj moveObjectTo:where position:distance slope:slope userInfo:[params objectForKey:@"userinfo"]];
	
	// if the target returns NO, it is telling us to stop immediately, whether or not we are looping
	
	if ( shouldStop )
		[timer invalidate];
}


#pragma mark -
#pragma mark - clipping utilities
- (void)				addInverseClip
{
	// this is similar to -addClip, except that it excludes the area bounded by the path instead of includes it. It works by combining this path
	// with the existing clip area using the E/O winding rule, then setting the result as the clip area. This should be called between
	// calls to save and restore the gstate, as for addClip.
	
	CGContextRef	context = [[NSGraphicsContext currentContext] graphicsPort];
	CGRect cbbox = CGContextGetClipBoundingBox( context );
	
	NSBezierPath*	cp = [NSBezierPath bezierPathWithRect:*(NSRect*)&cbbox];
	[cp appendBezierPath:self];
	[cp setWindingRule:NSEvenOddWindingRule];
	[cp setClip];
}


#pragma mark -

static void ConvertPathApplierFunction ( void* info, const CGPathElement* element )
{
	NSBezierPath* np = (NSBezierPath*) info;
	
	switch( element->type )
	{
		case kCGPathElementMoveToPoint:
			[np moveToPoint:*(NSPoint*) element->points];
			break;
		
		case kCGPathElementAddLineToPoint:
			[np lineToPoint:*(NSPoint*) element->points];
			break;
		
		case kCGPathElementAddQuadCurveToPoint:
			[np curveToPoint:*(NSPoint*) &element->points[1] controlPoint1:*(NSPoint*) &element->points[0] controlPoint2:*(NSPoint*) &element->points[0]];
			break;
		
		case kCGPathElementAddCurveToPoint:
			[np curveToPoint:*(NSPoint*) &element->points[2] controlPoint1:*(NSPoint*) &element->points[0] controlPoint2:*(NSPoint*) &element->points[1]];
			break;
			
		case kCGPathElementCloseSubpath:
			[np closePath];
			break;
			
		default:
			break;
	}
}


#pragma mark -


static void subdivideBezier(const NSPoint bez[4], NSPoint bez1[4], NSPoint bez2[4])
{
  NSPoint q;
  
  // Subdivide the B‚àö¬©zier further
  bez1[0].x = bez[0].x;
  bez1[0].y = bez[0].y;
  bez2[3].x = bez[3].x;
  bez2[3].y = bez[3].y;
  
  q.x = (bez[1].x + bez[2].x) / 2.0;
  q.y = (bez[1].y + bez[2].y) / 2.0;
  bez1[1].x = (bez[0].x + bez[1].x) / 2.0;
  bez1[1].y = (bez[0].y + bez[1].y) / 2.0;
  bez2[2].x = (bez[2].x + bez[3].x) / 2.0;
  bez2[2].y = (bez[2].y + bez[3].y) / 2.0;
  
  bez1[2].x = (bez1[1].x + q.x) / 2.0;
  bez1[2].y = (bez1[1].y + q.y) / 2.0;
  bez2[1].x = (q.x + bez2[2].x) / 2.0;
  bez2[1].y = (q.y + bez2[2].y) / 2.0;
  
  bez1[3].x = bez2[0].x = (bez1[2].x + bez2[1].x) / 2.0;
  bez1[3].y = bez2[0].y = (bez1[2].y + bez2[1].y) / 2.0;
}

// Subdivide a B‚àö¬©zier (specific division)
void subdivideBezierAtT(const NSPoint bez[4], NSPoint bez1[4], NSPoint bez2[4], float t)
{
  NSPoint q;
  float mt = 1 - t;
  
  // Subdivide the B‚àö¬©zier further
  bez1[0].x = bez[0].x;
  bez1[0].y = bez[0].y;
  bez2[3].x = bez[3].x;
  bez2[3].y = bez[3].y;
  
  q.x = mt * bez[1].x + t * bez[2].x;
  q.y = mt * bez[1].y + t * bez[2].y;
  bez1[1].x = mt * bez[0].x + t * bez[1].x;
  bez1[1].y = mt * bez[0].y + t * bez[1].y;
  bez2[2].x = mt * bez[2].x + t * bez[3].x;
  bez2[2].y = mt * bez[2].y + t * bez[3].y;
  
  bez1[2].x = mt * bez1[1].x + t * q.x;
  bez1[2].y = mt * bez1[1].y + t * q.y;
  bez2[1].x = mt * q.x + t * bez2[2].x;
  bez2[1].y = mt * q.y + t * bez2[2].y;
  
  bez1[3].x = bez2[0].x = mt * bez1[2].x + t * bez2[1].x;
  bez1[3].y = bez2[0].y = mt * bez1[2].y + t * bez2[1].y;
}

// Distance between two points
static inline float distanceBetween(NSPoint a, NSPoint b)
{
   return hypotf( a.x - b.x, a.y - b.y );
}

// Length of a B‚àö¬©zier curve
static float lengthOfBezier(const  NSPoint bez[4],
			     float acceptableError)
{
  float   polyLen = 0.0;
  float   chordLen = distanceBetween (bez[0], bez[3]);
  float   retLen, errLen;
  unsigned n;
  
  for (n = 0; n < 3; ++n)
    polyLen += distanceBetween (bez[n], bez[n + 1]);
  
  errLen = polyLen - chordLen;
  
  if (errLen > acceptableError) {
    NSPoint left[4], right[4];
    subdivideBezier (bez, left, right);
    retLen = (lengthOfBezier (left, acceptableError) 
	      + lengthOfBezier (right, acceptableError));
  } else {
    retLen = 0.5 * (polyLen + chordLen);
  }
  
  return retLen;
}

// Split a B‚àö¬©zier curve at a specific length
static float subdivideBezierAtLength (const NSPoint bez[4],
				       NSPoint bez1[4],
				       NSPoint bez2[4],
				       float length,
				       float acceptableError)
{
  float top = 1.0, bottom = 0.0;
  float t, prevT;
  
  prevT = t = 0.5;
  for (;;) {
    float len1;
    
    subdivideBezierAtT (bez, bez1, bez2, t);
    
    len1 = lengthOfBezier (bez1, 0.5 * acceptableError);
    
    if (fabs (length - len1) < acceptableError)
      return len1;
    
    if (length > len1) {
      bottom = t;
      t = 0.5 * (t + top);
    } else if (length < len1) {
      top = t;
      t = 0.5 * (bottom + t);
    }
    
    if (t == prevT)
      return len1;
    
    prevT = t;
  }
}

#pragma mark -
#pragma mark Path trimming utilities

// Find the first point in the path

- (NSPoint)			firstPoint
{
	NSPoint points[3];
	
	if ([self elementCount] > 0 )
	{
		NSBezierPathElement element = [self elementAtIndex:0 associatedPoints:points];

		if (element == NSCurveToBezierPathElement)
			return points[2];
		else
			return points[0];
	}
	else
		return NSZeroPoint;
}

- (NSPoint)			lastPoint
{
	NSPoint points[3];
	if ([self elementCount] > 0 )
	{
		NSBezierPathElement element = [self elementAtIndex:[self elementCount] - 1 associatedPoints:points];

		if ( element == NSCurveToBezierPathElement )
			return points[2];
		else
			return points[0];
	}
	else
		return NSZeroPoint;
}


#pragma mark -
// Convenience method

- (NSBezierPath *)	bezierPathByTrimmingToLength:(float)trimLength
{
	return [self bezierPathByTrimmingToLength:trimLength withMaximumError:0.1];
}


/* Return an NSBezierPath corresponding to the first trimLength units
   of this NSBezierPath. */
- (NSBezierPath *)	bezierPathByTrimmingToLength:(float)trimLength withMaximumError:(float) maxError
{
	NSBezierPath *newPath = [NSBezierPath bezierPath];
	int	       elements = [self elementCount];
	int	       n;
	float     length = 0.0;
	NSPoint    pointForClose = NSMakePoint (0.0, 0.0);
	NSPoint    lastPoint = NSMakePoint (0.0, 0.0);

	for (n = 0; n < elements; ++n)
	{
		NSPoint		points[3];
		NSBezierPathElement element = [self elementAtIndex:n associatedPoints:points];
		float		elementLength;
		float		remainingLength = trimLength - length;
    
		switch (element)
		{
			case NSMoveToBezierPathElement:
				[newPath moveToPoint:points[0]];
				pointForClose = lastPoint = points[0];
				continue;
	
			case NSLineToBezierPathElement:
				elementLength = distanceBetween (lastPoint, points[0]);
	
				if (length + elementLength <= trimLength)
					[newPath lineToPoint:points[0]];
				else
				{
					float f = remainingLength / elementLength;
					[newPath lineToPoint:NSMakePoint (lastPoint.x + f * (points[0].x - lastPoint.x), lastPoint.y + f * (points[0].y - lastPoint.y))];
					return newPath;
				}
	
				length += elementLength;
				lastPoint = points[0];
				break;
	
			case NSCurveToBezierPathElement:
			{
				NSPoint bezier[4] = { lastPoint, points[0], points[1], points[2] };
				elementLength = lengthOfBezier (bezier, maxError);
	
				if (length + elementLength <= trimLength)
					[newPath curveToPoint:points[2] controlPoint1:points[0] controlPoint2:points[1]];
				else
				{
					NSPoint bez1[4], bez2[4];
					subdivideBezierAtLength (bezier, bez1, bez2, remainingLength, maxError);
					[newPath curveToPoint:bez1[3] controlPoint1:bez1[1] controlPoint2:bez1[2]];
					return newPath;
				}
	
				length += elementLength;
				lastPoint = points[2];
				break;
			}
	
			case NSClosePathBezierPathElement:
				elementLength = distanceBetween (lastPoint, pointForClose);
	
				if (length + elementLength <= trimLength)
				{
					[newPath closePath];
				}
				else
				{
					float f = remainingLength / elementLength;
					[newPath lineToPoint:NSMakePoint (lastPoint.x + f * (pointForClose.x - lastPoint.x), lastPoint.y + f * (pointForClose.y - lastPoint.y))];
					return newPath;
				}
	
				length += elementLength;
				lastPoint = pointForClose;
				break;
				
			default:
				break;
		}
	} 
	return newPath;
}



// Convenience method
- (NSBezierPath *)	bezierPathByTrimmingFromLength:(float) trimLength
{
	return [self bezierPathByTrimmingFromLength:trimLength withMaximumError:0.1];
}


/* Return an NSBezierPath corresponding to the part *after* the first
   trimLength units of this NSBezierPath. */
- (NSBezierPath *)	bezierPathByTrimmingFromLength:(float)trimLength withMaximumError:(float)maxError
{
	NSBezierPath *newPath = [NSBezierPath bezierPath];
	int	       elements = [self elementCount];
	int	       n;
	float       length = 0.0;
	NSPoint      pointForClose = NSMakePoint (0.0, 0.0);
	NSPoint      lastPoint = NSMakePoint (0.0, 0.0);
  
	for (n = 0; n < elements; ++n)
	{
		NSPoint		points[3];
		NSBezierPathElement element = [self elementAtIndex:n associatedPoints:points];
		float		elementLength;
		float		remainingLength = trimLength - length;
    
		switch (element)
		{
			case NSMoveToBezierPathElement:
				if ( length > trimLength )
					[newPath moveToPoint:points[0]];
				pointForClose = lastPoint = points[0];
				continue;
	
			case NSLineToBezierPathElement:
				elementLength = distanceBetween (lastPoint, points[0]);
	
				if (length > trimLength)
					[newPath lineToPoint:points[0]];
				else if (length + elementLength > trimLength)
				{
					float f = remainingLength / elementLength;
					[newPath moveToPoint:NSMakePoint (lastPoint.x + f * (points[0].x - lastPoint.x), lastPoint.y + f * (points[0].y - lastPoint.y))];
					[newPath lineToPoint:points[0]];
				}
	  
				length += elementLength;
				lastPoint = points[0];
				break;
	
			case NSCurveToBezierPathElement:
			{
				NSPoint bezier[4] = { lastPoint, points[0], points[1], points[2] };
				elementLength = lengthOfBezier (bezier, maxError);
	
				if (length > trimLength)
					[newPath curveToPoint:points[2] controlPoint1:points[0] controlPoint2:points[1]];
				else if (length + elementLength > trimLength)
				{
					NSPoint bez1[4], bez2[4];
					subdivideBezierAtLength (bezier, bez1, bez2, remainingLength, maxError);
					[newPath moveToPoint:bez2[0]];
					[newPath curveToPoint:bez2[3] controlPoint1:bez2[1] controlPoint2:bez2[2]];
				}
	
				length += elementLength;
				lastPoint = points[2];
				break;
			}
	
			case NSClosePathBezierPathElement:
				elementLength = distanceBetween (lastPoint, pointForClose);
	
				if (length > trimLength)
				{
					[newPath lineToPoint:pointForClose];
					[newPath closePath];
				}
				else if (length + elementLength > trimLength)
				{
					float f = remainingLength / elementLength;
					[newPath moveToPoint:NSMakePoint (lastPoint.x + f * (points[0].x - lastPoint.x), lastPoint.y + f * (points[0].y - lastPoint.y))];
					[newPath lineToPoint:points[0]];
				}
	  
				length += elementLength;
				lastPoint = pointForClose;
				break;
				
			default:
				break;
		}
	} 
	return newPath;
}



- (NSBezierPath*)		bezierPathByTrimmingFromBothEnds:(float) trimLength
{
	return [self bezierPathByTrimmingFromBothEnds:trimLength withMaximumError:0.1];
}


- (NSBezierPath *)		bezierPathByTrimmingFromBothEnds:(float) trimLength withMaximumError:(float) maxError
{
	// trims <trimLength> from both ends of the path, returning the shortened centre section
	
	float rlen = [self length] - trimLength;
	
	NSBezierPath* p1 = [self bezierPathByTrimmingToLength:rlen withMaximumError:maxError];
	
	p1 = [p1 bezierPathByReversingPath];
	
	return [p1 bezierPathByTrimmingToLength:rlen - trimLength withMaximumError:maxError];
}


- (NSBezierPath*)		bezierPathByTrimmingFromCentre:(float) trimLength
{
	return [self bezierPathByTrimmingFromCentre:trimLength withMaximumError:0.1];
}


- (NSBezierPath*)		bezierPathByTrimmingFromCentre:(float) trimLength withMaximumError:(float) maxError
{
	// removes a section <trimLength> long from the centre of the path. The returned path thus consists of two
	// subpaths with a gap between them.
	
	float centre = [self length] * 0.5f;
	
	NSBezierPath* temp1 = [self bezierPathByTrimmingToLength:centre - (trimLength * 0.5f) withMaximumError:maxError];
	NSBezierPath* temp2 = [self bezierPathByTrimmingFromLength:centre + (trimLength * 0.5f) withMaximumError:maxError];
	
	[temp1 appendBezierPath:temp2];
	
	return temp1;
}



#pragma mark -
#pragma mark Arrow head utilities

// Create an NSBezierPath containing an arrowhead for the start of this path


- (NSBezierPath *)	bezierPathWithArrowHeadForStartOfLength:(float) length angle:(float) angle closingPath:(BOOL) closeit
{
	NSBezierPath *rightSide = [self bezierPathByTrimmingToLength:length];
	NSBezierPath *leftSide = [rightSide bezierPathByReversingPath];
	NSAffineTransform *rightTransform = [NSAffineTransform transform];
	NSAffineTransform *leftTransform = [NSAffineTransform transform];
	NSPoint firstPoint = [self firstPoint];
	//NSPoint fp2 = [self firstPoint2:length / 2.0];
	// Rotate about the point of the arrowhead
	[rightTransform translateXBy:firstPoint.x yBy:firstPoint.y];
	[rightTransform rotateByDegrees:angle];
	[rightTransform translateXBy:-firstPoint.x yBy:-firstPoint.y];
  
	[rightSide transformUsingAffineTransform:rightTransform];
  
	// Same again, but for the left hand side of the arrowhead
	[leftTransform translateXBy:firstPoint.x yBy:firstPoint.y];
	[leftTransform rotateByDegrees:-angle];
	[leftTransform translateXBy:-firstPoint.x yBy:-firstPoint.y];
  
	[leftSide transformUsingAffineTransform:leftTransform];
  
	/* Careful!  We don't want to append the -moveToPoint from the right hand
     side, because then -closePath won't do what we would want it to. */
	[leftSide appendBezierPathRemovingInitialMoveToPoint:rightSide];
	
	if ( closeit )
		[leftSide closePath];
  
	return leftSide;
}

// Convenience function for obtaining arrow for the other end
- (NSBezierPath *)	bezierPathWithArrowHeadForEndOfLength:(float) length  angle:(float) angle closingPath:(BOOL) closeit
{
	return [[self bezierPathByReversingPath] bezierPathWithArrowHeadForStartOfLength:length angle:angle closingPath:closeit];
}


#pragma mark -
/* Append a Bezier path, but if it starts with a -moveToPoint, then remove
   it.  This is useful when manipulating trimmed path segments. */

- (void)			appendBezierPathRemovingInitialMoveToPoint:(NSBezierPath*) path
{
	int	       elements = [path elementCount];
	int	       n;
  
	for (n = 0; n < elements; ++n)
	{
		NSPoint		points[3];
		NSBezierPathElement element = [path elementAtIndex:n associatedPoints:points];

		switch (element)
		{
			case NSMoveToBezierPathElement:
			{
				if (n != 0)
					[self moveToPoint:points[0]];
				break;
			}
	
			case NSLineToBezierPathElement:
				[self lineToPoint:points[0]];
			break;
	
			case NSCurveToBezierPathElement:
				[self curveToPoint:points[2] controlPoint1:points[0] controlPoint2:points[1]];
			break;
	
			case NSClosePathBezierPathElement:
				[self closePath];
				
			default:
				break;
		}
	}
}


#pragma mark -
// Convenience method

- (float)			length
{
	return [self lengthWithMaximumError:0.1];
}

// Estimate the total length of a B‚àö¬©zier path

- (float)			lengthWithMaximumError:(float) maxError
{
  int     elements = [self elementCount];
  int     n;
  float  length = 0.0;
  NSPoint pointForClose = NSMakePoint (0.0, 0.0);
  NSPoint lastPoint = NSMakePoint (0.0, 0.0);
  
  for (n = 0; n < elements; ++n)
  {
		NSPoint		points[3];
		NSBezierPathElement element = [self elementAtIndex:n associatedPoints:points];
    
		switch (element)
		{
			case NSMoveToBezierPathElement:
				pointForClose = lastPoint = points[0];
				break;
	
			case NSLineToBezierPathElement:
				length += distanceBetween (lastPoint, points[0]);
				lastPoint = points[0];
				break;
	
			case NSCurveToBezierPathElement:
			{
				NSPoint bezier[4] = { lastPoint, points[0], points[1], points[2] };
				length += lengthOfBezier (bezier, maxError);
				lastPoint = points[2];
				break;
			}
	
			case NSClosePathBezierPathElement:
				length += distanceBetween (lastPoint, pointForClose);
				lastPoint = pointForClose;
				break;
				
			default:
				break;
		}
  }
  
  return length;
}


@end


