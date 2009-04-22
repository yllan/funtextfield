///**********************************************************************************************************************************
///  GCContourPlotter.m
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

#import "GCContourPlotter.h"
//#import <GCDrawKit/CurveFit.h>	

#define xsect(p1,p2) (h[p2]*xh[p1]-h[p1]*xh[p2])/(h[p2]-h[p1])
#define ysect(p1,p2) (h[p2]*yh[p1]-h[p1]*yh[p2])/(h[p2]-h[p1])

inline static BOOL		pointsClose( NSPoint a, NSPoint b, float tolerance );
static void				reverse_list( Seq* list );
static void				remove_seq( Seq* list, Seq** head );
static void				free_seq( Seq* list );
static void				free_all( Seq* head );



@implementation GCContourPlotter


- (id)				initWithDataSource:(id) src dataReceiver:(id) rec
{
	if ((self = [super init]) != nil )
	{
		_progressMonitor = nil;
		[self setDataSource:src];
		[self setDataReceiver:rec];
	}
	
	return self;
}



- (void)			setDataSource:(id) src
{
	_dataSource = src;
}


- (id)				dataSource
{
	return _dataSource;
}


- (void)			setDataReceiver:(id) rec
{
	_dataReceiver = rec;
}


- (id)				dataReceiver
{
	return _dataReceiver;
}


- (void)			setDataProgressMonitor:(id) mon
{
	_progressMonitor = mon;
}


- (id)				dataProgressMonitor
{
	return _progressMonitor;
}



- (void)			computeContours
{
	NSTimeInterval t1 = [NSDate timeIntervalSinceReferenceDate];
	
	[self computeContoursWithUserInfo2:NULL];
	
	NSTimeInterval t2 = [NSDate timeIntervalSinceReferenceDate];
	
	NSLog(@"time to plot = %f sec", t2 - t1 );
}


