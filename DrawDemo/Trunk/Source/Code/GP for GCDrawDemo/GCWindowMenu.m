///**********************************************************************************************************************************
///  GCWindowMenu.m
///  GCDrawKitUI
///
///  Created by graham on 27/03/07.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "GCWindowMenu.h"

#import <GCDrawKit/LogEvent.h>


@implementation GCWindowMenu
#pragma mark As a GCWindowMenu
///*********************************************************************************************************************
///
/// method:			popUpWindowMenu:withEvent:forView:
/// scope:			public class method
/// overrides:		
/// description:	pops up a custom popup menu, tracks it, then hides it again with a fadeout
/// 
/// parameters:		<menu> the custom popup window to display
///					<event> the event to start the display with (usually from a mouse down)
///					<view> the view doing the popping up
/// result:			none
///
/// notes:			the menu is positioned with its top, left point just to the left of, and slightly below, the
///					point given in the event
///
///********************************************************************************************************************

+ (void)	popUpWindowMenu:(GCWindowMenu*) menu withEvent:(NSEvent*) event forView:(NSView*) view
{
	NSPoint loc = [event locationInWindow];
	loc.x -= 10;
	loc.y -= 5;
	
	[self popUpWindowMenu:menu atPoint:loc withEvent:event forView:view];
}


///*********************************************************************************************************************
///
/// method:			popUpWindowMenu:atPoint:withEvent:forView:
/// scope:			public class method
/// overrides:		
/// description:	pops up a custom popup menu, tracks it, then hides it again with a fadeout
/// 
/// parameters:		<menu> the custom popup window to display
///					<loc> the location within the view at which to display the menu (top, left of menu)
///					<event> the event to start the display with (usually from a mouse down)
///					<view> the view doing the popping up
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

