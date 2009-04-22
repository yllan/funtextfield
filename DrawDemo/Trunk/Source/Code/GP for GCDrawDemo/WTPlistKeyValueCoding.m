//
//  WTPlistKeyValueCoding.m
//  GradientTest
//
//  Created by Jason Jobe on 4/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "WTPlistKeyValueCoding.h"

static id
WTKeyValueDecodeObject (id val)
{	
	if (val == nil)
		return nil;
	
	if ([val isKindOfClass:[NSData class]]) {
		val = [NSUnarchiver unarchiveObjectWithData:val];
	}
	if ([val isKindOfClass:[NSDictionary class]]) {
		val = [(NSDictionary*)val unarchiveFromPropertyListFormat];
	}
	else if ([val isKindOfClass:[NSArray class]]) {
		NSMutableArray *na = [NSMutableArray arrayWithCapacity:[val count]];
		NSEnumerator *curs = [val objectEnumerator];
		id nob;
		while ((nob = [curs nextObject]) != nil)
			[na addObject:WTKeyValueDecodeObject(nob)];
		return na;
	}
	else if ([@"null" isEqualTo:val])
		return [NSNull null];
	// else
	return val;
}

static id
WTKeyValueEncodeObject (id val)
{	
	if (val == nil)
		return nil;
	
	if ([val isKindOfClass:[NSString class]]) {
		;
	}
	else if ([val isKindOfClass:[NSNumber class]]) {
		;
	}
	else if ([val isKindOfClass:[NSData class]]) {
		;
	} else if ([val isKindOfClass:[NSDictionary class]]) {
		val = [(NSDictionary*)val archiveFromPropertyListFormat];
	}
	else if ([val isKindOfClass:[NSArray class]]) {
		NSMutableArray *na = [NSMutableArray arrayWithCapacity:[val count]];
		NSEnumerator *curs = [val objectEnumerator];
		id nob;
		while ((nob = [curs nextObject]) != nil)
			[na addObject:WTKeyValueEncodeObject(nob)];
		val = na;
	}
	else if ([val supportsSimpleDictionaryKeyValueCoding]) {
		val = [NSDictionary archiveToPropertyListForRootObject:val];
		
	}
	else {
		val = [NSArchiver archivedDataWithRootObject:val];
	}
	return val;
}


#pragma mark -
@implementation NSObject (WTPlistKeyValueCoding)

+ (BOOL) supportsSimpleDictionaryKeyValueCoding
{
	return NO;
}


- (BOOL) supportsSimpleDictionaryKeyValueCoding
{
	return NO;
}

@end


#pragma mark -
@implementation NSDictionary (WTPlistKeyValueCoding)

+ (BOOL) supportsSimpleDictionaryKeyValueCoding
{
	return YES;
}


- (BOOL) supportsSimpleDictionaryKeyValueCoding
{
	return YES;
}
	
#pragma mark -
+ archiveToPropertyListForRootObject: rob;
{
	if ([rob supportsSimpleDictionaryKeyValueCoding]) {
		NSMutableDictionary *dict = [NSMutableDictionary dictionary];
		[dict setValue:NSStringFromClass ([rob class]) forKey:@"isa"];
		[rob encodeWithCoder:(NSCoder*)dict];
		return dict;
	}
	// else return a data object
	NSData *data = [NSArchiver archivedDataWithRootObject:rob];
	return data;
}


- unarchiveFromPropertyListFormat;
{
	NSString *type;

	type = [self valueForKey:@"isa"];
	if (type != nil) {
		Class factory = NSClassFromString(type);
		id nob = [[factory alloc] initWithCoder:(NSCoder*)self];
		return [nob autorelease];
	} else {
		NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[self count]];
		NSEnumerator *curs = [self keyEnumerator];
		NSString *key;
		id value;
		
		while ((key = [curs nextObject]) != nil) {
			value = WTKeyValueDecodeObject([self valueForKey:key]);
			if (value)
				[dict setValue:value forKey:key];
		}
		return dict;
	}
}


- archiveFromPropertyListFormat;
{
	NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:[self count]];
	NSEnumerator *curs = [self keyEnumerator];
	NSString *key;
	id value;
	
	while ((key = [curs nextObject]) != nil) {
		value = WTKeyValueEncodeObject([self valueForKey:key]);
		if (value)
			[dict setValue:value forKey:key];
	}
	return dict;
}


#pragma mark -
- (BOOL)	decodeBoolForKey:(NSString *)key
{
	NSString *b = [self valueForKey:key];
	if (b == nil) return NO;
	if ([b isEqualToString:@"YES"]) return YES;
	if ([b isEqualToString:@"yes"]) return YES;
	// else
	return NO;
}


- (float)	decodeFloatForKey:(NSString *)key
{
	return [[self valueForKey:key] floatValue];
}


- (int)		decodeIntForKey:(NSString *)key
{
	return [[self valueForKey:key] intValue];
}


- (id)		decodeObjectForKey:(NSString *)key
{
	id val = [self valueForKey:key];
	return WTKeyValueDecodeObject (val);
}

@end

#pragma mark -
@implementation NSMutableDictionary (WTPlistKeyValueCoding)

- (void)	encodeBool:(BOOL)intv forKey:(NSString *)key
{
	[self setValue:(intv ? @"YES" : @"NO") forKey:key];
}


- (void)	encodeFloat:(float)intv forKey:(NSString *)key
{
	[self setValue:[NSNumber numberWithFloat:intv] forKey:key];
}


- (void)	encodeInt:(int)intv forKey:(NSString *)key
{
	[self setValue:[NSNumber numberWithInt:intv] forKey:key];
}


- (void)	encodeObject:(id)intv forKey:(NSString *)key
{
	id val = WTKeyValueEncodeObject(intv);
	if (val)
		[self setValue:val forKey:key];
	/*
	if ([intv isKindOfClass:[NSArray class]]) {
		NSMutableArray *ar = [[NSMutableArray alloc] initWithCapacity:[intv count]];
		NSEnumerator *curs = [intv objectEnumerator];
		id val;
		while (val = [curs nextObject]) {
			NSMutableDictionary *dob = [[NSMutableDictionary alloc] init];
			[dob setValue:NSStringFromClass ([val class]) forKey:@"isa"];
			[val encodeWithCoder:(NSCoder*)dob];
			[ar addObject:dob];
			[dob release];
		}
		[self setValue:ar forKey:key];
		[ar release];
	} else {
		// else return a data object
		NSData *data = [NSArchiver archivedDataWithRootObject:intv];
		if (data)
			[self setValue:data forKey:key];
	}
	 */
}

@end