- (void)			computeContoursWithUserInfo:(void*) info
{
	// does the work by implementing the conrec algorithm using the delegate to obtain its parameters and to
	// send its output to.
	
/*
   Derivation from the fortran version of CONREC by Paul Bourke
   d               ! matrix of data to contour
   ilb,iub,jlb,jub ! index bounds of data matrix
   x               ! data matrix column coordinates
   y               ! data matrix row coordinates
   nc              ! number of contour levels
   z               ! contour levels in increasing order
*/

	int			ilb, jlb, iub, jub, nc;
	int			m1, m2, m3, case_value;
	double		dmin, dmax, x1=0, x2=0, y1=0, y2=0;
	int			i, j, k, m;
	double		h[5];
	int			sh[5];
	double		xh[5], yh[5];
	int			im[4] = {0,1,1,0},jm[4]={0,0,1,1};
	int			castab[3][3][3] =	{
									{ {0,0,8},{0,2,5},{7,6,9} },
									{ {0,3,4},{1,3,1},{4,3,0} },
									{ {9,6,7},{5,2,0},{8,0,0} }
									};
	
	double		temp1, temp2, temp3, temp4, zmin, zmax, d1, d2, z;

	ilb = [self minX];						// min extent of DEM cells horizontally
	jlb = [self minY];						// min extent of DEM cells vertically
	iub = [self maxX];						// max extent of DEM cells horizontally
	jub = [self maxY];						// max extent of DEM cells vertically
	
	nc = [self countOfContours];			// number of contours to plot
	zmin = [self contourForIndex:0];		// minimum height
	zmax = [self contourForIndex:nc - 1];	// maximum height
	
	NSLog(@"x:%d-%d; y:%d-%d; contour range: min = %f, max = %f", ilb, iub, jlb, jub, zmin, zmax );
	
	if( ![self notifyProgressValue:0 max:jub - jlb phase:kContourPlottingStarting userInfo:info])
		return;

	for ( j = (jub-1); j >= jlb; j-- )
	{
		if( ![self notifyProgressValue:jub - jlb - j max:jub - jlb phase:kContourPlottingContinuing userInfo:info])
			return;
		
		for ( i = ilb; i <= iub-1; i++ )
		{
			// get the min and max of heights to be found in this DEM cell
			
			d1 = [self heightForX:i y:j];
			d2 = [self heightForX:i y:j+1];
			temp1 = MIN( d1, d2 );
			temp3 = MAX( d1, d2 );
			
			d1 = [self heightForX:i+1 y:j];
			d2 = [self heightForX:i+1 y:j+1];
			temp2 = MIN( d1, d2 );
			temp4 = MAX( d1, d2 );
			
			dmin  = MIN(temp1, temp2);
			dmax  = MAX(temp3, temp4);
			
			//NSLog(@"testing coordinate x:%d, y:%d; height min = %f, max= %f", i, j, dmin, dmax );
			
			// if outside the overall contour range of interest, ignore the cell
			
			if ( dmax < zmin || dmin > zmax )
				continue;
				
			for ( k = 0; k < nc; k++ )
			{
				z = [self contourForIndex:k];	// get the contour height value corresponding to this index
				
				//NSLog(@"contour %d, value = %f", k, z );
				
				// if the height doesn't intersect this DEM cell's height range, nothing to do
				
				if ( z < dmin || z > dmax )
					continue;
				
				for ( m = 4; m >= 0; m-- )
				{
					NSPoint coord, coor1;
					
					if ( m > 0 )
					{
						h[m] = [self heightForX:i+im[m-1] y:j+jm[m-1]] - z;
						coord = [self coordinateForX:i+im[m-1] y:j+jm[m-1]];
						
						xh[m] = coord.x;
						yh[m] = coord.y;
					}
					else
					{
						coord = [self coordinateForX:i y:j];
						coor1 = [self coordinateForX:i+1 y:j+1];
						
						h[0]  = 0.25 * (h[1]+h[2]+h[3]+h[4]);
						xh[0] = 0.50 * (coord.x + coor1.x);
						yh[0] = 0.50 * (coord.y + coor1.y);
					}
					
					if ( h[m] > 0.0 )
						sh[m] = 1;
					else if ( h[m] < 0.0 )
						sh[m] = -1;
					else
						sh[m] = 0;
				}	// m

				/*
				   Note: at this stage the relative heights of the corners and the
				   centre are in the h array, and the corresponding coordinates are
				   in the xh and yh arrays. The centre of the box is indexed by 0
				   and the 4 corners by 1 to 4 as shown below.
				   Each triangle is then indexed by the parameter m, and the 3
				   vertices of each triangle are indexed by parameters m1,m2,and m3.
				   It is assumed that the centre of the box is always vertex 2
				   though this is important only when all 3 vertices lie exactly on
				   the same contour level, in which case only the side of the box
				   is drawn.
					  vertex 4 +-------------------+ vertex 3
							   | \               / |
							   |   \    m=3    /   |
							   |     \       /     |
							   |       \   /       |
							   |  m=2    X   m=2   |       the centre is vertex 0
							   |       /   \       |
							   |     /       \     |
							   |   /    m=1    \   |
							   | /               \ |
					  vertex 1 +-------------------+ vertex 2
				*/
				/* Scan each triangle in the box */
				
				for ( m = 1; m <= 4; m++ )
				{
					m1 = m;
					m2 = 0;
					if ( m != 4 )
						m3 = m + 1;
					else
						m3 = 1;
						
					if ((case_value = castab[sh[m1]+1][sh[m2]+1][sh[m3]+1]) == 0)
						continue;
						
					//NSLog(@"finding segment (case %d)...", case_value);
						
					switch (case_value)
					{
						case 1: /* Line between vertices 1 and 2 */
						   x1 = xh[m1];
						   y1 = yh[m1];
						   x2 = xh[m2];
						   y2 = yh[m2];
						   break;
						
						case 2: /* Line between vertices 2 and 3 */
						   x1 = xh[m2];
						   y1 = yh[m2];
						   x2 = xh[m3];
						   y2 = yh[m3];
						   break;
						
						case 3: /* Line between vertices 3 and 1 */
						   x1 = xh[m3];
						   y1 = yh[m3];
						   x2 = xh[m1];
						   y2 = yh[m1];
						   break;
						
						case 4: /* Line between vertex 1 and side 2-3 */
						   x1 = xh[m1];
						   y1 = yh[m1];
						   x2 = xsect(m2,m3);
						   y2 = ysect(m2,m3);
						   break;
						
						case 5: /* Line between vertex 2 and side 3-1 */
						   x1 = xh[m2];
						   y1 = yh[m2];
						   x2 = xsect(m3,m1);
						   y2 = ysect(m3,m1);
						   break;
						
						case 6: /* Line between vertex 3 and side 1-2 */
						   x1 = xh[m3];
						   y1 = yh[m3];
						   x2 = xsect(m3,m2);
						   y2 = ysect(m3,m2);
						   break;
						
						case 7: /* Line between sides 1-2 and 2-3 */
						   x1 = xsect(m1,m2);
						   y1 = ysect(m1,m2);
						   x2 = xsect(m2,m3);
						   y2 = ysect(m2,m3);
						   break;
						
						case 8: /* Line between sides 2-3 and 3-1 */
						   x1 = xsect(m2,m3);
						   y1 = ysect(m2,m3);
						   x2 = xsect(m3,m1);
						   y2 = ysect(m3,m1);
						   break;
						
						case 9: /* Line between sides 3-1 and 1-2 */
						   x1 = xsect(m3,m1);
						   y1 = ysect(m3,m1);
						   x2 = xsect(m1,m2);
						   y2 = ysect(m1,m2);
						   break;
						
						default:
						   break;
					}

					/* Finally output the line */
					
					[self contourWithIndex:k lineFromPoint:NSMakePoint( x1, y1 ) toPoint:NSMakePoint( x2, y2 )];
					
				} /* m */
			} /* k - contour */
		} /* i */
	} /* j */
	
	[self notifyProgressValue:jub - jlb max:jub - jlb phase:kContourPlottingComplete userInfo:info];
}


