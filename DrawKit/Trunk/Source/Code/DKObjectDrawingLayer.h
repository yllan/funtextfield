///**********************************************************************************************************************************
///  DKObjectDrawingLayer.h
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


#import "DKObjectOwnerLayer.h"


@interface DKObjectDrawingLayer : DKObjectOwnerLayer <NSCoding>
{
	NSMutableSet*		m_selection;				// list of selected objects
	NSSet*				m_selectionUndo;			// old selection when setting up undo
	NSRect				m_dragExcludeRect;			// drags will become "real" once this rect is left
	BOOL				m_selectionIsUndoable;		// YES if selection changes tracked by undo
	BOOL				m_drawSelectionOnTop;		// YES if selection highlights are drawn in a pseudo-layer on top of all objects
	BOOL				m_selectionVisible;			// YES if selection is actually drawn
	BOOL				m_allowDragTargeting;		// YES if the layer can target individual objects when receiving a drag/drop
	unsigned			mUndoCount;					// records undo count when the selection state is recorded
	NSArray*			m_objectsPendingDrag;		// temporary list of objects being dragged from the layer
}

+ (void)				setSelectionIsShownWhenInactive:(BOOL) visInactive;
+ (BOOL)				selectionIsShownWhenInactive;
+ (void)				setDefaultSelectionChangesAreUndoable:(BOOL) undoSel;
+ (BOOL)				defaultSelectionChangesAreUndoable;

// useful lists of objects:

- (NSArray*)			selectedAvailableObjects;
- (NSArray*)			selectedAvailableObjectsOfClass:(Class) aClass;
- (NSArray*)			selectedVisibleObjects;
- (NSSet*)				selectedObjectsReturning:(int) answer toSelector:(SEL) selector;
- (NSArray*)			duplicatedSelection;
- (NSArray*)			selectedObjectsPreservingStackingOrder;
- (int)					countOfSelectedAvailableObjects;

// doing stuff to each one:

- (void)				makeSelectedAvailableObjectsPerform:(SEL) selector;
- (void)				makeSelectedAvailableObjectsPerform:(SEL) selector withObject:(id) anObject;
- (void)				setSelectedObjectsLocked:(BOOL) lock;
- (void)				setSelectedObjectsVisible:(BOOL) visible;
- (BOOL)				setHiddenObjectsVisible;

- (void)				refreshSelectedObjects;
- (BOOL)				moveSelectedObjectsByX:(float) dx byY:(float) dy;

// the selection:

- (void)				setSelection:(NSSet*) sel;
- (NSSet*)				selection;
- (DKDrawableObject*)	singleSelection;

// selection operations:

- (void)				deselectAll;
- (void)				selectAll;
- (void)				addObjectToSelection:(DKDrawableObject*) obj;
- (void)				addObjectsToSelectionFromArray:(NSArray*) objs;
- (BOOL)				replaceSelectionWithObject:(DKDrawableObject*) obj;
- (void)				removeObjectFromSelection:(DKDrawableObject*) obj;
- (BOOL)				exchangeSelectionWithObjectsInArray:(NSArray*) sel;
- (void)				scrollToSelectionInView:(NSView*) aView;

// style operations on multiple items:

- (BOOL)				selectObjectsWithStyle:(DKStyle*) style;
- (BOOL)				replaceStyle:(DKStyle*) style withStyle:(DKStyle*) newStyle selectingObjects:(BOOL) select;

// useful selection tests:

- (BOOL)				isSelectedObject:(DKDrawableObject*) obj;
- (BOOL)				isSelectionNotEmpty;
- (BOOL)				isSingleObjectSelected;
- (BOOL)				selectionContainsObjectOfClass:(Class) c;
- (NSRect)				selectionBounds;

// selection undo stuff:

- (void)				setSelectionChangesAreUndoable:(BOOL) undoable;
- (BOOL)				selectionChangesAreUndoable;
- (void)				recordSelectionForUndo;
- (void)				commitSelectionUndoWithActionName:(NSString*) actionName;
- (BOOL)				selectionHasChangedFromRecorded;

