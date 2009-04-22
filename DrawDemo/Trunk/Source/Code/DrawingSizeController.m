#import "DrawingSizeController.h"

#import <GCDrawKit/DKDrawing.h>
#import <GCDrawKit/DKGridLayer.h>
#import <GCDrawKit/LogEvent.h>


#pragma mark Static Vars
static float		sUnitFactors[]	= { 1.0, 12.0, 72.0, 2.8346456692913, 28.346456692913, 2834.6456692913, 28346.456692913, 1.0 };
static NSString*	sUnitNames[]		= { @"Pixels", @"Picas", @"Inches", @"Millimetres", @"Centimetres", @"Metres", @"Kilometres", nil };


@implementation DrawingSizeController
#pragma mark As a DrawingSizeController

- (NSArray*)	unitNames
{
	NSMutableArray* arr = [NSMutableArray array];
	NSString*		name;
	int				i = 0;
	
	while( 1 )
	{
		name = sUnitNames[i++];
		
		if ( name )
			[arr addObject:name];
		else
			break;
	}
	
	return arr;
}


- (void)		prepareDialogWithDrawing:(DKDrawing*) drawing
{
	// set up the dialog elements with the current drawing settings

	NSSize	size = [drawing drawingSize];
	
	[mWidthTextField setFloatValue:size.width / mUnitConversionFactor];
	[mHeightTextField setFloatValue:size.height / mUnitConversionFactor];
	
	[mTopMarginTextField setFloatValue:[drawing topMargin] / mUnitConversionFactor];
	[mLeftMarginTextField setFloatValue:[drawing leftMargin] / mUnitConversionFactor];
	[mRightMarginTextField setFloatValue:[drawing rightMargin] / mUnitConversionFactor];
	[mBottomMarginTextField setFloatValue:[drawing bottomMargin] / mUnitConversionFactor];
	
	[mConversionFactorTextField setFloatValue:mUnitConversionFactor];
	[mConversionFactorSpinControl setFloatValue:mUnitConversionFactor];
	[mPaperColourWell setColor:[drawing paperColour]];
	
	DKGridLayer* grid = [drawing gridLayer];
	
	if ( grid )
	{
		[mGridSpanTextField setFloatValue:[grid span] / mUnitConversionFactor];
		[mGridDivsTextField setIntValue:[grid divisions]];
		[mGridDivsSpinControl setIntValue:[grid divisions]];
		[mGridMajorsTextField setIntValue:[grid majors]];
		[mGridMajorsSpinControl setIntValue:[grid majors]];
		[mGridThemeColourWell setColor:[grid spanColour]];
		[mGridPrintCheckbox setIntValue:[grid shouldDrawToPrinter]];
		[mGridAbbrevUnitsText setStringValue:[drawing abbreviatedDrawingUnits]];
		[mGridRulerStepsTextField setIntValue:[grid rulerSteps]];
		[mGridRulerStepsSpinControl setIntValue:[grid rulerSteps]];
				
		[mGridPreviewCheckbox setIntValue:mLivePreview];
	}
}


- (void)		setupComboBoxWithCurrentUnits:(NSString*) units
{
#pragma unused (units)
	// populate the combobox with default units
	[mUnitsComboBox setHasVerticalScroller:NO];
	[mUnitsComboBox addItemsWithObjectValues:[self unitNames]];
	[mUnitsComboBox setNumberOfVisibleItems:[[self unitNames] count]];
}


