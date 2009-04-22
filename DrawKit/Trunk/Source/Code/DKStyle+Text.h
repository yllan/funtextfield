///**********************************************************************************************************************************
///  DKStyle-Text.h
///  DrawKit
///
///  Created by graham on 21/09/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKStyle.h"


@interface DKStyle (TextAdditions)

+ (DKStyle*)			defaultTextStyle;
+ (DKStyle*)			textStyleWithFont:(NSFont*) font;
+ (NSString*)			styleNameForFont:(NSFont*) font;

- (void)				setParagraphStyle:(NSParagraphStyle*) style;
- (NSParagraphStyle*)	paragraphStyle;

- (void)				setAlignment:(NSTextAlignment) align;
- (NSTextAlignment)		alignment;

- (void)				changeTextAttribute:(NSString*) attribute toValue:(id) val;
- (NSString*)			actionNameForTextAttribute:(NSString*) attribute;

- (void)				setFont:(NSFont*) font;
- (NSFont*)				font;
- (void)				setFontSize:(float) size;
- (float)				fontSize;

- (void)				setUnderlined:(int) uval;
- (int)					underlined;
- (void)				toggleUnderlined;

- (void)				applyToText:(NSMutableAttributedString*) text;
- (void)				adoptFromText:(NSAttributedString*) text;

- (DKStyle*)			drawingStyleFromTextAttributes;

@end


/*

This adds text attributes to the DKStyle object. A DKTextShape makes use of styles with attached text attributes to style
the text it displays. Other objects that use text can make use of this as they wish.

Internally the text attributes are stored as a complete dictionary as a separate object within the style's dictionary.


*/
