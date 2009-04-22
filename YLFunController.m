//
//  YLFunTextFieldController.m
//  FunTextField
//
//  Created by Yung-Luen Lan on 6/22/08.
//  Copyright 2008 yllan.org. All rights reserved.
//

#import "YLFunController.h"
#import "YLFunTextView.h"
#import "YLBezierLayoutManager.h"
#import "YLTextStorage.h"
#import "NSBezierPath+Utility.h"

@implementation YLFunController
@synthesize textView = _textView;

- (void) awakeFromNib 
{
    // create bezier path
    NSPoint startPoint = NSMakePoint(10, 150);
    int direction = -1, numberOfWave = 10, i;
    CGFloat waveLength = 100, amplitude = 80, delta = 20;
    
    NSBezierPath *path = [NSBezierPath bezierPath];
    [path moveToPoint: NSMakePoint(200, 300)];
    [path moveToPoint: NSMakePoint(10, 24)];
    [path moveToPoint: startPoint];
    
    for (i = 0; i < numberOfWave; i++) {
        NSPoint endPoint = NSMakePoint(startPoint.x  + waveLength, startPoint.y);
        [path curveToPoint: endPoint controlPoint1: NSMakePoint(startPoint.x + delta, startPoint.y + direction * amplitude) controlPoint2: NSMakePoint(endPoint.x - delta, endPoint.y + direction * amplitude)];
        direction *= -1;
        startPoint = endPoint;
    }
    
    // add path to layout manager
    _textView.layoutManager = [YLBezierLayoutManager layoutManagerWithBezierPath: [path bezierPathByStrippingRedundantElements]];
    
    // create text storage
    YLTextStorage *storage = [YLTextStorage textStorage];
    NSMutableAttributedString *s = [[[NSMutableAttributedString alloc] initWithString: [NSString stringWithUTF8String: "Thé quick brown fox jumps over the lazy dog. 繁简にほん"]] autorelease];
    [s setAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [NSFont fontWithName: @"Times" size: 32.0], NSFontAttributeName, nil] range: NSMakeRange(0, [s length])];
    [s setAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [NSFont fontWithName: @"Marker Felt" size: 38.0], NSFontAttributeName, [NSColor brownColor], NSForegroundColorAttributeName, nil] range: NSMakeRange(10, 5)];
    [s setAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [NSFont fontWithName: @"Zapfino" size: 22.0], NSFontAttributeName, nil] range: NSMakeRange(16, 1)];
    [s setAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [NSFont fontWithName: @"Apple LiGothic" size: 40.0], NSFontAttributeName, nil] range: NSMakeRange([s length] - 5, 1)];
    [s setAttributes: [NSDictionary dictionaryWithObjectsAndKeys: [NSFont fontWithName: @"Kai" size: 24.0], NSFontAttributeName, nil] range: NSMakeRange([s length] - 4, 1)];
    [storage loadText: s];
    _textView.textStorage = storage;
}

@end
