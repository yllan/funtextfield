//
//  GCGradientView.h
//  panel
//
//  Created by Graham on Wed Apr 11 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>


@class GCGradient;



@interface GCGradientView : NSView
{
	GCGradient*		_gradient;
}


- (void)			setGradient:(GCGradient*) grad;
- (GCGradient*)		gradient;

@end


// ultra simple view class simply renders its gradient in the bounds.
// used (in part) to provide PDF/EPS export facility for gradients


// list view used to provide similar feature for exporting library images

@interface GCGradientListView : NSView
{
	NSArray*	_list;
	NSSize		_cellSize;
	NSSize		_cellSpacing;
}

- (void)	setGradientList:(NSArray*) list;
- (void)	setCellSize:(NSSize) size;

@end


#define kGCDefaultListViewCellSize		( NSMakeSize( 64, 64 ))
#define kGCDefaultListViewCellSpacing   ( NSMakeSize( 2, 2 ))