//
//  DKBezierTextContainer.h
//  GCDrawKit
//
//  Created by graham on 09/05/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DKBezierTextContainer : NSTextContainer
{
	NSBezierPath*	mPath;
}

- (void)			setBezierPath:(NSBezierPath*) aPath;

@end



/*

This class is used by DKTextAdornment to lay out text flowed into an arbitrary shape. Given the bezier path representing
the text container, this caches the text layout rects and uses that info to return rects on demand to the layout manager.

*/


