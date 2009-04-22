//
//  GCMiniCircularSlider.m
//  panel
//
//  Created by Graham on Thu Apr 12 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCMiniCircularSlider.h"


#pragma mark Static Vars
static float		sConstrainAngle = 0.261799387799; // 15 degrees


@implementation GCMiniCircularSlider
#pragma mark As a GCMiniCircularSlider
- (NSRect)		circleBounds
{
	NSRect  ar = NSInsetRect( [self bounds], 8, 8 );
	
	if ( ar.size.width > ar.size.height )
		ar.size.width = ar.size.height;
	else
		ar.size.height = ar.size.width;
		
	ar.origin.x = (( NSMinX([self bounds]) + NSMaxX([self bounds]) ) / 2.0 ) - ( ar.size.width / 2.0 );
	ar.origin.y = (( NSMinY([self bounds]) + NSMaxY([self bounds]) ) / 2.0 ) - ( ar.size.height / 2.0 );
		
	return ar;
}


#pragma mark -
#pragma mark As a GCMiniSlider
- (NSRect)		knobRect
{
	NSRect  ar = [self circleBounds];
	
	float radius = ar.size.width / 2.0;
	
	NSPoint	 cp;
	NSRect	 kr;
	
	cp.x = NSMidX( ar );
	cp.y = NSMidY( ar );
	
	kr.origin.x = ( cp.x + ( cos([self value]) * radius )) - ([mKnobImage size].width / 2.0);
	kr.origin.y = ( cp.y + ( sin([self value]) * radius )) - ([mKnobImage size].height / 2.0);
	kr.size = [mKnobImage size];
	
	return kr;
}


#pragma mark -
#pragma mark As a GCMiniControl
- (void)		draw
{
	NSRect  ar = [self circleBounds];
	
	NSBezierPath* path = [NSBezierPath bezierPathWithOvalInRect:ar];
	[path setLineWidth:10];
	[[NSGraphicsContext currentContext] saveGraphicsState];
	
	[self applyShadow];									
	[[self themeColour:kGCMiniControlThemeBackground] set];
	[path stroke];
	
	[[NSGraphicsContext currentContext] restoreGraphicsState];

	if ([self showTickMarks])
	{
		// append ticks to path. show ticks every 15 degrees
		
		float radius = ( ar.size.width / 2.0 );
		float	tickLength = 3, a = 0.0;
		NSPoint	cp, ts, te;
		int		t;
		
		cp.x = NSMidX( ar );
		cp.y = NSMidY( ar );
		
		for( t = 0; t < 24; ++t )
		{
			ts.x = cp.x + ( cos( a ) * ( radius - tickLength ));
			ts.y = cp.y + ( sin( a ) * ( radius - tickLength ));
			te.x = cp.x + ( cos( a ) * ( radius + tickLength ));
			te.y = cp.y + ( sin( a ) * ( radius + tickLength ));
		
			[path moveToPoint:ts];
			[path lineToPoint:te];
			
			a += sConstrainAngle;
		}
	}
	
	[path setLineWidth:0.5];

	NSAffineTransform* tfm = [NSAffineTransform transform];
	[tfm translateXBy:0 yBy:1];
	[path transformUsingAffineTransform:tfm];
	
	[[self themeColour:kGCMiniControlThemeSliderTrkHilite] set];
	[path stroke];
	
	tfm = [NSAffineTransform transform];
	[tfm translateXBy:0 yBy:-1];
	[path transformUsingAffineTransform:tfm];
	[[self themeColour:kGCMiniControlThemeSliderTrack] set];
	[path stroke];
	
	// draw the knob
	
	[mKnobImage drawInRect:[self knobRect] fromRect:NSZeroRect operation:NSCompositeSourceAtop fraction:[[self cluster] alpha]];
}


- (void)		flagsChanged:(int) flags
{
	BOOL shift = ( flags & NSShiftKeyMask ) != 0;
	[self setShowTickMarks:shift];
}


- (id)			initWithBounds:(NSRect) rect inCluster:(GCMiniControlCluster*) clust
{
	self = [super initWithBounds:rect inCluster:clust];
	if (self != nil)
	{
		mValue = 0.0;
		mMinValue = -pi;
		mMaxValue = pi;
		[self setInfoWindowMode:kGCMiniControlInfoWindowFollowsMouse];
	}
	return self;
}


- (BOOL)		mouseDownAt:(NSPoint) startPoint inPart:(int) part modifierFlags:(int) flags
{
#pragma unused (startPoint, flags)
	if ( part == kGCMiniSliderKnob )
	{
		NSString* fstr = [NSString stringWithUTF8String:"\x30\x2E\x30\xC2\xB0"];
		
		float degrees = fmodf(([self value] * 180.0f )/ pi, 360.0 );
		[self setupInfoWindowAtPoint:[self knobRect].origin withValue:degrees andFormat:fstr];
		return YES;
	}
	else
		return NO;
}


- (BOOL)		mouseDraggedAt:(NSPoint) currentPoint inPart:(int) part modifierFlags:(int) flags
{
#pragma unused (part)
	// recalculate the value based on the position of the knob
	
	NSPoint cp;
	NSRect  ar = [self circleBounds];
	
	cp.x = NSMidX( ar);
	cp.y = NSMidY( ar );
	
	float angle = atan2f( currentPoint.y - cp.y, currentPoint.x - cp.x );
	
	// constrain angle if shift down

	BOOL shift = ( flags & NSShiftKeyMask) != 0;
	
	if ( shift )
	{
		float rem = fmodf( angle, sConstrainAngle );
		
		if ( rem > sConstrainAngle / 2.0 )
			angle += ( sConstrainAngle - rem );
		else
			angle -= rem;
	}

	[self setNeedsDisplayInRect:[self knobRect]];
	[self setValue:angle];
	[self setNeedsDisplayInRect:[self knobRect]];
	
	float degrees = fmodf(([self value] * 180.0f )/ pi, 360.0 );
	
	[self updateInfoWindowAtPoint:[self knobRect].origin withValue:degrees];

	return YES;
}


@end
