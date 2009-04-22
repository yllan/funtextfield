///**********************************************************************************************************************************
///  GCDashEditor.h
///  GCDrawKit
///
///  Created by graham on 18/05/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>


@class DKLineDash;


@interface GCDashEditor : NSWindowController
{
	IBOutlet	id		mDashMarkTextField1;
	IBOutlet	id		mDashSpaceTextField1;
	IBOutlet	id		mDashMarkTextField2;
	IBOutlet	id		mDashSpaceTextField2;
	IBOutlet	id		mDashMarkTextField3;
	IBOutlet	id		mDashSpaceTextField3;
	IBOutlet	id		mDashMarkTextField4;
	IBOutlet	id		mDashSpaceTextField4;
	IBOutlet	id		mDashCountButtonMatrix;
	IBOutlet	id		mDashScaleCheckbox;
	IBOutlet	id		mDashPreviewEditView;
	IBOutlet	id		mPreviewCheckbox;
	IBOutlet	id		mPhaseSlider;
	DKLineDash*			mDash;
	NSTextField*		mEF[8];
	id					mDelegateRef;
}


- (void)				openDashEditorInParentWindow:(NSWindow*) pw modalDelegate:(id) del;
- (void)				updateForDash;
- (void)				setDash:(DKLineDash*) dash;
- (DKLineDash*)			dash;

- (void)				setLineWidth:(float) width;
- (void)				setLineCapStyle:(NSLineCapStyle) lcs;
- (void)				setLineJoinStyle:(NSLineJoinStyle) ljs;
- (void)				setLineColour:(NSColor*) colour;

- (void)				setDashCount:(int) c;
- (void)				notifyDelegate;

- (IBAction)			ok:(id) sender;
- (IBAction)			cancel:(id) sender;
- (IBAction)			dashValueAction:(id) sender;
- (IBAction)			dashScaleCheckboxAction:(id) sender;
- (IBAction)			dashCountMatrixAction:(id) sender;
- (IBAction)			dashPhaseSliderAction:(id) sender;

@end



#pragma mark -

@interface NSObject (GCDashEditorDelegate)

- (void)				dashDidChange:(id) sender;

@end