// making images of the selected objects:

- (void)				drawSelectedObjects;
- (void)				drawSelectedObjectsWithSelectionState:(BOOL) selected;

- (NSImage*)			imageOfSelectedObjects;
- (NSData*)				pdfDataOfSelectedObjects;

// clipboard ops:

- (void)				copySelectionToPasteboard:(NSPasteboard*) pb;

// options:

- (void)				setDrawsSelectionHighlightsOnTop:(BOOL) onTop;
- (BOOL)				drawsSelectionHighlightsOnTop;
- (void)				setAllowsObjectsToBeTargetedByDrags:(BOOL) allow;
- (BOOL)				allowsObjectsToBeTargetedByDrags;
- (void)				setSelectionVisible:(BOOL) vis;
- (BOOL)				selectionVisible;

// drag + drop:

- (void)				setDragExclusionRect:(NSRect) aRect;
- (NSRect)				dragExclusionRect;
- (void)				beginDragOfSelectedObjectsWithEvent:(NSEvent*) event inView:(NSView*) view;
- (void)				drawingSizeChanged:(NSNotification*) note;

// user actions:

- (IBAction)			cut:(id) sender;
- (IBAction)			copy:(id) sender;
- (IBAction)			paste:(id) sender;
- (IBAction)			delete:(id) sender;
- (IBAction)			deleteBackward:(id) sender;
- (IBAction)			duplicate:(id) sender;
- (IBAction)			selectAll:(id) sender;
- (IBAction)			selectNone:(id) sender;
- (IBAction)			objectBringForward:(id) sender;
- (IBAction)			objectSendBackward:(id) sender;
- (IBAction)			objectBringToFront:(id) sender;
- (IBAction)			objectSendToBack:(id) sender;
- (IBAction)			lockObject:(id) sender;
- (IBAction)			unlockObject:(id) sender;
- (IBAction)			showObject:(id) sender;
- (IBAction)			hideObject:(id) sender;
- (IBAction)			revealHiddenObjects:(id) sender;
- (IBAction)			groupObjects:(id) sender;
- (IBAction)			clusterObjects:(id) sender;

- (IBAction)			moveLeft:(id) sender;
- (IBAction)			moveRight:(id) sender;
- (IBAction)			moveUp:(id) sender;
- (IBAction)			moveDown:(id) sender;

- (IBAction)			selectMatchingStyle:(id) sender;
- (IBAction)			joinPaths:(id) sender;

@end


// magic numbers:

enum
{
	kGCMakeColinearJoinTag				= 200,  // set this tag value in "Join Paths" menu item to make the join colinear
	kDKPasteCommandContextualMenuTag	= 201	// used for contextual 'paste' menu to use mouse position when positioning pasted items
};


extern NSString*		kGCDrawableObjectPasteboardType;
extern NSString*		kGCLayerDidReorderObjects;
extern NSString*		kGCLayerSelectionDidChange;

/*

This layers adds the concept of selection to drawable objects as defined by DKObjectOwnerLayer. Selected objects are held in the -selection
list, which is a set (there is no order to selected objects per se - though sometimes the relative Z-stacking order of objects in the selection
is needed, and the method -selectedObjectsPreservingStackingOrder et. al. will provide that.

Note that for selection, the locked state of owned objects is ignored (because it is OK to select a locked object, just not to
do anything with it except unlock it).

Commands directed at this layer are usually meant to to go to "the selection", either multiple or single objects.

This class provides no direct mouse handlers for actually changing the selection - typically the selection and other manipulation
of objects in this layer is done through the agency of tools and a DKToolController.

The actual appearance of the selection is mainly down to the objects themselves, with some information supplied by the layer (for example
the layer's selectionColour). Also, the layer's (or more typically the drawing's) DKKnob class is generally used by objects to display their
selected state.

*/

