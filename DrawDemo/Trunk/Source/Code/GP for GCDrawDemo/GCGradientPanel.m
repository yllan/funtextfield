//
//  DKGradientController.m
//  GradientTest
//
//  Created by Jason Jobe on 3/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GCGradientPanel.h"
#import "GCGradient.h"
#import "WTGradientControl.h"
#import "GCGradientCell.h"
#import "WTToolbar.h"
//#import "DKInspectorToolbar.h"
#import "DKSwatchMatrix.h"
#import "WTPlistKeyValueCoding.h"
#import "NSFolderManagerAdditions.h"
#import "GCGradientPasteboard.h"
#import "DKPresetNameController.h"
#import "GCGradientExtensions.h"
#import "GCGradientSegmentedControl.h"
#import "GCRecentItemsList.h"


@implementation GCGradientPanel


static NSString* s_gpDefaultLibPath = nil;



+ (GCGradientPanel*)	sharedGradientPanel
{
	static GCGradientPanel *sharedInstance = nil;

	if (sharedInstance == nil)
		sharedInstance = [[[self class] alloc] init];
	
	return sharedInstance;
}


+ (void)				setGradientPanelDefaultLibraryPath:(NSString*) path
{
	// pass nil to use the default path
	
	[path retain];
	[s_gpDefaultLibPath release];
	s_gpDefaultLibPath = path;
}


- (int)					version
{
	return 0x0111;   // version 1.1.1
}


- (id) init
{
	self = [self initWithWindowNibName:@"DKGradientPanel"];
	if (self != nil)
	{
		drawerMinSize = 14;
		drawerUserSize = 14;
		drawerPosition = 14;
		drawerMaxSize = 200;
		inDrawerOp = NO;
		
		_target = nil;
		_action = nil;
		
		_recentLibs = [[GCRecentItemsList alloc] init];
		
		//_um = [[NSUndoManager alloc] init];
	}
	return self;
}


- (void)		dealloc
{
	//[defaultLibrary release];
	//[_um release];
	[_recentLibs release];
	[super dealloc];
}


- (void)		setTarget:(id) aTarget
{
	_target = aTarget;
}


- (void)		setAction:(SEL) anAction
{
	_action = anAction;
}



- (id)			target
{
	return _target;
}



- (SEL)			action
{
	return _action;
}



- (void)		setGradient:(GCGradient*) grad
{
	[gWell setGradient:grad];
	[gControl setGradient:grad];
	[self setGradientType:[grad gradientType]];	// forces control mode of main well
}


- (GCGradient*) gradient
{
	return [gWell gradient];
}



- (NSPanel*)	panel
{
	return (NSPanel*)[self window];
}


- (void) takeGradientFromWell: sender
{
	[gControl setGradient:[sender gradient]];
	[gControl setNeedsDisplay:YES];
	[self setGradientType:[self gradientType]];	// forces control mode of main well
	[self dispatchToClients];
}

- (void) takeGradientFromControl: sender
{
	[gWell setGradient:[sender gradient]];
	[gWell setNeedsDisplay:YES];
	[self setGradientType:[self gradientType]];	// forces control mode of main well
	[self dispatchToClients];
}


- (void)	dispatchToClients
{
	//NSLog(@"dispatching to clients");
	
	// record the change for undo
	/*
	GCGradient* gc = [[self gradient] copy];
	
	[_um registerUndoWithTarget:self selector:@selector(setGradient:) object:gc];
	[gc release];
	*/
	[NSApp sendAction:@selector(changeGradient:) to:nil from:self];
	
	if ( _target && _action )
		[NSApp sendAction:_action to:_target from:self];
		
	if ([GCGradientWell activeWell])
		[[GCGradientWell activeWell] setGradient:[self gradient]];
}


- (IBAction) selectGradient: sender
{
	GCGradient *grad = [[sender selectedItem] representedObject];
	[self setGradient:grad];
}


