///**********************************************************************************************************************************
///  DKRastGroup.h
///  DrawKit
///
///  Created by graham on 17/03/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKRasterizer.h"


@class DKRastGroup;



@interface DKRastGroup : DKRasterizer <NSCoding, NSCopying>
{
	NSMutableArray*		m_renderList;
	BOOL				m_reverse;
}

+ (DKRastGroup*)		rasterizerGroupWithStyleScript:(NSString*) string;

- (void)				setRenderList:(NSArray*) list;
- (NSArray*)			renderList;

- (DKRastGroup*)		root;

- (void)				observableWasAdded:(GCObservableObject*) observable;
- (void)				observableWillBeRemoved:(GCObservableObject*) observable;
	
- (void)				addRenderer:(DKRasterizer*) renderer;
- (void)				removeRenderer:(DKRasterizer*) renderer;
- (void)				moveRendererAtIndex:(unsigned) src toIndex:(unsigned) dest;
- (void)				insertRenderer:(DKRasterizer*) renderer atIndex:(unsigned) index;
- (void)				removeRendererAtIndex:(unsigned) index;
- (unsigned)			indexOfRenderer:(DKRasterizer*) renderer;

- (DKRasterizer*)		rendererAtIndex:(unsigned) index;
- (DKRasterizer*)		rendererWithName:(NSString*) name;

- (void)				reverseRenderingOrder;
- (BOOL)				isRenderingOrderReversed;

- (unsigned)			countOfRenderList;
- (BOOL)				containsRendererOfClass:(Class) cl;
- (NSArray*)			renderersOfClass:(Class) cl;
	
- (BOOL)				isValid;

- (void)				removeAllRenderers;
- (void)				removeRenderersOfClass:(Class) cl inSubgroups:(BOOL) subs;

// KVO compliant variants of the render list management methods, key = "renderList"

- (id)					objectInRenderListAtIndex:(unsigned) indx;
- (void)				insertObject:(id) obj inRenderListAtIndex:(unsigned) index;
- (void)				removeObjectFromRenderListAtIndex:(unsigned) indx;




@end


/*

A rendergroup is a single renderer which contains a list of other renderers. Each renderer is applied to the object
in list order.

Because the group is itself a renderer, it can be added to other groups, etc to form complex trees of rendering
behaviour.

A group saves and restores the graphics state around all of its calls, so can also be used to "bracket" sets of
rendering operations together.

The rendering group is the basis for the more application-useful drawing style object.

Because DKRasterizer inherits from GCObservableObject, the group object supports a KVO-based approach for observing its
components. Whenever a component is added or removed from a group, the root object (typically a style) is informed through 
the observableWasAdded: observableWillBeRemoved: methods. If the root object is indeed interested in observing the object,
it should call its setUpKVOForObserver and tearDownKVOForObserver methods. Groups propagate these messages down the tree
as well, so the root object is given the opportunity to observe any component anywhere in the tree. Additionally, groups
themselves are observed for changes to their lists, so the root object is able to track changes to the group structure
as well.


*/
