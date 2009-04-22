///**********************************************************************************************************************************
///  GCDashEditView.h
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

@interface GCDashEditView : NSView
{
	DKLineDash*		mDash;
	NSMutableArray*	mHandles;
	NSBezierPath*	mPath;
	int				mSelected;
	id				mDelegateRef;
	NSColor*		mLineColour;
	NSRect			mPhaseHandle;
}


- (void)			setDash:(DKLineDash*) dash;
- (DKLineDash*)		dash;

- (void)			setLineWidth:(float) width;
- (void)			setLineCapStyle:(NSLineCapStyle) lcs;
- (void)			setLineJoinStyle:(NSLineJoinStyle) ljs;
- (void)			setLineColour:(NSColor*) colour;

- (void)			setDelegate:(id) del;
- (id)				delegate;

- (void)			calcHandles;
- (int)				mouseInHandle:(NSPoint) mp;
- (void)			drawHandles;
- (void)			calcDashForPoint:(NSPoint) mp;

@end

@interface NSObject	(DashEditViewDelegate)

- (void)			dashDidChange:(id) sender;

@end

#define		kGCStandardHandleRectSize	(NSMakeSize(8, 8 ))
#define		kGCDashEditInset			8