- (NSMenu*) presetSelectionMenu:(NSMenu*) menu
{
	// add predefined gradients
	NSArray *presets = [GCGradient registeredGradients];
	if (presets == nil)
		[GCGradient initialize];
	
	NSEnumerator *curs = [[GCGradient registeredGradients] objectEnumerator];
	NSString *name;

	if ( menu == nil )
		menu = [[[NSMenu alloc] initWithTitle:@"Presets"] autorelease];
	else
	{
		int count = [menu numberOfItems];
		
		while( --count > 0 )
			[menu removeItemAtIndex:count];
	}
	
	NSMenuItem*  item;
	
	while (name = [curs nextObject])
	{
		GCGradient *grad = [GCGradient gradientWithName:name];
		item = (NSMenuItem*)[menu addItemWithTitle:[name capitalizedString] action:@selector(takePresetGradient:) keyEquivalent:@""];
		[item setImage:[grad standardSwatchImage]];
		[item setRepresentedObject:grad];
		[item setTarget:self];
	}
	
	[menu addItem:[NSMenuItem separatorItem]];
	item = (NSMenuItem*)[menu addItemWithTitle:NSLocalizedString(@"Clear Menu", @"") action:@selector(clearPresets:) keyEquivalent:@""];
	[item setTarget:self];
	
	return menu;
}


- (IBAction)	takePresetGradient:(id) sender
{
	[self setGradient:[sender representedObject]];
}


- (IBAction)	clearPresets:(id) sender
{
//	NSLog(@"clearing presets");
}


- (void)		setupToolbar
{	
	toolbar = [[WTToolbar alloc] initWithResource:@"GradientPanel"];

	[toolbar setTarget:self];
	[[self window] setToolbar:toolbar];
	[[self window] setDelegate:self];
}


- (void)		toolbar:(WTToolbar*) toolbar didLoadCustomView:(NSView*) view itemIdentifier:(NSString*) ident
{
	if ([ident isEqualToString:@"presets"] && [view isKindOfClass:[NSPopUpButton class]])
	{
		[self presetSelectionMenu:[(NSPopUpButton*)view menu]];
	}
	else if ([ident isEqualToString:@"types"] && [view isKindOfClass:[NSControl class]])
	{
		// need to install our custom cell class to handle the gradient selection
		
		// NSLog(@"Loaded segmented control %@", view);
		
		[(NSControl*) view setAction:@selector( takeGradientType: )];
		[(NSControl*) view setTarget:self];
	}
	else if ([ident isEqualToString:@"actions"] && [view isKindOfClass:[NSPopUpButton class]])
	{
		// remove the "Load Standard Library" if we don't have one (tag 100)
		
		NSMenu*			menu = [(NSPopUpButton*)view menu];
		NSMenuItem*		item; // == NSMenuItem*

		if ( 1 )
		{
			item  = (NSMenuItem*)[menu itemWithTag:100];
			if (item)
				[menu removeItem:item];
		}

		// add "Online Help" as alternate to existing Help item (tag 101)
		
		int ix = [menu indexOfItemWithTag:101];
		
		item = (NSMenuItem*)[menu insertItemWithTitle:NSLocalizedString(@"Online Help...", @"") action:@selector(onlineHelp:) keyEquivalent:@"" atIndex:ix + 1];
		[item setTarget:self];
		[item setAlternate:YES];
		[item setKeyEquivalentModifierMask:NSAlternateKeyMask];
		item = (NSMenuItem*)[menu insertItemWithTitle:NSLocalizedString(@"Credits...", @"") action:@selector(showCredits:) keyEquivalent:@"" atIndex:ix + 2];
		[item setTarget:self];
		[item setAlternate:YES];
		[item setKeyEquivalentModifierMask:NSAlternateKeyMask | NSShiftKeyMask];
	}
}


- (void) awakeFromNib
{
	// the main well has a special cell class and cannot become active

	[gWell setCell:[[GCGradientCell alloc] init]];
	[gWell setCanBecomeActiveWell:NO];
	
	[[self panel] setFloatingPanel:YES];
	[[self panel] setBecomesKeyOnlyIfNeeded:YES];
	[[self panel] setWorksWhenModal:YES];
	
	winHeight = [self positionOfDrawerEdge];
	drawerPosition = NSHeight( [[[self window] contentView] frame] ) - winHeight;
	drawerMaxSize = 400;//[[self window] contentMaxSize].height - winHeight;
	drawerUserSize = drawerMaxSize;
	
	[self setGradient:[GCGradient defaultGradient]];

	[gControl setTarget:self];
	[gControl setAction:@selector(takeGradientFromControl:)];
	[gControl setCanBecomeActiveWell:NO];
	
	[gWell setTarget:self];
	[gWell setAction:@selector(takeGradientFromWell:)];
	[gWell setDisplaysProxyIcon:NO];
	[gWell setForceSquare:YES];
	
	[self setupToolbar];
	[self loadUserConfiguration];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveUserConfiguration:)
												 name:NSApplicationWillTerminateNotification
												object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(swatchSizeChange:)
												 name:kDKSwatchDidChangeSizeNotification
											   object:gSwatchMatrix];
											   
	[gSwatchMatrix setDoubleAction:@selector(matrixDoubleClick:)];
	[gSwatchMatrix setTarget:self];
}


