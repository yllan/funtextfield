///**********************************************************************************************************************************
///  NSColor+DKAdditions.m
///  DrawKit
///
///  Created by graham on 26/03/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "NSColor+DKAdditions.h"

#import "LogEvent.h"


@implementation NSColor (DKAdditions)
#pragma mark As an NSColor
///*********************************************************************************************************************
///
/// method:			rgbWhite
/// scope:			public class method
/// overrides:		
/// description:	returns the Color white as an RGB Color
/// 
/// parameters:		none
/// result:			the Color white
///
/// notes:			uses the RGB Color space, not the greyscale Colorspace you get with NSColor's whiteColor
///					method. Gradients currently only work with RGB Colors.
///
///********************************************************************************************************************

+ (NSColor*)			rgbWhite
{
	return [self rgbGrey:1.0];
}


///*********************************************************************************************************************
///
/// method:			rgbBlack
/// scope:			public class method
/// overrides:		
/// description:	returns the Color black as an RGB Color
/// 
/// parameters:		none
/// result:			the Color black
///
/// notes:			uses the RGB Color space, not the greyscale Colorspace you get with NSColor's blackColor
///					method. Gradients currently only work with RGB Colors.
///
///********************************************************************************************************************

+ (NSColor*)			rgbBlack
{
	return [self rgbGrey:0.0];
}


///*********************************************************************************************************************
///
/// method:			rgbGrey:
/// scope:			public class method
/// overrides:		
/// description:	returns a grey RGB Color
/// 
/// parameters:		<grayscale> 0 to 1.0
/// result:			a grey Color
///
/// notes:			uses the RGB Color space, not the greyscale Colorspace you get with NSColor's grey
///					method. Gradients currently only work with RGB Colors.
///
///********************************************************************************************************************

+ (NSColor*)			rgbGrey:(float) grayscale
{
	return [self rgbGrey:grayscale withAlpha:1.0];
}


///*********************************************************************************************************************
///
/// method:			rgbGrey:withAlpha:
/// scope:			public class method
/// overrides:		
/// description:	returns a grey RGB Color
/// 
/// parameters:		<grayscale> 0 to 1.0
///					<alpha> 0 to 1.0
/// result:			a grey Color with variable opacity
///
/// notes:			uses the RGB Color space, not the greyscale Colorspace you get with NSColor's grey
///					method. Gradients currently only work with RGB Colors.
///
///********************************************************************************************************************

+ (NSColor*)			rgbGrey:(float) grayscale withAlpha:(float) alpha
{
	return [self colorWithCalibratedRed:grayscale green:grayscale blue:grayscale alpha:alpha];
}


///*********************************************************************************************************************
///
/// method:			rgbGreyWithLuminosityFrom:withAlpha:
/// scope:			public class method
/// overrides:		
/// description:	returns a grey RGB Color with the same perceived brightness as the source colour
/// 
/// parameters:		<colour> any rgb colour
///					<alpha> 0 to 1.0
/// result:			a grey Color in rgb space of equivalent luminosity
///
/// notes:			
///
///********************************************************************************************************************

+ (NSColor*)			rgbGreyWithLuminosityFrom:(NSColor*) colour withAlpha:(float) alpha
{
	return [self rgbGrey:[colour luminosity] withAlpha:alpha];
}


///*********************************************************************************************************************
///
/// method:			veryLightGrey
/// scope:			public class method
/// overrides:		
/// description:	a very light grey colour
/// 
/// parameters:		none
/// result:			a very light grey Color in rgb space
///
/// notes:			
///
///********************************************************************************************************************

+ (NSColor*)			veryLightGrey
{
	return [self rgbGrey:0.9];
}

#pragma mark -
///*********************************************************************************************************************
///
/// method:			contrastingColor
/// scope:			public class method
/// overrides:		
/// description:	returns black or white depending on input Color - dark Colors give white, else black.
/// 
/// parameters:		none
/// result:			black or white
///
/// notes:			
///
///********************************************************************************************************************

+ (NSColor*)			contrastingColor:(NSColor*) Color
{
	if ([Color luminosity] >= 0.5 )
		return [NSColor blackColor];
	else
		return [NSColor whiteColor];
}


