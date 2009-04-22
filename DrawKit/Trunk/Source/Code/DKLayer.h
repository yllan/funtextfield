///**********************************************************************************************************************************
///  DKLayer.h
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

@class DKDrawing, DKDrawingView, DKLayerGroup, DKDrawableObject, DKKnob, DKStyle, GCInfoFloater;

// generic layer class:

@interface DKLayer : NSObject <NSCoding, DKKnobOwner>
{
	DKLayerGroup*	m_groupRef;				// group we are contained by (or drawing)
	NSString*		m_name;					// layer name
	NSColor*		m_selectionColour;		// colour preference for selection highlights in this layer
	NSView*			m_eventViewRef;			// view that passed us current mouse event
	DKKnob*			m_knobs;				// knobs helper object if set - normally nil to defer to drawing
	BOOL			m_knobsAdjustToScale;	// YES if knobs allow for the view scale
	BOOL			m_visible;				// is the layer visible?
	BOOL			m_locked;				// is the layer locked?
	BOOL			m_printed;				// is the layer drawn when printing?
	GCInfoFloater * m_infoWindow;			// info window instance that can be used by client objects as they wish
}

+ (NSColor*)		selectionColourForIndex:(unsigned) index;

// owning drawing:

- (DKDrawing*)		drawing;
- (void)			drawingHasNewUndoManager:(NSUndoManager*) um;
- (NSUndoManager*)	undoManager;

// layer group hierarchy:

- (void)			setLayerGroup:(DKLayerGroup*) group;
- (DKLayerGroup*)	layerGroup;

// drawing:

- (void)			drawRect:(NSRect) rect inView:(DKDrawingView*) aView;
- (BOOL)			isOpaque;
- (void)			setNeedsDisplay:(BOOL) update;
- (void)			setNeedsDisplayInRect:(NSRect) rect;
- (void)			setNeedsDisplayInRects:(NSSet*) setOfRects;
- (void)			setNeedsDisplayInRects:(NSSet*) setOfRects withExtraPadding:(NSSize) padding;

- (void)			setSelectionColour:(NSColor*) colour;
- (NSColor*)		selectionColour;

- (NSImage*)		thumbnailImageWithSize:(NSSize) size;
- (NSImage*)		thumbnail;

// states:

- (void)			setLocked:(BOOL) locked;
- (BOOL)			locked;
- (void)			setVisible:(BOOL) visible;
- (BOOL)			visible;
- (BOOL)			isActive;
- (BOOL)			lockedOrHidden;

- (void)			setName:(NSString*) name;
- (NSString*)		name;

// print this layer?

- (void)			setShouldDrawToPrinter:(BOOL) printIt;
- (BOOL)			shouldDrawToPrinter;

// becoming/resigning active:

- (BOOL)			layerMayBecomeActive;
- (void)			layerDidBecomeActiveLayer;
- (void)			layerDidResignActiveLayer;

// mouse event handling:

- (BOOL)			shouldAutoActivateWithEvent:(NSEvent*) event;
- (BOOL)			hitLayer:(NSPoint) p;

- (void)			mouseDown:(NSEvent*) event inView:(NSView*) view;
- (void)			mouseDragged:(NSEvent*) event inView:(NSView*) view;
- (void)			mouseUp:(NSEvent*) event inView:(NSView*) view;
- (void)			flagsChanged:(NSEvent*) event;

- (void)			setCurrentView:(NSView*) view;
- (NSView*)			currentView;
- (NSCursor*)		cursor;
- (NSRect)			activeCursorRect;

- (NSMenu *)		menuForEvent:(NSEvent *)theEvent inView:(NSView*) view;

// supporting per-layer knob handling - default defers to the drawing as before

- (void)			setKnobs:(DKKnob*) knobs;
- (DKKnob*)			knobs;
- (void)			setKnobsShouldAdustToViewScale:(BOOL) ka;
- (BOOL)			knobsShouldAdjustToViewScale;

// pasteboard types for drag/drop etc:

- (NSArray*)		pasteboardTypesForOperation:(DKPasteboardOperationType) op;
- (BOOL)			pasteboard:(NSPasteboard*) pb hasAvailableTypeForOperation:(DKPasteboardOperationType) op;

// style utilities (implemented by subclasses such as DKObjectOwnerLayer)

- (NSSet*)			allStyles;
- (NSSet*)			allRegisteredStyles;
- (void)			replaceMatchingStylesFromSet:(NSSet*) aSet;

// info window utilities:

- (void)			showInfoWindowWithString:(NSString*) str atPoint:(NSPoint) p;
- (void)			hideInfoWindow;
- (void)			setInfoWindowBackgroundColour:(NSColor*) colour;

// user actions:

- (IBAction)		lockLayer:(id) sender;
- (IBAction)		unlockLayer:(id) sender;
- (IBAction)		toggleLayerLock:(id) sender;

- (IBAction)		showLayer:(id) sender;
- (IBAction)		hideLayer:(id) sender;
- (IBAction)		toggleLayerVisible:(id) sender;


@end


extern NSString*	kDKLayerLockStateDidChange;
extern NSString*	kDKLayerVisibleStateDidChange;

/*

drawing layers are lightweight objects which represent a layer. They are owned by a DKDrawing which manages the
stacking order and invokes the drawRect: method as needed. The other state variables control whether the layer is
visible, locked, etc.

DKDrawing will not ever call a drawRect: on a layer that returns NO for visible.

if isOpaque returns YES, layers that are stacked below this one will not be drawn, even if they are visible. isOpaque
returns NO by default.

locked layers should not be editable, but this must be enforced by subclasses, as this class contains no editing
features. However, locked layers will never receive mouse event calls so generally this will be enough.

As layers are retained by the drawing, this does not retain the drawing.

By definition the bounds of the layer is the same as the bounds of the drawing.


*/
