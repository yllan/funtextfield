///**********************************************************************************************************************************
///  WTGradientControl.m
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

#import "WTGradientControl.h"

#import "GCColourPickerView.h"
#import "GCGradientPasteboard.h"
#import "GCSpecialColorWell.h"
#import "GCWindowMenu.h"

#import "GCDrawKit/GCInfoFloater.h"
#import "GCDrawKit/DKGradient+UISupport.h"
#import <GCDrawKit/LogEvent.h>


@implementation WTGradientControl
#pragma mark As a WTGradientControl
- (void)		colorWellActivation:(NSNotification*) note
{
#pragma unused (note)
	// when any well activates, deselect any stop

	[self setSelectedStop:nil];
}


- (void)		drawStop:(DKColorStop*) stop inRect:(NSRect) rect state:(int) st
{
	int inset = MAX( 2, rect.size.height / 8 );
	NSRect	inner = [self centerScanRect:NSInsetRect( rect, inset, inset )];
	
	rect = [self centerScanRect:rect];
	
	switch( st )
	{
		case kGCInactiveState:
		case kGCNormalState:
			[[DKGradient aquaNormalGradient] fillRect:rect];
			break;
	
		case kGCPressedState:
			[[DKGradient aquaPressedGradient] fillRect:rect];
			break;
	
		case kGCSelectedState:
			[[DKGradient aquaSelectedGradient] fillRect:rect];
			break;
			
		default:
			break;
	}
	
	[[stop color] drawSwatchInRect:inner];

	if ( st == kGCInactiveState )
		[[NSColor lightGrayColor] set];
	else
		[[NSColor darkGrayColor] set];
	NSFrameRectWithWidth( rect, 1.0 );
	NSFrameRectWithWidth( inner, 1.0 );
}


- (void)		externalStopChange:(NSNotification*) note
{
	if([note object] == [self gradient])
	{
	//	LogEvent_(kUserEvent, @"external change to stops");
		
		[self invalidate];
		[mUnsortedStops setArray:[[self gradient] colorStops]];
		[self setNeedsDisplay:YES];
	}
}


- (void)		interpolation:(id) sender
{
	[[self gradient] setGradientInterpolation:[sender tag]];
	[self syncGradientToControlSettings];
	[self setNeedsDisplay:YES];
}


- (float)		relativeXWithPoint:(NSPoint) pt
{
	NSRect bounds = [self interior];
	float gPos = ((pt.x - bounds.origin.x) / bounds.size.width);
	
	gPos = MIN( 1.0, gPos );
	return MAX( 0.0, gPos );
}


#pragma mark -
- (void)		setGradient:(DKGradient*) aGradient
{
	if (aGradient != [self gradient])
	{
		[super setGradient:aGradient];
		[self setSelectedStop:nil];
		mDragStopRef = nil;
		
		// copy initial set of stops to the unsorted stops array
		
		[mUnsortedStops setArray:[aGradient colorStops]];
	}
	else
		[self setNeedsDisplay:YES];
	[self invalidate];
}


#pragma mark -
- (void)		removeColorStopAtPoint:(NSPoint) point
{
	DKColorStop *stop = [self stopAtPoint:point];
	if (stop)
	{
		[mUnsortedStops removeObject:stop];
		[self invalidate];
		[[self gradient] removeColorStop:stop];
		[self syncGradientToControlSettings];
		[self setNeedsDisplay:YES];
	}
}


- (DKColorStop*) addColorStop:(NSColor*) color atPoint:(NSPoint) point
{
	DKColorStop *stop = [self stopAtPoint:point];
	if (stop)
	{
		[stop setColor:color];
		[self syncGradientToControlSettings];
	}
	else
	{
		float gPos = [self relativeXWithPoint:point];
		
		[self setNeedsDisplay:YES];
		if (color == nil)
			color = [[self gradient] colorAtValue:gPos];
		
		stop = [[self gradient] addColor:color at:gPos];
		//[mUnsortedStops addObject:stop];
		[self invalidate];
		[self syncGradientToControlSettings];
	}
	return stop;
}


- (NSColor*)	colorAtPoint:(NSPoint) point
{
	float gPos = [self relativeXWithPoint:point];
	return [[self gradient] colorAtValue:gPos];
}


