//
//  GCGradientExtensions.m
//  GradientTest
//
//  Created by Jason Jobe on 3/3/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GCDrawKit/GCGradientExtensions.h"
#import "GCDrawKit/GCGradient.h"
#import "WTPlistKeyValueCoding.h"
#import "GCGradientPasteboard.h"

@implementation NSView (GCGradientExtensions)

- (void) dragStandardSwatchGradient:(GCGradient*)gradient slideBack:(BOOL)slideBack event:(NSEvent *)event
{
	NSSize size;
	size.width = 28;
	size.height = 28;
	[self dragGradient:gradient swatchSize:size slideBack:slideBack event:event];
}

- (void) dragGradient:(GCGradient*)gradient swatchSize:(NSSize)size slideBack:(BOOL)slideBack event:(NSEvent*) event
{
	if ( gradient == nil )
		return;

	NSPoint pt = [event locationInWindow];
	pt = [self convertPoint:pt fromView:nil];
	
	NSImage *swatchImage = [gradient swatchImageWithSize:size withBorder:YES];
	NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];

	// this method must not write data to the pasteboard. That must have been done prior to calling it.	That's because
	// the gradient object does not have a single pasteboard representation - it depends on the context of the drag.
	
	//	[gradient writeToPasteboard:pboard];
	//	[gradient writeFileToPasteboard:pboard];
	
	pt.x -= size.width/2;
	pt.y += size.height/2;
	
	[swatchImage setFlipped:NO];
	
	[[NSCursor currentCursor] push];
	[[NSCursor closedHandCursor] set];

	[self dragImage:swatchImage at:pt offset:size event:event
		 pasteboard:pboard
			 source:self slideBack:slideBack];
			 
	[NSCursor pop];
}

- (void) dragColor:(NSColor*)color swatchSize:(NSSize)size slideBack:(BOOL)slideBack event:(NSEvent *)event
{
	NSPoint pt = [event locationInWindow];
	pt = [self convertPoint:pt fromView:nil];
	NSImage *swatchImage = [color swatchImageWithSize:size withBorder:YES];
	
	
	NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
	[pboard declareTypes:[NSArray arrayWithObject:NSColorPboardType] owner:self];
	[color writeToPasteboard:pboard];
	
	pt.x -= size.width/2;
	pt.y -= size.height/2;
	
	[self dragImage:swatchImage at:pt offset:size event:event
		 pasteboard:pboard
			 source:self slideBack:slideBack];
}

@end

@implementation NSColor (GCGradientExtensions)

- (NSImage*) swatchImageWithSize:(NSSize) size withBorder:(BOOL) showBorder
{
	NSImage *swatchImage = [[NSImage alloc] initWithSize:size];
	NSRect box = NSMakeRect(0.0, 0.0, size.width, size.height);
	
	[[NSGraphicsContext currentContext] saveGraphicsState];
	[swatchImage lockFocus];
	[self drawSwatchInRect:box];
	
	if (showBorder)
	{
		[[NSColor grayColor] set];
		NSFrameRectWithWidth( box, 1.0 );
	}
	[swatchImage unlockFocus];
	[[NSGraphicsContext currentContext] restoreGraphicsState];
	
	return [swatchImage autorelease];
}

@end

@implementation GCGradient (DKGradientPlistTransformations)

+ (BOOL) supportsSimpleDictionaryKeyValueCoding { return YES; }
- (BOOL) supportsSimpleDictionaryKeyValueCoding { return YES; }

@end

@implementation GCColorStop (DKGradientPlistTransformations)

+ (BOOL) supportsSimpleDictionaryKeyValueCoding { return YES; }
- (BOOL) supportsSimpleDictionaryKeyValueCoding { return YES; }

@end



@implementation GCGradient (GCGradientExtensions)

- (void)		initExtensionData
{
	if (_extensionData == nil)
	{
		_extensionData = [[NSMutableDictionary alloc] init];
	}
}


- (void)		setRadialStartingPoint:(NSPoint) p
{
	[self initExtensionData];
	[_extensionData setPoint:p forKey:@"radialstartingpoint"];
}



