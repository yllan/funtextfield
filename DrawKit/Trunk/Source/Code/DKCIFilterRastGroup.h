///**********************************************************************************************************************************
///  DKCIFilterRastGroup.h
///  DrawKit
///
///  Created by graham on 16/03/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKRastGroup.h"


@interface DKCIFilterRastGroup : DKRastGroup <NSCoding, NSCopying>
{
	NSString*		m_filter;
	NSDictionary*	m_arguments;
	BOOL			m_clipToPath;
	NSImage*		m_cache;
}

+ (DKCIFilterRastGroup*)	effectGroupWithFilter:(NSString*) filter;

- (void)					setFilter:(NSString*) filter;
- (NSString*)				filter;

- (void)					setArguments:(NSDictionary*) dict;
- (NSDictionary*)			arguments;

- (void)					setClipsToPath:(BOOL) ctp;
- (BOOL)					clipsToPath;

- (void)					invalidateCache;

@end

@interface NSImage (CoreImage)
/* Draws the specified image using Core Image. */
- (void)drawAtPoint: (NSPoint)point fromRect: (NSRect)fromRect coreImageFilter: (NSString *)filterName arguments: (NSDictionary *)arguments;

/* Gets a bitmap representation of the image, or creates one if the image does not have any. */
- (NSBitmapImageRep *)bitmapImageRepresentation;
@end


#define CIIMAGE_PADDING 32.0f

@interface NSBitmapImageRep (CoreImage)
/* Draws the specified image representation using Core Image. */
- (void)drawAtPoint: (NSPoint)point fromRect: (NSRect)fromRect coreImageFilter: (NSString *)filterName arguments: (NSDictionary *)arguments;
@end

/*

This class implements a special rendergroup that captures the output of its contained renderers in an image, then
allows that image to be manipulated or processed (e.g. by core image) before rendering it back to the drawing. This
allows us to leverage all sorts of imaging code to extend the range of available styles and effects.

*/
