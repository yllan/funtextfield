///**********************************************************************************************************************************
///  DKPathInsertDeleteTool.h
///  DrawKit
///
///  Created by graham on 09/06/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKDrawingTool.h"


@class DKDrawablePath;

// modes of operation for this tool:

typedef enum
{
	kGCPathDeletePointMode		= 0,
	kGCPathInsertPointMode		= 1
}
DKPathToolMode;




@interface DKPathInsertDeleteTool : DKDrawingTool
{
	DKPathToolMode		m_mode;
	BOOL				m_performedAction;
	DKDrawablePath*		mTargetRef;
}

+ (DKDrawingTool*)		pathDeletionTool;
+ (DKDrawingTool*)		pathInsertionTool;

- (void)				setMode:(DKPathToolMode) m;
- (DKPathToolMode)		mode;

@end



/*

This tool is able to insert or delete on-path points from a path. If applied to other object type it does nothing.

*/

