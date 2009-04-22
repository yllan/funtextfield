//
//  DKSymbol.h
//  Smooth
//
//  Created by Jason Jobe on 4/25/05.
//  Copyright 2005 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DKSymbol : NSString <NSCopying>
{
    NSString*		mString;
    int				mIndex;
}

+ (NSMutableDictionary*)	symbolMap;
+ (DKSymbol*)				symbolForString:(NSString*) str;
+ (DKSymbol*)				symbolForCString:(const char*) cstr length:(int) len;

- (id)						initWithString:(NSString*) str index:(int) ndx;

-(int)						index;
-(NSString*)				string;

@end