///*********************************************************************************************************************
///
/// method:			colorWithWavelength:
/// scope:			public class method
/// overrides:		
/// description:	returns an RGB colour approximating the wavelength.
/// 
/// parameters:		<lambda> the wavelength in nanometres
/// result:			approximate rgb equivalent colour
///
/// notes:			lambda range outside 380 to 780 (nm) returns black
///
///********************************************************************************************************************

+ (NSColor*)			colorWithWavelength:(float) lambda
{
	float   gama = 0.8;
	int		wave;
	double  red = 0.0;
	double  green = 0.0;
	double  blue = 0.0;
	double  factor;
	
	wave = truncf( lambda );
	
	if ( wave < 380 || wave > 780 )
		return [NSColor blackColor];
		
	if ( wave >= 380 && wave < 440 )
	{
		red = -(lambda - 440.0f)/(440.0f - 380.0f);
		green = 0.0;
		blue = 1.0;
	}
	else if ( wave >= 440 && wave < 490 )
	{
		red = 0.0;
		green = (lambda - 440.0f)/(490.0f - 440.0f);
		blue = 1.0;
	}
	else if ( wave > 490 && wave < 510 )
	{
		red = 0.0;
		green = 1.0;
		blue = -(lambda - 510.0f)/(510.0f - 490.0f);
	}
	else if ( wave >= 510 && wave < 580 )
	{
		red = (lambda - 510.0f)/(580.0f - 510.0f);
		green = 1.0;
		blue = 0.0;
	}
	else if ( wave >= 580 && wave < 645 )
	{
		red = 1.0;
		green = -(lambda - 645.0f)/(645.0f - 580.0f);
		blue = 0.0;
	}
	else if ( wave >= 645 && wave <= 780 )
	{
		red = 1.0;
		green = 0.0;
		blue = 0.0;
	}
	// Let the intensity fall off near the vision limits
 
	if ( wave >= 380 && wave < 420 )
		factor = 0.3 + 0.7 * (lambda - 380.0f) / (420.0f - 380.0f);
	else if ( wave >= 420 && wave < 700 )
		factor = 1.0;
	else if ( wave >= 700 && wave <= 780 )
		factor = 0.3 + 0.7 * (780.0f - lambda) / (780.0f - 700.0f);
	else
		factor = 0.0;
		
	// adjust rgb for gamma and factor:
	
	red		= powf( red * factor, gama );
	green   = powf( green * factor, gama );
	blue	= powf( blue * factor, gama );
	
	LogEvent_(kInfoEvent, @"red: %f, green: %f, blue: %f", red, green, blue );

	return [NSColor colorWithCalibratedRed:red green:green blue:blue alpha:1.0];
}


///*********************************************************************************************************************
///
/// method:			colorWithHexString:
/// scope:			public class method
/// overrides:		
/// description:	returns an RGB colour corresponding to the standard-formatted HTML hexadecimal colour string.
/// 
/// parameters:		<hex> a string formatted '#RRGGBB'
/// result:			rgb equivalent colour
///
/// notes:			
///
///********************************************************************************************************************

