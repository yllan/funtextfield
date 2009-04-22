//
//  GCMiniControlCluster.m
//  panel
//
//  Created by Graham on Thu Apr 12 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCMiniControlCluster.h"


@implementation GCMiniControlCluster
#pragma mark As a GCMiniControlCluster
- (void)				addMiniControl:(GCMiniControl*) mc
{
	if (! [mControls containsObject:mc])
	{
		[mControls addObject:mc];
		[mc setCluster:self];
	}
}


- (void)				removeMiniControl:(GCMiniControl*) mc
{
	[mControls removeObject:mc];
}


- (NSArray*)			controls
{
	return mControls;
}


- (GCMiniControl*)		controlAtIndex:(int) n
{
	return [[self controls] objectAtIndex:n];
}


#pragma mark -
- (void)				setControl:(GCMiniControl*) ctrl forKey:(NSString*) key
{
	[mControlNames setObject:ctrl forKey:key];
}


- (GCMiniControl*)		controlForKey:(NSString*) key
{
	// looks for the key in local dict. If not there, looks for subclusters and asks them to look
	
	GCMiniControl*	mc = [mControlNames objectForKey:key];
	
	if ( mc == nil )
	{
		NSEnumerator* iter = [[self controls] objectEnumerator];
		 
		 while( (mc = [iter nextObject]) != nil)
		 {
			if ([mc isKindOfClass:[GCMiniControlCluster class]])
			{
				mc = [(GCMiniControlCluster*)mc controlForKey:key];
				
				if ( mc )
					break;
			}
		 }
	}

	return mc;
}


#pragma mark -
- (void)				setVisible:(BOOL) vis
{
	if ( vis )
	{
		[mCATimerRef invalidate];
		mCATimerRef = nil;
		[self setAlpha:1.0];
		mVisible = YES;
	}
	else if ( mVisible )
	{
		// trigger a fadeout which will set visible to NO at the end
		
		[self fadeControlAlphaWithTimeInterval:0.15];
	}
}


- (void)				forceVisible:(BOOL) vis
{
	// sets visible state directly without fade effect
	
	mVisible = vis;
	if ( vis )
		[self setAlpha:1.0];
}


- (BOOL)				visible
{
	if ([self cluster])
		return [[self cluster] visible];
	else	
		return mVisible;
}


#pragma mark -
- (void)				setView:(NSView*) view
{
	mViewRef = view;	// not retained
}


#pragma mark -
- (void)				setAlpha:(float) alpha
{
	mControlAlpha = alpha;
	[self setNeedsDisplay];
}


- (float)				alpha
{
	if ([self cluster])
		return [[self cluster] alpha];
	else
		return mControlAlpha;
}


- (void)				fadeControlAlphaWithTimeInterval:(NSTimeInterval) t
{
	
	if ( mCATimerRef == nil )
	{
		mFadeStartTime = [NSDate timeIntervalSinceReferenceDate];
		
		mCATimerRef = [NSTimer scheduledTimerWithTimeInterval:1/30.0
					target:self
					selector:@selector(timerFadeCallback:)
					userInfo:[NSNumber numberWithDouble:t]
					repeats:YES];
	}
}


- (void)				timerFadeCallback:(NSTimer*) timer
{
	NSTimeInterval total = [[timer userInfo] doubleValue];
	NSTimeInterval elapsed = [NSDate timeIntervalSinceReferenceDate] - mFadeStartTime;
	
	[self setAlpha:1.0 - ( elapsed / total )];
	
	if ( elapsed >= total )
	{
		[timer invalidate];
		mCATimerRef = nil;
		mVisible = NO;
	}
}


#pragma mark -
- (void)				setLinkControlPart:(int) partcode modifierKeyMask:(int) mask
{
	// this allows certain special behaviours when modifier keys are pressed for mouse operations on the cluster.
	// If the partcode is detected as being hit and the modifier flags match mask, all controls in the cluster will
	// receive mouse down/dragged/up messages together, whoever originally reported the hit. Set nopart to disable.
	
	// Note: this feature is largely untested in general - it was provided for the particular purpose of allowing
	// shift-drag of radial controls. YHBW.

	mLinkPart = partcode;
	mLinkModFlagsMask = mask;
}


#pragma mark -
#pragma mark As a GCMiniControl
- (NSRect)				bounds
{
	// clusters return the union of the bounds of their controls
	
	NSEnumerator*   iter = [[self controls] objectEnumerator];
	NSRect			r = NSZeroRect;
	GCMiniControl*  ctl;
	
	while( (ctl = [iter nextObject]) != nil)
		r = NSUnionRect( r, [ctl bounds]);
		
	return r;
}


- (void)				flagsChanged:(int) flags
{
	// propagate to all controls in the cluster

	NSEnumerator*	iter = [[self controls] objectEnumerator];
	GCMiniControl*	mc;
	
	while( (mc = [iter nextObject]) != nil)
		[mc flagsChanged:flags];
}


