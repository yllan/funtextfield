//
//  NSObject+StringValue.m
//  GCDrawKit
//
//  Created by graham on 03/04/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import "NSObject+StringValue.h"
#import "NSColor+DKAdditions.h"

@implementation NSObject (StringValue)

- (NSString*)	stringValue
{
	return NSStringFromClass([self class]);
}


- (NSString*)	address
{
	return [NSString stringWithFormat:@"0x%X", self];
}

@end


@implementation NSValue (StringValue)

- (NSString*)	stringValue
{
	const char* objcType = [self objCType];
	int m = -1;
	
	m = strncmp( objcType, @encode(NSRect), strlen( objcType ));
	
	if ( m == 0 )
		return NSStringFromRect([self rectValue]);
		
	m = strncmp( objcType, @encode(NSPoint), strlen( objcType ));
	
	if ( m == 0 )
		return NSStringFromPoint([self pointValue]);
		
	m = strncmp( objcType, @encode(NSSize), strlen( objcType ));
	
	if ( m == 0 )
		return NSStringFromSize([self sizeValue]);
		
	m = strncmp( objcType, @encode(NSRange), strlen( objcType ));
	
	if ( m == 0 )
		return NSStringFromRange([self rangeValue]);
		
	return nil;
}


@end


@implementation NSColor (StringValue)

- (NSString*)	stringValue
{
	return [self hexString];
}

@end


@implementation NSArray (StringValue)

- (NSString*)	stringValue
{
	NSMutableString*	sv = [[NSMutableString alloc] init];
	unsigned			i;
	id					object;
	
	for( i = 0; i < [self count]; ++i )
	{
		object = [self objectAtIndex:i];
		[sv appendString:[NSString stringWithFormat:@"%d: %@\n", i, [object stringValue]]];
	}
	
	if ([sv length] > 0)
		[sv deleteCharactersInRange:NSMakeRange([sv length] - 1, 1)];

	return [sv autorelease];
}

@end


@implementation NSDictionary (StringValue)

- (NSString*)	stringValue
{
	NSMutableString*	sv = [[NSMutableString alloc] init];
	id					object;
	id					key;
	NSEnumerator*		iter = [[self allKeys] objectEnumerator];
	
	while(( key = [iter nextObject]))
	{
		object = [self objectForKey:key];
		[sv appendString:[NSString stringWithFormat:@"%@: %@\n", key, [object stringValue]]];
	}
	
	if ([sv length] > 0)
		[sv deleteCharactersInRange:NSMakeRange([sv length] - 1, 1)];

	return [sv autorelease];
}

@end


@implementation NSSet (StringValue)

- (NSString*)	stringValue
{
	NSMutableString*	sv = [[NSMutableString alloc] init];
	id					object;
	NSEnumerator*		iter = [self objectEnumerator];
	
	while(( object = [iter nextObject]))
	{
		[sv appendString:[NSString stringWithFormat:@"%@\n", [object stringValue]]];
	}
	
	if ([sv length] > 0)
		[sv deleteCharactersInRange:NSMakeRange([sv length] - 1, 1)];

	return [sv autorelease];
}

@end



@implementation NSString (StringValue)

- (NSString*)	stringValue
{
	return self;
}

@end


@implementation NSDate (StringValue)

- (NSString*)	stringValue
{
	return [self description];
}


@end