#pragma mark -
- (NSRect)		swatchBoxAtPosition:(float) position
{
	NSRect box;
	NSRect bounds = [self interior];
	
	box.size.height = bounds.size.height;// / 2;
	box.size.width = 17;//box.size.height * 0.5;
	
	box.origin.x = bounds.origin.x + (bounds.size.width * position - (box.size.width / 2));
	box.origin.y = NSMinY( bounds ); //(box.size.height / 2);

	return box;
}


- (NSArray*)		allSwatchBoxes
{
	if ( mSBArray == nil )
	{
		mSBArray = [[NSMutableArray alloc] init];
	
		NSEnumerator*		iter = [mUnsortedStops objectEnumerator];
		DKColorStop*		stop;
		NSRect				r, rn, swr;
		NSMutableIndexSet*  hits;
		
		while( (stop = [iter nextObject]) != nil)
		{
			r = [self swatchBoxAtPosition:[stop position]];
			[mSBArray addObject:[NSValue valueWithRect:r]];
		}
		
		hits = [[NSMutableIndexSet alloc] init];
		swr = [self swatchBoxAtPosition:0.0];   // original rect height and origin
		
		unsigned i, k;
		
		for( i = 0; i < [mSBArray count]; ++i )
		{
			r = [[mSBArray objectAtIndex:i] rectValue];
			
			[hits removeAllIndexes];
			[hits addIndex:i];
			
			for( k = 0; k < [mSBArray count]; ++k )
			{
				if ( i != k )
				{
					rn = [[mSBArray objectAtIndex:k] rectValue];
					
					//rn.size.height = swr.size.height;
					//rn.origin.y = swr.origin.y;
					
					if ( NSIntersectsRect( r, rn ))
					{
						// collision, make note of its index
						[hits addIndex:k];
						r = rn;
					}
				}
			}
			
			// if any hits, need to adjust all indicated rects
			
			if ([hits count] > 1)
			{
				float height = swr.size.height / [hits count];
				float yorigin = swr.origin.y;
			
				int j;
				
				j = [hits firstIndex];
				
				do
				{
					r = [[mSBArray objectAtIndex:j] rectValue];
					
					r.size.height = height;
					r.origin.y = yorigin;
					
					yorigin += height;
				
					[mSBArray replaceObjectAtIndex:j withObject:[NSValue valueWithRect:r]];

					j = [hits indexGreaterThanIndex:j];
				}
				while( j != NSNotFound );
			}
		}
		[hits release];
	}
	return mSBArray;
}


- (void)		invalidate
{
//	LogEvent_(kReactiveEvent, @"invalidating stops rects");
	
	[mSBArray release];
	mSBArray = nil;
}


- (NSRect)		swatchRectForStop:(DKColorStop*) stop
{
	// returns the actual rect used for the given stop, taking into account overlaps, etc.
	
	int indx = [mUnsortedStops indexOfObject:stop];
	
	if ( indx != NSNotFound )
		return [[[self allSwatchBoxes] objectAtIndex:indx] rectValue];
	else
		return NSZeroRect;
}


#pragma mark -
- (void)			drawStopsInRect:(NSRect) rect
{
#pragma unused (rect)
	NSArray*	boxes = [self allSwatchBoxes];	// to detect overlaps
	
	NSEnumerator*	curs = [mUnsortedStops objectEnumerator];
	DKColorStop*	element;
	NSRect			sw;
	int				j = 0, state;
	
	while ((element = [curs nextObject]) != nil)
	{
		if ( element != mDeletionCandidateRef )
		{
			sw = [[boxes objectAtIndex:j] rectValue];
			
			if ( element == mSelectedStopRef || element == mDragStopRef )
			{
				if ( mMouseDownInStop )
					state = kGCPressedState;
				else
					state = kGCSelectedState;
			}
			else
				state = kGCNormalState;
			
			[self drawStop:element inRect:sw state:state];
		}
		++j;
	}
}


- (DKColorStop*)	stopAtPoint:(NSPoint) point
{
	NSEnumerator* iter = [[self allSwatchBoxes] objectEnumerator];
	NSValue*		v;
	NSRect			r;
	int				j = 0;
	
	while( (v = [iter nextObject]) != nil)
	{
		r = [v rectValue];
		
		if ( NSPointInRect( point, r ))
			return [mUnsortedStops objectAtIndex:j];

		++j;
	}
	
	return nil;
}


