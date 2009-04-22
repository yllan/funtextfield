//
//  NSBezierPath+Shapes.h
//  DrawKit
//
//  Created by graham on 08/01/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSBezierPath (Shapes)

// chains and sprockets

+ (NSBezierPath*)		bezierPathWithStandardChainLink;
+ (NSBezierPath*)		bezierPathWithStandardChainLinkFromPoint:(NSPoint) a toPoint:(NSPoint) b;
+ (NSBezierPath*)		bezierPathWithSprocketPitch:(float) pitch numberOfTeeth:(int) teeth;

// nuts and bolts

+ (NSBezierPath*)		bezierPathWithThreadedBarOfLength:(float) length diameter:(float) dia threadPitch:(float) pitch options:(unsigned) options;
+ (NSBezierPath*)		bezierPathWithThreadLinesOfLength:(float) length diameter:(float) dia threadPitch:(float) pitch;
+ (NSBezierPath*)		bezierPathWithHexagonHeadSideViewOfHeight:(float) height diameter:(float) dia options:(unsigned) options;
+ (NSBezierPath*)		bezierPathWithBoltOfLength:(float) length
									threadDiameter:(float) tdia
									threadPitch:(float) tpitch
									headDiameter:(float) hdia
									headHeight:(float) hheight
									shankLength:(float) shank
									options:(unsigned) options;

@end


// options:


enum
{
	kThreadedBarLeftEndCapped			= 1 << 0,
	kThreadedBarRightEndCapped			= 1 << 1,
	kThreadedBarThreadLinesDrawn		= 1 << 2,
	kFastenerCentreLine					= 1 << 3,
	kFastenerHasCapHead					= 1 << 4,
	kHexFastenerFaceCurvesDrawn			= 1 << 5
};


/*

A category on NSBezierPath for creating various unusual shape paths, particularly for engineering use

*/
