//
//  GCGradientCell.m
//  GradientTest
//
//  Created by Jason Jobe on 3/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GCGradientCell.h"

#import "GCGradientWell.h"
#import "GCMiniCircularSlider.h"
#import "GCMiniControlCluster.h"
#import "GCMiniRadialControl2.h"
#import "GCMiniRadialControls.h"

#import "GCDrawKit/DKGradientExtensions.h"
#import <GCDrawKit/LogEvent.h>


#pragma mark Contants (Non-localized)
// private IDs locate mini controls within the cell

static NSString*	kLinearAngleControlID	= @"kLinearAngleControlID";
static NSString*	kRadialStartControlID	= @"kRadialStartControlID";
static NSString*	kRadialEndControlID		= @"kRadialEndControlID";
static NSString*	kSweepCentreControlID	= @"kSweepCentreControlID";
static NSString*	kSweepSegmentsControlID = @"kSweepSegmentsControlID";
static NSString*	kSweepAngleControlID	= @"kSweepAngleControlID";

// clusters:

static NSString*	kLinearControlsClusterID	= @"kLinearControlsClusterID";
static NSString*	kRadialControlsClusterID	= @"kRadialControlsClusterID";
static NSString*	kSweepControlsClusterID		= @"kSweepControlsClusterID";


#pragma mark Static Vars
static unsigned		sMFlags = 0;


@implementation GCGradientCell
#pragma mark As a GCGradientCell
- (void)		setupMiniControls
{
	// the mini controls are stored in a series of hierarchical clusters. The top level is basically just used as a
	// container for the lower level clusters. Each subcluster contains a group of mini controls, one for each of the
	// gradient modes/types
	
	mMiniControls = [[GCMiniControlCluster alloc] initWithBounds:NSZeroRect inCluster:nil];
	[mMiniControls setDelegate:self];
	[mMiniControls forceVisible:NO];
	
	GCMiniControlCluster*	mcc;
	GCMiniControl*			mini;
	
	// first contains circular slider for linear gradient angle
	
	mcc = [[GCMiniControlCluster alloc] initWithBounds:NSZeroRect inCluster:mMiniControls];
	[mcc setIdentifier:kLinearControlsClusterID];
	
	mini = [[GCMiniCircularSlider alloc] initWithBounds:NSZeroRect inCluster:mcc];
	[mini setIdentifier:kLinearAngleControlID];
	[mini release];
	[mcc release];
	
	// second has twin radial controls
	
	mcc = [[GCMiniControlCluster alloc] initWithBounds:NSZeroRect inCluster:mMiniControls];
	[mcc setIdentifier:kRadialControlsClusterID];
	
	// allow shift key to move both minicontrols together:
	
	[mcc setLinkControlPart:kGCRadial2HitIris modifierKeyMask:NSShiftKeyMask];
	
	mini = [[GCMiniRadialControl2 alloc] initWithBounds:NSZeroRect inCluster:mcc];
	[mini setIdentifier:kRadialEndControlID];
	[mini release];
	
	mini = [[GCMiniRadialControl2 alloc] initWithBounds:NSZeroRect inCluster:mcc];
	[mini setIdentifier:kRadialStartControlID];
	[mini release];
	[mcc release];
	
	// third has circular slider + single radial control + straight slider
	// n.b. order is important as controls overlap. hit testing is done in reverse order to
	// that here, which is the drawing order.
	
	mcc = [[GCMiniControlCluster alloc] initWithBounds:NSZeroRect inCluster:mMiniControls];
	[mcc setIdentifier:kSweepControlsClusterID];

	mini = [[GCMiniCircularSlider alloc] initWithBounds:NSZeroRect inCluster:mcc];
	[mini setIdentifier:kSweepAngleControlID];
	[mini release];

	mini = [[GCMiniSlider alloc] initWithBounds:NSZeroRect inCluster:mcc];
	[mini setIdentifier:kSweepSegmentsControlID];
	[mini setInfoWindowMode:kGCMiniControlInfoWindowCentred];
	[mini setInfoWindowFormat:@"0"];
	[mini release];

	mini = [[GCMiniRadialControls alloc] initWithBounds:NSZeroRect inCluster:mcc];
	[mini setIdentifier:kSweepCentreControlID];
	[mini release];
}