- (void)			setSelectedStop:(DKColorStop*) stop
{
	if ( stop != mSelectedStopRef )
	{
		[self setNeedsDisplayInRect:[self swatchRectForStop:mSelectedStopRef]];
		
		mSelectedStopRef = stop;
		
		if (mSelectedStopRef)
		{
			// order here is important: deactivate external well before setting panel's colour:
			
			[GCSpecialColorWell deactivateCurrentWell];
			
			[[NSColorPanel sharedColorPanel] setColor:[mSelectedStopRef color]];
			[[NSColorPanel sharedColorPanel] setTarget:self];
			[[NSColorPanel sharedColorPanel] setAction:@selector(changeColor:)];
			
			[self setNeedsDisplayInRect:[self swatchRectForStop:mSelectedStopRef]];
		}
	}
}


- (DKColorStop*)	selectedStop
{
	return mSelectedStopRef;
}


- (void)			setColorOfSelectedStop:(NSColor*) Color
{
	if ( nil != mSelectedStopRef )
	{
		[mSelectedStopRef setColor:Color];
		[self syncGradientToControlSettings];
		[self setNeedsDisplay:YES];
	}
}


#pragma mark -
- (void)			updateInfoWithPosition:(float) pos
{
	if ( mShowsInfo )
	{
		NSRect sr = [self swatchBoxAtPosition:pos];
		NSPoint ip;
		
		ip.x = NSMinX( sr );
		ip.y = NSMinY( sr );
		
		[mInfoWin setFloatValue:pos * 100];
		[mInfoWin positionNearPoint:ip inView:self];
	}
}


- (void)			setShowsPositionInfo:(BOOL) show
{
	mShowsInfo = show;
}


- (BOOL)			showsPositionInfo
{
	return mShowsInfo;
}


#pragma mark -
- (BOOL)		setCursorInSafeLocation:(NSPoint) p
{
	NSRect	safeZone = NSInsetRect([self bounds], -32.0, -7.0 );

	if ( NSPointInRect( p, safeZone ) || [[self gradient] countOfColorStops] < 3 )
	{
		[[NSCursor arrowCursor] set];
		return YES;
	}
	else
	{
		[[self makeCursorForDeletingStop:mDragStopRef] set];
		return NO;
	}
}


- (NSImage*)		dragImageForStop:(DKColorStop*) stop
{
	NSRect sr = [self swatchBoxAtPosition:0.0];
	sr.origin = NSZeroPoint;
	
	NSImage* img = [[NSImage alloc] initWithSize:sr.size];
	
	[img lockFocus];
	[self drawStop:stop inRect:sr state:kGCNormalState];
	[img unlockFocus];
	
	return [img autorelease];
}


