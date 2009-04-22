///**********************************************************************************************************************************
///  DKTextAdornment.h
///  DrawKit
///
///  Created by graham on 18/05/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKRasterizer.h"
#import "DKTextShape.h"		// for vertical alignment constants


// layout modes:
typedef enum
{
	kGCTextLayoutInBoundingRect				= 0,		// simple text block ignores path shape (but can be clipped to it)
	kGCTextLayoutAlongPath					= 1,		// this usually results in "outside path"
	kGCTextLayoutAlongReversedPath			= 2,		// will allow text inside circle for example, i.e. "inside path"
	kGCTextLayoutFlowedInPath				= 3			// flows the text by wrapping within the path's shape
}
DKTextLayoutMode;



@interface DKTextAdornment : DKRasterizer <NSCoding, NSCopying>
{
	NSString*					m_identifier;				// identifier string - accessed metadata or KVC property
	NSString*					m_labelText;				// fixed text prepended to meta if set
	NSRect						m_textRect;					// layout rect
	NSDictionary*				m_textAttributes;			// text attributes applied to all the text when drawn
	float						m_angle;					// independent text angle
	DKVerticalTextAlignment		m_vertAlign;				// vertical text alignment
	DKTextLayoutMode			m_layoutMode;				// layout modes - wrap in box, shape or along path
	BOOL						m_wrapLines;				// YES to wrap into the text rect, NO for single line
	BOOL						m_clipToPath;				// YES to clip text within rendered object's path, NO otherwise
	BOOL						m_applyObjectAngle;			// YES to add the object's angle to the text angle
	float						mFlowedTextPathInset;		// inset the layout path by this much before laying out the text
}

+ (DKTextAdornment*)			textAdornmentWithText:(id) anySortOfText;
+ (NSDictionary*)				defaultTextAttributes;

- (NSString*)					string;
- (void)						setLabel:(id) anySortOfText;
- (NSAttributedString*)			label;

- (void)						setIdentifier:(NSString*) ident;
- (NSString*)					identifier;

- (void)						setVerticalAlignment:(DKVerticalTextAlignment) placement;
- (DKVerticalTextAlignment)		verticalAlignment;

- (void)						setLayoutMode:(DKTextLayoutMode) mode;
- (DKTextLayoutMode)			layoutMode;

- (void)						setFlowedTextPathInset:(float) inset;
- (float)						flowedTextPathInset;

- (void)						setAngle:(float) angle;
- (float)						angle;
- (void)						setAngleInDegrees:(float) degrees;
- (float)						angleInDegrees;

- (void)						setAppliesObjectAngle:(BOOL) aa;
- (BOOL)						appliesObjectAngle;

- (void)						setWrapsLines:(BOOL) wraps;
- (BOOL)						wrapsLines;

- (void)						setClipsToPath:(BOOL) ctp;
- (BOOL)						clipsToPath;

- (void)						setTextRect:(NSRect) rect;
- (NSRect)						textRect;

- (void)						setFont:(NSFont*) font;
- (NSFont*)						font;

- (void)						setColour:(NSColor*) colour;
- (NSColor*)					colour;

- (void)						setTextAttributes:(NSDictionary*) attrs;
- (NSDictionary*)				textAttributes;
- (void)						setParagraphStyle:(NSParagraphStyle*) style;
- (NSParagraphStyle*)			paragraphStyle;
- (void)						setAlignment:(NSTextAlignment) align;
- (NSTextAlignment)				alignment;
- (void)						setBackgroundColour:(NSColor*) colour;
- (NSColor*)					backgroundColour;


@end

// defined by DKTextShape, but also used by this class:


/*
enum
{
	kGCTextShapeVerticalAlignmentTop		= 0,
	kGCTextShapeVerticalAlignmentCentre		= 1,
	kGCTextShapeVerticalAlignmentBottom		= 2
};
*/



/*

The label renderer annotates an object with text. The text can be obtained either from the object's metadata using an identifier,
or by setting it directly (or both - the metadata is appended to the fixed text). The text is fully attributed, and is laid out
within the bounds of the rendered object's path. Note that at present the attributes apply to the entire text at once, there are
no runs of attributes.

This renderer allows text to be an attribute of any object.

This renderer also implements text-on-a-path. To do this, set the layoutMode to kGCTextLayoutAlongPath. Some attributes are ignored in
this mode such as angle and vertical alignment. However all textual attributes are honoured.

*/

