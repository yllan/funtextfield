//
//  YLBezierPathView.m
//  FunTextField
//
//  Created by Yung-Luen Lan on 6/20/08.
//  Copyright 2008 yllan.org. All rights reserved.
//

#import "YLFunTextView.h"
#import "NSBezierPath+Utility.h"
#import "YLBezierLayoutManager.h"
#import "YLTextStorage.h"

static inline NSRect SmallRectCerterAtPointWithLength(NSPoint p, CGFloat l) {
    return NSMakeRect(p.x - l/2, p.y - l/2, l, l);
}

@interface YLFunTextView (Private)
- (void) _drawControlForPath: (NSBezierPath *)path nodeColor: (NSColor *)nodeColor handleColor: (NSColor *)handleColor;
@end

@implementation YLFunTextView (Private)
- (void) _drawControlForPath: (NSBezierPath *)path nodeColor: (NSColor *)nodeColor handleColor: (NSColor *)handleColor 
{
    int i;
    NSPoint lastPoint = NSZeroPoint;
    for (i = 0; i < [path elementCount]; i++) {
        NSPoint points[5];
        NSBezierPathElement pathElement = [path elementAtIndex: i associatedPoints: points];        
        
        if (pathElement == NSCurveToBezierPathElement) {            
            [handleColor set];
            [NSBezierPath strokeLineFromPoint: lastPoint toPoint: points[0]];
            [NSBezierPath strokeLineFromPoint: points[1] toPoint: points[2]];
            [NSBezierPath fillRect: SmallRectCerterAtPointWithLength(points[0], 4)];
            [NSBezierPath fillRect: SmallRectCerterAtPointWithLength(points[1], 4)];
            lastPoint = points[2];
        } else {
            lastPoint = points[0];
        }
        
        [nodeColor set];
        [NSBezierPath fillRect: SmallRectCerterAtPointWithLength(lastPoint, 4)];        
    }
}
@end



@implementation YLFunTextView
@synthesize layoutManager = _layoutManager, textStorage = _textStorage;

- (id) initWithFrame: (NSRect)frame 
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void) drawRect: (NSRect)rect 
{
    // Background
    [[NSColor whiteColor] set];
    NSRectFill(rect);
    
    // Path
    [[NSColor redColor] set];
    [self.layoutManager.path stroke];

    // Path Control
//    [self drawControlForPath: self.layoutManager.path nodeColor: [NSColor redColor] handleColor: [NSColor lightGrayColor]];
    
    [self.layoutManager beginDrawText: self.textStorage.displayText];

    if (self.textStorage.selectionRange.length > 0)
        [self.layoutManager drawSelectionRange: self.textStorage.selectionRange selectionColor: nil];
    
    [self.layoutManager drawText];

    if (!self.textStorage.hasMarkedText && self.textStorage.selectionRange.length == 0)
        [self.layoutManager drawCaretAtIndex: self.textStorage.selectionRange.location];
    else if (self.textStorage.hasMarkedText && self.textStorage.markedTextSelectionRange.length == 0)
        [self.layoutManager drawCaretAtIndex: self.textStorage.selectionRange.location + self.textStorage.markedTextSelectionRange.location];

    [self.layoutManager endDrawText];

}

#pragma mark -
#pragma mark Event Handling

- (void) keyDown: (NSEvent *)event
{
    [self interpretKeyEvents: [NSArray arrayWithObject: event]];
}

#pragma mark -
#pragma mark Color Handling

- (void) changeColor: (id)sender
{
    if (self.textStorage.selectionRange.length == 0) {
        NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithDictionary: self.textStorage.currentAttributes];
        [attr setObject: [sender color] forKey: NSForegroundColorAttributeName];
        self.textStorage.currentAttributes = attr;
    } else {
        [self.textStorage.text addAttributes: [NSDictionary dictionaryWithObject: [sender color] forKey: NSForegroundColorAttributeName] range: self.textStorage.selectionRange];
        [self setNeedsDisplay: YES];
    }
}

#pragma mark -
#pragma mark Font Handling

