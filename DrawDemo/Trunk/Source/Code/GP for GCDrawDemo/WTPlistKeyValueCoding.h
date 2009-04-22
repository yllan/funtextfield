//
//  WTPlistKeyValueCoding.h
//  GradientTest
//
//  Created by Jason Jobe on 4/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSObject (WTPlistKeyValueCoding)

+ (BOOL) supportsSimpleDictionaryKeyValueCoding;
- (BOOL) supportsSimpleDictionaryKeyValueCoding;

@end

@interface NSDictionary (WTPlistKeyValueCoding)

+ archiveToPropertyListForRootObject: rob;
- unarchiveFromPropertyListFormat;
- archiveFromPropertyListFormat;

- (BOOL)	decodeBoolForKey:(NSString *)key;
- (float)	decodeFloatForKey:(NSString *)key;
- (int)		decodeIntForKey:(NSString *)key;
- (id)		decodeObjectForKey:(NSString *)key;

@end

@interface NSMutableDictionary (WTPlistKeyValueCoding)

- (void)	encodeBool:(BOOL)intv forKey:(NSString *)key;
- (void)	encodeFloat:(float)intv forKey:(NSString *)key;
- (void)	encodeInt:(int)intv forKey:(NSString *)key;
- (void)	encodeObject:(id)intv forKey:(NSString *)key;

@end
