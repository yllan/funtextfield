//
//  NSBezierPath+Utility.h
//  FunTextField
//
//  Created by Yung-Luen Lan on 6/22/08.
//  Copyright 2008 yllan.org. All rights reserved.
//

/* Copy from Graham Cox's DrawKit source code: http://apptree.net/drawkit.htm */

#import <Cocoa/Cocoa.h>

@interface NSBezierPath (YLUtility)
- (NSBezierPath*) paralleloidPathWithOffset: (float)delta;

- (NSBezierPath*) bezierPathByStrippingRedundantElements;
- (NSPoint) pointOnPathAtLength: (float)length slope: (float*)slope;
- (NSBezierPath *)	bezierPathByTrimmingFromLength: (float)trimLength;
- (NSBezierPath *)	bezierPathByTrimmingFromLength: (float)trimLength withMaximumError: (float)maxError;
- (NSBezierPath *)	bezierPathByTrimmingToLength: (float)trimLength;
- (NSBezierPath *)	bezierPathByTrimmingToLength:(float)trimLength withMaximumError:(float) maxError;

- (NSBezierPath*) bezierPathWithTextOnPath: (NSAttributedString*)str yOffset: (float)dy;
- (NSBezierPath*) bezierPathWithStringOnPath: (NSString*)str;
- (NSBezierPath*) bezierPathWithStringOnPath: (NSString*)str attributes: (NSDictionary*)attrs;

- (CGFloat) slopeStartingPath;
- (CGFloat) length;
- (CGFloat) lengthWithMaximumError: (float)maxError;
@end
