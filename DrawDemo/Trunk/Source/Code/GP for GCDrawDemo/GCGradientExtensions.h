//
//  GCGradientExtensions.h
//  GradientTest
//
//  Created by Jason Jobe on 3/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "GCGradient.h"


@interface NSView (GCGradientExtensions)

- (void) dragGradient:(GCGradient*)gradient swatchSize:(NSSize)size
			slideBack:(BOOL)slideBack event:(NSEvent *)event;

- (void) dragStandardSwatchGradient:(GCGradient*)gradient slideBack:(BOOL)slideBack event:(NSEvent *)event;

- (void) dragColor:(NSColor*)color swatchSize:(NSSize)size slideBack:(BOOL)slideBack event:(NSEvent *)event;

@end

@interface NSColor (GCGradientExtensions)

- (NSImage*) swatchImageWithSize:(NSSize) size withBorder:(BOOL) showBorder;

@end



@interface GCGradient (GCGradientExtensions)

- (void)		initExtensionData;

- (void)		setRadialStartingPoint:(NSPoint) p;
- (void)		setRadialEndingPoint:(NSPoint) p;
- (void)		setRadialStartingRadius:(float) rad;
- (void)		setRadialEndingRadius:(float) rad;

- (NSPoint)		radialStartingPoint;
- (NSPoint)		radialEndingPoint;
- (float)		radialStartingRadius;
- (float)		radialEndingRadius;

- (BOOL)		hasRadialSettings;

- (NSPoint)		mapPoint:(NSPoint) p fromRect:(NSRect) rect;
- (NSPoint)		mapPoint:(NSPoint) p toRect:(NSRect) rect;

- (void)		setNumberOfAngularSegments:(int) seg;
- (int)			numberOfAngularSegments;

- (void)		convertOldKey:(NSString*) key;
- (void)		convertOldKeys;

@end


@interface		NSDictionary (StructEncoding)

- (void)		setPoint:(NSPoint) p forKey:(id) key;
- (NSPoint)		pointForKey:(id) key;

- (void)		setFloat:(float) f forKey:(id) key;
- (float)		floatForKey:(id) key;

@end