- (void)		dragProxyIconAtPoint:(NSPoint) startPoint fromControl:(NSControl*) control
{
	// called from main well proxy drag method if the icon is enabled and the user drags it
	// n.b. if the icon is turned off, this can never be called, so there is no point
	// in commenting out chunks of this. All else being right, this method will work as it
	// should when called upon by turning the icon feature on.
	
//	NSLog(@"target proxy icon drag method");
	
	static BOOL		isFirstUse = YES;
	
	NSPoint			p = [control convertPoint:startPoint toView:nil];
	NSImage*		icon = [NSImage imageNamed:@"gradienticonsmall"];
	NSSize			iconSize = [icon size];
	NSPasteboard*	pBoard = [NSPasteboard pasteboardWithName:NSDragPboard];
	
	p.x -= iconSize.width / 2.0;
	p.y -= iconSize.height / 2.0;
	
	// make icon slightly transparent:
	
	if ( isFirstUse )
	{
		[icon lockFocus];
		[icon drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:0.75];
		[icon unlockFocus];
		isFirstUse = NO;
	}
	
	// #### add data to the pasteboard here ####
	
	[[self gradient] writeFileToPasteboard:pBoard];
	
	// drag it
	
	[gWell dragStandardSwatchGradient:[self gradient] slideBack:YES event:[NSApp currentEvent]];
}

// User configuration support

- (NSString*)	configurationDirectory
{
	NSString* appSupportFolder = [[[NSFileManager defaultManager] applicationSupportFolder] stringByAppendingPathComponent:@"DKGradientPanel"];
	
	// need to create the subfolder if necessary
	
	NSFileManager*	fm = [NSFileManager defaultManager];
	
	if( ![fm fileExistsAtPath:appSupportFolder])
		[fm createDirectoryAtPath:appSupportFolder attributes:nil];
	
	return appSupportFolder;
}


- (NSString*)	defaultLibraryPath
{
	// GPC, v1.1 - use in order: a) path explicitly set, or b) path in user defaults, or c) default path
	
	if ( s_gpDefaultLibPath == nil )
	{
		NSString* name = [[NSUserDefaults standardUserDefaults] valueForKey:@"gradient_panel_default_lib_file"];
	
		if ( name == nil )
			return [[self configurationDirectory] stringByAppendingPathComponent:@"GPDefaults.gradients"];
		else
			return [[self configurationDirectory] stringByAppendingPathComponent:name];
	}
	else
		return s_gpDefaultLibPath;
}



/**
	We save the configuration in 2 parts. One is the actual panel settings, the
	2nd is saving the current swatch set as a standard formatted gradient library.
	The panel should really be app-specific so we use UserDefaults for that. The gradient
	library is User-specific so that is stored in ~/Library/Gradients directory, the "GPDefault"
	being the special name reserved for the panel.
*/

