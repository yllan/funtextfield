//
//  YLTextStorage.m
//  FunTextField
//
//  Created by Yung-Luen Lan on 6/24/08.
//  Copyright 2008 yllan.org. All rights reserved.
//

#import "YLTextStorage.h"

@interface YLTextStorage (Private)
- (NSDictionary *) getAttributesNearCaret;
@end
@implementation YLTextStorage (Private)
- (NSDictionary *) getAttributesNearCaret 
{
    if (self.text.length == 0)
        return nil;
    NSUInteger index = self.selectionRange.location;
    if (index > 0) 
        index--;
    return [self.text attributesAtIndex: index effectiveRange: NULL];
}
@end

@implementation YLTextStorage
@synthesize selectionRange = _selectionRange;
@synthesize text = _text;
@synthesize markedText = _markedText;
@synthesize markedTextSelectionRange = _markedTextSelectionRange;
@synthesize currentAttributes = _currentAttributes;

+ (YLTextStorage *) textStorage 
{
    return [[YLTextStorage new] autorelease];
}

- (YLTextStorage *) init 
{
    if ([super init]) {
        self.text = [[[NSMutableAttributedString alloc] init] autorelease];
        _selectionRange.location = 0;
        _selectionRange.length = 0;
        self.currentAttributes = [NSDictionary dictionary];
    }
    return self;
}

- (void) dealloc
{
    [_text release];
    [_currentAttributes release];
    [_markedText release];
    [super dealloc];
}

- (void) loadText: (NSAttributedString *)string 
{
    self.text = [[[NSMutableAttributedString alloc] initWithAttributedString: string] autorelease];
    self.currentAttributes = [self.text attributesAtIndex: 0 effectiveRange: NULL];
}

- (BOOL) hasMarkedText 
{
    if (!self.markedText || self.markedText.length == 0)
        return NO;
    return YES;
}

- (NSAttributedString *) displayText
{
    NSMutableAttributedString *result = [[[NSMutableAttributedString alloc] initWithAttributedString: self.text] autorelease];
    if (!self.hasMarkedText)
        return result;
//    result = [result attributedSubstringFromRange: NSMakeRange(0, self.selectionRange.location)];
    [result replaceCharactersInRange: self.selectionRange withAttributedString: self.markedText];
    return result;
}

#pragma mark -
#pragma mark NSTextInput protocol related
- (void) insertText: (id) aString 
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, aString);
    
    if (![aString respondsToSelector: @selector(attributedSubstringFromRange:)]) {
        aString = [[[NSMutableAttributedString alloc] initWithString: aString] autorelease];
        [aString addAttributes: self.currentAttributes range: NSMakeRange(0, [aString length])];
    }
    
    [self.text replaceCharactersInRange: self.selectionRange withAttributedString: aString];        
    self.selectionRange = NSMakeRange(self.selectionRange.location + [aString length], 0);
    
    [self unmarkText];
}

- (void) doCommandBySelector: (SEL)aSelector 
{
    if (aSelector == @selector(deleteBackward:)) {
        if (self.selectionRange.length > 0) {
            [_text deleteCharactersInRange: _selectionRange];
            _selectionRange.length = 0;
        } else if (_selectionRange.location > 0) {
            [_text deleteCharactersInRange: NSMakeRange(_selectionRange.location - 1, 1)];
            _selectionRange.location -= 1;
        }
        if ([self getAttributesNearCaret])
            self.currentAttributes = [self getAttributesNearCaret];
        
    } else if (aSelector == @selector(deleteForward:)) {
        if (self.selectionRange.length > 0) {
            [_text deleteCharactersInRange: _selectionRange];
            _selectionRange.length = 0;
        } else if (_selectionRange.location < _text.length) {
            [_text deleteCharactersInRange: NSMakeRange(_selectionRange.location, 1)];
        }
        if ([self getAttributesNearCaret])
            self.currentAttributes = [self getAttributesNearCaret];
        
    } else if (aSelector == @selector(moveLeft:)) {
        if (_selectionRange.length > 0) {
            _selectionRange.length = 0;
        } else if (_selectionRange.location > 0) {
            _selectionRange.location -= 1;
        }
        if ([self getAttributesNearCaret])
            self.currentAttributes = [self getAttributesNearCaret];
        
    } else if (aSelector == @selector(moveRight:)) {
        if (_selectionRange.length > 0) {
            _selectionRange.location += _selectionRange.length;
            _selectionRange.length = 0;
        } else if (_selectionRange.location < _text.length) {
            _selectionRange.location += 1;
        }
        if ([self getAttributesNearCaret])
            self.currentAttributes = [self getAttributesNearCaret];
        
    } else if (aSelector == @selector(moveRightAndModifySelection:)) {
        if (_selectionRange.length == 0)
            _selectionAnchorIndex = _selectionRange.location;
        
        if (_selectionRange.location == _selectionAnchorIndex && _selectionRange.location + _selectionRange.length < _text.length) {
            _selectionRange.length++;
        } else if (_selectionRange.location != _selectionAnchorIndex) {
            _selectionRange.location++;
            _selectionRange.length--;
        }

    } else if (aSelector == @selector(moveLeftAndModifySelection:)) {
        if (_selectionRange.length == 0)
            _selectionAnchorIndex = _selectionRange.location;
        if (_selectionRange.location + _selectionRange.length == _selectionAnchorIndex && _selectionRange.location > 0) {
            _selectionRange.location--;
            _selectionRange.length++;
        } else if (_selectionRange.location + _selectionRange.length != _selectionAnchorIndex) {
            _selectionRange.length--;
        }
    } else if (aSelector == @selector(moveUp:) || aSelector == @selector(moveToBeginningOfLine:) || aSelector == @selector(moveToBeginningOfDocument:)) {
        _selectionRange.location = 0;
        _selectionRange.length = 0;
    } else if (aSelector == @selector(moveDown:) || aSelector == @selector(moveToEndOfLine:) || aSelector == @selector(moveToEndOfDocument:)) {
        _selectionRange.location = self.text.length;
        _selectionRange.length = 0;        
    } else if (aSelector == @selector(moveUpAndModifySelection:)) {
        if (_selectionRange.length == 0)
            _selectionAnchorIndex = _selectionRange.location;
        _selectionRange.location = 0;
        _selectionRange.length = _selectionAnchorIndex;
    } else if (aSelector == @selector(moveDownAndModifySelection:)) {
        if (_selectionRange.length == 0)
            _selectionAnchorIndex = _selectionRange.location;
        _selectionRange.location = _selectionAnchorIndex;
        _selectionRange.length = self.text.length - _selectionAnchorIndex;
    }
    NSLog(@"%s %s", __PRETTY_FUNCTION__, aSelector);
}

