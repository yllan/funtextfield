#import <Cocoa/Cocoa.h>

@interface GCDrawDemoPrefsController : NSWindowController
{
	IBOutlet id			mQualityThrottlingCheckbox;
	IBOutlet id			mUndoSelectionsCheckbox;
}


- (IBAction)			qualityThrottlingAction:(id) sender;
- (IBAction)			undoableSelectionAction:(id) sender;

@end
