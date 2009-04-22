///**********************************************************************************************************************************
///  DKImageShape+Vectorization.m
///  DrawKit
///
///  Created by graham on 25/06/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#ifdef qUsePotrace

#import "DKImageShape+Vectorization.h"

#import "DKStyle.h"
#import "DKObjectDrawingLayer.h"
#import "DKShapeGroup.h"
#import "DKStroke.h"
#import "LogEvent.h"


#pragma mark Contants (Non-localized)
NSString*	kGCIncludeStrokeStyle	= @"kGCIncludeStrokeStyle";		// BOOL
NSString*	kGCStrokeStyleWidth		= @"kGCStrokeStyleWidth";		// float
NSString*	kGCStrokeStyleColour	= @"kGCStrokeStyleColour";		// NSColor


#pragma mark Static Vars
static DKVectorizingMethod			sVecMethod = kGCVectorizeColour;
static int							sVecGrayLevels = 32;
static int							sVecColourPrecision = 5;
static DKColourQuantizationMethod	sQuantizationMethod = kGCColourQuantizeOctree;
static NSDictionary*				sTraceParams = nil;	// use default


#pragma mark -
@implementation DKImageShape (Vectorization)
#pragma mark As a DKImageShape
+ (void)			setPreferredVectorizingMethod:(DKVectorizingMethod) method
{
	sVecMethod = method;
}


+ (void)			setPreferredVectorizingLevels:(int) levelsOfGray
{
	sVecGrayLevels = levelsOfGray;
}


+ (void)			setPreferredVectorizingPrecision:(int) colourPrecision
{
	sVecColourPrecision = colourPrecision;
}


+ (void)			setPreferredQuantizationMethod:(DKColourQuantizationMethod) qm;
{
	sQuantizationMethod = qm;
}


#pragma mark -
+ (void)			setTracingParameters:(NSDictionary*) traceInfo
{
	[traceInfo retain];
	[sTraceParams release];
	sTraceParams = traceInfo;
}


+ (NSDictionary*)	tracingParameters
{
	return sTraceParams;
}


#pragma mark -
- (DKShapeGroup*)	makeGroupByVectorizing
{
	NSArray* shapes = [self makeObjectsByVectorizing];
	
	if ([shapes count] > 0 )
	{
		DKShapeGroup* group = [[DKShapeGroup alloc] initWithObjectsInArray:shapes];
		[group moveToPoint:[self location]];
		return [group autorelease];
	}
	else
		return nil;
}


- (DKShapeGroup*)	makeGroupByGrayscaleVectorizingWithLevels:(int) levelsOfGray
{
	NSArray* shapes = [self makeObjectsByGrayscaleVectorizingWithLevels:levelsOfGray];
	
	if ([shapes count] > 0 )
	{
		DKShapeGroup* group = [[DKShapeGroup alloc] initWithObjectsInArray:shapes];
		[group moveToPoint:[self location]];
		return [group autorelease];
	}
	else
		return nil;
}


- (DKShapeGroup*)	makeGroupByColourVectorizingWithPrecision:(int) colourPrecision
{
	NSArray* shapes = [self makeObjectsByColourVectorizingWithPrecision:colourPrecision];
	
	if ([shapes count] > 0 )
	{
		DKShapeGroup* group = [[DKShapeGroup alloc] initWithObjectsInArray:shapes];
		[group moveToPoint:[self location]];
		return [group autorelease];
	}
	else
		return nil;
}


#pragma mark -
- (NSArray*)		makeObjectsByVectorizing
{
	if ( sVecMethod == kGCVectorizeColour )
		return [self makeObjectsByColourVectorizingWithPrecision:sVecColourPrecision];
	else
		return [self makeObjectsByGrayscaleVectorizingWithLevels:sVecGrayLevels];
}


