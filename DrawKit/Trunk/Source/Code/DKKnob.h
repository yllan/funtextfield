//
//  DKKnob.h
//  DrawingArchitecture
//
//  Created by graham on 21/08/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DKCommonTypes.h"


// visual flags, used internally

typedef enum
{
	kDKKnobDrawsStroke				= ( 1 << 0 ),
	kDKKnobDrawsFill				= ( 1 << 1 )
}
DKKnobDrawingFlags;



@interface DKKnob : NSObject
{
	id				m_ownerRef;				// the object that owns (and hence retains) this
	NSSize			m_knobSize;				// the currently cached knob size
}

+ (id)				standardKnobs;

+ (void)			setControlKnobColour:(NSColor*) clr;
+ (NSColor*)		controlKnobColour;

+ (void)			setRotationKnobColour:(NSColor*) clr;
+ (NSColor*)		rotationKnobColour;

+ (void)			setControlOnPathPointColour:(NSColor*) clr;
+ (NSColor*)		controlOnPathPointColour;

+ (void)			setControlBarColour:(NSColor*) clr;
+ (NSColor*)		controlBarColour;

+ (void)			setControlKnobSize:(NSSize) size;
+ (NSSize)			controlKnobSize;

+ (void)			setControlBarWidth:(float) width;
+ (float)			controlBarWidth;

+ (NSRect)			controlKnobRectAtPoint:(NSPoint) kp;

// main high-level methods will be called by clients

- (void)			setOwner:(id<DKKnobOwner>) owner;
- (id<DKKnobOwner>)	owner;

- (BOOL)			hitTestPoint:(NSPoint) p inKnobAtPoint:(NSPoint) kp ofType:(DKKnobType) knobType userInfo:(id) userInfo;
- (void)			drawKnobAtPoint:(NSPoint) p ofType:(DKKnobType) knobType userInfo:(id) userInfo;
- (void)			drawKnobAtPoint:(NSPoint) p ofType:(DKKnobType) knobType angle:(float) radians userInfo:(id) userInfo;

// low-level methods (mostly internal and overridable)

- (void)			setControlKnobSize:(NSSize) cks;
- (void)			setControlKnobSizeForViewScale:(float) scale;
- (NSSize)			controlKnobSize;
- (NSRect)			controlKnobRectAtPoint:(NSPoint) kp;
- (NSRect)			controlKnobRectAtPoint:(NSPoint) kp ofType:(DKKnobType) knobType;

- (NSBezierPath*)	knobPathAtPoint:(NSPoint) p ofType:(DKKnobType) knobType angle:(float) radians userInfo:(id) userInfo;
- (void)			drawKnobPath:(NSBezierPath*) path ofType:(DKKnobType) knobType userInfo:(id) userInfo;
- (DKKnobDrawingFlags) drawingFlagsForKnobType:(DKKnobType) knobType;

- (NSColor*)		fillColourForKnobType:(DKKnobType) knobType;
- (NSColor*)		strokeColourForKnobType:(DKKnobType) knobType;
- (float)			strokeWidthForKnobType:(DKKnobType) knobType;

- (void)			drawControlBarFromPoint:(NSPoint) a toPoint:(NSPoint) b;
- (void)			drawControlBarWithKnobsFromPoint:(NSPoint) a toPoint:(NSPoint) b;
- (void)			drawControlBarWithKnobsFromPoint:(NSPoint) a ofType:(DKKnobType) typeA toPoint:(NSPoint) b ofType:(DKKnobType) typeB;
- (void)			drawRotationBarWithKnobsFromCentre:(NSPoint) centre toPoint:(NSPoint) p;
- (void)			drawPartcode:(int) code atPoint:(NSPoint) p fontSize:(float) fontSize;

@end


// keys in the userInfo that can be used to pass additional information to the knob drawing methods

extern NSString*	kDKKnobPreferredHighlightColour;		// references an NSColor


/*

simple class used to provide the drawing of knobs for object selection. You can override this and replace it (attached to any layer)
to customise the appearance of the selection knobs for all drawn objects in that layer.

The main method a drawable will call is drawKnobAtPoint:ofType:userInfo:

The type (DKKnobType) is a functional description of the knob only - this class maps that functional description to a consistent appearance taking
into account the basic type and a couple of generic state flags. Clients should generally avoid trying to do drawing themselves of knobs, but if they do,
should use the lower level methods here to get consistent results.

Subclasses may want to customise many aspects of a knob's appearance, and can override any suitable factored methods according to their needs. Customisations
might include the shape of a knob, its colours, whether stroked or filled or both, etc.

*/
