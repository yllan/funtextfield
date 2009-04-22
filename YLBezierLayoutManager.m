//
//  YLBezierLayoutManager.m
//  FunTextField
//
//  Created by Yung-Luen Lan on 6/24/08.
//  Copyright 2008 yllan.org. All rights reserved.
//

#import "YLBezierLayoutManager.h"
#import "NSBezierPath+Utility.h"

#define FREE_AND_NULL_IF_NEEDED(x) if ( x ) { free( x ); x = NULL; }

@implementation YLBezierLayoutManager
@synthesize path = _path;

+ (YLBezierLayoutManager *) layoutManagerWithBezierPath: (NSBezierPath *)bezierPath
{
    return [[[YLBezierLayoutManager alloc] initWithBezierPath: bezierPath] autorelease];
}

- (YLBezierLayoutManager *) initWithBezierPath: (NSBezierPath *)bezierPath
{
    if ([super init]) {
        self.path = bezierPath;
    }
    return self;
}

- (YLBezierLayoutManager *) init
{
    if ([super init]) {
        self.path = [NSBezierPath bezierPath];
    }
    return self;
}

- (void) dealloc 
{
    [_path release];
    [_cachedRunAttributes release];
    [super dealloc];
}

- (void) beginDrawText: (NSAttributedString *)string 
{
    _cachedStringLength = string.length;
    if (self.path.elementCount < 2)
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    // get the first line
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((CFAttributedStringRef)string);
    CFIndex count = CTTypesetterSuggestLineBreak(typesetter, 0, [self.path length]);
    CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(0, count));
    
    [self endDrawText]; // in case it wasn't invoked. Clear the previous cached data if needed.

    /* caret information */
    _cachedCaretOffset = (CGFloat *) malloc(sizeof(CGFloat) * (string.length + 1));
    int index;
    for (index = 0; index < string.length; index++) 
        _cachedCaretOffset[index] = CTLineGetOffsetForStringIndex(line, index, NULL);
    _cachedCaretOffset[string.length] = CTLineGetTypographicBounds(line, &_cachedAscent, &_cachedDescent, &_cachedLeading);    
    if (_cachedStringLength == 0) {
        _cachedAscent = 12;
        _cachedDescent = 6;
        _cachedLeading = 6;
    }
    
    _cachedFlatGlyphCount = CTLineGetGlyphCount(line);
    if (_cachedFlatGlyphCount == 0) 
        goto finalize;    
    
    /* flat glyph information */
    _cachedFlatGlyphs = (CGGlyph *) malloc(sizeof(CGGlyph) * _cachedFlatGlyphCount);
    _cachedFlatGlyphGetStringIndex = (CFIndex *) malloc(sizeof(CFIndex) * _cachedFlatGlyphCount);
    _cachedCTRunGetFlatPosition = (CGPoint *) malloc(sizeof(CGPoint) * _cachedFlatGlyphCount);
    _cachedFlatGlyphOrigin = (CGPoint *) malloc(sizeof(CGPoint) * _cachedFlatGlyphCount);
    _cachedFlatGlyphAngle = (CGFloat *) malloc(sizeof(CGFloat) * _cachedFlatGlyphCount);
    _cachedFlatGlyphTypographicsWidth = (CGFloat *) malloc(sizeof(CGFloat) * _cachedFlatGlyphCount);
    _cachedFlatGlyphImageBound = (CGRect *) malloc(sizeof(CGRect) * _cachedFlatGlyphCount);
    
    /* run information */
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    _cachedRunCount = CFArrayGetCount(runArray);
    _cachedRunGlyphCount = (CFIndex *) malloc(sizeof(CFIndex) * _cachedRunCount);
    _cachedRunAttributes = [NSMutableArray new];
    _cachedRunImageBound = (CGRect *) malloc(sizeof(CGRect) * _cachedRunCount);
    
    CFIndex glyphOffset = 0;
    CFIndex runIndex = 0;
    
    for (; runIndex < _cachedRunCount; runIndex++) {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CFIndex runGlyphCount = CTRunGetGlyphCount(run);
        _cachedRunGlyphCount[runIndex] = runGlyphCount;
        [_cachedRunAttributes addObject: (NSDictionary *) CTRunGetAttributes(run)];
                
        CFIndex runGlyphIndex = 0;
        CTRunGetGlyphs(run, CFRangeMake(0, runGlyphCount), _cachedFlatGlyphs + glyphOffset);
        CTRunGetStringIndices(run, CFRangeMake(0, runGlyphCount), _cachedFlatGlyphGetStringIndex + glyphOffset);
        
        _cachedRunImageBound[runIndex] = CTRunGetImageBounds(run, context, CFRangeMake(0, runGlyphCount));        
        
        for (; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
            CFRange glyphRange = CFRangeMake(runGlyphIndex, 1);
            CGFloat width = CTRunGetTypographicBounds(run, glyphRange, NULL, NULL, NULL);
            _cachedFlatGlyphTypographicsWidth[glyphOffset + runGlyphIndex] = width;
            CGFloat halfWidth = width / 2;

            CGPoint position;
            CTRunGetPositions(run, glyphRange, &position);
            _cachedCTRunGetFlatPosition[glyphOffset + runGlyphIndex] = position;
            
            CGFloat angle;
            NSPoint viewLocation = [self.path pointOnPathAtLength: position.x + halfWidth slope: &angle];
            
            // view location needs to be projected back along the baseline tangent by half the character width to align
            // the character based on the middle of the glyph instead of the left edge            
            viewLocation.x -= halfWidth * cosf(angle);
            viewLocation.y -= halfWidth * sinf(angle);

            _cachedFlatGlyphOrigin[glyphOffset + runGlyphIndex] = CGPointMake(viewLocation.x, viewLocation.y);
            _cachedFlatGlyphAngle[glyphOffset + runGlyphIndex] = angle;

            CGRect glyphBounds = CTRunGetImageBounds(run, context, CFRangeMake(runGlyphIndex, 1));
            _cachedFlatGlyphImageBound[glyphOffset + runGlyphIndex] = glyphBounds;
        }
        glyphOffset += runGlyphCount;
    }
