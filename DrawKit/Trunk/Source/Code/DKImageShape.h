///**********************************************************************************************************************************
///  DKImageShape.m
///  DrawKit
///
///  Created by graham on 23/08/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKDrawableShape.h"

// option constants for crop or scale image

typedef enum
{
	kDKImageScaleToPath		= 0,
	kDKImageCropToPath		= 1
}
DKImageCroppingOptions;


// the class

@interface DKImageShape : DKDrawableShape <NSCoding, NSCopying>
{
	NSImage*				m_image;				// the image the shape displays
	float					m_opacity;				// its opacity
	float					m_imageScale;			// its scale (currently ignored, but set to 1.0)
	NSPoint					m_imageOffset;			// the offset of the image within the bounds
	BOOL					m_drawnOnTop;			// YES if image drawn after style, NO for before
	NSCompositingOperation	m_op;					// the Quartz compositing mode to apply
	DKImageCroppingOptions	mImageCropping;			// whether the image is scaled or cropped to the bounds
	int						mImageOffsetPartcode;	// the partcode of the image offset hotspot
}


- (id)						initWithPasteboard:(NSPasteboard*) pboard;

- (id)						initWithImage:(NSImage*) anImage;
- (id)						initWithImageNamed:(NSString*) imageName;
- (id)						initWithContentsOfFile:(NSString*) filepath;

- (void)					setImage:(NSImage*) anImage;
- (NSImage*)				image;
- (BOOL)					setImageWithPasteboard:(NSPasteboard*) pb;

- (void)					setImageOpacity:(float) opacity;
- (float)					imageOpacity;

- (void)					setImageDrawsOnTop:(BOOL) onTop;
- (BOOL)					imageDrawsOnTop;

- (void)					setCompositingOperation:(NSCompositingOperation) op;
- (NSCompositingOperation)	compositingOperation;

- (void)					setImageScale:(float) scale;
- (float)					imageScale;

- (void)					setImageOffset:(NSPoint) imgoff;
- (NSPoint)					imageOffset;

- (void)					setImageCroppingOptions:(DKImageCroppingOptions) crop;
- (DKImageCroppingOptions)	imageCroppingOptions;

- (void)					drawImage;
- (NSAffineTransform*)		imageTransform;

// user actions

- (IBAction)				selectCropOrScaleAction:(id) sender;
- (IBAction)				toggleImageAboveAction:(id) sender;
- (IBAction)				pasteImage:(id) sender;
- (IBAction)				fitToImage:(id) sender;

@end


// metadata keys for data installed by this object when created

extern NSString*	kDKOriginalFileMetadataKey;
extern NSString*	kDKOriginalImageDimensionsMetadataKey;
extern NSString*	kDKOriginalNameMetadataKey;

/*

DKImageShape is a drawable shape that displays an image. The image is scaled and rotated to the path bounds and clipped to the
path. The opacity of the image can be set, and whether the image is drawn before or after the normal path rendering.

This object is quite flexible - by changing the path clipping and drawing styles, a very wide range of different effects are
possible. (n.b. if you don't attach a style, the path is not drawn at all [the default], but still clips the image. The default
path is a rect so that the entire image is drawn.

There are two basic modes of operation - scaling and cropping. Scaling fills the shape's bounds with the image. Cropping keeps the image at its
original size and allows the path to clip it as it is resized. In both cases the image offset can be used to position the image within the bounds.
A hotspot is added to allow the user to drag the image offset position around.

*/
