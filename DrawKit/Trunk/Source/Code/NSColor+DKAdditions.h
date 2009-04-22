///**********************************************************************************************************************************
///  NSColor+DKAdditions.h
///  DrawKit
///
///  Created by graham on 26/03/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>


@interface NSColor (DKAdditions)

+ (NSColor*)			rgbWhite;
+ (NSColor*)			rgbBlack;
+ (NSColor*)			rgbGrey:(float) grayscale;
+ (NSColor*)			rgbGrey:(float) grayscale withAlpha:(float) alpha;
+ (NSColor*)			rgbGreyWithLuminosityFrom:(NSColor*) colour withAlpha:(float) alpha;

+ (NSColor*)			veryLightGrey;

+ (NSColor*)			contrastingColor:(NSColor*) color;
+ (NSColor*)			colorWithWavelength:(float) lambda;
+ (NSColor*)			colorWithHexString:(NSString*) hex;

- (NSColor*)			colorWithHueFrom:(NSColor*) color;
- (NSColor*)			colorWithHueAndSaturationFrom:(NSColor*) color;
- (NSColor*)			colorWithRGBAverageFrom:(NSColor*) color;
- (NSColor*)			colorWithHSBAverageFrom:(NSColor*) color;

- (NSColor*)			colorWithRGBBlendFrom:(NSColor*) color blendingAmounts:(float[]) blends;
- (NSColor*)			colorWithHSBBlendFrom:(NSColor*) color blendingAmounts:(float[]) blends;

- (float)				luminosity;
- (NSColor*)			colorWithLuminosity;
- (NSColor*)			contrastingColor;
- (NSColor*)			invertedColor;

- (NSString*)			hexString;

- (CGColorRef)			quartzColor;

@end
