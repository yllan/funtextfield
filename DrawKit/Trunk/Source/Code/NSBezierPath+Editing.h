///**********************************************************************************************************************************
///  NSBezierPath-Editing.h
///  DrawKit
///
///  Created by graham on 08/10/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>


@interface NSBezierPath (DKEditing)

+ (void)				setConstraintAngle:(float) radians;
+ (NSPoint)				colinearPointForPoint:(NSPoint) p centrePoint:(NSPoint) q;
+ (NSPoint)				colinearPointForPoint:(NSPoint) p centrePoint:(NSPoint) q radius:(float) r;
+ (int)					point:(NSPoint) p inNSPointArray:(NSPoint*) array count:(int) count tolerance:(float) t;
+ (void)				colineariseVertex:(NSPoint[3]) inPoints cpA:(NSPoint*) outCPA cpB:(NSPoint*) outCPB;

- (NSBezierPath*)		bezierPathByRemovingTrailingElements:(int) numToRemove;
- (NSBezierPath*)		bezierPathByStrippingRedundantElements;

- (BOOL)				isPathClosed;

- (BOOL)				subpathContainingElementIsClosed:(int) element;
- (int)					subpathStartingElementForElement:(int) element;
- (int)					subpathEndingElementForElement:(int) element;

- (NSBezierPathElement)	elementTypeForPartcode:(int) pc;

- (void)				setControlPoint:(NSPoint) p forPartcode:(int) pc;
- (NSPoint)				controlPointForPartcode:(int) pc;

- (int)					partcodeHitByPoint:(NSPoint) p tolerance:(float) t;
- (int)					partcodeHitByPoint:(NSPoint) p tolerance:(float) t startingFromElement:(int) startElement;

- (void)				moveControlPointPartcode:(int) pc toPoint:(NSPoint) p colinear:(BOOL) colin coradial:(BOOL) corad constrainAngle:(BOOL) acon;

// adding and deleting points from a path:
// note that all of these methods return a new path since NSBezierPath doesn't support deletion/insertion except by reconstructing a path.

- (NSBezierPath*)		deleteControlPointForPartcode:(int) pc;
- (NSBezierPath*)		insertControlPointAtPoint:(NSPoint) p tolerance:(float) tol type:(int) controlPointType;

- (NSPoint)				nearestPointToPoint:(NSPoint) p tolerance:(float) tol;

// geometry utilities:

- (float)				tangentAtStartOfSubpath:(int) elementIndex;
- (float)				tangentAtEndOfSubpath:(int) elementIndex;

- (int)					elementHitByPoint:(NSPoint) p tolerance:(float) tol tValue:(float*) t;
- (int)					elementHitByPoint:(NSPoint) p tolerance:(float) tol tValue:(float*) t nearestPoint:(NSPoint*) npp;
- (int)					elementBoundsContainsPoint:(NSPoint) p tolerance:(float) tol;

// element bounding boxes - can reduce need to draw entire path when only a part is edited

- (NSRect)				boundingBoxForElement:(int) elementIndex;
- (void)				drawElementsBoundingBoxes;
- (NSSet*)				boundingBoxesForPartcode:(int) pc;
- (NSSet*)				allBoundingBoxes;


@end

// simple partcode cracking utils:

int						partcodeForElement( const int element );
int						partcodeForElementControlPoint( const int element, const int controlPointIndex );
int						arrayIndexForPartcode( const int pc );
int						elementIndexForPartcode( const int pc );


/*

This category provides some basic methods for supporting interactive editing of a NSBezierPath object. This can be more tricky
than it looks because control points are often not edited in isolation - they often crosslink to other control points (such as
when two curveto segments are joined and a colinear handle is needed).

These methods allow you to refer to any individual control point in the object using a unique partcode. These methods will
hit detect all control points, giving the partcode, and then get and set that point.

The moveControlPointPartcode:toPoint:colinear: is a high-level call that will handle most editing tasks in a simple to use way. It
optionally maintains colinearity across curve joins, and knows how to maintain closed loops properly.

*/

