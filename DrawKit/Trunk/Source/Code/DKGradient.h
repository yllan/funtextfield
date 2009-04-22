///**********************************************************************************************************************************
///  DKGradient.h
///  DrawKit
///
///  Created by graham on 2/03/05.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "GCObservableObject.h"


@class DKColorStop;


// gradient type:

typedef enum
{
	kGCGradientTypeLinear		= 0,
	kGCGradientTypeRadial		= 1,
	kGCGradientSweptAngle		= 3
}
DKGradientType;

// gradient blending mode:

typedef enum
{
	kGCGradientRGBBlending			= 0,
	kGCGradientHSBBlending			= 1,
	kGCGradientAlphaBlending		= 64
}
DKGradientBlending;


typedef enum
{
	kGCGradientInterpLinear			= 0,
	kGCGradientInterpQuadratic		= 2,
	kGCGradientInterpCubic			= 3,
	kGCGradientInterpSinus			= 4,
	kGCGradientInterpSinus2			= 5
}
DKGradientInterpolation;

// A DKGradient encapsulates gradient/shading drawing.

@interface DKGradient : GCObservableObject <NSCoding, NSCopying>
{
	NSMutableArray*			m_colorStops;		// color stops
	id						m_extensionData;	// additional supplementary data 
	CGShadingRef			m_shader;			// the shading
	CGFunctionRef			m_cbfunc;			// callback function
	float					m_gradAngle;		// linear angle in radians
	DKGradientType			m_gradType;			// type
	DKGradientBlending		m_blending;			// method to blend colours
	DKGradientInterpolation	m_interp;			// interpolation function
}

// simple gradient convenience methods

+ (DKGradient*)			defaultGradient;
+ (DKGradient*)			gradientWithStartingColor:(NSColor*) c1 endingColor:(NSColor*) c2;
+ (DKGradient*)			gradientWithStartingColor:(NSColor*) c1 endingColor:(NSColor*) c2 type:(int) gt angle:(float) degrees;

// modified copies:

- (DKGradient*)			gradientByColorizingWithColor:(NSColor*) color;
- (DKGradient*)			gradientWithAlpha:(float) alpha;

// setting up the Color stops

- (DKColorStop*)		addColor:(NSColor*) Color at:(float) pos;
- (void)				addColorStop:(DKColorStop*) stop;
- (void)				removeLastColor;
- (void)				removeColorStop:(DKColorStop*) stop;
- (void)				removeAllColors;

- (void)				setColorStops:(NSArray*) stops;
- (NSArray*)			colorStops;
- (void)				sortColorStops;
- (void)				reverseColorStops;

// KVO compliant accessors:

- (unsigned int)		countOfColorStops;
- (DKColorStop*)		objectInColorStopsAtIndex:(unsigned int) ix;
- (void)				insertObject:(DKColorStop*) stop inColorStopsAtIndex:(unsigned int) ix;
- (void)				removeObjectFromColorStopsAtIndex:(unsigned int) ix;

// a variety of ways to fill a path

- (void)				fillRect:(NSRect)rect;
- (void)				fillPath:(NSBezierPath*) path;
- (void)				fillPath:(NSBezierPath*) path centreOffset:(NSPoint) co;
- (void)				fillPath:(NSBezierPath*) path startingAtPoint:(NSPoint) sp
								startRadius:(float) sr endingAtPoint:(NSPoint) ep endRadius:(float) er;

- (void)				fillContext:(CGContextRef) context startingAtPoint:(NSPoint) sp
								startRadius:(float) sr endingAtPoint:(NSPoint) ep endRadius:(float) er;

- (NSColor*)			colorAtValue:(float) val;

// setting the angle

- (void)				setAngle:(float) ang;
- (float)				angle;
- (void)				setAngleInDegrees:(float) degrees;
- (float)				angleInDegrees;
- (void)				setAngleWithoutNotifying:(float) ang;

// setting gradient type, blending and interpolation settings

- (void)				setGradientType:(DKGradientType) gt;
- (DKGradientType)		gradientType;

- (void)				setGradientBlending:(DKGradientBlending) bt;
- (DKGradientBlending)  gradientBlending;

- (void)				setGradientInterpolation:(DKGradientInterpolation) intrp;
- (DKGradientInterpolation)	gradientInterpolation;

// swatch images

- (NSImage*)			swatchImageWithSize:(NSSize) size withBorder:(BOOL) showBorder;
- (NSImage*)			standardSwatchImage;

// script support:

- (NSString*)			styleScript;

@end

#define DKGradientSwatchSize (NSMakeSize (20, 20))

#pragma mark -
/// DKColorStop class - small object that links a Color with its relative position

@interface DKColorStop : NSObject <NSCoding, NSCopying>
{
	NSColor*			mColor;
	float				position;
	DKGradient*			m_ownerRef;
@public
	float				components[4];  // cached rgba values
}

- (id)					initWithColor:(NSColor*) aColor at:(float) pos;

- (NSColor*)			color;
- (void)				setColor:(NSColor*) aColor;
- (void)				setAlpha:(float) alpha;

- (float)				position;
- (void)				setPosition:(float) pos;

- (NSString*)			styleScript;

@end

// notifications sent by DKGradient:

extern NSString*	kGCNotificationGradientWillAddColorStop;
extern NSString*	kGCNotificationGradientDidAddColorStop;
extern NSString*	kGCNotificationGradientWillRemoveColorStop;
extern NSString*	kGCNotificationGradientDidRemoveColorStop;
extern NSString*	kGCNotificationGradientWillChange;
extern NSString*	kGCNotificationGradientDidChange;

// DKGradient is a simplified version of GCGradient as used in GradientPanel. Because this responds to exactly the same
// methods, you can cast a GCGradient to a DKGradient and it will work. This allows the GradientPanel to be used in a DK-based
// application without there being a clash between different frameworks.

// DKGradient drops the UI convenience methods and support for wavelength-based gradients
