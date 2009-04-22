//
//  DKImageOverlayLayer.h
//  DrawingArchitecture
//
//  Created by graham on 28/08/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "DKLayer.h"


// coverage method flags - can be combined to give different effects

typedef enum
{
	kGCDrawingImageCoverageNormal					= 0,
	kGCDrawingImageCoverageHorizontallyCentred		= 1,
	kGCDrawingImageCoverageHorizontallyStretched	= 2,
	kGCDrawingImageCoverageHorizontallyTiled		= 4,
	kGCDrawingImageCoverageVerticallyCentred		= 32,
	kGCDrawingImageCoverageVerticallyStretched		= 64,
	kGCDrawingImageCoverageVerticallyTiled			= 128,
}
DKImageCoverageFlags;



@interface DKImageOverlayLayer : DKLayer <NSCoding>
{
	NSImage*				m_image;
	float					m_opacity;
	DKImageCoverageFlags	m_coverageMethod;
}

- (id)						initWithImage:(NSImage*) image;
- (id)						initWithContentsOfFile:(NSString*) imagefile;

- (void)					setImage:(NSImage*) image;
- (NSImage*)				image;

- (void)					setOpacity:(float) op;
- (float)					opacity;

- (void)					setCoverageMethod:(DKImageCoverageFlags) cm;
- (DKImageCoverageFlags)	coverageMethod;

- (NSRect)					imageDestinationRect;

@end



/*

This layer type implements a single image overlay, for example for tracing a photograph in another layer. The coverage method
sets whether the image is scaled, tiled or drawn only once in a particular position.

*/

