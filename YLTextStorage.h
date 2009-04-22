//
//  YLTextStorage.h
//  FunTextField
//
//  Created by Yung-Luen Lan on 6/24/08.
//  Copyright 2008 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface YLTextStorage : NSObject {
    NSMutableAttributedString *_text;
    NSRange _selectionRange;
    NSMutableAttributedString *_markedText;
    NSRange _markedTextSelectionRange;
    NSDictionary *_currentAttributes;
    
    NSUInteger _selectionAnchorIndex; // mark the start point of selection
}
@property NSRange selectionRange;
@property NSRange markedTextSelectionRange;
@property (retain) NSMutableAttributedString *text;
@property (retain) NSMutableAttributedString *markedText;
@property (readonly) BOOL hasMarkedText;
@property (readonly) NSAttributedString *displayText; // include marked text
@property (retain) NSDictionary *currentAttributes;

+ (YLTextStorage *) textStorage;

/* Set the text and currentAttribute */
- (void) loadText: (NSAttributedString *)string;

/* Input protocol */
- (void) insertText: (id) aString;
- (void) doCommandBySelector: (SEL)aSelector;
- (void) setMarkedText: (id)aString selectedRange: (NSRange)selRange;
- (void) unmarkText;
- (NSAttributedString *) attributedSubstringFromRange: (NSRange)theRange;
- (NSRange) markedRange;
- (NSRange) selectedRange;

@end
