//
//  YLFunTextFieldController.h
//  FunTextField
//
//  Created by Yung-Luen Lan on 6/22/08.
//  Copyright 2008 yllan.org. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class YLFunTextView;

@interface YLFunController : NSObject {
    IBOutlet YLFunTextView *_textView;
}
@property (retain) YLFunTextView *textView;
@end
