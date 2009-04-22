///**********************************************************************************************************************************
///  GCStyleInspector.h
///  GCDrawKit
///
///  Created by graham on 13/05/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>
#import <GCDrawKit/DKDrawkit.h>

@interface GCStyleInspector : DKDrawkitInspectorBase
{
	IBOutlet	id		mOutlineView;
	IBOutlet	id		mTabView;
	IBOutlet	id		mAddRendererPopUpButton;
	IBOutlet	id		mRemoveRendererButton;
	IBOutlet	id		mActionsPopUpButton;
	
	IBOutlet	id		mDashEditController;
	IBOutlet	id		mScriptEditController;
	
	IBOutlet	id		mStyleCloneButton;
	IBOutlet	id		mStyleLibraryPopUpButton;
	IBOutlet	id		mStyleLockCheckbox;
	IBOutlet	id		mStyleNameTextField;
	IBOutlet	id		mStylePreviewImageWell;
	IBOutlet	id		mStyleRegisteredIndicatorText;
	IBOutlet	id		mStyleAddToLibraryButton;
	IBOutlet	id		mStyleRemoveFromLibraryButton;
	IBOutlet	id		mStyleSharedCheckbox;
	IBOutlet	id		mStyleClientCountText;
	
	IBOutlet	id		mStrokeControlsTabView;
	IBOutlet	id		mStrokeColourWell;
	IBOutlet	id		mStrokeSlider;
	IBOutlet	id		mStrokeTextField;
	IBOutlet	id		mStrokeShadowCheckbox;
	IBOutlet	id		mStrokeShadowGroup;
	IBOutlet	id		mStrokeShadowColourWell;
	IBOutlet	id		mStrokeShadowAngle;
	IBOutlet	id		mStrokeShadowBlur;
	IBOutlet	id		mStrokeShadowDistance;
	IBOutlet	id		mStrokeDashPopUpButton;
	IBOutlet	id		mStrokeArrowDimensionOptions;
	IBOutlet	id		mStrokeArrowStartPopUpButton;
	IBOutlet	id		mStrokeArrowEndPopUpButton;
	IBOutlet	id		mStrokeArrowPreviewImageWell;
	IBOutlet	id		mStrokeZZLength;
	IBOutlet	id		mStrokeZZAmp;
	IBOutlet	id		mStrokeZZSpread;
	IBOutlet	id		mStrokeLineJoinSelector;
	IBOutlet	id		mStrokeLineCapSelector;
	IBOutlet	id		mStrokeRoughnessSlider;
	
	IBOutlet	id		mFillControlsTabView;
	IBOutlet	id		mFillGradientControlBar;
	IBOutlet	id		mFillGradientAddButton;
	IBOutlet	id		mFillGradientRemoveButton;
	IBOutlet	id		mFillGradientAngleSlider;
	IBOutlet	id		mFillGradientAngleTextField;
	IBOutlet	id		mFillGradientAngleLittleArrows;
	IBOutlet	id		mFillGradientRelativeToObject;
	IBOutlet	id		mFillColourWell;
	IBOutlet	id		mFillShadowCheckbox;
	IBOutlet	id		mFillShadowGroup;
	IBOutlet	id		mFillShadowColourWell;
	IBOutlet	id		mFillShadowAngle;
	IBOutlet	id		mFillShadowBlur;
	IBOutlet	id		mFillShadowDistance;
	IBOutlet	id		mFillPatternImagePreview;
	IBOutlet	id		mFillZZLength;
	IBOutlet	id		mFillZZAmp;
	IBOutlet	id		mFillZZSpread;
	
	IBOutlet	id		mImageWell;
	IBOutlet	id		mImageIdentifierTextField;
	IBOutlet	id		mImageOpacitySlider;
	IBOutlet	id		mImageScaleSlider;
	IBOutlet	id		mImageAngleSlider;
	IBOutlet	id		mImageClipToPathCheckbox;
	IBOutlet	id		mImageFittingPopUpMenu;
	
	IBOutlet	id		mCIFilterPopUpMenu;
	IBOutlet	id		mCIFilterClipToPathCheckbox;
	
