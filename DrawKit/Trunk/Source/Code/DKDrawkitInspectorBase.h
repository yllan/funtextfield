///**********************************************************************************************************************************
///  DKDrawkitInspectorBase.h
///  DrawKit
///
///  Created by graham on 06/05/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>


@class DKDrawing, DKLayer, DKDrawingDocument, DKViewController;


@interface DKDrawkitInspectorBase : NSWindowController

- (void)				documentDidChange:(NSNotification*) note;
- (void)				layerDidChange:(NSNotification*) note;
- (void)				selectedObjectDidChange:(NSNotification*) note;

- (void)				redisplayContentForSelection:(NSArray*) selection;

- (id)					selectedObjectForCurrentTarget;
- (id)					selectedObjectForTargetWindow:(NSWindow*) window;
- (DKDrawing*)			drawingForTargetWindow:(NSWindow*) window;

// these return what they say when the app is in a static state. When responding to documentDidChange:, they can return nil
// because Cocoa's notifications are sent too early. In that case you should respond to the notification directly and
// extract the relevant DK objects working back from the window. It sucks, I know.

- (DKDrawingDocument*)	currentDocument;
- (DKDrawing*)			currentDrawing;
- (DKLayer*)			currentActiveLayer;

- (DKViewController*)	currentMainViewController;

@end



/*

This is a base class for any inspector for looking at DrawKit. All it does is respond to the various selection changed
notifications at the document, layer and object levels, and call a method which you can override to set up the displayed
content.


*/
