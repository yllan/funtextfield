///**********************************************************************************************************************************
///  DKObjectOwnerLayer.h
///  DrawKit
///
///  Created by graham on 21/11/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKLayer.h"


@class DKDrawableObject, DKStyle;


// caching options

typedef enum
{
	kDKLayerCacheNone			= 0,
	kDKLayerCacheUsingPDF		= ( 1 << 0 ),
	kDKLayerCacheUsingCGLayer	= ( 1 << 1 )
}
DKLayerCacheOption;



// the class


@interface DKObjectOwnerLayer : DKLayer <NSCoding>
{
	NSMutableArray*			m_objects;				// list of objects
	NSSize					m_pasteOffset;			// distance to offset a pasted object
	NSPoint					m_pasteAnchor;			// used when recording the paste/duplication offset
	BOOL					m_recordPasteOffset;	// set to YES following a paste, and NO following a drag. When YES, paste offset is recorded.
	BOOL					m_allowEditing;			// YES to allow editing of objects, NO to prevent
	BOOL					m_allowSnapToObjects;	// YES to let snapping look for other objects
	BOOL					m_inDragOp;				// YES if a drag is happening over the layer
	DKDrawableObject*		mNewObjectPending;		// temporary object being created - is drawn and handled as a normal object but can be deleted without undo
	DKLayerCacheOption		mLayerCachingOption;	// see constants defined above
	NSPDFImageRep*			mPDFCache;				// caches the layer's content as a PDF for better quality display when the layer is inactive
	CGLayerRef				mLayerContentCache;		// caches the layer's content for low quality fast display and displays it when the layer is inactive
	NSRect					mCacheBounds;			// the bounds rect of the cached layer or PDF rep - used to accurately position the cache when drawn
}

// as a container for a DKDrawableObject:

- (DKObjectOwnerLayer*)	layer;

// the list of objects:

- (void)				setObjects:(NSArray*) objs;
- (NSArray*)			objects;
- (NSArray*)			availableObjects;
- (NSArray*)			visibleObjects;
- (NSArray*)			objectsWithStyle:(DKStyle*) style;
- (NSArray*)			objectsReturning:(int) answer toSelector:(SEL) selector;

// getting objects:

- (int)					countOfObjects;
- (DKDrawableObject*)	objectAtIndex:(int) index;
- (DKDrawableObject*)	topObject;
- (DKDrawableObject*)	bottomObject;
- (int)					indexOfObject:(DKDrawableObject*) obj;

- (NSArray*)			objectsAtIndexesInSet:(NSIndexSet*) set;
- (NSIndexSet*)			indexSetForObjectsInArray:(NSArray*) objs;

// adding and removing objects:

- (void)				addObject:(DKDrawableObject*) obj;
- (void)				addObject:(DKDrawableObject*) obj atIndex:(int) index;
- (void)				addObjects:(NSArray*) objs;
- (void)				addObjects:(NSArray*) objs offsetByX:(float) dx byY:(float) dy;
- (void)				addObjects:(NSArray*) objs atIndexesInSet:(NSIndexSet*) set;

- (void)				removeObject:(DKDrawableObject*) obj;
- (void)				removeObjectAtIndex:(int) index;
- (void)				removeObjects:(NSArray*) objs;
- (void)				removeObjectsAtIndexesInSet:(NSIndexSet*) set;
- (void)				removeAllObjects;

- (NSEnumerator*)		objectTopToBottomEnumerator;
- (NSEnumerator*)		objectBottomToTopEnumerator;

// updating & drawing objects:

- (void)				drawable:(DKDrawableObject*) obj needsDisplayInRect:(NSRect) rect;
- (void)				drawVisibleObjects;
- (NSImage*)			imageOfObjects;
- (NSData*)				pdfDataOfObjects;

// pending object - used during interactive creation of new objects

- (void)				addObjectPendingCreation:(DKDrawableObject*) pend;
- (void)				removePendingObject;
- (void)				commitPendingObjectWithUndoActionName:(NSString*) actionName;
- (void)				drawPendingObjectInView:(NSView*) aView;

// geometry:

- (NSRect)				unionOfAllObjectBounds;
- (void)				refreshAllObjects;
- (NSAffineTransform*)	renderingTransform;

// stacking order:

- (void)				moveUpObject:(DKDrawableObject*) obj;
- (void)				moveDownObject:(DKDrawableObject*) obj;
- (void)				moveObjectToTop:(DKDrawableObject*) obj;
- (void)				moveObjectToBottom:(DKDrawableObject*) obj;
- (void)				moveObject:(DKDrawableObject*) obj toIndex:(int) i;

// clipboard ops:

- (NSArray*)			nativeObjectsFromPasteboard:(NSPasteboard*) pb;
- (void)				addObjects:(NSArray*) objects fromPasteboard:(NSPasteboard*) pb atDropLocation:(NSPoint) p;
- (void)				setPasteOffsetX:(float) x y:(float) y;

// hit testing:

- (DKDrawableObject*)	hitTest:(NSPoint) point;
- (DKDrawableObject*)	hitTest:(NSPoint) point partCode:(int*) part;
- (NSArray*)			objectsInRect:(NSRect) rect;

// snapping:

- (NSPoint)				snapPoint:(NSPoint) p toAnyObjectExcept:(DKDrawableObject*) except snapTolerance:(float) tol;
- (NSPoint)				snappedMousePoint:(NSPoint) mp forObject:(DKDrawableObject*) obj withControlFlag:(BOOL) snapControl;

// options:

- (void)				setAllowsEditing:(BOOL) editable;
- (BOOL)				allowsEditing;
- (void)				setAllowsSnapToObjects:(BOOL) snap;
- (BOOL)				allowsSnapToObjects;

- (void)				setLayerCacheOption:(DKLayerCacheOption) option;
- (DKLayerCacheOption)	layerCacheOption;

// user actions:

- (IBAction)			toggleSnapToObjects:(id) sender;

@end


extern NSString*		kGCDrawableObjectPasteboardType;
extern NSString*		kGCLayerDidReorderObjects;




/*

This layer class can be the owner of any number of DKDrawableObjects. It implements the ability to contain and render
these objects.

It does NOT support the concept of a selection, or of a list of selected objects (DKObjectDrawingLayer subclasses this to
provide that functionality).

This split between the owner/renderer layer and selection allows a more fine-grained opportunity to subclass for different
application needs.

Layer caching:

When a layer is NOT active, it may boost drawing performance to cache the layer's contents offscreen. This is especially beneficial
if you are using many layers. By setting the cache option, you can control how caching is done. If set to "none", objects
are never drawn using a cache, but simply drawn in the usual way. If "pdf", the cache is an NSPDFImageRep, which stores the image
as a PDF and so draws it at full vector quality at all zoom scales. If "CGLayer", an offscreen CGLayer is used which gives the
fastest rendering but will show pixellation at higher zooms. If both pdf and CGLayer are set, both caches will be created and
the CGLayer one used when DKDrawing has iits "low quality" hint set, and the PDF rep otherwise.

The cache is only used for screen drawing.

*/
