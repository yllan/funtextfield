//
//  DKStyleReader.h
//  DrawKit
//
//  Created by Jason Jobe on 3/16/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "DKEvaluator.h"


@class DKParser;


@interface DKStyleReader : DKEvaluator
{
	DKParser*	mParser;
}

- (id)			evaluateScript:(NSString*) script;
- (id)			readContentsOfFile:(NSString*) filenamet;
- (void)		loadBuiltinSymbols;

- (void)		registerClass:(id) aClass withShortName:(NSString*) sym;

@end
