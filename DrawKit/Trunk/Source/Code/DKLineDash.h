//
//  DKLineDash.h
//  DrawingArchitecture
//
//  Created by graham on 10/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DKLineDash : NSObject <NSCoding, NSCopying>
{
	float		m_pattern[8];
	float		m_phase;
	unsigned	m_count;
	BOOL		m_scaleToLineWidth;
}

+ (DKLineDash*)	defaultDash;
+ (DKLineDash*)	dashWithPattern:(float[]) dashes count:(int) count;
+ (DKLineDash*)	dashWithName:(NSString*) name;
+ (void)		registerDash:(DKLineDash*) dash withName:(NSString*) name;
+ (NSArray*)	registeredDashes;

+ (void)		saveDefaults;
+ (void)		loadDefaults;

- (id)			initWithPattern:(float[]) dashes count:(int) count;
- (void)		setDashPattern:(float[]) dashes count:(int) count;
- (void)		getDashPattern:(float[]) dashes count:(int*) count;
- (int)			count;
- (void)		setPhase:(float) ph;
- (float)		phase;
- (float)		length;

- (void)		setScalesToLineWidth:(BOOL) stlw;
- (BOOL)		scalesToLineWidth;

- (void)		applyToPath:(NSBezierPath*) path;
- (void)		applyToPath:(NSBezierPath*) path withPhase:(float) phase;

- (NSString*)	styleScript;
- (NSImage*)	dashSwatchImageWithSize:(NSSize) size strokeWidth:(float) width;
- (NSImage*)	standardDashSwatchImage;



@end


/*
 This stores a particular dash pattern for stroking an NSBezierPath, and can be owned by a DKStroke.
*/

#define			kGCStandardDashSwatchImageSize		(NSMakeSize( 80.0, 4.0 ))
#define			kGCStandardDashSwatchStrokeWidth	2.0
