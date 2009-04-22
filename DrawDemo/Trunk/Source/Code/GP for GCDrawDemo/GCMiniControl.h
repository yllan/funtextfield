//
//  GCMiniControl.h
//  panel
//
//  Created by Graham on Thu Apr 12 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class GCMiniControlCluster, GCInfoFloater;


@interface GCMiniControl : NSObject
{
	NSRect					mBounds;		// area fully enclosing the control
	GCMiniControlCluster*   mClusterRef;	// cluster we belong to, if any
	NSString*				mIdent;			// control's identifier, if any
	id						mDelegateRef;	// delegate, if any
	GCInfoFloater*			mInfoWin;		// optional info window
	
	float					mValue;			// current value
	float					mMinValue;		// min value
	float					mMaxValue;		// max value
	int						mInfoWMode;		// info window mode
	BOOL					mApplyShadow;	// YES to shadow drawn backgrounds
}

+ (NSColor*)				miniControlThemeColor:(int) themeElementID withAlpha:(float) alpha;

- (id)						initWithBounds:(NSRect) rect inCluster:(GCMiniControlCluster*) clust;
- (void)					setCluster:(GCMiniControlCluster*) clust;
- (GCMiniControlCluster*)	cluster;
- (NSView*)					view;

- (void)					setBounds:(NSRect) rect;
- (NSRect)					bounds;
- (void)					draw;

- (void)					applyShadow;

- (void)					setNeedsDisplay;
- (void)					setNeedsDisplayInRect:(NSRect) rect;

- (NSColor*)				themeColour:(int) themeElementID;

- (int)						hitTestPoint:(NSPoint) p;

- (BOOL)					mouseDownAt:(NSPoint) startPoint inPart:(int) part modifierFlags:(int) flags;
- (BOOL)					mouseDraggedAt:(NSPoint) currentPoint inPart:(int) part modifierFlags:(int) flags;
- (void)					mouseUpAt:(NSPoint) endPoint inPart:(int) part modifierFlags:(int) flags;
- (void)					flagsChanged:(int) flags;

- (void)					setInfoWindowMode:(int) mode;
- (void)					setupInfoWindowAtPoint:(NSPoint) p withValue:(float) val andFormat:(NSString*) format;
- (void)					updateInfoWindowAtPoint:(NSPoint) p withValue:(float) val;
- (void)					hideInfoWindow;
- (void)					setInfoWindowFormat:(NSString*) format;
- (void)					setInfoWindowValue:(float) value;

- (void)					setDelegate:(id) del;
- (id)						delegate;
- (void)					notifyDelegateWillChange:(id) value;
- (void)					notifyDelegateDidChange:(id) value;

- (void)					setIdentifier:(NSString*) name;
- (NSString*)				identifier;

- (void)					setValue:(float) v;
- (float)					value;

- (void)					setMaxValue:(float) v;
- (float)					maxValue;

- (void)					setMinValue:(float) v;
- (float)					minValue;

@end

// methods that can be implemented by the delegate (all optional)

@interface  NSObject (GCMiniControlDelegate)

- (void)					miniControl:(GCMiniControl*) mc willChangeValue:(id) newValue;
- (void)					miniControl:(GCMiniControl*) mc didChangeValue:(id) newValue;
- (float)					miniControlWillUpdateInfoWindow:(GCMiniControl*) mc withValue:(float) val;

@end

// standard "partcodes" returned by hitTest method
// subclasses can define their own using any other values

enum
{
	kGCMiniControlNoPart				= 0,
	kGCMiniControlEntireControl			= -1
};

// theme elements can be used to obtain standard colours across a range of controls

enum
{
	kGCMiniControlThemeBackground		= 0,
	kGCMiniControlThemeSliderTrack		= 1,
	kGCMiniControlThemeKnobInterior		= 2,
	kGCMiniControlThemeKnobStroke		= 3,
	kGCMiniControlThemeIris				= 4,
	kGCMiniControlThemeSliderTrkHilite	= 5
};

// can have optional info window floater - delegate will be asked to supply value. Info
// window is only shown during mouse tracking.

enum
{
	kGCMiniControlNoInfoWindow				= 0,
	kGCMiniControlInfoWindowFollowsMouse	= 1,
	kGCMiniControlInfoWindowCentred			= 2
};


// this is an abstract class providing the interface for useful concrete subclasses.

// a mini-control is similar in concept but much simpler than NSControl. It relies on the host view to
// call it with sensible parameters, and will draw into whatever is the current view. All coordinates
// are in the host view's coordinate system.

// mini-controls are designed to be used in clusters (though you can have a cluster of 1). The cluster will
// handle such things as control visible, etc and hit testing the cluster. clusters retain the controls
// but not vice versa.
