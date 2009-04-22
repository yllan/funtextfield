//
//  DKFillPattern.h
//  DrawingArchitecture
//
//  Created by graham on 26/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "DKPathDecorator.h"


@interface DKFillPattern : DKPathDecorator <NSCoding, NSCopying>
{
	float				m_altYOffset;
	float				m_altXOffset;
	float				m_angle;
	float				m_objectAngle;
	float				m_motifAngle;
	BOOL				m_angleRelativeToObject;
	BOOL				m_motifAngleRelativeToPattern;
}

+ (DKFillPattern*)	defaultPattern;
+ (DKFillPattern*)	fillPatternWithImage:(NSImage*) image;

- (void)			setPatternAlternateOffset:(NSSize) altOffset;
- (NSSize)			patternAlternateOffset;

- (void)			fillRect:(NSRect) rect;
- (void)			drawPatternInRect:(NSRect) rect;

- (void)			setAngle:(float) radians;
- (float)			angle;
- (void)			setAngleInDegrees:(float) degrees;
- (float)			angleInDegrees;

- (void)			setAngleIsRelativeToObject:(BOOL) relAngle;
- (BOOL)			angleIsRelativeToObject;

- (void)			setMotifAngle:(float) radians;
- (float)			motifAngle;
- (void)			setMotifAngleInDegrees:(float) degrees;
- (float)			motifAngleInDegrees;

- (void)			setMotifAngleIsRelativeToPattern:(BOOL) mrel;
- (BOOL)			motifAngleIsRelativeToPattern;

@end



extern NSString* kGCDrawingViewDidChangeScale;

/*

This object represents a pattern consisting of a repeated motif spaced out at intervals within a larger shape.

This subclasses DKPathDecorator which carries out the bulk of the work - it stores the image and caches it, this
just sets up the path clipping and calls the rendering method for each location of the repeating pattern.

*/
