///**********************************************************************************************************************************
///  DKSweptAngleGradient.h
///  DrawKit
///
///  Created by graham on 13/07/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKGradient.h"


typedef union
{
	unsigned long pixel;
	struct
	{
		unsigned char a;
		unsigned char r;
		unsigned char g;
		unsigned char b;
	}
	c;
}
pix_int;



@interface DKSweptAngleGradient : DKGradient
{
	CGImageRef		m_sa_image;
	CGContextRef	m_sa_bitmap;
	pix_int*		m_sa_colours;
	int				m_sa_segments;
	NSPoint			m_sa_centre;
	float			m_sa_startAngle;
	int				m_sa_img_width;
	BOOL			m_ditherColours;
}

+ (DKGradient*)		sweptAngleGradient;
+ (DKGradient*)		sweptAngleGradientWithStartingColor:(NSColor*) c1 endingColor:(NSColor*) c2;

- (void)			setNumberOfAngularSegments:(int) ns;
- (int)				numberOfAngularSegments;

- (void)			preloadColours;
- (void)			createGradientImageWithRect:(NSRect) rect;
- (void)			invalidateCache;

@end
