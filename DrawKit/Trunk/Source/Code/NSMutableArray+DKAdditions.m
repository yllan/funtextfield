//
//  NSArray+DKAdditions.m
//  DrawKit
//
//  Created by graham on 27/03/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import "NSMutableArray+DKAdditions.h"


@implementation NSMutableArray (DKAdditions)

- (void)				addUniqueObjectsFromArray:(NSArray*) array
{
	// adds objects from <array> to the receiver, but only those not already contained by it
	
	NSEnumerator*	iter = [array objectEnumerator];
	id				obj;
	
	while(( obj = [iter nextObject]))
	{
		if (! [self containsObject:obj])
			[self addObject:obj];
	}
}


@end

