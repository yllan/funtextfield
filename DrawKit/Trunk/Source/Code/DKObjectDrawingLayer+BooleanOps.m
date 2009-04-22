///**********************************************************************************************************************************
///  DKObjectDrawingLayer+BooleanOps.m
///  DrawKit
///
///  Created by graham on 03/11/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#ifdef qUseGPC

#import "DKObjectDrawingLayer+BooleanOps.h"

#import "DKDrawablePath.h"
#import "DKDrawableShape.h"
#import "NSBezierPath+GPC.h"


@implementation DKObjectDrawingLayer (BooleanOps)
#pragma mark As a DKObjectDrawingLayer
///*********************************************************************************************************************
///
/// method:			unionSelectedObjects:
/// scope:			public action method
///	overrides:
/// description:	forms the union of the selected objects and replaces the selection with the result
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			result adopts the style of the topmost object contributing.
///
///********************************************************************************************************************

- (IBAction)		unionSelectedObjects:(id) sender
{
	#pragma unused(sender)
	
	NSArray*			sel = [self selectedAvailableObjects];
	NSEnumerator*		iter = [sel objectEnumerator];
	DKDrawableShape*	obj;
	DKDrawableShape*	result;
	NSBezierPath*		rp = nil;
	
	// at least 2 objects required:
	
	if([sel count] < 2)
		return;
	
	while(( obj = [iter nextObject]))
	{
		// if the object is a path, convert it to a shape first
		
		if([obj isKindOfClass:[DKDrawablePath class]])
			obj = [(DKDrawablePath*)obj makeShape];
	
		// if result path is nil, this is the first object which is the one we'll keep unioning.
	
		if ( rp == nil )
			rp = [obj transformedPath];
		else
			rp = [rp pathFromUnionWithPath:[obj transformedPath]];
	}
	
	// make a new shape from the result path, inheriting style of the topmost object
	
	result = [DKDrawableShape drawableShapeWithPath:rp];
	[result setStyle:(DKStyle*)[[sel lastObject] style]];
	
	int xi = [self indexOfObject:[sel lastObject]];
	
	// remove the old shapes/paths from the layer, add the new shape and change the selection to it
	
	[self recordSelectionForUndo];
	[self addObject:result atIndex:xi];
	[self removeObjects:sel];
	[self replaceSelectionWithObject:result];
	[self commitSelectionUndoWithActionName:NSLocalizedString(@"Union", @"undo string for union op")];
}


///*********************************************************************************************************************
///
/// method:			diffSelectedObjects:
/// scope:			public action method
///	overrides:
/// description:	subtracts the topmost shape from the other.
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			requires exactly two contributing objects. If the shapes don't overlap, this does nothing. The
///					'cutter' object is removed from the layer.
///
///********************************************************************************************************************

- (IBAction)		diffSelectedObjects:(id) sender
{
	#pragma unused(sender)
	
	NSArray*	sel = [self selectedAvailableObjects];
	
	if ([sel count] == 2 )
	{
		DKDrawableShape		*a, *b;
		NSBezierPath*		rp;
		
		// get the objects in shape form
		
		a = [sel objectAtIndex:0];
		
		if ([a isKindOfClass:[DKDrawablePath class]])
			a = [(DKDrawablePath*)a makeShape];
		
		b = [sel objectAtIndex:1];

		if ([b isKindOfClass:[DKDrawablePath class]])
			b = [(DKDrawablePath*)b makeShape];
			
		// form the result
	
		rp = [[a transformedPath] pathFromDifferenceWithPath:[b transformedPath]];
		
		// if the result is not empty, turn it into a new shape
		
		if (! [rp isEmpty])
		{
			// if the original was a path, keep it as a path
			
			if([[sel objectAtIndex:0] isKindOfClass:[DKDrawablePath class]])
				[(DKDrawablePath*)[sel objectAtIndex:0] setPath:rp];
			else
				[a adoptPath:rp];
			
			[self recordSelectionForUndo];
			
			[self removeObject:[sel objectAtIndex:1]]; // if you wish to leave the "cutter" in the layer, remove this line
			
			[self replaceSelectionWithObject:[sel objectAtIndex:0]];
			[self commitSelectionUndoWithActionName:NSLocalizedString(@"Difference", @"undo string for diff op")];
		}
	}
}


///*********************************************************************************************************************
///
/// method:			intersectionSelectedObjects:
/// scope:			public action method
///	overrides:
/// description:	replaces a pair of objects by their intersection.
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			requires exactly two contributing objects. If the objects don't intersect, does nothing. The result
///					adopts the syle of the topmost contributing object
///
///********************************************************************************************************************

