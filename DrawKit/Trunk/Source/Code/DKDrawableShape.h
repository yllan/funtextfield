///**********************************************************************************************************************************
///  DKDrawableShape.h
///  DrawKit
///
///  Created by graham on 13/08/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKDrawableObject.h"


@class DKDrawablePath, DKDistortionTransform, DKGridLayer;

// edit operation constants tell the shape what info to display in the floater

typedef enum
{
	kDKShapeOperationResize		= 0,
	kDKShapeOperationMove		= 1,
	kDKShapeOperationRotate		= 2
}
DKShapeEditOperation;



@interface DKDrawableShape : DKDrawableObject <NSCoding, NSCopying>
{
	NSBezierPath*			m_path;					// shape's path stored in canonical form (origin centred and with unit size)
	NSMutableArray*			m_customHotSpots;		// list of attached custom hotspots (if any)
	DKDistortionTransform*	m_distortTransform;		// distortion transform for distort operations
	float					m_rotationAngle;		// angle of rotation of the shape
	NSPoint					m_location;				// where in the drawing it is placed
	NSSize					m_scale;				// object size/scale
	NSSize					m_offset;				// offset from origin of logical centre relative to canonical path
	NSSize					m_savedOffset;			// used when temporarily moving the origin for sizing operations
	BOOL					m_inRotateOp;			// YES while a rotation drag is in progress
	BOOL					m_hideOriginTarget;		// YES to hide temporarily the origin target - done for some mouse operations
	int						m_opMode;				// drag operation mode - normal versus distortion modes
	int						m_dragPart;				// partcode being dragged
}

+ (int)						knobMask;
+ (void)					setAngularConstraintAngle:(float) radians;
+ (NSRect)					unitRectAtOrigin;
+ (void)					setInfoWindowBackgroundColour:(NSColor*) colour;
+ (NSCursor*)				cursorForShapePartcode:(int) pc;

// convenient ways to create shapes for a path you have:

+ (DKDrawableShape*)		drawableShapeWithRect:(NSRect) aRect;
+ (DKDrawableShape*)		drawableShapeWithOvalInRect:(NSRect) aRect;
+ (DKDrawableShape*)		drawableShapeWithCanonicalPath:(NSBezierPath*) path;
+ (DKDrawableShape*)		drawableShapeWithPath:(NSBezierPath*) path;
+ (DKDrawableShape*)		drawableShapeWithPath:(NSBezierPath*) path rotatedToAngle:(float) angle;
+ (DKDrawableShape*)		drawableShapeWithPath:(NSBezierPath*) path withStyle:(DKStyle*) aStyle;
+ (DKDrawableShape*)		drawableShapeWithPath:(NSBezierPath*) path rotatedToAngle:(float) angle withStyle:(DKStyle*) aStyle;

// initialise a shape for a rect or oval or different kinds of path:

- (id)						initWithRect:(NSRect) aRect;
- (id)						initWithOvalInRect:(NSRect) aRect;
- (id)						initWithCanonicalBezierPath:(NSBezierPath*) aPath;
- (id)						initWithBezierPath:(NSBezierPath*) aPath;
- (id)						initWithBezierPath:(NSBezierPath*) aPath rotatedToAngle:(float) angle;

// path operations:

- (void)					setPath:(NSBezierPath*) path;
- (NSBezierPath*)			path;
- (void)					reshapePath;
- (void)					adoptPath:(NSBezierPath*) path;

- (NSBezierPath*)			transformedPath;

// geometry:

- (NSAffineTransform*)		transform;
- (NSAffineTransform*)		transformIncludingParent;
- (NSAffineTransform*)		inverseTransform;
- (NSPoint)					locationIgnoringOffset;

- (void)					rotateByAngle:(float) da;
- (void)					rotateUsingReferencePoint:(NSPoint) rp constrain:(BOOL) constrain;
- (void)					moveKnob:(int) knobPartCode toPoint:(NSPoint) p allowRotate:(BOOL) rotate constrain:(BOOL) constrain;

