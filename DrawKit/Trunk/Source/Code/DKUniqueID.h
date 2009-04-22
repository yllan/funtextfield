//
//  DKUniqueID.h
//  DrawKit
//
//  Created by graham on 15/03/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DKUniqueID : NSObject

+ (NSString*)			uniqueKey;

@end



/*

Utility class generates totally unique keys using CFUUID. The keys are guaranteed unique across time, space and different machines.

One intended client for this is to assign unique registry keys to styles to solve the registry merge problem.




*/
