///**********************************************************************************************************************************
///  DKDrawingView+Drop.m
///  DrawKit
///
///  Created by jason on 1/11/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKDrawingView+Drop.h"
#import "DKObjectOwnerLayer.h"

extern DKDrawingView*	sCurDView;



@implementation DKDrawingView (DropHandling)
#pragma mark As a DKDrawingView


///*********************************************************************************************************************
///
/// method:			activeLayer
/// scope:			public instance method
/// overrides:		
/// description:	returns the current active layer, by asking the controller for it
/// 
/// parameters:		none
/// result:			a layer, the one that is currently active
///
/// notes:			DKDrawing maintains the active layer - look there for a method to set it
///
///********************************************************************************************************************

- (DKLayer*)			activeLayer
{
	return [[self controller] activeLayer];
}


#pragma mark -
#pragma mark As part of NSDraggingDestination Protocol


///*********************************************************************************************************************
///
/// method:			draggingEntered
/// scope:			protocol method
/// overrides:		NSDraggingDestination
/// description:	a drag entered the view
/// 
/// parameters:		<sender> the drag sender
/// result:			a drag operation constant
///
/// notes:			
///
///********************************************************************************************************************

- (NSDragOperation)		draggingEntered:(id <NSDraggingInfo>)sender
{
	NSDragOperation result = NSDragOperationNone;
	
	if (![[self activeLayer] lockedOrHidden] && [[self activeLayer] respondsToSelector:@selector(draggingEntered:)])
	{
		sCurDView = self;
		result = [[self activeLayer] draggingEntered:sender];
		sCurDView = nil;
	}

	return result;
}


///*********************************************************************************************************************
///
/// method:			draggingUpdated
/// scope:			protocol method
/// overrides:		NSDraggingDestination
/// description:	a drag moved in the view
/// 
/// parameters:		<sender> the drag sender
/// result:			a drag operation constant
///
/// notes:			
///
///********************************************************************************************************************

- (NSDragOperation)		draggingUpdated:(id <NSDraggingInfo>)sender
{
	NSDragOperation result = NSDragOperationNone;
	
	if (![[self activeLayer] lockedOrHidden] && [[self activeLayer] respondsToSelector:@selector(draggingUpdated:)])
	{
		sCurDView = self;
		result = [[self activeLayer] draggingUpdated:sender];
		sCurDView = nil;
	}

	return result;
}


///*********************************************************************************************************************
///
/// method:			draggingExited
/// scope:			protocol method
/// overrides:		NSDraggingDestination
/// description:	a drag left the view
/// 
/// parameters:		<sender> the drag sender
/// result:			a drag operation constant
///
/// notes:			
///
///********************************************************************************************************************

- (void)				draggingExited:(id <NSDraggingInfo>) sender
{
	if (![[self activeLayer] lockedOrHidden] && [[self activeLayer] respondsToSelector:@selector(draggingExited:)])
	{
		sCurDView = self;
		[[self activeLayer] draggingExited:sender];
		sCurDView = nil;
	}
}


#pragma mark -


///*********************************************************************************************************************
///
/// method:			wantsPeriodicDraggingUpdates
/// scope:			protocol method
/// overrides:		NSDraggingDestination
/// description:	queries whether the active layer wantes periodic drag updates
/// 
/// parameters:		none
/// result:			YES if perodic update are wanted, NO otherwise
///
/// notes:			a layer implementing the NSDraggingDestination protocol should return the desired flag
///
///********************************************************************************************************************

- (BOOL)				wantsPeriodicDraggingUpdates
{
	BOOL result = NO;
	
	if (![[self activeLayer] lockedOrHidden] && [[self activeLayer] respondsToSelector:@selector(wantsPeriodicDraggingUpdates)])
	{
		sCurDView = self;
		result = [[self activeLayer] wantsPeriodicDraggingUpdates];
		sCurDView = nil;
	}

	return result;
}


#pragma mark -

///*********************************************************************************************************************
///
/// method:			performDragOperation
/// scope:			protocol method
/// overrides:		NSDraggingDestination
/// description:	perform the drop at the end of a drag
/// 
/// parameters:		<sender> the sender of the drag
/// result:			YES if the drop was handled, NO otherwise
///
/// notes:			
///
///********************************************************************************************************************

- (BOOL)				performDragOperation:(id <NSDraggingInfo>) sender
{
	BOOL result = NO;
	
	if (![[self activeLayer] lockedOrHidden] && [[self activeLayer] respondsToSelector:@selector(performDragOperation:)])
	{
		sCurDView = self;
		result = [[self activeLayer] performDragOperation:sender];
		sCurDView = nil;
	}

	return result;
}


///*********************************************************************************************************************
///
/// method:			prepareForDragOperation
/// scope:			protocol method
/// overrides:		NSDraggingDestination
/// description:	a drop is about to be performed, so get ready
/// 
/// parameters:		<sender> the sender of the drag
/// result:			YES if the drop will be handled, NO otherwise
///
/// notes:			
///
///********************************************************************************************************************

- (BOOL)				prepareForDragOperation:(id <NSDraggingInfo>) sender
{
	BOOL result = NO;
	
	if (![[self activeLayer] lockedOrHidden] && [[self activeLayer] respondsToSelector:@selector(prepareForDragOperation:)])
	{
		sCurDView = self;
		result = [[self activeLayer] prepareForDragOperation:sender];
		sCurDView = nil;
	}

	return result;
}


///*********************************************************************************************************************
///
/// method:			concludeDragOperation
/// scope:			protocol method
/// overrides:		NSDraggingDestination
/// description:	a drop was performed, so perform any final clean-up
/// 
/// parameters:		<sender> the sender of the drag
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

- (void)				concludeDragOperation:(id <NSDraggingInfo>) sender
{
	if (![[self activeLayer] lockedOrHidden] && [[self activeLayer] respondsToSelector:@selector(concludeDragOperation:)])
	{
		sCurDView = self;
		[[self activeLayer] concludeDragOperation:sender];
		sCurDView = nil;
	}
}


@end