- (NSArray*)		makeObjectsByGrayscaleVectorizingWithLevels:(int) levelsOfGray
{
	NSArray* result = [[self image] vectorizeToGrayscale:levelsOfGray];
	
//	LogEvent_(kInfoEvent, @"vectorized, planes = %d", [result count]);
	
	NSEnumerator*		iter = [result objectEnumerator];
	DKImageVectorRep*	rep;
	DKDrawableShape*	shape;
	NSBezierPath*		path;
	NSMutableArray*		listOfShapes;
	
	listOfShapes = [[NSMutableArray alloc] init];
	
	while(( rep = [iter nextObject]))
	{
		[rep setTracingParameters:sTraceParams];

		path = [rep vectorPath];
		
		if ( path && ![path isEmpty])
		{
			shape = [DKDrawableShape drawableShapeWithPath:path];
			[shape setStyle:[DKStyle styleWithFillColour:[rep colour] strokeColour:nil]];
			[listOfShapes addObject:shape];
			
			// check if trace params dict contains request for stroke - if so, set it up
			
			if ( sTraceParams && [sTraceParams objectForKey:kGCIncludeStrokeStyle])
			{
				NSColor* strokeColour = [sTraceParams objectForKey:kGCStrokeStyleColour];
				float	 strokeWidth = [[sTraceParams objectForKey:kGCStrokeStyleWidth] floatValue];
			
				DKStroke* stroke = [DKStroke strokeWithWidth:strokeWidth colour:strokeColour];
				[[shape style] addRenderer:stroke];
			}
		}
	}
	
	return [listOfShapes autorelease];
}


- (NSArray*)		makeObjectsByColourVectorizingWithPrecision:(int) colourPrecision
{
	NSArray* result = [[self image] vectorizeToColourWithPrecision:colourPrecision quantizationMethod:sQuantizationMethod];
	
//	LogEvent_(kInfoEvent, @"vectorized, planes = %d", [result count]);
	
	NSEnumerator*		iter = [result objectEnumerator];
	DKImageVectorRep*	rep;
	DKDrawableShape*	shape;
	NSBezierPath*		path;
	NSMutableArray*		listOfShapes;
	
	listOfShapes = [[NSMutableArray alloc] init];
	
	while(( rep = [iter nextObject]))
	{
		[rep setTracingParameters:sTraceParams];
		
		path = [rep vectorPath];		// actually performs the bitmap trace if necessary
		
		if ( path && ![path isEmpty])
		{
			shape = [DKDrawableShape drawableShapeWithPath:path];
			[shape setStyle:[DKStyle styleWithFillColour:[rep colour] strokeColour:nil]];
			[listOfShapes addObject:shape];

			// check if trace params dict contains request for stroke - if so, set it up
			
			if ( sTraceParams && [sTraceParams objectForKey:kGCIncludeStrokeStyle])
			{
				NSColor* strokeColour = [sTraceParams objectForKey:kGCStrokeStyleColour];
				float	 strokeWidth = [[sTraceParams objectForKey:kGCStrokeStyleWidth] floatValue];
			
				DKStroke* stroke = [DKStroke strokeWithWidth:strokeWidth colour:strokeColour];
				[[shape style] addRenderer:stroke];
			}
		}
	}
	
	return [listOfShapes autorelease];
}


#pragma mark -
- (IBAction)		vectorize:(id) sender
{
	#pragma unused(sender)
	
	DKShapeGroup* group = [self makeGroupByVectorizing];

	// now add the group to the layer
	
	if ( group )
	{	
		DKObjectDrawingLayer* odl = (DKObjectDrawingLayer*)[self layer];
		
		[odl recordSelectionForUndo];
		[odl addObject:group];
		[odl removeObject:self];
		[odl replaceSelectionWithObject:group];
		[odl commitSelectionUndoWithActionName:NSLocalizedString(@"Vectorize Image", @"undo string for vectorize")];
	}
}




@end

#endif /* defined qUsePotrace */
