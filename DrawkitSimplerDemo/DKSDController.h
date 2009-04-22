//
//  DKSDController.h
//  GCDrawKit
//
//  Created by graham on 19/06/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DKStyle;

// the controller class - this is the only custom class used in this demo application

@interface DKSDController : NSWindowController
{
// TOOLS
	IBOutlet	id	mToolMatrix;					// matrix of buttons for selecting the drawing tool
	IBOutlet	id	mToolStickyCheckbox;			// checkbox for setting "sticky" state of tools

// STYLE
	IBOutlet	id	mStyleFillCheckbox;				// checkbox for enabling the "fill" property
	IBOutlet	id	mStyleFillColourWell;			// colour well for the fill's colour
	IBOutlet	id	mStyleStrokeCheckbox;			// checkbox for enabling the "stroke" property
	IBOutlet	id	mStyleStrokeColourWell;			// colour well for the stroke's colour
	IBOutlet	id	mStyleStrokeWidthTextField;		// text field for the stroke's width
	IBOutlet	id	mStyleStrokeWidthStepper;		// stepper buttons for the stroke's width

// GRID
	IBOutlet	id	mGridMatrix;					// matrix of buttons for selecting the grid to use
	IBOutlet	id	mGridSnapCheckbox;				// checkbox to enable "snap to grid"

// LAYERS
	IBOutlet	id	mLayerTable;					// table view for listing the drawing's layers
	IBOutlet	id	mLayerAddButton;				// button for adding a new layer
	IBOutlet	id	mLayerRemoveButton;				// button for removing the active (selected) layer

// MAIN VIEW
	IBOutlet	id	mDrawingView;					// outlet to the main DKDrawingView that displays the content (and owns the drawing)
}

// TOOLS
- (IBAction)	toolMatrixAction:(id) sender;
- (IBAction)	toolStickyAction:(id) sender;

// STYLES
- (IBAction)	styleFillColourAction:(id) sender;
- (IBAction)	styleStrokeColourAction:(id) sender;
- (IBAction)	styleStrokeWidthAction:(id) sender;
- (IBAction)	styleFillCheckboxAction:(id) sender;
- (IBAction)	styleStrokeCheckboxAction:(id) sender;

// GRID
- (IBAction)	gridMatrixAction:(id) sender;
- (IBAction)	snapToGridAction:(id) sender;

// LAYERS
- (IBAction)	layerAddButtonAction:(id) sender;
- (IBAction)	layerRemoveButtonAction:(id) sender;

// Notifications
- (void)		drawingSelectionDidChange:(NSNotification*) note;
- (void)		activeLayerDidChange:(NSNotification*) note;
- (void)		selectedToolDidChange:(NSNotification*) note;

// Supporting methods
- (void)		updateControlsForSelection:(NSArray*) selection;
- (DKStyle*)	styleOfSelectedObject;

@end