- (NSCursor*)		makeCursorForDeletingStop:(DKColorStop*) stop
{
	// this is something of a hack, though an inspired one ;-). wish to show the stop under the cursor
	// when it's going to be deleted, but using a drag image doesn't fit the current logic design. So instead we
	// just create a custom cursor on the fly by compositing the stop image with the 'poof' cursor.
	
	static NSCursor* sCurs = nil;
	static DKColorStop*	sStop = nil;
	
	if ( sCurs == nil || stop != sStop )
	{
		if ( sCurs != nil )
			[sCurs release];
		
		NSImage* poofImage = [[NSCursor disappearingItemCursor] image];
		NSImage* stopImg = [self dragImageForStop:stop];
		NSPoint  hotspot = [[NSCursor disappearingItemCursor] hotSpot];
		
		NSImage* newImage;
		NSRect	 a, b, c;
		
		[poofImage setFlipped:YES];
		
		// compute size of composited image. stopImg will be centred under the hotspot
		
		a.size = [poofImage size];
		a.origin = NSZeroPoint;
		b.size = [stopImg size];
		b.origin.x = hotspot.x - ( b.size.width / 2.0 );
		b.origin.y = hotspot.y - ( b.size.height / 2.0 );
		
	//	LogEvent_(kInfoEvent,  @"rect B = {%f, %f - %f, %f}", b.origin.x, b.origin.y, b.size.width, b.size.height );
		
		c = NSUnionRect( a, b );

		b.origin.x -= c.origin.x;
		b.origin.y -= c.origin.y;
		a.origin.x -= c.origin.x;
		a.origin.y -= c.origin.y;
		c.origin = NSZeroPoint;
		hotspot.x = b.origin.x + ( b.size.width / 2.0 );
		hotspot.y = b.origin.y + ( b.size.height / 2.0 );
		
	//	LogEvent_(kInfoEvent,  @"rect C = {%f, %f - %f, %f}", c.origin.x, c.origin.y, c.size.width, c.size.height );
		newImage = [[NSImage alloc] initWithSize:c.size];
		
		[newImage setFlipped:YES];
		[newImage lockFocus];
		[stopImg drawInRect:b fromRect:NSZeroRect operation:NSCompositeCopy fraction:0.5];
		[poofImage drawInRect:a fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
		
		/*
		[[NSColor redColor] set];
		NSFrameRect( b );
		NSFrameRect( a );
		NSFrameRect( c );
		a = NSInsetRect( NSMakeRect( hotspot.x, hotspot.y, 0, 0 ), -2, -2 );
		NSFrameRect( a );
		*/
		[newImage unlockFocus];
		
		
		sCurs =  [[NSCursor alloc] initWithImage:newImage hotSpot:hotspot];
		sStop = stop;
	}
	
	return sCurs;
}


#pragma mark -
- (void)		trackMouseWithEvent:(NSEvent*) event
{
	// keeps control in its own event loop until the mouse is released. It handles the dragging of the stops and swatch
	// drag. This is more appropriate for a control than implementing mouseDown/dragged/up because any clients that
	// implement Undo don't want individual changes seen as separate undos.
	
	// Note - this is called from mouseDown, so do not call it again.
	
	unsigned int	mask;
	BOOL			loop = YES;
	
	mask = NSLeftMouseUpMask | NSLeftMouseDraggedMask;

	while( loop )
	{
		event = [[self window] nextEventMatchingMask:mask];
		
		switch([event type])
		{
			case NSLeftMouseUp:
				[self mouseUp:event];
				loop = NO;
				break;
				
			case NSLeftMouseDragged:
				[self mouseDragged:event];
				break;
			
			default:
				break;
		}
	}
}


#pragma mark -
- (IBAction)		changeColor:(id) sender
{
//	LogEvent_(kStateEvent, @"changing colour...");

	NSColor* clr = [sender color];
	[self setColorOfSelectedStop:clr];
	
	if( sender != [NSColorPanel sharedColorPanel])
		[[NSColorPanel sharedColorPanel] setColor:clr];
}


- (IBAction)		newStop:(id) sender
{
#pragma unused (sender)
	NSPoint p = mStopInsertHint;
	
	if ( NSEqualPoints( p, NSZeroPoint ))
	{
		p.x = NSMidX([self bounds]);
		p.y = NSMidY([self bounds]);
	}
	[self setSelectedStop:[self addColorStop:nil atPoint:p]];
}


- (IBAction)		blendMode:(id) sender
{
	[[self gradient] setGradientBlending:[sender tag]];
	[self syncGradientToControlSettings];
	[self setNeedsDisplay:YES];
}


- (IBAction) flip:(id) sender
{	
#pragma unused (sender)
	[[self gradient] reverseColorStops];
	[self syncGradientToControlSettings];
	[self setNeedsDisplay:YES];
	[self invalidate];
}


- (IBAction)		gradientType:(id) sender
{
	DKGradientType type = (DKGradientType)[sender tag];
	
	if ( type != [[self gradient] gradientType])
	{
		[[self gradient] setGradientType:type];
		[self syncGradientToControlSettings];
		[self setNeedsDisplay:YES];
	}
}


#pragma mark -
- (NSRect)		interior
{
	return NSInsetRect([self bounds], 11.0, 2.0 );
}


#pragma mark -
#pragma mark As an NSView
- (BOOL)		acceptsFirstMouse:(NSEvent*) theEvent
{
#pragma unused (theEvent)
	return YES;
}


- (void)			drawRect:(NSRect) rect
{
#pragma unused (rect)
	NSRect br = [self bounds];
	NSRect clip = NSInsetRect([self interior], -8, 0 );
	
	[[NSColor grayColor] set];
	NSFrameRectWithWidth( br, 1.0 );
	
	// draw a background pattern so we can "see" transparencies
	
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
		NSRectFill( clip );
	}
	
	// must make a copy of the gradient so that the angle and type can be ignored
	
	DKGradient* gradCopy = [[self gradient] copy];
	
	[gradCopy setGradientType:kGCGradientTypeLinear];
	[gradCopy setAngle:0.0];
	
	NSBezierPath*   path = [NSBezierPath bezierPathWithRect:clip];
	NSPoint			start, end;
	
	start = NSMakePoint( NSMinX( clip ), NSMidY( clip ));
	end = NSMakePoint( NSMaxX( clip ), NSMidY( clip ));
	
	[gradCopy fillPath:path startingAtPoint:start startRadius:0.0 endingAtPoint:end endRadius:0.0];
	[gradCopy release];
	
	// Draw the swatches
	[self drawStopsInRect:clip];
}


