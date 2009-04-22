///**********************************************************************************************************************************
///  NSBezierPath+GPC.m
///  DrawKit
///
///  Created by graham on 31/10/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#ifdef qUseGPC

#import "NSBezierPath+GPC.h"

#import "LogEvent.h"

#ifdef qUseCurveFit
#import "CurveFit.h"
#endif


//#define qUseLogPoly
#ifdef qUseLogPoly
static void		logPoly( gpc_polygon* poly );
#endif


#pragma mark Static Vars
static DKPathUnflatteningPolicy		sSimplifyingPolicy = kGCPathUnflattenAuto;


#pragma mark -
@implementation NSBezierPath (GPC)
#pragma mark As a NSBezierPath

///*********************************************************************************************************************
///
/// method:			bezierPathWithGPCPolygon:
/// scope:			class method
/// overrides:
/// description:	converts a vector polygon in gpc format to an NSBezierPath
/// 
/// parameters:		<poly> a gpc polygon structure
/// result:			the same polygon as an NSBezierPath
///
/// notes:			
///
///********************************************************************************************************************

+ (NSBezierPath*)		bezierPathWithGPCPolygon:(gpc_polygon*) poly
{
	NSBezierPath*	path = [NSBezierPath bezierPath];
	NSPoint			p;
	int				cont;
	
	for( cont = 0; cont < poly->num_contours; ++cont )
	{
		p.x = poly->contour[cont].vertex[0].x;
		p.y = poly->contour[cont].vertex[0].y;
		[path moveToPoint:p];
		
		int vert;
		
		for( vert = 1; vert < poly->contour[cont].num_vertices; ++vert )
		{
			p.x = poly->contour[cont].vertex[vert].x;
			p.y = poly->contour[cont].vertex[vert].y;
			[path lineToPoint:p];
		}
		
		[path closePath];
	}
	
	// set the default winding rule to be the one most useful for shapes
	// with holes.
	
	[path setWindingRule:NSEvenOddWindingRule];
	
	return path;
}


///*********************************************************************************************************************
///
/// method:			setPathUnflatteningPolicy:
/// scope:			class method
/// overrides:
/// description:	sets the unflattening (curve fitting) policy for curve fitting flattened paths after a boolean op
/// 
/// parameters:		<sp> policy constant
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

+ (void)				setPathUnflatteningPolicy:(DKPathUnflatteningPolicy) sp
{
	sSimplifyingPolicy = sp;
}


///*********************************************************************************************************************
///
/// method:			pathUnflatteningPolicy
/// scope:			class method
/// overrides:
/// description:	returns the unflattening (curve fitting) policy for curve fitting flattened paths after a boolean op
/// 
/// parameters:		none
/// result:			thne current unflattening policy
///
/// notes:			
///
///********************************************************************************************************************

