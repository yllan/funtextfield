//
//  DKGradientController.h
//  GradientTest
//
//  Created by Jason Jobe on 3/25/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class GCGradient, GCGradientWell, WTGradientControl, DKSwatchMatrix, WTToolbar, DKGradientController, GCRecentItemsList;





@interface GCGradientPanel : NSWindowController
{
	IBOutlet GCGradientWell*		gWell;
	IBOutlet WTGradientControl*		gControl;
	IBOutlet DKSwatchMatrix*		gSwatchMatrix;
	IBOutlet NSView*				gDrawerTopEdge;
	IBOutlet NSView*				gDrawerDragControl;
	IBOutlet NSView*				openAccessory;
	IBOutlet NSControl*				openMergeOption;
	IBOutlet NSView*				saveAccessory;
	IBOutlet id						namingController;
	IBOutlet id						credits;
	WTToolbar*						toolbar;
	id								_target;
	SEL								_action;
	GCRecentItemsList*				_recentLibs;
	int								winHeight;
	int								drawerPosition;
	int								drawerMinSize;
	int								drawerMaxSize;
	int								drawerUserSize;
	BOOL							inDrawerOp;
	int								maxRecentLibraries;
}

+ (GCGradientPanel*)	sharedGradientPanel;
+ (void)				setGradientPanelDefaultLibraryPath:(NSString*) path;

- (int)					version;

- (void)				setTarget:(id) aTarget;
- (void)				setAction:(SEL) anAction;
- (id)					target;
- (SEL)					action;

- (NSPanel*)			panel;

// gradients

- (void)				setGradient:(GCGradient*) grad;
- (GCGradient*)			gradient;
- (void)				setGradientType:(int) type;
- (int)					gradientType;

// current library

- (NSArray*)			gradientLibrary;
- (void)				setGradientLibrary:(NSArray*) lib addToExisting:(BOOL) merge;

- (NSDictionary*)		gradientLibraryPList;
- (void)				setGradientLibraryWithPList:(NSDictionary*) dict addToExisting:(BOOL) merge;

- (void)				loadGradientLibrary:(NSString*) filename merging:(BOOL) merge addingToRecent:(BOOL) addRecent;
- (void)				writeGradientLibraryToFile:(NSString*) path atomically:(BOOL) atom;

- (void)				updateRecentLibraryMenu;

// drawer handling

- (void)				setWindowSwatchDrawerLocation:(NSPoint) point;
- (void)				trackWindowSwatchDrawerWithEvent:(NSEvent*) event;
- (void)				setDrawerPosition:(int) pos;
- (void)				setDrawerPosition:(int) pos animate:(BOOL) animate;
- (int)					drawerPosition;
- (int)					positionOfDrawerEdge;
- (int)					findSnapPositionNearest:(int) pos;
- (NSIndexSet*)			drawerSnapPositions;
- (void)				swatchSizeChange:(NSNotification*) note;
- (BOOL)				isDrawerClosed;

- (void)				dispatchToClients;

// actions

- (IBAction)			flip:(id) sender;
- (IBAction)			takeGradientType:(id) sender;
- (IBAction)			show:(id) sender;
- (IBAction)			hide:(id) sender;
- (IBAction)			takePresetGradient:(id) sender;
- (IBAction)			clearPresets:(id) sender;

- (IBAction)			toggleDrawer:(id) sender;

- (IBAction)			saveLibrary: sender;
- (IBAction)			loadLibrary: sender;
- (IBAction)			loadStandardLibrary: sender;

- (IBAction)			addToPresets:(id) sender;

- (IBAction)			helpForGradientPanel:(id) sender;
- (IBAction)			onlineHelp:(id) sender;
- (IBAction)			showCredits:(id) sender;
- (IBAction)			openWebsite:(id) sender;
- (IBAction)			creditsOK:(id) sender;
- (IBAction)			openManual:(id) sender;
- (IBAction)			recentLibrary:(id) sender;

//- (IBAction)			undo:(id) sender;
//- (IBAction)			redo:(id) sender;

// User configuration support

- (void)				saveUserConfiguration:(NSNotification*) note;
- (void)				loadUserConfiguration;

@end


// informal protocol for simple receiving of gradient updates from the panel - any first responder
// that implements this will get the message. This is in addition to any explicit target/action you set.

@interface NSObject (GradientPanelClient)

- (void)				changeGradient:(id) sender;

@end


@interface NSObject (ImageResources)

- (NSImage*)		imageNamed:(NSString*) name fromBundleForClass:(Class) class;

@end


// this view simply used to pass mouse down event back to controller for dragging open the drawer

@interface DKDrawerDragView : NSView
{
	IBOutlet GCGradientPanel*		_controller;
}

@end

