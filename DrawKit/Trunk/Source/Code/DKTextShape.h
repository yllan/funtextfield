//
//  DKTextShape.h
//  DrawingArchitecture
//
//  Created by graham on 16/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "DKDrawableShape.h"

@class DKDrawingView;
@class DKShapeGroup;

// acceptable values for vertical alignment:

typedef enum
{
	kGCTextShapeVerticalAlignmentTop			= 0,
	kGCTextShapeVerticalAlignmentCentre			= 1,
	kGCTextShapeVerticalAlignmentBottom			= 2,
	kGCTextShapeVerticalAlignmentProportional	= 3
}
DKVerticalTextAlignment;




@interface DKTextShape : DKDrawableShape <NSCoding, NSCopying>
{
	NSTextStorage*			m_text;						// the text
	NSTextView*				m_editorRef;				// when editing, a reference to the editor view
	NSRect					m_textRect;					// rect of the text relative to the final shape
	DKVerticalTextAlignment	m_vertAlign;				// vertical text alignment
	BOOL					m_ignoreStyleAttributes;	// YES to keep the text attributes distinct from style
	float					mVerticalAlignmentAmount;	// value between 0..1 to set v align in prop mode
}

+ (DKTextShape*)			textShapeWithString:(NSString*) str inRect:(NSRect) bounds;
+ (DKTextShape*)			textShapeWithRTFData:(NSData*) rtfData inRect:(NSRect) bounds;

+ (void)					setDefaultIgnoresStyleAttributes:(BOOL) ignore;
+ (BOOL)					defaultIgnoresStyleAttributes;

+ (void)					setDefaultTextString:(NSString*) str;
+ (NSString*)				defaultTextString;

// the text:

- (void)					setText:(id) contents;
- (NSTextStorage*)			text;
- (NSString*)				string;
- (void)					sizeVerticallyToFitText;

- (void)					pasteTextFromPasteboard:(NSPasteboard*) pb ignoreFormatting:(BOOL) fmt;
- (BOOL)					canPasteText:(NSPasteboard*) pb;

// text layout and drawing:

- (void)					setTextRect:(NSRect) rect;
- (NSRect)					textRect;

- (NSSize)					minSize;
- (NSSize)					maxSize;
- (NSSize)					idealTextSize;
- (void)					drawText;
- (NSAffineTransform*)		textTransform;
- (NSPoint)					textOriginForSize:(NSSize) textSize;

// conversion to path/shape with text path:

- (NSBezierPath*)			textPath;
- (NSArray*)				textPathGlyphs;
- (NSArray*)				textPathGlyphsUsedSize:(NSSize*) textSize;
- (DKDrawableShape*)		makeShapeWithText;
- (DKShapeGroup*)			makeShapeGroupWithText;
- (DKStyle*)				styleWithTextAttributes;

// basic text attributes - accesses the style object or the local text attributes depending on
// whether the object is set to ignore style attributes or not

- (void)					setFont:(NSFont*) font;
- (NSFont*)					font;
- (void)					setFontSize:(float) size;
- (float)					fontSize;
- (void)					setTextColour:(NSColor*) colour;
- (NSColor*)				textColour;

- (void)					setVerticalAlignment:(DKVerticalTextAlignment) align;
- (DKVerticalTextAlignment)	verticalAlignment;
- (void)					setVerticalAlignmentProportion:(float) prop;
- (float)					verticalAlignmentProportion;
- (void)					setParagraphStyle:(NSParagraphStyle*) ps;
- (NSParagraphStyle*)		paragraphStyle;
- (NSTextAlignment)			alignment;

// attributes of the local text when ignoring the style:

- (void)					setLocalTextAttributes:(NSDictionary*) attrs;
- (NSDictionary*)			localTextAttributes;
- (void)					changeLocalTextAttribute:(NSString*) attr toValue:(id) val;
- (id)						localTextAttribute:(NSString*) attr;

// style stuff:

- (void)					syncWithStyle; 
- (void)					setIgnoresStyleAttributes:(BOOL) ignore;
- (BOOL)					ignoresStyleAttributes;
- (BOOL)					willRespondToTextAttributes;

// editing the text:

- (void)					startEditingInView:(DKDrawingView*) view;
- (void)					endEditing;

// user actions:

- (IBAction)				changeFont:(id) sender;
- (IBAction)				changeFontSize:(id) sender;
- (IBAction)				changeAttributes:(id) sender;
- (IBAction)				editText:(id) sender;
- (IBAction)				toggleIgnoreStyleAttributes:(id) sender;

- (IBAction)				alignLeft:(id) sender;
- (IBAction)				alignRight:(id) sender;
- (IBAction)				alignCenter:(id) sender;
- (IBAction)				alignJustified:(id) sender;
- (IBAction)				underline:(id) sender;

- (IBAction)				fitToText:(id) sender;
- (IBAction)				verticalAlign:(id) sender;
- (IBAction)				convertToShape:(id) sender;
- (IBAction)				convertToShapeGroup:(id) sender;

- (IBAction)				paste:(id) sender;

@end




/*
Text shapes are shapes that draw text. The text is drawn to fit the transformed bounding rect of the path. The inherited shape behaviours are used to provide an
optional filled/stroked background for the text. Text is rotated to the same angle as the path, and is clipped to the path edges - so normally you'll want to
set a rectangular path.

There are two ways to set the attributes of the text itself. If the shape has an attached style object, it can supply the attributes for the text such as its
font and size. This is good when you want to set up a text style such that all text objects sharing that style change if the style is changed. When used this way,
the attributes can't be applied to a subrange of the text - it's all or nothing.

The second way is to apply attributes to this object individually. That allows you to have different attributes in different subranges but you can't apply a style
change to every similar object at once.

The editing of the text uses the text editing utility methods of DKDrawingView.

Note that you can also add a DKTextAdornment to a style to apply text to any object - for many tasks that might be more useful.

*/