- (void)	saveUserConfiguration:(NSNotification*) note
{
	NSMutableDictionary *settings = [NSMutableDictionary dictionary];

	[settings setValue:[toolbar configurationDictionary] forKey:@"toolbarConfiguration"];
	[settings setValue:[[self window] stringWithSavedFrame] forKey:@"windowFrame"];
	[settings encodeInt:[self drawerPosition] forKey:@"drawerPosition"];
	[settings encodeInt:[gSwatchMatrix cellUserSize] forKey:@"swatchsize"];
	[settings encodeObject:[self gradient] forKey:@"mainGradient"];

	[[NSUserDefaults standardUserDefaults] setValue:settings forKey:@"gradient_panel_config"];
	[[NSUserDefaults standardUserDefaults] setValue:[[self defaultLibraryPath] lastPathComponent] forKey:@"gradient_panel_default_lib_file"];
	
	// Now the user's gradient library - this is the one situation we should preserve gaps
	
	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	[dict setValue:[gSwatchMatrix gradientsArrayPreservingGaps:YES] forKey:GCGradientsKey];
	[[dict archiveFromPropertyListFormat] writeToFile:[self defaultLibraryPath] atomically:YES];

	[_recentLibs saveToPrefsWithKeyRoot:@"gp_recent_library"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)		loadUserConfiguration;
{
	NSDictionary*	settings;
	
	[_recentLibs loadFromPrefsWithKeyRoot:@"gp_recent_library"];
	
	settings = [[NSUserDefaults standardUserDefaults] valueForKey:@"gradient_panel_config"];

	// the gradient library
	
	[self loadGradientLibrary:[self defaultLibraryPath] merging:NO addingToRecent:NO];

	id value;
	
	if (settings)
	{

		if (value = [settings valueForKey:@"toolbarConfiguration"])
			[toolbar setConfigurationFromDictionary:value];
		
		if (value = [settings valueForKey:@"drawerPosition"])
			[self setDrawerPosition:[value intValue]];

		if (value = [settings valueForKey:@"windowFrame"])
			[[self window] setFrameFromString:value];

		if (value = [settings valueForKey:@"mainGradient"])
			[self setGradient:[value unarchiveFromPropertyListFormat]];

		if (value = [settings valueForKey:@"swatchsize"])
			[gSwatchMatrix setCellUserSize:[value intValue]];
	}
	
	[self updateRecentLibraryMenu];
}


- (IBAction)	helpForGradientPanel:(id) sender
{
	NSString *locBookName = [[NSBundle bundleForClass:[self class]]
				objectForInfoDictionaryKey: @"CFBundleHelpBookName"];
	[[NSHelpManager sharedHelpManager] findString:@"DKGradientPanel"  inBook:locBookName];
}


- (IBAction)	onlineHelp:(id) sender
{
	NSURL* url = [NSURL URLWithString:@"http://www.gradientpanel.com/gphelp.htm"];
	
//	NSLog(@"opening online help: %@", [url absoluteString]);
	
	[[NSWorkspace sharedWorkspace] openURL:url];
}


- (IBAction)			showCredits:(id) sender
{
	// show credits dialog
	
	[NSApp beginSheet:credits modalForWindow:[self window] modalDelegate:self
					didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:@"credits"];
}

- (IBAction)			creditsOK:(id) sender
{
	[credits orderOut:self];
	[NSApp endSheet:credits returnCode:NSCancelButton];
}


- (IBAction)			openManual:(id) sender
{
	NSString* umfile;
	
	umfile = [[NSBundle bundleForClass:[self class]] pathForResource:@"User Manual" ofType:@"pdf"];
	[[NSWorkspace sharedWorkspace] openFile:umfile withApplication:@"Preview"];
}


- (IBAction)			openWebsite:(id) sender
{
	NSURL* url = [NSURL URLWithString:@"http://www.gradientpanel.com"];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

/*
- (IBAction)			undo:(id) sender
{
	[_um undo];
}


- (IBAction)			redo:(id) sender
{
	[_um redo];
}
*/

- (void)		writeGradientLibraryToFile:(NSString*) path atomically:(BOOL) atom
{
	[[self gradientLibraryPList] writeToFile:path atomically:atom];
	[_recentLibs addRecentItem:path];
	[self updateRecentLibraryMenu];
}


- (void)		savePanelDidEnd:(NSOpenPanel*) panel returnCode:(int)returnCode  contextInfo:(void*) contextInfo
{
	if (returnCode == NSOKButton)
	{
		[self writeGradientLibraryToFile:[panel filename] atomically:YES];
	}
}


- (IBAction)	saveLibrary: (id) sender
{
	NSSavePanel *panel = [NSSavePanel savePanel];
	[panel setTitle:@"Save Gradient Library"];
	[panel setRequiredFileType:@"gradients"];

	[panel beginSheetForDirectory:nil file:nil	modalForWindow:[self window]
					 modalDelegate:self didEndSelector:@selector(savePanelDidEnd:returnCode:contextInfo:) contextInfo:NULL];
}


- (IBAction)	recentLibrary:(id) sender
{
	NSString* path = [_recentLibs itemForIndexValue:[sender tag]];
	
	NSLog(@"recent library = %d, path = %@", [sender tag], path);
	
	if ( path )
		[self loadGradientLibrary:path merging:NO addingToRecent:YES];
	else
		[self updateRecentLibraryMenu];
}


- (void)		loadGradientLibrary:(NSString*) filename merging:(BOOL) merge addingToRecent:(BOOL) addRecent
{
	NSDictionary *lib = [[NSDictionary dictionaryWithContentsOfFile: filename] unarchiveFromPropertyListFormat];

	if (lib)
		[self setGradientLibraryWithPList:lib addToExisting:merge];
		
	if ( addRecent )
	{
		[_recentLibs addRecentItem:filename];
		[self updateRecentLibraryMenu];
	}
}


- (void)		updateRecentLibraryMenu
{
	NSPopUpButton*	actionMenu = (NSPopUpButton*)[toolbar viewWithIdentifier:@"actions"];
	NSMenu*			menu = [actionMenu menu];
	NSMenuItem*		item;
	
	item = (NSMenuItem*)[menu itemWithTag:442];
	[menu setSubmenu:[_recentLibs menuOfItemsWithAction:@selector(recentLibrary:) forTarget:self ] forItem:item];
}


- (void)		openPanelDidEnd:(NSOpenPanel*) oPanel returnCode:(int) returnCode  contextInfo:(void*) contextInfo
{
	if (returnCode == NSOKButton)
	{
        NSArray *filesToOpen = [oPanel filenames];
        int i = 0, count = [filesToOpen count];

		// We only want to apply user flag on 1st file because we assume that if multiple
		// files are selected then the set of them should be merged. The only question is
		// whether or not to clear the current set before loading these
		
		NSString *file = [filesToOpen objectAtIndex:i];
		[self loadGradientLibrary:file merging:![openMergeOption intValue] addingToRecent:YES];

		for (i = 1; i < count; i++)
		{
            NSString *file = [filesToOpen objectAtIndex:i];
            [self loadGradientLibrary:file merging:YES addingToRecent:YES];
        }
    }
}

- (IBAction)			loadStandardLibrary: (id) sender
{
}

- (IBAction)			loadLibrary: (id) sender
{
    NSArray *fileTypes = [NSArray arrayWithObjects:@"gradient", @"gradients", nil];
    NSOpenPanel *oPanel = [NSOpenPanel openPanel];
	
	[oPanel setAccessoryView:openAccessory];
    [oPanel setAllowsMultipleSelection:YES];
	[oPanel beginSheetForDirectory:nil file:nil types:fileTypes	modalForWindow:[self window]
					 modalDelegate:self didEndSelector:@selector(openPanelDidEnd:returnCode:contextInfo:) contextInfo:NULL];
    
}


- (NSArray*)			gradientLibrary
{
	// public accessors to get at lower level library data
	
	return [gSwatchMatrix gradientsArray];
}


- (NSDictionary*)		gradientLibraryPList
{
	// public accessors to get at lower level library data

	NSMutableDictionary * dict = [NSMutableDictionary dictionary];
	[dict setValue:[self gradientLibrary] forKey:GCGradientsKey];
	
	return [dict archiveFromPropertyListFormat];
}


- (void)				setGradientLibrary:(NSArray*) lib addToExisting:(BOOL) merge
{
	[gSwatchMatrix loadGradients:lib merge:merge];
}


- (void)				setGradientLibraryWithPList:(NSDictionary*) dict addToExisting:(BOOL) merge
{
	[self setGradientLibrary:[dict valueForKey:GCGradientsKey] addToExisting:merge];
}




- (IBAction)			addToPresets:(id) sender
{
//	NSLog(@"add to preset...");
	[namingController askUserForNameWithParentWindow:[self window] delegate:self];
}


- (void)				sheetDidEnd:(NSWindow*) sheet returnCode:(int) returnCode contextInfo:(void *) contextInfo
{
	if ( returnCode == NSOKButton )
	{
		if([@"preset_name" isEqualToString:contextInfo])
		{
			NSString* name = [namingController name];
			
//			NSLog(@"adding preset name = '%@'", name );
			
			if ( name && [name length] > 0 )
			{
				[GCGradient registerGradient:[self gradient] withName:name];
				
				// need to rebuild the menu if it exists yet
				
				NSMenu* presetMenu = [(NSPopUpButton*)[toolbar viewWithIdentifier:@"presets"] menu];
				
				if ( presetMenu )
					[self presetSelectionMenu:presetMenu];
			}
		}
	}
}



- (int)			gradientType
{
	return [[gWell gradient] gradientType];
}

- (void)		setGradientType:(int) type
{
	//NSLog(@"setting gradient type = %d", type );
	
	[[gWell gradient] setGradientType:type];
	
	GCGradientSegmentedControl* ctl = (GCGradientSegmentedControl*)[toolbar viewWithIdentifier:@"types"];
	
	// set the control mode of the main well to match the gradient's type
	
	switch( type )
	{
		case kGCGradientTypeLinear:
			[gWell setControlMode:kGCGradientWellAngleMode];
			[ctl setSelectedSegment:0];
			break;
			
		case kGCGradientTypeRadial:
			[gWell setControlMode:kGCGradientWellRadialMode];
			[ctl setSelectedSegment:1];
			break;
			
		case kGCGradientSweptAngle:
			[gWell setControlMode:kGCGradientWellSweepMode];
			[ctl setSelectedSegment:2];
			break;
			
		default:
			[gWell setControlMode:kGCGradientWellDisplayMode];
			break;
	}
	
	[gWell setNeedsDisplay:YES];
	[self dispatchToClients];
}

- (IBAction)	takeGradientType:(id) sender
{
	if ([sender selectedSegment] != [self gradientType])
		[self setGradientType:[sender selectedSegment]];
}

- (IBAction)	flip:(id) sender
{
	[gControl flip:sender];
}


- (IBAction)	show: sender;
{
	[[self window] orderFront:sender];
}


- (IBAction)	hide:(id) sender
{
	[[self window] orderOut:sender];
}


- (IBAction)	matrixDoubleClick:(id) sender
{
//	NSLog(@"matrix dbl-click");
	
	GCGradient* grad = [[[sender selectedCell] gradient] copy];
	
	if ( grad )
	{
		[self setGradient:grad];
		[grad release];
	}
}


- (void)		setWindowSwatchDrawerLocation:(NSPoint) point
{
	// this is the primitive method used to implement the "drawer" extension of the window. The window is extended
	// so that its bottom edge lies at the y coordinate of point (in screen coordinates)
	
	point.y -= 5;
	
	NSRect fr = [[self window] frame];
	
	int		change = point.y - fr.origin.y;
	
	[self setDrawerPosition:drawerPosition - change];
}


- (void)		trackWindowSwatchDrawerWithEvent:(NSEvent*) event
{
	//NSLog(@"starting track of window drawer...");
	
	[[NSCursor currentCursor] push];
	[[NSCursor closedHandCursor] set];
	NSPoint  currentPoint = [[event window] convertBaseToScreen:[event locationInWindow]];
	
	[self setWindowSwatchDrawerLocation:currentPoint];
	
	unsigned int	mask;
	BOOL			loop = YES;

	mask = NSLeftMouseUpMask | NSLeftMouseDraggedMask;

	while( loop )
	{
		event = [[self window] nextEventMatchingMask:mask];
		
		//NSLog(@"event = %@", event);
		
		currentPoint = [[event window] convertBaseToScreen:[event locationInWindow]];
				
		switch([event type])
		{
			case NSLeftMouseUp:
				loop = NO;
				break;
				
			case NSLeftMouseDragged:
				[self setWindowSwatchDrawerLocation:currentPoint];
				break;
				
			case NSFlagsChanged:
				break;
				
			default:
				break;
		}
	}
	
	[[self window] discardEventsMatchingMask:NSAnyEventMask beforeEvent:event];
	
	// set user size if not closed altogether

	if ( ![self isDrawerClosed])
	{
		// align to nearest whole row:
		
		[self swatchSizeChange:nil];
		drawerUserSize = drawerPosition;
	}
	[NSCursor pop];
	//NSLog(@"window tracking complete");
}


static NSTimeInterval	s_startTime = 0.0;
static NSTimer*			s_animTimer = nil;


 - (void)		timerDrawerAnimationCallback:(NSTimer*) timer
{
	NSTimeInterval total = [[[timer userInfo] valueForKey:@"interval"] doubleValue];
	NSTimeInterval elapsed = [NSDate timeIntervalSinceReferenceDate] - s_startTime;
	int				 pos = [[[timer userInfo] valueForKey:@"position"] intValue];
	int				 stp = [[[timer userInfo] valueForKey:@"start_position"] intValue];
	
	int dp = stp + (( elapsed / total ) * (pos - stp));
	
	if ( stp < pos && dp > pos )
		dp = pos;
		
	if ( pos < stp && dp < pos )
		dp = pos;
	
	[self setDrawerPosition:dp];
	
	if ( elapsed > total )
	{
		[timer invalidate];
		s_animTimer = nil;
	}
}


- (void)		setDrawerPosition:(int) pos animate:(BOOL) animate
{
	if ( s_animTimer != nil )
	{
		// already animating, so abort that and start again
		
		[s_animTimer invalidate];
		s_animTimer = nil;
	}

	if ( animate )
	{
		s_startTime = [NSDate timeIntervalSinceReferenceDate];
		
		NSTimeInterval	t = 0.15;
		
		NSDictionary*	userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:pos], @"position",
																				[NSNumber numberWithDouble:t], @"interval",
																				[NSNumber numberWithInt:drawerPosition], @"start_position", nil];

		s_animTimer = [NSTimer scheduledTimerWithTimeInterval:1/30.0
					target:self
					selector:@selector(timerDrawerAnimationCallback:)
					userInfo:userInfo
					repeats:YES];
		
	}
	else
		[self setDrawerPosition:pos];
}


