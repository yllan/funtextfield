///**********************************************************************************************************************************
///  DKShapeGroup.h
///  DrawKit
///
///  Created by graham on 28/10/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKDrawableShape.h"


@class DKObjectDrawingLayer;


// caching options

typedef enum
{
	kDKGroupCacheNone			= 0,
	kDKGroupCacheUsingPDF		= ( 1 << 0 ),
	kDKGroupCacheUsingCGLayer	= ( 1 << 1 )
}
DKGroupCacheOption;



@interface DKShapeGroup : DKDrawableShape <NSCoding, NSCopying>
{
	NSArray*			m_objects;				// objects in the group
	BOOL				m_transformVisually;	// if YES, group transform is visual only (like SVG) otherwise it's genuine
	CGLayerRef			mContentCache;			// used to cache content
	NSPDFImageRep*		mPDFContentCache;		// used to cache content at higher quality
	DKGroupCacheOption	mCacheOption;			// caching options
	BOOL				mIsWritingToCache;		// YES when building cache - modifies transforms
}

// creating new groups:

+ (DKShapeGroup*)		groupWithBezierPaths:(NSArray*) paths objectType:(int) type style:(DKStyle*) style;
+ (DKShapeGroup*)		groupWithObjects:(NSArray*) objects;

// setting up the group:

- (id)					initWithObjectsInArray:(NSArray*) objects;

- (void)				setGroupObjects:(NSArray*) objects;
- (NSArray*)			groupObjects;
- (void)				calcBoundingRectOfObjects:(NSArray*) objects;
- (NSSize)				extraSpaceNeededByObjects:(NSArray*) objects;

- (void)				setObjects:(NSArray*) objects;

// drawing the group:

- (NSAffineTransform*)	contentTransform;
- (NSAffineTransform*)	renderingTransform;
- (NSPoint)				convertPointFromContainer:(NSPoint) p; 
- (NSPoint)				convertPointToContainer:(NSPoint) p; 
- (void)				drawGroupContent;

- (NSData*)				pdfDataOfObjects;

// caching:

- (void)				setCacheOptions:(DKGroupCacheOption) cacheOption;
- (DKGroupCacheOption)	cacheOptions;

// ungrouping:

- (void)				ungroupToLayer:(DKObjectDrawingLayer*) layer;
- (IBAction)			ungroupObjects:(id) sender;

@end

// constant that can be passed as <objectType> to groupWithBezierPaths:objectType:style:

enum
{
	kGCCreateGroupWithShapes		= 0,
	kGCCreateGroupWithPaths			= 1
};



/*

This is a group objects that can group any number of shapes or paths.

It inherits from DKDrawableShape so that it gets the usual sizing and rotation behaviours.

This operates by establishing its own coordinate system in which the objects are embedded. An informal protocol is used that allows a shape or
path to obtain the transform of its "parent". When that parent is a group, the transform is manipulated such that the path is modified just
prior to rendering to allow for the group's size, rotation, etc.

Be aware of one "gotcha" with this class - a bit of a chicken-and-egg situation. When objects are grouped, they are offset to be local to the group's
overall location. For grouping to be undoable, the objects being grouped need to have a valid container at the time this location offset is done,
so that there is an undo manager available to record that change. If not they might end up in the wrong place when undoing the "group" command.

For the normal case of grouping existing objects within a layer, this is not an issue, but can be if you are programmatically creating groups.

*/
