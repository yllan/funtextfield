//
//  GCDrawDemoDocument.m
//  GCDrawDemo
//
//  Created by Jason Jobe on 2/18/07.
//  Copyright __MyCompanyName__ 2007 . All rights reserved.
//

#import "GCDrawDemoDocument.h"

#import "GCPolarDuplicateController.h"
#import "GCLinearDuplicateController.h"
#import "DrawingSizeController.h"
#import "GCBasicDialogController.h"

#import <GCDrawKit/DKDrawKit.h>


@implementation GCDrawDemoDocument
#pragma mark As a GCDrawDemoDocument

static BOOL		sDefaultQualityMod = NO;


+ (void)				setDefaultQualityModulation:(BOOL) dqm
{
	sDefaultQualityMod = dqm;
	
	// also push the setting out to all current documents
	
	NSEnumerator* iter = [[[NSDocumentController sharedDocumentController] documents] objectEnumerator]; 
	id			  doc;
	
	while(( doc = [iter nextObject]))
	{
		if([doc isKindOfClass:[DKDrawingDocument class]])
			[[doc drawing] setDynamicQualityModulationEnabled:dqm];
	}
}


+ (BOOL)				defaultQualityModulation
{
	return sDefaultQualityMod;
}



- (NSString*)			askUserForToolName
{
	// this method needs redoing for Leopard, but is not currently used anyway
	
	// displays the tool naming sheet, handles it, and returns the entered name (or nil, if the dialog was cancelled or no name entered)
	/*
	NSString* s = nil;
	
	int result = [mToolNamePanelController runModalWithParentWindow:[self windowForSheet]];
	
	if ( result == NSOKButton )
		s = [[mToolNamePanelController primaryItem] stringValue];
	
	return s;
	*/
	
	return  nil;
}


#pragma mark -
- (IBAction)			makeToolFromSelectedShape:(id) sender
{
#pragma unused (sender)
	// allows a single selected shape in the active layer to be turned into a named tool. If the selection is valid, this then asks the user
	// for a name for the tool.
	
	DKObjectDrawingLayer*	layer = [[self drawing] activeLayerOfClass:[DKObjectDrawingLayer class]];
	
	if ( layer )
	{
		if ([layer isSingleObjectSelected] && [layer selectionContainsObjectOfClass:[DKDrawableShape class]])
		{
			DKDrawableShape*	shape = (DKDrawableShape*)[layer singleSelection];
			
			// ok, got an object that can be turned into a tool, so ask the user to name it.
			
			NSString* toolName = [self askUserForToolName];
			
			if ( toolName )
				[DKObjectCreationTool registerDrawingToolForObject:shape withName:toolName];
		}
	}
}


#pragma mark -
- (IBAction)			polarDuplicate:(id) sender
{
#pragma unused (sender)
	[mPolarDuplicateController beginPolarDuplicationDialog:[self windowForSheet] polarDelegate:self];
}


- (IBAction)			linearDuplicate:(id) sender
{
#pragma unused (sender)
	[mLinearDuplicateController beginLinearDuplicationDialog:[self windowForSheet] linearDelegate:self];
}


#pragma mark -
- (IBAction)			openDrawingSizePanel:(id) sender
{
#pragma unused (sender)
	if ( mDrawingSizeController == nil )
		mDrawingSizeController = [[DrawingSizeController alloc] initWithWindowNibName:@"Drawingsize"];
	
	[mDrawingSizeController beginDrawingSizeDialog:[self windowForSheet] withDrawing:[self drawing]];
}


#pragma mark -
- (IBAction)	test:(id) sender
{
#pragma unused (sender)
}


#pragma mark -
#pragma mark As an DKDrawingDocument

- (void)			setDrawing:(DKDrawing*) dwg
{
	[super setDrawing:dwg];
	[dwg setDynamicQualityModulationEnabled:[[self class] defaultQualityModulation]];
}


#pragma mark -
#pragma mark As an NSDocument
- (NSString *)		windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"GCDrawDemoDocument";
}


- (void)			windowControllerDidLoadNib:(NSWindowController*) winController
{
	// zoom the window to max size initially
	// call super to ensure correct establishment of model-view-controller within the DK internals
	
	[super windowControllerDidLoadNib:winController];
	[[winController window] zoom:self];
}


#pragma mark -
#pragma mark As a PolarDuplication delegate
- (int)				countOfItemsInSelection
{
	DKObjectDrawingLayer* odl = [[self drawing] activeLayerOfClass:[DKObjectDrawingLayer class]];
	
	if ( odl != nil )
		return [[odl selectedAvailableObjects] count];
	else
		return 0;
}