- (void)		setDrawerPosition:(int) pos
{
	// programmatically set drawer location relative to window, where <pos> is distance in pixels
	// from the "bottom" of the window without the drawer. In other words, adding pos to the "closed" height
	// gives the window height. This honours the min and max limits set for the drawer.
	
	pos = MAX( drawerMinSize, MIN( drawerMaxSize, pos ));
	
	// snap shut?
	
	if ( pos < ( drawerMinSize + 20 ))
		pos = drawerMinSize;
		
	// snap to other positions?
	
	pos = [self findSnapPositionNearest:pos];

	if ( pos != drawerPosition )
	{
		inDrawerOp = YES;
		
		float	dh =  pos - drawerPosition;
		
		drawerPosition = pos;
			
		//NSLog(@"setting drawer = %d, rel = %f", drawerPosition, dh );

		NSRect	svr, wFrame = [[self window] frame];
		
		wFrame.origin.y -= dh;
		wFrame.size.height += dh;
				
		// compensate content min/max sizes to account for the drawer extension

		NSSize ns = [[self window] contentMinSize];
		ns.height += dh;
		[[self window] setContentMinSize:ns];
		
		ns = [[self window] contentMaxSize];
		ns.height += dh;
		[[self window] setContentMaxSize:ns];
		
		// resize/position all primary views to compensate
		
		[[[self window] contentView] setAutoresizesSubviews:NO];
	
		NSEnumerator*	iter = [[[[self window] contentView] subviews] objectEnumerator];
		NSView*			sv;
		while( sv = [iter nextObject])
		{
			svr = [sv frame];
			svr.origin.y += dh;
			[sv setFrame:svr];
		}

		// manually resize the swatch view to fit the window
		
		svr = [gSwatchMatrix frame];
		svr.size.height += dh;
		svr.origin.y -= dh;
		[gSwatchMatrix setFrame:svr];
		
		// likewise the actual drag widget
		
		svr = [gDrawerDragControl frame];
		svr.origin.y -= dh;
		[gDrawerDragControl setFrame:svr];
		
		[[self window] setFrame:wFrame display:YES animate:NO];
		[[[self window] contentView] setAutoresizesSubviews:YES];

		inDrawerOp = NO;
	}
}


