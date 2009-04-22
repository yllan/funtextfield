///**********************************************************************************************************************************
///  DKObjectDrawingLayer+Alignment.m
///  DrawKit
///
///  Created by graham on 18/09/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKObjectDrawingLayer+Alignment.h"

#import "DKDrawableShape.h"
#import "DKDrawing.h"
#import "DKGridLayer.h"
#import "LogEvent.h"


#pragma mark Static Functions
static int vertLocSortFunc( id a, id b, void* context );
static int horizLocSortFunc( id a, id b, void* context );


#pragma mark -
@implementation DKObjectDrawingLayer (Alignment)
#pragma mark As a DKObjectDrawingLayer
///*********************************************************************************************************************
///
/// method:			alignObjects:withAlignment:
/// scope:			public instance method
///	overrides:
/// description:	aligns a set ofobjects
/// 
/// parameters:		<objects> the objects to align
///					<align> the alignment operation required
/// result:			none
///
/// notes:			objects are aligned with the first object in the supplied list
///
///********************************************************************************************************************

- (void)		alignObjects:(NSArray*) objects withAlignment:(int) align
{
	id master = [objects objectAtIndex:0];
	[self alignObjects:objects toMasterObject:master withAlignment:align];
}


///*********************************************************************************************************************
///
/// method:			alignObjects:toMasterObject:withAlignment:
/// scope:			public instance method
///	overrides:
/// description:	aligns a set ofobjects
/// 
/// parameters:		<objects> the objects to align
///					<object> the "master" object - the one to which the others are aligned
///					<align> the alignment operation required
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

- (void)		alignObjects:(NSArray*) objects toMasterObject:(id) object withAlignment:(int) align
{
	// if we are distributing the objects, use the distributor method first - master
	// doesn't come into it
	
	if (( align & kGCAlignmentDistributionMask ) != 0 )
		[self distributeObjects:objects withAlignment:align];
	
	// apply other alignment flag if there is any
	
	if (( align & ~kGCAlignmentDistributionMask ) != 0 )
	{
		NSEnumerator*   iter;
		id				mo;
		NSRect			mb, ob;
		NSPoint			alignOffset;
		
		LogEvent_(kUserEvent, @"Aligning objects with alignment = %d", align );
		
		mb = [object apparentBounds];
		
		iter = [objects objectEnumerator];
		
		while(( mo = [iter nextObject]))
		{
			if ( mo != object )
			{
				ob = [mo apparentBounds];
				alignOffset = calculateAlignmentOffset( mb, ob, align );
				[mo moveByX:alignOffset.x byY:alignOffset.y];
			}
		}
	}
}


///*********************************************************************************************************************
///
/// method:			alignObjects:toLocation:withAlignment:
/// scope:			public instance method
///	overrides:
/// description:	aligns a set of objects to a given point
/// 
/// parameters:		<objects> the objects to align
///					<loc> the point to which the objects are aligned
///					<align> the alignment operation required
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