- (void)			computeContoursWithUserInfo2:(void*) info
{
	// This is a modified version of CONREC that splits each cell into two triangles instead of four. This
	// is done to make it faster (potentially). Precision can be regained by making the cells smaller.
	// As well as this algorithmic change, this uses tighter code, calls the datasource directly, and prefetches the contour height table.
	
	static int	im[4] = {0,1,1,0}, jm[4]={0,0,1,1};
	static int	castab[3][3][3] =	{
									{ {0,0,8},{0,2,5},{7,6,9} },
									{ {0,3,4},{1,3,1},{4,3,0} },
									{ {9,6,7},{5,2,0},{8,0,0} }
									};

	int			ilb, jlb, iub, jub, nc;
	int			m1, m2, m3, case_value;
	int			i, j, k, m;
	int			sh[4];				// relative positions of the corners above, equal or below the contour plane (-1, 0, 1)
	double		z, zmin, zmax, dmin, dmax, x1, x2, y1, y2;
	
	double		d[4];				// absolute heights of the four corners of the cell
	double		h[4];				// relative heights of the four corners of the cell
	double		xh[4], yh[4];		// the real x, y coordinates of the corners of the cell
	
	NSPoint		coord;
	
	double*		zz;									// table of heights prefetched from data source

	ilb = [_dataSource minX];						// min extent of DEM cells horizontally
	jlb = [_dataSource minY];						// min extent of DEM cells vertically
	iub = [_dataSource maxX];						// max extent of DEM cells horizontally
	jub = [_dataSource maxY];						// max extent of DEM cells vertically
	
	nc = [_dataSource countOfContours];				// number of contours to plot
	zmin = [_dataSource contourForIndex:0];			// minimum height
	zmax = [_dataSource contourForIndex:nc - 1];	// maximum height
	
	//NSLog(@"x:%d-%d; y:%d-%d; contour range: min = %f, max = %f", ilb, iub, jlb, jub, zmin, zmax );
	
	if( ![self notifyProgressValue:0 max:jub - jlb phase:kContourPlottingStarting userInfo:info])
		goto cleanup;
	
	// build a table of contour heights for each indexed contour
	
	zz = malloc( sizeof(double) * nc );
	
	for( k = 0; k < nc; ++k )
		zz[k] = [_dataSource contourForIndex:k];
	
	// outer loop, scan rows
	
	for ( j = jlb; j < jub; ++j )
	{
		if( ![self notifyProgressValue:j - jlb max:jub - jlb phase:kContourPlottingContinuing userInfo:info])
			goto cleanup;
		
		// inner loop, scan columns
		
		for ( i = ilb; i < iub; ++i )
		{
			// get the values and min and max of heights to be found in this DEM cell
			
			dmin = HUGE_VAL;
			dmax = -HUGE_VAL;
			
			for( m = 0; m < 4; ++m )
			{
				d[m] = [_dataSource heightForX:i+im[m] y:j+jm[m]];
			
				if ( d[m] > dmax )
					dmax = d[m];
					
				if ( d[m] < dmin )
					dmin = d[m];
			}

			// if outside the overall contour range of interest, ignore the cell
			
			if ( dmax < zmin || dmin > zmax )
				continue;
			
			// for each cell, check against the range of contours of interest
				
			for ( k = 0; k < nc; ++k )
			{
				z = zz[k];
				
				// if the height doesn't intersect this DEM cell's height range, nothing to do
				
				if ( z < dmin || z > dmax )
					continue;
				
				// for the two triangle case, we don't need to compute the centre of the cell, though we
				// still need the 4 corners at this stage
				
				for ( m = 0; m < 4; ++m )
				{
					h[m] = d[m] - z;
					sh[m] = ((h[m] > 0.0)? 2 : ((h[m] < 0.0)? 0 : 1 ));

					coord = [_dataSource coordinateForX:i+im[m] y:j+jm[m]];
				
					xh[m] = coord.x;
					yh[m] = coord.y;
				}

				/*
				   Note: at this stage the relative heights of the corners are in the h array, and the corresponding coordinates are
				   in the xh and yh arrays. The 4 corners are indexed by 0 to 3 as shown below.
				   Each triangle is then indexed by the parameter m, and the 3
				   vertices of each triangle are indexed by parameters m1,m2,and m3.
				   
					  vertex 3 +-------------------+ vertex 2
							   |                 / |
							   |               /   |
							   |             /     |
							   |           /       |
							   |  m=1    /         |       
							   |       /           |
							   |     /             |
							   |   /    m=0        |
							   | /                 |
					  vertex 0 +-------------------+ vertex 1
				*/
				/* Scan the pair of triangles in the box */
				
				m1 = 0;
				m2 = 1;
				m3 = 2;

				for ( m = 0; m < 2; ++m )
				{
					if ( m == 1 )
					{
						m1 = 2;
						m2 = 3;
						m3 = 0;
					}
					
					if ((case_value = castab[sh[m1]][sh[m2]][sh[m3]]) == 0)
						continue;
						
					//NSLog(@"finding segment (case %d)...", case_value);
						
					switch (case_value)
					{
						case 1: /* Line between vertices 1 and 2 */
						   x1 = xh[m1];
						   y1 = yh[m1];
						   x2 = xh[m2];
						   y2 = yh[m2];
						   break;
						
						case 2: /* Line between vertices 2 and 3 */
						   x1 = xh[m2];
						   y1 = yh[m2];
						   x2 = xh[m3];
						   y2 = yh[m3];
						   break;
						
						case 3: /* Line between vertices 3 and 1 */
						   x1 = xh[m3];
						   y1 = yh[m3];
						   x2 = xh[m1];
						   y2 = yh[m1];
						   break;
						
						case 4: /* Line between vertex 1 and side 2-3 */
						   x1 = xh[m1];
						   y1 = yh[m1];
						   x2 = xsect(m2,m3);
						   y2 = ysect(m2,m3);
						   break;
						
						case 5: /* Line between vertex 2 and side 3-1 */
						   x1 = xh[m2];
						   y1 = yh[m2];
						   x2 = xsect(m3,m1);
						   y2 = ysect(m3,m1);
						   break;
						
						case 6: /* Line between vertex 3 and side 1-2 */
						   x1 = xh[m3];
						   y1 = yh[m3];
						   x2 = xsect(m3,m2);
						   y2 = ysect(m3,m2);
						   break;
						
						case 7: /* Line between sides 1-2 and 2-3 */
						   x1 = xsect(m1,m2);
						   y1 = ysect(m1,m2);
						   x2 = xsect(m2,m3);
						   y2 = ysect(m2,m3);
						   break;
						
						case 8: /* Line between sides 2-3 and 3-1 */
						   x1 = xsect(m2,m3);
						   y1 = ysect(m2,m3);
						   x2 = xsect(m3,m1);
						   y2 = ysect(m3,m1);
						   break;
						
						case 9: /* Line between sides 3-1 and 1-2 */
						   x1 = xsect(m3,m1);
						   y1 = ysect(m3,m1);
						   x2 = xsect(m1,m2);
						   y2 = ysect(m1,m2);
						   break;
						
						default:
						   break;
					}

					/* Finally output the line */
					
					[_dataReceiver contourWithIndex:k lineFromPoint:NSMakePoint( x1, y1 ) toPoint:NSMakePoint( x2, y2 )];
					
				} /* m */
			} /* k - contour */
		} /* i */
	} /* j */
	
	[self notifyProgressValue:jub - jlb max:jub - jlb phase:kContourPlottingComplete userInfo:info];
	
cleanup:
	free( zz );
}


