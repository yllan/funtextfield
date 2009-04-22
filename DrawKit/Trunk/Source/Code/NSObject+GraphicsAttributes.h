///**********************************************************************************************************************************
///  NSObject+GraphicsAttributes.h
///  DrawKit
///
///  Created by graham on 09/03/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>


@class DKExpression;


@interface NSObject (GraphicsAttributes)

- (id)			initWithExpression:(DKExpression*) expr;
- (void)		setValue:(id) val forNumericParameter:(int) pnum;

- (NSImage*)	imageResourceNamed:(NSString*) name;


@end