- (void)		alignObjects:(NSArray*) objects toLocation:(NSPoint) loc withAlignment:(int) align
{
	#pragma unused(objects)
	#pragma unused(loc)
	#pragma unused(align)
	
	
	
	// TO DO
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			alignObjectEdges:toGrid:
/// scope:			public instance method
///	overrides:
/// description:	aligns the objects to the grid, resizing and positioning as necessary so that all edges lie on
///					the grid. The logical bounds is used for alignment, consistent with normal snapping behaviour.
/// 
/// parameters:		<objects> the objects to align
///					<grid> the grid to use
/// result:			none
///
/// notes:			may minimally resize the objects.
///
///********************************************************************************************************************

- (void)		alignObjectEdges:(NSArray*) objects toGrid:(DKGridLayer*) grid
{
	NSAssert( grid != nil, @"grid parameter is nil" );

	NSEnumerator*		iter;
	DKDrawableObject*	mo;
	NSRect				objRect;
	NSSize				offset;
	
	iter = [objects objectEnumerator];
	
	while(( mo = [iter nextObject]))
	{
		if([mo respondsToSelector:@selector(adjustToFitGrid:)])
			[(id)mo adjustToFitGrid:grid];
		else
		{
			objRect = [mo logicalBounds];
			objRect.size = [mo size];
			offset = [mo offset];
			
			objRect.origin = [grid nearestGridIntersectionToPoint:objRect.origin];
			objRect.size = [grid nearestGridIntegralToSize:objRect.size];

			[mo setOffset:NSMakeSize( -0.5, -0.5 )];
			
			[mo moveToPoint:objRect.origin];
			[mo setSize:objRect.size];
			[mo setOffset:offset];
		}
	}
}


///*********************************************************************************************************************
///
/// method:			alignObjectLocation:toGrid:
/// scope:			public instance method
///	overrides:
/// description:	aligns a set of objects so their locations lie on a grid intersection
/// 
/// parameters:		<objects> the objects to align
///					<grid> the grid to use
/// result:			none
///
/// notes:			does not resize the objects
///
///********************************************************************************************************************

- (void)		alignObjectLocation:(NSArray*) objects toGrid:(DKGridLayer*) grid
{
	NSAssert( grid != nil, @"grid parameter is nil" );
	
	NSEnumerator*		iter;
	DKDrawableObject*	mo;
	NSPoint				p;
	
	iter = [objects objectEnumerator];
	
	while(( mo = [iter nextObject]))
	{
		p = [grid  nearestGridIntersectionToPoint:[mo location]];
		[mo moveToPoint:p];
	}
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			totalVerticalSpace:
/// scope:			private instance method
///	overrides:
/// description:	computes the amount of space available for a vertical distribution operation
/// 
/// parameters:		<objects> the objects to align
/// result:			the total space available for distribution in the vertical direction
///
/// notes:			the list of objects must be sorted into order of their vertical location.
///					The space is the total distance between the top and bottom objects, minus the sum of the heights
///					of the objects in between
///
///********************************************************************************************************************

- (float)		totalVerticalSpace:(NSArray*) objects
{
	float		span, sumHeight = 0.0;
	unsigned	i;
	id			mo;
	NSRect		br;
	float		prevLowerEdge;
	
	prevLowerEdge = NSMaxY( [[objects objectAtIndex:0] logicalBounds ] );
	span = NSMinY( [[objects lastObject] logicalBounds ] ) - prevLowerEdge;
	
	for ( i = 1; i < [objects count] - 1; i++ )
	{
		mo = [objects objectAtIndex:i];
		br = [mo logicalBounds];
		sumHeight += br.size.height;
	}
	
	return span - sumHeight;
}


///*********************************************************************************************************************
///
/// method:			totalHorizontalSpace:
/// scope:			private instance method
///	overrides:
/// description:	computes the amount of space available for a horizontal distribution operation
/// 
/// parameters:		<objects> the objects to align
/// result:			the total space available for distribution in the horizontal direction
///
/// notes:			the list of objects must be sorted into order of their horizontal location.
///					The space is the total distance between the leftmost and rightmost objects, minus the sum of the widths
///					of the objects in between
///
///********************************************************************************************************************

- (float)		totalHorizontalSpace:(NSArray*) objects
{
	float		span, sumWidth = 0.0;
	unsigned	i;
	id			mo;
	NSRect		br;
	float		prevLowerEdge;
	
	prevLowerEdge = NSMaxX( [[objects objectAtIndex:0] logicalBounds ] );
	span = NSMinX( [[objects lastObject] logicalBounds ] ) - prevLowerEdge;
	
	for ( i = 1; i < [objects count] - 1; i++ )
	{
		mo = [objects objectAtIndex:i];
		br = [mo logicalBounds];
		sumWidth += br.size.width;
	}
	
	return span - sumWidth;
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			objectsSortedByVerticalPosition:
/// scope:			private instance method
///	overrides:
/// description:	sorts a set of objects into order of their vertical location
/// 
/// parameters:		<objects> the objects to sort
/// result:			a copy of the array sorted into vertical order
///
/// notes:			
///
///********************************************************************************************************************

- (NSArray*)	objectsSortedByVerticalPosition:(NSArray*) objects
{
	LogEvent_(kReactiveEvent, @"sorting objects into vertical order");
	
	NSMutableArray* na = [objects mutableCopy];
	
	[na sortUsingFunction:vertLocSortFunc context:nil];
	return [na autorelease];
}


///*********************************************************************************************************************
///
/// method:			objectsSortedByHorizontalPosition:
/// scope:			private instance method
///	overrides:
/// description:	sorts a set of objects into order of their horizontal location
/// 
/// parameters:		<objects> the objects to sort
/// result:			a copy of the array sorted into horizontal order
///
/// notes:			
///
///********************************************************************************************************************

- (NSArray*)	objectsSortedByHorizontalPosition:(NSArray*) objects
{
	LogEvent_(kReactiveEvent, @"sorting objects into horizontal order");
 	
	NSMutableArray* na = [objects mutableCopy];
	
	[na sortUsingFunction:horizLocSortFunc context:nil];
	return [na autorelease];
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			distributeObjects:withAlignment:
/// scope:			public instance method
///	overrides:
/// description:	distributes a set of objects
/// 
/// parameters:		<objects> the objects to distribute
///					<align> the distribution required
/// result:			YES if the operation could be performed, NO otherwise
///
/// notes:			normally this is called by the higher level alignObjects: methods when a distribution alignment is
///					detected
///
///********************************************************************************************************************

- (BOOL)		distributeObjects:(NSArray*) objects withAlignment:(int) align
{
	// distribute the objects - this is usually called from the alignment method as needed - calling it directly will
	// ignore any edge alignment set.
	
	NSArray*			sorted;
	int					numToAlign, i;
	float				spanDistance, spanIncrement, min, max;
	DKDrawableObject*	mo;
	
	numToAlign = [objects count];
	
	// needs to be a minimum of three for this method to do anything useful
	
	if ( numToAlign < 3 )
		return NO;
	
	if ( align & kGCAlignmentAlignVDistribution )
	{
		sorted = [self objectsSortedByVerticalPosition:objects];
		
		// find the span distance - the difference between the first and last objects
		
		min = [(DKDrawableObject*)[sorted objectAtIndex:0] location].y;
		max = [(DKDrawableObject*)[sorted lastObject] location].y;
	
		spanDistance = max - min;	//NSMidY( bottom ) - NSMidY( top );
		spanIncrement = spanDistance / (float)( numToAlign - 1 );
		
	//	LogEvent_(kReactiveEvent, @"vertically distributing %d objects, increment = %f, span = %f", numToAlign, spanIncrement, spanDistance );
		
		NSPoint cp;
		
		// iterate through the objects between the two, setting their vertical position accordingly
		
		for( i = 1; i < ( numToAlign - 1 ); i++ )
		{
			mo = [sorted objectAtIndex:i];
			
			cp.x = [mo location].x;
			cp.y = min + ((float) i * spanIncrement );
			
		//	LogEvent_(kReactiveEvent,  @"positioning object %d, {%f, %f}", i, cp.x, cp.y );
			
			[mo moveToPoint:cp];
		}
	}

	if ( align & kGCAlignmentAlignHDistribution )
	{
		sorted = [self objectsSortedByHorizontalPosition:objects];
		
		// find the span distance - the difference between the first and last objects
		
		min = [(DKDrawableObject*)[sorted objectAtIndex:0] location].x;
		max = [(DKDrawableObject*)[sorted lastObject] location].x;
		
		spanDistance = max - min;		//NSMidX( bottom ) - NSMidX( top );
		spanIncrement = spanDistance / (float)( numToAlign - 1 );
		
		NSPoint cp;
		
		// iterate through the objects between the two, setting their vertical position accordingly
		
		for( i = 1; i < ( numToAlign - 1 ); i++ )
		{
			mo = [sorted objectAtIndex:i];
			
			cp.y = [mo location].y;
			cp.x = min + ((float) i * spanIncrement );
			
			[mo moveToPoint:cp];
		}
	}
	
	if ( align & kGCAlignmentAlignVSpaceDistribution )
	{
		// the space between the objects is shared out equally.
		sorted = [self objectsSortedByVerticalPosition:objects];
		float		space = [self totalVerticalSpace:sorted];
		float		spaceEach = space / (float)( numToAlign - 1 );
		float		nte;
		NSRect		mobr;
		NSRect		prevBounds = NSZeroRect;
		
		// if the space is zero or negative, the objects overlap to a degree, and the space can't be distributed
		
		if ( space > 0.0 )
		{
		//	LogEvent_(kReactiveEvent, @"distributing space = %f among %d objects", space, numToAlign );
			
			NSPoint		cp;

			for ( i = 0; i < numToAlign - 1; i++ )
			{
				mo = [sorted objectAtIndex:i];
				mobr = [mo logicalBounds];
				
				if ( i > 0 )
				{
					cp.x = [mo location].x;
					
					// top edge of this object is bottom edge of last + spaceEach, but we are calculating the
					// centre
					
					nte = NSMaxY( prevBounds) + spaceEach;
					cp.y = NSMidY( mobr ) - NSMinY( mobr) + nte;
					
					[mo moveToPoint:cp];
					mobr = [mo logicalBounds];
				}
				prevBounds = mobr;
			}
		}
	}
	
	if ( align & kGCAlignmentAlignHSpaceDistribution )
	{
		// the space between the objects is shared out equally.
		sorted = [self objectsSortedByHorizontalPosition:objects];
		float		space = [self totalHorizontalSpace:sorted];
		float		spaceEach = space / (float)( numToAlign - 1 );
		float		nte;
		NSRect		mobr;
		NSRect		prevBounds = NSZeroRect;
		
		// if the space is zero or negative, the objects overlap to a degree, and the space can't be distributed
		
		if ( space > 0.0 )
		{
		//	LogEvent_(kReactiveEvent, @"distributing space = %f among %d objects", space, numToAlign );
			
			NSPoint		cp;

			for ( i = 0; i < numToAlign - 1; i++ )
			{
				mo = [sorted objectAtIndex:i];
				mobr = [mo logicalBounds];
				
				if ( i > 0 )
				{
					cp.y = [mo location].y;
					
					// top edge of this object is bottom edge of last + spaceEach, but we are calculating the
					// centre
					
					nte = NSMaxX( prevBounds) + spaceEach;
					cp.x = NSMidX( mobr ) - NSMinX( mobr) + nte;
					
					[mo moveToPoint:cp];
					mobr = [mo logicalBounds];
				}
				prevBounds = mobr;
			}
		}
	}
	
	return YES;
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			alignmentMenuItemRequiredObjects:
/// scope:			public action method
///	overrides:
/// description:	returns the minimum number of objects needed to enable the menu item
/// 
/// parameters:		<item> the menu item to validate
/// result:			number of objects needed for validation. If the item isn't a known alignment command, returns 0
///
/// notes:			call this from a generic validateMenuItem method for the layer as a whole
///
///********************************************************************************************************************

- (int)		alignmentMenuItemRequiredObjects:(NSMenuItem*) item
{
	SEL		action = [item action];
	
	if ( action == @selector( alignLeftEdges: ) ||
		 action == @selector( alignRightEdges: ) ||
		 action == @selector( alignHorizontalCentres: ) ||
		 action == @selector( alignTopEdges: ) ||
		 action == @selector( alignBottomEdges: ) ||
		 action == @selector( alignVerticalCentres: ))
		return 2;
	else if ( action == @selector( distributeVerticalCentres: ) ||
		 action == @selector( distributeVerticalSpace: ) ||
		 action == @selector( distributeHorizontalCentres: ) ||
		 action == @selector( distributeHorizontalSpace: ))
		return 3;
	else if ( action == @selector( alignEdgesToGrid: ) ||
		 action == @selector( alignLocationToGrid: ))
		return 1;

	return 0;
}


#pragma mark -
#pragma mark - user actions
///*********************************************************************************************************************
///
/// method:			alignLeftEdges:
/// scope:			public action method
///	overrides:
/// description:	aligns the selected objects on their left edges
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

- (IBAction)	alignLeftEdges:(id) sender
{
	#pragma unused(sender)
	
	if( ![self locked])
	{
		[self alignObjects:[self selectedAvailableObjects] withAlignment:kGCAlignmentAlignLeftEdge];
		[[self undoManager] setActionName:NSLocalizedString(@"Align Left Edges", @"undo string for align left edges")];
	}
}


///*********************************************************************************************************************
///
/// method:			alignRightEdges:
/// scope:			public action method
///	overrides:
/// description:	aligns the selected objects on their right edges
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

- (IBAction)	alignRightEdges:(id) sender
{
	#pragma unused(sender)
	
	if( ![self locked])
	{
		[self alignObjects:[self selectedAvailableObjects] withAlignment:kGCAlignmentAlignRightEdge];
		[[self undoManager] setActionName:NSLocalizedString(@"Align Right Edges", @"undo string for align right edges")];
	}
}


///*********************************************************************************************************************
///
/// method:			alignHorizontalCentres:
/// scope:			public action method
///	overrides:
/// description:	aligns the selected objects on their horizontal centres
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

- (IBAction)	alignHorizontalCentres:(id) sender
{
	#pragma unused(sender)
	
	if( ![self locked])
	{
		[self alignObjects:[self selectedAvailableObjects] withAlignment:kGCAlignmentAlignHorizontalCentre];
		[[self undoManager] setActionName:NSLocalizedString(@"Align Horizontal Centres", @"undo string for align h centres")];
	}
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			alignTopEdges:
/// scope:			public action method
///	overrides:
/// description:	aligns the selected objects on their top edges
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

- (IBAction)	alignTopEdges:(id) sender
{
	#pragma unused(sender)
	
	if( ![self locked])
	{
		[self alignObjects:[self selectedAvailableObjects] withAlignment:kGCAlignmentAlignTopEdge];
		[[self undoManager] setActionName:NSLocalizedString(@"Align Top Edges", @"undo string for align top edges")];
	}
}


///*********************************************************************************************************************
///
/// method:			alignBottomEdges:
/// scope:			public action method
///	overrides:
/// description:	aligns the selected objects on their bottom edges
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

- (IBAction)	alignBottomEdges:(id) sender
{
	#pragma unused(sender)
	
	if( ![self locked])
	{
		[self alignObjects:[self selectedAvailableObjects] withAlignment:kGCAlignmentAlignBottomEdge];
		[[self undoManager] setActionName:NSLocalizedString(@"Align Bottom Edges", @"undo string for align bottom edges")];
	}
}


///*********************************************************************************************************************
///
/// method:			alignVerticalCentres:
/// scope:			public action method
///	overrides:
/// description:	aligns the selected objects on their vertical centres
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

- (IBAction)	alignVerticalCentres:(id) sender
{
	#pragma unused(sender)
	
	if( ![self locked])
	{
		[self alignObjects:[self selectedAvailableObjects] withAlignment:kGCAlignmentAlignVerticalCentre];
		[[self undoManager] setActionName:NSLocalizedString(@"Align Vertical Centres", @"undo string for align v centres")];
	}
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			distributeVerticalCentres:
/// scope:			public action method
///	overrides:
/// description:	distributes the selected objects to equalize the vertical centres
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

- (IBAction)	distributeVerticalCentres:(id) sender
{
	#pragma unused(sender)
	
	if( ![self locked])
	{
		[self alignObjects:[self selectedAvailableObjects] withAlignment:kGCAlignmentAlignVDistribution];
		[[self undoManager] setActionName:NSLocalizedString(@"Distribute Vertically", @"undo string for distribute v centres")];
	}
}


///*********************************************************************************************************************
///
/// method:			distributeVerticalSpace:
/// scope:			public action method
///	overrides:
/// description:	distributes the selected objects to equalize the vertical space
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

- (IBAction)	distributeVerticalSpace:(id) sender
{
	#pragma unused(sender)
	
	if( ![self locked])
	{
		[self alignObjects:[self selectedAvailableObjects] withAlignment:kGCAlignmentAlignVSpaceDistribution];
		[[self undoManager] setActionName:NSLocalizedString(@"Distribute Vertical Space", @"undo string for distribute v space")];
	}
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			distributeHorizontalCentres:
/// scope:			public action method
///	overrides:
/// description:	distributes the selected objects to equalize the horizontal centres
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

- (IBAction)	distributeHorizontalCentres:(id) sender
{
	#pragma unused(sender)
	
	if( ![self locked])
	{
		[self alignObjects:[self selectedAvailableObjects] withAlignment:kGCAlignmentAlignHDistribution];
		[[self undoManager] setActionName:NSLocalizedString(@"Distribute Horizontally", @"undo string for distribute h centres")];
	}
}


///*********************************************************************************************************************
///
/// method:			distributeHorizontalSpace:
/// scope:			public action method
///	overrides:
/// description:	distributes the selected objects to equalize the horizontal space
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

- (IBAction)	distributeHorizontalSpace:(id) sender
{
	#pragma unused(sender)
	
	if( ![self locked])
	{
		[self alignObjects:[self selectedAvailableObjects] withAlignment:kGCAlignmentAlignHSpaceDistribution];
		[[self undoManager] setActionName:NSLocalizedString(@"Distribute Horizontal Space", @"undo string for distribute h space")];
	}
}


#pragma mark -
- (IBAction)	alignEdgesToGrid:(id) sender
{
	#pragma unused(sender)
	
	if( ![self locked])
	{
		DKGridLayer*	grid = [[self drawing] gridLayer];
		[self alignObjectEdges:[self selectedAvailableObjects] toGrid:grid];
		[[self undoManager] setActionName:NSLocalizedString(@"Align Edges To Grid", @"undo string for align edges to grid")];
	}
}


- (IBAction)	alignLocationToGrid:(id) sender
{
	#pragma unused(sender)
	
	if( ![self locked])
	{
		DKGridLayer*	grid = [[self drawing] gridLayer];
		[self alignObjectLocation:[self selectedAvailableObjects] toGrid:grid];
		[[self undoManager] setActionName:NSLocalizedString(@"Align Objects To Grid", @"undo string for align objects to grid")];
	}
}


@end


#pragma mark -
#pragma mark Static Functions
///*********************************************************************************************************************
///
/// method:			vertLocSortFunc()
/// scope:			static function
///	overrides:
/// description:	determines the relative vertical position order of a pair of objects
/// 
/// parameters:		<a>, <b> the objects to compare
/// result:			sort order constant
///
/// notes:			objects must respond to the -apparentBounds method
///
///********************************************************************************************************************

static int vertLocSortFunc( id a, id b, void* context )
{
	#pragma unused(context)
	
	float   ya, yb;
	
	//ya = NSMidY( [a apparentBounds] );
	//yb = NSMidY( [b apparentBounds] );
	
	ya = [(DKDrawableObject*)a location].y;
	yb = [(DKDrawableObject*)b location].y;
	
	if ( ya < yb )
		return NSOrderedAscending;
	else if ( ya > yb )
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}


///*********************************************************************************************************************
///
/// method:			horizLocSortFunc()
/// scope:			static function
///	overrides:
/// description:	determines the relative horizontal position order of a pair of objects
/// 
/// parameters:		<a>, <b> the objects to compare
/// result:			sort order constant
///
/// notes:			objects must respond to the -apparentBounds method
///
///********************************************************************************************************************

static int horizLocSortFunc( id a, id b, void* context )
{
	#pragma unused(context)
	
	float   xa, xb;
	
	xa = [(DKDrawableObject*)a location].x;	//NSMidX( [a apparentBounds] );
	xb = [(DKDrawableObject*)b location].x;	//NSMidX( [b apparentBounds] );
	
	if ( xa < xb )
		return NSOrderedAscending;
	else if ( xa > xb )
		return NSOrderedDescending;
	else
		return NSOrderedSame;
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			calculateAlignmentOffset()
/// scope:			internal function
///	overrides:
/// description:	returns an offset indicating the distance sr needs to be moved to give the chosen alignment with mr
/// 
/// parameters:		<mr>, <sr> two bounding rectangles
///					<alignment> the type of alignment being applied
/// result:			an x and y offset
///
/// notes:			
///
///********************************************************************************************************************

NSPoint calculateAlignmentOffset( NSRect mr, NSRect sr, int alignment )
{
	NSPoint p = { 0, 0 };
	
	if ( alignment & kGCAlignmentAlignLeftEdge )
		p.x = NSMinX( mr ) - NSMinX( sr );
		
	if ( alignment & kGCAlignmentAlignTopEdge )
		p.y = NSMinY( mr ) - NSMinY( sr );
		
	if ( alignment & kGCAlignmentAlignRightEdge )
		p.x = NSMaxX( mr ) - NSMaxX( sr );
		
	if ( alignment & kGCAlignmentAlignBottomEdge )
		p.y = NSMaxY( mr ) - NSMaxY( sr );
		
	if ( alignment & kGCAlignmentAlignVerticalCentre )
		p.y = NSMidY( mr ) - NSMidY( sr );
		
	if ( alignment & kGCAlignmentAlignHorizontalCentre )
		p.x = NSMidX( mr ) - NSMidX( sr );

	return p;
}