- (int)				countOfContours
{
	if ([self dataSource])
		return [[self dataSource] countOfContours];
	else
		return 1;
}


- (double)			contourForIndex:(int) index
{
	if ([self dataSource])
		return [[self dataSource] contourForIndex:index];
	else
		return (double) index;
}


- (int)				minX
{
	if ([self dataSource])
		return [[self dataSource] minX];
	else
		return 0;
}


- (int)				minY
{
	if ([self dataSource])
		return [[self dataSource] minY];
	else
		return 0;
}



- (int)				maxX
{
	if ([self dataSource])
		return [[self dataSource] maxX];
	else
		return 1;
}



- (int)				maxY
{
	if ([self dataSource])
		return [[self dataSource] maxY];
	else
		return 1;
}



- (double)			heightForX:(int) x y:(int) y
{
	if ([self dataSource])
		return [[self dataSource] heightForX:x y:y];
	else
		return 1.0;
}


- (NSPoint)			coordinateForX:(int) x y:(int) y
{
	if ([self dataSource])
		return [[self dataSource] coordinateForX:x y:y];
	else
		return NSMakePoint( x, y );
}


- (BOOL)			notifyProgressValue:(int) p max:(int) maxP phase:(int) phase userInfo:(void*) info
{
	if ([self dataProgressMonitor])
		return [[self dataProgressMonitor] notifyProgressValue:p max:maxP phase:phase userInfo:info];
	else
	{
		//NSLog(@"contour #%d of %d; phase = %d", p, maxP, phase );
		return YES;		// keep going
	}
}