	IBOutlet	id		mTextLabelTextField;
	IBOutlet	id		mTextIdentifierTextField;
	IBOutlet	id		mTextLayoutPopUpButton;
	IBOutlet	id		mTextAlignmentPopUpButton;
	IBOutlet	id		mTextLabelPlacementPopUpButton;
	IBOutlet	id		mTextWrapLinesCheckbox;
	IBOutlet	id		mTextClipToPathCheckbox;
	IBOutlet	id		mTextRelativeAngleCheckbox;
	IBOutlet	id		mTextAngleSlider;
	IBOutlet	id		mTextColourWell;
	IBOutlet	id		mFlowedTextInsetSlider;
	
	IBOutlet	id		mHatchColourWell;
	IBOutlet	id		mHatchSpacingSlider;
	IBOutlet	id		mHatchSpacingTextField;
	IBOutlet	id		mHatchLineWidthSlider;
	IBOutlet	id		mHatchLineWidthTextField;
	IBOutlet	id		mHatchAngleSlider;
	IBOutlet	id		mHatchAngleTextField;
	IBOutlet	id		mHatchLeadInSlider;
	IBOutlet	id		mHatchLeadInTextField;
	IBOutlet	id		mHatchDashPopUpButton;
	IBOutlet	id		mHatchRelativeAngleCheckbox;
	IBOutlet	id		mHatchLineCapButton;
	
	IBOutlet	id		mPDControlsTabView;
	IBOutlet	id		mPDIntervalSlider;
	IBOutlet	id		mPDScaleSlider;
	IBOutlet	id		mPDNormalToPathCheckbox;
	IBOutlet	id		mPDLeaderSlider;
	IBOutlet	id		mPDPreviewImage;
	IBOutlet	id		mPDPatAltOffsetSlider;
	IBOutlet	id		mPDRampProportionSlider;
	IBOutlet	id		mPDAngleSlider;
	IBOutlet	id		mPDRelativeAngleCheckbox;
	IBOutlet	id		mMotifAngleSlider;
	IBOutlet	id		mMotifRelativeAngleCheckbox;
	
	IBOutlet	id		mBlendModePopUpButton;
	IBOutlet	id		mBlendGroupAlphaSlider;
	IBOutlet	id		mBlendGroupImagePreview;
	
	IBOutlet	id		mShadowAngleSlider;
	IBOutlet	id		mShadowDistanceSlider;
	IBOutlet	id		mShadowColourWell;
	IBOutlet	id		mShadowBlurRadiusSlider;
	
	DKStyle*			mStyle;
	DKRasterizer*		mSelectedRendererRef;
	BOOL				mIsChangingGradient;
	DKRasterizer*		mDragItem;
	DKLineDash*			mSavedDash;
}

// general state management:

- (void)				setStyle:(DKStyle*) style;
- (DKStyle*)			style;
- (void)				updateUIForStyle;
- (void)				updateStylePreview;

// responding to notifications:

- (void)				styleChanged:(NSNotification*) note;
- (void)				styleAttached:(NSNotification*) note;
- (void)				styleRegistered:(NSNotification*) note;

// selecting which tab view is shown for the selected rasterizer:

- (void)				selectTabPaneForObject:(DKRasterizer*) obj;
- (void)				addAndSelectNewRenderer:(DKRasterizer*) obj;

// refreshing the UI for different selected rasterizers as the selection changes:

- (void)				updateSettingsForStroke:(DKStroke*) stroke;
- (void)				updateSettingsForFill:(DKFill*) fill;
- (void)				updateSettingsForHatch:(DKHatching*) hatch;
- (void)				updateSettingsForImage:(DKImageAdornment*) ir;
- (void)				updateSettingsForCoreImageEffect:(DKCIFilterRastGroup*) effg;
- (void)				updateSettingsForTextLabel:(DKTextAdornment*) tlr;
- (void)				updateSettingsForPathDecorator:(DKPathDecorator*) pd;
- (void)				updateSettingsForBlendEffect:(DKQuartzBlendRastGroup*) brg;

// setting up various menu listings:

- (void)				populatePopUpButtonWithLibraryStyles:(NSPopUpButton*) button;
- (void)				populateMenuWithDashes:(NSMenu*) menu;
- (void)				populateMenuWithCoreImageFilters:(NSMenu*) menu;

// opening the subsidiary sheet for editing dashes:

- (void)				openDashEditor;

// actions from stroke widgets:

