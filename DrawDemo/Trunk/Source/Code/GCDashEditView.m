///**********************************************************************************************************************************
///  GCDashEditView.m
///  GCDrawKit
///
///  Created by graham on 18/05/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "GCDashEditView.h"

#import <GCDrawKit/DKLineDash.h>
#import <GCDrawKit/LogEvent.h>


@implementation GCDashEditView
#pragma mark As a GCDashEditView
- (void)			setDash:(DKLineDash*) dash
{
	[dash retain];
	[mDash release];
	mDash = dash;
	[self setNeedsDisplay:YES];
}


- (DKLineDash*)		dash;
{
	return mDash;
}


#pragma mark -
- (void)			setLineWidth:(float) width;
{
	[mPath setLineWidth:width];
	[self setNeedsDisplay:YES];
}


- (void)			setLineCapStyle:(NSLineCapStyle) lcs
{
	[mPath setLineCapStyle:lcs];
	[self setNeedsDisplay:YES];
}


- (void)			setLineJoinStyle:(NSLineJoinStyle) ljs
{
	[mPath setLineJoinStyle:ljs];
	[self setNeedsDisplay:YES];
}


- (void)			setLineColour:(NSColor*) colour
{
	[colour retain];
	[mLineColour release];
	mLineColour = colour;
	[self setNeedsDisplay:YES];
}


#pragma mark -
- (void)			setDelegate:(id) del
{
	mDelegateRef = del;
}


- (id)				delegate
{
	return mDelegateRef;
}


#pragma mark -
- (void)			calcHandles
{
	// calculates where the handle rects are given the current dash
	
	NSRect	hr, br;
	int		i, c;
	float	scale = [[self dash] scalesToLineWidth]? [mPath lineWidth] : 1.0;
	float	d[8];
	float	phase;
	
	hr.size = kGCStandardHandleRectSize;
	br = [self bounds];
	[mHandles removeAllObjects];
	[[self dash] getDashPattern:d count:&c];
	
	phase = [[self dash] phase] * scale;
	
	hr.origin.x = kGCDashEditInset - ( hr.size.width * 0.5f) + phase;
	
	for( i = 0; i < c; ++i )
	{
		hr.origin.x += ( d[i] * scale );
		hr.origin.y = 12 + ( NSMinY(br) + NSMaxY(br)) / 4.0;
		
		// if this collides with the previous rect, offset it downwards
		
		if ( i > 0 )
		{
			NSRect kr, pr = [[mHandles objectAtIndex:i - 1] rectValue];
			
			kr = hr;
			kr.size.height += 100;
		
			if ( NSIntersectsRect( hr, pr ))
				hr.origin.y = NSMaxY( pr ) + 1;
		}
	
		[mHandles addObject:[NSValue valueWithRect:hr]];
	}
	
	// add a handle for the phase
	
	hr.origin.y = MAX( 2, scale) + (( NSMinY(br) + NSMaxY(br)) / 4.0 );
	mPhaseHandle = NSMakeRect( kGCDashEditInset + phase, hr.origin.y, 5, 10 );
}


- (int)				mouseInHandle:(NSPoint) mp
{
	int	i, c;
	
	c = [mHandles count];
	
	for( i = 0; i < c; ++i )
	{
		if ( NSPointInRect( mp, [[mHandles objectAtIndex:i] rectValue]))
			return i;
	}
	
	if ( NSPointInRect( mp, mPhaseHandle ))
		return 99;	// phase "part code"
	
	return -1;
}


- (void)			drawHandles
{
	NSBezierPath* temp = [NSBezierPath bezierPath];
	
	int		i, c;
	NSRect	hr, br;
	NSPoint	a, b;
	c = [mHandles count];
	br = [self bounds];
	
	// draw the selected one highlighted
	
	if( mSelected != -1 && mSelected != 99 )
	{
		[temp appendBezierPathWithOvalInRect:[[mHandles objectAtIndex:mSelected] rectValue]];
		[[NSColor greenColor] set];
		[temp fill];
		[temp removeAllPoints];
	}
	
	a.y = 3 + ( NSMinY(br) + NSMaxY(br)) / 4.0;
	
	for( i = 0; i < c; ++i )
	{
		hr = [[mHandles objectAtIndex:i] rectValue];
		
		a.x = b.x = hr.origin.x + ( hr.size.width * 0.5f );
		b.y = hr.origin.y;
		
		[temp moveToPoint:a];
		[temp lineToPoint:b];
		[temp appendBezierPathWithOvalInRect:hr];
	}
	
	[[NSColor darkGrayColor] set];
	[temp stroke];
}