- (void)				setControlledAttributeFromMiniControl:(GCMiniControl*) ctrl
{
	NSString*	ident = [ctrl identifier];
	
	GCMiniRadialControls* rc;
	
	if([ident isEqualToString:kLinearAngleControlID] || [ident isEqualToString:kSweepAngleControlID])
	{
		[[self gradient] setAngle:[ctrl value]];
	}
	else if ([ident isEqualToString:kSweepSegmentsControlID])
	{
		int seg = [ctrl value] * 50;
		if ( seg < 4 )
			seg = 0;		
		
		//[[self gradient] setNumberOfAngularSegments:seg];
	}
	else if ([ident isEqualToString:kRadialStartControlID] || [ident isEqualToString:kSweepCentreControlID])
	{
		rc = (GCMiniRadialControls*) ctrl;
		
	//	LogEvent_(kStateEvent, @"setting starting radius: %f", [rc radius]);
		
		NSPoint p = [[self gradient] mapPoint:[rc centre] fromRect:mControlBoundsRect];
		[[self gradient] setRadialStartingPoint:p];
		[[self gradient] setRadialStartingRadius:[rc radius]/mControlBoundsRect.size.width];
	}
	else if ([ident isEqualToString:kRadialEndControlID])
	{
		rc = (GCMiniRadialControls*) ctrl;
		
	//	LogEvent_(kStateEvent, @"setting ending radius: %f", [rc radius]);
		NSPoint p = [[self gradient] mapPoint:[rc centre] fromRect:mControlBoundsRect];
		[[self gradient] setRadialEndingPoint:p];
		[[self gradient] setRadialEndingRadius:[rc radius]/mControlBoundsRect.size.width];
	}
}


#pragma mark -
- (void)		setMiniControlBoundsWithCellFrame:(NSRect) cellframe forMode:(int) mode
{
	// sets up the mini controls' bounds from the cellFrame. Each one is individually calculated as appropriate. Note
	// that some types, notably the circular slider, position themselves centrally in their bounds so this method need
	// not bother with that.
	
	NSRect cframe = NSInsetRect( cellframe, 20, 20 );
	[mMiniControls setView:[self controlView]];
	
	// linear:
	
	if ( mode == kGCGradientWellAngleMode )
	{
		[self setMiniControlBounds:cframe withIdentifier:kLinearAngleControlID];
	}
	else if ( mode == kGCGradientWellRadialMode )
	{
		// radial controls likewise just need the entire frame:
		
		[self setMiniControlBounds:cellframe withIdentifier:kRadialStartControlID];
		[self setMiniControlBounds:cellframe withIdentifier:kRadialEndControlID];
	}
	else if ( mode == kGCGradientWellSweepMode )
	{
		// sweep controls:

		[self setMiniControlBounds:cframe withIdentifier:kSweepAngleControlID];
		[self setMiniControlBounds:cellframe withIdentifier:kSweepCentreControlID];

		// only the segment slider has a complex bounds calc:
		
		NSRect sr = NSInsetRect( cframe, 40, 50 );
		sr.size.height = 12;
		sr.origin.y = cframe.origin.y + ( cframe.size.height * 0.63 );

		[self setMiniControlBounds:sr withIdentifier:kSweepSegmentsControlID];
	}
}


- (void)		setMiniControlBounds:(NSRect) br withIdentifier:(NSString*) key
{
	// sets the mini control with <key> identifier to have the bounds <br>
	
	GCMiniControl*	mc = [mMiniControls controlForKey:key];
	
	if ( mc )
		[mc setBounds:br];
}


