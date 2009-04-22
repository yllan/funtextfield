///**********************************************************************************************************************************
///  DKDrawDocument.h
///  DrawKit
///
///  Created by graham on 15/10/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>


@class DKDrawing, DKDrawingView, DKViewController;


@interface DKDrawingDocument : NSDocument
{
	DKDrawing*				m_drawing;
	IBOutlet DKDrawingView*	m_mainView;
}

+ (NSUndoManager*)		sharedDrawkitUndoManager;

- (void)				setDrawing:(DKDrawing*) drwg;
- (DKDrawing*)			drawing;
- (DKDrawingView*)		mainView;
- (DKViewController*)	makeControllerForView:(NSView*) aView;
- (DKDrawing*)			makeDefaultDrawing;

- (NSSet*)				allStyles;
- (NSSet*)				allRegisteredStyles;

- (void)				remergeStyles:(NSSet*) stylesToMerge readFromURL:(NSURL*) url;
- (void)				replaceDocumentStylesWithMatchingStylesFromSet:(NSSet*) aSetOfStyles;
- (NSString*)			documentStyleCategoryName;

- (IBAction)			newDrawingLayer:(id) sender;
- (IBAction)			newLayerWithSelection:(id) sender;
- (IBAction)			deleteActiveLayer:(id) sender;

@end

extern NSString*		kGCDrawingDocumentType;
extern NSString*		kDKDrawingDocumentUTI;

/*

This class is a simple document type that owns a drawing instance. It can be used as the basis for any drawing-based
document, where there is a 1:1 relationship between the documnent, the drawing and the main drawing view.

You can subclass to add functionality without having to rewrite the drawing ownership stuff.

This also handles standard printing of the drawing

Note that this is expected to be set up via the associated nib file. The outlet m_mainView should be set to the DKDrawingView in the window. Inherited
outlets such as window should be set as normal (File's Owner is of course, this object). If you forget to set the m_mainView outlet things won't work
properly because the document won't know which view to link to the drawing it creates. What will happen is that the unconnected view will work, and the first
time it goes to draw it will detect it has no back-end, and create one automatically. This is a feature, but in this case can be misleading, in that the drawing
you *see* is NOT the drawing that the document owns. The m_mainView outlet is the only way the document has to know about the view it's supposed to connect to
its drawing.

If you subclass this to have more views, etc, bear this in mind - you have to consider how the document's drawing gets hooked up to the views you want. Outlets
like this are one easy way to do it, but not the only way.

*/
