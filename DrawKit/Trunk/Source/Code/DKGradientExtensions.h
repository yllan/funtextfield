//
//  DKGradientExtensions.h
//  GradientTest
//
//  Created by Jason Jobe on 3/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DKGradient.h"


@interface NSView (DKGradientExtensions)

- (void) dragGradient:(DKGradient*)gradient swatchSize:(NSSize)size
			slideBack:(BOOL)slideBack event:(NSEvent *)event;

- (void) dragStandardSwatchGradient:(DKGradient*)gradient slideBack:(BOOL)slideBack event:(NSEvent *)event;

- (void) dragColor:(NSColor*)color swatchSize:(NSSize)size slideBack:(BOOL)slideBack event:(NSEvent *)event;

@end

@interface NSColor (DKGradientExtensions)

- (NSImage*) swatchImageWithSize:(NSSize) size withBorder:(BOOL) showBorder;

@end



@interface DKGradient (DKGradientExtensions)

- (void)		setUpExtensionData;

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

- (void)		convertOldKey:(NSString*) key;
- (void)		convertOldKeys;

@end


@interface		NSDictionary (StructEncoding)

- (void)		setPoint:(NSPoint) p forKey:(id) key;
- (NSPoint)		pointForKey:(id) key;

- (void)		setFloat:(float) f forKey:(id) key;
- (float)		floatForKey:(id) key;

@end

