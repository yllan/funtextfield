//
//  GCLinearDuplicateController.m
//  GCDrawKit
//
//  Created by graham on 01/04/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import "GCLinearDuplicateController.h"

#import <GCDrawKit/LogEvent.h>


@implementation GCLinearDuplicateController


- (IBAction)		numberOfCopiesAction:(id) sender
{
#pragma unused (sender)
	[self conditionallyEnableOKButton];
}


- (IBAction)		xyOffsetAction:(id) sender
{
#pragma unused (sender)
	[self conditionallyEnableOKButton];
}


- (IBAction)		okAction:(id) sender
{
#pragma unused (sender)
	[[self window] orderOut:self];
	[NSApp endSheet:[self window] returnCode:NSOKButton];
}


- (IBAction)		cancelAction:(id) sender
{
#pragma unused (sender)
	[[self window] orderOut:self];
	[NSApp endSheet:[self window] returnCode:NSCancelButton];
}



- (void)			beginLinearDuplicationDialog:(NSWindow*) parentWindow linearDelegate:(id) delegate
{
	mDelegateRef = delegate;
	
	[NSApp	beginSheet:[self window]
			modalForWindow:parentWindow
			modalDelegate:self
			didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
			contextInfo:@"linear_duplication"];

	[self conditionallyEnableOKButton];
}


- (void)			sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo
{
#pragma unused (sheet, contextInfo)
	if ( returnCode == NSOKButton )
	{
		// extract parameters and do something with them
		
		int			copies = [mNumberOfCopiesTextField intValue];
		NSSize		offset;
		
		offset.width =  [mXOffsetTextField floatValue];
		offset.height =  [mYOffsetTextField floatValue];
		
		LogEvent_(kReactiveEvent, @"dialog data: copies %d; offset {%.2f,%.2f}", copies, offset.width, offset.height );

		[mDelegateRef doLinearDuplicateCopies:copies offset:offset];
	}
}



- (void)			conditionallyEnableOKButton
{
	if ([mNumberOfCopiesTextField stringValue] == nil ||
			[[mNumberOfCopiesTextField stringValue] isEqualToString:@""] ||
			[mXOffsetTextField stringValue] == nil ||
			[[mXOffsetTextField stringValue] isEqualToString:@""] ||
			[mYOffsetTextField stringValue] == nil ||
			[[mYOffsetTextField stringValue] isEqualToString:@""])
		[mOKButton setEnabled:NO];
	else
		[mOKButton setEnabled:YES];
}


@end
