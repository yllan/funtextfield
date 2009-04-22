//
//  GCGradientWell.h
//  GradientTest
//
//  Created by Jason Jobe on 3/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DKGradient;


@interface GCGradientWell : NSControl
{
	int					mControlMode;
	NSTrackingRectTag	mTrackingTag;
	BOOL				mForceSquare;
	BOOL				mShowProxyIcon;
	BOOL				mCanBecomeActive;
	BOOL				mIsSendingAction;
}

+ (void)				setActiveWell:(GCGradientWell*) well;
+ (GCGradientWell*)		activeWell;
+ (void)				clearAllActiveWells;

- (void)				setGradient:(DKGradient*) aGradient;
- (DKGradient*)			gradient;
- (void)				syncGradientToControlSettings;
- (void)				initiateGradientDragWithEvent:(NSEvent*) theEvent;

- (void)				setControlMode:(int) mode;
- (int)					controlMode;

- (void)				setDisplaysProxyIcon:(BOOL) proxy;
- (BOOL)				displaysProxyIcon;

- (void)				setupTrackingRect;
- (void)				setForceSquare:(BOOL) fsq;

- (void)				setCanBecomeActiveWell:(BOOL) canbecome;
- (BOOL)				canBecomeActiveWell;
- (BOOL)				isActiveWell;
- (void)				wellDidBecomeActive;
- (void)				wellWillResignActive;
- (void)				toggleActiveWell;

- (NSMenu*)				menuForEvent:(NSEvent*) theEvent;

- (IBAction)			cut:(id) sender;
- (IBAction)			copy:(id) sender;
- (IBAction)			copyImage:(id) sender;
- (IBAction)			paste:(id) sender;
- (IBAction)			delete:(id) sender;
- (IBAction)			resetRadial:(id) sender;

@end



enum
{
	kGCGradientWellDisplayMode			= 0,
	kGCGradientWellAngleMode			= 1,
	kGCGradientWellRadialMode			= 2,
	kGCGradientWellSweepMode			= 3
};
