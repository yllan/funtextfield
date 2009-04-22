//
//  GCGradientWell.m
//  GradientTest
//
//  Created by Jason Jobe on 3/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GCGradientWell.h"

#import "GCGradientCell.h"
#import "GCGradientPasteboard.h"
#import "NSFolderManagerAdditions.h"

#import "GCDrawKit/DKGradientExtensions.h"
#import <GCDrawKit/LogEvent.h>


#pragma mark Static Vars
static GCGradientWell*		sCurrentActiveWell	= nil;


#pragma mark -
@implementation GCGradientWell
#pragma mark As a GCGradientWell
+ (void)	setActiveWell:(GCGradientWell*) well
{
	if ( well != sCurrentActiveWell && [well canBecomeActiveWell])
	{
		[sCurrentActiveWell wellWillResignActive];
		sCurrentActiveWell = well;
		[sCurrentActiveWell wellDidBecomeActive];
	}
}


+ (GCGradientWell*)	activeWell
{
	return sCurrentActiveWell;
}


+ (void)	clearAllActiveWells
{
	[self setActiveWell:nil];
}


#pragma mark -
- (void)		setGradient:(DKGradient*) aGradient
{
	if([self gradient] != aGradient )
	{
		[[self cell] setGradient:aGradient];
		[self setNeedsDisplay:YES];
		[self syncGradientToControlSettings];
	}
}


- (DKGradient*) gradient
{
	return [(GCGradientCell*)[self cell] gradient];
}


- (void)		syncGradientToControlSettings
{
	//LogEvent_(kReactiveEvent, @"synching target/action, target = %@, action = %@", [self target], NSStringFromSelector([self action]));
	
	if ( !mIsSendingAction )
	{
		mIsSendingAction = YES;
		[self setNeedsDisplay:YES];
		[self sendAction:[self action] to:[self target]];
		mIsSendingAction = NO;
	}
}


- (void)		initiateGradientDragWithEvent:(NSEvent*) theEvent
{
	[[self gradient] writeFileToPasteboard:[NSPasteboard pasteboardWithName:NSDragPboard]];
	[self dragStandardSwatchGradient:[self gradient] slideBack:YES event:theEvent];	
}


#pragma mark -
- (void)		setControlMode:(int) mode
{
	if ( mControlMode != mode )
	{
		mControlMode = mode;
		[self setNeedsDisplay:YES];
		//[self setupTrackingRect];
		
	}
	//[(GCGradientCell*)[self cell] updateMiniControlsForMode:mode];
}


- (int)			controlMode
{
	return mControlMode;
}


#pragma mark -
- (void)		setDisplaysProxyIcon:(BOOL) proxy
{
	mShowProxyIcon = proxy;
}


- (BOOL)		displaysProxyIcon
{
	return mShowProxyIcon;
}


#pragma mark -
- (void)		setupTrackingRect
{
//	LogEvent_(kStateEvent, @"setting tracking rect");
	
	if([[self cell] isKindOfClass:[GCGradientCell class]])
	{
		if ( mTrackingTag != 0 )
			[self removeTrackingRect:mTrackingTag];
		
		NSPoint loc=[self convertPoint:[[self window] mouseLocationOutsideOfEventStream] fromView:nil];
		BOOL inside=([self hitTest:loc]==self);
		
		if ( inside )
			[[self window] makeFirstResponder:self];
			
		//NSRect fr = [self frame];
		//fr.origin = NSZeroPoint;
		
		mTrackingTag = [self addTrackingRect:[self visibleRect] owner:self userData:nil assumeInside:inside];
	}
}


- (void)		setForceSquare:(BOOL) fsq
{
	mForceSquare = fsq;
}


#pragma mark -
- (void)		setCanBecomeActiveWell:(BOOL) canbecome
{
	mCanBecomeActive = canbecome;
}


- (BOOL)		canBecomeActiveWell
{
	return mCanBecomeActive;
}


- (BOOL)		isActiveWell
{
	return ([GCGradientWell activeWell] == self);
}