#pragma mark -
- (void)		sheetDidEnd:(NSWindow*) sheet returnCode:(int) returnCode contextInfo:(void*) contextInfo
{
#pragma unused (sheet, contextInfo)
	DKGridLayer* grid = [mDrawing gridLayer];

	if ( returnCode == NSOKButton )
	{
		// apply the settings to the drawing.
		
		NSSize	dwgSize;
		float	t, l, b, r;
		
		dwgSize.width = [mWidthTextField floatValue] * mUnitConversionFactor;
		dwgSize.height = [mHeightTextField floatValue] * mUnitConversionFactor;
	
		t = [mTopMarginTextField floatValue] * mUnitConversionFactor;
		l = [mLeftMarginTextField floatValue] * mUnitConversionFactor;
		b = [mBottomMarginTextField floatValue] * mUnitConversionFactor;
		r = [mRightMarginTextField floatValue] * mUnitConversionFactor;
		
		[mDrawing setDrawingSize:dwgSize];
		[mDrawing setMarginsLeft:l top:t right:b bottom:r];
		[mDrawing setDrawingUnits:[mUnitsComboBox stringValue] unitToPointsConversionFactor:mUnitConversionFactor];
		[mDrawing setPaperColour:[mPaperColourWell color]];
		
		if ( grid )
		{
			float	span;
			int		divs, majs;
			
			span = [mGridSpanTextField floatValue] * mUnitConversionFactor;
			divs = [mGridDivsTextField intValue];
			majs = [mGridMajorsTextField intValue];
		
			[grid setSpan:span divisions:divs majors:majs];
			
			if([mTweakMarginsCheckbox intValue] == 1 )
				[grid tweakDrawingMargins];
				
			[grid setGridThemeColour:[mGridThemeColourWell color]];
		}
		
		[mDrawing setNeedsDisplay:YES];
	}
	else if ( returnCode == NSCancelButton )
	{
		// restore saved grid settings
		
		if ( grid )
		{
			[mDrawing setDrawingUnits:mSavedUnits unitToPointsConversionFactor:mSavedCF];
			[grid setSpan:mSavedSpan divisions:mSavedDivs majors:mSavedMajors];
			[grid setGridThemeColour:mSavedGridColour];
		}
		
		[mDrawing setPaperColour:mSavedPaperColour];
	}
	[mSavedUnits release];
	[mSavedGridColour release];
	[mSavedPaperColour release];
}


- (void)			beginDrawingSizeDialog:(NSWindow*) parent withDrawing:(DKDrawing*) drawing
{
	mDrawing = drawing;
	mUnitConversionFactor = mSavedCF = [drawing unitToPointsConversionFactor];
	
	// save off the current grid settings in case we cancel:
	
	mSavedPaperColour = [[drawing paperColour] retain];
	
	DKGridLayer* grid = [mDrawing gridLayer];
	
	if ( grid )
	{
		mSavedSpan = [grid span];
		mSavedDivs = [grid divisions];
		mSavedMajors = [grid majors];
		mSavedGridColour = [[grid spanColour] retain];
		mSavedUnits = [[drawing drawingUnits] retain];
	}
	
	[mUnitsComboBox setStringValue:[drawing drawingUnits]];
	[mConversionFactorLabelText setStringValue:[NSString stringWithFormat:@"1 %@ occupies", [drawing drawingUnits]]];
	[self prepareDialogWithDrawing:drawing];
	
	[NSApp	beginSheet:[self window]
			modalForWindow:parent
			modalDelegate:self
			didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
			contextInfo:@"drawing_size"];
}


#pragma mark -
- (IBAction)		cancelAction:(id)sender
{
#pragma unused (sender)
	[[self window] orderOut:self];
	[NSApp endSheet:[self window] returnCode:NSCancelButton];
}


- (IBAction)		gridDivsAction:(id)sender
{
	DKGridLayer* grid = [mDrawing gridLayer];
	
	if (mLivePreview && grid )
	{
		float	span;
		int		majs;
		
		span = [grid span];
		majs = [grid majors];
		
		[grid	setSpan:span
				unitToPointsConversionFactor:mUnitConversionFactor
				measurementSystem:[grid measurementSystem]
				drawingUnits:[mDrawing drawingUnits]
				divisions: [sender intValue]
				majors: majs
				rulerSteps:[mGridRulerStepsTextField intValue]];
	}
	
	if ( sender == mGridDivsSpinControl )
		[mGridDivsTextField setIntValue:[sender intValue]];
	else
		[mGridDivsSpinControl setIntValue:[sender intValue]];
}


- (IBAction)		gridMajorsAction:(id)sender
{
	DKGridLayer* grid = [mDrawing gridLayer];
	
	if (mLivePreview && grid )
	{
		float	span;
		int		divs;
		
		span = [grid span];
		divs = [grid divisions];
		
		[grid	setSpan:span
				unitToPointsConversionFactor:mUnitConversionFactor
				measurementSystem:[grid measurementSystem]
				drawingUnits:[mDrawing drawingUnits]
				divisions: divs
				majors: [sender intValue]
				rulerSteps:[mGridRulerStepsTextField intValue]];
	}
	if ( sender == mGridMajorsSpinControl )
		[mGridMajorsTextField setIntValue:[sender intValue]];
	else
		[mGridMajorsSpinControl setIntValue:[sender intValue]];
}