- (id)			initWithFrame:(NSRect) frame
{
    self = [super initWithFrame:frame];
	if (self != nil)
	{
		NSAssert(mDragStopRef == nil, @"Expected init to zero");
		NSAssert(mSelectedStopRef == nil, @"Expected init to zero");
		NSAssert(mDeletionCandidateRef == nil, @"Expected init to zero");
		mInfoWin = [[GCInfoFloater infoFloater] retain];
		
		mUnsortedStops = [[NSMutableArray alloc] init];
		NSAssert(mSBArray == nil, @"Expected init to zero");
		
		NSAssert(NSEqualPoints(mStopInsertHint, NSZeroPoint), @"Expected init to zero");
		NSAssert(!mStopWasDragged, @"Expected init to zero");
		NSAssert(!mMouseDownInStop, @"Expected init to zero");
		mShowsInfo = YES;
		
		if (mInfoWin == nil)
		{
			[self autorelease];
			self = nil;
		}
    }
	if (self != nil)
	{
		[mInfoWin setFormat:@"0.0%"];
		[self setGradient:[DKGradient defaultGradient]];
	}
   return self;
}


- (BOOL)		isFlipped
{
	return YES;
}


- (NSMenu*)		menuForEvent:(NSEvent*) theEvent
{
	NSPoint p = [theEvent locationInWindow];
	p = [self convertPoint:p fromView:nil];
	
	DKColorStop* stop = [self stopAtPoint:p];
	
	if ( stop )
	{
		// right-click in stop. pop up our custom menu
		
	//	LogEvent_(kReactiveEvent, @"popping up stop contextual menu");
		
		[self setSelectedStop:stop];
		
		// figure out where to put the menu
		
		NSRect  sw = [self swatchRectForStop:stop];
		NSPoint loc;
		
		loc.x = NSMinX( sw );
		loc.y = NSMaxY( sw );
		loc = [self convertPoint:loc toView:nil];
		
		NSRect sr = NSMakeRect( 0, 0, 161, 161 );

		GCColourPickerView* picker = [[GCColourPickerView alloc] initWithFrame:sr];
		GCWindowMenu* popup = [GCWindowMenu windowMenuWithContentView:picker];

		if ([theEvent modifierFlags] & NSAlternateKeyMask)
			[picker setMode:kGCColourPickerModeSwatches];
		else
			[picker setMode:kGCColourPickerModeSpectrum];

		[picker setTarget:self];
		[picker setAction:@selector(changeColor:)];
		[picker setColorForUndefinedSelection:[stop color]];
		[picker setShowsInfo:YES];
		[picker release];
		
		[GCWindowMenu popUpWindowMenu:popup atPoint:loc withEvent:theEvent forView:self];
	
		return nil;
	}
	else
	{
		NSMenu* contextualMenu = [super menuForEvent:theEvent];
		
		NSMenuItem*	item;

		item = (NSMenuItem*)[contextualMenu insertItemWithTitle:NSLocalizedString(@"New Color Stop", @"") action:@selector(newStop:) keyEquivalent:@"" atIndex:0];
		item = (NSMenuItem*)[contextualMenu insertItemWithTitle:NSLocalizedString(@"Reverse Colors", @"") action:@selector(flip:)
									 keyEquivalent:@"" atIndex:1];
		[item setTarget:self];
		
		[contextualMenu insertItem:[NSMenuItem separatorItem] atIndex:2];
		
		// gradient types:
		
		[contextualMenu addItem:[NSMenuItem separatorItem]];
		item = (NSMenuItem*)[contextualMenu addItemWithTitle:NSLocalizedString(@"Linear", @"") action:@selector(gradientType:) keyEquivalent:@""];
		[item setTarget:self];
		[item setTag:0];
		item = (NSMenuItem*)[contextualMenu addItemWithTitle:NSLocalizedString(@"Radial", @"") action:@selector(gradientType:) keyEquivalent:@""];
		[item setTarget:self];
		[item setTag:1];
		item = (NSMenuItem*)[contextualMenu addItemWithTitle:NSLocalizedString(@"Sweep", @"") action:@selector(gradientType:) keyEquivalent:@""];
		[item setTarget:self];
		[item setTag:2];
		
		// blending modes:
		
		[contextualMenu addItem:[NSMenuItem separatorItem]];
		item = (NSMenuItem*)[contextualMenu addItemWithTitle:NSLocalizedString(@"RGB Blending", @"") action:@selector(blendMode:) keyEquivalent:@""];
		[item setTarget:self];
		[item setTag:0];
		item = (NSMenuItem*)[contextualMenu addItemWithTitle:NSLocalizedString(@"HSV Blending", @"") action:@selector(blendMode:) keyEquivalent:@""];
		[item setTarget:self];
		[item setTag:1];
		
		// interpolations:
		[contextualMenu addItem:[NSMenuItem separatorItem]];
		
		item = (NSMenuItem*)[contextualMenu addItemWithTitle:NSLocalizedString(@"Linear", @"") action:@selector(interpolation:) keyEquivalent:@""];
		[item setTarget:self];
		[item setTag:0];
		item = (NSMenuItem*)[contextualMenu addItemWithTitle:NSLocalizedString(@"Quadratic", @"") action:@selector(interpolation:) keyEquivalent:@""];
		[item setTarget:self];
		[item setTag:2];
		item = (NSMenuItem*)[contextualMenu addItemWithTitle:NSLocalizedString(@"Cubic", @"") action:@selector(interpolation:) keyEquivalent:@""];
		[item setTarget:self];
		[item setTag:3];
		item = (NSMenuItem*)[contextualMenu addItemWithTitle:NSLocalizedString(@"Sinusoid", @"") action:@selector(interpolation:) keyEquivalent:@""];
		[item setTarget:self];
		[item setTag:4];
		
		mStopInsertHint = p;
		
		return contextualMenu;
	}
	
	return nil;
}


