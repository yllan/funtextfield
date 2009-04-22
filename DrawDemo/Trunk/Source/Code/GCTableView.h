/* GCTableView */

#import <Cocoa/Cocoa.h>

@interface GCTableView : NSTableView
@end



// declare a custom NSCell class for drawing a colour in a table's column


@interface GCColourCell	: NSCell
{
	NSColor*	mColour;
	BOOL		mHighlighted;
	NSRect		mFrame;
	NSView*		mControlView;
}


- (void)		setColorValue:(NSColor*) colour;
- (NSColor*)	colorValue;
- (void)		setState:(BOOL) state;

@end




@interface NSObject (GCColourCellHack)

- (void)				setTemporaryColour:(NSColor*) aColour forTableView:(NSTableView*) tView row:(int) row;

@end


