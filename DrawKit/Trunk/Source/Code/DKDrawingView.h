///**********************************************************************************************************************************
///  DKDrawingView.h
///  DrawKit
///
///  Created by graham on 11/08/2006.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "GCZoomView.h"


@class DKDrawing, DKLayer, DKViewController;


@interface DKDrawingView : GCZoomView
{
	NSTextView*			m_textEditViewRef;		// if valid, set to text editing view
	NSPrintInfo*		m_pageBreakPrintInfo;	// print info used to draw page breaks (set nil to not draw page breaks)
	DKViewController*	mControllerRef;			// the view's controller (weak ref)
	DKDrawing*			mAutoDrawing;			// the drawing we created automatically (if we did so - typically nil for doc-based apps)
	BOOL				m_didCreateDrawing;		// YES if the window built the back end itself
	NSRect				mEditorFrame;			// tracks current frame of text editor
	const NSRect*		mRectDrawingList;		// for threaded drawing
	int					mRectCount;				// for threaded drawing
}

+ (DKDrawingView*)		currentlyDrawingView;
+ (void)				setPageBreakColour:(NSColor*) colour;
+ (NSColor*)			pageBreakColour;

// setting up and maintaining threaded drawing updates:

+ (void)				setDrawUsingSecondaryThread:(BOOL) threaded;
+ (BOOL)				drawUsingSecondaryThread;

// the view's controller

- (void)				setController:(DKViewController*) aController;
- (DKViewController*)	controller;

// automatic drawing info

- (DKDrawing*)			drawing;
- (void)				createAutoDrawing;
- (DKViewController*)	makeViewController;

// drawing page breaks

- (void)				drawPageBreaks;
- (void)				setPageBreakInfo:(NSPrintInfo*) pbpi;
- (BOOL)				pageBreaksVisible;

// drawing the view's content - factored from drawRect: to permit calling from a secondary thread

- (void)				drawContentInRect:(NSRect) rect withRectsBeingDrawn:(const NSRect*) rectList count:(int) count;
- (NSRect*)				copyRectsBeingDrawn:(int*) count;

// editing text directly in the drawing:

- (NSTextView*)			editText:(NSTextStorage*) text inRect:(NSRect) rect delegate:(id) del;
- (void)				endTextEditing;
- (NSTextStorage*)		editedText;
- (NSTextView*)			textEditingView;
- (void)				editorFrameChangedNotification:(NSNotification*) note;


// ruler stuff

- (void)				updateRulerMouseTracking:(NSPoint) mouse;
- (void)				moveRulerMarkerRepresentingObject:(id) obj toLocation:(float) loc;
- (void)				createRulerMarkers;
- (void)				removeRulerMarkers;
- (void)				resetRulerClientView;

// user actions

- (IBAction)			toggleRuler:(id) sender;
- (IBAction)			toggleShowPageBreaks:(id) sender;

// monitoring the mouse location:

- (void)				postMouseLocationInfo:(NSString*) operation event:(NSEvent*) event;

// window activations

- (void)				windowActiveStateChanged:(NSNotification*) note;


@end


extern NSString* kGCDrawingViewDidBeginTextEditing;
extern NSString* kGCDrawingViewTextEditingContentsDidChange;
extern NSString* kGCDrawingViewDidEndTextEditing;
extern NSString* kGCDrawingMouseDownLocation;
extern NSString* kGCDrawingMouseDraggedLocation;
extern NSString* kGCDrawingMouseUpLocation;
extern NSString* kGCDrawingMouseMovedLocation;

extern NSString* kGCDrawingMouseLocationInView;
extern NSString* kGCDrawingMouseLocationInDrawingUnits;

/*

DKDrawingView is the visible "front end" for the DKDrawing architecture.

A drawing can have multiple views into the same drawing data model, each with independent scales, scroll positions and so forth, but
all showing the same drawing. Manipulating the drawing through any view updates all of the views. In many cases there will only be
one view. The views are not required to be in the same window.

The actual contents of the drawing are all supplied by DKDrawing - all this does is call it to render its contents.

If the drawing system is built by hand, the drawing owns the view controller(s), and some other object (a document for example) will own the
drawing. However, like NSTextView, if you don't build a system by hand, this creates a default one for you which it takes ownership
of. By default this consists of 3 layers - a grid layer, a guide layer and a standard object layer. You can change this however you like, it's
there just as a construction convenience.

Note that because the controllers are owned by the drawing, there is no retain cycle even when the view owns the drawing. Views are owned by
their parent view or window, not by their controller.

*/
