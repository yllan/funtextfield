///**********************************************************************************************************************************
///  DKQuartzBlendRastGroup.h
///  DrawKit
///
///  Created by graham on 30/06/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKRastGroup.h"


@interface DKQuartzBlendRastGroup : DKRastGroup <NSCoding, NSCopying>
{
	CGBlendMode				m_blendMode;
	float					m_alpha;
	NSImage*				m_maskImage;
}

- (void)					setBlendMode:(CGBlendMode) mode;
- (CGBlendMode)				blendMode;

- (void)					setAlpha:(float) alpha;
- (float)					alpha;

- (void)					setMaskImage:(NSImage*) image;
- (NSImage*)				maskImage;

@end



/*

Simple render group subclass that applies the set blend mode to the context for all of the renderers it contains,
yielding a wide range of available effects.


*/
