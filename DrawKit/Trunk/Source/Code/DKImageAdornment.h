///**********************************************************************************************************************************
///  DKImageAdornment.h
///  DrawKit
///
///  Created by graham on 15/05/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKRasterizer.h"


@class DKDrawableObject;

// fitting options:

typedef enum
{
	kGCScaleToFitBounds					= 0,			// scale setting ignored - image will fill bounds
	kGCScaleToFitPreservingAspectRatio	= 1,			// scale setting ignored - image will fit bounds with original aspect ratio preserved
	kGCClipToBounds						= 2				// scales according to setting, but clipped to object's path if size exceeds it
}
DKImageFittingOption;




@interface DKImageAdornment : DKRasterizer <NSCoding, NSCopying>
{
	NSImage*				m_image;
	float					m_scale;
	float					m_opacity;
	float					m_angle;
	NSPoint					m_origin;
	NSCompositingOperation	m_op;
	DKImageFittingOption	m_fittingOption;
	NSString*				m_imageIdentifier;
	BOOL					m_clipToPath;
}

+ (DKImageAdornment*)	imageAdornmentWithImage:(NSImage*) image;
+ (DKImageAdornment*)	imageAdornmentWithImageFromFile:(NSString*) path;

- (void)				setImage:(NSImage*) image;
- (NSImage*)			image;
- (void)				setImageIdentifier:(NSString*) imageID;
- (NSString*)			imageIdentifier;

- (void)				setScale:(float) scale;
- (float)				scale;

- (void)				setOpacity:(float) opacity;
- (float)				opacity;

- (void)				setOrigin:(NSPoint) origin;
- (NSPoint)				origin;

- (void)				setAngle:(float) angle;
- (float)				angle;
- (void)				setAngleInDegrees:(float) degrees;
- (float)				angleInDegrees;

- (void)				setOperation:(NSCompositingOperation) op;
- (NSCompositingOperation) operation;

- (void)				setFittingOption:(DKImageFittingOption) fopt;
- (DKImageFittingOption) fittingOption;

- (void)				setClipsToPath:(BOOL) ctp;
- (BOOL)				clipsToPath;

- (NSAffineTransform*)	imageTransformForObject:(DKDrawableObject*) renderableObject;

@end



/*

This class allows any image to be part of the rendering tree. 

*/
