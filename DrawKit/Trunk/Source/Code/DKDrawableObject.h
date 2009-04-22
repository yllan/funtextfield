///**********************************************************************************************************************************
///  DKDrawableObject.h
///  DrawKit
///
///  Created by graham on 11/08/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>
#import "DKCommonTypes.h"


@class DKObjectOwnerLayer, DKStyle, DKDrawing, DKDrawingTool;



@interface DKDrawableObject : NSObject <NSCoding, NSCopying>
{
	id					mContainerRef;			// the immediate container of this object (layer, group or another drawable)
	DKStyle*			m_style;				// the drawing style attached
	id					m_userInfo;				// attached user info (can be anything)
	NSSize				m_mouseOffset;			// used to track where mouse was relative to bounds
	BOOL				m_inMouseOp;			// YES while a mouse operation (drag) is in progress
	BOOL				m_mouseEverMoved;		// used to set up undo for mouse operations
	BOOL				m_visible;				// YES if visible
	BOOL				m_locked;				// YES if locked
	BOOL				m_snapEnable;			// YES if mouse actions snap to grid/guides
	NSRect				m_bounds;				// bounds rectangle (subclasses may use this to cache bounds if required)
	BOOL				m_showBBox:1;			// debugging - display the object's bounding box
	BOOL				m_clipToBBox:1;			// debugging - force clip region to the bbox
	BOOL				m_showPartcodes:1;		// debugging - display the partcodes for each control/knob/handle
	BOOL				m_showTargets:1;		// debugging - show the bbox for each control/knob/handle
	BOOL				m_unused_padding:4;		// not used - reserved
}

+ (BOOL)				displaysSizeInfoWhenDragging;
+ (void)				setDisplaysSizeInfoWhenDragging:(BOOL) doesDisplay;

+ (NSRect)				unionOfBoundsOfDrawablesInArray:(NSArray*) array;
+ (int)					initialPartcodeForObjectCreation;

// pasteboard types for drag/drop:

+ (NSArray*)			pasteboardTypesForOperation:(DKPasteboardOperationType) op;

// relationships:

- (DKObjectOwnerLayer*)	layer;
- (DKDrawing*)			drawing;
- (NSUndoManager*)		undoManager;
- (id)					container;
- (void)				setContainer:(id) aContainer;

// state:

- (void)				setVisible:(BOOL) vis;
- (BOOL)				visible;
- (void)				setLocked:(BOOL) locked;
- (BOOL)				locked;
- (void)				setMouseSnappingEnabled:(BOOL) ems;
- (BOOL)				mouseSnappingEnabled;

// selection state:

- (BOOL)				isSelected;
- (void)				objectDidBecomeSelected;
- (void)				objectIsNoLongerSelected;

// drawing:

- (void)				drawContentWithSelectedState:(BOOL) selected;
- (void)				drawContent;
- (void)				drawContentWithStyle:(DKStyle*) aStyle;
- (void)				drawContentForHitBitmap;

- (void)				drawSelectedState;
- (void)				drawSelectionPath:(NSBezierPath*) path;
- (void)				notifyVisualChange;
- (void)				notifyStatusChange;
- (void)				setNeedsDisplayInRect:(NSRect) rect;

- (NSBezierPath*)		renderingPath;
- (BOOL)				useLowQualityDrawing;

// style:

- (void)				setStyle:(DKStyle*) aStyle;
- (DKStyle*)			style;
- (void)				styleWillChange:(NSNotification*) note;
- (void)				styleDidChange:(NSNotification*) note;
- (NSSet*)				allStyles;
- (NSSet*)				allRegisteredStyles;
- (void)				replaceMatchingStylesFromSet:(NSSet*) aSet;

// geometry:

- (void)				setSize:(NSSize) size;
- (NSSize)				size;
- (NSRect)				bounds;
- (NSRect)				apparentBounds;
- (NSRect)				logicalBounds;
- (NSSize)				extraSpaceNeeded;

- (void)				moveToPoint:(NSPoint) p;
- (void)				moveByX:(float) dx byY:(float) dy;
- (NSPoint)				location;
- (float)				angle;
- (void)				rotateToAngle:(float) angle;
- (float)				angleInDegrees;

- (void)				setOffset:(NSSize) offs;
- (NSSize)				offset;
- (void)				resetOffset;