finalize:    
    [pool release];
    
    CFRelease(typesetter);
    CFRelease(line);
}

- (void) endDrawText 
{
    FREE_AND_NULL_IF_NEEDED(_cachedFlatGlyphs);
    FREE_AND_NULL_IF_NEEDED(_cachedCTRunGetFlatPosition);
    FREE_AND_NULL_IF_NEEDED(_cachedFlatGlyphOrigin);
    FREE_AND_NULL_IF_NEEDED(_cachedFlatGlyphAngle);
    FREE_AND_NULL_IF_NEEDED(_cachedFlatGlyphTypographicsWidth);
    FREE_AND_NULL_IF_NEEDED(_cachedFlatGlyphGetStringIndex);
    FREE_AND_NULL_IF_NEEDED(_cachedFlatGlyphImageBound);
    
    FREE_AND_NULL_IF_NEEDED(_cachedCaretOffset);
    
    FREE_AND_NULL_IF_NEEDED(_cachedRunGlyphCount);
    FREE_AND_NULL_IF_NEEDED(_cachedRunImageBound);
    
    [_cachedRunAttributes autorelease];
    _cachedRunAttributes = nil;
}

- (void) drawCaretAtIndex: (NSUInteger)index
{
    CGFloat slope;
    
    NSPoint position = [self.path pointOnPathAtLength:  _cachedStringLength == 0 ? : _cachedCaretOffset[index] slope: &slope];

    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy: position.x yBy: position.y];
    [transform rotateByRadians: slope];
    [transform concat];
    
    [[NSColor blackColor] set];
    [NSBezierPath strokeLineFromPoint: NSMakePoint(0.0, 0.0 - (_cachedDescent + _cachedLeading)) toPoint: NSMakePoint(0.0, _cachedAscent)];
    
    [transform invert];
    [transform concat];
}

- (void) drawSelectionRange: (NSRange)selRange selectionColor: (NSColor *)selectionColor
{
    if (selRange.length == 0)
        return;

    if ([self.path elementCount] < 2 || _cachedStringLength == 0)
        return;

    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    
    [[NSColor selectedTextBackgroundColor] set];
    [selectionColor set]; // If selectionColor == nil, this line does nothing. Use the system color.
    
	int index = 0;
	for (; index < _cachedFlatGlyphCount; index++) {
		NSRange glyphStringRange;
		if (index == _cachedFlatGlyphCount - 1) 
			glyphStringRange = NSMakeRange(_cachedFlatGlyphGetStringIndex[index], _cachedStringLength - _cachedFlatGlyphGetStringIndex[index]);
		else
			glyphStringRange = NSMakeRange(_cachedFlatGlyphGetStringIndex[index], _cachedFlatGlyphGetStringIndex[index + 1] - _cachedFlatGlyphGetStringIndex[index]);

		NSRange intersectRange = NSIntersectionRange(glyphStringRange, selRange);
		if (intersectRange.length == 0) 
			continue;
		
        CGFloat startOffset = _cachedCaretOffset[intersectRange.location];
        CGFloat endOffset = _cachedCaretOffset[intersectRange.location + intersectRange.length];

        CGPoint position = _cachedCTRunGetFlatPosition[index];
		CGPoint viewLocation = _cachedFlatGlyphOrigin[index];
		CGFloat angle = _cachedFlatGlyphAngle[index];

		CGContextSaveGState(context);
		CGContextTranslateCTM(context, viewLocation.x, viewLocation.y);
		CGContextRotateCTM(context, angle);

        CGContextFillRect(context, CGRectMake(startOffset - position.x, 0 - (_cachedDescent + _cachedLeading), endOffset - startOffset, (_cachedAscent + _cachedDescent + _cachedLeading)));
        
		CGContextRestoreGState(context);
	}
}