- (void)					setOffset:(NSSize) offs;
- (NSSize)					offset;
- (void)					resetOffset;

- (void)					flipHorizontally;
- (void)					flipVertically;

- (void)					resetBoundingBox;
- (void)					resetBoundingBoxAndRotation;
- (void)					adjustToFitGrid:(DKGridLayer*) grid;

- (BOOL)					allowSizeKnobsToRotateShape;
- (NSRect)					knobRect:(int) knobPartCode;
- (NSPoint)					convertPointFromRelativeLocation:(NSPoint) rloc;

// private:

- (NSRect)					knobBounds;
- (int)						partcodeOppositeKnob:(int) knobPartCode;
- (void)					setDragAnchorToPart:(int) knobPartCode;
- (float)					knobAngleFromOrigin:(int) knobPartCode;
- (void)					drawKnob:(int) knobPartCode;

- (NSPoint)					canonicalCornerPoint:(int) knobPartCode;
- (NSPoint)					knobPoint:(int) knobPartCode;

- (NSString*)				undoActionNameForPartCode:(int) pc;
- (void)					moveDistortionKnob:(int) partCode toPoint:(NSPoint) p;
- (void)					drawDistortionEnvelope;

- (void)					prepareRotation;
- (NSPoint)					rotationKnobPoint;

- (void)					updateInfoForOperation:(DKShapeEditOperation) op atPoint:(NSPoint) mp;

// operation modes:

- (void)					setOperationMode:(int) mode;
- (int)						operationMode;

// distortion ops:

- (void)					setDistortionTransform:(DKDistortionTransform*) dt;
- (DKDistortionTransform*)	distortionTransform;

// convert to editable path:

- (DKDrawablePath*)			makePath;

// user actions:

- (IBAction)				convertToPath:(id) sender;
- (IBAction)				unrotate:(id) sender;
- (IBAction)				rotate:(id) sender;
- (IBAction)				setDistortMode:(id) sender;
- (IBAction)				resetBoundingBox:(id) sender;
- (IBAction)				toggleHorizontalFlip:(id) sender;
- (IBAction)				toggleVerticalFlip:(id) sender;
- (IBAction)				pastePath:(id) sender;

- (BOOL)					canPastePathWithPasteboard:(NSPasteboard*) pb;

@end


// part codes:

// since part codes are private to each drawable class (except 0 meaning no part), these are arranged partially as
// bit values, so they can be added together to indicate corner positions. Don't change these numbers as this
// is taken advantage of internally to simplify the handling of the part codes.

enum
{
	kGCDrawableShapeLeftHandle			= ( 1 << 0 ),
	kGCDrawableShapeTopHandle			= ( 1 << 1 ),
	kGCDrawableShapeRightHandle			= ( 1 << 2 ),
	kGCDrawableShapeBottomHandle		= ( 1 << 3 ),
	kGCDrawableShapeTopLeftHandle		= ( 1 << 4 ),
	kGCDrawableShapeTopRightHandle		= ( 1 << 5 ),
	kGCDrawableShapeBottomLeftHandle	= ( 1 << 6 ),
	kGCDrawableShapeBottomRightHandle	= ( 1 << 7 ),
	kGCDrawableShapeObjectCentre		= ( 1 << 8 ),
	kGCDrawableShapeOriginTarget		= ( 1 << 9 ),
	kGCDrawableShapeRotationHandle		= ( 1 << 10 ),
	kGCDrawableShapeTopLeftDistort		= ( 1 << 11 ),
	kGCDrawableShapeTopRightDistort		= ( 1 << 12 ),
	kGCDrawableShapeBottomRightDistort	= ( 1 << 13 ),
	kGCDrawableShapeBottomLeftDistort	= ( 1 << 14 ),
	kGCDrawableShapeSnapToPathEdge		= -98,
};

// knob masks:

