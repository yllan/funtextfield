#import "GCLayersPaletteController.h"
#import "GCTableView.h"
#import <GCDrawKit/DKDrawing.h>
#import <GCDrawKit/DKObjectDrawingLayer.h>
#import <GCDrawKit/DKViewController.h>
#import <GCDrawKit/DKDrawingView.h>
#import <GCDrawKit/LogEvent.h>

#pragma mark Contants (Non-localized)
NSString*		kGCTableRowInternalDragPasteboardType = @"kGCTableRowInternalDragPasteboardType";


#pragma mark -
@implementation GCLayersPaletteController
#pragma mark As a GCLayersPaletteController
- (void)				setDrawing:(DKDrawing*) drawing
{
	LogEvent_( kReactiveEvent, @"layers palette setting drawing = %@", drawing );
	
	[mLayersTable reloadData];
	if ( drawing != nil )
	{
		int row = [drawing indexOfLayer:[drawing activeLayer]];
		
		LogEvent_( kReactiveEvent, @"index of active layer = %d", row );

		[mLayersTable selectRow:row byExtendingSelection:NO];
		[mLayersTable scrollRowToVisible:row];
	}
}


- (DKDrawing*)			drawing
{
	return [self currentDrawing];
}


#pragma mark -
- (IBAction)		addLayerButtonAction:(id)sender
{
	#pragma unused (sender)

	DKLayer* layer = [[DKObjectDrawingLayer alloc] init];
	[[self drawing] addLayer:layer andActivateIt:YES];
	
	NSString* action = [NSString stringWithFormat:@"%@ %C%@%C", NSLocalizedString(@"Add Layer", @""), 0x201C, [layer name], 0x201D];

	[[[self drawing] undoManager] setActionName:action];
}


- (IBAction)		removeLayerButtonAction:(id)sender
{
	#pragma unused (sender)

	DKLayer* active = [[self drawing] activeLayer];

	NSString* action = [NSString stringWithFormat:@"%@ %C%@%C", NSLocalizedString(@"Delete Layer", @""), 0x201C, [active name], 0x201D];
	[[self drawing] removeLayer:active andActivateLayer:nil];

	[[[self drawing] undoManager] setActionName:action];
}


- (IBAction)		autoActivationAction:(id) sender
{
	DKViewController* vc = [self currentMainViewController];
	
	if( vc != nil )
		[vc setActivatesLayersAutomatically:[sender intValue]];

}


#pragma mark -
- (void)				drawingDidReorderLayersNotification:(NSNotification*) note
{
	#pragma unused (note)

	[self setDrawing:[self drawing]];
}


#pragma mark -
#pragma mark As an NSTableView delegate
- (void)				tableViewSelectionDidChange:(NSNotification*) aNotification
{
	if ([aNotification object] == mLayersTable)
	{
		int row = [mLayersTable selectedRow];
		
		LogEvent_( kReactiveEvent, @"layer selection changed to %d", row );
		
		if ( row != -1 )
			[[self drawing] setActiveLayer:[[self drawing] layerAtIndex:row]];
	}
}


- (void)	tableView:(NSTableView*) tableView willDisplayCell:(id) cell forTableColumn:(NSTableColumn*) tableColumn row:(int) row
{
	if([[tableColumn identifier] isEqualToString:@"name"])
	{
		NSColor *fontColor;
		//NSColor *shadowColor;
		NSFont* font = [cell font];
		
		if ([[tableView selectedRowIndexes] containsIndex:row] && ([tableView editedRow] != row))
		{
			fontColor = [NSColor whiteColor];
			//shadowColor = [NSColor colorWithDeviceRed:(127.0/255.0) green:(140.0/255.0) blue:(160.0/255.0) alpha:1.0];
			
			font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSBoldFontMask];
			[cell setFont:font];
		}
		else
		{
			fontColor = [NSColor blackColor];
			//shadowColor = nil;

			font = [[NSFontManager sharedFontManager] convertFont:font toHaveTrait:NSUnboldFontMask];
			[cell setFont:font];
		}
		[cell setTextColor:fontColor];
		/*
		NSShadow *shad = [[NSShadow alloc] init];
		NSSize shadowOffset = { width: 1.0, height: -1.5};
		[shad setShadowOffset:shadowOffset];
		[shad setShadowColor:shadowColor];
		[shad set];	
		*/
	}
}



