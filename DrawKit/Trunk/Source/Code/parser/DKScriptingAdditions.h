//
//  DKScriptingAdditions.h
//  DrawKit
//
//  Created by Jason Jobe on 3/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DKExpression;


@interface NSColor (DKStyleExpressions)

+ (NSColor*)	instantiateFromExpression:(DKExpression*)expr;
- (NSString*)	styleScript;

@end

@interface NSShadow (DKStyleExpressions)

+ (NSShadow*)	instantiateFromExpression:(DKExpression*) expr;
- (NSString*)	styleScript;

@end
