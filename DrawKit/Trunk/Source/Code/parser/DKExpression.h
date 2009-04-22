//*******************************************************************************************
//  DKExpression.h
//  Parser
//
//  Created by Jason Jobe on 1/28/07.
//  Released under the Creative Commons license 2007 Datalore, LLC.
//
// 
//  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ 
//  or send a letter to
//  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
//
//*******************************************************************************************/

#import <Foundation/Foundation.h>


@interface DKExpression : NSObject
{
	NSString*		mType;
	NSMutableArray* mValues;
}

- (void)			setType:(NSString*) aType;
- (NSString*)		type;
- (BOOL)			isSequence;
- (BOOL)			isMethodCall;

- (BOOL)			isLiteralValue;
- (int)				argCount;

// The value methods dereference pairs if found

- (id)				valueAtIndex:(int) ndx;
- (id)				valueForKey:(NSString*)key;

// This method may return a key:value "pair"

- (id)				objectAtIndex:(int) ndx;
- (void)			replaceObjectAtIndex:(int) ndx withObject:(id) obj;

- (void)			addObject:(id) aValue;
- (void)			addObject:(id) aValue forKey:(NSString*) key;

- (void)			applyKeyedValuesTo:(id) anObject;

- (NSString*)		selectorFromKeys;

- (NSArray*)        allKeys;
- (NSEnumerator*)   keyEnumerator;
- (NSEnumerator*)   objectEnumerator;

@end


@interface DKExpressionPair : NSObject
{
	NSString*		key;
	id				value;
}

- (id)				initWithKey:(NSString*) aKey value:(id) aValue;
- (NSString*)		key;
- (id)				value;
- (void)			setValue:(id) val;

@end


@interface NSObject (DKExpressionSupport)

- (BOOL)			isLiteralValue;

@end