- (void)		wellDidBecomeActive
{
	[self setNeedsDisplay:YES];
	
	// copy its gradient to the GP, if it has one
	
	if ([self gradient])
	{
		DKGradient* copyGrad = [[self gradient] copy];
		//[[GCGradientPanel sharedGradientPanel] setGradient:copyGrad];
		[copyGrad release];
	}
	else
	{
		// should we do this?
		
		//[self setGradient:[[GCGradientPanel sharedGradientPanel] gradient]];
	}

	//[[GCGradientPanel sharedGradientPanel] show:self];
}


- (void)		wellWillResignActive
{
	// set our own gradient to a copy so as to fully detach it from the GP
	if ([self gradient])
	{
		DKGradient* copyGrad = [[self gradient] copy];
		[self setGradient:copyGrad];
		[copyGrad release];
	}

	[self setNeedsDisplay:YES];
}


- (void)		toggleActiveWell
{
	// if already the active well, turn off all active wells, otherwise, make it the active well
	
	if([self isActiveWell])
		[GCGradientWell clearAllActiveWells];
	else
		[GCGradientWell setActiveWell:self];
}


#pragma mark -
- (IBAction)		cut:(id) sender
{
	[self copy:sender];
	[self setGradient:nil];
}


- (IBAction)		copy:(id) sender
{
#pragma unused (sender)
	[[self gradient] writeToPasteboard:[NSPasteboard generalPasteboard]];
}


- (IBAction)		copyImage:(id) sender
{
#pragma unused (sender)
	NSPasteboard *pboard = [NSPasteboard generalPasteboard];
	DKGradient *grad = [self gradient];
	[pboard declareTypes:[NSArray arrayWithObject:NSPDFPboardType] owner:grad];
	[grad writeType:NSPDFPboardType toPasteboard:[NSPasteboard generalPasteboard]];
	[grad writeType:NSTIFFPboardType toPasteboard:[NSPasteboard generalPasteboard]];
}


- (IBAction)		copyBorderedImage:(id) sender
{
#pragma unused (sender)
	NSPasteboard *pboard = [NSPasteboard generalPasteboard];
	DKGradient *grad = [self gradient];
	[pboard declareTypes:[NSArray arrayWithObject:NSTIFFPboardType] owner:grad];
	NSImage* image = [grad swatchImageWithSize:NSMakeSize(128.0f, 128.0f) withBorder:YES];
	[pboard setData:[image TIFFRepresentation] forType:NSTIFFPboardType];
}


- (IBAction)		paste:(id) sender
{
#pragma unused (sender)
	[self setGradient:[DKGradient gradientWithPasteboard:[NSPasteboard generalPasteboard]]];
	
	if ([self isActiveWell])
	{
		// update GP with dropped gradient too
		
		DKGradient* copyGrad = [[self gradient] copy];
		//[[GCGradientPanel sharedGradientPanel] setGradient:copyGrad];
		[copyGrad release];
	}
}


- (IBAction)		delete:(id) sender
{
#pragma unused (sender)
	[self setGradient:nil];

	NSPoint globalLoc;
	NSRect	cf;
	
	cf = [self bounds];
	globalLoc.x = NSMidX( cf );
	globalLoc.y = NSMidY( cf );
	
	globalLoc = [self convertPoint:globalLoc toView:nil];
	globalLoc = [[self window] convertBaseToScreen:globalLoc];
	
	NSShowAnimationEffect(NSAnimationEffectDisappearingItemDefault, globalLoc, NSZeroSize, nil, nil, nil );
}


- (IBAction)		resetRadial:(id) sender
{
	if([self controlMode] == kGCGradientWellRadialMode)
#pragma unused (sender)
	{
		[[self gradient] setRadialStartingPoint:NSMakePoint( 0.5, 0.5 )];
		[[self gradient] setRadialEndingPoint:NSMakePoint( 0.5, 0.5 )];
		[[self gradient] setRadialStartingRadius:0.0];
		[[self gradient] setRadialEndingRadius:0.5];
	}
	else if ([self controlMode] == kGCGradientWellSweepMode)
	{
		[[self gradient] setRadialStartingPoint:NSMakePoint( 0.5, 0.5 )];
	}
	[self syncGradientToControlSettings];
	[self setNeedsDisplay:YES];
}


#pragma mark -
#pragma mark As an NSControl
+ (Class)	cellClass
{
    return [DKGradientCell class];
}


