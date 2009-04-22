//
//  DKSDController.m
//  GCDrawKit
//
//  Created by graham on 19/06/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import "DKSDController.h"
#import <GCDrawKit/DKDrawKit.h>

@implementation DKSDController


- (IBAction)	toolMatrixAction:(id) sender
{
	// the drawing view can handle this for us, provided we pass it an object that responds to -title and returns
	// the valid name of a registered tool. The selected button cell is just such an object.
	
	NSButtonCell* cell = [sender selectedCell];
	[mDrawingView selectDrawingToolByName:cell];
}


- (IBAction)	toolStickyAction:(id) sender
{
	// sets the tool controller's flag to the inverted state of the checkbox
	
	[(DKToolController*)[mDrawingView controller] setAutomaticallyRevertsToSelectionTool:![sender intValue]];
}


#pragma mark -

- (IBAction)	styleFillColourAction:(id) sender
{
	// get the style of the selected object
	
	DKStyle* style = [self styleOfSelectedObject];
	
	// if it has a fill property...
	
	if( style != nil && [style hasFill])
	{
		// ...get the fill property and set its colour to the sender's
		
		DKFill* fill = (DKFill*)[[style renderersOfClass:[DKFill class]] lastObject];
		[fill setColour:[sender color]];
	}
}




- (IBAction)	styleStrokeColourAction:(id) sender
{
	// get the style of the selected object
	
	DKStyle* style = [self styleOfSelectedObject];
	
	// if it has a stroke property...
	
	if( style != nil && [style hasStroke])
	{
		// ...get the stroke property and set its colour to the sender's
		
		DKStroke* stroke = (DKStroke*)[[style renderersOfClass:[DKStroke class]] lastObject];
		[stroke setColour:[sender color]];
	}
}




- (IBAction)	styleStrokeWidthAction:(id) sender
{
	// get the style of the selected object
	
	DKStyle* style = [self styleOfSelectedObject];
	
	// if the style has a stroke property...
	
	if( style != nil && [style hasStroke])
	{
		// ...get the stroke property and set its width to the float value of the sender
		
		DKStroke* stroke = (DKStroke*)[[style renderersOfClass:[DKStroke class]] lastObject];
		[stroke setWidth:[sender floatValue]];
	}
	
	// synchronise the text field and the stepper so they both have the same value
	
	if( sender == mStyleStrokeWidthStepper )
		[mStyleStrokeWidthTextField setFloatValue:[sender floatValue]];
	else
		[mStyleStrokeWidthStepper setFloatValue:[sender floatValue]];
}


- (IBAction)	styleFillCheckboxAction:(id) sender
{
	// get the style of the selected object

	DKStyle* style = [self styleOfSelectedObject];
	
	if( style != nil )
	{
		// are we removing or adding the fill property?
		
		BOOL removing = ([sender intValue] == 0);
	
		if ( removing )
		{
			// remove all fill properties and set the Undo menu to suit
			
			[style removeRenderersOfClass:[DKFill class] inSubgroups:YES];
			[[mDrawingView undoManager] setActionName:@"Delete Fill"];
		}
		else
		{
			// add a fill property at the back of the render list (strokes are placed in front of fills here)
			
			DKFill* newFill = [DKFill fillWithColour:[mStyleFillColourWell color]];
			[style insertRenderer:newFill atIndex:0];
			[[mDrawingView undoManager] setActionName:@"Add Fill"];
		}
	}
}


- (IBAction)	styleStrokeCheckboxAction:(id) sender
{
	// get the style of the selected object

	DKStyle* style = [self styleOfSelectedObject];
	
	if( style != nil )
	{
		// are we removing or adding the stroke property?

		BOOL removing = ([sender intValue] == 0);
	
		if ( removing )
		{
			// remove all stroke properties and set the Undo menu to suit

			[style removeRenderersOfClass:[DKStroke class] inSubgroups:YES];
			[[mDrawingView undoManager] setActionName:@"Delete Stroke"];
		}
		else
		{
			// add a stroke property at the front of the render list (strokes are placed in front of fills here)

			DKStroke* newStroke = [DKStroke strokeWithWidth:[mStyleStrokeWidthTextField floatValue] colour:[mStyleStrokeColourWell color]];
			[style addRenderer:newStroke];
			[[mDrawingView undoManager] setActionName:@"Add Stroke"];
		}
	}
}


#pragma mark -

- (IBAction)	gridMatrixAction:(id) sender
{
	// the drawing's grid layer already knows how to do this - just pass it the selected cell from where it
	// can extract the tag which it interprets as one of the standard grids.
	
	[[[mDrawingView drawing] gridLayer] setMeasurementSystemAction:[sender selectedCell]];
}


- (IBAction)	snapToGridAction:(id) sender
{
	// set the drawing's snapToGrid flag to match the sender's state
	
	[[mDrawingView drawing] setSnapsToGrid:[sender intValue]];
}


#pragma mark -

