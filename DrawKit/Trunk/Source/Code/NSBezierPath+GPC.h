///**********************************************************************************************************************************
///  NSBezierPath+GPC.h
///  DrawKit
///
///  Created by graham on 31/10/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#ifdef qUseGPC

#import <Cocoa/Cocoa.h>
#import "gpc.h"


// path simplifying constants - auto will not simplify when both source paths consist only of line segments

typedef enum
{
	kGCPathUnflattenNever	= 0,
	kGCPathUnflattenAlways	= 1,
	kGCPathUnflattenAuto	= 2
}
DKPathUnflatteningPolicy;


@interface NSBezierPath (GPC)


+ (NSBezierPath*)			 bezierPathWithGPCPolygon:(gpc_polygon*) poly;
+ (void)					 setPathUnflatteningPolicy:(DKPathUnflatteningPolicy) sp;
+ (DKPathUnflatteningPolicy) pathUnflatteningPolicy;

- (gpc_polygon*)		gpcPolygon;
- (gpc_polygon*)		gpcPolygonWithFlatness:(float) flatness;

- (int)					subPathCountStartingAtElement:(int) se;
- (void)				getPathMoveToCount:(int*) mtc lineToCount:(int*) ltc curveToCount:(int*) ctc closePathCount:(int*) cpc;

- (BOOL)				intersectsPath:(NSBezierPath*) path;
- (NSBezierPath*)		pathFromPath:(NSBezierPath*) otherPath usingBooleanOperation:(gpc_op) op;
- (NSBezierPath*)		pathFromPath:(NSBezierPath*) otherPath usingBooleanOperation:(gpc_op) op unflattenResult:(BOOL) uf;


// boolean ops on bezier paths yay!

- (NSBezierPath*)		pathFromUnionWithPath:(NSBezierPath*) otherPath;
- (NSBezierPath*)		pathFromIntersectionWithPath:(NSBezierPath*) otherPath;
- (NSBezierPath*)		pathFromDifferenceWithPath:(NSBezierPath*) otherPath;
- (NSBezierPath*)		pathFromExclusiveOrWithPath:(NSBezierPath*) otherPath;

// unflatten a poly-based path using curve fitting

- (NSBezierPath*)		bezierPathByUnflatteningPath;


@end





#define		kGCCurveFittingErrorValue		1E-4

/*

This category on NSBezierPath converts to and from the gpc_polygon data structure used by
the wonderful gpc (general polygon clipping) lib. This lib is used to perform boolean ops on paths.

Note that at present paths are flattened into polygons and so curve control points, etc are not preserved.

The curve-fitting is accomplished using 3rd party code from Lib2Geom, which is in turn a C++ implementation
of the classic Graphics Gems code. Curve-fitting is controlled by the "simplifying policy" that you set. By
default it's set to 'auto', meaning that if either of the original paths contains curves, curve fitting will
be done on the result, but if both source paths only have line segments, it won't be. This preserves sharp-cornered
shapes such as rects, etc.

For simplifying a path at any other time, you must pass a flattened path. Simplifying really means "unflattening".

*/

#endif /* defined (qUseGPC) */
