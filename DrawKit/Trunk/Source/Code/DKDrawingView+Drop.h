///**********************************************************************************************************************************
///  DKDrawingView+Drop.h
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

#import "DKDrawingView.h"


@interface DKDrawingView (DropHandling)

- (DKLayer*)			activeLayer;

@end



/*

Drag and Drop is extended down to the layer level by this category. When a layer is made active, the drawing view will register its
pasteboard types (because this registration must be performed by an NSView). Subsequently all drag/drop destination messages are
forwarded to the active layer, so the layer merely needs to implement those parts of the NSDraggingDestination protocol that it
is interested in, just as if it were a view. The layer can use [self currentView] if it needs to access the real view object.

Note that if the layer is locked or hidden, drag messages are not forwarded, so the layer does not need to implement this
check itself.

The default responses to the dragging destination calls are NSDragOperationNone, etc. This means that the layer MUST
correctly implement the protocol to its requirements, and not just "hope for the best".


*/