- (NSAffineTransform*)	transform;
- (NSAffineTransform*)	containerTransform;

// creation tool protocol:

- (void)				creationTool:(DKDrawingTool*) tool willBeginCreationAtPoint:(NSPoint) p;
- (void)				creationTool:(DKDrawingTool*) tool willEndCreationAtPoint:(NSPoint) p;
- (BOOL)				objectIsValid;

// snapping to guides, grid and other objects (utility methods)

- (NSPoint)				snappedMousePoint:(NSPoint) mp withControlFlag:(BOOL) snapControl;
- (NSPoint)				snappedMousePoint:(NSPoint) mp forSnappingPointsWithControlFlag:(BOOL) snapControl;

- (NSArray*)			snappingPoints;
- (NSArray*)			snappingPointsWithOffset:(NSSize) offset;
- (NSSize)				mouseOffset;

// getting dimensions in drawing coordinates

- (float)				convertLength:(float) len;
- (NSPoint)				convertPointToDrawing:(NSPoint) pt;

// hit testing:

- (BOOL)				intersectsRect:(NSRect) rect;
- (int)					hitPart:(NSPoint) pt;
- (int)					hitSelectedPart:(NSPoint) pt forSnapDetection:(BOOL) snap;
- (NSPoint)				pointForPartcode:(int) pc;
- (DKKnobType)			knobTypeForPartCode:(int) pc;
- (BOOL)				rectHitsPath:(NSRect) r;
- (BOOL)				pointHitsPath:(NSPoint) p;

- (NSBitmapImageRep*)	pathBitmapInRect:(NSRect) aRect;

// mouse events:

- (void)				mouseDownAtPoint:(NSPoint) mp inPart:(int) partcode event:(NSEvent*) evt;
- (void)				mouseDraggedAtPoint:(NSPoint) mp inPart:(int) partcode event:(NSEvent*) evt;
- (void)				mouseUpAtPoint:(NSPoint) mp inPart:(int) partcode event:(NSEvent*) evt;
- (NSView*)				currentView;
- (void)				mouseDoubleClickedAtPoint:(NSPoint) mp inPart:(int) partcode event:(NSEvent*) evt;

- (NSCursor*)			cursorForPartcode:(int) partcode mouseButtonDown:(BOOL) button;

// contextual menu:

- (BOOL)				populateContextualMenu:(NSMenu*) theMenu;

// swatch image of this object:

- (NSImage*)			swatchImageWithSize:(NSSize) size;

// user info:

- (void)				setUserInfo:(id) info;
- (id)					userInfo;

// user level commands that can be responded to by this object (and its subclasses)

- (IBAction)			copyDrawingStyle:(id) sender;
- (IBAction)			pasteDrawingStyle:(id) sender;

#ifdef qIncludeGraphicDebugging
// debugging:

- (IBAction)			toggleShowBBox:(id) sender;
- (IBAction)			toggleClipToBBox:(id) sender;
- (IBAction)			toggleShowPartcodes:(id) sender;
- (IBAction)			toggleShowTargets:(id) sender;

#endif

@end


// partcodes that are known to the layer - most are private to the drawable object class, but these are public:

enum
{
	kGCDrawingNoPart			= 0,
	kGCDrawingEntireObjectPart	= -1
};


extern NSString*		kGCDrawableObjectPasteboardType;
extern NSString*		kGCDrawableDidChangeNotification;
extern NSString*		kDKDrawableStyleWillBeDetachedNotification;
extern NSString*		kDKDrawableStyleWasAttachedNotification;

// keys for items in user info sent with notifications

extern NSString*		kDKDrawableOldStyleKey;
extern NSString*		kDKDrawableNewStyleKey;

/*
 A drawable object is owned by a DKObjectDrawingLayer, which is responsible for drawing it when required and handling
 selections. This object is responsible for the visual representation of the selection as well as any content.
 
 It can draw whatever it likes within <bounds>, which it is responsible for calculating correctly.
 
 hitTest can return an integer to indicate which part was hit - a value of 0 means nothing hit. The returned value's meaning
 is otherwise private to the class, but is returned in the mouse event methods.
 
 This is intended to be an abstract class - it draws nothing very useful itself (except a frame within bounds, for testing).
 
 The user info is a dictionary attached to an object. It plays no part in the graphics system, but can be used by applications
 to attach arbitrary data to any drawable object.

*/


