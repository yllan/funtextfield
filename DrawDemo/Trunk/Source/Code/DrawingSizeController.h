/* DrawingSizeController */

#import <Cocoa/Cocoa.h>


@class DKDrawing;



@interface DrawingSizeController : NSWindowController
{
    IBOutlet id mBottomMarginTextField;
    IBOutlet id mGridDivsTextField;
    IBOutlet id mGridMajorsTextField;
    IBOutlet id mGridPreviewCheckbox;
    IBOutlet id mGridSpanTextField;
    IBOutlet id mGridThemeColourWell;
    IBOutlet id mHeightTextField;
    IBOutlet id mLeftMarginTextField;
    IBOutlet id mRightMarginTextField;
    IBOutlet id mTopMarginTextField;
    IBOutlet id mTweakMarginsCheckbox;
    IBOutlet id mUnitsComboBox;
    IBOutlet id mWidthTextField;
	IBOutlet id	mGridControlsBox;
	IBOutlet id	mGridDivsSpinControl;
	IBOutlet id	mGridMajorsSpinControl;
	IBOutlet id	mGridAbbrevUnitsText;
	IBOutlet id	mGridPrintCheckbox;
	IBOutlet id mGridRulerStepsTextField;
	IBOutlet id mGridRulerStepsSpinControl;
	IBOutlet id	mConversionFactorTextField;
	IBOutlet id mConversionFactorSpinControl;
	IBOutlet id mConversionFactorLabelText;
	IBOutlet id	mPaperColourWell;
	
	DKDrawing*	mDrawing;
	BOOL		mLivePreview;
	float		mUnitConversionFactor;
	float		mSavedSpan;
	float		mSavedCF;
	int			mSavedDivs;
	int			mSavedMajors;
	NSString*	mSavedUnits;
	NSColor*	mSavedGridColour;
	NSColor*	mSavedPaperColour;
}


- (void)		beginDrawingSizeDialog:(NSWindow*) parent withDrawing:(DKDrawing*) drawing;

- (IBAction)	cancelAction:(id)sender;
- (IBAction)	gridDivsAction:(id)sender;
- (IBAction)	gridMajorsAction:(id)sender;
- (IBAction)	gridSpanAction:(id)sender;
- (IBAction)	gridRulerStepsAction:(id) sender;
- (IBAction)	gridThemeColourAction:(id)sender;
- (IBAction)	gridPrintAction:(id) sender;
- (IBAction)	livePreviewAction:(id)sender;
- (IBAction)	okAction:(id)sender;
- (IBAction)	unitsComboBoxAction:(id) sender;
- (IBAction)	conversionFactorAction:(id) sender;
- (IBAction)	paperColourAction:(id) sender;

@end
