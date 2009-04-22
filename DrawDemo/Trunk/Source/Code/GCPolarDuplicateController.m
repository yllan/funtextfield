#import "GCPolarDuplicateController.h"

#import <GCDrawKit/LogEvent.h>


@implementation GCPolarDuplicateController
#pragma mark As a GCPolarDuplicateController

- (IBAction)		angleAction:(id)sender
{
#pragma unused (sender)
}


- (IBAction)		cancelAction:(id)sender
{
#pragma unused (sender)
	[[self window] orderOut:self];
	[NSApp endSheet:[self window] returnCode:NSCancelButton];
}


- (IBAction)		centreAction:(id)sender
{
#pragma unused (sender)
	// disable the OK button if either of the centre fields are empty
	[self conditionallyEnableOKButton];
}


- (IBAction)		copiesAction:(id)sender
{
#pragma unused (sender)
}


- (IBAction)		duplicateAction:(id)sender
{
#pragma unused (sender)
	[[self window] orderOut:self];
	[NSApp endSheet:[self window] returnCode:NSOKButton];
}


- (IBAction)		rotateCopiesAction:(id)sender
{
#pragma unused (sender)
}


- (IBAction)		autoFitAction:(id) sender
{
	BOOL enable = ([sender intValue] == 0);
	
	//[mManualSettingsBox setEnabled:enable];

	[mAngleIncrementTextField setEnabled:enable];
	[mCopiesTextField setEnabled:enable];
	[mRotateCopiesCheckbox setIntValue:1];
	[mRotateCopiesCheckbox setEnabled:enable];
}


#pragma mark -
- (void)			beginPolarDuplicationDialog:(NSWindow*) parentWindow polarDelegate:(id) delegate
{
	mDelegateRef = delegate;
	
	[NSApp	beginSheet:[self window]
			modalForWindow:parentWindow
			modalDelegate:self
			didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
			contextInfo:@"polar_duplication"];

	int items = [delegate countOfItemsInSelection];
	[mAutoFitCircleCheckbox setEnabled:(items == 1)];
	[self conditionallyEnableOKButton];
}


- (void)			sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
#pragma unused (sheet, contextInfo)
	if ( returnCode == NSOKButton )
	{
		// extract parameters and do something with them
		
		int			copies = [mCopiesTextField intValue];
		NSPoint		centre;
		
		centre.x =  [mCentreXTextField floatValue];
		centre.y =  [mCentreYTextField floatValue];
		
		float		incAngle = [mAngleIncrementTextField floatValue];
		BOOL		rotCopies = [mRotateCopiesCheckbox intValue];
		
		if ([mAutoFitCircleCheckbox intValue] == 1 )
		{
			[mDelegateRef doAutoPolarDuplicateWithCentre:centre];
		}
		else
		{
	
			LogEvent_(kReactiveEvent, @"dialog data: copies %d; centre {%.2f,%.2f}; incAngle %.3f; rotateCopies %d", copies, centre.x, centre.y, incAngle, rotCopies );

			[mDelegateRef doPolarDuplicateCopies:copies centre:centre incAngle:incAngle rotateCopies:rotCopies];
		}
	}
}


#pragma mark -
- (void)	conditionallyEnableOKButton
{
	if ([mCentreXTextField stringValue] == nil ||
			[[mCentreXTextField stringValue] isEqualToString:@""] ||
			[mCentreYTextField stringValue] == nil ||
			[[mCentreYTextField stringValue] isEqualToString:@""])
		[mOKButton setEnabled:NO];
	else
		[mOKButton setEnabled:YES];
}


@end