- (void) changeFont: (id)sender
{
    if (self.textStorage.selectionRange.length == 0) {
        NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithDictionary: self.textStorage.currentAttributes];
        NSFont *font = [attr objectForKey: NSFontAttributeName];
        if (!font)
            font = [NSFont userFontOfSize: 12];
        [attr setObject: [sender convertFont: font] forKey: NSFontAttributeName];
        self.textStorage.currentAttributes = attr;
    } else {
        NSUInteger index = self.textStorage.selectionRange.location;
        NSRange effectiveRange, restricRange = self.textStorage.selectionRange;
        while (index < self.textStorage.selectionRange.location + self.textStorage.selectionRange.length) {
            NSMutableDictionary *attr = [NSMutableDictionary dictionaryWithDictionary: [self.textStorage.text attributesAtIndex: index longestEffectiveRange: &effectiveRange inRange: restricRange]];
            NSFont *font = [attr objectForKey: NSFontAttributeName];
            if (!font)
                font = [NSFont userFontOfSize: 12];

            [attr setObject: [sender convertFont: font] forKey: NSFontAttributeName];
            [self.textStorage.text setAttributes: attr range: effectiveRange];
            index = effectiveRange.location + effectiveRange.length;
            restricRange.location += effectiveRange.length;
            restricRange.length -= effectiveRange.length;
        }
        [self setNeedsDisplay: YES];
    }
}


#pragma mark -
#pragma mark NSTextInput Protocol
/* NSTextInput protocol */

- (void) insertText: (id) aString 
{
    [self.textStorage insertText: aString];
    [self setNeedsDisplay: YES];
}

- (void) doCommandBySelector: (SEL)aSelector 
{
    [self.textStorage doCommandBySelector: aSelector];
    [self setNeedsDisplay: YES];
}

// setMarkedText: cannot take a nil first argument. aString can be NSString or NSAttributedString
- (void) setMarkedText: (id)aString selectedRange: (NSRange)selRange 
{
    [self.textStorage setMarkedText: aString selectedRange: selRange];
    [self setNeedsDisplay: YES];
}

- (void) unmarkText 
{
    [self.textStorage unmarkText];
}

- (BOOL) hasMarkedText 
{
    return self.textStorage.hasMarkedText;
}

- (NSInteger) conversationIdentifier 
{
    return (NSInteger) self.textStorage;
}

/* Returns attributed string at the range.  This allows input mangers to query any range in backing-store.  May return nil. */
- (NSAttributedString *) attributedSubstringFromRange: (NSRange)theRange 
{
    return [self.textStorage attributedSubstringFromRange: theRange];
}

/* This method returns the range for marked region.  If hasMarkedText == false, it'll return NSNotFound location & 0 length range. */
- (NSRange) markedRange 
{
    return [self.textStorage markedRange];
}

/* This method returns the range for selected region.  Just like markedRange method, its location field contains char index from the text beginning. */
- (NSRange) selectedRange 
{
    return self.textStorage.markedTextSelectionRange;
}

/* This method returns the first frame of rects for theRange in screen coordindate system. */
- (NSRect) firstRectForCharacterRange: (NSRange)theRange 
{
    NSRect viewCoordinateRect = [self.layoutManager approximatedRectForFirstCharactersInRange: theRange string: self.textStorage.text];
    NSPoint screenCoordinateOrigin = [self.window convertBaseToScreen: viewCoordinateRect.origin];
    viewCoordinateRect.origin = screenCoordinateOrigin;
    return viewCoordinateRect;
}

/* This method returns the index for character that is nearest to thePoint.  thPoint is in screen coordinate system. */
- (NSUInteger) characterIndexForPoint:(NSPoint)thePoint 
{
    // I haven't implement this method, just simply return NSNotFound.
	return NSNotFound;
}

/* This method is the key to attribute extension.  We could add new attributes through this method. NSInputServer examines the return value of this method & constructs appropriate attributed string.
 */
- (NSArray*) validAttributesForMarkedText 
{
	return [NSArray arrayWithObjects: NSFontAttributeName, NSUnderlineStyleAttributeName, NSForegroundColorAttributeName, NSBackgroundColorAttributeName, NSUnderlineColorAttributeName, NSMarkedClauseSegmentAttributeName, nil];
}


#pragma mark -
#pragma mark Override

- (BOOL) isRichText {
    return YES;
}

- (BOOL) isFlipped 
{
	return NO;
}

- (BOOL) isOpaque 
{
	return YES;
}

- (BOOL) acceptsFirstResponder 
{
	return YES;
}

- (BOOL)canBecomeKeyView 
{
    return YES;
}

@end
