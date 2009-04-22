///**********************************************************************************************************************************
///  DKStroke.h
///  DrawKit
///
///  Created by graham on 09/11/2006.
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


@interface DKStroke : DKRasterizer <NSCoding, NSCopying>
{
	NSColor*			m_colour;
	DKLineDash*			m_dash;
	NSShadow*			m_shadow;
	NSLineCapStyle		m_cap;
	NSLineJoinStyle		m_join;
	
	float				m_width;
	float				m_pathScale;
	float				m_trimLength;
	int					m_strokePosition;
}

+ (DKStroke*)			defaultStroke;
+ (DKStroke*)			strokeWithWidth:(float) width colour:(NSColor*) colour;

- (id)					initWithWidth:(float) width colour:(NSColor*) colour;

- (void)				setColour:(NSColor*) colour;
- (NSColor*)			colour;

- (void)				setWidth:(float) width;
- (float)				width;
- (void)				scaleWidthBy:(float) scale;
- (float)				allowance;

- (void)				setDash:(DKLineDash*) dash;
- (DKLineDash*)			dash;
- (void)				setAutoDash;

- (void)				setStrokePosition:(int) sp;
- (int)					strokePosition;
- (void)				setPathScaleFactor:(float) psf;
- (float)				pathScaleFactor;

- (void)				setShadow:(NSShadow*) shadow;
- (NSShadow*)			shadow;

- (void)				strokeRect:(NSRect) rect;
- (void)				applyAttributesToPath:(NSBezierPath*) path;

- (void)				setLineCapStyle:(NSLineCapStyle) lcs;
- (NSLineCapStyle)		lineCapStyle;

- (void)				setLineJoinStyle:(NSLineJoinStyle) ljs;
- (NSLineJoinStyle)		lineJoinStyle;

- (void)				setTrimLength:(float) tl;
- (float)				trimLength;


@end


enum
{
	kGCStrokePathCentreLine			= 0,
	kGCStrokePathInside				= 1,
	kGCStrokePathOutside			= 2
};


/*

represents the stroke of a path, and can be added as an attribute of a DKStyle. Note that because a stroke
is an object, it's easy to stroke a path multiple times for special effects. A DKStyle will apply all
the strokes it is aware of in order when it is asked to stroke a path.

DKStyle can contains a list of strokes without limit.

*/
