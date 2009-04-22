///**********************************************************************************************************************************
///  DKObjectDrawingLayer+Alignment.h
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

#import "DKObjectDrawingLayer.h"


@class DKGridLayer;


enum
{
	kGCAlignmentLeftEdge				= 0,
	kGCAlignmentTopEdge					= 1,
	kGCAlignmentRightEdge				= 2,
	kGCAlignmentBottomEdge				= 3,
	kGCAlignmentVerticalCentre			= 4,
	kGCAlignmentHorizontalCentre		= 5,
	kGCAlignmentVerticalDistribution	= 6,
	kGCAlignmentHorizontalDistribution  = 7,
	kGCAlignmentVSpaceDistribution		= 8,
	kGCAlignmentHSpaceDistribution		= 9,
	
	kGCAlignmentAlignLeftEdge			= ( 1 << kGCAlignmentLeftEdge ),
	kGCAlignmentAlignTopEdge			= ( 1 << kGCAlignmentTopEdge ),
	kGCAlignmentAlignRightEdge			= ( 1 << kGCAlignmentRightEdge ),
	kGCAlignmentAlignBottomEdge			= ( 1 << kGCAlignmentBottomEdge ),
	kGCAlignmentAlignVerticalCentre		= ( 1 << kGCAlignmentVerticalCentre ),
	kGCAlignmentAlignHorizontalCentre	= ( 1 << kGCAlignmentHorizontalCentre ),
	kGCAlignmentAlignVDistribution		= ( 1 << kGCAlignmentVerticalDistribution ),
	kGCAlignmentAlignHDistribution		= ( 1 << kGCAlignmentHorizontalDistribution ),
	kGCAlignmentAlignVSpaceDistribution = ( 1 << kGCAlignmentVSpaceDistribution ),
	kGCAlignmentAlignHSpaceDistribution = ( 1 << kGCAlignmentHSpaceDistribution ),
	
	kGCAlignmentAlignNone				= 0,
	kGCAlignmentAlignColocate			= kGCAlignmentAlignVerticalCentre | kGCAlignmentAlignHorizontalCentre,
	kGCAlignmentHorizontalAlignMask		= kGCAlignmentAlignLeftEdge | kGCAlignmentAlignRightEdge | kGCAlignmentAlignHorizontalCentre | kGCAlignmentAlignHDistribution | kGCAlignmentAlignHSpaceDistribution,
	kGCAlignmentVerticalAlignMask		= kGCAlignmentAlignTopEdge | kGCAlignmentAlignBottomEdge | kGCAlignmentAlignVerticalCentre | kGCAlignmentAlignVDistribution | kGCAlignmentAlignVSpaceDistribution,
	kGCAlignmentDistributionMask		= kGCAlignmentAlignVDistribution | kGCAlignmentAlignHDistribution | kGCAlignmentAlignVSpaceDistribution | kGCAlignmentAlignHSpaceDistribution
};


@interface DKObjectDrawingLayer (Alignment)

- (void)		alignObjects:(NSArray*) objects withAlignment:(int) align;
- (void)		alignObjects:(NSArray*) objects toMasterObject:(id) object withAlignment:(int) align;
- (void)		alignObjects:(NSArray*) objects toLocation:(NSPoint) loc withAlignment:(int) align;

- (void)		alignObjectEdges:(NSArray*) objects toGrid:(DKGridLayer*) grid;
- (void)		alignObjectLocation:(NSArray*) objects toGrid:(DKGridLayer*) grid;

- (float)		totalVerticalSpace:(NSArray*) objects;
- (float)		totalHorizontalSpace:(NSArray*) objects;

- (NSArray*)	objectsSortedByVerticalPosition:(NSArray*) objects;
- (NSArray*)	objectsSortedByHorizontalPosition:(NSArray*) objects;

- (BOOL)		distributeObjects:(NSArray*) objects withAlignment:(int) align;

- (int)			alignmentMenuItemRequiredObjects:(NSMenuItem*) item;

// user actions:

- (IBAction)	alignLeftEdges:(id) sender;
- (IBAction)	alignRightEdges:(id) sender;
- (IBAction)	alignHorizontalCentres:(id) sender;

- (IBAction)	alignTopEdges:(id) sender;
- (IBAction)	alignBottomEdges:(id) sender;
- (IBAction)	alignVerticalCentres:(id) sender;

- (IBAction)	distributeVerticalCentres:(id) sender;
- (IBAction)	distributeVerticalSpace:(id) sender;

- (IBAction)	distributeHorizontalCentres:(id) sender;
- (IBAction)	distributeHorizontalSpace:(id) sender;

- (IBAction)	alignEdgesToGrid:(id) sender;
- (IBAction)	alignLocationToGrid:(id) sender;

@end

// alignment helper function:

NSPoint		calculateAlignmentOffset( NSRect mr, NSRect sr, int alignment );

/*

 This category implements object alignment features for DKObjectDrawingLayer

*/
