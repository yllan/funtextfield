#import "GCTableView.h"
#import "GCColourPickerView.h"
#import "GCWindowMenu.h"

#import <GCDrawKit/DKGradient+UISupport.h>
#import <GCDrawKit/NSColor+DKAdditions.h>

@implementation GCTableView
#pragma mark As an NSTableView
- (void)		textDidEndEditing:(NSNotification*) aNotification
{
	// this overrides the standard behaviour so that ending text editing does not select a new cell for editing
	// Instead the delegate is called as normal but then the table is made 1stR.
	
	NSString* theString = [[aNotification object] string];
	
	//NSLog(@"column = %d, string = %@", [self editedColumn], theString);
	
	NSTableColumn* theColumn = [[self tableColumns] objectAtIndex:[self editedColumn]];
	[[self delegate] tableView:self setObjectValue:theString forTableColumn:theColumn row:[self selectedRow]];
	[self abortEditing];
	[[self window] makeFirstResponder:self];
}



- (void)		highlightSelectionInClipRect:(NSRect) clipRect
{
	[super highlightSelectionInClipRect:clipRect];

	NSRange rows = [self rowsInRect:clipRect];
	
	if( NSLocationInRange([self selectedRow], rows))
	{
		NSRect sr = [self rectOfRow:[self selectedRow]];
		
		DKGradient* aqua = [DKGradient sourceListSelectedGradient];
		[aqua setAngleInDegrees:-90];
		[aqua fillRect:sr];
		
		[[NSColor blackColor] set];
		NSFrameRectWithWidth( NSInsetRect(sr, -1, 0 ), 1 );
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

	if ([dataCell isKindOfClass:[NSButtonCell class]] || [dataCell isKindOfClass:[GCColourCell class]])
	{
		// no way to get the button type for further testing, so we'll plough on blindly
		
		NSRect	cellFrame = [self frameOfCellAtColumn:column row:row];
		
		// track the button - this keeps control until the mouse goes up. If the mouse was in on release,
		// it will have changed the button's state and returns YES.
		
		if ([dataCell trackMouse:event inRect:cellFrame ofView:self untilMouseUp:YES])
		{
			// call the data source to handle the checkbox state change as normal
			[[self dataSource] tableView:self setObjectValue:[dataCell objectValue] forTableColumn:theColumn row:row];
			[self updateCell:dataCell];
		}
	}
	else
		[super mouseDown:event];	// for all other columns, work as normal
}


@end


#pragma mark -

@implementation GCColourCell


#pragma mark As a GCColourCell


- (void)		setColorValue:(NSColor*) colour
{
	[colour retain];
	[mColour release];
	mColour = colour;
	
	[(NSControl*)mControlView updateCellInside:self];
}


- (NSColor*)	colorValue
{
	return mColour;
}


- (void)		setState:(BOOL) state
{
	mHighlighted = state;
}


- (IBAction)	colourChangeFromPicker:(id) sender
{
	// hack - call the table's dataSource to temporarily set a colour that will be returned to the table when we update here - this
	// allows the cell to update live even though the cell is shared with all the other cells in the column.
	
	if ([mControlView isKindOfClass:[NSTableView class]])
	{
		id ds = [(NSTableView*)mControlView dataSource];
		NSRange rows = [(NSTableView*)mControlView rowsInRect:mFrame];
		
		[ds setTemporaryColour:[sender color] forTableView:(NSTableView*)mControlView row:rows.location];
		
		// force a reload of the row which will grab the temp colour and update the cell
		
		[mControlView setNeedsDisplayInRect:mFrame];
	}
}



#pragma mark -
#pragma mark As a NSCell

-(void)			drawInteriorWithFrame:(NSRect) theFrame inView:(NSView*) theView
{
	#pragma unused(theView)
	
	if([self colorValue] != nil )
	{
		NSRect r;
		
		if ( mHighlighted )
			[[NSColor darkGrayColor] set];
		else
			[[NSColor whiteColor] set];
		r = NSInsetRect( theFrame, 6, 5 );
		NSRectFill( r );

		r = NSInsetRect( theFrame, 8, 7 );

		[[self colorValue] set];
		NSRectFill( r );
		
		r = NSInsetRect( theFrame, 6, 5 );
		[[NSColor darkGrayColor] set];
		NSFrameRectWithWidth( r, 1 );
		
		// draw the menu triangle image
		
		NSImage* img = [NSImage imageNamed:@"menu_triangle"];
		
		if( img != nil )
		{
			[img setFlipped:YES];
			NSPoint mp = NSMakePoint( NSMaxX( theFrame ) - 18, NSMaxY( theFrame ) - 13);
			[img drawAtPoint:mp fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:1.0];
		}
	}
}


- (void)		setObjectValue:(id) obj
{
	if([obj isKindOfClass:[NSColor class]])
		[self setColorValue:obj];
	else
		[self setColorValue:nil];
}


- (id)			objectValue
{
	return [self colorValue];
}




- (BOOL)		trackMouse:(NSEvent*)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL) untilMouseUp
{
	#pragma unused (theEvent, untilMouseUp)
	
	mControlView = controlView;
	mFrame = cellFrame;
	
	[self setState:YES];
	[controlView setNeedsDisplayInRect:cellFrame];
	
	// pop up the colour picker
	
	NSPoint loc;
	
	loc.x = NSMinX( cellFrame ) + 6;
	loc.y = NSMaxY( cellFrame ) - 5;
		
	loc = [controlView convertPoint:loc toView:nil];
	
	NSRect sr = NSMakeRect( 0, 0, 161, 161 );

	GCColourPickerView* picker = [[GCColourPickerView alloc] initWithFrame:sr];
	GCWindowMenu* popup = [GCWindowMenu windowMenuWithContentView:picker];

	[picker setMode:kGCColourPickerModeSwatches];
	//[picker setMode:kGCColourPickerModeSpectrum];
	
	[picker setTarget:self];
	[picker setAction:@selector(colourChangeFromPicker:)];
	[picker setColorForUndefinedSelection:[self colorValue]];
	[picker setShowsInfo:NO];
	[picker release];
	
	[GCWindowMenu popUpWindowMenu:popup atPoint:loc withEvent:theEvent forView:controlView];

	// keeps control until mouse up
	
	[self setState:NO];
	
	if ([mControlView isKindOfClass:[NSTableView class]])
	{
		id ds = [(NSTableView*)controlView dataSource];
		[ds setTemporaryColour:nil forTableView:(NSTableView*)mControlView row:-1];
	}
	[controlView setNeedsDisplayInRect:cellFrame];

	return YES;
}



@end
