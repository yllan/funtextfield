///**********************************************************************************************************************************
///  NSDictionary+DeepCopy.h
///  DrawKit
///
///  Created by graham on 12/11/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>


@interface NSDictionary (DeepCopy)

- (NSDictionary*)		deepCopy;

@end


@interface NSArray (DeepCopy)

- (NSArray*)			deepCopy;

@end


@interface NSObject (DeepCopy)

- (id)					deepCopy;

@end





/*

implements a deep copy of a dictionary and array. The keys are unchanged but each object is copied.

if the dictionary contains another dictionary or an array, it is also deep copied.

to retain the semantics of a normal copy, the object returned is not autoreleased.




*/

