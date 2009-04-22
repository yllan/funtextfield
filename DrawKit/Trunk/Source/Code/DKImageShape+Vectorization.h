///**********************************************************************************************************************************
///  DKImageShape+Vectorization.h
///  DrawKit
///
///  Created by graham on 25/06/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#ifdef qUsePotrace

#import "DKImageShape.h"
#import "NSImage+Tracing.h"

@class DKShapeGroup;


typedef enum
{
	kGCVectorizeGrayscale	= 0,
	kGCVectorizeColour		= 1
}
DKVectorizingMethod;

// this category implements very high-level vectorizing operations on an image shape. At its simplest,
// it vectorizes the image using the default settings and replaces the image object by a group containing the
// shapes resulting. For the user, this looks like a vectorization operation was applied "in place".

// Apps are free to implement this in a more controlled way if they wish, for example by using a dialog
// to set up the various parameters.

// Be sure to also check out NSImage+Tracing because that's where the real work is done.


@interface DKImageShape (Vectorization)

+ (void)			setPreferredVectorizingMethod:(DKVectorizingMethod) method;
+ (void)			setPreferredVectorizingLevels:(int) levelsOfGray;
+ (void)			setPreferredVectorizingPrecision:(int) colourPrecision;
+ (void)			setPreferredQuantizationMethod:(DKColourQuantizationMethod) qm;

+ (void)			setTracingParameters:(NSDictionary*) traceInfo;
+ (NSDictionary*)	tracingParameters;

- (DKShapeGroup*)	makeGroupByVectorizing;
- (DKShapeGroup*)	makeGroupByGrayscaleVectorizingWithLevels:(int) levelsOfGray;
- (DKShapeGroup*)	makeGroupByColourVectorizingWithPrecision:(int) colourPrecision;

- (NSArray*)		makeObjectsByVectorizing;
- (NSArray*)		makeObjectsByGrayscaleVectorizingWithLevels:(int) levelsOfGray;
- (NSArray*)		makeObjectsByColourVectorizingWithPrecision:(int) colourPrecision;

- (IBAction)		vectorize:(id) sender;

@end


// additional dict keys that can be set in the trace params:

extern NSString*	kGCIncludeStrokeStyle;		// BOOL
extern NSString*	kGCStrokeStyleWidth;		// float
extern NSString*	kGCStrokeStyleColour;		// NSColor


#endif /* defined qUsePotrace */