+ (DKPathUnflatteningPolicy)	pathUnflatteningPolicy
{
	return sSimplifyingPolicy;
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			gpcPolygon
/// scope:			instance method
/// extends:		NSBezierPath
/// description:	converts a bezier path to a gpc polygon format structure
/// 
/// parameters:		none
/// result:			a newly allocated gpc polygon structure
///
/// notes:			the caller is responsible for freeing the returned object (in contrast to usual cocoa rules)
///
///********************************************************************************************************************

- (gpc_polygon*)		gpcPolygon
{
	return [self gpcPolygonWithFlatness:0.01];
}


///*********************************************************************************************************************
///
/// method:			gpcPolygonWithFlatness
/// scope:			instance method
/// extends:		NSBezierPath
/// description:	converts a bezier path to a gpc polygon format structure
/// 
/// parameters:		<flatness> the flatness value for converting curves to vector form
/// result:			a newly allocated gpc polygon structure
///
/// notes:			the caller is responsible for freeing the returned object (in contrast to usual cocoa rules)
///
///********************************************************************************************************************

- (gpc_polygon*)		gpcPolygonWithFlatness:(float) flatness
{
	[self setFlatness:flatness];
	
	NSBezierPath*			flat = [self bezierPathByFlatteningPath];
	NSBezierPathElement		elem;
	NSPoint					ap[3];
	int						i, ec = [flat elementCount];
	gpc_polygon*			poly;
	
	[flat setWindingRule:[self windingRule]];
	
	// allocate memory for the poly.
	
	poly = (gpc_polygon*) malloc( sizeof( gpc_polygon ));
	
	if ( poly == NULL )
		return NULL;
		
	poly->contour = NULL;
	poly->hole = NULL;
	
	// how many contours do we need?
	
	int subs;
	[self getPathMoveToCount:&subs lineToCount:NULL curveToCount:NULL closePathCount:NULL];
	poly->num_contours = subs;

	poly->contour = (gpc_vertex_list*) malloc( sizeof( gpc_vertex_list ) * poly->num_contours );
	
	if ( poly->contour == NULL )
	{
		gpc_free_polygon( poly );
		return NULL;
	}
	
	// how many elements in each contour?
	
	int es = 0;
	
	for( i = 0; i < poly->num_contours; ++i )
	{
		int spc = [flat subPathCountStartingAtElement:es];
	
		// allocate enough memory to hold this many points
				
		poly->contour[i].num_vertices = spc;
		poly->contour[i].vertex = (gpc_vertex*) malloc( sizeof( gpc_vertex ) * spc );
		
		es += spc;
	}
	
	// es will now keep track of which contour we are adding to; k is the element index within it.
	
	int k = 0;
	es = -1;
	NSPoint	 spStart = NSZeroPoint;
	
	for( i = 0; i < ec; ++i )
	{
		elem = [flat elementAtIndex:i associatedPoints:ap];
		
		switch( elem )
		{
			case NSMoveToBezierPathElement:
			// begins a new contour.
			
			if ( es != -1 )
			{
				// close the previous contour by adding a vertex with the subpath start
				
				poly->contour[es].vertex[k].x = spStart.x;
				poly->contour[es].vertex[k].y = spStart.y;
			}
			// next contour:
			++es;
			k = 0;
			// keep a note of the start of the subpath so we can close it
			spStart = ap[0];
			
			// sanity check es - must not exceed contour count - 1
			
			if ( es >= poly->num_contours )
			{
				LogEvent_(kWheneverEvent, @"discrepancy in contour count versus number of subpaths encountered - bailing");
				
				gpc_free_polygon( poly );
				return NULL;
			}
			
			// fall through to record the vertex for the moveto
			
			case NSLineToBezierPathElement:
			// add a vertex to the list
			poly->contour[es].vertex[k].x = ap[0].x;
			poly->contour[es].vertex[k].y = ap[0].y;
			++k;
			break;
			
			case NSCurveToBezierPathElement:
				// should never happen - we have already converted the path to a flat version. Bail.
				LogEvent_(kWheneverEvent, @"got a curveto unexpectedly - bailing");
				gpc_free_polygon( poly );
				return NULL;
			
			default:	
			case NSClosePathBezierPathElement:
			// ignore
			break;
			
		}
	}
	
#ifdef qUseLogPoly
	logPoly( poly );
#endif
	
	return poly;
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			subPathCountStartingAtElement:
/// scope:			instance method
/// extends:		NSBezierPath
/// description:	counts the number of separate subpath in the path starting from a given element
/// 
/// parameters:		<se> the index of some element in the path
/// result:			integer, the number of subpaths after and including se (actually the number of moveTo ops)
///
/// notes:			
///
///********************************************************************************************************************

- (int)					subPathCountStartingAtElement:(int) se
{
	// returns the number of elements in the subpath starting at element <se>. The caller is responsible for setting se
	// correctly - it should be the index of a 'moveto' element. This counts up until the next moveTo or the end of
	// the path, and returns the element count.
	
	NSBezierPathElement	et;
	int					sp, i, ec = [self elementCount];
	
	sp = 1;
	
	for( i = se + 1; i < ec; ++i )
	{
		et = [self elementAtIndex:i];
		
		if ( et == NSMoveToBezierPathElement )
			break;
			
		++sp;
	}
	
	return sp;
}


///*********************************************************************************************************************
///
/// method:			getPathMoveToCount:lineToCount:curveToCount:closePathCount:
/// scope:			instance method
/// extends:		NSBezierPath
/// description:	counts the number of elements of each type in the path
/// 
/// parameters:		<mtc, ltc, ctc, cpc> pointers to integers that receive the counts for each element type
/// result:			none
///
/// notes:			pass NULL for any values you are not interested in
///
///********************************************************************************************************************

- (void)				getPathMoveToCount:(int*) mtc lineToCount:(int*) ltc curveToCount:(int*) ctc closePathCount:(int*) cpc
{
	int i, ec = [self elementCount];
	int m, l, c, p;
	
	NSBezierPathElement	elem;
	
	m = l = c = p = 0;
	
	for( i = 0; i < ec; ++i )
	{
		elem = [self elementAtIndex:i];
		
		switch( elem )
		{
			case NSMoveToBezierPathElement:
				++m;
				break;
				
			case NSLineToBezierPathElement:
				++l;
				break;
				
			case NSCurveToBezierPathElement:
				++c;
				break;
				
			case NSClosePathBezierPathElement:
				++p;
				break;
				
			default:
				break;
		}
	}
	
	if( mtc )
		*mtc = m;
		
	if( ltc )
		*ltc = l;
		
	if( ctc )
		*ctc = c;
		
	if( cpc )
		*cpc = p;
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			intersectsPath:
/// scope:			instance method
/// extends:		NSBezierPath
/// description:	tests whether this path intersects another
/// 
/// parameters:		<path> another path to test against
/// result:			YES if the paths intersect, NO otherwise
///
/// notes:			this works by computing the intersection of the two paths and checking if it's empty. Because it
///					does a full-blown intersection, it is not necessarily a trivial operation. It is accurate for
///					curves, etc however. It is worth trying to eliminate all obvious non-intersecting cases prior to
///					calling this where performance is critical - this does however return quickly if the bounds do not
///					intersect.
///
///********************************************************************************************************************

- (BOOL)				intersectsPath:(NSBezierPath*) path
{
	NSRect		bbox = [path bounds];
	
	if ( NSIntersectsRect( bbox, [self bounds]))
	{
		// bounds intersect, so it's a possibility - find the intersection and see if it's empty.
	
		NSBezierPath* ip = [self pathFromIntersectionWithPath:path];
		
		return ![ip isEmpty];
	}
	else
		return NO;
}


///*********************************************************************************************************************
///
/// method:			pathFromPath:usingBooleanOperation:
/// scope:			instance method
/// extends:		NSBezierPath
/// description:	creates a new path from a boolean operation between this path and another path
/// 
/// parameters:		<otherPath> another path which is combined with this one's path
///					<op> the operation to perform - constants defined in gpc.h
/// result:			a new path (may be empty in certain cases)
///
/// notes:			this applies the current flattening policy set for the class. If the policy is auto, this looks
///					at the makeup of the contributing paths to determine whether to unflatten or not. If both source
///					paths consist solely of line elements (no bezier curves), then no unflattening is performed.
///
///********************************************************************************************************************

- (NSBezierPath*)		pathFromPath:(NSBezierPath*) otherPath usingBooleanOperation:(gpc_op) op
{
	BOOL simplify = NO;
	
	if (sSimplifyingPolicy == kGCPathUnflattenAlways)
		simplify = YES;
	else if (sSimplifyingPolicy == kGCPathUnflattenAuto)
	{
		// for auto, if both this path and the other path have no curve segments, simplify is NO, otherwise YES.
		
		int cs, co;
		
		[self getPathMoveToCount:NULL lineToCount:NULL curveToCount:&cs closePathCount:NULL];
		[otherPath getPathMoveToCount:NULL lineToCount:NULL curveToCount:&co closePathCount:NULL];
		
		if ( cs == 0 && co == 0 )
			simplify = NO;
		else
			simplify = YES;
	}
	
	return [self pathFromPath:otherPath usingBooleanOperation:op unflattenResult:simplify];
}


///*********************************************************************************************************************
///
/// method:			pathFromPath:usingBooleanOperation:unflattenResult:
/// scope:			instance method
/// extends:		NSBezierPath
/// description:	creates a new path from a boolean operation between this path and another path
/// 
/// parameters:		<otherPath> another path which is combined with this one's path
///					<op> the operation to perform - constants defined in gpc.h
///					<unflattenResult> YES to attempt curve fitting on the result, NO to leave it in vector form
/// result:			a new path (may be empty in certain cases)
///
/// notes:			the unflattening flag is passed directly - the curve fitting policy of the class is ignored
///
///********************************************************************************************************************

- (NSBezierPath*)		pathFromPath:(NSBezierPath*) otherPath usingBooleanOperation:(gpc_op) op unflattenResult:(BOOL) uf
{
	NSBezierPath*	result;
	gpc_polygon		*a, *b, *c;
	
	a = [self gpcPolygon];
	b = [otherPath gpcPolygon];
	c = (gpc_polygon*) malloc( sizeof( gpc_polygon ));
	
	gpc_polygon_clip( op, a, b, c );
	
#ifdef qUseLogPoly
	logPoly( c );
#endif
	
	result = [NSBezierPath bezierPathWithGPCPolygon:c];
	
//	LogEvent_(kReactiveEvent, @"path = %@", result );
	
	gpc_free_polygon( a );
	gpc_free_polygon( b );
	gpc_free_polygon( c );
	
	if ( uf )
		return [result bezierPathByUnflatteningPath];
	else
		return result;
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			pathFromUnionWithPath:
/// scope:			instance method
/// extends:		NSBezierPath
/// description:	creates a new path which is the union of this path and another path
/// 
/// parameters:		<otherPath> another path which is unioned with this one's path
/// result:			a new path
///
/// notes:			curve fitting policy for the class is applied to this method
///
///********************************************************************************************************************

- (NSBezierPath*)		pathFromUnionWithPath:(NSBezierPath*) otherPath
{
	return [self pathFromPath:otherPath usingBooleanOperation:GPC_UNION];
}


///*********************************************************************************************************************
///
/// method:			pathFromIntersectionWithPath:
/// scope:			instance method
/// extends:		NSBezierPath
/// description:	creates a new path which is the intersection of this path and another path
/// 
/// parameters:		<otherPath> another path which is intersected with this one's path
/// result:			a new path (possibly empty)
///
/// notes:			curve fitting policy for the class is applied to this method
///
///********************************************************************************************************************

- (NSBezierPath*)		pathFromIntersectionWithPath:(NSBezierPath*) otherPath
{
	return [self pathFromPath:otherPath usingBooleanOperation:GPC_INT];
}


///*********************************************************************************************************************
///
/// method:			pathFromDifferenceWithPath:
/// scope:			instance method
/// extends:		NSBezierPath
/// description:	creates a new path which is the difference of this path and another path
/// 
/// parameters:		<otherPath> another path which is subtracted from this one's path
/// result:			a new path (possibly empty)
///
/// notes:			curve fitting policy for the class is applied to this method
///
///********************************************************************************************************************

- (NSBezierPath*)		pathFromDifferenceWithPath:(NSBezierPath*) otherPath
{
	return [self pathFromPath:otherPath usingBooleanOperation:GPC_DIFF];
}


///*********************************************************************************************************************
///
/// method:			pathFromExclusiveOrWithPath:
/// scope:			instance method
/// extends:		NSBezierPath
/// description:	creates a new path which is the xor of this path and another path
/// 
/// parameters:		<otherPath> another path which is xored with this one's path
/// result:			a new path (possibly empty)
///
/// notes:			curve fitting policy for the class is applied to this method
///
///********************************************************************************************************************

- (NSBezierPath*)		pathFromExclusiveOrWithPath:(NSBezierPath*) otherPath
{
	return [self pathFromPath:otherPath usingBooleanOperation:GPC_XOR];
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			bezierPathByUnflatteningPath
/// scope:			instance method
/// extends:		NSBezierPath
/// description:	creates a new path which is the unflattened version of this
/// 
/// parameters:		none
/// result:			the unflattened path (curve fitted)
///
/// notes:			
///
///********************************************************************************************************************

- (NSBezierPath*)		bezierPathByUnflatteningPath
{
	NSSize ps = [self bounds].size;
	
	float epsilon = MIN( ps.width, ps.height ) / 1000.0;
	
	LogEvent_(kInfoEvent, @"curve fit epsilon: %f", epsilon );

#ifdef qUseCurveFit
	return smartCurveFitPath( self, epsilon, kGCDefaultCornerThreshold );
#else
	return self;
#endif
}


@end



#pragma mark -
#ifdef qUseLogPoly
static void		logPoly( gpc_polygon* poly )
{
	// dumps the contents of the poly to the log

	LogEvent_(kReactiveEvent, @"gpc_polygon: %p", poly );
	LogEvent_(kReactiveEvent, @"contours: %d\n", poly->num_contours );
	
	int cont;
	
	for( cont = 0; cont < poly->num_contours; ++cont )
	{
		LogEvent_(kReactiveEvent, @"contour #%d: %d vertices", cont, poly->contour[cont].num_vertices );
		
		int vert;
		
		for( vert = 0; vert < poly->contour[cont].num_vertices; ++vert )
			LogEvent_(kReactiveEvent, @"{ %f, %f },", poly->contour[cont].vertex[vert].x, poly->contour[cont].vertex[vert].y );
			
		LogEvent_(kReactiveEvent, @"------ end of contour %d ------", cont );
	}
	LogEvent_(kReactiveEvent, @"------ end of polygon ------" );
}
#endif


#endif /* defined (qUseGPC) */
