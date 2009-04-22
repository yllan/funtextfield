//
//  GCGradientCell.h
//  GradientTest
//
//  Created by Jason Jobe on 3/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DKGradientCell.h"


@class GCMiniControl;
@class GCMiniControlCluster;


@interface GCGradientCell : DKGradientCell
{
	NSRect					mControlBoundsRect;
	GCMiniControlCluster*	mMiniControls;
	BOOL					mUpdatingControls;
	int						mHitPart;
}


- (void)					setMiniControlBoundsWithCellFrame:(NSRect) cframe forMode:(int) mode;
- (void)					setMiniControlBounds:(NSRect) br withIdentifier:(NSString*) key;
- (void)					drawMiniControlsForMode:(int) mode;
- (GCMiniControlCluster*)	controlClusterForMode:(int) mode;
- (GCMiniControl*)			miniControlForIdentifier:(NSString*) key;
- (void)					updateMiniControlsForMode:(int) mode;

- (NSRect)					proxyIconRectInCellFrame:(NSRect) rect;

- (void)					setControlVisible:(BOOL) vis;

@end





#define kGCDefaultGradientCellInset		(NSMakeSize( 8.0, 8.0 ))


// internal "partcodes" for where a mouse hit occurred

enum
{
	kGCHitNone				= 0,
	kGCHitMiniControl		= 5,
	kGCHitProxyIcon			= 7,
	kGCHitOther				= 999
};

