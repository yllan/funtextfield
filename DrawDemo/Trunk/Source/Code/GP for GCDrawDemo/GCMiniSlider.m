//
//  GCMiniSlider.m
//  panel
//
//  Created by Graham on Thu Apr 12 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCMiniSlider.h"

#import "GCGradientPanel.h"
#import "NSBezierPath+GCAdditions.h"


@implementation GCMiniSlider
#pragma mark As a GCMiniSlider
- (void)		setShowTickMarks:(BOOL) ticks
{
	if ( ticks != mShowTicks )
	{
		mShowTicks = ticks;
		[self setNeedsDisplay];
	}
}


- (BOOL)		showTickMarks
{
	return mShowTicks;
}


#pragma mark -
- (NSRect)		knobRect
{
	NSRect	kr = NSInsetRect([self bounds], kMiniSliderEndCapWidth, 1 );
	
	float length = [self bounds].size.width - ( kMiniSliderEndCapWidth * 2 );
	
	kr.size = [mKnobImage size];
	kr.origin.x += ([self value] * length ) - ( kr.size.width / 2.0 );
	kr.origin.y = NSMidY([self bounds]) - ( kr.size.height / 2.0 );
	
	return kr;
}


#pragma mark -
#pragma mark As a GCMiniControl
- (void)		draw
{
	NSBezierPath* path = [NSBezierPath bezierPathWithRoundEndedRectInRect:[self bounds]];
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	
	[self applyShadow];									
	[[self themeColour:kGCMiniControlThemeBackground] set];
	[path fill];
	[[NSGraphicsContext currentContext] restoreGraphicsState];

	[[self themeColour:kGCMiniControlThemeSliderTrack] set];
	
	NSPoint sp, ep;
	
	sp.x = NSMinX([self bounds]) + kMiniSliderEndCapWidth;
	sp.y = NSMidY([self bounds]);
	ep.x = NSMaxX([self bounds]) - kMiniSliderEndCapWidth;
	ep.y = NSMidY([self bounds]);
	
	[NSBezierPath setDefaultLineWidth:0.5];
	[NSBezierPath strokeLineFromPoint:sp toPoint:ep];
	
	sp.y += 1.0;
	ep.y += 1.0;
	
	[[self themeColour:kGCMiniControlThemeSliderTrkHilite] set];
	[NSBezierPath strokeLineFromPoint:sp toPoint:ep];
	
	// position and draw the knob
	
	[mKnobImage drawInRect:[self knobRect] fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:[[self cluster] alpha]];
}


- (int)			hitTestPoint:(NSPoint) p
{
	int ph = [super hitTestPoint:p];
	
	if ( ph == kGCMiniControlEntireControl )
	{
		if ( NSPointInRect( p, [self knobRect]))
			ph = kGCMiniSliderKnob;
	}
	
	return ph;
}


- (id)			initWithBounds:(NSRect) rect inCluster:(GCMiniControlCluster*) clust
{
	self = [super initWithBounds:rect inCluster:clust];
	if (self != nil)
	{
		//mKnobImage = [[NSImage imageNamed:@"smallBlueKnob"] retain];
		
		mKnobImage = [[self imageNamed:@"smallBlueKnob" fromBundleForClass:[self class]] retain];

		NSAssert(!mShowTicks, @"Expected init to zero");
		
		if (mKnobImage == nil)
		{
			[self autorelease];
			self = nil;
		}
	}
	if (self != nil)
	{
		[mKnobImage setFlipped:YES];
	}
	return self;
}


- (BOOL)		mouseDownAt:(NSPoint) startPoint inPart:(int) part modifierFlags:(int) flags
{
#pragma unused (flags)
	if ( part == kGCMiniSliderKnob )
		[self setupInfoWindowAtPoint:startPoint withValue:[self value] andFormat:nil];
	return ( part == kGCMiniSliderKnob );
}


- (BOOL)		mouseDraggedAt:(NSPoint) currentPoint inPart:(int) part modifierFlags:(int) flags
{
	// recalculate the value based on the position of the knob
	
	float val = ( currentPoint.x - ( NSMinX([self bounds]) + kMiniSliderEndCapWidth )) / ([self bounds].size.width - ( kMiniSliderEndCapWidth * 2 ));
	
	[super mouseDraggedAt:currentPoint inPart:part modifierFlags:flags];
	
	[self setNeedsDisplayInRect:[self knobRect]];
	[self setValue:val];
	[self setNeedsDisplayInRect:[self knobRect]];
	
	return YES;
}


#pragma mark -
#pragma mark As an NSObject
- (void)		dealloc
{
	[mKnobImage release];
	
	[super dealloc];
}


@end
