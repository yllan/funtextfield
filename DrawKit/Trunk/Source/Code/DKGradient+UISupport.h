//
//  DKGradient+UISupport.h
//  DrawKit
//
//  Created by graham on 26/03/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DKGradient.h"


@interface DKGradient (UISupport)

+ (DKGradient*)			aquaSelectedGradient;
+ (DKGradient*)			aquaNormalGradient;
+ (DKGradient*)			aquaPressedGradient;

+ (DKGradient*)			unifiedSelectedGradient;
+ (DKGradient*)			unifiedNormalGradient;
+ (DKGradient*)			unifiedPressedGradient;
+ (DKGradient*)			unifiedDarkGradient;


+ (DKGradient*)			sourceListSelectedGradient;
+ (DKGradient*)			sourceListUnselectedGradient;

@end



/*

This category of DKGradient supplies a number of prebuilt gradients that implement a variety of user-interface gradients
as found in numerour apps, including Apple's own.


*/