#pragma mark -
#pragma mark As an NSView
- (BOOL)	acceptsFirstMouse:(NSEvent *)theEvent
{
#pragma unused (theEvent)
	return YES;
}


- (id)		initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
	{
		[self setControlMode:kGCGradientWellDisplayMode];
		NSAssert(mTrackingTag == 0, @"Expected init to zero");
		NSAssert(!mForceSquare, @"Expected init to zero");
		NSAssert(!mShowProxyIcon, @"Expected init to zero");
		mCanBecomeActive = YES;
    }
    return self;
}


- (BOOL)	isFlipped
{
	return YES;
}


- (NSMenu*) menuForEvent:(NSEvent*) theEvent;
{
#pragma unused (theEvent)
	NSMenu*		contextualMenu = [[NSMenu alloc] initWithTitle:@"GradientWell"];
	NSMenuItem*	item;
	BOOL		allowsClear;
	
	allowsClear = mCanBecomeActive && ![[self cell] isKindOfClass:[GCGradientCell class]];

	// add "Copy" and "Paste" command
	
	if ( allowsClear )
	{
		item = (NSMenuItem*)[contextualMenu addItemWithTitle:NSLocalizedString(@"Cut", @"") action:@selector(cut:) keyEquivalent:@""];
		[item setTarget:self];
	}
	item = (NSMenuItem*)[contextualMenu addItemWithTitle:NSLocalizedString(@"Copy Gradient", @"") action:@selector(copy:) keyEquivalent:@""];
	[item setTarget:self];
	item = (NSMenuItem*)[contextualMenu addItemWithTitle:NSLocalizedString(@"Paste Gradient", @"") action:@selector(paste:) keyEquivalent:@""];
	[item setTarget:self];
	if ( allowsClear )
	{
		item = (NSMenuItem*)[contextualMenu addItemWithTitle:NSLocalizedString(@"Delete", @"") action:@selector(delete:) keyEquivalent:@""];
		[item setTarget:self];
		[contextualMenu addItem:[NSMenuItem separatorItem]];
	}
	
	item = (NSMenuItem*)[contextualMenu addItemWithTitle:NSLocalizedString(@"Copy Image", @"")
									 action:@selector(copyImage:) keyEquivalent:@""];
	[item setTarget:self];
	
	item = (NSMenuItem*)[contextualMenu addItemWithTitle:NSLocalizedString(@"Copy Bordered Image", @"")
									 action:@selector(copyBorderedImage:) keyEquivalent:@""];
	[item setTarget:self];
	[item setAlternate:YES];
	[item setKeyEquivalentModifierMask:NSAlternateKeyMask];
	
	if([self controlMode] == kGCGradientWellRadialMode || [self controlMode] == kGCGradientWellSweepMode)
	{
		[contextualMenu addItem:[NSMenuItem separatorItem]];
		item = (NSMenuItem*)[contextualMenu addItemWithTitle:NSLocalizedString(@"Reset Radial Gradient", @"") action:@selector(resetRadial:) keyEquivalent:@""];
		[item setTarget:self];
	}

	return [contextualMenu autorelease];
}


-(void)			resetCursorRects
{
	[super resetCursorRects];
	[self setupTrackingRect];
}


- (void)		setFrame:(NSRect) frame
{
	if ( mForceSquare )
	{
		// if forced to be square, the frame size will be set to be the maximum size
		// that will fit squarely in the superview. (the other dimension is centred).
		// !!!---this assumes that the superview is set up to do the right thing---!!!
		
		NSSize ss = [[self superview] frame].size;
		
		float smaller = MIN( ss.width, ss.height );
		smaller -= 20;
		
		frame.size.width = frame.size.height = smaller;
		
		smaller /= 2.0;
		
		if ( frame.size.width < ss.width )
			frame.origin.x = ( ss.width / 2.0 ) - smaller;
		
		if ( frame.size.height < ss.height )
			frame.origin.y = ( ss.height / 2.0 ) - smaller;
	}
	
	[super setFrame:frame];
	[self setupTrackingRect];
	[[self superview] setNeedsDisplay:YES];
}


- (void)		viewDidMoveToWindow
{
	if([self window])
		[self setupTrackingRect];
}


