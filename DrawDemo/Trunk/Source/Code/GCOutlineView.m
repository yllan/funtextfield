//
//  GCOutlineView.m
//  GCDrawKit
//
//  Created by graham on 23/04/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import "GCOutlineView.h"
#import <GCDrawKit/DKGradient+UISupport.h>


@implementation GCOutlineView

#pragma mark As a NSOutlineView

- (void)		highlightSelectionInClipRect:(NSRect) clipRect
{
	[super highlightSelectionInClipRect:clipRect];

	NSRange rows = [self rowsInRect:clipRect];
	
	if( NSLocationInRange([self selectedRow], rows))
	{
		NSRect sr = [self rectOfRow:[self selectedRow]];
		/*
		DKGradient* aqua = [DKGradient sourceListSelectedGradient];
		[aqua fillRect:sr];
		
		[[NSColor blackColor] set];
		NSFrameRectWithWidth( NSInsetRect(sr, -1, 0 ), 1 );
		*/
		
		[[NSColor selectedTextBackgroundColor] set];
		[NSBezierPath fillRect:sr];
	}
}


-(id)			_highlightColorForCell:(NSCell*) cell
{
    #pragma unused(cell)
	return nil;
}


- (NSColor *)	gridColor
{
	return [NSColor colorWithCalibratedRed:0.30 green:0.60 blue:0.92 alpha:0.15];
}

#pragma mark -
#pragma mark As an NSResponder
- (void)		mouseDown:(NSEvent*) event
{
	NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
	
	// which column and cell has been hit?
	
	int column = [self columnAtPoint:p];
	int row = [self rowAtPoint:p];
	NSTableColumn* theColumn = [[self tableColumns] objectAtIndex:column];
	id dataCell = [theColumn dataCellForRow:row];
	
	// if the checkbox column, handle click in checkbox without selecting the row

	if ([dataCell isKindOfClass:[NSButtonCell class]])
	{
		// no way to get the button type for further testing, so we'll plough on blindly
		
		NSRect	cellFrame = [self frameOfCellAtColumn:column row:row];
		
		// track the button - this keeps control until the mouse goes up. If the mouse was in on release,
		// it will have changed the button's state and returns YES.
		
		if ([dataCell trackMouse:event inRect:cellFrame ofView:self untilMouseUp:YES])
		{
			// call the data source to handle the checkbox state change as normal
			[[self dataSource] outlineView:self setObjectValue:[dataCell objectValue] forTableColumn:theColumn byItem:[self itemAtRow:row]];
			[self updateCell:dataCell];
		}
	}
	else
		[super mouseDown:event];	// for all other columns, work as normal
}

@end
