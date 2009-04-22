///**********************************************************************************************************************************
///  GCDrawDemoDocument+TimelineLayout.m
///  GCDrawKit
///
///  Created by graham on 07/07/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "GCDrawDemoDocument+TimelineLayout.h"

#import <GCDrawKit/DKObjectDrawingLayer.h>
#import <GCDrawKit/DKDrawableObject+Metadata.h>
#import <GCDrawKit/DKGridLayer.h>
#import <GCDrawKit/DKDrawing.h>
#import <GCDrawKit/DKDrawablePath.h>
#import <GCDrawKit/DKStyle.h>
#import <GCDrawKit/DKTextShape.h>
#import <GCDrawKit/LogEvent.h>


#pragma mark Static Functions
static int metaDataSortFunction( id a, id b, void* context)
{
	// context is NSString key of metadata item to compare
	
	id na;
	id nb;
	
	na = [a metadataObjectForKey:(NSString*) context];
	nb = [b metadataObjectForKey:(NSString*) context];

	return [na compare:nb];
}


#pragma mark -
@implementation GCDrawDemoDocument (TimelineLayout)
#pragma mark As a GCDrawDemoDocument

- (void)		performTimelineLayoutWithLayer:(DKObjectDrawingLayer*) layer showAsYouGo:(BOOL) showIt
{
	// this function is an experiment to illustrate the kinds of automatic functionality you can easily create using the
	// drawkit. This makes the following assumptions:
	
	// 1. that there exists in the drawing (text) objects occupying a rectangular area containing metadata "year" and an integer value.
	// 2. that the drawing scale/grid is set up such that a linear timeline of integral years is available horizontally
	
	// what it does is this: it first finds all such objects having metadata "year" key. Then it sorts them into chronological
	// order by year. Then it assigns a position to them in the drawing where the horizontal position is set to the year (plus a
	// small "leader" offet) and the vertical position is calculated to avoid colliding with any labels already laid down and
	// in such a vertical order that the leader lines do not cross over.
	
	// first locate the candidate objects:
	
	NSMutableArray*		tlObjects;
	NSEnumerator*		iter = [[layer availableObjects] objectEnumerator];
	DKDrawableObject*	obj;
	static float		lowestEdge = -10000;

	tlObjects = [NSMutableArray array];
	
	while( (obj = [iter nextObject]) != nil)
	{
		// does this object have a metadata item "year"?
		
		if ([obj hasMetadataForKey:@"year"])
		{
			[tlObjects addObject:obj];
			
			// make a note of the lowest edge found among these objects - it will be used as the starting point for
			// applying the vertical location.
			
			NSPoint loc = [obj location];
			
			if ( loc.y > lowestEdge )
				lowestEdge = loc.y;
		}
	}
	
//	LogEvent_(kReactiveEvent, @"found %d eligible objects. Bottom edge = %f", [tlObjects count], lowestEdge);
	
	if ([tlObjects count] < 1 )
		return;		// nothing to do

	// sort the objects into chronological order:
	
	[tlObjects sortUsingFunction:metaDataSortFunction context:@"year"];
	
	// next, remove all the existing leader lines (we recreate them as we lay out the labels). Note - this will not work when
	// reloading the drawing from a file, as the style object is not literally the same. TO DO: fix this.
	
	NSArray* leaderLines = [layer objectsWithStyle:[self leaderLineStyle]];
	if ( leaderLines && [leaderLines count] > 0 )
		[layer removeObjects:leaderLines];

	// now lay out the labels. This iterates in reverse since labels extend to the right (i.e into the future) so the non-crossing
	// criterion is simply met by performing the layout right to left.
	
	iter = [tlObjects reverseObjectEnumerator];
	
	// we need the grid to locate objects in time and space
	
	DKGridLayer* grid = [[self drawing] gridLayer];
	
	// indx tracks the location of the next object ahead of the one we are laying out
	
	unsigned			indx = [tlObjects count], j;
	int					year;
	NSPoint				position;
	NSRect				objRect, colObjRect;
	float				gridVIncrement;
	DKDrawableObject*	colObj;
	DKDrawablePath*		leader;
	NSPoint				lp1, lp2;
	
	gridVIncrement = [grid divisionDistance].y;
	
	while( (obj = [iter nextObject]) != nil)
	{
		// place the object's horizontal position based on the "year" value. To make this easier we also offset the
		// "loc" of the object relative to its top, left corner:
		
		[obj setOffset:NSMakeSize( -0.5, -0.5 )];
		year = [[obj metadataObjectForKey:@"year"] intValue];
		
		// use the grid to figure the real position:
		
		position.x = (float) year;
		position.y = 0;
		position = [grid pointForGridLocation:position];
		
		// this is the candidate location (x will not change), but we shift it upwards vertically to avoid collision with any other
		// already laid objects. To allow a neat layout, we test in grid increments
		
		//[(GCTextShape*)obj sizeVerticallyToFitText];
		objRect.size = [obj size];
		
		// if the size is less than 4 grid units high, make it at least that high
		
		if ( objRect.size.height < ( gridVIncrement * 4 ))
		{
			objRect.size.height = gridVIncrement * 4;
			[obj setSize:objRect.size];
		}
		else if ( objRect.size.height > ( gridVIncrement * 4 ))
		{
			// make sure we are either exactly at 4 grid spaces, or 6 for 2-line labels
			
			float rem = fmodf( objRect.size.height, gridVIncrement );
		
			objRect.size.height -= rem;
			
			if ( objRect.size.height > ( gridVIncrement * 4 ))
				objRect.size.height = gridVIncrement * 6;
			[obj setSize:objRect.size];
		}
		
		position.y = lowestEdge - objRect.size.height;
		
		// position one grid square to the right:
		
		position.x += gridVIncrement;
		
		// allow a grid square's space around the label:
		
		objRect.size.height += gridVIncrement;
		objRect.size.width += gridVIncrement;
		objRect.origin = position;
		
		// reposition to avoid collision:

		j = indx;
		
		while( j < [tlObjects count])
		{
			colObj = [tlObjects objectAtIndex:j];
			
			colObjRect.origin = [colObj location];
			colObjRect.size = [colObj size];
			
			// if this object is beyond the x range of our object, we can jump out now since there
			// is no more beyond j worth testing against
			
			if ( colObjRect.origin.x > NSMaxX( objRect ))
				break;
			
			if ( NSIntersectsRect( objRect, colObjRect ))
			{
				// they collide, so try incrementing the vertical position and starting again
				
				objRect.origin.y -= gridVIncrement;
				j = indx;
			}
			else
			{
				// they don't collide, so try the next in sequence.
				
				++j;
			}
		}
		
		// the object is now positioned so that it doesn't collide, so place it here
		
		position.y = objRect.origin.y;
		[obj moveToPoint:position];
		[(DKTextShape*)obj setVerticalAlignment:kGCTextShapeVerticalAlignmentCentre];
		
	//	LogEvent_(kReactiveEvent, @"laid object %@ at position {%.2f,%.2f}", obj, position.x, position.y );
		
		// now create a leader line which links this label with the timeline vertical datum
		
		lp1.x = position.x - gridVIncrement;
		lp1.y = lowestEdge + ( gridVIncrement * 3 );
		lp2.x = objRect.origin.x;
		objRect.size.height -= gridVIncrement;
		lp2.y = NSMidY( objRect );
		
		leader = [self leaderLineFromPoint:lp1 toPoint:lp2];
		[layer addObject:leader];
		[layer moveObjectToBottom:leader];
		
		if ( showIt )
		{
			[[self drawing] scrollToRect:objRect];
			[[self windowForSheet] displayIfNeeded];
		}
		
		// one more to check against next time
	
		--indx;
	}
}


