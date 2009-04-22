//
//  DKRuntimeHelper.h
//  DrawKit
//
//  Created by graham on 27/03/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DKRuntimeHelper : NSObject

+ (NSArray*)	allClasses;
+ (NSArray*)	allClassesOfKind:(Class) aClass;


@end



BOOL	classIsNSObject( const Class aClass );
BOOL	classIsSubclassOfClass( const Class aClass, const Class subclass );