- (void)		setFrame:(NSRect) frame
{
	[super setFrame:frame];
	[self invalidate];
}


#pragma mark -
#pragma mark As an NSFirstResponder
- (void)		mouseDown:(NSEvent*) event
{
	NSPoint pt = [event locationInWindow];
	pt = [self convertPoint:pt fromView:nil];
	
	mDragStopRef = nil;
	mStopWasDragged = NO;
	
	DKColorStop *stop = [self stopAtPoint:pt];
	
	if (stop)
	{
		mDragStopRef = stop;
		mMouseDownInStop = YES;
		//mSelectedStopRef = nil;
		// prepare the info window to show the stop's position
		
		if ( mShowsInfo )
		{
			[self updateInfoWithPosition:[mDragStopRef position]];
			[mInfoWin orderFront:self];
		}
		[self setNeedsDisplayInRect:[self swatchRectForStop:stop]];
	}
	
	[self trackMouseWithEvent:event];
}


- (void)		mouseDragged:(NSEvent*) event
{
	if (mDragStopRef)
	{
		NSPoint point = [event locationInWindow];
		point = [self convertPoint:point fromView:nil];
		float gPos = [self relativeXWithPoint:point];
		
		if( ![self setCursorInSafeLocation:point])
		{
			mDeletionCandidateRef = mDragStopRef;
			[mInfoWin orderOut:self];
		}
		else
		{
			mDeletionCandidateRef = nil;

			if ( mShowsInfo )
				[mInfoWin show];
			
			// round gPos to "grid" clicks if desired
			if ([event modifierFlags] & NSShiftKeyMask)
				gPos = round( gPos * 100 ) / 100;
			
			[self updateInfoWithPosition:gPos];
			[mDragStopRef setPosition:gPos];
			[self invalidate];
			[[self gradient] sortColorStops];
			[self syncGradientToControlSettings];
			
			mStopWasDragged = YES;
		}

		[self setNeedsDisplay:YES];
	}
	else
		[self initiateGradientDragWithEvent:event];
}


