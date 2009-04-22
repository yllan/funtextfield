/* GCLayersPaletteController */

#import <GCDrawKit/DKDrawkitInspectorBase.h>


@class DKDrawing;



@interface GCLayersPaletteController : DKDrawkitInspectorBase
{
    IBOutlet id		mLayersTable;
	IBOutlet id		mAutoActivateCheckbox;
	NSColor*		mTemporaryColour;
	int				mTemporaryColourRow;
}


- (void)			setDrawing:(DKDrawing*) drawing;
- (DKDrawing*)		drawing;

- (IBAction)		addLayerButtonAction:(id)sender;
- (IBAction)		removeLayerButtonAction:(id)sender;
- (IBAction)		autoActivationAction:(id) sender;

- (void)			setTemporaryColour:(NSColor*) aColour forTableView:(NSTableView*) tView row:(int) row;
@end


extern NSString*		kGCTableRowInternalDragPasteboardType;