- (int)			drawerPosition
{
	return drawerPosition;
}


- (int)			positionOfDrawerEdge
{
	// the drawer edge is the position of the dividing line (gDrawerTopEdge) relative to the
	// top of the content view.

	NSRect	cvb = [[[self window] contentView] frame];//[[gDrawerTopEdge superview] frame];
	NSRect	def = [gDrawerTopEdge frame];
	
	//NSLog(@"sv height %f, y pos %f", NSHeight( cvb ), NSMinY( def ));
	int pos = NSHeight( cvb ) - NSMinY( def );
	
	//NSLog(@"drawer edge: %d", pos );
	
	return pos;
}

#define kGCDrawerSnapLimit		9


- (int)					findSnapPositionNearest:(int) pos
{
	NSIndexSet* snaps = [self drawerSnapPositions];
	
	if ( snaps )
	{
		int k = [snaps firstIndex];
		
		do
		{
			if ( ABS( pos - k ) <= kGCDrawerSnapLimit )
				return k;
				
			k = [snaps indexGreaterThanIndex:k];
		}
		while( k != NSNotFound );
	}
	
	return pos;
}


- (NSIndexSet*)			drawerSnapPositions
{
	// return an index set of values to get the drawer to snap gently at those positions. nil
	// means no snap.
	
	NSMutableIndexSet*	mix = [[NSMutableIndexSet alloc] init];
	
	NSSize	cs = [gSwatchMatrix cellSize];
	NSSize	ics = [gSwatchMatrix intercellSpacing];
	
	int i, k = drawerMinSize / 2;
	
	for( i = drawerMinSize; i <= drawerMaxSize; ++i )
	{
		k += cs.height + ics.height;
		
		[mix addIndex:k + drawerMinSize];
	}
	
	return [mix autorelease];
}