- (void)	doPolarDuplicateCopies:(int) copies centre:(NSPoint) cp incAngle:(float) angle rotateCopies:(BOOL) rotCopies
{
	// callback from dialog. Locate the selection and use the object drawing layer method to do the deed. Note - centre is passed
	// in grid coordinates so needs converting to the drawing, and the angle is in degrees and needs converting to radians.
	
	DKObjectDrawingLayer* odl = [[self drawing] activeLayerOfClass:[DKObjectDrawingLayer class]];
	
	if ( odl != nil )
	{
		NSArray* target = [odl selectedAvailableObjects];
		
		if ( target && [target count] > 0 )
		{
			// convert the units
			
			float radians = ( angle * pi ) / 180.0f;
			
			DKGridLayer* grid = [[self drawing] gridLayer];
			
			NSPoint drawingPt = [grid pointForGridLocation:cp];
		
			NSArray* newCopies = [odl	polarDuplicate:target
										centre:drawingPt
										numberOfCopies:copies
										incrementAngle:radians
										rotateCopies:rotCopies];
										
			// add newCopies to the layer and select them
			
			if ([newCopies count] > 0 )
			{
			//	LogEvent_(kReactiveEvent, @"copies: %@", newCopies);
				
				[odl recordSelectionForUndo];
				[odl addObjects:newCopies];
				[odl exchangeSelectionWithObjectsInArray:newCopies];
				[odl commitSelectionUndoWithActionName:NSLocalizedString(@"Polar Duplication", @"polar dupe undo string")];
			}
		}
	}
}


- (void)				doAutoPolarDuplicateWithCentre:(NSPoint) cp
{
	DKObjectDrawingLayer* odl = [[self drawing] activeLayerOfClass:[DKObjectDrawingLayer class]];
	
	if ( odl != nil )
	{
		DKDrawableObject* target = [odl singleSelection];
		
		if ( target )
		{
			DKGridLayer* grid = [[self drawing] gridLayer];
			
			NSPoint drawingPt = [grid pointForGridLocation:cp];
		
			NSArray* newCopies = [odl	autoPolarDuplicate:target centre:drawingPt];
										
			// add newCopies to the layer and select them
			
			if ([newCopies count] > 0 )
			{
			//	LogEvent_(kReactiveEvent, @"copies: %@", newCopies);
				
				[odl recordSelectionForUndo];
				[odl addObjects:newCopies];
				[odl exchangeSelectionWithObjectsInArray:newCopies];
				[odl commitSelectionUndoWithActionName:NSLocalizedString(@"Auto Polar Duplication", @"auto dupe undo string")];
			}
		}
	}
}

#pragma mark -
#pragma mark As a LinearDuplication delegate

- (void)	doLinearDuplicateCopies:(int) copies offset:(NSSize) offset
{
	DKObjectDrawingLayer* odl = [[self drawing] activeLayerOfClass:[DKObjectDrawingLayer class]];
	
	if ( odl != nil )
	{
		NSArray* target = [odl selectedAvailableObjects];
		
		if ( target && [target count] > 0 )
		{
			// convert the units

			DKGridLayer* grid = [[self drawing] gridLayer];
			NSSize	drawingOffset;
			
			drawingOffset.width = [grid quartzDistanceForGridDistance:offset.width];
			drawingOffset.height = [grid quartzDistanceForGridDistance:offset.height];
		
			NSArray* newCopies = [odl linearDuplicate:target
										offset:drawingOffset
										numberOfCopies:copies];
										
			// add newCopies to the layer and select them
			
			if ([newCopies count] > 0 )
			{
			//	LogEvent_(kReactiveEvent, @"copies: %@", newCopies);
				
				[odl recordSelectionForUndo];
				[odl addObjects:newCopies];
				[odl exchangeSelectionWithObjectsInArray:newCopies];
				[odl commitSelectionUndoWithActionName:NSLocalizedString(@"Linear Duplication", @"linear dupe undo string")];
			}
		}
	}
}


#pragma mark -
#pragma mark As part of NSMenuValidation  Protocol

- (BOOL)			validateMenuItem:(NSMenuItem*) menuItem
{
	BOOL enable = YES;
	SEL action = [menuItem action];
	
	NSAssert(menuItem != nil, @"Expected valid menuItem");
	if ( action == @selector(linearDuplicate:))
	{
		enable = ([self countOfItemsInSelection] > 0);
	}
	else if ( action == @selector(polarDuplicate:) ||
			 action == @selector( newLayerWithSelection: ))
	{
		enable = ([self countOfItemsInSelection] > 0);
	}
	return enable;
}


@end
