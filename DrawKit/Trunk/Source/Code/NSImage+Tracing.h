///**********************************************************************************************************************************
///  NSImage+Tracing.h
///  DrawKit
///
///  Created by graham on 23/06/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#ifdef qUsePotrace

#import <Cocoa/Cocoa.h>
#import "potracelib.h"

// possible values for the quantization method (not all implemented)

typedef enum
{
	kGCColourQuantizeUniform	= 0,		// implemented, very basic results but fast
	kGCColourQuantizePopular555	= 1,
	kGCColourQuantizePopular444	= 2,
	kGCColourQuantizeOctree		= 3,		// implemented, fairly good results and fast
	kGCColourQuantizeMedianCut	= 4
}
DKColourQuantizationMethod;


// category on NSImage returns lists of 'vector rep' objects (see below)

@interface NSImage (Tracing)

- (NSArray*)			vectorizeToGrayscale:(int) levels;
- (NSArray*)			vectorizeToColourWithPrecision:(int) prec quantizationMethod:(DKColourQuantizationMethod) qm;

- (NSBitmapImageRep*)	eightBitImageRep;
- (NSBitmapImageRep*)	twentyFourBitImageRep;

@end

// the 'vector rep' object represents each bitplane or separate colour in the image, and will perform the vectorization
// using potrace when the vector data is requested (lazy vectorization).

@interface DKImageVectorRep	: NSObject
{
	potrace_bitmap_t*	mBits;
	unsigned			mLevels;
	unsigned			mPixelValue;
	potrace_param_t*	mTraceParams;
	NSBezierPath*		mVectorData;
	NSColor*			mColour;
}

- (id)					initWithImageSize:(NSSize) isize pixelValue:(unsigned) pixv levels:(unsigned) lev;

- (potrace_bitmap_t*)	bitmap;

// get the traced path, performing the trace if needed

- (NSBezierPath*)		vectorPath;

// colour from original image associated with this bitplane

- (void)				setColour:(NSColor*) cin;
- (NSColor*)			colour;

// tracing parameters

- (void)				setTurdSize:(int) turdsize;
- (int)					turdSize;

- (void)				setTurnPolicy:(int) turnPolicy;
- (int)					turnPolicy;

- (void)				setAlphaMax:(double) alphaMax;
- (double)				alphaMax;

- (void)				setOptimizeCurve:(BOOL) opt;
- (BOOL)				optimizeCurve;

- (void)				setOptimizeTolerance:(double) optTolerance;
- (double)				optimizeTolerance;

- (void)				setTracingParameters:(NSDictionary*) dict;
- (NSDictionary*)		tracingParameters;

@end

// dict keys used to set tracing parameters from a dictionary

extern NSString*	kGCTracingParam_turdsize;			// integer value, sets pixel area below which is not traced
extern NSString*	kGCTracingParam_turnpolicy;			// integer value, turn policy
extern NSString*	kGCTracingParam_alphamax;			// double value, sets smoothness of corners
extern NSString*	kGCTracingParam_opticurve;			// boolean value, 1 = simplify curves, 0 = do not simplify
extern NSString*	kGCTracingParam_opttolerance;		// double value, epsilon limit for curve fit



/*

This image category implements image vectorization using Peter Selinger's potrace algorithm and OSS code.

It works as follows:

// stage 1:

1. A 24-bit bit image is made from the NSImage contents (ensures that regardless of image format, we have a standard RGB bitmap to work from)
2. The image is analysed using a quantizer to determine the best set of colours needed to represent it at the chosen sampling value
3. A DKImageVectorRep is allocated for each colour. This allocates a bitmap data structure that potrace can work with.
4. The 24-bit image is scanned and the corresponding bits in the bit images are set according to the index value returned by the quantizer
5. Empty bitplanes are discarded
6. The resulting list of DKImageVectorRep objects is returned

// stage 2:

7. The client code requests the vector path from the DKImageVectorRep. This triggers a call to potrace with the generated bitmap for that colour
8. The client assembles the resulting paths into objects that can use the paths, for example DKDrawableShapes.
9. The client assembles the shapes into a group and adds it to the drawing.

(Steps 8 and 9 are what is done in DrawKit - other client code might have other ideas).

Note that the API to this operates at a high level in a category on DKImageShape - see DKImageShape+Vectorization.

*/

#endif /* defined qUsePotrace */