- (void)			contourWithIndex:(int) index lineFromPoint:(NSPoint) a toPoint:(NSPoint) b
{
	if ([self dataReceiver])
		[[self dataReceiver] contourWithIndex:index lineFromPoint:a toPoint:b];
	else
		NSLog(@"contour #%d: a:%@ b:%@", index, NSStringFromPoint(a), NSStringFromPoint(b));
}



@end


#pragma mark -


@implementation GCBezierContourer

- (id)					init
{
	if ((self = [super init]) != nil )
	{
		_contours = [[NSMutableDictionary alloc] init];
		_fitTolerance = 1.0;
		_curveFit = NO;
	}
	
	return self;
}



- (void)				dealloc
{
	[_contours release];
	[super dealloc];
}


- (void)				setDoCurveFitting:(BOOL) fit withTolerance:(float) tol
{
	_curveFit = fit;
	_fitTolerance = tol;
}



- (BOOL)				doesCurveFitting
{
	return _curveFit;
}



- (float)				fitTolerance
{
	return _fitTolerance;
}



- (NSBezierPath*)		vectorPathForIndex:(int) index
{
	// if no contours, ask the plotter to perform the operation:
	
	if ([_contours count] == 0 )
		return nil;
	
	GCContourBuilder* cb = [_contours objectForKey:[NSString stringWithFormat:@"%d", index]];
	
	if ( cb == nil )
		return nil;		// index not known
		
	return [cb contourPath];
}



- (NSBezierPath*)		contourPathForIndex:(int) index
{
	NSBezierPath* path = [self vectorPathForIndex:index];
	/*
	if([self doesCurveFitting])
	{
		// curve fit the path here
		
		path = smartCurveFitPath( path, [self fitTolerance], 0.5 );

		NSLog(@"fitted path = %d elements", [path elementCount]);
	}
	*/
	return path;
}



