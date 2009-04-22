//
//  GCMiniControl.m
//  panel
//
//  Created by Graham on Thu Apr 12 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCMiniControl.h"
#import "GCMiniControlCluster.h"
#import "GCDrawKit/GCInfoFloater.h"
#import <GCDrawKit/LogEvent.h>


@implementation GCMiniControl
#pragma mark As a GCMiniControl
+ (NSColor*)	miniControlThemeColor:(int) themeElementID withAlpha:(float) alpha
{
	switch( themeElementID )
	{
		case kGCMiniControlThemeBackground:
			return [[NSColor lightGrayColor] colorWithAlphaComponent:0.25 * alpha];

		case kGCMiniControlThemeSliderTrack:
			return [[NSColor blackColor] colorWithAlphaComponent:0.67 * alpha];
			
		case kGCMiniControlThemeSliderTrkHilite:
			return [[NSColor lightGrayColor] colorWithAlphaComponent:0.67 * alpha];
		
		case kGCMiniControlThemeKnobInterior:
			return [[NSColor grayColor] colorWithAlphaComponent:0.5 * alpha];
		
		case kGCMiniControlThemeKnobStroke:
			return [[NSColor whiteColor] colorWithAlphaComponent:0.67 * alpha];
		
		case kGCMiniControlThemeIris:
			return [[NSColor lightGrayColor] colorWithAlphaComponent:0.33 * alpha];

		default:
			return nil;
	}
}


#pragma mark -
- (id)			initWithBounds:(NSRect) rect inCluster:(GCMiniControlCluster*) clust
{
	self = [super init];
	if (self != nil)
	{
		[self setBounds:rect];
		mClusterRef = clust;
		NSAssert(mIdent == nil, @"Expected init to zero");
		NSAssert(mDelegateRef == nil, @"Expected init to zero");
		mInfoWin = [[GCInfoFloater infoFloater] retain];
		
		NSAssert(mValue == 0.0, @"Expected init to zero");
		NSAssert(mMinValue == 0.0, @"Expected init to zero");
		mMaxValue = 1.0;
		NSAssert(mInfoWMode == kGCMiniControlNoInfoWindow, @"Expected init to zero");
		mApplyShadow = YES;
		
		if (mInfoWin == nil)
		{
			[self autorelease];
			self = nil;
		}
	}if (self != nil)
	{
		if ( clust != nil)
		{
			[clust addMiniControl:self];
		}
	}
	return self;
}


- (void)				setCluster:(GCMiniControlCluster*) clust
{
	mClusterRef = clust;   // not retained; cluster retains this
}


- (GCMiniControlCluster*) cluster
{
	return mClusterRef;
}


- (NSView*)		view
{
	return [[self cluster] view];
}


#pragma mark -
- (void)		setBounds:(NSRect) rect
{
	mBounds = rect;
}


- (NSRect)		bounds
{
	return mBounds;
}


- (void)		draw
{
	// override to do something
}


#pragma mark -
- (void)		applyShadow
{
	if ( mApplyShadow )
	{
		NSShadow*	shadowObj = [[[NSShadow alloc] init] autorelease];
		
		[shadowObj setShadowColor:[NSColor blackColor]];
		[shadowObj setShadowOffset:NSMakeSize( 2, -2 )];
		[shadowObj setShadowBlurRadius:1.0];
		[shadowObj set];
	}
}


#pragma mark -
- (void)		setNeedsDisplay
{
	// relies on the delegate implementing setNeedsDisplayInRect: there is no guarantee that this will actually
	// cause a redraw - you need to set it up to work. 
	
	[self setNeedsDisplayInRect:[self bounds]];
}


- (void)		setNeedsDisplayInRect:(NSRect) rect
{
	// relies on the delegate implementing setNeedsDisplayInRect: there is no guarantee that this will actually
	// cause a redraw - you need to set it up to work. 
	
	if ([self view])
		[[self view] setNeedsDisplayInRect:rect];
	else if ([self delegate] && [[self delegate] respondsToSelector:@selector(setNeedsDisplayInRect:)])
		[[self delegate] setNeedsDisplayInRect:rect];
}


#pragma mark -
- (NSColor*)	themeColour:(int) themeElementID
{
	// returns theme colour but applies local value of alpha
	
	return [[self class] miniControlThemeColor:themeElementID withAlpha:[[self cluster] alpha]];
}


#pragma mark -
- (int)			hitTestPoint:(NSPoint) p
{
	return ( NSPointInRect( p, [self bounds]))? kGCMiniControlEntireControl : kGCMiniControlNoPart;
}


#pragma mark -
- (BOOL)		mouseDownAt:(NSPoint) startPoint inPart:(int) part modifierFlags:(int) flags
{
#pragma unused (flags)
	// override to do something, call super to handle info windows
	
//	LogEvent_(kReactiveEvent, @"mini-control mouse down, part = %d", part);
	
	if ( part != kGCMiniControlNoPart )
	{
		[self setupInfoWindowAtPoint:startPoint withValue:[self value] andFormat:nil];
		return YES;
	}
	else
		return NO;
}


- (BOOL)		mouseDraggedAt:(NSPoint) currentPoint inPart:(int) part modifierFlags:(int) flags
{
#pragma unused (part, flags)
	// override to do something, call super to handle info windows
	
	[self updateInfoWindowAtPoint:currentPoint withValue:[self value]];
	return YES;
}


