///**********************************************************************************************************************************
///  GCBasicDialogController.m
///  GCDrawKit
///
///  Created by graham on 03/11/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "GCBasicDialogController.h"


@implementation GCBasicDialogController
#pragma mark As a GCBasicDialogController
- (int)			runModal
{
	mRunningAsSheet = NO;
	
	int result = [NSApp runModalForWindow:[self window]];
	
	[[self window] orderOut:self];
	
	return result;
}


- (void)		runAsSheetInParentWindow:(NSWindow*) parent modalDelegate:(id) delegate
{
	mRunningAsSheet = YES;
	
	[NSApp beginSheet:[self window]
			modalForWindow:parent
			modalDelegate:delegate
			didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
			contextInfo:self];
}


#pragma mark -
- (id)			primaryItem
{
	return mPrimaryItem;
}


#pragma mark -
- (IBAction)	ok:(id) sender
{
	#pragma unused(sender)
	
	if ( mRunningAsSheet )
	{
		[[self window] orderOut:self];
		[NSApp endSheet:[self window] returnCode:NSOKButton];
	}
	else
		[NSApp stopModalWithCode:NSOKButton];
}


- (IBAction)	cancel:(id) sender
{
	#pragma unused(sender)
	
	if ( mRunningAsSheet )
	{
		[[self window] orderOut:self];
		[NSApp endSheet:[self window] returnCode:NSCancelButton];
	}
	else
		[NSApp stopModalWithCode:NSCancelButton];
}


- (IBAction)	primaryItemAction:(id) sender
{
	#pragma unused(sender)
	

}


@end
