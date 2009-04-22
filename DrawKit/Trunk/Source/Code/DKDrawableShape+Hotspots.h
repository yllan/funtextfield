///**********************************************************************************************************************************
///  DKDrawableShape+Hotspots.h
///  DrawKit
///
///  Created by graham on 30/06/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKDrawableShape.h"


@class DKHotspot;


typedef enum
{
	kGCHotspotStateOff			= 0,
	kGCHotspotStateOn			= 1,
	kGCHotspotStateDisabled		= 2
}
DKHotspotState;


@interface DKDrawableShape (Hotspots)

- (int)					addHotspot:(DKHotspot*) hspot;
- (void)				removeHotspot:(DKHotspot*) hspot;
- (void)				setHotspots:(NSArray*) spots;
- (NSArray*)			hotspots;

- (DKHotspot*)			hotspotForPartCode:(int) pc;
- (DKHotspot*)			hotspotUnderMouse:(NSPoint) mp;
- (NSPoint)				hotspotPointForPartcode:(int) pc;

- (NSRect)				hotspotRect:(DKHotspot*) hs;
- (void)				drawHotspotAtPoint:(NSPoint) hp inState:(DKHotspotState) state;
- (void)				drawHotspotsInState:(DKHotspotState) state;

@end


enum
{
	kGCHotspotBasePartcode		= 1000
};


#pragma mark -


@interface DKHotspot : NSObject <NSCoding, NSCopying>
{
	DKDrawableShape*	m_owner;
	int					m_partcode;
	NSPoint				m_relLoc;
	id					m_delegate;
}


- (id)					initHotspotWithOwner:(DKDrawableShape*) shape partcode:(int) pc delegate:(id) delegate;

- (void)				setOwner:(DKDrawableShape*) shape;
- (void)				setOwner:(DKDrawableShape*) shape withPartcode:(int) pc;
- (DKDrawableShape*)	owner;

- (void)				setPartcode:(int) pc;
- (int)					partcode;

- (void)				setRelativeLocation:(NSPoint) rloc;
- (NSPoint)				relativeLocation;

- (void)				drawHotspotAtPoint:(NSPoint) p inState:(DKHotspotState) state;

- (void)				setDelegate:(id) delegate;
- (id)					delegate;

- (void)				startMouseTracking:(NSEvent*) event inView:(NSView*) view;
- (void)				continueMouseTracking:(NSEvent*) event inView:(NSView*) view;
- (void)				endMouseTracking:(NSEvent*) event inView:(NSView*) view;

@end


#define		kGCDefaultHotspotSize		NSMakeSize( 6, 6 )

#pragma mark -

@interface NSObject (DKHotspotDelegate)

 - (void)				hotspot:(DKHotspot*) hs willBeginTrackingWithEvent:(NSEvent*) event inView:(NSView*) view;
 - (void)				hotspot:(DKHotspot*) hs isTrackingWithEvent:(NSEvent*) event inView:(NSView*) view;
 - (void)				hotspot:(DKHotspot*) hs didEndTrackingWithEvent:(NSEvent*) event inView:(NSView*) view;


@end


/*

A HOTSPOT is an object attached to a shape to provide a direct user-interface for implementing custom actions, etc.

Hotspots are clickable areas on a shape indicated by a special "knob" appearance. They can appear anywhere within the bounds. When clicked,
they will be tracked and can do any useful thing they wish. The original purpose is to allow the direct manipulation of certain shape parameters
such as radius of round corners, and so on, but the design is completely general-purpose. 

The action of a hotspot is handled by default by its delegate, though you could also subclass it and implement the action directly if you wish.

The appearance of a hotspot is drawn by default by a method of DKKnob.

*/
