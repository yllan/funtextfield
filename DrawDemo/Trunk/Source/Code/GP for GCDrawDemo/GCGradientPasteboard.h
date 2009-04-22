//
//  GCGradientPasteboard.h
//  GradientTest
//
//  Created by Jason Jobe on 4/5/07.
//  Released under the Creative Commons license 2006 Datalore, LLC.
//
// 
//  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
//  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
//
//***********************************************************************************************

#import "GCDrawKit/DKGradient.h"


@interface DKGradient (GCGradientPasteboard)

// Pasteboard Support

+ (NSArray*)			readablePasteboardTypes;
+ (NSArray*)			writablePasteboardTypes;

+ (BOOL)				canInitalizeFromPasteboard:(NSPasteboard*)pboard;
+ (void)				setPasteboardImageSize:(NSSize) pbiSize;
+ (DKGradient*)			gradientWithPasteboard:(NSPasteboard*) pboard;
+ (DKGradient*)			gradientWithPlist:(NSDictionary*) plist;

- (BOOL)				writeToPasteboard:(NSPasteboard*) pboard;
- (BOOL)				writeType:(NSString*)type toPasteboard:(NSPasteboard*) pboard;

- (NSData*)				pdf;
- (NSData*)				eps;

// File interface

+ (DKGradient*)			gradientWithContentsOfFile:(NSString*) path;
- (BOOL)				writeToFile:(NSString*) path atomically:(BOOL) flag;
- (NSData*)				fileRepresentation;
- (NSFileWrapper*)		fileWrapperRepresentation;
- (NSDictionary*)		plistRepresentation;

- (BOOL)				writeFileToPasteboard:(NSPasteboard*) pboard;

@end

// Gradient Library Keys
extern NSString*	GCGradientInfoKey;
extern NSString*	GCGradientsKey;

// Pasteboard and file types
extern NSString*	GPGradientPasteboardType;
extern NSString*	GPGradientLibPasteboardType;
extern NSString*	GradientFileExtension;