// setMarkedText: cannot take a nil first argument. aString can be NSString or NSAttributedString
- (void) setMarkedText: (id)aString selectedRange: (NSRange)selRange 
{
    NSLog(@"%s [%@] %@ %@", __PRETTY_FUNCTION__, aString, [aString class], NSStringFromRange(selRange));
    if (![aString respondsToSelector: @selector(attributedSubstringFromRange:)]) {
        aString = [[[NSAttributedString alloc] initWithString: aString attributes: 
                    [NSDictionary dictionaryWithObject:[NSColor colorWithCalibratedRed: 1.0 green: 0.855 blue: 0.33 alpha: 1.0] forKey: NSBackgroundColorAttributeName]] autorelease];
        // give it some attribute
    }
    
    self.markedText = [[[NSMutableAttributedString alloc] initWithAttributedString: aString] autorelease];
    [self.markedText addAttributes: self.currentAttributes range: NSMakeRange(0, [aString length])];
    self.markedTextSelectionRange = selRange;
    
    if (self.selectionRange.length > 0) 
        [self.text deleteCharactersInRange: self.selectionRange];
    
    self.selectionRange = NSMakeRange(self.selectionRange.location, 0);
}

- (void) unmarkText 
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    self.markedText = nil;
}

- (NSAttributedString *) attributedSubstringFromRange: (NSRange)theRange 
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, NSStringFromRange(theRange));
    NSRange textRange = NSIntersectionRange(theRange, NSMakeRange(0, self.displayText.length));
    if (textRange.length == 0) {
        return nil;
    }
    return [self.displayText attributedSubstringFromRange: textRange];
}

- (NSRange) markedRange 
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if (!self.hasMarkedText) 
        return NSMakeRange(NSNotFound, 0);
    return NSMakeRange(self.selectionRange.location, self.markedText.length);
}

/* This method returns the range for selected region.  Just like markedRange method, its location field contains char index from the text beginning. */
- (NSRange) selectedRange 
{
    NSLog(@"%s %@", __PRETTY_FUNCTION__, NSStringFromRange(self.markedTextSelectionRange));
    return self.markedTextSelectionRange;
}

#pragma mark -
#pragma mark Method Forward
/*  I believed that there's a strange implementation in Apple's IMKit. In some cases, it will directly test if the view has property called "textStorage". If so, it will treat your textStorage as a NSTextStorage derived class without any test. Sometimes I got a -[YLTextStorage length]: unrecognized selector sent to instance 0x13c130. */

- (NSMethodSignature *) methodSignatureForSelector: (SEL)aSelector
{
    NSMethodSignature* sig;
	
	sig = [super methodSignatureForSelector: aSelector];
	
    if (sig == nil)
        sig = [self.text methodSignatureForSelector: aSelector];
    
	return sig;
}

- (void) forwardInvocation: (NSInvocation *)anInvocation 
{
    SEL aSelector = [anInvocation selector];

    if ([self.text respondsToSelector: aSelector]) {
        [anInvocation invokeWithTarget: self.text];
        return;
    }
    
    [self doesNotRecognizeSelector: aSelector];
}
@end