- (void)		setRadialEndingPoint:(NSPoint) p
{
	[self initExtensionData];
	[_extensionData setPoint:p forKey:@"radialendingpoint"];
}



- (void)		setRadialStartingRadius:(float) rad
{
	[self initExtensionData];
	[_extensionData setFloat:rad forKey:@"radialstartingradius"];
}



- (void)		setRadialEndingRadius:(float) rad
{
	[self initExtensionData];
	[_extensionData setFloat:rad forKey:@"radialendingradius"];
}




- (NSPoint)		radialStartingPoint
{
	return [_extensionData pointForKey:@"radialstartingpoint"];
}



- (NSPoint)		radialEndingPoint
{
	return [_extensionData pointForKey:@"radialendingpoint"];
}



- (float)		radialStartingRadius;
{
	return [_extensionData floatForKey:@"radialstartingradius"];
}



- (float)		radialEndingRadius
{
	return [_extensionData floatForKey:@"radialendingradius"];
}


- (BOOL)		hasRadialSettings
{
	// return YES if there are valid radial settings. 
	
	if ( _extensionData )
		return ([_extensionData valueForKey:@"radialstartingpoint.x"] != nil && [_extensionData valueForKey:@"radialendingpoint.x"] != nil );
	
	return NO;
}


- (NSPoint)		mapPoint:(NSPoint) p fromRect:(NSRect) rect
{
	// given a point <p> within <rect> this returns it mapped to a 0..1 interval
	
	p.x = ( p.x - rect.origin.x ) / rect.size.width;
	p.y = ( p.y - rect.origin.y ) / rect.size.height;
	
	return p;
}


- (NSPoint)		mapPoint:(NSPoint) p toRect:(NSRect) rect
{
	// given a point <p> in 0..1 space, maps it to <rect>
	
	p.x = ( p.x * rect.size.width ) + rect.origin.x;
	p.y = ( p.y * rect.size.height ) + rect.origin.y;
	
	return p;
}


- (void)		setNumberOfAngularSegments:(int) seg
{
	[self initExtensionData];
	[_extensionData setValue:[NSNumber numberWithInt:seg] forKey:@"angularsegments"];
}


- (int)			numberOfAngularSegments
{
	return [[_extensionData valueForKey:@"angularsegments"] intValue];
}


- (void)		convertOldKey:(NSString*) key
{
	// given a key to an old NSPoint based struct, this converts it to the new archiver-compatible storage
//	NSLog(@"converting old key: %@ in %@", key, self );
	
	NSPoint p = [[_extensionData valueForKey:key] pointValue];
	[_extensionData removeObjectForKey:key];
	[_extensionData setPoint:p forKey:key]; 
}


- (void)		convertOldKeys
{
	NSEnumerator*	iter = [[_extensionData allKeys] objectEnumerator];
	NSString*		key;
	id				value;
	const char*		cType;
	
	while( key = [iter nextObject])
	{
		value = [_extensionData valueForKey:key];
		
		if ([value isKindOfClass:[NSValue class]])
		{
			cType = [value objCType];
			
			if ( strcmp( cType, @encode( NSPoint )) == 0 )
				[self convertOldKey:key];
		}
	}
}



@end



@implementation NSDictionary (StructEncoding)

- (void)		setPoint:(NSPoint) p forKey:(id) key
{
	[self setFloat:p.x forKey:[key stringByAppendingString:@".x"]];
	[self setFloat:p.y forKey:[key stringByAppendingString:@".y"]];
}


- (NSPoint)		pointForKey:(id) key
{
	NSPoint p;
	
	p.x = [self floatForKey:[key stringByAppendingString:@".x"]];
	p.y = [self floatForKey:[key stringByAppendingString:@".y"]];
	return p;
}


- (void)		setFloat:(float) f forKey:(id) key
{
	[self setValue:[NSNumber numberWithFloat:f] forKey:key];
}


- (float)		floatForKey:(id) key
{
	return [[self valueForKey:key] floatValue];
}


@end
