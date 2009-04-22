///**********************************************************************************************************************************
///  DKObjectDrawingLayer+Duplication.h
///  DrawKit
///
///  Created by graham on 22/06/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKObjectDrawingLayer.h"


@interface DKObjectDrawingLayer (Duplication)

- (NSArray*)	polarDuplicate:(NSArray*) objectsToDuplicate
				centre:(NSPoint) centre
				numberOfCopies:(int) nCopies
				incrementAngle:(float) incRadians
				rotateCopies:(BOOL) rotCopies;
				
- (NSArray*)	linearDuplicate:(NSArray*) objectsToDuplicate
				offset:(NSSize) offset
				numberOfCopies:(int) nCopies;
				
- (NSArray*)	autoPolarDuplicate:(DKDrawableObject*) object
				centre:(NSPoint) centre;
				
- (NSArray*)	concentricDuplicate:(NSArray*) objectsToDuplicate
				centre:(NSPoint) centre
				numberOfCopies:(int) nCopies
				insetBy:(float) inset;
				

@end



/*

Some handy methods for implementing various kinds of object duplications.





*/
