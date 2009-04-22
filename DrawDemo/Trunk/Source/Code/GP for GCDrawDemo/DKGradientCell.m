//
//  DKGradientCell.m
//  GradientTest
//
//  Created by Jason Jobe on 4/12/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DKGradientCell.h"

#import "GCDrawKit/DKGradient.h"
#import "GCGradientWell.h"
#import "NSBezierPath+GCAdditions.h"
#import <GCDrawKit/LogEvent.h>


@implementation DKGradientCell
#pragma mark As a DKGradientCell
- (void)		setGradient:(DKGradient*) value
{
	if ( value != [self gradient])
	{
		[self setInset:kGCDefaultGradientCellInset];
		mEnableCache = YES;

		[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:mGradient];
		[mGradient tearDownKVOForObserver:self];
		[value retain];
		[mGradient release];
		mGradient = value;
		[mGradient setUpKVOForObserver:self];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gradientDidChange:) name:kGCNotificationGradientDidAddColorStop object:mGradient];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gradientDidChange:) name:kGCNotificationGradientDidRemoveColorStop object:mGradient];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gradientWillChange:) name:kGCNotificationGradientWillAddColorStop object:mGradient];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gradientWillChange:) name:kGCNotificationGradientWillRemoveColorStop object:mGradient];
		
		[self invalidateCache];
	}
}


- (DKGradient*)	gradient
{
	return mGradient;
}


#pragma mark -
- (void)		setInset:(NSSize) inset
{
	mInset = inset;
}


- (NSSize)		inset
{
	return mInset;
}


#pragma mark -
- (void)		invalidateCache
{
	//LogEvent_(kReactiveEvent, @"invalidating cache");
	[self setObjectValue:nil];
}


- (NSImage*)	cachedImageForSize:(NSSize) size
{
	NSImage *img = [self image];
	if (img == nil)
	{
		img = [self makeCacheImageWithSize:size];
		[img setScalesWhenResized:YES];
		[self setObjectValue: img];
	}
	return img;
}


- (NSImage*)	makeCacheImageWithSize:(NSSize) size
{
	// creates an image of the current gradient for rendering in this cell as a cache. Note that the swatch method
	// of the gradient itself does not include the chequered background
	
	NSImage *swatchImage = [[NSImage alloc] initWithSize:size];
	NSRect box = NSMakeRect(0.0, 0.0, size.width, size.height);
	[swatchImage setFlipped:YES];
	
	[swatchImage lockFocus];
	[[self gradient] fillRect:box];
	[swatchImage unlockFocus];
	
	return [swatchImage autorelease];
}


#pragma mark -
- (void)		gradientDidChange:(NSNotification*) note
{
#pragma unused (note)
	[self invalidateCache];
	[mGradient setUpKVOForObserver:self];
}


- (void)		gradientWillChange:(NSNotification*) note
{
#pragma unused (note)
	[mGradient tearDownKVOForObserver:self];
}


#pragma mark -
#pragma mark As an NSCell
- (SEL)			action
{
	return mAction;
}


- (void)		drawInteriorWithFrame:(NSRect) cellFrame inView:(NSView*) controlView
{
	if ([self gradient])
	{
		static NSImage* pat = nil;
		
		if ( pat == nil )
		{
			NSString *imres = [[NSBundle bundleForClass:[self class]] pathForImageResource:@"chequered"];
			pat = [[NSImage alloc] initByReferencingFile:imres];
		}
		
		if ( pat )
		{
			NSColor* pp = [NSColor colorWithPatternImage:pat];
			
			[pp set];
			NSRectFill( NSInsetRect( cellFrame, mInset.width, mInset.height ));
		}
		
		if ( mEnableCache )
		{
			[self cachedImageForSize:cellFrame.size];
			[super drawInteriorWithFrame:cellFrame inView:controlView];
		}
		else
		{
			[super drawInteriorWithFrame:cellFrame inView:controlView];
			[[self gradient] fillRect:NSInsetRect( cellFrame, mInset.width, mInset.height )];
		}
	}
}


- (void)		drawWithFrame:(NSRect) cellFrame inView:(NSView *) controlView
{
	// if active, draw the "active" hilite
	
	[super drawWithFrame:cellFrame inView:controlView];

	if([controlView isKindOfClass:[GCGradientWell class]])
	{
		if ([(GCGradientWell*)controlView isActiveWell])
		{
			NSBezierPath* rr = [NSBezierPath roundRectInRect:NSInsetRect( cellFrame, 2, 2 ) andCornerRadius:5];
			
			[rr setLineWidth:3];
			
			[[NSColor colorForControlTint:[NSColor currentControlTint]] set];
			[rr stroke];
		}
	}

}


- (void)		setAction:(SEL) action
{
	mAction = action;
}


- (void)		setTarget:(id) target
{
	mTargetRef = target;
}


- (id)			target
{
	return mTargetRef;
}


- (BOOL)		trackMouse:(NSEvent*) theEvent inRect:(NSRect) cellFrame ofView:(NSView*) controlView untilMouseUp:(BOOL) untilMouseUp
{
#pragma unused (cellFrame, untilMouseUp)
	NSPoint p = [controlView convertPoint:[theEvent locationInWindow] fromView:nil];
	
	if ([self startTrackingAt:p inView:controlView])
	{
		unsigned int	mask;
		NSEvent*		event;
		BOOL			loop = YES;
		NSPoint			currentPoint, lastPoint;
		
		mEnableCache = NO;
		mask = NSLeftMouseUpMask | NSLeftMouseDraggedMask;
		lastPoint = p;
		
		while( loop )
		{
			event = [[controlView window] nextEventMatchingMask:mask];
			
			currentPoint = [controlView convertPoint:[event locationInWindow] fromView:nil];
			
			switch([event type])
			{
				case NSLeftMouseUp:
					[self stopTracking:lastPoint at:currentPoint inView:controlView mouseIsUp:YES];
					loop = NO;
					
					// set active if allowed to become (default is YES)
					
					if([[self controlView] isKindOfClass:[GCGradientWell class]])
						[(GCGradientWell*)[self controlView] toggleActiveWell];
					break;
					
				case NSLeftMouseDragged:
					loop = NO;
					[self stopTracking:lastPoint at:currentPoint inView:controlView mouseIsUp:NO];
					[controlView initiateGradientDragWithEvent:theEvent];
					break;
					
				default:
					break;
			}
			
			lastPoint = currentPoint;
		}
		[[controlView window] discardEventsMatchingMask:mask beforeEvent:event];
		mEnableCache = YES;
	}
	
	return YES;
}


#pragma mark -
#pragma mark As an NSObject
- (void) dealloc
{
	[mGradient release];
	
	[super dealloc];
}


- (id)	init
{
	self = [super initImageCell:nil];
	if (self != nil)
	{
		NSAssert(mGradient == nil, @"Expected init to zero");
		NSAssert(mTargetRef == nil, @"Expected init to zero");
		NSAssert(mAction == nil, @"Expected init to zero");
		[self setInset:kGCDefaultGradientCellInset];
		mEnableCache = YES;
	}
	if (self != nil)
	{
		[self setContinuous:YES];
		[self setImageFrameStyle:NSImageFrameGrayBezel];
		[self setImageScaling:NSScaleToFit];
	}
	return self;
}


#pragma mark -
#pragma mark As part of NSKeyValueObserving Protocol
- (void)		observeValueForKeyPath:(NSString*)keypath ofObject:(id) object change:(NSDictionary*) change context:(void*) context
{
#pragma unused (keypath, object, change, context)
	[self invalidateCache];
}


@end
