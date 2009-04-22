//
//  GCLinearDuplicateController.h
//  GCDrawKit
//
//  Created by graham on 01/04/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GCLinearDuplicateController : NSWindowController
{
	IBOutlet id		mNumberOfCopiesTextField;
	IBOutlet id		mXOffsetTextField;
	IBOutlet id		mYOffsetTextField;
	IBOutlet id		mOKButton;
	
	id				mDelegateRef;
}


- (IBAction)		numberOfCopiesAction:(id) sender;
- (IBAction)		xyOffsetAction:(id) sender;
- (IBAction)		okAction:(id) sender;
- (IBAction)		cancelAction:(id) sender;

- (void)			beginLinearDuplicationDialog:(NSWindow*) parentWindow linearDelegate:(id) delegate;
- (void)			sheetDidEnd:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void  *)contextInfo;

- (void)			conditionallyEnableOKButton;

@end


@interface NSObject (LinearDuplicationDelegate)

- (void)	doLinearDuplicateCopies:(int) copies offset:(NSSize) offset;
- (int)		countOfItemsInSelection;

@end