enum
{
	kGCDrawableShapeAllKnobs			= 0xFFFFFFFF,
	kGCDrawableShapeAllSizeKnobs		= kGCDrawableShapeAllKnobs &~ ( kGCDrawableShapeRotationHandle |
																		kGCDrawableShapeOriginTarget |
																		kGCDrawableShapeObjectCentre ),
	kGCDrawableShapeHorizontalSizingKnobs	= (kGCDrawableShapeLeftHandle | kGCDrawableShapeRightHandle |
												kGCDrawableShapeTopLeftHandle | kGCDrawableShapeTopRightHandle |
												kGCDrawableShapeBottomLeftHandle | kGCDrawableShapeBottomRightHandle),
	kGCDrawableShapeVerticalSizingKnobs		= (kGCDrawableShapeTopHandle | kGCDrawableShapeBottomHandle |
											kGCDrawableShapeTopLeftHandle | kGCDrawableShapeTopRightHandle |
											kGCDrawableShapeBottomLeftHandle | kGCDrawableShapeBottomRightHandle),
	kGCDrawableShapeAllLeftHandles			= (kGCDrawableShapeLeftHandle | kGCDrawableShapeTopLeftHandle | kGCDrawableShapeBottomLeftHandle),
	kGCDrawableShapeAllRightHandles			= (kGCDrawableShapeRightHandle | kGCDrawableShapeTopRightHandle | kGCDrawableShapeBottomRightHandle),
	kGCDrawableShapeAllTopHandles			= (kGCDrawableShapeTopHandle | kGCDrawableShapeTopLeftHandle | kGCDrawableShapeTopRightHandle),
	kGCDrawableShapeAllBottomHandles		= (kGCDrawableShapeBottomHandle | kGCDrawableShapeBottomLeftHandle | kGCDrawableShapeBottomRightHandle),
	kGCDrawableShapeAllCornerHandles		= (kGCDrawableShapeTopLeftHandle | kGCDrawableShapeTopRightHandle |
											kGCDrawableShapeBottomLeftHandle | kGCDrawableShapeBottomRightHandle),
	kGCDrawableShapeNWSECorners				= (kGCDrawableShapeTopLeftHandle | kGCDrawableShapeBottomRightHandle),
	kGCDrawableShapeNESWCorners				= (kGCDrawableShapeBottomLeftHandle | kGCDrawableShapeTopRightHandle),
	kGCDrawableShapeEWHandles				= (kGCDrawableShapeLeftHandle | kGCDrawableShapeRightHandle),
	kGCDrawableShapeNSHandles				= (kGCDrawableShapeTopHandle | kGCDrawableShapeBottomHandle)
};


// operation modes:

enum
{
	kGCShapeTransformStandard			= 0,		// normal resize/rotate transforms
	kGCShapeTransformFreeDistort		= 1,		// free distort transform
	kGCShapeTransformHorizontalShear	= 2,		// shear horizontally
	kGCShapeTransformVerticalShear		= 3,		// shear vertically
	kGCShapeTransformPerspective		= 4			// perspective
};
	

/*

DKDrawableShape is a semi-abstract base class for a drawable object consisting of any path-based shape that can be drawn to fit a
rectangle. DKShapeFactory can be used to supply lots of different path shapes usable with this class.

This implements rotation of the shape about a specified point (defaulting to the centre), and also standard selection handles.

Resizing and moving of the shape is handled by its implementations of the mouseDown/dragged/up event handlers.

This class uses the handle drawing supplied by DKKnob.

The path is stored internally in its untransformed form. This means that its datum is at the origin and it is unrotated. When rendered, the
object's location and rotation angle are applied so what you see is what you expect. The bounds naturally refers to the transformed
bounds. The selection handles themselves are also transformed by the same transform, since the shape remains editable at any orientation.

The canonical path is set to have a bounding rect 1.0 on each side. The actual size of the object is factored into the transform to
render the object in the drawing. Thus the original path is NEVER changed once established. This allows us to share basic shapes which
can be generated by a factory class.


*/


