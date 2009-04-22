//
//  GCMiniRadialControls.m
//  panel
//
//  Created by Graham on Thu Apr 12 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCMiniRadialControls.h"

#import "GCDrawKit/NSColor+DKAdditions.h"
#import "NSBezierPath+GCAdditions.h"
#import <GCDrawKit/LogEvent.h>



@implementation GCMiniRadialControls
#pragma mark As a GCMiniRadialControls
- (void)			setCentre:(NSPoint) p
{
	if ( ! NSEqualPoints( p, mCentre ))
	{
		[self notifyDelegateWillChange:nil];
		mCentre = p;
		[self notifyDelegateDidChange:nil];
	}
}


- (NSPoint)			centre
{
	return mCentre;
}

#pragma mark -
- (void)			setRadius:(float) radius
{
	if (  radius != mRadius )
	{
		[self notifyDelegateWillChange:nil];
		mRadius = radius;
		[self notifyDelegateDidChange:nil];
	}
}


- (float)			radius
{
	return mRadius;
}


#pragma mark -
- (NSRect)			targetRect
{
	NSRect pr;
	pr.size = NSMakeSize( 20, 20 );
	
	pr.origin.x = mCentre.x - ( pr.size.width / 2.0 );
	pr.origin.y = mCentre.y - ( pr.size.height / 2.0 );
	
	return pr;
}


- (NSRect)			rectForRadius
{
	NSRect  pr;
	pr.size = NSMakeSize( 25, 25 );
	
	NSPoint sp;
	
	sp.x = NSMidX([self targetRect]);
	sp.y = NSMidY([self targetRect]);
	
	pr.origin.x = sp.x - ( pr.size.width / 2.0 );
	pr.origin.y = sp.y - ( pr.size.height / 2.0 );
	
	return pr;
}


- (void)			drawRadControlInRect:(NSRect) rr radius:(float) rad colorValue:(float) u
{
#pragma unused (u)
	//NSBezierPath* path = [NSBezierPath bezierPathWithOffsetTargetInRect:rr offset:( u < 0.5 )? -1 : 1];
	//NSColor*	fillc = [[[self gradient] colorAtValue:u] colorWithAlphaComponent:mControlAlpha];
	
	NSBezierPath* path = [NSBezierPath bezierPathWithTargetInRect:rr];
	
	NSColor* fillc = [NSColor rgbGrey:0.5];
	[fillc set];
	[path fill];
	[[fillc contrastingColor] set];
	
	[path setLineWidth:0.7];
	rr = NSInsetRect( rr, -10, -10 );
	//[path appendBezierPathWithOvalInRect:rr]; 
	[path stroke];
	
	if ( rad > 0.0 )
	{
		NSRect		radr;
		float		dash[2] = { 5.0, 5.0 };
		
		radr.origin.x = NSMidX( rr ) - rad;
		radr.origin.y = NSMidY( rr ) - rad;
		radr.size.width = radr.size.height = ( rad * 2 );
		
	//	LogEvent_(kReactiveEvent, @"rad rect = {%f, %f} - {%f, %f}", radr.origin.x, radr.origin.y, radr.size.width, radr.size.height );
		
		path = [NSBezierPath bezierPathWithOvalInRect:radr];
		[path setLineWidth:5.0];
		[[[NSColor whiteColor] colorWithAlphaComponent:0.25] set];
		[path stroke];
		
		[path setLineWidth:1.0];
		[path setLineDash:dash count:2 phase:0.0];
		[[NSColor orangeColor] set];
		[path stroke];
	}
}


#pragma mark -
#pragma mark As a GCMiniControl
- (void)			draw
{
	[self drawRadControlInRect:[self targetRect] radius:mRadius colorValue:[self value]];
}


- (int)				hitTestPoint:(NSPoint) p
{
	if ([super hitTestPoint:p] == kGCMiniControlEntireControl )
	{
		if ( NSPointInRect( p, [self targetRect]))
			return kGCHitRadialTarget;
		else
		{
			/*
			float		pr;
			NSPoint		mp;
			NSRect		kr = [self rectForRadius];

			mp.x = NSMidX( kr );
			mp.y = NSMidY( kr );
			pr = hypotf( p.x - mp.x, p.y - mp.y );
			
			LogEvent_(kReactiveEvent, @"pr = %f, rad= %f", pr, mRadius );
			
			if ( ABS( mRadius - pr ) < 30 )
				return kGCHitRadialRadius;
			*/
		}
	}
	
	return kGCMiniControlNoPart;
}


- (id)				initWithBounds:(NSRect) rect inCluster:(GCMiniControlCluster*) clust
{
	self = [super initWithBounds:rect inCluster:clust];
	if (self != nil)
	{
		NSAssert(mRadius == 0.0, @"Expected init to zero");
		mCentre = NSMakePoint(NSMidX(rect), NSMidY(rect));
	}
	return self;
}


- (BOOL)			mouseDraggedAt:(NSPoint) currentPoint inPart:(int) part modifierFlags:(int) flags
{
#pragma unused (flags)
	if ( part == kGCHitRadialTarget )
		[self setCentre:currentPoint];
	else if ( part == kGCHitRadialRadius )
	{
		NSRect		kr = [self targetRect];
		NSPoint		mp;
		
		mp.x = NSMidX( kr );
		mp.y = NSMidY( kr );
		[self setRadius:hypotf( currentPoint.x - mp.x, currentPoint.y - mp.y )];
	}
	
	return YES;
}


@end