- (IBAction)	layerAddButtonAction:(id) sender
{
	// adding a new layer - first create it

	DKObjectDrawingLayer* newLayer = [[DKObjectDrawingLayer alloc] init];
	
	// add it to the drawing and make it active - this triggers notifications which update the UI
	
	[[mDrawingView drawing] addLayer:newLayer andActivateIt:YES];
	
	// drawing now owns the layer so we can release it
	
	[newLayer release];
	
	// inform the Undo Manager what we just did:
	
	[[mDrawingView undoManager] setActionName:@"New Drawing Layer"];
}




- (IBAction)	layerRemoveButtonAction:(id) sender
{
	// removing the active (selected) layer - first find that layer
	
	DKLayer* activeLayer = [[mDrawingView drawing] activeLayer];
	
	// remove it and activate another (passing nil tells the drawing to use its nous to activate something sensible)
	
	[[mDrawingView drawing] removeLayer:activeLayer andActivateLayer:nil];
	
	// inform the Undo Manager what we just did:
	
	[[mDrawingView undoManager] setActionName:@"Delete Drawing Layer"];
}


#pragma mark -



- (void)		drawingSelectionDidChange:(NSNotification*) note
{
	// the selection changed within the drawing - update the UI to match the state of whatever was selected. We pass nil
	// because in fact we just grab the current selection directly.
	
	[self updateControlsForSelection:nil];
}