- (IBAction)			strokeColourAction:(id) sender;
- (IBAction)			strokeWidthAction:(id) sender;
- (IBAction)			strokeShadowCheckboxAction:(id) sender;
- (IBAction)			strokeDashMenuAction:(id) sender;
- (IBAction)			strokePathScaleAction:(id) sender;
- (IBAction)			strokeArrowStartMenuAction:(id) sender;
- (IBAction)			strokeArrowEndMenuAction:(id) sender;
- (IBAction)			strokeArrowShowDimensionAction:(id) sender;
- (IBAction)			strokeTrimLengthAction:(id) sender;
- (IBAction)			strokeZigZagLengthAction:(id) sender;
- (IBAction)			strokeZigZagAmplitudeAction:(id) sender;
- (IBAction)			strokeZigZagSpreadAction:(id) sender;
- (IBAction)			strokeLineJoinStyleAction:(id) sender;
- (IBAction)			strokeLineCapStyleAction:(id) sender;
- (IBAction)			strokeRoughnessAction:(id) sender;

// actions from fill widgets:

- (IBAction)			fillColourAction:(id) sender;
- (IBAction)			fillShadowCheckboxAction:(id) sender;
- (IBAction)			fillGradientAction:(id) sender;
- (IBAction)			fillRemoveGradientAction:(id) sender;
- (IBAction)			fillAddGradientAction:(id) sender;
- (IBAction)			fillGradientAngleAction:(id) sender;
- (IBAction)			fillGradientRelativeToObjectAction:(id) sender;
- (IBAction)			fillPatternPasteImageAction:(id) sender;
- (IBAction)			fillZigZagLengthAction:(id) sender;
- (IBAction)			fillZigZagAmplitudeAction:(id) sender;
- (IBAction)			fillZigZagSpreadAction:(id) sender;

// actions from style registry widgets:

- (IBAction)			scriptButtonAction:(id) sender;
- (IBAction)			libraryMenuAction:(id) sender;
- (IBAction)			libraryItemAction:(id) sender;
- (IBAction)			sharedStyleCheckboxAction:(id) sender;
- (IBAction)			styleNameAction:(id) sender;
- (IBAction)			cloneStyleAction:(id) sender;
- (IBAction)			unlockStyleAction:(id) sender;

// actions from general style widgets:

- (IBAction)			addRendererElementAction:(id) sender;
- (IBAction)			removeRendererElementAction:(id) sender;
- (IBAction)			duplicateRendererElementAction:(id) sender;
- (IBAction)			copyRendererElementAction:(id) sender;
- (IBAction)			pasteRendererElementAction:(id) sender;
- (IBAction)			removeTextAttributesAction:(id) sender;

// actions from image adornment widgets:

- (IBAction)			imageFileButtonAction:(id) sender;
- (IBAction)			imageWellAction:(id) sender;
- (IBAction)			imageIdentifierAction:(id) sender;
- (IBAction)			imageOpacityAction:(id) sender;
- (IBAction)			imageScaleAction:(id) sender;
- (IBAction)			imageAngleAction:(id) sender;
- (IBAction)			imageFittingMenuAction:(id) sender;
- (IBAction)			imageClipToPathAction:(id) sender;

// actions from hatch widgets:

- (IBAction)			hatchColourWellAction:(id) sender;
- (IBAction)			hatchSpacingAction:(id) sender;
- (IBAction)			hatchLineWidthAction:(id) sender;
- (IBAction)			hatchAngleAction:(id) sender;
- (IBAction)			hatchRelativeAngleAction:(id) sender;
- (IBAction)			hatchDashMenuAction:(id) sender;
- (IBAction)			hatchLeadInAction:(id) sender;

// actions from CI Filter widgets:

- (IBAction)			filterMenuAction:(id) sender;
- (IBAction)			filterClipToPathAction:(id) sender;

// actions from text adornment widgets

- (IBAction)			textLabelAction:(id) sender;
- (IBAction)			textIdentifierAction:(id) sender;
- (IBAction)			textLayoutAction:(id) sender;
- (IBAction)			textAlignmentMenuAction:(id) sender;
- (IBAction)			textPlacementMenuAction:(id) sender;
- (IBAction)			textWrapLinesAction:(id) sender;
- (IBAction)			textClipToPathAction:(id) sender;
- (IBAction)			textRelativeAngleAction:(id) sender;
- (IBAction)			textAngleAction:(id) sender;
- (IBAction)			textFontButtonAction:(id) sender;
- (IBAction)			textColourAction:(id) sender;
- (IBAction)			textChangeFontAction:(id) sender;
- (IBAction)			textFlowInsetAction:(id) sender;

