//
//  DKScriptingAdditions.m
//  DrawKit
//
//  Created by Jason Jobe on 3/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DKScriptingAdditions.h"

#import "DKExpression.h"


@implementation NSColor (DKStyleExpressions)
#pragma mark As a NSColor
+ (NSColor*)	instantiateFromExpression:(DKExpression*)expr
{
	NSColor *color;
	id val;
	
/*
	if ([expr argCount] == 2)
	{
		id val = [expr valueAtIndex:1];
		if ([val isKindOfClass:[NSColor class]])
			color = val;
	}
	else
*/
	if ((val = [expr valueForKey:@"r"]))
	{
		color = [NSColor colorWithCalibratedRed:[val floatValue]
										  green:[[expr valueForKey:@"g"] floatValue]
										   blue:[[expr valueForKey:@"b"] floatValue]
										  alpha:[[expr valueForKey:@"a"] floatValue]];
	}
	else if ((val = [expr valueForKey:@"red"]))
	{
		color = [NSColor colorWithCalibratedRed:[val floatValue]
										  green:[[expr valueForKey:@"green"] floatValue]
										   blue:[[expr valueForKey:@"blue"] floatValue]
										  alpha:[[expr valueForKey:@"alpha"] floatValue]];
	} else {
		color = [NSColor colorWithCalibratedRed:[[expr valueAtIndex:1] floatValue]
										  green:[[expr valueAtIndex:2] floatValue]
										   blue:[[expr valueAtIndex:3] floatValue]
										  alpha:[[expr valueAtIndex:4] floatValue]];
	}
	return color;
}

- (NSString*)	styleScript
{
	NSColor* cc = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];	
	return [NSString stringWithFormat:@"(colour r:%1.2f g:%1.2f b:%1.2f a:%1.2f)", [cc redComponent], [cc greenComponent], [cc blueComponent], [cc alphaComponent]];
}

@end


#pragma mark -
@implementation NSShadow (DKStyleExpressions)
#pragma mark As a NSShadow
+ (NSShadow*)	instantiateFromExpression:(DKExpression*) expr;
{
	// shadows are specified by:
	// 0 or colour = shadow colour (NSColor)
	// 1 or blur   = blur radius (float)
	// 2 or x	   = x offset (float)
	// 3 or y      = y offset (float)
	
	NSSize	 so = NSMakeSize( 10, 10 );
	//	float	 br = 10.0;
	id val;
	
	NSShadow *obj = [[[NSShadow alloc] init] autorelease];
	
	if ([expr argCount] == 1) {
		// use default values
		[obj setShadowColor:[NSColor blackColor]];
		[obj setShadowOffset:so];
		[obj setShadowBlurRadius:10.0];
		return obj;
	}
	
	if ((val = [expr valueForKey:@"colour"]) ||
		(val = [expr valueForKey:@"color"]))
	{
		// using keys
		[obj setShadowColor:val];
		
		so.width = [[expr valueForKey:@"x"] floatValue];
		so.height = [[expr valueForKey:@"y"] floatValue];
		[obj setShadowOffset:so];
		
		[obj setShadowBlurRadius:[[expr valueForKey:@"blur"] floatValue]];
	}
	else {
		[obj setShadowColor:[expr valueAtIndex:1]];
		[obj setShadowBlurRadius:[[expr valueAtIndex:2] floatValue]];
		so.width = [[expr valueAtIndex:3] floatValue];
		so.height = [[expr valueAtIndex:4] floatValue];
		[obj setShadowOffset:so];
	}
	return obj;
}

- (NSString*)	styleScript
{
	return [NSString stringWithFormat:@"(shadow colour:%@ blur:%1.1f x:%1.1f y:%1.1f)", [[self shadowColor] styleScript], [self shadowBlurRadius], [self shadowOffset].width, [self shadowOffset].height];
}

@end

