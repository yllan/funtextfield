///**********************************************************************************************************************************
///  DKLayerGroup.h
///  DrawKit
///
///  Created by graham on 23/08/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKLayer.h"


@interface DKLayerGroup : DKLayer <NSCoding>
{
	NSMutableArray*			m_layers;
}

+ (DKLayerGroup*)			layerGroupWithLayers:(NSArray*) layers;

- (id)						initWithLayers:(NSArray*) layers;

// layer list

- (void)					setLayers:(NSArray*) layers;
- (NSArray*)				layers;
- (unsigned)				countOfLayers;
- (unsigned)				indexOfHighestOpaqueLayer;

// adding and removing layers

- (DKLayer*)				addNewLayerOfClass:(Class) layerClass;
- (void)					addLayer:(DKLayer*) aLayer;
- (void)					addLayer:(DKLayer*) aLayer aboveLayerIndex:(unsigned) layerIndex;
- (void)					insertLayer:(DKLayer*) aLayer atIndex:(unsigned) layerIndex;
- (void)					removeLayer:(DKLayer*) aLayer;
- (void)					removeLayerAtIndex:(unsigned) layerIndex;
- (void)					removeAllLayers;

// getting layers

- (DKLayer*)				layerAtIndex:(unsigned) layerIndex;
- (DKLayer*)				topLayer;
- (DKLayer*)				bottomLayer;
- (unsigned)				indexOfLayer:(DKLayer*) aLayer;
- (DKLayer*)				firstLayerOfClass:(Class) cl;
- (NSEnumerator*)			layerTopToBottomEnumerator;
- (NSEnumerator*)			layerBottomToTopEnumerator;

// layer stacking order

- (void)					moveUpLayer:(DKLayer*) aLayer;
- (void)					moveDownLayer:(DKLayer*) aLayer;
- (void)					moveLayerToTop:(DKLayer*) aLayer;
- (void)					moveLayerToBottom:(DKLayer*) aLayer;
- (void)					moveLayer:(DKLayer*) aLayer aboveLayer:(DKLayer*) otherLayer;
- (void)					moveLayer:(DKLayer*) aLayer belowLayer:(DKLayer*) otherLayer;
- (void)					moveLayer:(DKLayer*) aLayer toIndex:(unsigned) i;


@end


extern NSString*		kDKLayerGroupDidAddLayer;
extern NSString*		kDKLayerGroupDidRemoveLayer;
extern NSString*		kDKLayerGroupWillReorderLayers;
extern NSString*		kDKLayerGroupDidReorderLayers;


/*

A layer group is a layer which maintains a list of other layers. This permits layers to be organised hierarchically if
the application wishes to do so.

DKDrawing is a subclass of this, so it inherits the ability to maintain a list of layers. However it doesn't honour
every possible feature of a layer group, particularly those the group inherits from DKLayer. This is because
DKLayerGroup is actually a refactoring of DKDrawing and backward compatibility with existing files is required.

Layers placed into a group are still "owned" by the drawing and the back links to the drawing work as normal. Layers
can discover the group they belong to using the -group method - this is very likely to be the drawing.


The stacking order of layers is arranged so that the top layer always has the index zero, and the bottom is at (count -1).
In general your code should minimise its exposure to the actual layer index, but the reason that layers are stacked this
way is so that a layer UI such as a NSTableView doesn't have to do anything special to view layers in a natural way, with
the top layer at the top of such a table. Prior to beta 3, layers were stacked the other way so such tables appeared to
be upside-down. This class automatically reverses the stacking order in an archive if it detects an older version.

*/