- (IBAction)	toggleDrawer:(id) sender
{
	// toggles drawer between user size and closed
	
	if ([self isDrawerClosed])
		[self setDrawerPosition:drawerUserSize animate:YES];
	else
		[self setDrawerPosition:drawerMinSize animate:YES];
}


- (void)		swatchSizeChange:(NSNotification*) note
{
	//NSLog(@"swatch size change notification");
	// tweak the drawer position so it moves to the nearest whole number of rows
	
	// if drawer closed, leave it closed
	
	if ([self isDrawerClosed])
		return;
	
	int			pos = drawerPosition, closest = 10000;
	
	NSIndexSet* snaps = [self drawerSnapPositions];
	
	if ( snaps )
	{
		int k = [snaps firstIndex];
		
		while( k != NSNotFound )
		{
			if ( ABS( drawerPosition - k ) < closest )
			{
				closest = ABS( drawerPosition - k );
				pos = k;
			}
				
			k = [snaps indexGreaterThanIndex:k];
		}
		
		[self setDrawerPosition:pos animate:YES];
	}
}


- (BOOL)		isDrawerClosed
{
	return drawerPosition < ( drawerMinSize + 20 );
}

/*
- (NSSize)		windowWillResize:(NSWindow*) win toSize:(NSSize) proposedSize
{
	// limit downward resize if the main well is at its max horizontal fit.
	
	NSSize ps = proposedSize;
	
	NSRect  mwf = [gWell frame];
	
	if ( mwf.size.width >= ( ps.width - 30) )
		ps.height = MIN( ps.height, [win frame].size.height );

	return ps;
}
*/

