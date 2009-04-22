///**********************************************************************************************************************************
///  DKUndoManager.h
///  DrawKit
///
///  Created by graham on 22/06/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************


#import <Foundation/Foundation.h>

@interface DKUndoManager : NSUndoManager
{
	BOOL			mCoalescingEnabled;
	BOOL			mDeferGroupsEnabled;
	BOOL			mSkipTask;
	id				mSkipTargetRef;
	id				mLastTargetRef;
	SEL				mLastSelector;
	unsigned		mChangeCount;
	BOOL			mGroupDeferred;
	unsigned		mGroupOpenCount;
	BOOL			mInPrivateMethod;

}

- (void)			enableUndoTaskCoalescing:(BOOL) enable;
- (BOOL)			isUndoTaskCoalescingEnabled;

- (unsigned)		changeCount;
- (void)			resetChangeCount;

- (void)			enableGroupDeferral:(BOOL) defer;
- (BOOL)			isGroupDeferralEnabled;
- (BOOL)			isGroupBeingDeferred;

@end

/*

This subclass of NSUndoManager can coalesce consecutive tasks that it receives so that only one task is recorded to undo a series of
otherwise identical ones. This is very useful when interactively editing objects where a large stream of identical tasks can be
received. It is largely safe to use with coalescing enabled even for normal undo situations, so coalescing is enabled by default.

It also records a change count which is an easy way to check if the state of the undo stack has changed from some earlier time -
just compare the change count with one you recorded earlier.


************* NOTE - THIS DOES NOT WORK - DO NOT ENABLE GROUP DEFERRAL!! ***************

Group deferral is another useful thing that works around an NSUndoManager bug. When beginUndoGrouping is called, the group is not
actually opened at that point - instead it is flagged as deferred. If an actual task is received, the group is opened if the
defer flag is set. This ensures that a group is only created when there is something to put in it - NSUndoManager creates a
bogus Undo item on the stack for empty groups. This allows client code to simply open a group on mouse down, do stuff in dragged,
and close the group at mouse up without creating bogus stack states.

*/


