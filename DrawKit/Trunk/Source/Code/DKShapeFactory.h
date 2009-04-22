//
//  DKShapeFactory.h
//  DrawingArchitecture
//
//  Created by graham on 20/08/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DKShapeFactory : NSObject <NSCoding>

+ (DKShapeFactory*)	sharedShapeFactory;

+ (NSRect)			rectOfUnitSize;

+ (NSBezierPath*)	rect;
+ (NSBezierPath*)	oval;
+ (NSBezierPath*)	roundRect;
+ (NSBezierPath*)	roundRectWithCornerRadius:(float) radius;
+ (NSBezierPath*)	roundRectInRect:(NSRect) rect andCornerRadius:(float) radius;

+ (NSBezierPath*)	regularPolygon:(int) numberOfSides;

+ (NSBezierPath*)	equilateralTriangle;
+ (NSBezierPath*)	rightTriangle;

+ (NSBezierPath*)	pentagon;
+ (NSBezierPath*)	hexagon;
+ (NSBezierPath*)	heptagon;
+ (NSBezierPath*)	octagon;

+ (NSBezierPath*)	star:(int) numberOfPoints innerDiameter:(float) diam;
+ (NSBezierPath*)	regularStar:(int) numberOfPoints;

+ (NSBezierPath*)	ring:(float) innerDiameter;

+ (NSBezierPath*)	roundRectSpeechBalloon:(int) sbParams cornerRadius:(float) cr;
+ (NSBezierPath*)	roundRectSpeechBalloonInRect:(NSRect) rect params:(int) sbParams cornerRadius:(float) cr;
+ (NSBezierPath*)	ovalSpeechBalloon:(int) sbParams;

+ (NSBezierPath*)	arrowhead;
+ (NSBezierPath*)	arrowTailFeather;
+ (NSBezierPath*)	arrowTailFeatherWithRake:(float) rakeFactor;
+ (NSBezierPath*)	inflectedArrowhead;

+ (NSBezierPath*)	roundEndedRect:(NSRect) rect;

+ (NSBezierPath*)	pathFromGlyph:(NSString*) glyph inFontWithName:(NSString*) fontName;

- (NSBezierPath*)	roundRectInRect:(NSRect) bounds objParam:(id) param;
- (NSBezierPath*)	roundEndedRect:(NSRect) rect objParam:(id) param;
- (NSBezierPath*)	speechBalloonInRect:(NSRect) rect objParam:(id) param;

@end


// params for speech balloon shapes:

enum
{
	kGCSpeechBalloonPointsLeft		= 0,
	kGCSpeechBalloonPointsRight		= 1,
	kGCSpeechBalloonPointsDown		= 0,
	kGCSpeechBalloonPointsUp		= 1,
	kGCSpeechBalloonLeftEdge		= 2,
	kGCSpeechBalloonRightEdge		= 4,
	kGCSpeechBalloonTopEdge			= 6,
	kGCSpeechBalloonBottomEdge		= 8,
	kGCStandardSpeechBalloon		= kGCSpeechBalloonTopEdge | kGCSpeechBalloonPointsLeft,
	kGCSpeechBalloonEdgeMask		= 0x0E
};

// param keys for dictionary passed to provider methods:

extern NSString*	kGCSpeechBalloonType;
extern NSString*	kGCSpeechBalloonCornerRadius;

/*

This class provides a number of standard shareable paths that can be utilsed by DKDrawableShape. These are all
bounded by the standard unit square 1.0 on each side and centered at the origin. The DKDrawableShape class
provides rotation, scaling and offset for each shape that it draws.

Note that for efficiency many of the path objects returned here are shared. That means that if you change a shape
with the path editor you MUST copy it first.

The other job of this class is to provide shapes for reshapable shapes on demand. In that case, an instance of
the shape factory is used (usually sharedShapeFactory) and the instance methods which conform to the reshapable informal
protocol are used as shape providers. See DKReshapableShape for more details.

*/