- (NSArray*)			allContourPaths
{
	NSMutableArray* paths = [NSMutableArray arrayWithCapacity:[self countOfContours]];
	
	int n;
	NSBezierPath*	contour;
	
	for( n = 0; n < [self countOfContours]; ++n )
	{
		contour = [self contourPathForIndex:n];
		
		// insert a null object in place of empty or null contours - thus the array index is
		// the original contour index
		
		if ( contour && ![contour isEmpty])
		{
			//NSLog(@"adding contour %d", n );
			[paths addObject:contour];
		}
		else
			[paths addObject:[NSNull null]];
	}
	
	return paths;
}



- (int)					countOfContours
{
	return [_contours count];
}



- (BOOL)				notifyProgressValue:(int) p max:(int) maxP phase:(int) phase userInfo:(void*) info
{
	NSLog(@"plotting %d of %d (phase = %d)", p, maxP, phase );
	
	return YES;
}



- (void)				contourWithIndex:(int) index lineFromPoint:(NSPoint) a toPoint:(NSPoint) b
{
	// save each line segment as a pair of point values in a dictionary referenced to the index. Each entry is stored with point a as the
	// key and point b as the value.
	
	//NSLog(@"recording contour segment, contour = %d. a = %@, b = %@", index, NSStringFromPoint( a ), NSStringFromPoint( b ));
	
	GCContourBuilder* cb = [_contours objectForKey:[NSString stringWithFormat:@"%d", index]];
	
	if ( cb == nil )
	{
		cb = [[GCContourBuilder alloc] init];
		[_contours setObject:cb forKey:[NSString stringWithFormat:@"%d", index]];
		[cb release];
	}
	
	[cb addSegmentFromPoint:a toPoint:b];
}


- (void)				reset
{
	[_contours removeAllObjects];
}


@end



#pragma mark -

@implementation GCContourBuilder


- (id)					init
{
	if ((self = [super init]) != nil )
	{
		_s = NULL;
		_tolerance = 0.0001;
	}
	
	return self;
}

- (void)				dealloc
{
	free_all( _s );
	[super dealloc];
}


- (NSBezierPath*)		contourPath
{
	NSBezierPath*	path = [NSBezierPath bezierPath];
	Seq*			ss;
	Lpt*			pp;
	int				n = 0;
	
	ss = _s;
	
	while( ss )
	{
		//NSLog(@"converting vector, pcount = %d", ss->pcount );
		
		if ( ss->pcount > 3 )	// discard (skip) very short sequences (????)
		{
			[path moveToPoint:ss->head->p];
			
			pp = ss->head->next;
			++n;
			
			while( pp )
			{
				[path lineToPoint:pp->p];
				pp = pp->next;
			}

			if ( ss->closed )
				[path closePath];
		}
		ss = ss->next;
	}
	
	NSLog(@"contour path, %d sections, %d elements", n, [path elementCount]);
	
	return path;
}