- (void)			calcDashForPoint:(NSPoint) mp
{
	// sets the dash element indexed by mSelected to the right size for the given mouse point
	
	float	d[8];
	float	scale = [[self dash] scalesToLineWidth]? [mPath lineWidth] : 1.0;
	float	phase = [[self dash] phase] * scale;
	float	fixedAmount = kGCDashEditInset;
	int		i, c;
	
	if ( mSelected == 99 )
	{
		// dragging the phase
		
		phase = MAX( 0, ( mp.x - fixedAmount ) / scale);
		[[self dash] setPhase:phase];
	}
	else
	{
		fixedAmount += phase;
		[[self dash] getDashPattern:d count:&c];
		
		// sanity check the value of selected:
		
		if ( mSelected < 0 || mSelected >= c )
			return;
		
		// compute the fixed amount to subtract from mp.x
		
		for( i = 0; i < mSelected; ++i )
			fixedAmount += (d[i] * scale);
			
		d[mSelected] = ( mp.x - fixedAmount ) / scale;
		
		if(d[mSelected] < 0)
			d[mSelected] = 0;
		
		// write the value back to the dash
		
		[[self dash] setDashPattern:d count:c];
	}
	// inform delegate
	
	if(mDelegateRef && [mDelegateRef respondsToSelector:@selector(dashDidChange:)])
		[mDelegateRef dashDidChange:self];
}


#pragma mark -
#pragma mark As an NSView
- (BOOL)			acceptsFirstMouse:(NSEvent*) event
{
#pragma unused (event)
	return YES;
}


- (void)			drawRect:(NSRect) rect
{
	[[NSColor whiteColor] set];
	NSRectFill( rect );
	
	[[NSColor lightGrayColor] set];
	NSFrameRectWithWidth([self bounds], 1.0 );
	NSRect	br = [self bounds];
	NSPoint	a, b;
	
	a.y = b.y = ( NSMinY(br) + NSMaxY(br)) / 4.0;
	a.x = NSMinX(br) + kGCDashEditInset;
	b.x = NSMaxX(br) - kGCDashEditInset;
	
	[mPath removeAllPoints];
	[mPath moveToPoint:a];
	[mPath lineToPoint:b];
	
	[[self dash] applyToPath:mPath];
	
	[mLineColour set];
	[mPath stroke];
	
	[self calcHandles];
	[self drawHandles];
	
	// draw phase handle - right pointing triangle
	
	NSBezierPath* path = [NSBezierPath bezierPath];
	[path moveToPoint:NSMakePoint( NSMinX( mPhaseHandle ), NSMinY( mPhaseHandle))];
	[path lineToPoint:NSMakePoint( NSMinX( mPhaseHandle ), NSMaxY( mPhaseHandle))];
	[path lineToPoint:NSMakePoint( NSMaxX( mPhaseHandle ), NSMidY( mPhaseHandle))];
	[path closePath];
	
	[[NSColor darkGrayColor] set];
	[path fill];
}


- (id)				initWithFrame:(NSRect) frame
{
    self = [super initWithFrame:frame];
    if (self != nil)
	{
		NSAssert(mDash == nil, @"Expected init to zero");
		mHandles = [[NSMutableArray alloc] init];
		mPath = [[NSBezierPath bezierPath] retain];
		mSelected = -1;
		NSAssert(mDelegateRef == nil, @"Expected init to zero");
		[self setLineColour:[NSColor grayColor]];
		
		if (mHandles == nil 
				|| mPath == nil 
				|| mLineColour == nil)
		{
			[self autorelease];
			self = nil;
		}
    }
	if (self != nil)
	{
		[mPath setLineWidth:5.0];
	}
   
	return self;
}


- (BOOL)			isFlipped
{
	return YES;
}


#pragma mark -
#pragma mark As an NSResponder
- (void)			mouseDown:(NSEvent*) event
{
	NSPoint mp = [self convertPoint:[event locationInWindow] fromView:nil];
	mSelected = [self mouseInHandle:mp];
	[self setNeedsDisplay:YES];
	
//	LogEvent_(kReactiveEvent, @"selected = %d", mSelected);
}


- (void)			mouseDragged:(NSEvent*) event
{
	NSPoint mp = [self convertPoint:[event locationInWindow] fromView:nil];
	
	if ( mSelected != -1 )
	{
		[self calcDashForPoint:mp];
		[self setNeedsDisplay:YES];
	}
}


- (void)			mouseUp:(NSEvent*) event
{
#pragma unused (event)
	mSelected = -1;
	[self setNeedsDisplay:YES];
}


#pragma mark -
#pragma mark As an NSObject
- (void)			dealloc
{
	[mLineColour release];
	[mPath release];
	[mHandles release];
	[mDash release];
	
	[super dealloc];
}


@end