+ (void)	popUpWindowMenu:(GCWindowMenu*) menu atPoint:(NSPoint) loc withEvent:(NSEvent*) event forView:(NSView*) view;
{
	// pop up a window menu, and track it until the mouse goes up. Implements standard menu behaviour
	// but uses a completely custom view. If <menu> is nil creates a default window. <loc> is the point in window
	// coordinates that <view> belongs to.
		
	if ( menu == nil )
		menu = [GCWindowMenu windowMenu];
	
	[menu retain];
	
	loc = [[view window] convertBaseToScreen:loc];
	[menu setFrameTopLeftPoint:loc];
	
	// show the "menu"
	
	[menu orderFront:self];
	
	// track the menu (keeps control in its own event loop):

	[menu trackWithEvent:event];
	
	// all done, tear down
	
	BOOL shift = NO; //(([[NSApp currentEvent] modifierFlags] & NSShiftKeyMask) != 0);
	
	[menu fadeWithTimeInterval:shift? 1.5 : 0.15];
	[menu release];
	
//	LogEvent_(kReactiveEvent, @"pop-up complete");
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			windowMenu
/// scope:			public class method
/// overrides:		
/// description:	makes a window menu that can be popped up using the above methods.
/// 
/// parameters:		none
/// result:			a new poppable window menu
///
/// notes:			this method just makes an empy window with the default size. It's up to you to add some useful
///					content before displaying it
///
///********************************************************************************************************************

+ (GCWindowMenu*)	windowMenu
{
	GCWindowMenu* fi =  [[GCWindowMenu alloc]  initWithContentRect:NSZeroRect
												styleMask:NSBorderlessWindowMask
												backing:NSBackingStoreBuffered
												defer:YES];
	
	// note - because windows are all sent a -close message at quit time, set it
	// not to be released at that time, otherwise the release from the autorelease pool
	// will cause a crash due to the stale reference

	[fi setReleasedWhenClosed:NO];	// **** important!! ****
	return [fi autorelease];
}


///*********************************************************************************************************************
///
/// method:			windowMenuWithContentView:
/// scope:			public class method
/// overrides:		
/// description:	makes a window menu that can be popped up using the above methods.
/// 
/// parameters:		<view> the view to display within the menu
/// result:			a new poppable window menu containing the given view
///
/// notes:			the window is sized to fit the frame of the view you pass.
///
///********************************************************************************************************************

+ (GCWindowMenu*)   windowMenuWithContentView:(NSView*) view
{
	GCWindowMenu* menu = [self windowMenu];
	
	[menu setMainView:view sizeToFit:YES];
	return menu;
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			trackWithEvent:
/// scope:			public instance method
/// overrides:		
/// description:	track the mouse in the menu
/// 
/// parameters:		<event> the initial starting event (will usually be a mouse down)
/// result:			none
///
/// notes:			tracking calls the main view's usual mouseDown/dragged/up methods, and tries to do so as compatibly
///					as possible with the usual view behaviours.
///
///********************************************************************************************************************

- (void)			trackWithEvent:(NSEvent*) event
{
	// tracks the "menu" by keeping control until a mouse up (or down, if menu 'clicked' into being)
	
//	LogEvent_(kReactiveEvent, @"starting tracking; initial event = %@", event);
		
	//[NSEvent startPeriodicEventsAfterDelay:1.0 withPeriod:0.1];
	
	NSTimeInterval startTime = [event timestamp];
	
	//[self setAcceptsMouseMovedEvents:YES];
	[[self mainView] mouseDown:[self transmogrify:event]];
	
	NSEvent* theEvent;
	BOOL keepOn = YES;
	unsigned int mask;
	BOOL invertedTracking = NO;
	
	mask = NSLeftMouseUpMask | NSLeftMouseDraggedMask |
			NSRightMouseUpMask | NSRightMouseDraggedMask |
			NSAppKitDefinedMask | NSFlagsChangedMask |
			NSScrollWheelMask;
 
	while (keepOn)
	{
		theEvent = [self transmogrify:[self nextEventMatchingMask:mask]];

		switch ([theEvent type])
		{
			//case NSMouseMovedMask:
			case NSRightMouseDragged:
			case NSLeftMouseDragged:
				[[self mainView] mouseDragged:theEvent];
				break;
			
			case NSRightMouseUp:
			case NSLeftMouseUp:
				// if this is within a very short time of the mousedown, leave the menu up but track it
				// using mouse moved and mouse down to end.
				
				if ([theEvent timestamp] - startTime < 0.25 )
				{
					invertedTracking = YES;
					mask |= ( NSLeftMouseDownMask | NSRightMouseDownMask );
				}
				else
				{
					[[self mainView] mouseUp:theEvent];
					keepOn = NO;
				}
				break;
				
			case NSRightMouseDown:
			case NSLeftMouseDown:
				if ( ! NSPointInRect([theEvent locationInWindow], [[self mainView] frame]))
					keepOn = NO;
				else
					[[self mainView] mouseDown:theEvent];
				break;

			case NSPeriodic:
				break;
				
			case NSFlagsChanged:
				[[self mainView] flagsChanged:theEvent];
				break;
				
			case NSAppKitDefined:
			//	LogEvent_(kReactiveEvent, @"appkit event: %@", theEvent);
				if([theEvent subtype] == NSApplicationDeactivatedEventType )
					keepOn = NO;
				break;
				
			case NSScrollWheel:
				[[self mainView] scrollWheel:theEvent];
				break;

			default:
				/* Ignore any other kind of event. */
				break;
		}
	}
	
	//[self setAcceptsMouseMovedEvents:NO];
	[self discardEventsMatchingMask:NSAnyEventMask beforeEvent:theEvent];
		
	//[NSEvent stopPeriodicEvents];
//	LogEvent_(kReactiveEvent, @"ending tracking...");
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			setMainView:sizeToFit:
/// scope:			public instance method
/// overrides:		
/// description:	sets the pop-up window's content to the given view, and optionally sizes the window to fit
/// 
/// parameters:		<aView> any view already created to be displayed in the menu
///					<stf> if YES, window is sized to the view's frame. If NO, the window size is not changed
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

- (void)			setMainView:(NSView*) aView sizeToFit:(BOOL) stf
{
	mMainViewRef = aView;
	
	// add as a subview which retains it as well
	
	[[self contentView] addSubview:aView];
	
	// if stf, position the view at top, left corner of the window and
	// make the window the size of the view
	
	if ( stf )
	{
		NSRect fr = [aView frame];
	
		fr.origin = NSZeroPoint;
		[aView setFrameOrigin:NSZeroPoint];
		[self setFrame:fr display:YES];
	}
	
	[mMainViewRef setNeedsDisplay:YES];
}


///*********************************************************************************************************************
///
/// method:			mainView
/// scope:			public instance method
/// overrides:		
/// description:	get the main view
/// 
/// parameters:		none
/// result:			the main view
///
/// notes:			
///
///********************************************************************************************************************

- (NSView*)			mainView
{
	return mMainViewRef;
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			fadeWithTimeInterval:
/// scope:			private instance method
/// overrides:		
/// description:	fades the window out
/// 
/// parameters:		<t> the total time to take to perform the fade out (0.15 is recommended as being close to a standard menu)
/// result:			none
///
/// notes:			this is called by the main popup method as needed
///
///********************************************************************************************************************

static	NSTimeInterval sFadeStartTime = 0.0;


- (void)			fadeWithTimeInterval:(NSTimeInterval) t
{
	// fades the window to invisible over <t> seconds. Used when the menu is closed.
	// retain ourselves so that the timer can run long after the window's owner has said goodbye.
	
	if ([self isVisible])
	{
		[self retain];
		
		sFadeStartTime = [NSDate timeIntervalSinceReferenceDate];
		
		[NSTimer scheduledTimerWithTimeInterval:1/30.0
					target:self
					selector:@selector(timerFadeCallback:)
					userInfo:[NSNumber numberWithDouble:t]
					repeats:YES];
	}
}


///*********************************************************************************************************************
///
/// method:			timerFadeCallback:
/// scope:			private instance method
/// overrides:		
/// description:	timer callback
/// 
/// parameters:		<timer> the timer
/// result:			none
///
/// notes:			when complete, the timer is automatically discarded and the window closed & released
///
///********************************************************************************************************************

- (void)			timerFadeCallback:(NSTimer*) timer
{
	NSTimeInterval total = [[timer userInfo] doubleValue];
	NSTimeInterval elapsed = [NSDate timeIntervalSinceReferenceDate] - sFadeStartTime;
	
	float fade = 1.0 - ( elapsed / total );
	
	[self setAlphaValue:fade];
	
	if ( elapsed > total )
	{
		[timer invalidate];
		[self orderOut:self];
		[self release];
	}
}


///*********************************************************************************************************************
///
/// method:			transmogrify:
/// scope:			private instance method
/// overrides:		
/// description:	convert the event to the local window if necessary
/// 
/// parameters:		<event> an event
/// result:			the same event, or a modified version
///
/// notes:			ensures that events received while tracking are always targetted at the right window
///
///********************************************************************************************************************

- (NSEvent*)		transmogrify:(NSEvent*) event
{
	if(([event window] != self) && [event isMouseEventType])
	{
		NSPoint glob = [[event window] convertBaseToScreen:[event locationInWindow]];

		return [NSEvent mouseEventWithType:	[event type]
						location:			[self convertScreenToBase:glob]
						modifierFlags:		[event modifierFlags]
						timestamp:			[event timestamp]
						windowNumber:		[self windowNumber]
						context:			[NSGraphicsContext currentContext]
						eventNumber:		[event eventNumber]
						clickCount:			[event clickCount]
						pressure:			[event pressure]];
	}
	else
		return event;
}


#pragma mark -
#pragma mark As an NSWindow
- (BOOL)			canBecomeMainWindow
{
	return YES;
}


- (id)	initWithContentRect:(NSRect) contentRect
		styleMask:(unsigned int) styleMask
		backing:(NSBackingStoreType) bufferingType
		defer:(BOOL) deferCreation
{
	self = [super initWithContentRect:contentRect
			styleMask:styleMask
			backing:bufferingType
			defer:deferCreation];
	if (self != nil)
	{
		NSAssert(mMainViewRef == nil, @"Expected init to zero");
	}
	if (self != nil)
	{
		[self setLevel:NSPopUpMenuWindowLevel];
		[self setHasShadow:YES];
		[self setAlphaValue:0.95];
		[self setReleasedWhenClosed:YES];
		[self setFrame:kGCDefaultWindowMenuSize display:NO];
	}
	return self;
}


@end


#pragma mark -
@implementation NSEvent (GCAdditions)

///*********************************************************************************************************************
///
/// method:			isMouseEventType:
/// scope:			public instance method
/// overrides:		
/// description:	checks event to see if it's any mouse event
/// 
/// parameters:		none
/// result:			YES if the event is a mouse event of any kind
///
/// notes:			
///
///********************************************************************************************************************

- (BOOL)	isMouseEventType
{
	// returns YES if type is any mouse type
	
	NSEventType t = [self type];
	
	return ( t == NSLeftMouseDown		||
			 t == NSLeftMouseUp			||
			 t == NSRightMouseDown		||
			 t == NSRightMouseUp		||
			 t == NSLeftMouseDragged	||
			 t == NSRightMouseDragged   ||
			 t == NSOtherMouseDown		||
			 t == NSOtherMouseUp		||
			 t == NSOtherMouseDragged );
}

@end
