///**********************************************************************************************************************************
///  DKArrowStroke.h
///  DrawKit
///
///  Created by graham on 20/03/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKStroke.h"


// arrow head kinds - each end can be specified independently:

typedef enum
{
	kDKArrowHeadNone					= 0,
	kDKArrowHeadStandard				= 1,
	kDKArrowHeadInflected				= 2,
	kDKArrowHeadRound					= 3,
	kDKArrowHeadSingleFeather			= 4,
	kDKArrowHeadDoubleFeather			= 5,
	kDKArrowHeadTripleFeather			= 6,
	kDKArrowHeadDimensionLine			= 7,
	kDKArrowHeadDimensionLineAndBar		= 8
}
DKArrowHeadKind;


typedef enum
{
	kDKDimensionNone					= 0,
	kDKDimensionPlaceAboveLine			= 1,
	kDKDimensionPlaceInLine				= 2,
	kDKDimensionPlaceBelowLine			= 3
}
DKDimensioningLineOptions;

// the class:

@interface DKArrowStroke : DKStroke <NSCoding, NSCopying>
{
	DKArrowHeadKind				mArrowHeadAtStart;
	DKArrowHeadKind				mArrowHeadAtEnd;
	float						m_arrowLength;
	float						m_arrowWidth;
	DKDimensioningLineOptions	mDimensionOptions;
	NSNumberFormatter*			m_dims_formatter;
	NSColor*					m_outlineColour;
	float						m_outlineWidth;
}

+ (void)						setDimensioningLineTextAttributes:(NSDictionary*) attrs;
+ (NSDictionary*)				dimensioningLineTextAttributes;
+ (DKArrowStroke*)				standardDimensioningLine;

// head kind at each end

- (void)						setArrowHeadAtStart:(DKArrowHeadKind) kind;
- (void)						setArrowHeadAtEnd:(DKArrowHeadKind) kind;
- (DKArrowHeadKind)				arrowHeadAtStart;
- (DKArrowHeadKind)				arrowHeadAtEnd;

// head widths and lengths (some head kinds may set these also)

- (void)						setArrowHeadWidth:(float) width;
- (float)						arrowHeadWidth;
- (void)						setArrowHeadLength:(float) length;
- (float)						arrowHeadLength;

- (void)						standardArrowForStrokeWidth:(float) sw;

- (void)						setOutlineColour:(NSColor*) colour width:(float) width;
- (NSColor*)					outlineColour;
- (float)						outlineWidth;

- (NSImage*)					arrowSwatchImageWithSize:(NSSize) size strokeWidth:(float) width;
- (NSImage*)					standardArrowSwatchImage;

- (NSBezierPath*)				arrowPathFromOriginalPath:(NSBezierPath*) inPath fromObject:(id) obj;

// dimensioning lines:

- (void)						setFormatter:(NSNumberFormatter*) fmt;
- (NSNumberFormatter*)			formatter;
- (void)						setFormat:(NSString*) format;

- (void)						setDimensioningLineOptions:(DKDimensioningLineOptions) dimOps;
- (DKDimensioningLineOptions)	dimensioningLineOptions;

- (NSAttributedString*)			dimensionTextForObject:(id) obj;
- (float)						widthOfDimensionTextForObject:(id) obj;


@end


#define			kGCStandardArrowSwatchImageSize		(NSMakeSize( 80.0, 9.0 ))
#define			kGCStandardArrowSwatchStrokeWidth	3.0

/*

DKArrowStroke is a rasterizer that implements arrowheads on the ends of paths. The heads are drawn by filling the
arrowhead using the same colour as the stroke, thus seamlessly blending the head into the path. Where multiple
strokes are used, the resulting effect should be correct when angles are kept the same and lengths are calculated
from the stroke width.

*/
