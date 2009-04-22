///**********************************************************************************************************************************
///  DKSelectAndEditTool.h
///  DrawKit
///
///  Created by graham on 8/04/2008.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************


#import "DKDrawingTool.h"


@class DKDrawingView, DKStyle, DKObjectDrawingLayer;

// modes of operation determined by what was hit and what is in the selection

typedef enum
{
	kDKEditToolInvalidMode		= 0,
	kDKEditToolSelectionMode	= 1,
	kDKEditToolEditObjectMode	= 2,
	kDKEditToolMoveObjectsMode	= 3
}
DKEditToolOperation;

// drag phases passed to dragObjectAsGroup:...

typedef enum
{
	kDKDragMouseDown			= 1,
	kDKDragMouseDragged			= 2,
	kDKDragMouseUp				= 3
}
DKEditToolDragPhase;


// tool class

@interface DKSelectAndEditTool : DKDrawingTool
{
	DKEditToolOperation		mOperationMode;				// what the tool is doing (selecting, editing or moving)
	NSPoint					mAnchorPoint;				// the point of the initial mouse down
	NSRect					mMarqueeRect;				// the selection rect, while selecting
	DKStyle*				mMarqueeStyle;				// the appearance style of the marquee
	NSString*				mUndoAction;				// the most recently performed action name
	BOOL					mHideSelectionOnDrag;		// YES to hide knobs and jhandles while dragging an object
	BOOL					mAllowMultiObjectDrag;		// YES to allow all objects in the selection to be moved at once
	BOOL					mPerformedUndoableTask;		// YES if the tool did anything undoable
	BOOL					mAllowDirectCopying;		// YES if option-drag copies the objects directly
	BOOL					mDidCopyDragObjects;		// YES if objects were copied when dragged
	BOOL					mMouseMoved;				// YES if mouse was actually dragged, not just clicked
	float					mViewScale;					// the view's current scale, valid for the renderingPath callback
}

+ (DKStyle*)				defaultMarqueeStyle;

// modes of operation:

- (void)					setOperationMode:(DKEditToolOperation) op;
- (DKEditToolOperation)		operationMode;

// drawing the marquee (selection rect):

- (void)					drawMarqueeInView:(DKDrawingView*) aView;
- (NSRect)					marqueeRect;
- (void)					setMarqueeRect:(NSRect) marqueeRect inLayer:(DKLayer*) aLayer;

- (void)					setMarqueeStyle:(DKStyle*) aStyle;
- (DKStyle*)				marqueeStyle;

// setting up optional behaviours:

- (void)					setSelectionShouldHideDuringDrag:(BOOL) hideSel;
- (BOOL)					selectionShouldHideDuringDrag;
- (void)					setDragsAllObjectsInSelection:(BOOL) multi;
- (BOOL)					dragsAllObjectsInSelection;
- (void)					setAllowsDirectDragCopying:(BOOL) dragCopy;
- (BOOL)					allowsDirectDragCopying;

// handling the selection

- (void)					changeSelectionWithTarget:(DKDrawableObject*) targ inLayer:(DKObjectDrawingLayer*) layer event:(NSEvent*) event;

// dragging objects

- (void)					dragObjectsAsGroup:(NSArray*) objects inLayer:(DKObjectDrawingLayer*) layer toPoint:(NSPoint) p event:(NSEvent*) event dragPhase:(DKEditToolDragPhase) ph;

// setting the undo action name

- (void)					setUndoAction:(NSString*) action;

@end


/*

This tool implements the standard selection and edit tool behaviour (multi-purpose tool) which allows objects to be selected,
moved by dragging and to be edited by having their knobs dragged. For editing, objects mostly handle this themselves, but this
provides the initial translation of mouse events into edit operations.

Note that the tool can only be used in layers which are DKObjectDrawingLayers - if the layer is not of this kind then the
tool mode is set to invalid and nothing is done.

The 'marquee' (selection rect) is drawn using a style, giving great flexibility as to its appearance. In general a style that
has a very low opacity should be used - the default style takes the system's highlight colour and makes a low opacity version of it.

*/
