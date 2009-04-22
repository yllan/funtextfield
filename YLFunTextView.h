//
//  YLBezierPathView.h
//  FunTextField
//
//  Created by Yung-Luen Lan on 6/20/08.
//  Copyright 2008 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YLBezierLayoutManager, YLTextStorage;

@interface YLFunTextView : NSView <NSTextInput> {

    YLBezierLayoutManager *_layoutManager;
    YLTextStorage *_textStorage;
}
@property(retain) YLBezierLayoutManager *layoutManager;
@property(retain) YLTextStorage *textStorage;

@end