- (void)		mouseUp:(NSEvent*) event
{
	NSPoint pt = [event locationInWindow];
	pt = [self convertPoint:pt fromView:nil];
	mMouseDownInStop = NO;

	[mInfoWin hide];
	
	if ( nil != mDragStopRef )
	{
		if ( mSelectedStopRef == mDragStopRef && !mStopWasDragged )
		{
			mSelectedStopRef = nil;
		}
		else
		{
			[self setSelectedStop:mDragStopRef];

			if ( ! mStopWasDragged )
				[[NSColorPanel sharedColorPanel] orderFront:self];
		}

		if( ! [self setCursorInSafeLocation:pt])
		{
			if ( mDragStopRef == mSelectedStopRef )
				mSelectedStopRef = nil;
			
			[mUnsortedStops removeObject:mDragStopRef];
			[[self gradient] removeColorStop:mDragStopRef];
			[self syncGradientToControlSettings];
			
			NSShowAnimationEffect(NSAnimationEffectDisappearingItemDefault, [NSEvent mouseLocation], NSZeroSize, nil, nil, nil );
			[[NSCursor arrowCursor] set];
			[self invalidate];
		}
	}
	mDragStopRef = nil;
	[self setNeedsDisplay:YES];
}


#pragma mark -
#pragma mark As an NSObject
- (void)		dealloc
{
	[mSBArray release];
	[mUnsortedStops release];
	
	[mInfoWin release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark As part of NSDraggingDestination  Protocol
- (NSDragOperation)	draggingEntered:(id <NSDraggingInfo>) sender
{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
	
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
	
	if([DKGradient canInitalizeFromPasteboard:pboard] ||
	   [[pboard types] containsObject:NSColorPboardType])
	{
        if (sourceDragMask & NSDragOperationGeneric)
		{
            return NSDragOperationGeneric;
        }
    }
    return NSDragOperationNone;
}


- (BOOL)			performDragOperation:(id <NSDraggingInfo>) sender
{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
	
	mDragStopRef = nil;

    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
	
    if ( [DKGradient canInitalizeFromPasteboard:pboard] && [sender draggingSource] != self)
	{
        DKGradient *aGradient = [DKGradient gradientWithPasteboard:pboard];
		if (aGradient)
			[self setGradient:aGradient];
    }
	else if ( [[pboard types] containsObject:NSColorPboardType] )
	{
        NSColor *color = [NSColor colorFromPasteboard:pboard];
		NSPoint pt = [sender draggingLocation];
		pt = [self convertPoint:pt fromView:nil];
        [self setSelectedStop:[self addColorStop:color atPoint:pt]];
    }
	[self setNeedsDisplay:YES];
    return YES;
}


#pragma mark -
#pragma mark As part of NSMenuValidation Protocol
- (BOOL)	validateMenuItem:(NSMenuItem*) item
{
	BOOL	enable = [super validateMenuItem:item];
	SEL		act = [item action];
	
	if ( act == @selector(blendMode:))
		[item setState:([item tag] == (int)[[self gradient] gradientBlending])? NSOnState : NSOffState];
	else if ( act == @selector(interpolation:))
		[item setState:([item tag] == (int)[[self gradient] gradientInterpolation])? NSOnState : NSOffState];
	else if ( act == @selector(gradientType:))
		[item setState:([item tag] == (int)[[self gradient] gradientType])? NSOnState : NSOffState];
	
	return enable;
}


#pragma mark -
#pragma mark As part of NSNibAwaking  Protocol
- (void)		awakeFromNib
{
	[[NSColorPanel sharedColorPanel] setShowsAlpha:YES];

	[self registerForDraggedTypes:[DKGradient readablePasteboardTypes]];
	[self registerForDraggedTypes:[NSArray arrayWithObject:NSColorPboardType]];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(colorWellActivation:) name:kGCColorWellWillActivate object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(externalStopChange:) name:kGCNotificationGradientDidAddColorStop object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(externalStopChange:) name:kGCNotificationGradientDidRemoveColorStop object:nil];
}


@end