+ (NSColor*)			colorWithHexString:(NSString*) hex
{
	float		r[3];
	const char* p = [[hex lowercaseString] cStringUsingEncoding:NSUTF8StringEncoding];
	NSColor*	c = nil;
	int			h, k = 0;
	char		v;
	
	if (*p++ == '#' && [hex length] >= 7 )
	{
		while( k < 3 && *p != 0 )
		{
			v = *p++;
			if ( v > '9' )
				h = (int)((v - 'a') + 10) * 16;
			else
				h = (int)v * 16;
				
			v = *p++;
			if ( v > '9' )
				h += (int)(v - 'a') + 10;
			else
				h += (int)v;
			
			r[k++] = (float)h / 255.0f;
		}
	
		c = [NSColor colorWithCalibratedRed:r[0] green:r[1] blue:r[2] alpha:1.0];
	}
	
	return c;
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			colorWithHueFrom:
/// scope:			public instance method
/// overrides:		
/// description:	returns a copy ofthe receiver but substituting the hue from the given colour.
/// 
/// parameters:		<color> donates hue
/// result:			a colour with the hue of <color> but the receiver's saturation and brightness
///
/// notes:			if the receiver is black or white or otherwise fully unsaturated, colourization may not produce visible
///					results
///
///********************************************************************************************************************

- (NSColor*)			colorWithHueFrom:(NSColor*) color
{
	return [NSColor colorWithCalibratedHue:[color hueComponent] saturation:[self saturationComponent] brightness:[self brightnessComponent] alpha:[self alphaComponent]];
}


///*********************************************************************************************************************
///
/// method:			colorWithHueAndSaturationFrom:
/// scope:			public instance method
/// overrides:		
/// description:	returns a copy ofthe receiver but substituting the hue and saturation from the given colour.
/// 
/// parameters:		<color> donates hue and saturation
/// result:			a colour with the hue, sat of <color> but the receiver's brightness
///
/// notes:			
///
///********************************************************************************************************************

- (NSColor*)			colorWithHueAndSaturationFrom:(NSColor*) color
{
	return [NSColor colorWithCalibratedHue:[color hueComponent] saturation:[color saturationComponent] brightness:[self brightnessComponent] alpha:[self alphaComponent]];
}


///*********************************************************************************************************************
///
/// method:			colorWithRGBAverageFrom:
/// scope:			public instance method
/// overrides:		
/// description:	returns a colour by averaging the receiver with <color> in rgb space
/// 
/// parameters:		<color> average with this colour
/// result:			average of the two colours
///
/// notes:			
///
///********************************************************************************************************************

- (NSColor*)			colorWithRGBAverageFrom:(NSColor*) color
{
	float ba[4] = {0.5, 0.5, 0.5, 0.5};
	
	return [self colorWithRGBBlendFrom:color blendingAmounts:ba];
}


///*********************************************************************************************************************
///
/// method:			colorWithHSBAverageFrom:
/// scope:			public instance method
/// overrides:		
/// description:	returns a colour by averaging the receiver with <color> in hsb space
/// 
/// parameters:		<color> average with this colour
/// result:			average of the two colours
///
/// notes:			
///
///********************************************************************************************************************

- (NSColor*)			colorWithHSBAverageFrom:(NSColor*) color
{
	float ba[4] = {0.5, 0.5, 0.5, 0.5};
	
	return [self colorWithHSBBlendFrom:color blendingAmounts:ba];
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			colorWithRGBBlendFrom:blendingAmounts:
/// scope:			public instance method
/// overrides:		
/// description:	returns a colour by blending the receiver with <color> in rgb space
/// 
/// parameters:		<color> blend with this colour
///					<blendingAmounts> an array of four values, each 0..1, specifies how components from each colour are
///					blended
/// result:			blend of the two colours
///
/// notes:			
///
///********************************************************************************************************************

- (NSColor*)			colorWithRGBBlendFrom:(NSColor*) color blendingAmounts:(float[]) blends
{
	float r, g, b, a;
	
	r = ([self redComponent] * ( 1.0 - blends[0])) + ([color redComponent] * blends[0]);
	g = ([self greenComponent] * ( 1.0 - blends[1])) + ([color greenComponent] * blends[1]);
	b = ([self blueComponent] * ( 1.0 - blends[2])) + ([color blueComponent] * blends[2]);
	a = ([self alphaComponent] * ( 1.0 - blends[3])) + ([color alphaComponent] * blends[3]);
	
	return [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
}


///*********************************************************************************************************************
///
/// method:			colorWithHSBBlendFrom:blendingAmounts:
/// scope:			public instance method
/// overrides:		
/// description:	returns a colour by blending the receiver with <color> in hsb space
/// 
/// parameters:		<color> blend with this colour
///					<blendingAmounts> an array of four values, each 0..1, specifies how components from each colour are
///					blended
/// result:			blend of the two colours
///
/// notes:			
///
///********************************************************************************************************************

- (NSColor*)			colorWithHSBBlendFrom:(NSColor*) color blendingAmounts:(float[]) blends
{
	float h, s, b, a;
	
	h = ([self hueComponent] * ( 1.0 - blends[0])) + ([color hueComponent] * blends[0]);
	s = ([self saturationComponent] * ( 1.0 - blends[1])) + ([color saturationComponent] * blends[1]);
	b = ([self brightnessComponent] * ( 1.0 - blends[2])) + ([color brightnessComponent] * blends[2]);
	a = ([self alphaComponent] * ( 1.0 - blends[3])) + ([color alphaComponent] * blends[3]);
	
	return [NSColor colorWithCalibratedHue:h saturation:s brightness:b alpha:a];
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			luminosity
/// scope:			public instance method
/// overrides:		
/// description:	returns the luminosity value of the receiver
/// 
/// parameters:		none
/// result:			a value 0..1 that is the colour's luminosity
///
/// notes:			luminosity of a colour is both subjective and dependent on the display characteristics of particular
///					monitors, etc. A frequently used formula can be traced to experiments done by the NTSC television
///					standards committee in 1953, which was based on tube phosphors in common use at that time. A more
///					modern formula is applicable for LCD monitors. This method uses the NTSC formula if
///					NTSC_1953_STANDARD is defined, otherwise the modern one.
///
///********************************************************************************************************************

- (float)				luminosity
{
#ifdef NTSC_1953_STANDARD
	return [self redComponent] * 0.299 + [self greenComponent] * 0.587 + [self blueComponent] * 0.114;
#else
	return [self redComponent] * 0.212671 + [self greenComponent] * 0.715160 + [self blueComponent] * 0.072169;
#endif
}


///*********************************************************************************************************************
///
/// method:			colorWithLuminosity:
/// scope:			public instance method
/// overrides:		
/// description:	returns a grey rgb colour having the same luminosity as the receiver
/// 
/// parameters:		none
/// result:			a grey colour having the same luminosity
///
/// notes:			
///
///********************************************************************************************************************

- (NSColor*)			colorWithLuminosity
{
	return [NSColor rgbGrey:[self luminosity]];
}


///*********************************************************************************************************************
///
/// method:			contrastingColor
/// scope:			public instance method
/// overrides:		
/// description:	returns black or white to give best contrast with the receiver's colour
/// 
/// parameters:		none
/// result:			black or white
///
/// notes:			
///
///********************************************************************************************************************

- (NSColor*)			contrastingColor
{
	return [NSColor contrastingColor:self];
}


///*********************************************************************************************************************
///
/// method:			invertedColor
/// scope:			public instance method
/// overrides:		
/// description:	returns the colour with each colour component subtracted from 1
/// 
/// parameters:		none
/// result:			the "inverse" of the receiver
///
/// notes:			the alpha value is not inverted
///
///********************************************************************************************************************

- (NSColor*)			invertedColor
{
	NSColor* rgb = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	
	float r, g, b;
	
	r = 1.0 - [rgb redComponent];
	g = 1.0 - [rgb greenComponent];
	b = 1.0 - [rgb blueComponent];
	
	return [NSColor colorWithCalibratedRed:r green:g blue:g alpha:[rgb alphaComponent]];
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			hexString
/// scope:			public instance method
/// overrides:		
/// description:	returns a standard web-formatted hexadecimal representation of the receiver's colour
/// 
/// parameters:		none
/// result:			hexadecimal string
///
/// notes:			format is '#000000' (black) to '#FFFFFF' (white)
///
///********************************************************************************************************************

- (NSString*)			hexString
{
	NSColor* rgb = [self colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
	
	float	r, g, b, a;
	int		hr, hb, hg;
	
	[rgb getRed:&r green:&g blue:&b alpha:&a];
	
	hr = rinttol( r * 255 );
	hg = rinttol( g * 255 );
	hb = rinttol( b * 255 );
	
	NSString* s = [NSString stringWithFormat:@"#%02X%02X%02X", hr, hg, hb ];
	
//	LogEvent_(kInfoEvent, @"hex string from %@ is: %@", self, s );
	return s;
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			quartzColor
/// scope:			public instance method
/// overrides:		
/// description:	returns a quartz CGColorRef corresponding to the receiver's colours
/// 
/// parameters:		none
/// result:			CGColorRef
///
/// notes:			returned colour uses the generic RGB colour space, regardless of the receivers colourspace. Caller
///					is responsible for releasing the colour ref when done.
///
///********************************************************************************************************************

- (CGColorRef)			quartzColor
{
    NSColor* deviceColor = [self colorUsingColorSpaceName:NSDeviceRGBColorSpace];
   
    float components[4];
	
	[deviceColor getRed:&components[0] green:&components[1] blue:&components[2] alpha:&components[3]];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef cgColor = CGColorCreate(colorSpace, components);
    CGColorSpaceRelease(colorSpace);

    return cgColor;
}


@end