- (void)				addSegmentFromPoint:(NSPoint) a toPoint:(NSPoint) b
{
	Seq*    ss = _s;
	Seq*	ma = NULL;
	Seq*	mb = NULL;
	BOOL	prependA = NO;
	BOOL	prependB = NO;
	
	while( ss )
	{
		if ( ma == NULL )
		{
			// no match for a yet
			
			if ( pointsClose( a, ss->head->p, _tolerance ))
			{
				ma = ss;
				prependA = YES;
			}
			else if ( pointsClose( a, ss->tail->p, _tolerance ))
				ma = ss;
		}
		
		if ( mb == NULL )
		{
			// no match for b yet
			
			if ( pointsClose( b, ss->head->p, _tolerance ))
			{
				mb = ss;
				prependB = YES;
			}
			else if ( pointsClose( b, ss->tail->p, _tolerance ))
				mb = ss;
		}
		
		// if we matched both no need to continue searching
		
		if ( mb != NULL && ma != NULL )
			break;
		else
			ss = ss->next;
	}
	
	// the case selector based on which of ma and/or mb are set
	
	int c = (( ma != NULL )? 1 : 0) | (( mb != NULL )? 2 : 0);
	
	switch( c )
	{
		case 0:		// both unmatched, add as new sequence
		{
			Lpt* aa = malloc( sizeof( Lpt ));
			Lpt* bb = malloc( sizeof( Lpt ));
			aa->p = a;
			bb->p = b;
			aa->next = bb;
			bb->prev = aa;
			aa->prev = bb->next = NULL;
			
			// create sequence element and push onto head of main list. The order
			// of items in this list is unimportant
			
			ma = malloc( sizeof( Seq ));
			ma->head = aa;
			ma->tail = bb;
			ma->next = _s;
			ma->prev = NULL;
			ma->pcount = 2;
			ma->closed = NO;
			
			if ( _s )
				_s->prev = ma;
			_s = ma;
		}
		break;
			
		case 1:		// a matched, b did not - thus b extends sequence ma
		{
			Lpt* pp = malloc( sizeof( Lpt ));
			pp->p = b;
			
			if ( prependA )
			{
				pp->next = ma->head;
				pp->prev = NULL;
				ma->head->prev = pp;
				ma->head = pp;
			}
			else
			{
				pp->next = NULL;
				pp->prev = ma->tail;
				ma->tail->next = pp;
				ma->tail = pp;
			}
			ma->pcount++;
		}
		break;
			
		case 2:		// b matched, a did not - thus a extends sequence mb
		{
			Lpt* pp = malloc( sizeof( Lpt ));
			pp->p = a;
			
			if ( prependB )
			{
				pp->next = mb->head;
				pp->prev = NULL;
				mb->head->prev = pp;
				mb->head = pp;
			}
			else
			{
				pp->next = NULL;
				pp->prev = mb->tail;
				mb->tail->next = pp;
				mb->tail = pp;
			}
			mb->pcount++;
		}
		break;
			
		case 3:		// both matched, can merge sequences
		{
			// if the same sequence, closing path, flag and do nothing
			
			if ( ma == mb )
			{
				ma->closed = YES;
				break;
			}
			// there are 4 ways the sequence pair can be joined. The current setting of prependA and
			// prependB will tell us which type of join is needed. For head/head and tail/tail joins
			// one sequence needs to be reversed
			
			switch((prependA? 1 : 0) | (prependB? 2 : 0))
			{
				case 0:		// tail-tail
                  // reverse ma and append to mb
					reverse_list( ma );
					// fall through to head/tail case
				case 1:		// head-tail
                  // ma is appended to mb and ma discarded
					mb->tail->next = ma->head;
					ma->head->prev = mb->tail;
					mb->tail = ma->tail;
					mb->pcount += ma->pcount;
					
					//discard ma sequence record
					remove_seq( ma, &_s );
					free( ma );
					break;
					
				case 3:		// head-head
                  // reverse ma and append mb to it
					reverse_list( ma );
					// fall through to tail/head case
				case 2:		// tail-head
                  // mb is appended to ma and mb is discarded
					ma->tail->next = mb->head;
					mb->head->prev = ma->tail;
					ma->tail = mb->tail;
					ma->pcount += mb->pcount;
					
					//discard mb sequence record
					remove_seq( mb, &_s );
					free( mb );
					break;
			}
		}
	}
}


@end




inline static BOOL		pointsClose( NSPoint a, NSPoint b, float tolerance )
{
	return hypotf( b.x - a.x, b.y - a.y ) < tolerance;
}


static void				reverse_list( Seq* list )
{
	Lpt*  	pp;
	Lpt*	temp;
	
	pp = list->head;
	
	while( pp )
	{
		// swap prev/next pointers
		temp = pp->next;
		pp->next = pp->prev;
		pp->prev = temp;
		
		// continue through the list
		pp = temp;
	}
	
	// swap head/tail pointers
	
	temp = list->head;
	list->head = list->tail;
	list->tail = temp;
}


static void			remove_seq( Seq* list, Seq** head )
{
	// if <list> is the first item, static ptr s is updated
	
	if ( list->prev )
		list->prev->next = list->next;
	else
		*head = list->next;
	
	if ( list->next )
		list->next->prev = list->prev;
}


static void			free_seq( Seq* list )
{
	Lpt*	pp = list->head;
	Lpt*	temp;
	
	while( pp )
	{
		temp = pp->next;
		free( pp );
		pp = temp;
	}
	
	free( list );
}


static void			free_all( Seq* head )
{
	Seq* ss = head;
	Seq* temp;
	
	while( ss )
	{
		temp = ss->next;
		free_seq( ss );
		ss = temp;
	}
}