@end

#pragma mark -

@implementation DKDrawerDragView


- (BOOL)		acceptsFirstMouse:(NSEvent*) theEvent
{
	return YES;
}


- (void)		drawRect:(NSRect) rect
{
	NSRect kr;

	NSImage* dh = [self imageNamed:@"drawerhandle" fromBundleForClass:[self class]];
	
	if ( dh )
	{
		kr = NSMakeRect( 0, 0, [dh size].width, [dh size].height );
		kr = NSOffsetRect( kr, NSMidX([self bounds]) - kr.size.width / 2.0, NSMidY([self bounds]) - kr.size.height / 2.0 );

		[dh drawInRect:kr fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:1.0];
	}
	else
	{
		NSRect kr = NSMakeRect( 0, 0, 5, 5 );
		kr = NSOffsetRect( kr, NSMidX([self bounds]) - 2.5, NSMidY([self bounds]) - 2.5 );
		NSBezierPath* path = [NSBezierPath bezierPathWithOvalInRect:kr];
		
		[[NSColor lightGrayColor] set];
		[path fill];
		[[NSColor blackColor] set];
		[path setLineWidth:0.5];
		[path stroke];
	}
}


- (void)		mouseDown:(NSEvent*) event
{
	if([event clickCount] >= 2 )
		[_controller toggleDrawer:self];
	else
		[_controller trackWindowSwatchDrawerWithEvent:event];
}


@end



@implementation NSObject (ImageResources)

- (NSImage*)		imageNamed:(NSString*) name fromBundleForClass:(Class) class
{
	NSString *path = [[NSBundle bundleForClass:class] pathForImageResource:name];
	NSImage *image = [[NSImage alloc] initByReferencingFile:path];
	if (image == nil)
		NSLog(@"ERROR: Unable to locate image resource '%@'", name);
	return [image autorelease];
}


@end