- (void)				drawMiniControlsForMode:(int) mode
{
	// given the mode which is set by the owning GCGradientWell, this draws the controls in the appropriate cluster.
	
	[[self controlClusterForMode:mode] draw];
}


- (GCMiniControlCluster*)	controlClusterForMode:(int) mode;
{
	switch ( mode )
	{
		default:
		case kGCGradientWellDisplayMode:
			return nil;
		
		case kGCGradientWellAngleMode:
			return (GCMiniControlCluster*)[mMiniControls controlForKey:kLinearControlsClusterID];
			
		case kGCGradientWellRadialMode:
			return (GCMiniControlCluster*)[mMiniControls controlForKey:kRadialControlsClusterID];
			
		case kGCGradientWellSweepMode:
			return (GCMiniControlCluster*)[mMiniControls controlForKey:kSweepControlsClusterID];
	}
}


- (GCMiniControl*)		miniControlForIdentifier:(NSString*) key
{
	return [mMiniControls controlForKey:key];
}


- (void)				updateMiniControlsForMode:(int) mode
{
	// sets the minicontrol values in <mode> cluster to match the current gradient
	
	mUpdatingControls = YES;
	
	if ( mode == kGCGradientWellAngleMode )
	{
		[[self miniControlForIdentifier:kLinearAngleControlID] setValue:[[self gradient] angle]];
	}
	else if ( mode == kGCGradientWellRadialMode )
	{
	//	LogEvent_(kStateEvent, @"setting up radial controls");
		
		GCMiniRadialControl2* rc = (GCMiniRadialControl2*)[mMiniControls controlForKey:kRadialStartControlID];
		
		[rc setRingRadiusScale:0.85];
		[rc setCentre:[[self gradient] mapPoint:[[self gradient] radialStartingPoint] toRect:mControlBoundsRect]];
		[rc setRadius:[[self gradient] radialStartingRadius] * mControlBoundsRect.size.width];
		[rc setTabColor:[[self gradient] colorAtValue:0.0]];
		
		rc = (GCMiniRadialControl2*)[mMiniControls controlForKey:kRadialEndControlID];

		[rc setCentre:[[self gradient] mapPoint:[[self gradient] radialEndingPoint] toRect:mControlBoundsRect]];
		[rc setRadius:[[self gradient] radialEndingRadius] * mControlBoundsRect.size.width];
		[rc setTabColor:[[self gradient] colorAtValue:1.0]];
	}
	else if ( mode == kGCGradientWellSweepMode )
	{
		// sweep controls:

		GCMiniRadialControls* rc = (GCMiniRadialControls*)[mMiniControls controlForKey:kSweepCentreControlID];
		
		[rc setCentre:[[self gradient] mapPoint:[[self gradient] radialStartingPoint] toRect:mControlBoundsRect]];
		
		int		seg = 100;//[[self gradient] numberOfAngularSegments];
		float	v = (float) seg / 50.0;
					
		if ( seg < 4 )
			v = 0.0;

		[[self miniControlForIdentifier:kSweepSegmentsControlID] setValue:v];
		[[self miniControlForIdentifier:kSweepAngleControlID] setValue:[[self gradient] angle]];
	}
	
	mUpdatingControls = NO;
}


#pragma mark -
- (NSRect)			proxyIconRectInCellFrame:(NSRect) rect
{
	NSImage* ficon = [NSImage imageNamed:@"fileiconsmall"];
	NSRect		ir, br;
	
	br = NSInsetRect( rect, 8, 9 );
	
	ir.size = [ficon size];
	ir.origin.x = NSMaxX( br ) - ir.size.width;
	ir.origin.y = NSMaxY( br ) - ir.size.height;
	
	return ir;
}


#pragma mark -
- (void)		setControlVisible:(BOOL) vis
{
	[mMiniControls setVisible:vis];
	[[self controlView] setNeedsDisplay:YES];
}


