//
//  YLBezierLayoutManager.h
//  FunTextField
//
//  Created by Yung-Luen Lan on 6/24/08.
//  Copyright 2008 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface YLBezierLayoutManager : NSObject {
    NSBezierPath *_path;

    /* Cached Data:
     * Create by invoke beginDrawText:, destroyed with endDrawText. 
     */
    
    // Line Metric
    CGFloat _cachedAscent;
    CGFloat _cachedDescent;
    CGFloat _cachedLeading;
    
    // Flat Glyph Information
    CFIndex _cachedFlatGlyphCount;
    CGGlyph *_cachedFlatGlyphs;
    CGPoint *_cachedCTRunGetFlatPosition; // not converted to bezier path
    CGPoint *_cachedFlatGlyphOrigin;
    CGFloat *_cachedFlatGlyphAngle;
    CGFloat *_cachedFlatGlyphTypographicsWidth;
    CFIndex *_cachedFlatGlyphGetStringIndex;
    CGRect *_cachedFlatGlyphImageBound; // not converted to bezier path
    
    // Caret Information
    CGFloat *_cachedCaretOffset;
    CFIndex _cachedStringLength;
    
    // Run Information
    CFIndex _cachedRunCount;
    CFIndex *_cachedRunGlyphCount;
    NSMutableArray *_cachedRunAttributes;
    CGRect *_cachedRunImageBound;
}
@property(retain) NSBezierPath *path;

- (YLBezierLayoutManager *) initWithBezierPath: (NSBezierPath *)bezierPath;
+ (YLBezierLayoutManager *) layoutManagerWithBezierPath: (NSBezierPath *)bezierPath;

/* Create the geometry of attributed string and cache the information */
- (void) beginDrawText: (NSAttributedString *)string;

/* Destroy the cached geometry information. */
- (void) endDrawText;

- (void) drawCaretAtIndex: (NSUInteger)index;
- (void) drawSelectionRange: (NSRange)selRange selectionColor: (NSColor *)selectionColor;
- (void) drawText;

/* Return a rectangle near the first character in range of string */
- (NSRect) approximatedRectForFirstCharactersInRange: (NSRange)range string: (NSAttributedString *)string;
@end
