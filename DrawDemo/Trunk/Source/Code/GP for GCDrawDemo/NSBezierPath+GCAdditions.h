//
//  NSBezierPath+GCAdditions.h
//  GCDrawKit
//
//  Created by graham on 12/04/2007.
//  Copyright 2007 Apptree.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSBezierPath (GCAdditions)

+ (NSBezierPath*)	bezierPathWithTargetInRect:(NSRect) rect;
+ (NSBezierPath*)	bezierPathWithRoundEndedRectInRect:(NSRect) rect;
+ (NSBezierPath*)	roundRectInRect:(NSRect) rect andCornerRadius:(float) radius;
+ (NSBezierPath*)   bezierPathWithOffsetTargetInRect:(NSRect) rect offset:(int) off;


+ (NSBezierPath*)   bezierPathWithIrisRingWithRadius:(float) radius width:(float) width tabSize:(NSSize) tabsize;
+ (NSBezierPath*)   bezierPathWithIrisRingWithRadius:(float) radius width:(float) width tabAngle:(float) angle tabSize:(NSSize) tabsize;

+ (NSBezierPath*)   bezierPathWithIrisTabWithRadius:(float) radius width:(float) width tabSize:(NSSize) tabsize;
+ (NSBezierPath*)   bezierPathWithIrisTabWithRadius:(float) radius width:(float) width tabAngle:(float) angle tabSize:(NSSize) tabsize;

@end
