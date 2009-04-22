//
//  GCMiniCircularSlider.h
//  panel
//
//  Created by Graham on Thu Apr 12 2007.
//  Copyright (c) 2007 __MyCompanyName__. All rights reserved.
//

#import "GCMiniSlider.h"


@interface GCMiniCircularSlider : GCMiniSlider

- (NSRect)		circleBounds;

@end


/*

a circular slider - value is current angle in radians.

will be drawn centred in bounds with radius equal to the shorter dimension,
less an offset to allow for the knob.

*/
