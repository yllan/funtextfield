///**********************************************************************************************************************************
///  NSDictionary+DeepCopy.m
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

#import "NSDictionary+DeepCopy.h"


@implementation NSDictionary (DeepCopy)


- (NSDictionary*)		deepCopy
{
	NSMutableDictionary*	copy;
	NSEnumerator*			iter = [self keyEnumerator];
	id						key, cobj;
	
	copy = [[NSMutableDictionary alloc] init];
	
	while(( key = [iter nextObject]))
	{
		cobj = [[self objectForKey:key] deepCopy];
		[copy setObject:cobj forKey:key];
		[cobj release];
	}

	return copy;
}


@end


#pragma mark -
@implementation NSArray (DeepCopy)

- (NSArray*)			deepCopy
{
	NSMutableArray*			copy;
	NSEnumerator*			iter = [self objectEnumerator];
	id						obj, cobj;
	
	copy = [[NSMutableArray alloc] init];
	
	while(( obj = [iter nextObject]))
	{
		cobj = [obj deepCopy];
		[copy addObject:cobj];
		[cobj release];
	}

	return copy;
}


@end


#pragma mark -
@implementation NSObject (DeepCopy)

- (id)					deepCopy
{
	return [self copy];
}


@end