#pragma mark -
#pragma mark As part of NSTableDataSource Protocol
- (int)					numberOfRowsInTableView:(NSTableView*) aTableView
{
#pragma unused (aTableView)
	return [[self drawing] countOfLayers];
}


- (BOOL)				tableView:(NSTableView*) aTableView acceptDrop:(id <NSDraggingInfo>) info row:(int)row dropOperation:(NSTableViewDropOperation) operation
{
#pragma unused (aTableView, operation)
    NSPasteboard* pboard = [info draggingPasteboard];
    NSData* rowData = [pboard dataForType:kGCTableRowInternalDragPasteboardType];
    NSIndexSet* rowIndexes = [NSKeyedUnarchiver unarchiveObjectWithData:rowData];
    
	int dragRow = [rowIndexes firstIndex];
	
	DKLayer* layer = [[self drawing] layerAtIndex:dragRow];
	
	if ( layer )
	{
		[[self drawing] moveLayer:layer toIndex:row];
		[[[self drawing] undoManager] setActionName:NSLocalizedString(@"Reorder Layers", @"")];
		return YES;
	}
	else
		return NO;
}


- (id)					tableView:(NSTableView*) aTableView objectValueForTableColumn:(NSTableColumn*) aTableColumn row:(int) rowIndex
{
#pragma unused (aTableView)
	DKLayer* layer = [[self drawing] layerAtIndex:rowIndex];
	id val = [layer valueForKey:[aTableColumn identifier]];
	
	// hack - if a temporary colour is set for the requested row and column, return it instead of getting it from the drawing.
	// this permits the cutsom cells that display this colour in the table to update "live" without having to change the data model
	// which is potentially very expensive.
	
	if( rowIndex == mTemporaryColourRow && mTemporaryColour != nil && [[aTableColumn identifier] isEqualToString:@"selectionColour"])
		val = mTemporaryColour;
	
	//NSLog(@"table value = %@", [val stringValue] );
	
	return val;
}


- (void)				tableView:(NSTableView*) aTableView setObjectValue:(id) anObject forTableColumn:(NSTableColumn*) aTableColumn row:(int) rowIndex
{
#pragma unused (aTableView)
	DKLayer* layer = [[self drawing] layerAtIndex:rowIndex];
	[layer setValue:anObject forKey:[aTableColumn identifier]];
}


- (BOOL)				tableView:(NSTableView*) aTableView writeRowsWithIndexes:(NSIndexSet*) indexes toPasteboard:(NSPasteboard*) pb
{
#pragma unused (aTableView)
	NSData* data = [NSKeyedArchiver archivedDataWithRootObject:indexes];
	
	[pb declareTypes:[NSArray arrayWithObject:kGCTableRowInternalDragPasteboardType] owner:self];
    [pb setData:data forType:kGCTableRowInternalDragPasteboardType];
	return YES;
}


- (NSDragOperation)		tableView:(NSTableView*) aTableView validateDrop:(id <NSDraggingInfo>) info proposedRow:(int) row proposedDropOperation:(NSTableViewDropOperation) op 
{
#pragma unused (aTableView, info, row, op)
    return NSDragOperationEvery;    
}



- (void)				setTemporaryColour:(NSColor*) aColour forTableView:(NSTableView*) tView row:(int) row
{
	#pragma unused(tView)
	
	// this is a bit of a hack to make the selection colour cells in the table update live as the menu is tracked, but without
	// updating the actual selection colour, which can be very expensive if there are many selected objects. This is called
	// to set the temporary colour and the objectValue... method will return this for the given row if set.
	
	//NSLog(@"setting temp colour: %@, row = %d", [aColour stringValue], row);
	
	[aColour retain];
	[mTemporaryColour release];
	mTemporaryColour = aColour;
	mTemporaryColourRow = row;
}