- (void) drawText
{
    if (self.path.elementCount < 2 || _cachedStringLength == 0)
        return;
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);

    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    
    if (_cachedFlatGlyphCount == 0) 
        goto finalize;

    CFIndex glyphOffset = 0;
    CFIndex runIndex = 0;
    
    for (; runIndex < _cachedRunCount; runIndex++) {
        CFIndex runGlyphCount = _cachedRunGlyphCount[runIndex];

        NSDictionary *attributes = [_cachedRunAttributes objectAtIndex: runIndex];

        CGFontRef cgFont = CTFontCopyGraphicsFont((CTFontRef) [attributes objectForKey: NSFontAttributeName], NULL);
        CGContextSetFont(context, cgFont);
        CGContextSetFontSize(context, CTFontGetSize((CTFontRef) [attributes objectForKey: NSFontAttributeName]));
        CFRelease(cgFont);
        
        CFIndex runGlyphIndex = 0;
        
        // Draw the underline
        if ([attributes valueForKey: NSUnderlineStyleAttributeName]) {
            CGRect runRect = _cachedRunImageBound[runIndex];
            NSBezierPath *underlinePath = [self.path bezierPathByTrimmingFromLength: runRect.origin.x];
            underlinePath = [underlinePath bezierPathByTrimmingToLength: runRect.size.width];
            underlinePath = [underlinePath paralleloidPathWithOffset: -2.0];
            if ([[attributes valueForKey: NSUnderlineStyleAttributeName]  isEqualTo: [NSNumber numberWithInt: NSUnderlineStyleThick]])
                [underlinePath setLineWidth: 2.0];

            [[NSColor greenColor] set];
            [[attributes valueForKey: NSUnderlineColorAttributeName] set];
            [underlinePath stroke];
        }
        
        // Draw the background color
        if ([attributes valueForKey: NSBackgroundColorAttributeName]) {
            [[attributes valueForKey: NSBackgroundColorAttributeName] set];
            for (; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
//                CGPoint position = _cachedCTRunGetFlatPosition[glyphOffset + runGlyphIndex];
                CGPoint viewLocation = _cachedFlatGlyphOrigin[glyphOffset + runGlyphIndex];
                CGFloat angle = _cachedFlatGlyphAngle[glyphOffset + runGlyphIndex];
                CGContextSaveGState(context);
                CGContextTranslateCTM(context, viewLocation.x, viewLocation.y);
                CGContextRotateCTM(context, angle);
                CGContextFillRect(context, CGRectMake(0, 0 - (_cachedDescent + _cachedLeading), _cachedFlatGlyphTypographicsWidth[glyphOffset + runGlyphIndex], (_cachedAscent + _cachedDescent + _cachedLeading)));
                CGContextRestoreGState(context);
            }            
        }
        
        [[NSColor blackColor] set]; // Default color
        [[attributes valueForKey: NSForegroundColorAttributeName] set];
                
        for (runGlyphIndex = 0; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
            CGFloat halfWidth = _cachedFlatGlyphTypographicsWidth[glyphOffset + runGlyphIndex] / 2;
            if (halfWidth < 1E-7) 
                continue;
            
            CGPoint position = _cachedCTRunGetFlatPosition[glyphOffset + runGlyphIndex];

            if ([[self.path bezierPathByTrimmingFromLength: position.x + halfWidth] length] < halfWidth)
                continue;

            CGPoint viewLocation = _cachedFlatGlyphOrigin[glyphOffset + runGlyphIndex];
            CGFloat angle = _cachedFlatGlyphAngle[glyphOffset + runGlyphIndex];
            
            CGContextSaveGState(context);
			CGContextTranslateCTM(context, viewLocation.x, viewLocation.y);
            CGContextRotateCTM(context, angle);
  
            CGContextShowGlyphsAtPositions(context, _cachedFlatGlyphs + glyphOffset + runGlyphIndex, &CGPointZero, 1);

            // Draw Bounding Box
//* <-- Enable by adding a '/' in the beginning of this line
            CGRect glyphBounds = _cachedFlatGlyphImageBound[glyphOffset + runGlyphIndex];
            glyphBounds.origin.x -= position.x;
            glyphBounds.origin.y -= position.y;
            CGContextSetRGBStrokeColor(context, 0.0, 0.7, 0.7, 1.0);
            CGContextStrokeRect(context, glyphBounds);
/**/            
            CGContextRestoreGState(context);
            
        }
        glyphOffset += runGlyphCount;
    }
    
finalize:
    
    [pool release];
}

- (NSRect) approximatedRectForFirstCharactersInRange: (NSRange)range string: (NSAttributedString *)string
{
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((CFAttributedStringRef)string);
    CFIndex count = CTTypesetterSuggestLineBreak(typesetter, 0, [self.path length]);
    CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(0, count));
    CGFloat offset = CTLineGetOffsetForStringIndex(line, range.location, NULL);
    NSPoint origin = [self.path pointOnPathAtLength: offset slope: NULL];
    
    CFRelease(line);
    CFRelease(typesetter);
    
    return NSMakeRect(origin.x, origin.y, 20, 20);
}
@end
