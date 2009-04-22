//
//  GCColourPickerView.h
//  gradientpanel
//
//  Created by Graham on Tue Mar 27 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>


@class GCInfoFloater;


@interface GCColourPickerView : NSView
{
	NSColor*		mNonSelectColour;
	GCInfoFloater*  mInfoWin;
	id				mTargetRef;
	int				mMode;
	NSPoint			mSel;
	SEL				mSelector;
	float			mBright;
	BOOL			mShowsInfo;
}


- (void)		setMode:(int) aMode;
- (int)			mode;

- (void)		drawSwatches:(NSRect) rect;
- (void)		drawSpectrum:(NSRect) rect;

- (NSColor*)	color;
- (NSColor*)	colorForSpectrumPoint:(NSPoint) p;
- (NSPoint)		pointForSpectrumColor:(NSColor*) colour;
- (NSRect)		rectForSpectrumPoint:(NSPoint) sp;
- (BOOL)		pointIsInColourwheel:(NSPoint) p;

- (void)		setBrightness:(float) brightness;
- (float)		brightness;

- (NSPoint)		swatchAtPoint:(NSPoint) p;
- (NSColor*)	colorForSwatchX:(int) x y:(int) y;
- (NSRect)		rectForSwatch:(NSPoint) sp;
- (void)		updateInfoAtPoint:(NSPoint) p;

- (void)		sendToTarget;

- (void)		setTarget:(id) target;
- (void)		setAction:(SEL) selector;

- (void)		setColorForUndefinedSelection:(NSColor*) colour;
- (void)		setShowsInfo:(BOOL) si;

@end

enum
{
	kGCColourPickerModeSwatches = 0,
	kGCColourPickerModeSpectrum = 1
};
