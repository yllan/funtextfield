//
//  NSObject+StringValue.h
//  GCDrawKit
//
//  Created by graham on 03/04/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSObject (StringValue)

- (NSString*)	stringValue;
- (NSString*)	address;

@end


@interface NSValue (StringValue)

- (NSString*)	stringValue;

@end


@interface NSColor (StringValue)

- (NSString*)	stringValue;

@end


@interface NSArray (StringValue)

- (NSString*)	stringValue;

@end


@interface NSDictionary (StringValue)

- (NSString*)	stringValue;

@end


@interface NSSet (StringValue)

- (NSString*)	stringValue;

@end


@interface NSString (StringValue)

- (NSString*)	stringValue;

@end

@interface NSDate (StringValue)

- (NSString*)	stringValue;

@end


/*

This category allows -stringValue to be called on a broader range of objects than standard - in fact any object.

The most useful is probably NSValue, since this will automatically use NSStringFromRect/Point/Size etc. 

*/

