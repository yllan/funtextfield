//
//  GCMiniControlCluster.h
//  panel
//
//  Created by Graham on Thu Apr 12 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCMiniControl.h"


@interface GCMiniControlCluster : GCMiniControl
{
	NSMutableArray*			mControls;
	NSMutableDictionary*	mControlNames;
	NSTimer*				mCATimerRef;
	NSView*					mViewRef;
	GCMiniControl*			mHitTarget;
	NSTimeInterval			mFadeStartTime;
	
	float					mControlAlpha;
	int						mHitPart;
	int						mLinkPart;
	int						mLinkModFlagsMask;
	BOOL					mVisible;
}


- (void)					addMiniControl:(GCMiniControl*) mc;
- (void)					removeMiniControl:(GCMiniControl*) mc;
- (NSArray*)				controls;
- (GCMiniControl*)			controlAtIndex:(int) n;

- (void)					setControl:(GCMiniControl*) ctrl forKey:(NSString*) key;
- (GCMiniControl*)			controlForKey:(NSString*) key;

- (void)					setVisible:(BOOL) vis;
- (void)					forceVisible:(BOOL) vis;
- (BOOL)					visible;

- (void)					setView:(NSView*) view;

- (void)					setAlpha:(float) alpha;
- (float)					alpha;
- (void)					fadeControlAlphaWithTimeInterval:(NSTimeInterval) t;
- (void)					timerFadeCallback:(NSTimer*) timer;

- (void)					setLinkControlPart:(int) partcode modifierKeyMask:(int) mask;


@end



/*

The mini-control cluster owns one or more mini controls, and manages them as a group. The cluster of
controls shares common attributes such as visibility and alpha value.

A cluster may be owned by further clusters, or it may be owned by another object. Ultimately clusters
must be owned by some sort of view and are drawn into that view.


*/
