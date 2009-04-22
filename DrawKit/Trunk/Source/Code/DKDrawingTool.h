///**********************************************************************************************************************************
///  DKDrawingTool.h
///  DrawKit
///
///  Created by graham on 23/09/2006.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKDrawingToolProtocol.h"


@interface DKDrawingTool : NSObject <DKDrawingTool>
{
	NSString*			mKeyboardEquivalent;
	unsigned			mKeyboardModifiers;
}

+ (DKDrawingTool*)		drawingToolWithName:(NSString*) name;
+ (void)				registerDrawingTool:(DKDrawingTool*) tool withName:(NSString*) name;
+ (DKDrawingTool*)		drawingToolWithKeyboardEquivalent:(NSEvent*) keyEvent;

+ (void)				registerStandardTools;
+ (NSArray*)			toolNames;
+ (BOOL)				toolPerformsUndoableAction;


- (NSString*)			registeredName;
- (void)				drawRect:(NSRect) aRect inView:(NSView*) aView;
- (void)				flagsChanged:(NSEvent*) event inLayer:(DKLayer*) layer;
- (BOOL)				isValidTargetLayer:(DKLayer*) aLayer;

- (void)				set;

- (void)				setCursorForPoint:(NSPoint) mp targetObject:(DKDrawableObject*) obj inLayer:(DKLayer*) aLayer event:(NSEvent*) event;

// if a keyboard equivalent is set, the tool controller will set the tool if the keyboard equivalent is received in keyDown:
// the tool must be registered for this to function.

- (void)				setKeyboardEquivalent:(NSString*) str modifierFlags:(unsigned) flags;
- (NSString*)			keyboardEquivalent;
- (unsigned)			keyboardModifierFlags;

@end


extern NSString*		kGCDrawingToolWasRegisteredNotification;
extern NSString*		kDKStandardSelectionToolName;

/*

DKDrawingTool is the semi-abstract base class for all types of drawing tool. The point of a tool is to act as a translator for basic mouse events and
convert those events into meaningful operations on the target layer or object(s). One tool can be set at a time (see DKToolController) and
establishes a "mode" of operation for handling mouse events.

The tool also supplies a cursor for the view when that tool is selected.

A tool typically targets a layer or the objects within it. The calling sequence to a tool is coordinated by the DKToolController, targeting
the current active layer. Tools can change the data content of the layer or not - for example a zoom zool would only change the scale of
a view, not change any data.

Tools should be considered to be controllers, and sit between the view and the drawing data model.

Note: do not confuse "tools" as DK defines them with a palette of buttons or other UI - an application might implement an interface to
select a tool in such a way, but the buttons are not tools. A button could store a tool as its representedObject however. These UI con-
siderations are outside the scope of DK itself.

*/
