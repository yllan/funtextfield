/* GCPolarDuplicateController */

#import <Cocoa/Cocoa.h>

@interface GCPolarDuplicateController : NSWindowController
{
    IBOutlet id mAngleIncrementTextField;
    IBOutlet id mCentreXTextField;
    IBOutlet id mCentreYTextField;
    IBOutlet id mCopiesTextField;
    IBOutlet id mRotateCopiesCheckbox;
	IBOutlet id	mAutoFitCircleCheckbox;
	IBOutlet id	mOKButton;
	IBOutlet id	mCancelButton;
	IBOutlet id	mManualSettingsBox;
	
	id			mDelegateRef;
}


- (IBAction)	angleAction:(id)sender;
- (IBAction)	cancelAction:(id)sender;
- (IBAction)	centreAction:(id)sender;
- (IBAction)	copiesAction:(id)sender;
- (IBAction)	duplicateAction:(id)sender;
- (IBAction)	rotateCopiesAction:(id)sender;
- (IBAction)	autoFitAction:(id) sender;


- (void)	beginPolarDuplicationDialog:(NSWindow*) parentWindow polarDelegate:(id) delegate;
- (void)	sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;

- (void)	conditionallyEnableOKButton;

@end



@interface NSObject (PolarDuplicationDelegate)

- (void)	doPolarDuplicateCopies:(int) copies centre:(NSPoint) cp incAngle:(float) angle rotateCopies:(BOOL) rotCopies;
- (void)	doAutoPolarDuplicateWithCentre:(NSPoint) cp;
- (int)		countOfItemsInSelection;

@end
