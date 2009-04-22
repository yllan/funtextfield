///**********************************************************************************************************************************
///  DKZoomTool.m
///  DrawKit
///
///  Created by graham on 25/03/2008.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************


#import <Cocoa/Cocoa.h>
#import "DKDrawingTool.h"

@interface DKZoomTool : DKDrawingTool
{
	BOOL	mMode;			// NO to zoom in, YES to zoom out
	NSPoint	mAnchor;		// initial click pt
	NSRect	mZoomRect;		// zoom rect when dragged
}


@end


/*

This tool implements a zoom "magnifier" tool. It can zoom in, zoom out or zoom in to a dragged rect. It does not affect
the data content of the drawing, only the view that is applying it, so does not generate any undo tasks.


*/


