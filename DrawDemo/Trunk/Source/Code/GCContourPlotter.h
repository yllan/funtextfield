///**********************************************************************************************************************************
///  GCContourPlotter.h
///  GCDrawKit
///
///  Created by graham on 18/09/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>


@interface GCContourPlotter : NSObject
{
	id				_dataSource;
	id				_dataReceiver;
	id				_progressMonitor;
}

- (id)				initWithDataSource:(id) src dataReceiver:(id) rec;

- (void)			setDataSource:(id) src;
- (id)				dataSource;
- (void)			setDataReceiver:(id) rec;
- (id)				dataReceiver;
- (void)			setDataProgressMonitor:(id) mon;
- (id)				dataProgressMonitor;

- (void)			computeContours;
- (void)			computeContoursWithUserInfo:(void*) info;		// original CONREC algorithm
- (void)			computeContoursWithUserInfo2:(void*) info;		// modified CONREC algorithm about 60% faster


@end

// progress phases:

enum
{
	kContourPlottingStarting		= 0,
	kContourPlottingContinuing		= 1,
	kContourPlottingComplete		= 2
};


// these informal protocols should be implemented by the various delegates of the plotter object. The data source supplies the limits for x and y,
// maxContours, and the height value for the coordinate x,y.

// The data receiver receives the output line segments as they are generated.

// If no delegates are supplied, the plotter object itself implements these methods, so can be subclassed and used that way if preferred.


@interface NSObject (ContourDataSource)

- (int)				countOfContours;
- (double)			contourForIndex:(int) index;

- (int)				minX;
- (int)				minY;
- (int)				maxX;
- (int)				maxY;
- (double)			heightForX:(int) x y:(int) y;
- (NSPoint)			coordinateForX:(int) x y:(int) y;

@end


@interface NSObject (ContourProgress)

- (BOOL)			notifyProgressValue:(int) p max:(int) maxP phase:(int) phase userInfo:(void*) info;

@end



@interface NSObject (ContourDataReceiver)

- (void)			contourWithIndex:(int) index lineFromPoint:(NSPoint) a toPoint:(NSPoint) b;

@end



// this object can be a data receiver of a plotter to produce bezier curves for the contours.

@interface GCBezierContourer : NSObject
{
	NSMutableDictionary*	_contours;
	BOOL					_curveFit;
	float					_fitTolerance;
}

- (void)				setDoCurveFitting:(BOOL) fit withTolerance:(float) tol;
- (BOOL)				doesCurveFitting;
- (float)				fitTolerance;

- (NSBezierPath*)		vectorPathForIndex:(int) index;

- (NSBezierPath*)		contourPathForIndex:(int) index;
- (NSArray*)			allContourPaths;

- (void)				reset;

@end

// the following is a helper used by GCBezierContourer. It accumulates out of order contour segments into ordered vector paths
// in an efficient manner and converts them to a bezier path on request. The bezier contourer maintains one of these per contour.

struct Lpt
{
	struct Lpt*		next;
	struct Lpt*		prev;
	NSPoint			p;
};

typedef struct Lpt Lpt;

struct Seq
{
	struct Seq*		next;
	struct Seq*		prev;
	Lpt*			head;
	Lpt*			tail;
	int				pcount;
	BOOL			closed;
};

typedef struct Seq Seq;

@interface	GCContourBuilder	: NSObject
{
	Seq*				_s;						// list of sequences
	float				_tolerance;
}


- (NSBezierPath*)		contourPath;
- (void)				addSegmentFromPoint:(NSPoint) a toPoint:(NSPoint) b;

@end