- (IBAction)		gridSpanAction:(id)sender
{
	DKGridLayer* grid = [mDrawing gridLayer];
	
	if (mLivePreview && grid )
	{
		int		divs, majs;
		
		divs = [grid divisions];
		majs = [grid majors];
		
		[grid	setSpan:[sender floatValue] * mUnitConversionFactor
				unitToPointsConversionFactor:mUnitConversionFactor
				measurementSystem:[grid measurementSystem]
				drawingUnits:[mDrawing drawingUnits]
				divisions: divs
				majors: majs
				rulerSteps:[mGridRulerStepsTextField intValue]];
	}
}


- (IBAction)		gridRulerStepsAction:(id) sender
{
	DKGridLayer* grid = [mDrawing gridLayer];
	
	if (mLivePreview && grid )
		[grid setRulerSteps:[sender intValue]];

	if ( sender == mGridRulerStepsSpinControl )
		[mGridRulerStepsTextField setIntValue:[sender intValue]];
	else
		[mGridRulerStepsSpinControl setIntValue:[sender intValue]];
}


- (IBAction)		gridThemeColourAction:(id)sender
{
	DKGridLayer* grid = [mDrawing gridLayer];
	
	if (mLivePreview && grid )
		[grid setGridThemeColour:[sender color]];
}


- (IBAction)		gridPrintAction:(id) sender
{
	[[mDrawing gridLayer] setShouldDrawToPrinter:[sender intValue]];
}


- (IBAction)		livePreviewAction:(id)sender
{
	mLivePreview = [sender intValue];
}


- (IBAction)		okAction:(id)sender
{
#pragma unused (sender)
	[[self window] orderOut:self];
	[NSApp endSheet:[self window] returnCode:NSOKButton];
}


- (IBAction)		unitsComboBoxAction:(id) sender
{
//	LogEvent_(kStateEvent, @"units changing to: %@", [sender stringValue]);
	
	int indx = [mUnitsComboBox indexOfItemWithObjectValue:[sender stringValue]];
	
	if ( indx == NSNotFound )
	{
		mUnitConversionFactor = 1.0;
		//[mConversionFactorTextField setEnabled:YES];
		//[mConversionFactorSpinControl setEnabled:YES];
	}
	else
	{
		mUnitConversionFactor = sUnitFactors[indx];
		//[mConversionFactorTextField setEnabled:NO];
		//[mConversionFactorSpinControl setEnabled:NO];
	}
		
	[mConversionFactorLabelText setStringValue:[NSString stringWithFormat:@"1 %@ occupies", [sender stringValue]]];
	[mDrawing setDrawingUnits:[sender stringValue] unitToPointsConversionFactor:mUnitConversionFactor];
	
	if ( mLivePreview )
		[[mDrawing gridLayer] synchronizeRulers];
	
	[self prepareDialogWithDrawing:mDrawing];
}


- (IBAction)		conversionFactorAction:(id) sender
{
	float oldUCF = mUnitConversionFactor;
	
	mUnitConversionFactor = [sender floatValue];
	
	if ( sender == mConversionFactorSpinControl )
		[mConversionFactorTextField setFloatValue:[sender floatValue]];
	else
		[mConversionFactorSpinControl setFloatValue:[sender floatValue]];

	DKGridLayer* grid = [mDrawing gridLayer];
	
	if (mLivePreview && grid )
	{
		int		divs, majs;
		float	span;
		
		divs = [grid divisions];
		majs = [grid majors];
		span = ([grid span] * mUnitConversionFactor )/ oldUCF;
		
		[grid	setSpan:MAX( 1.0, span )
				unitToPointsConversionFactor:mUnitConversionFactor
				measurementSystem:[grid measurementSystem]
				drawingUnits:[mDrawing drawingUnits]
				divisions: divs
				majors: majs
				rulerSteps:[mGridRulerStepsTextField intValue]];
	}
}


- (IBAction)		paperColourAction:(id) sender
{
	if ( mLivePreview )
		[mDrawing setPaperColour:[sender color]];
}


#pragma mark -
#pragma mark As an NSWindowController
- (void)		windowDidLoad
{
	mLivePreview = YES;
	[self setupComboBoxWithCurrentUnits:[mDrawing drawingUnits]];
	[mUnitsComboBox setStringValue:[mDrawing drawingUnits]];
	[mConversionFactorLabelText setStringValue:[NSString stringWithFormat:@"1 %@ occupies", [mDrawing drawingUnits]]];
	[self prepareDialogWithDrawing:mDrawing];
}


@end
