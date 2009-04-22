/*******************************************************************************************
//  DKParser.m
//  Parser
//
//  Created by Jason Jobe on 1/28/07.
//  Released under the Creative Commons license 2007 Datalore, LLC.
//
// 
//  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ 
//  or send a letter to
//  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
//
*******************************************************************************************/

#import "DKParser.h"

#import "DKExpression.h"
#import "DKSymbol.h"

#define PARSER_TYPE DKParser*

#include "reader.m"


int dk_lex (id *val, YYLTYPE *yloc, void *reader)
{
    DKParser *self = (DKParser*)reader;
	yloc->first_line = self->scanr.curline;
	int tok = scan (&self->scanr);
	self->scanr.token = tok;
	yloc->last_line = self->scanr.curline;
	*val = [self currentToken];
	return tok;
}
#include "reader_g.m"


@implementation DKParser
#pragma mark As a DKParser
- (void)registerFactoryClass:fClass forKey:(NSString*)key;
{
	if ([fClass isKindOfClass:[NSString class]])
		fClass = NSClassFromString (fClass);
		
	if (fClass)
		[mFactories setValue:fClass forKey:key];
}

#pragma mark -
- parseData:(NSData*)someData
{
	[mParseStack removeAllObjects];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	scan_init_buf(&scanr, (char*)[someData bytes]);
	dk_parse(self);
	scan_finalize(&scanr);
	[pool release];

	return ([mParseStack count] ? [mParseStack objectAtIndex:0] : nil);
}

- parseString:(NSString*)inString;
{	
	NSData *input = [inString dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
	return [self parseData:input];
}

- parseContentsOfFile:(NSString*)filename;
{
	NSMutableData *input = [[NSMutableData alloc] initWithContentsOfFile:filename];
	const char *term = "\0";
	[input appendBytes:term length:1];
	return [self parseData:input];
}

#pragma mark -
- delegate;
{
	return mDelegate;
}

- (void)setDelegate:anObject;
{
	if (mDelegate)
		[mDelegate autorelease];
	mDelegate = [anObject retain];
}

#pragma mark -
#pragma mark - Settings
-(void)setThrowErrorIfMissingFactory:(BOOL)flag;
{
	throwErrorIfMissingFactory = flag;
}

-(BOOL)willThrowErrorIfMissingFactory;
{
	return throwErrorIfMissingFactory;
}

#pragma mark -
#pragma mark - Parser interface
-(void)parseError:(NSString*)fmt, ...
{
    va_list argumentList;
   	va_start(argumentList, fmt);  
    NSString *msg = [[NSString alloc] initWithFormat:fmt arguments:argumentList];
    va_end(argumentList);

	NSString *error = [NSString stringWithFormat:@"DKParser parse ERROR: line: %d \n%@",
		scanr.curline, msg];

	NSLog (error);
}

#pragma mark -
- currentToken
{
	id token;
	switch (scanr.token) {
		case TK_String:
			// trim off the quotes
			token = [NSString stringWithCString:&scanr.data[1] length:scanr.len -2];
		break;
		case TK_Keyword:
			// trim off the trailing ':'
			token = [NSString stringWithCString:scanr.data length:scanr.len -1];
		break;
		case TK_Identifier:
		token = [DKSymbol symbolForCString:scanr.data length:scanr.len];
		break;
		case TK_Hex:
			token = [NSString stringWithCString:scanr.data length:scanr.len];
			break;
		case TK_Real:
		case TK_Integer:
		{
			NSString *stringValue, *error;
			stringValue = [NSString stringWithCString:scanr.data length:scanr.len];

			if (![numberFormatter getObjectValue:&token forString:stringValue errorDescription:&error])
				[self parseError:@"BAD NUMBER Format in %@", stringValue];
		}
		break;
		default:
			token = [NSString stringWithCString:scanr.data length:scanr.len];
	} 
	return token;
}

#pragma mark -
- (NSArray*)parseStack;
{
	return mParseStack;
}

#pragma mark -
-(void)push:value
{	
	[mParseStack addObject:value];
}


- pop
{	
	id value = [[[mParseStack lastObject] retain] autorelease];
	[mParseStack removeLastObject];

	return value;
}

- instantiate:(NSString*)type;
{
    Class factory = [mFactories valueForKey:type];
	
    // Some default types
    if (factory == Nil)
    {
        if ([type isEqualToString:@"array"])
            return [NSMutableArray array];
        else
        {
           DKExpression* expr = [[[DKExpression alloc] init] autorelease];
	   [(DKExpression*)expr setType:type];
	   return expr;
        }
    } else {
      return [[[factory alloc] init] autorelease];
    }
      //	return [self instantiateType:type withExpression:nil popping:NO];
}

- (void)setNodeValue:value forKey:(NSString*)key;
{
	DKExpression *dict = [mParseStack lastObject];
	[dict addObject:value forKey:key];
}

- (void)addNode:node
{
	NSMutableArray *array = [mParseStack lastObject];
	if (array == nil)
		array = mParseStack;
	[array addObject:node];
}


#pragma mark -
#pragma mark As an NSObject
-(void)dealloc
{
	[numberFormatter release];
	
	[mDelegate release];
	[mParseStack release];
	[mFactories release];
	
	[super dealloc];
}


- (NSString*) description
{
	return [NSString stringWithFormat:@"<DKParser %@>", mParseStack];
}


- (id)init
{
	self = [super init];
	if (self != nil)
	{
		// All scanr members set to zero.
		mFactories = [[NSMutableDictionary alloc] init];
		mParseStack = [[NSMutableArray alloc] init];
		NSAssert(mDelegate == nil, @"Expected init to zero");
		
		numberFormatter = [[NSNumberFormatter alloc] init];
		
		// Default settings
		throwErrorIfMissingFactory = YES;
		
		if (mFactories == nil 
				|| mParseStack == nil 
				|| numberFormatter == nil)
		{
			[self autorelease];
			self = nil;
		}
	}
	return self;
}


@end


#pragma mark -
@implementation DKParser (ParserDebugging)

- (void)setGrammarDebug:(BOOL)flag;
{
	extern int dk_debug;
	dk_debug = flag;
}

@end

#ifdef DKTEST

int main (int argc, char** argv)
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	DKParser *reader = [[DKParser alloc] init];
	id node;

	[reader setThrowErrorIfMissingFactory:NO];
//	[reader setGrammarDebug:YES];
	
//	node = [reader parseString:@"(do with:1,234.56 and: 'single string')"];
//	NSLog (@"NODE: %@", node);
	
	if (argc > 1) {
		node = [reader parseContentsOfFile:[NSString stringWithCString:argv[1]]];
		fprintf (stdout, "%s\n", [[node description] cString]);
	}
	[pool release];
	return 0;
}

#endif

