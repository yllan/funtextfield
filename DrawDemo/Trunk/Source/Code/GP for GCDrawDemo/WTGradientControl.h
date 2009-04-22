///**********************************************************************************************************************************
///  WTGradientControl.h
///  GCDrawKit
///
///  Created by Jason Jobe on 24/02/07.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "GCGradientWell.h"


@class DKColorStop;
@class GCInfoFloater;


@interface WTGradientControl : GCGradientWell
{
	DKColorStop*	mDragStopRef;
	DKColorStop*	mSelectedStopRef;
	DKColorStop*	mDeletionCandidateRef;
	GCInfoFloater*	mInfoWin;
	
	NSMutableArray*	mUnsortedStops;
	NSMutableArray*	mSBArray;
	
	NSPoint			mStopInsertHint;
	BOOL			mStopWasDragged;
	BOOL			mMouseDownInStop;
	BOOL			mShowsInfo;
}


- (void)			setGradient:(DKGradient*) aGradient;

- (void)			removeColorStopAtPoint:(NSPoint) point;
- (DKColorStop*)	addColorStop: (NSColor*) color atPoint:(NSPoint) point;
- (NSColor*)		colorAtPoint:(NSPoint) point;

- (NSRect)			swatchBoxAtPosition:(float) position;
- (NSArray*)		allSwatchBoxes;
- (NSRect)			swatchRectForStop:(DKColorStop*) stop;
- (void)			invalidate;

- (void)			drawStopsInRect:(NSRect) rect;
- (DKColorStop*)	stopAtPoint:(NSPoint) point;
- (void)			setSelectedStop:(DKColorStop*) stop;
- (DKColorStop*)	selectedStop;
- (void)			setColorOfSelectedStop:(NSColor*) Color;

- (void)			updateInfoWithPosition:(float) pos;
- (void)			setShowsPositionInfo:(BOOL) show;
- (BOOL)			showsPositionInfo;

- (BOOL)			setCursorInSafeLocation:(NSPoint) p;
- (NSImage*)		dragImageForStop:(DKColorStop*) stop;
- (NSCursor*)		makeCursorForDeletingStop:(DKColorStop*) stop;

- (void)			trackMouseWithEvent:(NSEvent*) event;

- (IBAction)		changeColor:(id) sender;
- (IBAction)		newStop:(id) sender;
- (IBAction)		blendMode:(id) sender;
- (IBAction)		flip:(id) sender;
- (IBAction)		gradientType:(id) sender;


- (NSRect)			interior;

@end

// state constants used to specify highlighting for stops

enum
{
	kGCNormalState				= 0,
	kGCPressedState				= 1,
	kGCSelectedState			= 2,
	kGCInactiveState			= 3,
	kGCHighlightedForMenuState	= 4
};