#pragma mark -
#pragma mark As an NSResponder
- (void)		mouseEntered:(NSEvent*) event
{
#pragma unused (event)
//	LogEvent_(kReactiveEvent,  @"mouse went in..." );
	
	//[super mouseEntered:event];
	[[self cell] setControlVisible:YES];
}


- (void)		mouseExited:(NSEvent*) event
{
#pragma unused (event)
//	LogEvent_(kReactiveEvent,  @"...mouse went out" );

	[[self cell] setControlVisible:NO];
	//[super mouseExited:event];
}


#pragma mark -
#pragma mark As an NSObject
- (void)	dealloc
{
	[self removeTrackingRect:mTrackingTag];
	
	[super dealloc];
}


#pragma mark -
#pragma mark As part of NSDraggingDestination Protocol


- (NSDragOperation)	draggingEntered:(id <NSDraggingInfo>)sender
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


- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL) isLocal
{
#pragma unused (isLocal)
	return NSDragOperationGeneric;
}


- (BOOL)		performDragOperation:(id <NSDraggingInfo>) sender
{
    NSPasteboard *pboard;
    NSDragOperation sourceDragMask;
	
    sourceDragMask = [sender draggingSourceOperationMask];
    pboard = [sender draggingPasteboard];
	
	if ( [sender draggingSource] != self )
	{
		if ( [DKGradient canInitalizeFromPasteboard:pboard])
		{
			DKGradient *gradient = [DKGradient gradientWithPasteboard:pboard];
			if (gradient)
				[self setGradient:gradient];
			
		}
		else if ([[pboard types] containsObject:NSColorPboardType])
		{
			
			NSColor*	colour = [NSColor colorFromPasteboard:pboard];
			DKGradient* grad = [[self gradient] gradientByColorizingWithColor:colour];
			
		//	LogEvent_(kReactiveEvent, @"received colour drag, colourizing. %@", grad);
			if ( grad )
				[self setGradient:grad]; 
		}
	}
	
	if([[self cell] isKindOfClass:[GCGradientCell class]])
		[[self cell] setControlVisible:YES];
    else if ([self isActiveWell])
	{
		// update GP with dropped gradient too
		
		DKGradient* copyGrad = [[self gradient] copy];
		//[[GCGradientPanel sharedGradientPanel] setGradient:copyGrad];
		[copyGrad release];
	}
	
	return YES;
}


#pragma mark -
#pragma mark As part of NSDraggingInfo Protocol
///*********************************************************************************************************************
///
/// method:			namesOfPromisedFilesDroppedAtDestination:
/// scope:			public instance method
/// overrides:		NSObject <NSDraggingSource>
/// description:	creates the gradient file on demand when a file drop takes place
/// 
/// parameters:		<dropDestination> the destination within the filesystem
/// result:			an array of created filenames 
///
/// notes:			this actually creates the file here since it is only one and is small. This determines a
///					unique default name at the destination by appending digits until no conflicts remain.
///
///********************************************************************************************************************

- (NSArray *)		namesOfPromisedFilesDroppedAtDestination:(NSURL*) dropDestination
{	
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *path = [fm writeContents:[[self gradient] fileRepresentation] toUniqueFile:@"untitled gradient.gradient" inDirectory:[dropDestination path]];
	
	if ( path )
		return [NSArray arrayWithObject:[path lastPathComponent]];
	else
		return nil;
}


#pragma mark -
#pragma mark As part of NSMenuValidation Protocol
- (BOOL)	validateMenuItem:(NSMenuItem*) item
{
	BOOL	enable = ([self gradient] != nil);
	SEL		act = [item action];
	
	if ( act == @selector( paste: ))
	{
		enable = [[NSPasteboard generalPasteboard] availableTypeFromArray:[NSArray arrayWithObject:GPGradientPasteboardType]] != nil;
	}
	
	return enable;
}


#pragma mark -
#pragma mark As part of NSNibAwaking Protocol
- (void) awakeFromNib
{
	[self registerForDraggedTypes:[DKGradient readablePasteboardTypes]];
	[self registerForDraggedTypes:[NSArray arrayWithObject:NSColorPboardType]];
}


@end
