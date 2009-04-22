//
//  GCMiniSlider.h
//  panel
//
//  Created by Graham on Thu Apr 12 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCMiniControl.h"


@interface GCMiniSlider : GCMiniControl
{
	NSImage*	mKnobImage;
	BOOL		mShowTicks;
}


- (void)		setShowTickMarks:(BOOL) ticks;
- (BOOL)		showTickMarks;

- (NSRect)		knobRect;

@end



enum
{
	kGCMiniSliderKnob   = 2
};


#define kMiniSliderEndCapWidth  10
