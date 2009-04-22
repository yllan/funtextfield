///**********************************************************************************************************************************
///  DKObjectDrawingLayer+BooleanOps.h
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

#import "DKObjectDrawingLayer.h"


@interface DKObjectDrawingLayer (BooleanOps)

- (IBAction)		unionSelectedObjects:(id) sender;
- (IBAction)		diffSelectedObjects:(id) sender;
- (IBAction)		intersectionSelectedObjects:(id) sender;
- (IBAction)		xorSelectedObjects:(id) sender;
- (IBAction)		combineSelectedObjects:(id) sender;
- (IBAction)		setBooleanOpsFittingPolicy:(id) sender;

@end




/*

This category provides high-level Boolean Operation commands for a drawing layer. It requires the
NSBezierPath+GPC category to function.

The operations here are user-level ops, and can be simply hooked to menu commands. The operations proceed as follows:

Union:

Two or more objects in the selection are replaced by a single shape object whose path is the union of all the selected object's paths.
Path objects are converted to shape objects prior to forming the union. The result object does not preserve the rotation angle
of the original objects. The result inherits the style of the topmost object. The result is always a shape even if some or all
of the contributing objects are paths.

Difference:

Exactly two objects must be in the selection. The shape or path that is topmost is unchanged, but acts as a "cookie cutter"
for the other object, which is replaced by the result. The result inherits the style and type of the object it replaces.
Rotation angle is preserved for shapes.

Intersection:

Exactly two objects must be in the selection. Path objects are converted to shape objects before computing the intersection.
The original objects are replaced by the intersection unless the intersection is empty, in which case this is a no-op. The
result inherits the style of the topmost original object. Rotation angle is not preserved; the result is always a shape even if
one or both of the operands is a path object.

Xor:

As for intersection.

Combine:

Two or more objects must be in the selection. Appends each path to the lowest one using appendBezierPath. The result is like an Xor
or a union, depending on the disposition of the paths. The advantage of this is that no path flattening is required.

Note that the design choices here about what type the result is, how stacking order affects the result, and so forth are intended
to provide the most natural and obvious outcomes for a typical drawing type program. That's why these operations must be considered
high level. If you want to implement some other behaviour built from boolean operations on paths, you have every freedom to do so,
since the code this calls operates purely at the abstract NSBezierPath level.

*/

#endif /* defined (qUseGPC) */
