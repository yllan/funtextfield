//
//  GCMiniRadialControl2.h
//  panel
//
//  Created by Graham on Tue Apr 17 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCMiniControl.h"


@interface GCMiniRadialControl2 : GCMiniControl
{
	NSColor*		mTabColour;
	NSBezierPath*   mTabPath;
	NSBezierPath*   mHitTabPath;
	NSBezierPath*   mIrisPath;
	NSPoint			mCentre;
	NSSize			mOffset;
	
	float			mRadius;
	float			mRingRadius;
	float			mTabAngle;
	float			mRingScale;
	BOOL			mIrisDilating;
	BOOL			mAutoFlip;
}


- (void)			setCentre:(NSPoint) p;
- (NSPoint)			centre;

- (void)			setRadius:(float) radius;
- (float)			radius;

- (void)			setRingRadius:(float) radius;
- (float)			ringRadius;
- (void)			setRingRadiusScale:(float) rsc;

- (void)			setTabColor:(NSColor*) colour;
- (NSColor*)		tabColor;

- (void)			setTabAngle:(float) ta;
- (float)			tabAngle;

- (NSBezierPath*)   irisPath;
- (NSBezierPath*)   tabPath;
- (void)			invalidatePathCache;


@end


enum
{
	kGCRadial2HitIris   = 17,
	kGCRadial2HitTab	= 18
};
