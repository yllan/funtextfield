//
//  GCGradientView.m
//  panel
//
//  Created by Graham on Wed Apr 11 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCGradientView.h"
#import "GCGradient.h"

@implementation GCGradientView

- (id)				initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
	if (self)
	{
		[self setGradient:[GCGradient defaultGradient]];
    }
    return self;
}


- (void)			dealloc
{
	[_gradient release];
	[super dealloc];
}


- (BOOL)			isFlipped
{
	return YES;
}


- (void)			drawRect:(NSRect) rect
{
	[[self gradient] fillRect:[self bounds]];
}



- (void)			setGradient:(GCGradient*) grad
{
	[grad retain];
	[_gradient release];
	_gradient = grad;
	[self setNeedsDisplay:YES];
}


- (GCGradient*)		gradient
{
	return _gradient;
}


@end


@implementation GCGradientListView


- (id)				initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    
	if (self)
	{
		_list = nil;
		_cellSize = kGCDefaultListViewCellSize;
		_cellSpacing = kGCDefaultListViewCellSpacing;
    }
    return self;
}


- (void)			dealloc
{
	[_list release];
	[super dealloc];
}


- (BOOL)			isFlipped
{
	return YES;
}


- (void)			drawRect:(NSRect) rect
{
	// render each gradient in the list in a row/column matrix arrangement
	
	NSRect			r = [self bounds];
	int				rows, cols, j, k, i;
	GCGradient*		grad;
	NSRect			gr;
	
	cols = MAX( 1, NSWidth( r ) / ( _cellSize.width + _cellSpacing.width ));
	rows = ([_list count] / cols ) + 1;
	
	gr.origin.x = _cellSpacing.width;
	gr.origin.y = _cellSpacing.height;
	gr.size = _cellSize;
	
	for( j = 0; j < rows; ++j )
	{
		for( k = 0; k < cols; ++k )
		{
			i = ( j * cols ) + k;
			
			if ( i >= 0 && i < [_list count] )
			{
				grad = [_list objectAtIndex:i];
				[grad fillRect:gr];
			}
			
			gr.origin.x += ( _cellSize.width + _cellSpacing.width );
		}
		
		gr.origin.y += ( _cellSize.height + _cellSpacing.height );
		gr.origin.x = _cellSpacing.width;
	}
}



- (void)			setGradientList:(NSArray*) list
{
	[list retain];
	[_list release];
	_list = list;
}


- (void)			setCellSize:(NSSize) size
{
	_cellSize = size;
}

@end
