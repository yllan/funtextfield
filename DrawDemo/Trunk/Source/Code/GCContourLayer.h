///**********************************************************************************************************************************
///  GCContourLayer.h
///  GCDrawKit
///
///  Created by graham on 01/10/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>
#import <GCDrawKit/GCDrawingLayer.h>
#import "GCContourPlotter.h"


@interface GCContourLayer : GCDrawingLayer
{
	GCContourPlotter*		_plotter;
	GCBezierContourer*		_bc;
	NSColor*				_contourLineColour;
	float					_contourLineWidth;
	NSArray*				_contoursCache;
	float					_cellSize;
}


- (void)					clearCache;
- (void)					recalculateContours;
- (NSColor*)				colourForHeight:(double) h;

@end
