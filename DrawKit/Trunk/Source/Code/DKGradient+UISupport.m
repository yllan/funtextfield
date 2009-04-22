//
//  DKGradient+UISupport.m
//  DrawKit
//
//  Created by graham on 26/03/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import "DKGradient+UISupport.h"


@implementation DKGradient (UISupport)


+ (DKGradient*)		aquaSelectedGradient
{
	DKGradient* grad = [[DKGradient alloc] init];
	
	[grad addColor:[NSColor colorWithCalibratedRed:0.58 green:0.86 blue:0.98 alpha:1.00] at:0.0];
	[grad addColor:[NSColor colorWithCalibratedRed:0.42 green:0.68 blue:0.90 alpha:1.00] at:11.5/23];
	[grad addColor:[NSColor colorWithCalibratedRed:0.64 green:0.80 blue:0.94 alpha:1.00] at:11.5/23];
	[grad addColor:[NSColor colorWithCalibratedRed:0.56 green:0.70 blue:0.90 alpha:1.00] at:1.0];
	[grad setAngleInDegrees:90];
	
	return [grad autorelease];
}


+ (DKGradient*)		aquaNormalGradient
{
	DKGradient* grad = [[DKGradient alloc] init];
	
	[grad addColor:[NSColor colorWithCalibratedRed:0.95 green:0.95 blue:0.95 alpha:1.00] at:0.0];
	[grad addColor:[NSColor colorWithCalibratedRed:0.83 green:0.83 blue:0.83 alpha:1.00] at:11.5/23];
	[grad addColor:[NSColor colorWithCalibratedRed:0.95 green:0.95 blue:0.95 alpha:1.00] at:11.5/23];
	[grad addColor:[NSColor colorWithCalibratedRed:0.92 green:0.92 blue:0.92 alpha:1.00] at:1.0];
	[grad setAngleInDegrees:90];
	
	return [grad autorelease];
}


+ (DKGradient*)		aquaPressedGradient
{
	DKGradient* grad = [[DKGradient alloc] init];
	
	[grad addColor:[NSColor colorWithCalibratedRed:0.80 green:0.80 blue:0.80 alpha:1.00] at:0.0];
	[grad addColor:[NSColor colorWithCalibratedRed:0.64 green:0.64 blue:0.64 alpha:1.00] at:11.5/23];
	[grad addColor:[NSColor colorWithCalibratedRed:0.80 green:0.80 blue:0.80 alpha:1.00] at:11.5/23];
	[grad addColor:[NSColor colorWithCalibratedRed:0.77 green:0.77 blue:0.77 alpha:1.00] at:1.0];	
	[grad setAngleInDegrees:90];
	
	return [grad autorelease];
}


+ (DKGradient*)		unifiedSelectedGradient
{
	DKGradient* grad = [[DKGradient alloc] init];
	
	[grad addColor:[NSColor colorWithCalibratedRed:0.85 green:0.85 blue:0.85 alpha:1.00] at:0.0];
	[grad addColor:[NSColor colorWithCalibratedRed:0.95 green:0.95 blue:0.95 alpha:1.00] at:1.0];	
	[grad setAngleInDegrees:90];
	
	return [grad autorelease];
}


+ (DKGradient*)		unifiedNormalGradient
{
	DKGradient* grad = [[DKGradient alloc] init];
	
	[grad addColor:[NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.00] at:0.0];
	[grad addColor:[NSColor colorWithCalibratedRed:0.90 green:0.90 blue:0.90 alpha:1.00] at:1.0];	
	[grad setAngleInDegrees:90];
	
	return [grad autorelease];
}


+ (DKGradient*)		unifiedPressedGradient
{
	DKGradient* grad = [[DKGradient alloc] init];
	
	[grad addColor:[NSColor colorWithCalibratedRed:0.60 green:0.60 blue:0.60 alpha:1.00] at:0.0];	
	[grad addColor:[NSColor colorWithCalibratedRed:0.75 green:0.75 blue:0.75 alpha:1.00] at:1.0];
	[grad setAngleInDegrees:90];
	
	return [grad autorelease];
}

+ (DKGradient*)		unifiedDarkGradient
{
	DKGradient* grad = [[DKGradient alloc] init];
	
	[grad addColor:[NSColor colorWithCalibratedRed:0.68 green:0.68 blue:0.68 alpha:1.00] at:0.0];	
	[grad addColor:[NSColor colorWithCalibratedRed:0.83 green:0.83 blue:0.83 alpha:1.00] at:1.0];
	[grad setAngleInDegrees:90];
	
	return [grad autorelease];
}


+ (DKGradient*)		sourceListSelectedGradient
{
	DKGradient* grad = [[DKGradient alloc] init];
	
	[grad addColor:[NSColor colorWithCalibratedRed:0.06 green:0.37 blue:0.85 alpha:1.00] at:0.0];	
	[grad addColor:[NSColor colorWithCalibratedRed:0.30 green:0.60 blue:0.92 alpha:1.00] at:1.0];
	[grad setAngleInDegrees:90];
	
	return [grad autorelease];
}

+ (DKGradient*)		sourceListUnselectedGradient
{
	DKGradient* grad = [[DKGradient alloc] init];
	
	[grad addColor:[NSColor colorWithCalibratedRed:0.43 green:0.43 blue:0.43 alpha:1.00] at:0.0];	
	[grad addColor:[NSColor colorWithCalibratedRed:0.60 green:0.60 blue:0.60 alpha:1.00] at:1.0];
	[grad setAngleInDegrees:90];
	
	return [grad autorelease];
}

@end
