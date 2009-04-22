///**********************************************************************************************************************************
///  DKDrawableObject+Metadata.m
///  DrawKit
///
///  Created by graham on 19/03/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKDrawableObject+Metadata.h"

#import "LogEvent.h"


@implementation DKDrawableObject (Metadata)
#pragma mark As a DKDrawableObject
- (void)		setupMetadata
{
	if ([self userInfo] == nil && ![self locked])
		[self setUserInfo:[NSMutableDictionary dictionaryWithCapacity:8]];
}


#pragma mark -
- (void)		setMetadataObject:(id) obj forKey:(id) key
{
	NSAssert( obj != nil, @"cannot set a nil metadata object");
	NSAssert( key != nil, @"cannot use a nil metadata key");
	
	if( ![self locked])
	{
		[self setupMetadata];
		[(NSMutableDictionary*)[self userInfo] setObject:obj forKey:key];
		[self notifyVisualChange];
	}
}


- (id)			metadataObjectForKey:(id) key
{
	// retrieve the metadata object for the given key. As an extra bonus, if the
	// key is a string, and it starts with a dollar sign, the rest of the string is used
	// as a keypath, and will return the property at that keypath. This allows stuff that
	// reads metadata to introspect objects in the framework - for example $style.name returns the style name, etc.
	
	if([key isKindOfClass:[NSString class]])
	{
		NSString* ks = (NSString*) key;
		
		if([ks length] > 1 && [[ks substringWithRange:NSMakeRange( 0, 1 )] isEqualToString:@"$"])
		{
			NSString* keyPath = [ks substringFromIndex:1];
			return [self valueForKeyPath:keyPath];
		}
	}
	
	return [[self userInfo] objectForKey:key];
}


- (BOOL)		hasMetadataForKey:(id) key
{
	return ([self metadataObjectForKey:key] != nil);
}


- (void)		removeMetadataForKey:(id) key
{
	[(NSMutableDictionary*)[self userInfo] removeObjectForKey:key];
}


#pragma mark -
- (void)		setFloatValue:(float) val forKey:(id) key
{
	[self setMetadataObject:[NSNumber numberWithFloat:val] forKey:key];
}


- (float)		floatValueForKey:(id) key
{
	return [[self metadataObjectForKey:key] floatValue];
}


#pragma mark -
- (void)		setIntValue:(int) val forKey:(id) key
{
	[self setMetadataObject:[NSNumber numberWithInt:val] forKey:key];
}


- (int)			intValueForKey:(id) key
{
	return [[self metadataObjectForKey:key] intValue];
}


#pragma mark -
- (void)		setString:(NSString*) string forKey:(id) key
{
	[self setMetadataObject:string forKey:key];
}


- (NSString*)	stringForKey:(id) key
{
	return (NSString*)[self metadataObjectForKey:key];
}


#pragma mark -
- (void)		setColour:(NSColor*) colour forKey:(id) key
{
	[self setMetadataObject:colour forKey:key];
}


- (NSColor*)	colourForKey:(id) key
{
	return (NSColor*)[self metadataObjectForKey:key];
}


- (void)		setSize:(NSSize) size forKey:(id) key
{
	// save as 2 keyed floats to allow keyed archiving of the metadata
	
	[self setMetadataObject:[NSNumber numberWithFloat:size.width] forKey:[NSString stringWithFormat:@"%@.size_width", key]];
	[self setMetadataObject:[NSNumber numberWithFloat:size.height] forKey:[NSString stringWithFormat:@"%@.size_height", key]];
}


- (NSSize)		sizeForKey:(id) key
{
	NSSize size;
	
	size.width = [[self metadataObjectForKey:[NSString stringWithFormat:@"%@.size_width", key]] floatValue];
	size.height = [[self metadataObjectForKey:[NSString stringWithFormat:@"%@.size_height", key]] floatValue];
	
	return size;
}



@end


#pragma mark -
#pragma mark Contants (Non-localized)
NSString*	kGCPrivateGradientStartPointKey		= @"kGCPrivateGradientStartPointKey";
NSString*	kGCPrivateGradientEndPointKey		= @"kGCPrivateGradientEndPointKey";
NSString*	kGCPrivateGradientStartRadiusKey	= @"kGCPrivateGradientStartRadiusKey";
NSString*	kGCPrivateGradientEndRadiusKey		= @"kGCPrivateGradientEndRadiusKey";
NSString*	kGCPrivateShapeOriginalText			= @"kGCPrivateShapeOriginalText";


@implementation DKDrawableObject (DrawkitPrivateMetadata)
#pragma mark As a DKDrawableObject
- (void)		setGradientStartPoint:(NSPoint) p
{
	// to support more flexibility with gradients, an object may set specific values for the start and endpoints of
	//a gradient. These should be relative to the object's location so they don't need updating when the object moves.
	
	// to acheive this, the point is transformed by the inverse transform when set, and the transform when retreived
	
	NSAffineTransform* t = [self transform];
	[t invert];
	
	p = [t transformPoint:p];
	
	[self setMetadataObject:[NSValue valueWithPoint:p] forKey:kGCPrivateGradientStartPointKey];
}


- (NSPoint)		gradientStartPoint
{
	NSPoint p = [[self metadataObjectForKey:kGCPrivateGradientStartPointKey] pointValue];
	
	NSAffineTransform* t = [self transform];
	return [t transformPoint:p];
}


- (void)		setGradientEndPoint:(NSPoint) p
{
	NSAffineTransform* t = [self transform];
	[t invert];
	
	p = [t transformPoint:p];

	[self setMetadataObject:[NSValue valueWithPoint:p] forKey:kGCPrivateGradientEndPointKey];
}


- (NSPoint)		gradientEndPoint
{
	NSPoint p = [[self metadataObjectForKey:kGCPrivateGradientEndPointKey] pointValue];

	NSAffineTransform* t = [self transform];
	return [t transformPoint:p];
}


#pragma mark -
- (void)				setGradientStartRadius:(float) rad
{
	[self setFloatValue:rad forKey:kGCPrivateGradientStartRadiusKey];
}


- (float)				gradientStartRadius
{
	return [self floatValueForKey:kGCPrivateGradientStartRadiusKey];
}


- (void)				setGradientEndRadius:(float) rad
{
	[self setFloatValue:rad forKey:kGCPrivateGradientEndRadiusKey];
}


- (float)				gradientEndRadius
{
	return [self floatValueForKey:kGCPrivateGradientEndRadiusKey];
}


#pragma mark -
- (void)				setOriginalText:(NSAttributedString*) text
{
	[self setMetadataObject:text forKey:kGCPrivateShapeOriginalText];
}


- (NSAttributedString*)	originalText
{
	return [self metadataObjectForKey:kGCPrivateShapeOriginalText];
}


@end

