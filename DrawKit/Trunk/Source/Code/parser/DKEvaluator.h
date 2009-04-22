//
//  DKEvaluator.h
//
//  Created by Jason Jobe on 2007-03-07.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class DKExpression;


@interface DKEvaluator : NSObject
{
	NSMutableDictionary*	mSymbolTable;
}


- (void)	addValue:(id) value forSymbol:(NSString*)symbol;

- (id)		evaluateSymbol:(NSString*) symbol;
- (id)		evaluateObject:(id) anObject;
- (id)		evaluateExpression:(DKExpression*) expr;
- (id)		evaluateSimpleExpression:(DKExpression*) expr;

@end
