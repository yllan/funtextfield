//
//  DKZigZagFill.h
//  DrawKit
//
//  Created by graham on 04/01/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import "DKFill.h"


@interface DKZigZagFill : DKFill <NSCoding, NSCopying>
{
	float		mWavelength;
	float		mAmplitude;
	float		mSpread;
}

- (void)		setWavelength:(float) w;
- (float)		wavelength;

- (void)		setAmplitude:(float) amp;
- (float)		amplitude;

- (void)		setSpread:(float) sp;
- (float)		spread;

@end
