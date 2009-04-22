#import "GCDrawDemoPrefsController.h"
#import "GCDrawDemoDocument.h"
#import <GCDrawKit/DKObjectDrawingLayer.h>

@implementation GCDrawDemoPrefsController

- (IBAction)			qualityThrottlingAction:(id) sender
{
	[GCDrawDemoDocument setDefaultQualityModulation:[sender intValue]];
}


- (IBAction)			undoableSelectionAction:(id) sender
{
	[DKObjectDrawingLayer setDefaultSelectionChangesAreUndoable:[sender intValue]];
}


- (void)				awakeFromNib
{
	[mQualityThrottlingCheckbox setIntValue:[GCDrawDemoDocument defaultQualityModulation]];
	[mUndoSelectionsCheckbox setIntValue:[DKObjectDrawingLayer defaultSelectionChangesAreUndoable]];
}


@end