#pragma mark -
#pragma mark As a DKDrawkitInspectorBase
- (void)				redisplayContentForSelection:(NSArray*) selection
{
#pragma unused (selection)
	[self setDrawing:[self currentDrawing]];
}


- (void)				documentDidChange:(NSNotification*) note
{
	LogEvent_(kReactiveEvent, @"layers palette got document change, main = %@", [note object]);
	
	if ([[note name] isEqualToString:NSWindowDidResignMainNotification])
	{
		// delay here to ensure that the document/drawing has really gone for reloading the table
		[self performSelector:@selector(setDrawing:) withObject:nil afterDelay:0.2];
	}
	else
	{
		DKDrawing* drawing = [self drawingForTargetWindow:[note object]];
		
		[self setDrawing:drawing];
		[[self window] setTitle:[NSString stringWithFormat:@"%@ - Layers", [[note object] title]]];
		
		// see if the window contains a DKDrawingView and controller
		
		id view = [[note object] firstResponder];
		
		// if view is nil try initial first responder
		
		if ( view == nil )
			view = [[note object] initialFirstResponder];
		
		if( view != nil && [view isKindOfClass:[DKDrawingView class]])
		{
			DKViewController* vc = [(DKDrawingView*)view controller];
			[mAutoActivateCheckbox setIntValue:[vc activatesLayersAutomatically]];
		}
	}
}



#pragma mark -
#pragma mark As an NSWindowController
- (void)				windowDidLoad
{
	[(NSPanel*)[self window] setFloatingPanel:YES];
	[(NSPanel*)[self window] setBecomesKeyOnlyIfNeeded:YES];
	
	[mLayersTable setAllowsEmptySelection:YES];
	
	if([self drawing] != nil )
	{
		int row = [[self drawing] indexOfLayer:[[self drawing] activeLayer]];
	
		if ( row != NSNotFound )
			[mLayersTable selectRow:row byExtendingSelection:NO];
	}	
	// set the cell type of the colours column to GCColourCell
	
	GCColourCell* cc = [[[GCColourCell alloc] init] autorelease];
	[[mLayersTable tableColumnWithIdentifier:@"selectionColour"] setDataCell:cc];
	/*
	NSTableColumn* col = [mLayersTable tableColumnWithIdentifier:@"locked"];
	NSImageCell* headerCell = [[NSImageCell alloc] init];
	[headerCell setImage:[NSImage imageNamed:@"locked_symbol"]];
	[headerCell setImageFrameStyle:NSImageFrameButton];
	[col setHeaderCell:headerCell];
	[headerCell release];
	*/
	// subscribe to active layer notifications so the table can be kept in synch
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector( drawingDidReorderLayersNotification: ) name:kDKLayerGroupDidReorderLayers object:[self drawing]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector( drawingDidReorderLayersNotification: ) name:kDKLayerGroupDidAddLayer object:[self drawing]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector( drawingDidReorderLayersNotification: ) name:kDKLayerGroupDidRemoveLayer object:[self drawing]];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector( layerDidChange: ) name:kDKLayerVisibleStateDidChange object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector( layerDidChange: ) name:kDKLayerLockStateDidChange object:nil];
	

	// position the palette at the right hand edge of the screen
	
	NSRect panelFrame = [[self window] frame];
	NSRect screenFrame = [[[NSScreen screens] objectAtIndex:0] visibleFrame];
	
	panelFrame.origin.x = NSMaxX( screenFrame ) - NSWidth( panelFrame ) - 20;
	[[self window] setFrameOrigin:panelFrame.origin];

	// allow row-drag reordering
	
	[mLayersTable registerForDraggedTypes:[NSArray arrayWithObject:kGCTableRowInternalDragPasteboardType]];
	[[self window] setTitle:[NSString stringWithFormat:@"%@ - Layers", [[NSApp mainWindow] title]]];
}


- (NSString*)			windowNibName
{
	return @"LayersPalette";
}


@end
