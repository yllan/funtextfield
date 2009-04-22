///**********************************************************************************************************************************
///  DKPathDecorator.h
///  DrawKit
///
///  Created by graham on 17/06/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKRasterizer.h"


@interface DKPathDecorator : DKRasterizer <NSCoding, NSCopying>
{
	NSImage*			m_image;
	NSPDFImageRep*		m_pdf;
	
	float				m_scale;
	float				m_interval;
	float				m_leader;
	float				m_leadInLength;
	float				m_leadOutLength;
	float				m_liloProportion;
	
	BOOL				m_normalToPath;
	BOOL				m_useChainMethod;
	CGLayerRef			m_cache;
	BOOL				m_lowQuality;
	int					m_pathClip;
}

+ (DKPathDecorator*)	pathDecoratorWithImage:(NSImage*) image;

- (id)					initWithImage:(NSImage*) image;

- (void)				setImage:(NSImage*) image;
- (NSImage*)			image;
- (void)				setUpCache;
- (void)				setPDFImageRep:(NSPDFImageRep*) rep;

- (void)				setScale:(float) scale;
- (float)				scale;

- (void)				setInterval:(float) interval;
- (float)				interval;

- (void)				setLeaderDistance:(float) leader;
- (float)				leaderDistance;

- (void)				setNormalToPath:(BOOL) normal;
- (BOOL)				normalToPath;

- (void)				setPathClipping:(int) clipping;
- (int)					pathClipping;

- (void)				setLeadInLength:(float) linLength;
- (void)				setLeadOutLength:(float) loutLength;
- (float)				leadInLength;
- (float)				leadOutLength;

- (void)				setLeadInAndOutLengthProportion:(float) proportion;
- (float)				leadInAndOutLengthProportion;
- (float)				rampFunction:(float) val;

- (void)				setUsesChainMethod:(BOOL) chain;
- (BOOL)				usesChainMethod;

@end

// clipping values:


enum
{
	kGCPathDecoratorClippingNone	= 0,
	kGCPathDecoratorClipOutsidePath	= 1,
	kGCPathDecoratorClipInsidePath	= 2
};

/*

This renderer draws the image along the path of another object spaced at <interval> distance. Each image is scaled by <scale> and is
rotated to be normal to the path unless _normalToPath is NO.

This prefers PDF image representations where the image contains one, preserving resolution as the drawing is scaled.

*/
