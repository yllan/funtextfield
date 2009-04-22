///**********************************************************************************************************************************
///  GCContourLayer.m
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

#import "GCContourLayer.h"
#import <GCDrawKit/GCDrawing.h>
#import <GCDrawKit/NSBezierPath+Geometry.h>

@implementation GCContourLayer


- (id)						initWithDrawing:(GCDrawing*) drawing
{
	if ((self = [super initWithDrawing:drawing]) != nil )
	{
		_contourLineWidth = 0.5;
		_contourLineColour = [[NSColor grayColor] retain];
		_contoursCache = nil;
		_cellSize = 8.0;
		
		_bc = [[GCBezierContourer alloc] init];
		_plotter = [[GCContourPlotter alloc] initWithDataSource:self dataReceiver:_bc];
	}
	
	return self;
}


- (void)					dealloc
{
	[_bc release];
	[_plotter release];
	[_contourLineColour release];
	[super dealloc];
}


- (void)					clearCache
{
	[_contoursCache release];
	_contoursCache = nil;
}


- (void)					recalculateContours
{
	NSLog(@"recomputing contours...");
	
	if ( _contoursCache )
		[self clearCache];
	
	[_bc reset];
	[_plotter computeContours];
		
	_contoursCache = [[_bc allContourPaths] retain];
}



#define __CONTOUR_TEST__		0


- (void)					drawRect:(NSRect) rect
{
		
#if __CONTOUR_TEST__
	[_plotter setDataReceiver:self];
	[_plotter computeContours];
	
#else
	if ( _contoursCache == nil )
		[self recalculateContours];

		
	NSEnumerator*	iter = [_contoursCache objectEnumerator];
	NSBezierPath*	path;
	NSRect			bounds;
	int				n = 0;
	NSString*		label;
	
	while( path = [iter nextObject])
	{
		if ((id)path != [NSNull null])
		{
			bounds = NSInsetRect( [path bounds], -_contourLineWidth, -_contourLineWidth );
			
			if ( NSIntersectsRect( bounds, rect ))
			{
				[[self colourForHeight:[self contourForIndex:n]] setFill];
				[path fill];
				[_contourLineColour setStroke];
				[path setLineWidth:_contourLineWidth];
				[path stroke];
				
				label = [NSString stringWithFormat:@"%.3f", [self contourForIndex:n]];
				[path drawStringOnPath:label];
			}
		}
		++n;
	}
#endif
}


- (void)				contourWithIndex:(int) index lineFromPoint:(NSPoint) a toPoint:(NSPoint) b
{
	// test callback method - will plot the contour directly for testing if the layer is set as the data receiver of the plotter
	// and the plotter is made to run during drawRect.
	
	[NSBezierPath setDefaultLineWidth:_contourLineWidth];
	[_contourLineColour setStroke];
	[NSBezierPath strokeLineFromPoint:a toPoint:b];
}


- (BOOL)				shouldDrawToPrinter
{
	return YES;
}


- (int)					countOfContours
{
	return 12;
}



- (double)				contourForIndex:(int) index
{
	return (3.1123f * (float)index) + 0;
}


- (int)					minX
{
	return 0;
}


- (int)					minY
{
	return 0;
}


- (int)					maxX
{
	return NSWidth([[self drawing] interior]) / _cellSize;
}



- (int)					maxY
{
	return NSHeight([[self drawing] interior]) / _cellSize;
}



- (double)				heightForX:(int) x y:(int) y
{
	float xx, yy;

	yy = (((float) x / (float)[self maxX]) - 0.5 ) * 3.0;
	xx = (((float) y / (float)[self maxY]) - 0.5 ) * 3.0;

	float h = 1.0 / ( pow(( pow( xx, 2 ) + ((yy - 0.842) * ( yy + 0.842 ))), 2 ) + pow(( xx * (yy - 0.842)) + ( xx * ( yy - 0.842)) , 2));
	
	return 0 + ([self countOfContours] / 3.0 * h );
}



- (NSPoint)				coordinateForX:(int) x y:(int) y
{
	NSRect r = [[self drawing] interior];
	
	return NSMakePoint( x * _cellSize + NSMinX( r ), y * _cellSize + NSMinY( r ));
}


- (NSColor*)			colourForHeight:(double) h
{
	float r, g, b, a, hmax;
	
	hmax = ([self countOfContours] * 3.1123 ) + 0;
	
	r = h / hmax;
	g = 0.7;
	b = r * 0.8;
	a = 0.5 * r;
	
	
	return [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
}



@end