- (void)		activeLayerDidChange:(NSNotification*) note
{
	// change the selection in the layer table to match the actual layer that has been activated
	
	DKDrawing* dwg = [mDrawingView drawing];
	
	if( dwg != nil )
	{
		// ensure the table is correct for the current number of layers, etc:
		
		[mLayerTable reloadData];
		
		// now find the active layer's index and set the selection to the same value
		
		unsigned index = [dwg indexOfLayer:[dwg activeLayer]];
		
		if( index != NSNotFound )
			[mLayerTable selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
	}
}


- (void)		selectedToolDidChange:(NSNotification*) note
{
	// the selected tool changed - find out which button cell matches and select it so that
	// the tool UI and the actual selected tool agree. This is necessary because when a tool is automatically
	// "sprung back" the UI needs to keep up with that automatic change.
	
	// which tool was selected?
	
	DKDrawingTool*	tool = [[note object] drawingTool];
	NSString*		toolName = [tool registeredName];
	
	// keep the "sticky" checkbox synchronised with the tool controller's actual state
	
	BOOL sticky = ![(DKToolController*)[mDrawingView controller] automaticallyRevertsToSelectionTool];
	[mToolStickyCheckbox setIntValue:sticky];
	
	// search through the matrix to find the cell whose title matches the tool's name,
	// and select it.
	
	int				row, col, rr, cc;
	NSCell*			cell;
	
	[mToolMatrix getNumberOfRows:&row columns:&col];
	
	for( rr = 0; rr < row; ++rr )
	{
		for( cc = 0; cc < col; ++cc )
		{
			cell = [mToolMatrix cellAtRow:rr column:cc];
			
			if([[cell title] isEqualToString:toolName])
			{
				[mToolMatrix selectCellAtRow:rr column:cc];
				return;
			}
		}
	}
	
	[mToolMatrix selectCellAtRow:0 column:0];
}


#pragma mark -

- (void)		updateControlsForSelection:(NSArray*) selection
{
	// update all necessary UI controls to match the state of the selected object. Note that this ignores the selection passed to it
	// and just gets the info directly. It also doesn't bother to worry about more than one selected object - it just uses the info from
	// the topmost object - for this simple demo that's sufficient.
	
	// get the selected object's style
	
	DKStyle*		style = [self styleOfSelectedObject];
	DKRasterizer*	rast;
	NSColor*		temp;
	float			sw;
	
	// set up the fill controls if the style has a fill property, or disable them
	// altogether if it does not.
	
	if([style hasFill])
	{
		rast = [[style renderersOfClass:[DKFill class]] lastObject];
		temp = [(DKFill*)rast colour];
		[mStyleFillColourWell setEnabled:YES];
		[mStyleFillCheckbox setIntValue:YES];
	}
	else
	{
		temp = [NSColor whiteColor];
		[mStyleFillColourWell setEnabled:NO];
		[mStyleFillCheckbox setIntValue:NO];
	}	
	[mStyleFillColourWell setColor:temp];
	
	// set up the stroke controls if the style has a stroke property, or disable them
	// altogether if it does not.

	if([style hasStroke])
	{
		rast = [[style renderersOfClass:[DKStroke class]] lastObject];
		temp = [(DKStroke*)rast colour];
		sw = [(DKStroke*)rast width];
		[mStyleStrokeColourWell setEnabled:YES];
		[mStyleStrokeWidthStepper setEnabled:YES];
		[mStyleStrokeWidthTextField setEnabled:YES];
		[mStyleStrokeCheckbox setIntValue:YES];
	}
	else
	{
		temp = [NSColor whiteColor];
		sw = 1.0;
		[mStyleStrokeColourWell setEnabled:NO];
		[mStyleStrokeWidthStepper setEnabled:NO];
		[mStyleStrokeWidthTextField setEnabled:NO];
		[mStyleStrokeCheckbox setIntValue:NO];
	}
	
	[mStyleStrokeColourWell setColor:temp];
	[mStyleStrokeWidthStepper setFloatValue:sw];
	[mStyleStrokeWidthTextField setFloatValue:sw];
}


- (DKStyle*)	styleOfSelectedObject
{
	// return sthe style of the topmost selected object in the active layer, or nil if there is nothing selected.
	
	DKStyle* selectedStyle = nil;
	
	// get the active layer, but only if it's one that supports drawable objects
	
	DKObjectDrawingLayer* activeLayer = [[mDrawingView drawing] activeLayerOfClass:[DKObjectDrawingLayer class]];
	
	if( activeLayer != nil )
	{
		// get the selected objects and use the style of the last object, corresponding to the
		// one drawn last, or on top of all the others.
		
		NSArray* selectedObjects = [activeLayer selectedAvailableObjects];
		
		if(selectedObjects != nil && [selectedObjects count] > 0 )
			selectedStyle = [(DKDrawableObject*)[selectedObjects lastObject] style];
	}
	
	return selectedStyle;
}


#pragma mark -
#pragma mark - as a NSWindowController

- (void)		awakeFromNib
{
	// make sure the view has a drawing object initialised. While the view itself will do this for us later, we tip its hand now so that we definitely
	// have a valid DKDrawing object available for setting up the notifications and user interface. In this case we are simply allowing the view to
	// create and own the drawing, rather than owning ithere - though that would also be a perfectly valid way to do things.
	
	[mDrawingView createAutoDrawing];
	
	// subscribe to selection, layer and tool change notifications so that we can update the UI when these change
	
	
	[[NSNotificationCenter defaultCenter]	addObserver:self
											selector:@selector(drawingSelectionDidChange:)
											name:kGCLayerSelectionDidChange
											object:nil];

	[[NSNotificationCenter defaultCenter]	addObserver:self
											selector:@selector(drawingSelectionDidChange:)
											name:kDKStyleDidChangeNotification
											object:nil];
											
	[[NSNotificationCenter defaultCenter]	addObserver:self
											selector:@selector(activeLayerDidChange:)
											name:kDKDrawingActiveLayerDidChange
											object:[mDrawingView drawing]];
											
	[[NSNotificationCenter defaultCenter]	addObserver:self
											selector:@selector(selectedToolDidChange:)
											name:kDKDidChangeToolNotification
											object:nil];

	// creating the drawing set up the initial active layer but we weren't ready to listen to that notification. So that we can set
	// up the user-interface correctly this first time, just call the responder method directly now.
	
	[self activeLayerDidChange:nil];
}



#pragma mark -
#pragma mark - as the TableView dataSource


- (int)			numberOfRowsInTableView:(NSTableView*) aTable
{
	return [[mDrawingView drawing] countOfLayers];
}


- (id)			tableView:(NSTableView *)aTableView
				objectValueForTableColumn:(NSTableColumn *)aTableColumn
				row:(int)rowIndex
{
	return [[[[mDrawingView drawing] layers] objectAtIndex:rowIndex] valueForKey:[aTableColumn identifier]];
}


- (void)		tableView:(NSTableView *)aTableView
				setObjectValue:anObject
				forTableColumn:(NSTableColumn *)aTableColumn
				row:(int)rowIndex
{
	DKLayer* layer = [[[mDrawingView drawing] layers] objectAtIndex:rowIndex];
	[layer setValue:anObject forKey:[aTableColumn identifier]];
}

#pragma mark -
#pragma mark - as the TableView delegate

- (void)				tableViewSelectionDidChange:(NSNotification*) aNotification
{
	// when the user selects a different layer in the table, change the real active layer to match.
	
	if ([aNotification object] == mLayerTable)
	{
		int row = [mLayerTable selectedRow];
		
		if ( row != -1 )
			[[mDrawingView drawing] setActiveLayer:[[mDrawingView drawing] layerAtIndex:row]];
	}
}


#pragma mark -
#pragma mark - as the NSApplication delegate

- (void)		applicationDidFinishLaunching:(NSNotification*) aNotification
{
	// app ready to go - first turn off all style sharing. For this simple demo this makes life a bit easier.
	// (note - comment out this line and see what happens. It's perfectly safe ;-)
	
	[DKStyle setStylesAreSharableByDefault:NO];
	
	// register the default set of tools (Select, Rectangle, Oval, etc)
	
	[DKDrawingTool registerStandardTools];
}



#pragma mark -
#pragma mark - as the Window delegate

- (void)		windowDidResize:(NSNotification*) notification
{
	NSSize size = [mDrawingView frame].size;
	[[mDrawingView drawing] setDrawingSize:size];
}


- (NSUndoManager*) windowWillReturnUndoManager:(NSWindow*) window
{
	static DKUndoManager* um = nil;
	
	if( um == nil )
		um = [[DKUndoManager alloc] init];

	return um;
}


@end
