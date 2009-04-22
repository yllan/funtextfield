///**********************************************************************************************************************************
///  DKDrawing+Paper.h
///  DrawKit
///
///  Created by graham on 14/08/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************


#import <Cocoa/Cocoa.h>
#import "DKDrawing.h"

@interface DKDrawing (Paper)

+ (NSSize)					isoA0PaperSize:(BOOL) portrait;
+ (NSSize)					isoA1PaperSize:(BOOL) portrait;
+ (NSSize)					isoA2PaperSize:(BOOL) portrait;
+ (NSSize)					isoA3PaperSize:(BOOL) portrait;
+ (NSSize)					isoA4PaperSize:(BOOL) portrait;
+ (NSSize)					isoA5PaperSize:(BOOL) portrait;

@end



/*

This category on DKDrawing simply supplies some common ISO paper sizes in terms of Quartz point dimensions.

The sizes can be passed directly to -initWithSize:




*/

