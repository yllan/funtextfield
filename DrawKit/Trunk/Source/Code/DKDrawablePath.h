//
//  DKDrawablePath.h
//  DrawingArchitecture
//
//  Created by graham on 10/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "DKDrawableObject.h"


@class DKDrawableShape;
@class DKKnob;


@interface DKDrawablePath : DKDrawableObject <NSCoding, NSCopying>
{
	NSBezierPath*			m_path;
	int						m_editPathMode;
	float					m_freehandEpsilon;
}


+ (DKDrawablePath*)		drawablePathWithPath:(NSBezierPath*) path;
+ (DKDrawablePath*)		drawablePathWithPath:(NSBezierPath*) path withStyle:(DKStyle*) aStyle;

+ (void)				setInfoWindowBackgroundColour:(NSColor*) colour;

- (id)					initWithBezierPath:(NSBezierPath*) aPath;

- (void)				setPath:(NSBezierPath*) path;
- (NSBezierPath*)		path;
- (void)				drawControlPointsOfPath:(NSBezierPath*) path usingKnobs:(DKKnob*) knobs;

- (void)				combine:(DKDrawablePath*) anotherPath;
- (BOOL)				join:(DKDrawablePath*) anotherPath tolerance:(float) tol makeColinear:(BOOL) colin;
- (NSArray*)			breakApart;

- (void)				setPathEditingMode:(int) editPathMode;
- (int)					pathEditingMode;

- (void)				pathCreateLoop:(NSPoint) initialPoint;
- (void)				lineCreateLoop:(NSPoint) initialPoint;
- (void)				polyCreateLoop:(NSPoint) initialPoint;
- (void)				freehandCreateLoop:(NSPoint) initialPoint;
- (void)				arcCreateLoop:(NSPoint) initialPoint;

- (BOOL)				shouldEndPathCreationWithEvent:(NSEvent*) event;

- (BOOL)				pathDeletePointWithPartCode:(int) pc;
- (int)					pathInsertPointAt:(NSPoint) loc ofType:(int) pathPointType;

- (void)				setFreehandSmoothing:(float) fs;
- (float)				freehandSmoothing;

- (DKDrawableShape*)	makeShape;

// user level commands this object can respond to:

- (IBAction)			convertToShape:(id) sender;
- (IBAction)			addRandomNoise:(id) sender;
- (IBAction)			convertToOutline:(id) sender;
- (IBAction)			breakApart:(id) sender;
- (IBAction)			roughenPath:(id) sender;
#ifdef qUseCurveFit
- (IBAction)			smoothPath:(id) sender;
- (IBAction)			smoothPathMore:(id) sender;
#endif
- (IBAction)			parallelCopy:(id) sender;

- (IBAction)			toggleHorizontalFlip:(id) sender;
- (IBAction)			toggleVerticalFlip:(id) sender;

@end

// special partcode value used to mean snap to the nearest point on the path itself:

enum
{
	kGCSnapToNearestPathPointPartcode	= -99
};


// editing modes:

enum
{
	kGCPathCreateModeEditExisting		= 0,		// normal operation - just move points on the existing path
	kGCPathCreateModeLineCreate			= 1,		// create a straight line between two points
	kGCPathCreateModeBezierCreate		= 2,		// create a curved path point by point
	kGCPathCreateModePolygonCreate		= 3,		// create an irreglar polygon pont by point (multiple lines)
	kGCPathCreateModeFreehandCreate		= 4,		// create a curve path by dragging freehand
	kGCPathCreateModeArcSegment			= 5,		// create an arc section
	kGCPathCreateModeWedgeSegment		= 6			// create a wedge section
};

// path point types that can be passed to pathInsertPointAt:ofType:

enum
{
	kGCPathPointTypeAuto				= 0,		// insert whatever the hit element is already using
	kGCPathPointTypeLine				= 1,		// insert a line segment
	kGCPathPointTypeCurve				= 2,		// insert a curve segment
	kGCPathPointTypeInverseAuto			= 3,		// insert the opposite of whatever hit element is already using
};

/*

DKDrawablePath is a drawable object that renders a path such as a line or curve (bezigon). Unlike DKDrawableShape, the path doesn't
usually have a fill (though a track-type style provides a different type/definition of a fill for this type of object).

The path is rendered at its stored size, not transformed to its final size like DKDrawableShape. Thus this type of object doesn't
maintain the concept of rotation or scale - it just is what it is.

This object uses an offscreen bitmap to detect hits.

*/
