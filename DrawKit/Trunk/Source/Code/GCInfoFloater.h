//
//  GCInfoFloater.h
//  DrawingArchitecture
//
//  Created by graham on 02/10/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GCInfoFloater : NSWindow
{
	NSControl*		m_infoViewRef;
	NSSize			m_wOffset;
}


+ (GCInfoFloater*)	infoFloater;

- (void)			setFloatValue:(float) val;
- (void)			setStringValue:(NSString*) str;

- (void)			setFormat:(NSString*) fmt;
- (void)			setWindowOffset:(NSSize) offset;
- (void)			positionNearPoint:(NSPoint) p inView:(NSView*) v;
- (void)			positionAtScreenPoint:(NSPoint) sp;

- (void)			show;
- (void)			hide;

@end


/*

This class provides a very simple tooltip-like window in which you can display a short piece of information, such
as a single numeric value.

By positioning this next to the mouse and supplying it with info, you can enhance the usability of some kinds of
user interaction.

*/

