///**********************************************************************************************************************************
///  DKDrawableObject+Metadata.h
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

#import "DKDrawableObject.h"


@interface DKDrawableObject (Metadata)


- (void)		setupMetadata;

- (void)		setMetadataObject:(id) obj forKey:(id) key;
- (id)			metadataObjectForKey:(id) key;
- (BOOL)		hasMetadataForKey:(id) key;
- (void)		removeMetadataForKey:(id) key;

- (void)		setFloatValue:(float) val forKey:(id) key;
- (float)		floatValueForKey:(id) key;

- (void)		setIntValue:(int) val forKey:(id) key;
- (int)			intValueForKey:(id) key;

- (void)		setString:(NSString*) string forKey:(id) key;
- (NSString*)	stringForKey:(id) key;

- (void)		setColour:(NSColor*) colour forKey:(id) key;
- (NSColor*)	colourForKey:(id) key;

- (void)		setSize:(NSSize) size forKey:(id) key;
- (NSSize)		sizeForKey:(id) key;

@end



/* adds some convenience methods for standard meta data attached to a graphic object. By default the metadata is just an uncomitted
id, but using this sets it to be a mutable dictionary. You can then easily get and set values in that dictionary.

*/


extern NSString*	kGCPrivateGradientStartPointKey;
extern NSString*	kGCPrivateGradientEndPointKey;
extern NSString*	kGCPrivateGradientStartRadiusKey;
extern NSString*	kGCPrivateGradientEndRadiusKey;

extern NSString*	kGCPrivateShapeOriginalText;


@interface DKDrawableObject (DrawkitPrivateMetadata)

- (void)				setGradientStartPoint:(NSPoint) p;
- (NSPoint)				gradientStartPoint;
- (void)				setGradientEndPoint:(NSPoint) p;
- (NSPoint)				gradientEndPoint;

- (void)				setGradientStartRadius:(float) rad;
- (float)				gradientStartRadius;
- (void)				setGradientEndRadius:(float) rad;
- (float)				gradientEndRadius;


- (void)				setOriginalText:(NSAttributedString*) text;
- (NSAttributedString*)	originalText;

@end


/*

Stores various drawkit private variables in the metadata.


*/