#pragma mark -
- (DKDrawablePath*)		leaderLineFromPoint:(NSPoint) p1 toPoint:(NSPoint) p2
{
	DKDrawablePath* leader = [DKDrawablePath drawablePathWithPath:[self leaderLinePathFromPoint:p1 toPoint:p2]];
	
	[leader setStyle:[self leaderLineStyle]];
	return leader;
}


- (NSBezierPath*)		leaderLinePathFromPoint:(NSPoint) p1 toPoint:(NSPoint) p2
{
	// return a L-shaped path from p1 to p2. the path extends vertically, then horizontally.
	
	NSBezierPath*	path = [NSBezierPath bezierPath];
	NSPoint			pp;
	
	pp.x = p1.x;
	pp.y = p2.y;
	
	[path moveToPoint:p1];
	[path lineToPoint:pp];
	[path lineToPoint:p2];
	
	return path;
}


- (DKStyle*)		leaderLineStyle
{
	static DKStyle*	style = nil;
	
	// set the style to something appropriate:
	
	if ( style == nil )
	{
		style = [[DKStyle styleWithScript:@"(style (stroke 0.5 gray))"] retain];
		[style setStyleSharable:YES];
	}
				
	return style;
}


#pragma mark -
- (IBAction)	timelineAction:(id) sender
{
#pragma unused (sender)
	// locate the active layer and do the timeline layout on it
	
	DKObjectDrawingLayer* odl = [[self drawing] activeLayerOfClass:[DKObjectDrawingLayer class]];
	
	if ( odl )
		[self performTimelineLayoutWithLayer:odl showAsYouGo:YES];
}


@end
