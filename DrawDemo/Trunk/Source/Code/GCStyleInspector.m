///**********************************************************************************************************************************
///  GCStyleInspector.m
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

#import "GCStyleInspector.h"

#import "GCGradientWell.h"
#import "GCGradientCell.h"
#import "GCDashEditor.h"
#import "GCDashEditView.h"
#import "GCBasicDialogController.h"

#import <QuartzCore/CIFilter.h>
#import <GCDrawKit/NSShadow+Scaling.h>


@implementation GCStyleInspector
#pragma mark As a GCStyleInspector

- (void)				setStyle:(DKStyle*) style
{
	if ( style != mStyle )
	{
		if ( mStyle )
			[[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:mStyle];

		[style retain];
		[mStyle release];
		mStyle = style;
		
		// listen for style change notifications so we can track changes made by undo, etc
		
		if( mStyle )
		{
			[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(styleChanged:) name:kDKStyleDidChangeNotification object:mStyle];
		}
		[self updateUIForStyle];
	}
}


- (DKStyle*)			style
{
	return mStyle;
}


- (void)				updateUIForStyle
{
	// set up the UI to match the style attached
	
//	LogEvent_(kInfoEvent, @"selected style = %@", mStyle );
	
	mSelectedRendererRef = nil;
	
	[mOutlineView reloadData];
	
	if ( mStyle != nil )
	{
		[mOutlineView expandItem:[self style] expandChildren:YES];
		[mOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
		
		[mStyleLockCheckbox setEnabled:YES];
		[mStyleSharedCheckbox setIntValue:[[self style] isStyleSharable]];
		[mStyleLockCheckbox setIntValue:[[self style] locked]];
		[mStyleClientCountText setIntValue:[[self style] countOfClients]];
		
		if ([[self style] name])
			[mStyleNameTextField setStringValue:[[self style] name]];
		else
			[mStyleNameTextField setStringValue:@""];
			
		if( ![mStyle locked])
		{
			[mAddRendererPopUpButton setEnabled:YES];
			[mRemoveRendererButton setEnabled:YES];
			[mStyleNameTextField setEnabled:YES];
			[mStyleSharedCheckbox setEnabled:YES];
			//[mActionsPopUpButton setEnabled:YES];
		}
		else
		{
			[mAddRendererPopUpButton setEnabled:NO];
			[mRemoveRendererButton setEnabled:NO];
			[mStyleNameTextField setEnabled:NO];
			[mStyleSharedCheckbox setEnabled:NO];
			//[mActionsPopUpButton setEnabled:NO];
		}
		
		// if the style isn't in the registry, disable the lock checkbox
		
		BOOL registered = [[self style] isStyleRegistered];
		
		//[mStyleLockCheckbox setEnabled:registered];
		[mStyleRegisteredIndicatorText setHidden:!registered];
		[mStyleAddToLibraryButton setEnabled:!registered];
		[mStyleRemoveFromLibraryButton setEnabled:registered];
		[mStyleCloneButton setEnabled:YES];
		[self updateStylePreview];
	}
	else
	{
		[mOutlineView deselectAll:self];
		[mAddRendererPopUpButton setEnabled:NO];
		[mRemoveRendererButton setEnabled:NO];
		[mStyleNameTextField setStringValue:@""];
		[mStyleNameTextField setEnabled:NO];
		[mStyleSharedCheckbox setEnabled:NO];
		[mStyleRegisteredIndicatorText setHidden:YES];
		[mStyleAddToLibraryButton setEnabled:NO];
		[mStyleRemoveFromLibraryButton setEnabled:NO];
		[mStyleCloneButton setEnabled:NO];
		[mStyleLockCheckbox setEnabled:NO];
		[mStylePreviewImageWell setImage:nil];
	}
}


- (void)				updateStylePreview
{
	NSSize is = NSMakeSize( 128, 128 );

	NSImage* img = [[[self style] styleSwatchWithSize:is type:kGCStyleSwatchAutomatic] copy];
	[mStylePreviewImageWell setImage:img];
	[img release];
}


- (void)				styleChanged:(NSNotification*) note
{
//	LogEvent_(kInfoEvent, @"style changed notification: %@", note );
	
	if([note object] == [self style]) // && !mIsChangingGradient
	{
		if ( mSelectedRendererRef == nil )
			[self updateUIForStyle];
		else
			[self selectTabPaneForObject:mSelectedRendererRef];
		
		[mOutlineView reloadData];
		[self updateStylePreview];
	}
}


- (void)				styleAttached:(NSNotification*) note
{
	// a style is being changed in some object - if the style being detached is our current style,
	// then update the UI to show the new one being attached, otherwise just ignore it. This allows this
	// UI to keep up with undo, style pasting, drag modifications and so on
		
	id	theOldStyle = [[note userInfo] objectForKey:kDKDrawableOldStyleKey];
	
	if ( theOldStyle == [self style])
		[self setStyle:[[note userInfo] objectForKey:kDKDrawableNewStyleKey]];
}


- (void)				styleRegistered:(NSNotification*) note
{
#pragma unused (note)
	//[self populateMenuWithLibraryStyles:[mStyleLibraryPopUpButton menu]];
	
	[self populatePopUpButtonWithLibraryStyles:mStyleLibraryPopUpButton];
}


#pragma mark -
- (void)			selectTabPaneForObject:(DKRasterizer*) obj
{
	// given an item in the outline view, this selects the appropriate tab view and sets its widget contents
	// to match the object
	
	if ( mSelectedRendererRef != obj )
	{
		// reset the font manager's action, in case an earlier label editor changed it:
		
		[[NSFontManager sharedFontManager] setAction:@selector(changeFont:)];
	}
		
	mSelectedRendererRef = obj;

	int	tab = -1;
	
	if([obj isKindOfClass:[DKStroke class]])
		tab = kGCInspectorStrokeTab;
	else if ([obj isKindOfClass:[DKFill class]])
		tab = kGCInspectorFillTab;
	else if ([obj isKindOfClass:[DKCIFilterRastGroup class]])
		tab = kGCInspectorFilterTab;
	else if ([obj isKindOfClass:[DKQuartzBlendRastGroup class]])
		tab = kGCInspectorBlendModeTab;
	else if ([obj isKindOfClass:[DKRastGroup class]])
		tab = kGCInspectorStylePreviewTab;
	else if ([obj isKindOfClass:[DKImageAdornment class]])
		tab = kGCInspectorImageTab;
	else if ([obj isKindOfClass:[DKHatching class]])
		tab = kGCInspectorHatchTab;
	else if ([obj isKindOfClass:[DKTextAdornment class]])
		tab = kGCInspectorLabelTab;
	else if ([obj isKindOfClass:[DKPathDecorator class]] || [obj isKindOfClass:[DKFillPattern class]])
		tab = kGCInspectorPathDecorTab;
		
		
//	LogEvent_(kInfoEvent, @"tab selected = %d", tab );
	
	if ( tab != -1 )
	{
		// synch tab's contents with selected renderer attributes
		
		switch( tab )
		{
			case kGCInspectorStrokeTab:
				[self updateSettingsForStroke:(DKStroke*) mSelectedRendererRef];
				break;
				
			case kGCInspectorFillTab:
				[self updateSettingsForFill:(DKFill*) mSelectedRendererRef];
				break;
				
			case kGCInspectorHatchTab:
				[self updateSettingsForHatch:(DKHatching*) mSelectedRendererRef];
				break;
				
			case kGCInspectorImageTab:
				[self updateSettingsForImage:(DKImageAdornment*) mSelectedRendererRef];
				break;
				
			case kGCInspectorFilterTab:
				[self updateSettingsForCoreImageEffect:(DKCIFilterRastGroup*) mSelectedRendererRef];
				break;
				
			case kGCInspectorLabelTab:
				[self updateSettingsForTextLabel:(DKTextAdornment*) mSelectedRendererRef];
				break;
				
			case kGCInspectorPathDecorTab:
				[self updateSettingsForPathDecorator:(DKPathDecorator*) mSelectedRendererRef];
				break;
				
			case kGCInspectorBlendModeTab:
				[self updateSettingsForBlendEffect:(DKQuartzBlendRastGroup*) mSelectedRendererRef];
				break;
				
			case kGCInspectorStylePreviewTab:
				[self updateStylePreview];
				break;
				
			default:
				break;
		}
		
		[mTabView selectTabViewItemAtIndex:tab];
	}
	else
		[mTabView selectTabViewItemAtIndex:kGCInspectorNoItemsTab];
}


- (void)				addAndSelectNewRenderer:(DKRasterizer*) obj
{
	// given a renderer object, this adds it to the end of the currently selected group and selects it.
	
	NSAssert( obj != nil, @"trying to insert a nil renderer");
	
	// need to determine which group is currently selected in the outline view to give the item a parent
	
	DKRastGroup*	parent;
	id				sel = [mOutlineView itemAtRow:[mOutlineView selectedRow]];
	
	if ( sel == nil )
		parent = [self style];
	else
	{
		if ([sel isKindOfClass:[DKRastGroup class]])
			parent = sel;
		else
			parent = (DKRastGroup*)[sel container];
	}
	
	mSelectedRendererRef = nil;
	
	[[self style] notifyClientsBeforeChange];
	[parent addRenderer:obj];
	[[self style] notifyClientsAfterChange];

	[mOutlineView reloadData];
	
	int row = [mOutlineView rowForItem:obj];
	
	if ( row != NSNotFound )
		[mOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
}

#pragma mark -
- (void)				updateSettingsForStroke:(DKStroke*) stroke
{
	// set UI widgets to match stroke's attributes
	
	[mStrokeColourWell setColor:[stroke colour]];
	[mStrokeSlider setFloatValue:[stroke width]];
	[mStrokeTextField setFloatValue:[stroke width]];
	[mStrokeShadowCheckbox setIntValue:[stroke shadow] != nil];
	
	// set dash menu to match current dash:
	
	DKLineDash* dash = [stroke dash];
	
	if ( dash == nil )
		[mStrokeDashPopUpButton selectItemWithTag:-1];	// None
	else
	{
		int i = [mStrokeDashPopUpButton indexOfItemWithRepresentedObject:dash];
		
		if( i != -1 )
			[mStrokeDashPopUpButton selectItemAtIndex:i];
		else
			[mStrokeDashPopUpButton selectItemWithTag:-3];	// Other...
	}
	
	// set shadow controls (TO DO)
	
	
	
	// set cap/join selector (segmented control)
	
	[mStrokeLineCapSelector setSelectedSegment:[stroke lineCapStyle]];
	[mStrokeLineJoinSelector setSelectedSegment:[stroke lineJoinStyle]];
	
	// show/hide auxiliary controls for subclasses
	
	if ([stroke isKindOfClass:[DKArrowStroke class]])
	{
		DKArrowStroke* as = (DKArrowStroke*)stroke;
		
		[mStrokeControlsTabView setSubviewsWithTag:kGCArrowStrokeParameterItemsTag hidden:NO];
		[mStrokeArrowStartPopUpButton selectItemWithTag:[as arrowHeadAtStart]];
		[mStrokeArrowEndPopUpButton selectItemWithTag:[as arrowHeadAtEnd]];
		[mStrokeArrowDimensionOptions selectItemWithTag:[as dimensioningLineOptions]];
		
		NSSize previewSize = [mStrokeArrowPreviewImageWell bounds].size;
		NSImage* preview = [as arrowSwatchImageWithSize:previewSize strokeWidth:MIN( 8.0, [as width])];
		[mStrokeArrowPreviewImageWell setImage:preview];
	}
	else if ([stroke isKindOfClass:[DKRoughStroke class]])
	{
		[mStrokeControlsTabView setSubviewsWithTag:kGCRoughStrokeParameterItemsTag hidden:NO];
		[mStrokeControlsTabView setSubviewsWithTag:kGCArrowStrokeParameterItemsTag hidden:YES];
		[mStrokeRoughnessSlider setFloatValue:[(DKRoughStroke*)stroke roughness]];
	}
	else
	{
		[mStrokeControlsTabView setSubviewsWithTag:kGCArrowStrokeParameterItemsTag hidden:YES];
		[mStrokeControlsTabView setSubviewsWithTag:kGCRoughStrokeParameterItemsTag hidden:YES];
	}
		
	if ([stroke isKindOfClass:[DKZigZagStroke class]])
	{
		DKZigZagStroke* zz = (DKZigZagStroke*)stroke;
		
		[mStrokeZZLength setFloatValue:[zz wavelength]];
		[mStrokeZZAmp setFloatValue:[zz amplitude]];
		[mStrokeZZSpread setFloatValue:[zz spread]];
		[mStrokeControlsTabView setSubviewsWithTag:kGCZigZagParameterItemsTag hidden:NO];
	}
	else
	{
		[mStrokeControlsTabView setSubviewsWithTag:kGCZigZagParameterItemsTag hidden:YES];
	}
}


- (void)				updateSettingsForFill:(DKFill*) fill
{
	// which tab of the fill type view to display
	
	int tab = kGCInspectorFillTypeSolid;
	
	if([fill gradient] != nil )
		tab = kGCInspectorFillTypeGradient;
	
	NSShadow* fs = [fill shadow];
			
	[mFillShadowCheckbox setIntValue:fs != nil];
	[mFillColourWell setColor:[fill colour]];
	[mFillControlsTabView setSubviewsWithTag:kGCShadowParameterItemsTag enabled:fs != nil];
	
	if ( fs != nil )
	{
		[mShadowColourWell setColor:[fs shadowColor]];
		[mShadowBlurRadiusSlider setFloatValue:[fs shadowBlurRadius]];
		[mShadowDistanceSlider setFloatValue:[fs distance]];
		[mShadowAngleSlider setFloatValue:[fs shadowAngleInDegrees]];
	}
	
	DKGradient* gradient = [fill gradient];
	
	if( !mIsChangingGradient)
		[mFillGradientControlBar setGradient:gradient];
	[mFillGradientRemoveButton setEnabled:(gradient != nil)];
	[mFillGradientAddButton setEnabled:(gradient == nil)];
	
	float angle = [gradient angleInDegrees];
	
	[mFillGradientAngleSlider setFloatValue:angle];
	[mFillGradientAngleTextField setFloatValue:angle];
	[mFillGradientAngleLittleArrows setFloatValue:angle];
	
	[mFillGradientRelativeToObject setIntValue:[fill tracksObjectAngle]];
	
	if([fill isKindOfClass:[DKZigZagFill class]])
	{
		DKZigZagFill* zz = (DKZigZagFill*)fill;
		
		[mFillZZLength setFloatValue:[zz wavelength]];
		[mFillZZAmp setFloatValue:[zz amplitude]];
		[mFillZZSpread setFloatValue:[zz spread]];
		[mFillControlsTabView setSubviewsWithTag:kGCZigZagParameterItemsTag hidden:NO];
	}
	else
	{
		[mFillControlsTabView setSubviewsWithTag:kGCZigZagParameterItemsTag hidden:YES];
	}
}


- (void)				updateSettingsForHatch:(DKHatching*) hatch
{
	[mHatchColourWell setColor:[hatch colour]];
	[mHatchSpacingSlider setFloatValue:[hatch spacing]];
	[mHatchSpacingTextField setFloatValue:[hatch spacing]];
	[mHatchLineWidthSlider setFloatValue:[hatch width]];
	[mHatchLineWidthTextField setFloatValue:[hatch width]];
	[mHatchAngleSlider setFloatValue:[hatch angleInDegrees]];
	[mHatchAngleTextField setFloatValue:[hatch angleInDegrees]];
	[mHatchLeadInSlider setFloatValue:[hatch leadIn]];
	[mHatchLeadInTextField setFloatValue:[hatch leadIn]];
	[mHatchLineCapButton setSelectedSegment:[hatch lineCapStyle]];
	[mHatchRelativeAngleCheckbox setIntValue:[hatch angleIsRelativeToObject]];
	
	// set dash menu to match current dash:
	
	DKLineDash* dash = [hatch dash];
	
	if ( dash == nil )
		[mHatchDashPopUpButton selectItemWithTag:-1];
	else
	{
		int i = [mHatchDashPopUpButton indexOfItemWithRepresentedObject:dash];
		
		if( i != -1 )
			[mHatchDashPopUpButton selectItemAtIndex:i];
		else
			[mHatchDashPopUpButton selectItemWithTag:-3];
	}
}


- (void)				updateSettingsForImage:(DKImageAdornment*) ir
{
	[mImageWell setImage:[ir image]];
	[mImageOpacitySlider setFloatValue:[ir opacity]];
	[mImageScaleSlider setFloatValue:[ir scale]];
	[mImageAngleSlider setFloatValue:[ir angleInDegrees]];
	[mImageClipToPathCheckbox setIntValue:[ir clipsToPath]];
	[mImageIdentifierTextField setStringValue:[ir imageIdentifier]];
	[mImageFittingPopUpMenu selectItemWithTag:[ir fittingOption]];
	
	// if fitting option is fit to bounds, or fit proportionally, disable scale slider
	 
	if([ir fittingOption] == kGCClipToBounds)
		[mImageScaleSlider setEnabled:YES];
	else
		[mImageScaleSlider setEnabled:NO];
}


- (void)				updateSettingsForCoreImageEffect:(DKCIFilterRastGroup*) effg
{
	[mCIFilterClipToPathCheckbox setIntValue:[effg clipsToPath]];
	
	// check and select the menu item corresponding to the current filter
	
	[mCIFilterPopUpMenu selectItemAtIndex:[[mCIFilterPopUpMenu menu] indexOfItemWithRepresentedObject:[effg filter]]];
}


- (void)				updateSettingsForTextLabel:(DKTextAdornment*) tlr
{
	[mTextLabelTextField setStringValue:[tlr string]];
	[mTextIdentifierTextField setStringValue:[tlr identifier]];
	[mTextLayoutPopUpButton selectItemWithTag:[tlr layoutMode]];
	[mTextAlignmentPopUpButton selectItemWithTag:[tlr alignment]];
	[mTextWrapLinesCheckbox setIntValue:[tlr wrapsLines]];
	[mTextClipToPathCheckbox setIntValue:[tlr clipsToPath]];
	[mTextRelativeAngleCheckbox setIntValue:[tlr appliesObjectAngle]];
	[mTextAngleSlider setFloatValue:[tlr angleInDegrees]];
	[mTextLabelPlacementPopUpButton selectItemWithTag:[tlr verticalAlignment]];
	[mFlowedTextInsetSlider setFloatValue:[tlr flowedTextPathInset]];
	
	if ([tlr colour] != nil )
		[mTextColourWell setColor:[tlr colour]];
	else
		[mTextColourWell setColor:[NSColor blackColor]];
		
	// disable items not relevant to path text if that mode is set
	
	BOOL enable = ([tlr layoutMode] != kGCTextLayoutAlongPath && [tlr layoutMode] != kGCTextLayoutAlongReversedPath);
	
	[mTextClipToPathCheckbox setEnabled:enable];
	[mTextRelativeAngleCheckbox setEnabled:enable];
	[mFlowedTextInsetSlider setEnabled:enable];
	
	enable &= ([tlr layoutMode] != kGCTextLayoutFlowedInPath);
	
	[mTextAngleSlider setEnabled:enable];
	[mTextWrapLinesCheckbox setEnabled:enable];
	
	// synchronise the Font Panel to the renderer's settings and set its action to apply to it
	
	[[NSFontManager sharedFontManager] setAction:@selector(temporaryPrivateChangeFontAction:)];
	[[NSFontManager sharedFontManager] setSelectedFont:[tlr font] isMultiple:NO];
	[[NSFontManager sharedFontManager] setSelectedAttributes:[tlr textAttributes] isMultiple:NO];
}


- (void)				updateSettingsForPathDecorator:(DKPathDecorator*) pd
{
	[mPDIntervalSlider setFloatValue:[pd interval]];
	[mPDScaleSlider setFloatValue:[pd scale]];
	[mPDNormalToPathCheckbox setIntValue:[pd normalToPath]];
	[mPDLeaderSlider setFloatValue:[pd leaderDistance]];
	[mPDPreviewImage setImage:[pd image]];
	[mPDRampProportionSlider setFloatValue:[pd leadInAndOutLengthProportion]];
	
	// if really a fill pattern, deal with the alt offset control
	
	if([pd isKindOfClass:[DKFillPattern class]])
	{
		[mPDPatAltOffsetSlider setFloatValue:[(DKFillPattern*)pd patternAlternateOffset].height];
		[mPDAngleSlider setFloatValue:[(DKFillPattern*)pd angleInDegrees]];
		[mPDRelativeAngleCheckbox setIntValue:[(DKFillPattern*)pd angleIsRelativeToObject]];
		[mMotifAngleSlider setFloatValue:[(DKFillPattern*)pd motifAngleInDegrees]];
		[mMotifRelativeAngleCheckbox setIntValue:[(DKFillPattern*)pd motifAngleIsRelativeToPattern]];
		
		[mPDControlsTabView setSubviewsWithTag:kGCPathDecoratorParameterItemsTag hidden:YES];  
		[mPDControlsTabView setSubviewsWithTag:kGCPatternFillParameterItemsTag hidden:NO];  
	}
	else
	{
		[mPDControlsTabView setSubviewsWithTag:kGCPathDecoratorParameterItemsTag hidden:NO];  
		[mPDControlsTabView setSubviewsWithTag:kGCPatternFillParameterItemsTag hidden:YES];  
	}
}


- (void)				updateSettingsForBlendEffect:(DKQuartzBlendRastGroup*) brg
{
	[mBlendModePopUpButton selectItemWithTag:[brg blendMode]];
	[mBlendGroupAlphaSlider setFloatValue:[brg alpha]];
	[mBlendGroupImagePreview setImage:[brg maskImage]];
}


#pragma mark -
- (void)				populatePopUpButtonWithLibraryStyles:(NSPopUpButton*) button
{
	[button setMenu:[[DKStyleRegistry sharedStyleRegistry] createItemMenuWithItemCallback:self isPopUpMenu:YES]];
	[button setTitle:@"Style Library"];
}


- (void)				populateMenuWithDashes:(NSMenu*) menu
{
	NSArray*		dashes = [DKLineDash registeredDashes];
	NSEnumerator*	iter = [dashes objectEnumerator];
	DKLineDash*		dash;
	NSMenuItem*		item;
	int				k = 1;
	
	while( (dash = [iter nextObject]) != nil)
	{
		item = [menu insertItemWithTitle:@"" action:NULL keyEquivalent:@"" atIndex:k++];
		
		[item setEnabled:YES];
		//[item setTarget:self];
		[item setRepresentedObject:dash];
		[item setImage:[dash standardDashSwatchImage]];
	}
}


- (void)				populateMenuWithCoreImageFilters:(NSMenu*) menu
{
	//NSArray*		categories = [NSArray arrayWithObjects:kCICategoryDistortionEffect, kCICategoryStylize, kCICategoryBlur, kCICategorySharpen, nil];
	NSEnumerator*	iter = [[CIFilter filterNamesInCategory:kCICategoryStillImage] objectEnumerator];
	NSString*		filter;
	NSMenuItem*		item;
	
	[menu removeAllItems];
	
	while( (filter = [iter nextObject]) != nil)
	{
		item = [menu addItemWithTitle:[CIFilter localizedNameForFilterName:filter] action:NULL keyEquivalent:@""];
		[item setRepresentedObject:filter];
	}
	
}


#pragma mark -
- (void)				openDashEditor
{
	mSavedDash = [[(id)mSelectedRendererRef dash] retain];	// in case the editor is doing live preview
	
	DKLineDash* dash = [[(id)mSelectedRendererRef dash] copy];
	[mDashEditController setDash:dash];
	[dash release];
	
	// as long as the current renderer supports these methods, the dash editor will work:
	
	[mDashEditController setLineWidth:[(id)mSelectedRendererRef width]];
	[mDashEditController setLineCapStyle:[(id)mSelectedRendererRef lineCapStyle]];
	[mDashEditController setLineJoinStyle:[(id)mSelectedRendererRef lineJoinStyle]];
	[mDashEditController setLineColour:[(id)mSelectedRendererRef colour]];
	
	[mDashEditController openDashEditorInParentWindow:[self window] modalDelegate:self];
}


#pragma mark -
- (IBAction)			strokeColourAction:(id) sender
{
	[(DKStroke*)mSelectedRendererRef setColour:[sender color]]; 
}


- (IBAction)			strokeWidthAction:(id) sender
{
	[(DKStroke*)mSelectedRendererRef setWidth:[sender floatValue]]; 
}


- (IBAction)			strokeShadowCheckboxAction:(id) sender
{
	[(DKStroke*) mSelectedRendererRef setShadow:[sender intValue]? [DKStyle defaultShadow] : nil]; 
}


- (IBAction)			strokeDashMenuAction:(id) sender
{
	int tag = [[sender selectedItem] tag];
	
	if ( tag == -1 )
		[(DKStroke*) mSelectedRendererRef setDash:nil];
	else if ( tag == -2 )
		[(DKStroke*) mSelectedRendererRef setAutoDash];
	else if ( tag == -3 )
	{
		// "Other..." item
		[self openDashEditor];
	}
	else
	{
		// menu's attributed object is the dash itself
		
		DKLineDash*		dash = [[sender selectedItem] representedObject];
		[(DKStroke*) mSelectedRendererRef setDash:dash];
	}
}


- (IBAction)			strokePathScaleAction:(id) sender
{
	[(DKStroke*) mSelectedRendererRef setPathScaleFactor:[sender floatValue]]; 
}


- (IBAction)			strokeArrowStartMenuAction:(id) sender
{
	DKArrowHeadKind kind = (DKArrowHeadKind)[[sender selectedItem] tag];
	[(DKArrowStroke*) mSelectedRendererRef setArrowHeadAtStart:kind];
}


- (IBAction)			strokeArrowEndMenuAction:(id) sender
{
	DKArrowHeadKind kind = (DKArrowHeadKind)[[sender selectedItem] tag];
	[(DKArrowStroke*) mSelectedRendererRef setArrowHeadAtEnd:kind];

}


- (IBAction)			strokeArrowShowDimensionAction:(id) sender
{
	[(DKArrowStroke*) mSelectedRendererRef setDimensioningLineOptions:[[sender selectedItem] tag]];
}


- (IBAction)			strokeTrimLengthAction:(id) sender
{
	[(DKStroke*)mSelectedRendererRef setTrimLength:[sender floatValue]];
}


- (IBAction)			strokeZigZagLengthAction:(id) sender
{
	[(DKZigZagStroke*)mSelectedRendererRef setWavelength:[sender floatValue]];
}


- (IBAction)			strokeZigZagAmplitudeAction:(id) sender
{
	[(DKZigZagStroke*)mSelectedRendererRef setAmplitude:[sender floatValue]];
}


- (IBAction)			strokeZigZagSpreadAction:(id) sender
{
	[(DKZigZagStroke*)mSelectedRendererRef setSpread:[sender floatValue]];
}


- (IBAction)			strokeLineJoinStyleAction:(id) sender
{
	[(id)mSelectedRendererRef setLineJoinStyle:[sender selectedSegment]];
}


- (IBAction)			strokeLineCapStyleAction:(id) sender
{
	[(id)mSelectedRendererRef setLineCapStyle:[sender selectedSegment]];
}


- (IBAction)			strokeRoughnessAction:(id) sender
{
	[(id)mSelectedRendererRef setRoughness:[sender floatValue]];
}


#pragma mark -
- (IBAction)			fillColourAction:(id) sender
{
	[(DKFill*)mSelectedRendererRef setColour:[sender color]];
}


- (IBAction)			fillShadowCheckboxAction:(id) sender;
{
	[(DKFill*) mSelectedRendererRef setShadow:[sender intValue]? [DKStyle defaultShadow] : nil]; 
}


- (IBAction)			fillGradientAction:(id) sender
{
//	LogEvent_(kInfoEvent, @"gradient change from %@", sender );
	
	mIsChangingGradient = YES;
	
	// copy needed to force KVO to flag the change of gradient in the fill
	
	DKGradient* grad = [[sender gradient] copy];
	
	[(DKFill*) mSelectedRendererRef setGradient:grad];

	[grad release];
	mIsChangingGradient = NO;
}


- (IBAction)			fillRemoveGradientAction:(id) sender
{
#pragma unused (sender)
//	LogEvent_(kInfoEvent, @"removing gradient from fill");
	
	[(DKFill*)mSelectedRendererRef setGradient:nil];
}


- (IBAction)			fillAddGradientAction:(id) sender
{
#pragma unused (sender)
	//[(DKFill*) mSelectedRendererRef setColour:[NSColor clearColor]];
	
	[mFillGradientControlBar setGradient:[DKGradient defaultGradient]];
	[self fillGradientAction:mFillGradientControlBar];
	//[(DKFill*) mSelectedRendererRef setGradient:[mFillGradientControlBar gradient]];
}


- (IBAction)			fillGradientAngleAction:(id) sender
{
	DKGradient* gradient = [(DKFill*)mSelectedRendererRef gradient];
	[gradient setAngleInDegrees:[sender floatValue]];
}


- (IBAction)			fillGradientRelativeToObjectAction:(id) sender
{
	[(DKFill*)mSelectedRendererRef setTracksObjectAngle:[sender intValue]];
}


- (IBAction)			fillPatternPasteImageAction:(id) sender
{
#pragma unused (sender)
	NSPasteboard* pb = [NSPasteboard generalPasteboard];
	
	if([NSImage canInitWithPasteboard:pb])
	{
		NSImage* image = [[NSImage alloc] initWithPasteboard:pb];
		[(DKFill*) mSelectedRendererRef setColour:[NSColor colorWithPatternImage:image]];
		[mFillPatternImagePreview setImage:image];
		[image release];
			
		LogEvent_(kInfoEvent, @"color space name: %@", [[(DKFill*)mSelectedRendererRef colour] colorSpaceName]);
	}
}


- (IBAction)			fillZigZagLengthAction:(id) sender
{
	[(DKZigZagFill*) mSelectedRendererRef setWavelength:[sender floatValue]];
}


- (IBAction)			fillZigZagAmplitudeAction:(id) sender
{
	[(DKZigZagFill*) mSelectedRendererRef setAmplitude:[sender floatValue]];
}


- (IBAction)			fillZigZagSpreadAction:(id) sender
{
	[(DKZigZagFill*) mSelectedRendererRef setSpread:[sender floatValue]];
}


#pragma mark -
- (IBAction)			scriptButtonAction:(id) sender
{
#pragma unused (sender)
	// open the script editing dialog
	
	[mScriptEditController runAsSheetInParentWindow:[self window] modalDelegate:self];
}


- (IBAction)			libraryMenuAction:(id) sender
{
	int tag = [sender tag];//[[sender selectedItem] tag];
	
	if( tag == -1 )
	{
		// add to library using the name in the field
		
		[DKStyleRegistry registerStyle:[self style]];
		
		// update the library menu
		
		//[self populateMenuWithLibraryStyles:[mStyleLibraryPopUpButton menu]];
		[self updateUIForStyle];
	}
	else if ( tag == -4 )
	{
		// remove from library, if indeed the style really is part of it (more likely a copy, so this won't do anything)
		
		[DKStyleRegistry unregisterStyle:[self style]];
		[self populatePopUpButtonWithLibraryStyles:mStyleLibraryPopUpButton];
		[self updateUIForStyle];
	}
	else if ( tag == - 2 )
	{
		// save library
	}
	else if ( tag == - 3 )
	{
		// load library
	}
}


- (IBAction)			libraryItemAction:(id) sender
{
//	LogEvent_(kInfoEvent, @"library style = %@", [sender representedObject]);
	
	// set the style for the objects in the selection to the menu item style
	
	NSArray* selection = [self selectedObjectForCurrentTarget];
	
	if ( selection )
	{
		// so that the item gets added to "recently used", request the style from the registry using this method:
		
		NSString* key = [[sender representedObject] uniqueKey];
		DKStyle* ss = [DKStyleRegistry styleForKeyAddingToRecentlyUsed:key];
		
		[selection makeObjectsPerformSelector:@selector(setStyle:) withObject:ss];
		[self redisplayContentForSelection:selection];
		
		[[[self currentDocument] undoManager] setActionName:NSLocalizedString(@"Apply Style", @"")];
	}
}


- (IBAction)			sharedStyleCheckboxAction:(id) sender
{
	if ( ![[self style] locked])
		[[self style] setStyleSharable:[sender intValue]];
}


- (IBAction)			styleNameAction:(id) sender
{
	if ( ![[self style] locked])
	{
		[[self style] setName:[sender stringValue]];
		
		// if the style is registered, update the library menu
		
		if ([[self style] isStyleRegistered])
			[self populatePopUpButtonWithLibraryStyles:mStyleLibraryPopUpButton];
			
		[[[self currentDocument] undoManager] setActionName:NSLocalizedString(@"Change Style Name", @"")];
	}
}


- (IBAction)			cloneStyleAction:(id) sender
{
#pragma unused (sender)
	// makes a copy (mutable) of the current style and applies it to the objects in the selection. This gives us a useful
	// starting point for making a new style
	
	DKStyle* clone = [[self style] mutableCopy];
	
	// give it a new name:
	// if it has text attributes, give it a name based on the font, otherwise, blank.
	
	[clone setName:nil];

	if([clone hasTextAttributes])
	{
		NSFont* font = [[clone textAttributes] objectForKey:NSFontAttributeName];
		
		if ( font != nil )
			[clone setName:[DKStyle styleNameForFont:font]];
	}
	
	// attach it to the selected objects and update
	
	NSArray* selection = [self selectedObjectForCurrentTarget];
	
	if ( selection )
	{
		[selection makeObjectsPerformSelector:@selector(setStyle:) withObject:clone];
		[self redisplayContentForSelection:selection];
	}
	
	[clone release];
	[[[self currentDocument] undoManager] setActionName:NSLocalizedString(@"Clone Style", @"")];
}


- (IBAction)			unlockStyleAction:(id) sender
{
	// unlocks a locked style for editing. If the style is registered, posts a stern warning
	
	if ([[self style] isStyleRegistered] && [sender intValue] == 0)
	{
		// warn user what could happen
		
		NSAlert* alert = [NSAlert alertWithMessageText:@"Caution: Registered Style"
							defaultButton:@"Cancel"
							alternateButton:@"Unlock Anyway"
							otherButton:nil
							informativeTextWithFormat:@"Editing a registered style can have unforseen consequences as such styles may become permanently changed. Are you sure you want to unlock the style '%@' for editing?",
							[[self style] name]];

		int result = [alert runModal];
		
		if ( result == NSAlertAlternateReturn )
			[[self style] setLocked:NO];
	}
	else
		[[self style] setLocked:[sender intValue]];
	
	[self updateUIForStyle];
	
	if ([[self style] isStyleRegistered] && [sender intValue] == 1)
		[self populatePopUpButtonWithLibraryStyles:mStyleLibraryPopUpButton];
		
	[[[self currentDocument] undoManager] setActionName:NSLocalizedString([[self style] locked]? @"Lock Style" : @"Unlock Style", @"")];
}


#pragma mark -
- (IBAction)			addRendererElementAction:(id) sender
{
	int tag = [[sender selectedItem] tag];

	// tag maps to the type of renderer to add
	
	DKRasterizer*	 rend;
	
	switch( tag )
	{
		case kGCAddStrokeRendererTag:
			rend = [[DKStroke alloc] init];
			break;
			
		case kGCAddZigZagStrokeRendererTag:
			rend = [[DKZigZagStroke alloc] init];
			break;
			
		case kGCAddFillRendererTag:
			rend = [[DKFill alloc] init];
			break;
			
		case kGCAddZigZagFillRendererTag:
			rend = [[DKZigZagFill alloc] init];
			break;
			
		case kGCAddGroupRendererTag:
			rend = [[DKRastGroup alloc] init];
			break;
			
		case kGCAddCoreEffectRendererTag:
			rend = [[DKCIFilterRastGroup alloc] init];
			break;
			
		case kGCAddImageRendererTag:
			rend = [[DKImageAdornment alloc] init];
			break;
			
		case kGCAddHatchRendererTag:
			rend = [[DKHatching alloc] init];
			break;
			
		case kGCAddLabelRendererTag:
			rend = [[DKTextAdornment alloc] init];
			break;
			
		case kGCAddArrowStrokeRendererTag:
			rend = [[DKArrowStroke alloc] init];
			[(DKArrowStroke*)rend setWidth:MAX( 1.0, [[self style] maxStrokeWidth])];
			break;
			
		case kGCAddPathDecoratorRendererTag:
			rend = [[DKPathDecorator alloc] init];
			break;
			
		case kGCAddPatternFillRendererTag:
			rend = [[DKFillPattern alloc] init];
			break;
			
		case kGCAddBlendEffectRendererTag:
			rend = [[DKQuartzBlendRastGroup alloc] init];
			break;
			
		case kGCAddRoughStrokeRendererTag:
			rend = [[DKRoughStroke alloc] init];
			break;
			
		default:
			return;	// TO DO
	}
	
	NSAssert( rend != nil, @"renderer was nil - can't continue");
	
	[self addAndSelectNewRenderer:rend];
	[rend release];
		
	[[[self currentDocument] undoManager] setActionName:NSLocalizedString(@"Add Style Component", @"")];
}


- (IBAction)			removeRendererElementAction:(id) sender
{
#pragma unused (sender)
	DKRastGroup*	parent;
	id				sel = [mOutlineView itemAtRow:[mOutlineView selectedRow]];
	
	if ( sel == nil || sel == [self style])
		return;
		
	parent = (DKRastGroup*)[sel container];
		
//	LogEvent_(kInfoEvent, @"deleting renderer %@ from parent %@", sel, parent );
	
	mSelectedRendererRef = nil;
	
	[[self style] notifyClientsBeforeChange];
	[parent removeRenderer:sel];
	[[self style] notifyClientsAfterChange];

	[mOutlineView reloadData];
	
	int row = [mOutlineView rowForItem:parent];
	
	if ( row != NSNotFound )
		[mOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];

	[[[self currentDocument] undoManager] setActionName:NSLocalizedString(@"Delete Style Component", @"")];
}


- (IBAction)			duplicateRendererElementAction:(id) sender
{
#pragma unused (sender)
	// duplicates the selected renderer within its current parent group. If the root style is selected,
	// does nothing
	id				sel = [mOutlineView itemAtRow:[mOutlineView selectedRow]];
	
	if ( sel == nil || sel == [self style])
	{
		NSBeep();
		return;
	}
	
	id newItem = [sel copy];
	
	[self addAndSelectNewRenderer:newItem];
	[newItem release];
	[[[self currentDocument] undoManager] setActionName:NSLocalizedString(@"Duplicate Style Component", @"")];
}


- (IBAction)			copyRendererElementAction:(id) sender
{
#pragma unused (sender)
	// ensure the copy is of a component and not the whole thing
	
	id	sel = [mOutlineView itemAtRow:[mOutlineView selectedRow]];
	
	if ( sel == nil || sel == [self style])
	{
		NSBeep();
		return;
	}	
	
	[sel copyToPasteboard:[NSPasteboard generalPasteboard]];
}


- (IBAction)			pasteRendererElementAction:(id) sender
{
#pragma unused (sender)
	DKRasterizer* rend = [DKRasterizer rasterizerFromPasteboard:[NSPasteboard generalPasteboard]];
	
	if( rend != nil )
	{
		[self addAndSelectNewRenderer:rend];
		[[[self currentDocument] undoManager] setActionName:NSLocalizedString(@"Paste Style Component", @"")];
	}
	else
		NSBeep();
}


 - (IBAction)			removeTextAttributesAction:(id) sender
{
	#pragma unused(sender)
	
	if(![[self style] locked] && [[self style] hasTextAttributes])
	{
		[[self style] removeTextAttributes];
		[[[self currentDocument] undoManager] setActionName:NSLocalizedString(@"Remove Text Attributes", @"")];
	}
}



#pragma mark -
- (IBAction)			imageFileButtonAction:(id) sender
{
#pragma unused (sender)
	NSOpenPanel*	op = [NSOpenPanel openPanel];
	
	[op setAllowsMultipleSelection:NO];
	[op setCanChooseDirectories:NO];
	
	int result = [op runModalForTypes:[NSImage imageFileTypes]];
	
	if( result == NSOKButton )
	{
		NSImage* image = [[NSImage alloc] initByReferencingFile:[op filename]];
		
		if ([mSelectedRendererRef respondsToSelector:@selector(setImage:)])
			[(DKImageAdornment*)mSelectedRendererRef setImage:image];
		else if ([mSelectedRendererRef isKindOfClass:[DKFill class]])
		{
			[(DKFill*)mSelectedRendererRef setColour:[NSColor colorWithPatternImage:image]];
			[mFillPatternImagePreview setImage:image];
		}
		
		[image release];
	
	}
}


- (IBAction)			imageWellAction:(id) sender
{
#pragma unused (sender)

}


- (IBAction)			imageIdentifierAction:(id) sender
{
	[(DKImageAdornment*)mSelectedRendererRef setImageIdentifier:[sender stringValue]];
}


- (IBAction)			imageOpacityAction:(id) sender
{
	[(DKImageAdornment*)mSelectedRendererRef setOpacity:[sender floatValue]];
}


- (IBAction)			imageScaleAction:(id) sender
{
	[(DKImageAdornment*)mSelectedRendererRef setScale:[sender floatValue]];
}


- (IBAction)			imageAngleAction:(id) sender
{
	[(DKImageAdornment*)mSelectedRendererRef setAngleInDegrees:[sender floatValue]];
}


- (IBAction)			imageFittingMenuAction:(id) sender
{
	int option = [[sender selectedItem] tag];
	[(DKImageAdornment*)mSelectedRendererRef setFittingOption:option];
}


- (IBAction)			imageClipToPathAction:(id) sender
{
	[(DKImageAdornment*)mSelectedRendererRef setClipsToPath:[sender intValue]];
}


#pragma mark -
- (IBAction)			hatchColourWellAction:(id) sender
{
	[(DKHatching*) mSelectedRendererRef setColour:[sender color]];
}


- (IBAction)			hatchSpacingAction:(id) sender
{
	[(DKHatching*) mSelectedRendererRef setSpacing:[sender floatValue]];
}


- (IBAction)			hatchLineWidthAction:(id) sender
{
	[(DKHatching*) mSelectedRendererRef setWidth:[sender floatValue]];
}


- (IBAction)			hatchAngleAction:(id) sender
{
	[(DKHatching*) mSelectedRendererRef setAngleInDegrees:[sender floatValue]];
}


- (IBAction)			hatchRelativeAngleAction:(id) sender
{
	[(DKHatching*) mSelectedRendererRef setAngleIsRelativeToObject:[sender intValue]];
}


- (IBAction)			hatchDashMenuAction:(id) sender
{
	int tag = [[sender selectedItem] tag];
	
	if ( tag == -1 )
		[(DKHatching*) mSelectedRendererRef setDash:nil];
	else if ( tag == -2 )
		[(DKHatching*) mSelectedRendererRef setAutoDash];
	else if ( tag == -3 )
	{
		// "Other..." item
		
		[self openDashEditor];
	}
	else
	{
		// menu's attributed object is the dash itself
		
		DKLineDash*		dash = [[sender selectedItem] representedObject];
		[(DKHatching*) mSelectedRendererRef setDash:dash];
	}
}


- (IBAction)			hatchLeadInAction:(id) sender
{
	[(DKHatching*) mSelectedRendererRef setLeadIn:[sender floatValue]];
}


#pragma mark -
- (IBAction)			filterMenuAction:(id) sender
{
	LogEvent_(kInfoEvent, @"filter menu, choice = %@", [[sender selectedItem] title]);
	
	[(DKCIFilterRastGroup*)mSelectedRendererRef setFilter:[[sender selectedItem] representedObject]];
}


- (IBAction)			filterClipToPathAction:(id) sender
{
	[(DKCIFilterRastGroup*)mSelectedRendererRef setClipsToPath:[sender intValue]];
}


#pragma mark -
- (IBAction)			textLabelAction:(id) sender
{
	NSString* ss = [sender stringValue];
	[(DKTextAdornment*) mSelectedRendererRef setLabel:ss];
}


- (IBAction)			textIdentifierAction:(id) sender
{
	[(DKTextAdornment*) mSelectedRendererRef setIdentifier:[sender stringValue]];
}


- (IBAction)			textLayoutAction:(id) sender
{
	[(DKTextAdornment*) mSelectedRendererRef setLayoutMode:[[sender selectedItem] tag]];
}


- (IBAction)			textAlignmentMenuAction:(id) sender
{
	[(DKTextAdornment*) mSelectedRendererRef setAlignment:[[sender selectedItem] tag]];
}


- (IBAction)			textPlacementMenuAction:(id) sender
{
	[(DKTextAdornment*) mSelectedRendererRef  setVerticalAlignment:[[sender selectedItem] tag]];
}


- (IBAction)			textWrapLinesAction:(id) sender
{
	[(DKTextAdornment*) mSelectedRendererRef setWrapsLines:[sender intValue]];
}


- (IBAction)			textClipToPathAction:(id) sender
{
	[(DKTextAdornment*) mSelectedRendererRef setClipsToPath:[sender intValue]];
}


- (IBAction)			textRelativeAngleAction:(id) sender
{
	[(DKTextAdornment*) mSelectedRendererRef setAppliesObjectAngle:[sender intValue]];
}


- (IBAction)			textAngleAction:(id) sender
{
	[(DKTextAdornment*) mSelectedRendererRef setAngleInDegrees:[sender floatValue]];
}


- (IBAction)			textFontButtonAction:(id) sender
{
	// set the font panel's action to our private redirection action when the Font button is clicked. This gets
	// restored to the standard action whenever the focus is removed from this pane.
	
	[[NSFontManager sharedFontManager] orderFrontFontPanel:sender];
}


- (IBAction)			textColourAction:(id) sender
{
	[(DKTextAdornment*) mSelectedRendererRef setColour:[sender color]];
}


- (IBAction)			textChangeFontAction:(id) sender
{
	if ([mSelectedRendererRef isKindOfClass:[DKTextAdornment class]])
	{
		LogEvent_(kInfoEvent, @"got font change");
		
		NSFont*		newFont = [sender convertFont:[(DKTextAdornment*) mSelectedRendererRef font]];
		[(DKTextAdornment*) mSelectedRendererRef setFont:newFont];
	}
}


- (IBAction)			textFlowInsetAction:(id) sender
{
	[(DKTextAdornment*) mSelectedRendererRef setFlowedTextPathInset:[sender floatValue]];
}

#pragma mark -
- (IBAction)			pathDecoratorIntervalAction:(id) sender
{
	[(DKPathDecorator*) mSelectedRendererRef setInterval:[sender floatValue]];
}


- (IBAction)			pathDecoratorScaleAction:(id) sender
{
	[(DKPathDecorator*) mSelectedRendererRef setScale:[sender floatValue]];
}


- (IBAction)			pathDecoratorPasteObjectAction:(id) sender
{
#pragma unused (sender)
	// allow PDF data to be pasted as an image
	
	NSPasteboard* pb = [NSPasteboard generalPasteboard];
	
	if([NSImage canInitWithPasteboard:pb])
	{
		NSImage* image = [[NSImage alloc] initWithPasteboard:pb];
		[(DKPathDecorator*) mSelectedRendererRef setImage:image];
		[image release];
	}
}


- (IBAction)			pathDecoratorPathNormalAction:(id) sender
{
	[(DKPathDecorator*) mSelectedRendererRef setNormalToPath:[sender intValue]];
}


- (IBAction)			pathDecoratorLeaderDistanceAction:(id) sender
{
	[(DKPathDecorator*) mSelectedRendererRef setLeaderDistance:[sender floatValue]];
}


- (IBAction)			pathDecoratorAltPatternAction:(id) sender
{
	[(DKFillPattern*) mSelectedRendererRef setPatternAlternateOffset:NSMakeSize(0, [sender floatValue])];
}


- (IBAction)			pathDecoratorRampProportionAction:(id) sender;
{
	[(DKPathDecorator*) mSelectedRendererRef setLeadInAndOutLengthProportion:[sender floatValue]];
}


- (IBAction)			pathDecoratorAngleAction:(id) sender
{
	[(DKFillPattern*) mSelectedRendererRef setAngleInDegrees:[sender floatValue]];
}


- (IBAction)			pathDecoratorRelativeAngleAction:(id) sender
{
	[(DKFillPattern*) mSelectedRendererRef setAngleIsRelativeToObject:[sender intValue]];
}


- (IBAction)			pathDecoratorMotifAngleAction:(id) sender
{
	[(DKFillPattern*) mSelectedRendererRef setMotifAngleInDegrees:[sender floatValue]];
}


- (IBAction)			pathDecoratorMotifRelativeAngleAction:(id) sender
{
	[(DKFillPattern*) mSelectedRendererRef setMotifAngleIsRelativeToPattern:[sender intValue]];
}




#pragma mark -
- (IBAction)			blendModeAction:(id) sender
{
	int tag = [[sender selectedItem] tag];
	[(DKQuartzBlendRastGroup*) mSelectedRendererRef setBlendMode:(CGBlendMode) tag];
}


- (IBAction)			blendGroupAlphaAction:(id) sender;
{
	[(DKQuartzBlendRastGroup*) mSelectedRendererRef setAlpha:[sender floatValue]];
}


- (IBAction)			blendGroupImagePasteAction:(id) sender;
{
#pragma unused (sender)
	NSPasteboard* pb = [NSPasteboard generalPasteboard];
	
	if([NSImage canInitWithPasteboard:pb])
	{
		NSImage* image = [[NSImage alloc] initWithPasteboard:pb];
		[(DKQuartzBlendRastGroup*) mSelectedRendererRef setMaskImage:image];
		[image release];
	}
}

#pragma mark -


// shadow actions make copies because shadow properties are not directly under KVO, but
// -setShadow: is, so the actions are still undoable.

- (IBAction)			shadowAngleAction:(id) sender
{
	NSShadow* shad = [[(DKFill*)mSelectedRendererRef shadow] copy];
	float distance = [shad distance];
	[shad setShadowAngleInDegrees:[sender floatValue] distance:distance];
	[(DKFill*)mSelectedRendererRef setShadow:shad];
	[shad release];
}


- (IBAction)			shadowDistanceAction:(id) sender
{
	NSShadow* shad = [[(DKFill*)mSelectedRendererRef shadow] copy];
	float angle = [shad shadowAngle];
	[shad setShadowAngle:angle distance:[sender floatValue]];
	[(DKFill*)mSelectedRendererRef setShadow:shad];
	[shad release];
}


- (IBAction)			shadowBlurRadiusAction:(id) sender
{
	NSShadow* shad = [[(DKFill*)mSelectedRendererRef shadow] copy];
	[shad setShadowBlurRadius:[sender floatValue]];
	[(DKFill*)mSelectedRendererRef setShadow:shad];
	[shad release];
}


- (IBAction)			shadowColourAction:(id) sender
{
	NSShadow* shad = [[(DKFill*)mSelectedRendererRef shadow] copy];
	[shad setShadowColor:[sender color]];
	[(DKFill*)mSelectedRendererRef setShadow:shad];
	[shad release];
}



#pragma mark -
#pragma mark modal sheet callback - called by selector, otherwise private

- (void)				sheetDidEnd:(NSWindow*) sheet returnCode:(int) returnCode contextInfo:(void*) contextInfo
{
#pragma unused (sheet)
//	LogEvent_(kReactiveEvent, @"sheet ended, return code = %d", returnCode);
	
	if((id)contextInfo == mDashEditController )
	{
		if( returnCode == NSOKButton )
			[(id)mSelectedRendererRef setDash:[mDashEditController dash]];
		else
			[(id)mSelectedRendererRef setDash:mSavedDash];
		
		[mSavedDash release];
		mSavedDash = nil;
	}
	else if ((id)contextInfo == mScriptEditController )
	{
		if ( returnCode == NSOKButton )
		{
			NSString* script = [[mScriptEditController primaryItem] string];
			
			if ( script != nil && ![script isEqualToString:@""])
			{
				LogEvent_(kReactiveEvent, @"about to attempt to build new style from script: %@", script);
				
				DKStyle* style = [DKStyle styleWithScript:script];
				
				if ( style != nil )
				{
					LogEvent_(kReactiveEvent, @"style constructed OK, inserting it into inspector...");
					
					// success, so set it as the current style in the inspector
					
					[self setStyle:style];
					
					// and use it for the current object(s)
					
					NSArray* selection = [self selectedObjectForCurrentTarget];
		
					if ( selection )
					{
						[selection makeObjectsPerformSelector:@selector(setStyle:) withObject:style];
						[[[self currentDocument] undoManager] setActionName:NSLocalizedString(@"New Style", @"")];
					}
				}
			}
			else
				NSBeep();	// TO DO: add error about bad script or whatever
		}
	}
}


#pragma mark -
#pragma mark As a DKDrawkitInspectorBase
- (void)				redisplayContentForSelection:(NSArray*) selection
{
	// inherited from inspector base - is passed current selection array whenever a change in selection state occurs
//	LogEvent_(kInfoEvent, @"selection: %@", selection );
	
	if ( selection != nil )
	{
		if([selection count] > 1 )
		{
			// multiple selection
			
			[self setStyle:nil];
			[mTabView selectTabViewItemAtIndex:kGCInspectorMultipleItemsTab];
		}
		else if ([selection count] == 1 )
		{
			// single selection
			
			[self setStyle:[(DKDrawableObject*)[selection objectAtIndex:0] style]];
			[mTabView selectTabViewItemAtIndex:kGCInspectorStylePreviewTab];
			[mStyleClientCountText setIntValue:[[self style] countOfClients]];
		}
		else
		{
			// no selection
			
			[self setStyle:nil];
			[mTabView selectTabViewItemAtIndex:kGCInspectorNoItemsTab];
		}
	}
	else
	{
		[self setStyle:nil]; // no selection
		[mTabView selectTabViewItemAtIndex:kGCInspectorNoItemsTab];
	}
}


#pragma mark -
#pragma mark As an NSWindowController
- (void)				windowDidLoad
{
	[(NSPanel*)[self window] setFloatingPanel:YES];
	[(NSPanel*)[self window] setBecomesKeyOnlyIfNeeded:YES];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(styleAttached:) name:kDKDrawableStyleWillBeDetachedNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(styleRegistered:) name:kDKStyleRegistryDidFlagPossibleUIChange object:nil];
	
	//[mFillGradientWell setCell:[[GCGradientCell alloc] init]];
	//[mFillGradientWell setCanBecomeActiveWell:NO];
	[mFillGradientControlBar setCanBecomeActiveWell:NO];
	[mFillGradientControlBar setTarget:self];
	[mFillGradientControlBar setAction:@selector(fillGradientAction:)];
	
	[mOutlineView setDelegate:self];
	[mOutlineView registerForDraggedTypes:[NSArray arrayWithObject:kGCTableRowInternalDragPasteboardType]];
    [mOutlineView setDraggingSourceOperationMask:NSDragOperationEvery forLocal:YES];
	[mOutlineView setVerticalMotionCanBeginDrag:YES];
	
	[[mStyleLibraryPopUpButton menu] insertItemWithTitle:@"Style Library" action:NULL keyEquivalent:@"" atIndex:0];

	[self populatePopUpButtonWithLibraryStyles:mStyleLibraryPopUpButton];
	
	[self populateMenuWithDashes:[mHatchDashPopUpButton menu]];
	[self populateMenuWithDashes:[mStrokeDashPopUpButton menu]];
	[self populateMenuWithCoreImageFilters:[mCIFilterPopUpMenu menu]];
	
	[mAddRendererPopUpButton setFont:[NSFont fontWithName:@"Lucida Grande" size:10]];
	[[mAddRendererPopUpButton menu] setAutoenablesItems:NO];
	[[mAddRendererPopUpButton menu] uncheckAllItems];
	[[mAddRendererPopUpButton menu] disableItemsWithTag:-99];
	
	[mActionsPopUpButton setFont:[NSFont fontWithName:@"Lucida Grande" size:10]];
	[[mActionsPopUpButton menu] uncheckAllItems];
	
	mStyle = nil;
	[self updateUIForStyle];

	NSRect panelFrame = [[self window] frame];
	NSRect screenFrame = [[[NSScreen screens] objectAtIndex:0] visibleFrame];
	
//	LogEvent_(kInfoEvent, @"screen frame = %@", NSStringFromRect( screenFrame ));
	
	panelFrame.origin.x = NSMaxX( screenFrame ) - NSWidth( panelFrame ) - 20;
	[[self window] setFrameOrigin:panelFrame.origin];
}


#pragma mark -
#pragma mark As an NSObject
- (id)					init
{
	self = [super init];
	if (self != nil)
	{
		NSAssert(mStyle == nil, @"Expected init to zero");
		NSAssert(mSelectedRendererRef == nil, @"Expected init to zero");
		NSAssert(!mIsChangingGradient, @"Expected init to zero");
		NSAssert(mDragItem == nil, @"Expected init to zero");
		NSAssert(mSavedDash == nil, @"Expected init to zero");
	}
	return self;
}


#pragma mark -
#pragma mark As part of CategoryManagerMenuCallback Protocol
- (void)				menuItem:(NSMenuItem*) item wasAddedForObject:(id) object inCategory:(NSString*) category
{
#pragma unused (category)
	if( object == [DKStyleRegistry sharedStyleRegistry])
	{
		[item setTitle:NSLocalizedString(@"Style", @"")];
	}
	else
	{
		[item setTarget:self];
		[item setAction:@selector(libraryItemAction:)];
		[item setRepresentedObject:object];
		
		// fetch swatch at a large size and scale down to menu icon size - this gives a better impression of most styles
		// than trying to render the icon at 1:1 size using the style
		
		NSImage* swatch = [[object styleSwatchWithSize:NSMakeSize( 112, 112 ) type:kGCStyleSwatchAutomatic] copy];
		
		[swatch setScalesWhenResized:YES];
		[swatch setSize:NSMakeSize( 28, 28 )];
		[swatch lockFocus];
		[[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationLow];
		[item setImage:swatch];
		[swatch unlockFocus];
		[swatch release];
		
		if([object name] != nil )
			[item setTitle:[object name]];
	}
}


#pragma mark -
#pragma mark As a GCDashEditorDelegate delegate
- (void)				dashDidChange:(id) sender
{
	// called if live preview is set - set the target's dash to the sender's
	
	[(id)mSelectedRendererRef setDash:[sender dash]];
}


#pragma mark -
#pragma mark As part of NSOutlineViewDataSource Protocol
- (BOOL)			outlineView:(NSOutlineView*) olv acceptDrop:(id <NSDraggingInfo>)info item:(id)targetItem childIndex:(int) childIndex
{
#pragma unused (info)
	// the item being moved is already stored as mDragItem, so simply move it to the new place
	
	DKRastGroup* group;
	
	if ( targetItem == nil )
		group = [self style];
	else
		group = targetItem;
		
	int srcIndex, row;
	
	srcIndex = [[group renderList] indexOfObject:mDragItem];
	
	if ( srcIndex != NSNotFound )
	{
		// moving within the same group it already belongs to
		
		[[self style] notifyClientsBeforeChange];
		[group moveRendererAtIndex:srcIndex toIndex:childIndex];
		[[self style] notifyClientsAfterChange];

		[olv reloadData];
		
		row = [olv rowForItem:mDragItem];
	
		if ( row != NSNotFound )
		{
			[olv selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];	// workaround over-optimisation bug in o/v
			[olv selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
		}
		
		[[[self currentDocument] undoManager] setActionName:NSLocalizedString(@"Reorder Style Component", @"")];

		return YES;
	}
	else if ( group != [mDragItem container])
	{
		// moving to another group in the hierarchy
		
		[[self style] notifyClientsBeforeChange];
		[mDragItem retain];
		[[mDragItem container] removeRenderer:mDragItem];
		[group addRenderer:mDragItem];
		[group moveRendererAtIndex:[group countOfRenderList] - 1 toIndex:childIndex];
		[mDragItem release];
		[[self style] notifyClientsAfterChange];
	
		[olv reloadData];
		row = [olv rowForItem:mDragItem];
	
		if ( row != NSNotFound )
		{
			[olv selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO]; // workaround over-optimisation bug in o/v
			[olv selectRowIndexes:[NSIndexSet indexSetWithIndex:row] byExtendingSelection:NO];
		}

		[[[self currentDocument] undoManager] setActionName:NSLocalizedString(@"Move Style Component To Group", @"")];

		return YES;
	}
	else
		return NO;
}


- (id)				outlineView:(NSOutlineView*) outlineView child:(int) childIndex ofItem:(id) item
{
#pragma unused (outlineView)
    return (item == nil) ? [self style] : [item rendererAtIndex:childIndex];
}
 
 
- (BOOL)			outlineView:(NSOutlineView*) outlineView isItemExpandable:(id) item 
{
#pragma unused (outlineView)
    if([self style] == nil)
		return NO;
	else
		return (item == nil) ? YES : [item isKindOfClass:[DKRastGroup class]];
}


- (int)				outlineView:(NSOutlineView*) outlineView numberOfChildrenOfItem:(id) item
{
#pragma unused (outlineView)
    return (item == nil) ? 1 : [item countOfRenderList];
}


- (id)				outlineView:(NSOutlineView*) outlineView objectValueForTableColumn:(NSTableColumn*) tableColumn byItem:(id) item
{
#pragma unused (outlineView)
    if([[tableColumn identifier] isEqualToString:@"class"])
		return (item == nil) ? NSStringFromClass([[self style] class]) : NSStringFromClass([item class]);
	else if([[tableColumn identifier] isEqualToString:@"enabled"])
		return [item valueForKey:@"enabled"];
	else
		return nil;
}


- (void)			outlineView:(NSOutlineView*) outlineView setObjectValue:(id) object forTableColumn:(NSTableColumn*) tableColumn byItem:(id) item
{
#pragma unused (outlineView)
	if([[tableColumn identifier] isEqualToString:@"enabled"])
		[item setValue:object forKey:@"enabled"];
}


- (NSDragOperation)	outlineView:(NSOutlineView*) olv validateDrop:(id <NSDraggingInfo>)info proposedItem:(id)item proposedChildIndex:(int) childIndex
{
#pragma unused (info)
//	LogEvent_(kInfoEvent, @"proposing drop on %@, childIndex = %d", item, childIndex );

	if([item isKindOfClass:[DKRastGroup class]])
	{
		if ( childIndex == NSOutlineViewDropOnItemIndex )
			[olv setDropItem:item dropChildIndex:0];
		else
			[olv setDropItem:item dropChildIndex:childIndex];
		
		return NSDragOperationGeneric;    
	}
	else
		return NSDragOperationNone;
}


- (BOOL)			outlineView:(NSOutlineView*) oView writeItems:(NSArray*) rows toPasteboard:(NSPasteboard*) pboard
{
#pragma unused (oView)
//	LogEvent_(kInfoEvent, @"starting drag in outline view, array = %@", rows );
	
	mDragItem = [rows objectAtIndex:0];
	
	if ( mDragItem == [self style])
		return NO;
	
	// just write dummy data to the pboard - it's all internal so we just keep a reference to the item being moved
	
	[pboard declareTypes:[NSArray arrayWithObject:kGCTableRowInternalDragPasteboardType] owner:self];
    [pboard setData:[NSData data] forType:kGCTableRowInternalDragPasteboardType];
	
	return YES;
}


#pragma mark -
#pragma mark As an NSOutlineView delegate
- (void)			outlineViewSelectionDidChange:(NSNotification*) notification
{
#pragma unused (notification)
	// select the appropriate tab for the selected item and set up its contents
	
	int row = [mOutlineView selectedRow];
	
	if ( row != - 1 )
	{
		id item = [mOutlineView itemAtRow:row];
		
		if([[self style] locked])
			[self selectTabPaneForObject:[self style]];
		else
			[self selectTabPaneForObject:item];
	}
	else
		[self selectTabPaneForObject:nil];
}


- (NSString*)	outlineView:(NSOutlineView *)ov toolTipForCell:(NSCell*) cell rect:(NSRectPointer) rect
					tableColumn:(NSTableColumn*) tc item:(id) item mouseLocation:(NSPoint) mouseLocation
{
#pragma unused (ov, cell, rect, tc, mouseLocation)
	return [item styleScript];
}


- (void)		outlineView:(NSOutlineView*) outlineView willDisplayCell:(id) cell
					forTableColumn:(NSTableColumn*) tableColumn item:(id) item
{
#pragma unused (outlineView, item)
	if([[tableColumn identifier] isEqualToString:@"class"])
	{
		if ([[self style] locked])
			[cell setTextColor:[NSColor lightGrayColor]];
		else
			[cell setTextColor:[NSColor blackColor]];
	}
	else if([[tableColumn identifier] isEqualToString:@"enabled"])
	{
		[cell setEnabled:![[self style] locked]];
	}
}


#pragma mark -
#pragma mark As part of the NSMenuValidation protocol

- (BOOL)		validateMenuItem:(NSMenuItem*) item
{
	SEL		action = [item action];
	BOOL	enable = YES;
	id		sel = [mOutlineView itemAtRow:[mOutlineView selectedRow]];
	
	if ( action == @selector(copyRendererElementAction:))
	{
		// permitted for a valid selection even if style locked
		
		if ( sel == nil || sel == [self style])
			enable = NO;
	}
	else if ( action == @selector(duplicateRendererElementAction:) ||
		 action == @selector(removeRendererElementAction:))
	{
		// permitted if the selection is not root or nil, and style unlocked
		
		if ( sel == nil || sel == [self style] || [[self style] locked])
			enable = NO;
	}
	else if ( action == @selector(pasteRendererElementAction:))
	{
		// permitted if the pasteboard contains a renderer & style unlocked
		
		NSString* pbType = [[NSPasteboard generalPasteboard] availableTypeFromArray:[NSArray arrayWithObject:kDKRasterizerPasteboardType]];
		
		enable = (pbType != nil && ![[self style] locked]);
	}
	else if ( action == @selector( libraryItemAction: ))
	{
		[item setState:[item representedObject] == mStyle? NSOnState : NSOffState];
	}
	else if ( action == @selector( removeTextAttributesAction: ))
	{
		enable = ![[self style] locked] && [[self style] hasTextAttributes];
	}

	return enable;
}


@end


#pragma mark -
@implementation NSObject (ImageResources)

- (NSImage*)		imageNamed:(NSString*) name fromBundleForClass:(Class) class
{
	NSString *path = [[NSBundle bundleForClass:class] pathForImageResource:name];
	NSImage *image = [[NSImage alloc] initByReferencingFile:path];
	if (image == nil)
		LogEvent_(kWheneverEvent, @"ERROR: Unable to locate image resource '%@'", name);
	return [image autorelease];
}


@end


#pragma mark -
@implementation NSMenu (GCAdditions)

- (void)	disableItemsWithTag:(int) tag
{
	int i, m = [self numberOfItems];
	NSMenuItem*	item;
	
	for( i = 0; i < m; ++i )
	{
		item = [self itemAtIndex:i];
		
		if ([item tag] == tag )
			[item setEnabled:NO];
	}
}


- (void)			removeAllItems
{
	int i, m = [self numberOfItems];
	
	for( i = m - 1; i >= 0; --i )
		[self removeItemAtIndex:i];
}


- (void)			uncheckAllItems
{
	int i, m = [self numberOfItems];
	
	for( i = 0; i < m; ++i )
		[[self itemAtIndex:i] setState:NSOffState];
}


@end


#pragma mark -

@implementation NSView (TagEnablingAdditions)


- (void)	setSubviewsWithTag:(int) tag hidden:(BOOL) hide
{
	// recursively checks the tags of all subviews below this, and sets any that match <tag> to the hidden state <hide>
	
	if([self tag] == tag )
		[self setHidden:hide];
	else
	{
		NSEnumerator*	iter = [[self subviews] objectEnumerator];
		NSView*			sub;
	
		while(( sub = [iter nextObject]))
			[sub setSubviewsWithTag:tag hidden:hide];
	}
}


- (void)	setSubviewsWithTag:(int) tag enabled:(BOOL) enable
{
	// recursively checks the tags of all subviews below this, and sets any that match <tag> to the enabled state <enable>
	// provided that the object actually implements setEnabled: (i.e. it's a control)
	
	if([self tag] == tag && [self respondsToSelector:@selector(setEnabled:)])
		[(id)self setEnabled:enable];
	else
	{
		NSEnumerator*	iter = [[self subviews] objectEnumerator];
		NSView*			sub;
	
		while(( sub = [iter nextObject]))
			[sub setSubviewsWithTag:tag enabled:enable];
	}
}

@end
