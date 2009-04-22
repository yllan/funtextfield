///**********************************************************************************************************************************
///  DKGeometryUtilities.h
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

#import <Cocoa/Cocoa.h>

#ifdef __cplusplus
extern "C"
{
#endif


NSRect				NSRectFromTwoPoints( const NSPoint a, const NSPoint b );
NSRect				UnionOfTwoRects( const NSRect a, const NSRect b );
NSSet*				DifferenceOfTwoRects( const NSRect a, const NSRect b );
NSSet*				SubtractTwoRects( const NSRect a, const NSRect b );

float				PointFromLine( const NSPoint inPoint, const NSPoint a, const NSPoint b );
NSPoint				NearestPointOnLine( const NSPoint inPoint, const NSPoint a, const NSPoint b );
float				RelPoint( const NSPoint inPoint, const NSPoint a, const NSPoint b );

NSPoint				BisectLine( const NSPoint a, const NSPoint b );
NSPoint				Interpolate( const NSPoint a, const NSPoint b, const float proportion);
float				LineLength( const NSPoint a, const NSPoint b );

float				SquaredLength( const NSPoint p );
NSPoint				DiffPoint( const NSPoint a, const NSPoint b );
float				DiffPointSquaredLength( const NSPoint a, const NSPoint b );
NSPoint				SumPoint( const NSPoint a, const NSPoint b );

NSPoint				EndPoint( NSPoint origin, float angle, float length );
float				Slope( const NSPoint a, const NSPoint b );
float				AngleBetween( const NSPoint a, const NSPoint b, const NSPoint c );
float				DotProduct( const NSPoint a, const NSPoint b );
NSPoint				Intersection( const NSPoint aa, const NSPoint ab, const NSPoint ba, const NSPoint bb );
NSPoint				Intersection2( const NSPoint p1, const NSPoint p2, const NSPoint p3, const NSPoint p4 );

NSRect				CentreRectOnPoint( const NSRect inRect, const NSPoint p );
NSPoint				MapPointFromRect( const NSPoint p, const NSRect rect );
NSPoint				MapPointToRect( const NSPoint p, const NSRect rect );
NSPoint				MapPointFromRectToRect( const NSPoint p, const NSRect srcRect, const NSRect destRect );
NSRect				MapRectFromRectToRect( const NSRect inRect, const NSRect srcRect, const NSRect destRect );

NSRect				ScaledRectForSize( const NSSize inSize, NSRect const fitRect );
NSRect				CentreRectInRect(const NSRect r, const NSRect cr );

NSRect				NormalizedRect( const NSRect r );
NSAffineTransform*	RotationTransform( const float radians, const NSPoint aboutPoint );

//NSPoint			PerspectiveMap( NSPoint inPoint, NSSize sourceSize, NSPoint quad[4]);

NSPoint				NearestPointOnCurve( const NSPoint inp, const NSPoint bez[4], double* tValue );
NSPoint				Bezier( const NSPoint* v, const int degree, const double t, NSPoint* Left, NSPoint* Right );

float				BezierSlope( const NSPoint bez[4], const float t );


#ifdef __cplusplus
}
#endif