- (void)				draw
{
	// draws all the controls if visible
	
	if ([self visible])
		[[self controls] makeObjectsPerformSelector:@selector(draw)];
}


- (int)					hitTestPoint:(NSPoint) p
{
	// hit test all owned controls, returning the partcode resulting. If this is not 0, this also
	// sets mHitTarget to the control hit. This hit tests in reverse order in case controls overlap.
	
	NSEnumerator*   iter = [[self controls] reverseObjectEnumerator];
	GCMiniControl*  ctl;
	int				pc;
	
	while( (ctl = [iter nextObject]) != nil)
	{
		pc = [ctl hitTestPoint:p];
		
		if ( pc != kGCMiniControlNoPart )
		{
			mHitTarget = ctl;
			return pc;
		}
	}
	
	return kGCMiniControlNoPart;
}


- (id)					initWithBounds:(NSRect) rect inCluster:(GCMiniControlCluster*) clust
{
	self = [super initWithBounds:rect inCluster:clust];
	if (self != nil)
	{
		mControls = [[NSMutableArray alloc] init];
		mControlNames = [[NSMutableDictionary alloc] init];
		NSAssert(mCATimerRef == nil, @"Expected init to zero");
		NSAssert(mViewRef == nil, @"Expected init to zero");
		NSAssert(mHitTarget == nil, @"Expected init to zero");
		NSAssert(mFadeStartTime == 0.0, @"Expected init to zero");
		
		mControlAlpha = 1.0;
		NSAssert(mHitPart == kGCMiniControlNoPart, @"Expected init to zero");
		NSAssert(mLinkPart == kGCMiniControlNoPart, @"Expected init to zero");
		NSAssert(mLinkModFlagsMask == 0, @"Expected init to zero");
		mVisible = YES;
		
		if (mControls == nil 
				|| mControlNames == nil)
		{
			[self autorelease];
			self = nil;
		}
	}
	return self;
}


- (BOOL)				mouseDownAt:(NSPoint) startPoint inPart:(int) part modifierFlags:(int) flags
{
#pragma unused (part)
	// determine which control was hit and what part. This will be used for subsequent
	// tracking of the mouse in that control. If the cluster is not visible, does nothing and returns
	// NO. Otherwise returns YES if there was a valid hit, NO otherwise.
	
	if ([self visible])
	{
		mHitPart = [self hitTestPoint:startPoint];
	
		if ( mHitPart == kGCMiniControlNoPart )
			return NO;
		else
		{
			if ( mLinkPart == mHitPart )
			{
				// detected a linkage - send all objects the mouse down.
				
				NSEnumerator*   iter = [[self controls] objectEnumerator];
				GCMiniControl*  mc;
				
				while( (mc = [iter nextObject]) != nil)
					[mc mouseDownAt:startPoint inPart:mHitPart modifierFlags:flags];
					
				return YES;
			}
			else
				return [mHitTarget mouseDownAt:startPoint inPart:mHitPart modifierFlags:flags];
		}
	}
	
	return NO;
}


- (BOOL)				mouseDraggedAt:(NSPoint) currentPoint inPart:(int) part modifierFlags:(int) flags
{
#pragma unused (part)
	// track the mouse in the current hit target with the part established by the mouse down. The
	// value of <part> passed here is ignored. return YES to continue tracking, NO otherwise.
	
	if ([self visible] && mHitTarget )
	{
		if (( mLinkPart == mHitPart ) && (( flags & mLinkModFlagsMask ) != 0 ))
		{
			// detected a linkage - send all objects the mouse drag if the mask is also matched
			
			NSEnumerator*   iter = [[self controls] objectEnumerator];
			GCMiniControl*  mc;
			
			while( (mc = [iter nextObject]) != nil)
				[mc mouseDraggedAt:currentPoint inPart:mHitPart modifierFlags:flags];
				
			return YES;
		}
		else
			return [mHitTarget mouseDraggedAt:currentPoint inPart:mHitPart modifierFlags:flags];
	}
	else
		return NO;
}


- (void)				mouseUpAt:(NSPoint) endPoint inPart:(int) part modifierFlags:(int) flags
{
#pragma unused (part)
	if ([self visible] && mHitTarget )
	{
		if ( mLinkPart == mHitPart )
		{
			NSEnumerator*   iter = [[self controls] objectEnumerator];
			GCMiniControl*  mc;
			
			while( (mc = [iter nextObject]) != nil)
				[mc mouseUpAt:endPoint inPart:mHitPart modifierFlags:flags];
		}
		else
			[mHitTarget mouseUpAt:endPoint inPart:mHitPart modifierFlags:flags];
	}	
	
	mHitTarget = nil;
}


- (NSView*)				view
{
	if ( mViewRef )
		return mViewRef;
	else
		return [super view];
}


#pragma mark -
#pragma mark As an NSObject
- (void)				dealloc
{
	[mControlNames release];
	[mControls release];
	
	[super dealloc];
}


@end