#pragma mark -
#pragma mark As an DKGradientCell
- (SEL)			action
{
	return mAction;
}


- (void)		drawInteriorWithFrame:(NSRect) cellFrame inView:(NSView*) controlView
{
	if ([self gradient])
	{
		[super drawInteriorWithFrame:cellFrame inView:controlView];
		
		mControlBoundsRect = cellFrame;
		id control = [self controlView];
		
		if([control isKindOfClass:[GCGradientWell class]])
		{
			[control setupTrackingRect];
			[self setMiniControlBoundsWithCellFrame:cellFrame forMode:[control controlMode]];
			[self updateMiniControlsForMode:[control controlMode]];
			
			[NSBezierPath clipRect: NSInsetRect( cellFrame, 8, 8 )];
			[self drawMiniControlsForMode:[control controlMode]];
			
			// if proxy icon flag set, draw it
			
			if ([control displaysProxyIcon])
			{
				NSImage* ficon = [NSImage imageNamed:@"fileiconsmall"];
				[ficon setFlipped:YES];
				[ficon drawInRect:[self proxyIconRectInCellFrame:cellFrame] fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:0.8];
			}
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


#pragma mark -
#pragma mark As an NSCell
- (BOOL)		continueTracking:(NSPoint) lastPoint at:(NSPoint) currentPoint inView:(NSView*) controlView
{
#pragma unused (lastPoint)
	if( [controlView isKindOfClass:[GCGradientWell class]])
	{
		if ( mHitPart == kGCHitMiniControl )
		{
			int cmode = [(GCGradientWell*)controlView controlMode];
			GCMiniControlCluster*	cc = [self controlClusterForMode:cmode];
		
			return [cc mouseDraggedAt:currentPoint inPart:0 modifierFlags:[self mouseDownFlags]];
		}
	}
	return NO;
}


- (int)			mouseDownFlags
{
	return sMFlags;
}


- (BOOL)		startTrackingAt:(NSPoint) startPoint inView:(NSView*) controlView
{
//	LogEvent_(kReactiveEvent, @"cell starting tracking...");
	
	mHitPart = kGCHitOther;
	
	if( [controlView isKindOfClass:[GCGradientWell class]])
	{
		// hit in proxy icon?
		
		if ([(GCGradientWell*)controlView displaysProxyIcon])
		{
			NSRect ir = [self proxyIconRectInCellFrame:mControlBoundsRect];
			
			if ( NSPointInRect( startPoint, ir ))
			{
				mHitPart = kGCHitProxyIcon;
				return YES;
			}
		}

		int cmode = [(GCGradientWell*)controlView controlMode];
		GCMiniControlCluster*	cc = [self controlClusterForMode:cmode];
			
		if ( [cc mouseDownAt:startPoint inPart:0 modifierFlags:[self mouseDownFlags]])
		{
			mHitPart = kGCHitMiniControl;   // for any mini-control
			return YES;
		}
	}
	
	return YES;
}


- (void)		stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView*) controlView mouseIsUp:(BOOL) flag
{
#pragma unused (lastPoint, flag)
	if( [controlView isKindOfClass:[GCGradientWell class]])
	{
		if ( mHitPart == kGCHitMiniControl )
		{
			int cmode = [(GCGradientWell*)controlView controlMode];
			GCMiniControlCluster*	cc = [self controlClusterForMode:cmode];
	
			[cc mouseUpAt:stopPoint inPart:0 modifierFlags:[self mouseDownFlags]];
		}
	}
}


- (BOOL)		trackMouse:(NSEvent*) theEvent inRect:(NSRect) cellFrame ofView:(NSView*) controlView untilMouseUp:(BOOL) untilMouseUp
{
#pragma unused (cellFrame, untilMouseUp)
	NSPoint p = [controlView convertPoint:[theEvent locationInWindow] fromView:nil];
	
	sMFlags = [theEvent modifierFlags];
	[mMiniControls flagsChanged:sMFlags];
	[mMiniControls setVisible:YES];
	
	if ([self startTrackingAt:p inView:controlView])
	{
		unsigned int	mask;
		NSEvent*		event;
		BOOL			loop = YES;
		NSPoint			currentPoint, lastPoint;
		
		mEnableCache = NO;
		mask = NSLeftMouseUpMask | NSLeftMouseDraggedMask | NSFlagsChangedMask;
		lastPoint = p;
		
	//	LogEvent_(kReactiveEvent, @"starting track loop, hit part = %d", mHitPart );
	
		while( loop )
		{
			event = [[controlView window] nextEventMatchingMask:mask];
			
		//	LogEvent_(kUIEvent, @"event = %@", event);
			
			currentPoint = [controlView convertPoint:[event locationInWindow] fromView:nil];
			sMFlags = [event modifierFlags];
			
			switch([event type])
			{
				case NSLeftMouseUp:
				//	LogEvent_(kReactiveEvent, @"mouse up");
					[self stopTracking:lastPoint at:currentPoint inView:controlView mouseIsUp:YES];
					loop = NO;
					break;
					
				case NSLeftMouseDragged:
					loop = [self continueTracking:lastPoint at:currentPoint inView:controlView];
					if( ! loop )
					{
						[self stopTracking:lastPoint at:currentPoint inView:controlView mouseIsUp:NO];
						if ( mHitPart == kGCHitOther )
						{
							[mMiniControls setVisible:NO];
							[controlView initiateGradientDragWithEvent:theEvent];
						}
					}
					break;
					
				case NSFlagsChanged:
					[mMiniControls flagsChanged:[event modifierFlags]];
					break;
					
				default:
					break;
			}
			
			lastPoint = currentPoint;
		}
		[[controlView window] discardEventsMatchingMask:mask beforeEvent:event];
		mHitPart = kGCHitNone;
		mEnableCache = YES;
		[mMiniControls flagsChanged:0];
	}
//	LogEvent_(kReactiveEvent, @"cell ended tracking");
	
	return YES;
}


#pragma mark -
#pragma mark As an NSObject
- (void) dealloc
{
	[mMiniControls release];
	
	[super dealloc];
}


- (id)	init
{
	self = [super init];
	if (self != nil)
	{
		NSAssert(NSEqualRects(mControlBoundsRect, NSZeroRect), @"Expected init to zero");
		[self setupMiniControls];
		NSAssert(!mUpdatingControls, @"Expected init to zero");
		NSAssert(mHitPart == kGCHitNone, @"Expected init to zero");
		
		if (mMiniControls == nil)
		{
			[self autorelease];
			self = nil;
		}
	}
	if (self != nil)
	{
		NSAssert([self isContinuous], @"Expected isContinuous set in base class");
	}
	return self;
}


#pragma mark -
#pragma mark As a GCMiniControl delegate
- (void)				miniControl:(GCMiniControl*) mc didChangeValue:(id) newValue
{
#pragma unused (newValue)
	// delegate method called for a change in any mini-control value. route the result to the appropriate
	// setting. Note - no need to call for redisplay, that has been done.
	
	if ( ! mUpdatingControls )
	{
	//	LogEvent_(kInfoEvent, @"miniControl '%@' didChangeValue '%@'", [mc identifier],  newValue);
		
		[self setControlledAttributeFromMiniControl:mc];
		
		if([[self controlView] isKindOfClass:[GCGradientWell class]])
			[(GCGradientWell*)[self controlView] syncGradientToControlSettings];
	}
}


- (float)		miniControlWillUpdateInfoWindow:(GCMiniControl*) mc withValue:(float) val
{
	if ([[mc identifier] isEqualToString:kSweepSegmentsControlID])
	{
		int seg = [mc value] * 50;
		if ( seg < 4 )
			seg = 0;		
		
		return seg;
	}
	else
		return val;
}


@end