- (void)		mouseUpAt:(NSPoint) endPoint inPart:(int) part modifierFlags:(int) flags
{
#pragma unused (endPoint, part, flags)
	// override to do something, call super to handle info windows
//	LogEvent_(kReactiveEvent, @"mini-control mouse up, part = %d", part);
	[self hideInfoWindow];
}


- (void)		flagsChanged:(int) flags
{
#pragma unused (flags)
	// override to do something
	
//	LogEvent_(kInfoEvent, @"mini-control flags changed, flags = %d", flags);
}


#pragma mark -
- (void)		setInfoWindowMode:(int) mode
{
	mInfoWMode = mode;
}


- (void)		setupInfoWindowAtPoint:(NSPoint) p withValue:(float) val andFormat:(NSString*) format
{
	if ( mInfoWMode != kGCMiniControlNoInfoWindow )
	{
		if ( mInfoWin == nil )
			mInfoWin = [[GCInfoFloater infoFloater] retain];
		
		if ( format )
			[self setInfoWindowFormat:format];
			
		[self updateInfoWindowAtPoint:p withValue:val];
		[mInfoWin orderFront:self];
	}
}


#pragma mark -
- (void)		updateInfoWindowAtPoint:(NSPoint) p withValue:(float) val
{
	// let delegate have opportunity to set this value
	
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(miniControlWillUpdateInfoWindow:withValue:)])
		val = [[self delegate] miniControlWillUpdateInfoWindow:self withValue:val];
	
	[mInfoWin setFloatValue:val];
	
	if ( mInfoWMode == kGCMiniControlInfoWindowFollowsMouse )
		[mInfoWin positionNearPoint:p inView:[self view]];
	else if ( mInfoWMode == kGCMiniControlInfoWindowCentred )
	{
		// position window above and centred horizontally in bounds
	
		NSRect	wfr = [mInfoWin frame];
		NSRect	br = [self bounds];
		NSPoint	wp;
		
		wp.x = (( NSMinX( br ) + NSMaxX( br )) / 2.0 ) - ( NSWidth( wfr ) / 2.0 );
		wp.y = NSMinY( br ) - 2;//NSHeight( wfr );
		
		[mInfoWin positionNearPoint:wp inView:[self view]];
	}
}


- (void)		hideInfoWindow
{
	[mInfoWin hide];
}


- (void)		setInfoWindowFormat:(NSString*) format
{
	[mInfoWin setFormat:format];
}


- (void)		setInfoWindowValue:(float) value
{
	[mInfoWin setFloatValue:value];
}


#pragma mark -
- (void)		setDelegate:(id) del
{
	mDelegateRef = del;
}


- (id)			delegate
{
	// return the delegate if we have one, otherwise use the cluster's delegate
	
	if ( mDelegateRef )
		return mDelegateRef;
	else
		return [[self cluster] delegate];
}


- (void)		notifyDelegateWillChange:(id) value
{
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(miniControl:willChangeValue:)])
		[[self delegate] miniControl:self willChangeValue:value];
}


- (void)		notifyDelegateDidChange:(id) value
{
	if ([self delegate] && [[self delegate] respondsToSelector:@selector(miniControl:didChangeValue:)])
		[[self delegate] miniControl:self didChangeValue:value];
}


#pragma mark -
- (void)		setIdentifier:(NSString*) name
{
	// stores the control against <name> in the owning cluster, so it can easily be located by name
	
	[name retain];
	[mIdent release];
	mIdent = name;
	[[self cluster] setControl:self forKey:name];
}


- (NSString*)	identifier
{
	return mIdent;
}


#pragma mark -
- (void)		setValue:(float) v
{
	v = MAX( v, [self minValue]);
	v = MIN( v, [self maxValue]);
	
	if ( v != mValue )
	{
		[self notifyDelegateWillChange:[NSNumber numberWithFloat:mValue]];
		mValue = v;
		[self notifyDelegateDidChange:[NSNumber numberWithFloat:mValue]];
	}
}


- (float)		value
{
	return mValue;
}


#pragma mark -
- (void)		setMaxValue:(float) v
{
	mMaxValue = v;
	
	if ( mValue > mMaxValue )
		[self setValue:mMaxValue];
}


- (float)		maxValue
{
	return mMaxValue;
}


#pragma mark -
- (void)		setMinValue:(float) v
{
	mMinValue = v;
	
	if ( mValue < mMinValue )
		[self setValue:mMinValue];
}


- (float)		minValue
{
	return mMinValue;
}


#pragma mark -
#pragma mark As an NSObject
- (void)		dealloc
{
	[mInfoWin release];
	[mIdent release];
	
	[super dealloc];
}


@end



/*
@implementation  NSObject (GCMiniControlDelegate)

- (void)		miniControl:(GCMiniControl*) mc willChangeValue:(id) newValue
{
	LogEvent_(kReactiveEvent, @"miniControl '%@' willChangeValue '%@'", mc,  newValue);
}


- (void)		miniControl:(GCMiniControl*) mc didChangeValue:(id) newValue
{
	LogEvent_(kReactiveEvent, @"miniControl '%@' didChangeValue '%@'", mc,  newValue);
}

@end
*/

