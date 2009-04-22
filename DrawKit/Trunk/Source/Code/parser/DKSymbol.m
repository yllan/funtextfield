//
//  DKSymbol.m
//  Smooth
//
//  Created by Jason Jobe on 4/25/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import "DKSymbol.h"


#pragma mark Static Vars
static NSMutableDictionary* sSymbolMap;
static int sSymCounter = 0;


#pragma mark -
@implementation DKSymbol
#pragma mark As a DKSymbol
+ (NSMutableDictionary*)	symbolMap
{
    if (sSymbolMap == nil)
        sSymbolMap = [[NSMutableDictionary alloc] init];
   
	return sSymbolMap;
}


+ (DKSymbol*)				symbolForString:(NSString*) str
{
    DKSymbol *sym = [[DKSymbol symbolMap] valueForKey:str];
    
	if (sym == nil)
	{
        sym = [[DKSymbol alloc] initWithString:str index:(++sSymCounter)];
        [[DKSymbol symbolMap] setValue:sym forKey:[sym string]];
        [sym release];
    }
    
	return sym;
}


+ (DKSymbol*)				symbolForCString:(const char*) cstr length:(int) len
{
    NSString *str = [[NSString alloc] initWithCString:cstr length:len];
    DKSymbol* sym = [DKSymbol symbolForString:str];
    [str release];
    return sym;
}


#pragma mark -
- (id)						initWithString:(NSString*) str index:(int) ndx
{
	self = [super init];
	if (self != nil)
	{
		mString = [str retain];
		mIndex = ndx;
		
		if (mString == nil)
		{
			[self autorelease];
			self = nil;
		}
	}
	return self;
}

-(int)						index
{
    return mIndex;
}


#pragma mark -
#pragma mark As an NSString
- (unichar)					characterAtIndex:(unsigned) ndx
{
	return [mString characterAtIndex:ndx];
}


- (void)					getCharacters:(unichar *) buffer range:(NSRange) aRange
{
	[mString getCharacters:buffer range:aRange];
}


- (BOOL)					isEqualToString:(NSString*) str
{
	return ((self == str) || [mString isEqualToString:str]);
}

- (unsigned int)			length
{
	return [mString length];
}


-(NSString*)				string
{
    return mString;
}


#pragma mark -
- (BOOL)					isLiteralValue
{
	return NO;
}


- (BOOL)					isSmoothAtom
{
	return NO;
}


- (BOOL)					isSmoothIdentifier
{
	return YES;
}


// NSString protocol
#pragma mark -
#pragma mark As an NSObject
- (void)					dealloc
{
    [mString release];
	
    [super dealloc];
}


- (NSString*)				description
{
    return mString;
}

-(BOOL)						isEqualTo:(id) anObject
{
	return ((self == anObject) || [mString isEqualToString:[anObject description]]);
}


#pragma mark -
#pragma mark As part of NSCopying Protocol
- (id)						copyWithZone:(NSZone*) zone
{
	#pragma unused(zone)
	
	return [self retain];
}


@end