// actions from path decaorator widgets:

- (IBAction)			pathDecoratorIntervalAction:(id) sender;
- (IBAction)			pathDecoratorScaleAction:(id) sender;
- (IBAction)			pathDecoratorPasteObjectAction:(id) sender;
- (IBAction)			pathDecoratorPathNormalAction:(id) sender;
- (IBAction)			pathDecoratorLeaderDistanceAction:(id) sender;
- (IBAction)			pathDecoratorAltPatternAction:(id) sender;
- (IBAction)			pathDecoratorRampProportionAction:(id) sender;
- (IBAction)			pathDecoratorAngleAction:(id) sender;
- (IBAction)			pathDecoratorRelativeAngleAction:(id) sender;
- (IBAction)			pathDecoratorMotifAngleAction:(id) sender;
- (IBAction)			pathDecoratorMotifRelativeAngleAction:(id) sender;

// actions from blend effect widgets:

- (IBAction)			blendModeAction:(id) sender;
- (IBAction)			blendGroupAlphaAction:(id) sender;
- (IBAction)			blendGroupImagePasteAction:(id) sender;

// actions from shadow widgets:

- (IBAction)			shadowAngleAction:(id) sender;
- (IBAction)			shadowDistanceAction:(id) sender;
- (IBAction)			shadowBlurRadiusAction:(id) sender;
- (IBAction)			shadowColourAction:(id) sender;

@end


@interface NSObject (ImageResources)

- (NSImage*)		imageNamed:(NSString*) name fromBundleForClass:(Class) class;

@end


// tab indexes for main tab view

enum
{
	kGCInspectorStrokeTab			= 0,
	kGCInspectorFillTab				= 1,
	kGCInspectorMultipleItemsTab	= 2,
	kGCInspectorNoItemsTab			= 3,
	kGCInspectorStylePreviewTab		= 4,
	kGCInspectorImageTab			= 5,
	kGCInspectorFilterTab			= 6,
	kGCInspectorLabelTab			= 7,
	kGCInspectorHatchTab			= 8,
	kGCInspectorPathDecorTab		= 9,
	kGCInspectorBlendModeTab		= 10
};


// tab indexes for fill type tab view

enum
{
	kGCInspectorFillTypeSolid		= 0,
	kGCInspectorFillTypeGradient	= 1,
	kGCInspectorFillTypePattern		= 2
};

// tags in Add Renderer menu

enum
{
	kGCAddStrokeRendererTag			= 0,
	kGCAddFillRendererTag			= 1,
	kGCAddGroupRendererTag			= 2,
	kGCAddImageRendererTag			= 3,
	kGCAddCoreEffectRendererTag		= 4,
	kGCAddLabelRendererTag			= 5,
	kGCAddHatchRendererTag			= 6,
	kGCAddArrowStrokeRendererTag	= 7,
	kGCAddPathDecoratorRendererTag	= 8,
	kGCAddPatternFillRendererTag	= 9,
	kGCAddBlendEffectRendererTag	= 10,
	kGCAddZigZagStrokeRendererTag	= 11,
	kGCAddZigZagFillRendererTag		= 12,
	kGCAddRoughStrokeRendererTag	= 13
};


// tags used to selectively hide or disable particular items in the UI (such as labels) without needing
// an explicit outlet to them. The tags are deliberately set to arbitrary numbers that are unlikely to be accidentally set.

enum
{
	kGCZigZagParameterItemsTag			= 145,
	kGCPathDecoratorParameterItemsTag	= 146,
	kGCPatternFillParameterItemsTag		= 147,
	kGCArrowStrokeParameterItemsTag		= 148,
	kGCShadowParameterItemsTag			= 149,
	kGCRoughStrokeParameterItemsTag		= 150
};


extern NSString*		kGCTableRowInternalDragPasteboardType;


// utility categories that help manage the user interface

@interface NSMenu (GCAdditions)

- (void)	disableItemsWithTag:(int) tag;
- (void)	removeAllItems;
- (void)	uncheckAllItems;

@end



@interface NSView (TagEnablingAdditions)

- (void)	setSubviewsWithTag:(int) tag hidden:(BOOL) hide;
- (void)	setSubviewsWithTag:(int) tag enabled:(BOOL) enable;

@end