- (IBAction)		intersectionSelectedObjects:(id) sender
{
	#pragma unused(sender)
	
	NSArray*	sel = [self selectedAvailableObjects];
	
	if ([sel count] == 2 )
	{
		DKDrawableShape		*a, *b;
		NSBezierPath*		rp;
		
		// get the objects in shape form
		
		a = [sel objectAtIndex:0];
		
		if ([a isKindOfClass:[DKDrawablePath class]])
			a = [(DKDrawablePath*)a makeShape];
		
		b = [sel objectAtIndex:1];

		if ([b isKindOfClass:[DKDrawablePath class]])
			b = [(DKDrawablePath*)b makeShape];
			
		// form the result
	
		rp = [[a transformedPath] pathFromIntersectionWithPath:[b transformedPath]];
		
		// if the result is not empty, turn it into a new shape
		
		if (! [rp isEmpty])
		{
			DKDrawableShape* shape = [DKDrawableShape drawableShapeWithPath:rp];
			
			[shape setStyle:(DKStyle*)[[sel objectAtIndex:1] style]];
			
			int xi = [self indexOfObject:[sel lastObject]];
			
			[self recordSelectionForUndo];
			[self addObject:shape atIndex:xi];
			[self removeObjects:sel];
			[self replaceSelectionWithObject:shape];
			[self commitSelectionUndoWithActionName:NSLocalizedString(@"Intersection", @"undo string for sect op")];
		}
	}
}


///*********************************************************************************************************************
///
/// method:			xorSelectedObjects:
/// scope:			public action method
///	overrides:
/// description:	replaces a pair of objects by their exclusive-OR.
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			requires exactly two contributing objects. If the objects don't intersect, does nothing. The result
///					adopts the syle of the topmost contributing object
///
///********************************************************************************************************************

- (IBAction)		xorSelectedObjects:(id) sender
{
	#pragma unused(sender)
	
	NSArray*	sel = [self selectedAvailableObjects];
	
	if ([sel count] == 2 )
	{
		DKDrawableShape		*a, *b;
		NSBezierPath*		rp;
		
		// get the objects in shape form
		
		a = [sel objectAtIndex:0];
		
		if ([a isKindOfClass:[DKDrawablePath class]])
			a = [(DKDrawablePath*)a makeShape];
		
		b = [sel objectAtIndex:1];

		if ([b isKindOfClass:[DKDrawablePath class]])
			b = [(DKDrawablePath*)b makeShape];
			
		// form the result
	
		rp = [[a transformedPath] pathFromExclusiveOrWithPath:[b transformedPath]];
		
		// if the result is not empty, turn it into a new shape
		
		if (! [rp isEmpty])
		{
			DKDrawableShape* shape = [DKDrawableShape drawableShapeWithPath:rp];
			
			[shape setStyle:[b style]];
			
			int xi = [self indexOfObject:[sel lastObject]];
			
			[self recordSelectionForUndo];
			[self addObject:shape atIndex:xi];
			[self removeObjects:sel];
			[self replaceSelectionWithObject:shape];
			[self commitSelectionUndoWithActionName:NSLocalizedString(@"Exclusive Or", @"undo string for xor op")];
		}
	}
}


///*********************************************************************************************************************
///
/// method:			combineSelectedObjects:
/// scope:			public action method
///	overrides:
/// description:	replaces a pair of objects by combining their paths.
/// 
/// parameters:		<sender> the action's sender
/// result:			none
///
/// notes:			requires two or more contributing objects. The result adopts the syle of the topmost
///					contributing object. The result can act like a union, difference or xor depending on the relative
///					disposition of the contributing paths.
///
///********************************************************************************************************************

- (IBAction)		combineSelectedObjects:(id) sender
{
	#pragma unused(sender)
	
	NSArray*	sel = [self selectedAvailableObjects];
	
	if ([sel count] > 1 )
	{
		DKDrawableObject*	o;
		NSBezierPath*		rp;
		NSBezierPath*		oPath;
		DKStyle*			style = nil;
		
		rp = [NSBezierPath bezierPath];
		NSEnumerator*		iter = [sel objectEnumerator];
		
		while(( o = [iter nextObject]))
		{
			if ([o isKindOfClass:[DKDrawablePath class]])
				oPath = [(DKDrawablePath*)o path];
			else
				oPath = [(DKDrawableShape*)o transformedPath];
		
			[rp appendBezierPath:oPath];
			
			if ( style == nil )
				style = [[o style] retain];
		}

		// form the result
		
		[rp setWindingRule:NSEvenOddWindingRule];
		
		// if the result is not empty, turn it into a new shape
		
		if (! [rp isEmpty])
		{
			DKDrawableShape* shape = [DKDrawableShape drawableShapeWithPath:rp];
			
			[shape setStyle:style];
			
			int xi = [self indexOfObject:[sel objectAtIndex:0]];
			
			[self recordSelectionForUndo];
			[self addObject:shape atIndex:xi];
			[self removeObjects:sel];
			[self replaceSelectionWithObject:shape];
			[self commitSelectionUndoWithActionName:NSLocalizedString(@"Combine Objects", @"undo string for combine op")];
		}
		
		[style release];
	}
}


- (IBAction)		setBooleanOpsFittingPolicy:(id) sender
{
	// sets the curve fitting policy for subsequent boolean operations.
	
	[NSBezierPath setPathUnflatteningPolicy:[sender tag]];
}


@end

#endif /* defined (qUseGPC) */
