//
//  DKGradientCell.h
//  GradientTest
//
//  Created by Jason Jobe on 4/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class DKGradient;


@interface DKGradientCell : NSImageCell
{
	DKGradient*				mGradient;
	id						mTargetRef;
	SEL						mAction;
	NSSize					mInset;
	BOOL					mEnableCache;
}


- (DKGradient*)		gradient;
- (void)			setGradient:(DKGradient*) grad;

- (void)			setInset:(NSSize) inset;
- (NSSize)			inset;

- (void)			invalidateCache;
- (NSImage*)		cachedImageForSize:(NSSize) size;
- (NSImage*)		makeCacheImageWithSize:(NSSize) size;

- (void)			gradientDidChange:(NSNotification*) note;
- (void)			gradientWillChange:(NSNotification*) note;

@end


#define kGCDefaultGradientCellInset		(NSMakeSize( 8.0, 8.0 ))


@interface NSObject (GradientDragging)

- (void)			dragProxyIconAtPoint:(NSPoint) startPoint fromControl:(NSControl*) control;
- (void)			initiateGradientDragWithEvent:(NSEvent*) event;

@end
