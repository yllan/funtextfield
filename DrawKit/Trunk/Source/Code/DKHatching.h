///**********************************************************************************************************************************
///  DKHatching.h
///  DrawKit
///
///  Created by graham on 06/10/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKRasterizer.h"


@class DKLineDash;


@interface DKHatching : DKRasterizer <NSCoding, NSCopying>
{
	NSBezierPath*	m_cache;
	NSColor*		m_hatchColour;
	DKLineDash*		m_hatchDash;
	NSLineCapStyle	m_cap;
	NSLineJoinStyle	m_join;
	float			m_leadIn;
	float			m_spacing;
	float			m_angle;
	float			m_lineWidth;
	BOOL			m_angleRelativeToObject;
}

+ (DKHatching*)		defaultHatching;

- (void)			hatchPath:(NSBezierPath*) path;
- (void)			hatchPath:(NSBezierPath*) path objectAngle:(float) oa;

- (void)			setAngle:(float) radians;
- (float)			angle;
- (void)			setAngleInDegrees:(float) degs;
- (float)			angleInDegrees;
- (void)			setAngleIsRelativeToObject:(BOOL) rel;
- (BOOL)			angleIsRelativeToObject;

- (void)			setSpacing:(float) spacing;
- (float)			spacing;
- (void)			setLeadIn:(float) amount;
- (float)			leadIn;

- (void)			setWidth:(float) width;
- (float)			width;
- (void)			setLineCapStyle:(NSLineCapStyle) lcs;
- (NSLineCapStyle)	lineCapStyle;
- (void)			setLineJoinStyle:(NSLineJoinStyle) ljs;
- (NSLineJoinStyle)	lineJoinStyle;

- (void)			setColour:(NSColor*) colour;
- (NSColor*)		colour;

- (void)			setDash:(DKLineDash*) dash;
- (DKLineDash*)		dash;
- (void)			setAutoDash;

- (void)			invalidateCache;
- (void)			calcHatchInRect:(NSRect) rect;

@end



/*

This class provides a simple hatching fill for a path. It draws equally-spaced solid lines of a given thickness at a
particular angle. Subclass for more sophisticated hatches.

Can be set as a fill style in a DKStyle object.

The hatch is cached in an NSBezierPath object based on the bounds of the path. If another path is hatched that is smaller
than the cached size, it is not rebuilt. It is rebuilt if the angle or spacing changes or a bigger path is hatched. Linewidth also
doesn't change the cache.

*/
