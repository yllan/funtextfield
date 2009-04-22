//
//  GCGradientPasteboard.m
//  GradientTest
//
//  Created by Jason Jobe on 4/5/07.
//  Copyright 2007 __MyCompanyName__. All rights reserved.
//

#import "GCGradientPasteboard.h"

#import "NSFolderManagerAdditions.h"
#import "WTPlistKeyValueCoding.h"
#import <GCDrawKit/LogEvent.h>


#pragma mark Contants (Non-localized)
// Pasteboard and file types
NSString*	GPGradientPasteboardType	= @"GPGradientPasteboardType";
NSString*	GPGradientLibPasteboardType	= @"GPGradientLibPasteboardType";
NSString*	GradientFileExtension		= @"gradient";

NSString*	GCGradientInfoKey			= @"info";
NSString*	GCGradientsKey				= @"gradients";


#pragma mark Static Vars
static NSSize				sGradientPasteboardImageSize = {256.0, 256.0};


@implementation DKGradient (GCGradientPasteboard)
#pragma mark As a DKGradient
///*********************************************************************************************************************
///
/// method:			readablePasteboardTypes
/// scope:			public class method
/// overrides:		
/// description:	returns the list of types this class is able to read from a pasteboard
/// 
/// parameters:		none
/// result:			an NSArray containing the pasteboard types 
///
/// notes:			
///
///********************************************************************************************************************

+ (NSArray*)			readablePasteboardTypes
{
	static NSArray *types = nil;

	if (types == nil)
	{
		types = [[NSArray alloc] initWithObjects:
									GPGradientPasteboardType,
									NSFileContentsPboardType,
									NSFilenamesPboardType,
									nil];
	}
	
	return types;
}

///*********************************************************************************************************************
///
/// method:			writablePasteboardTypes
/// scope:			public class method
/// overrides:		
/// description:	returns the list of types this class is able to write to a pasteboard
/// 
/// parameters:		none
/// result:			an NSArray containing the pasteboard types
///
/// notes:			in fact this only declares one type - the native type. When writing to a pasteboard using
///					writeType:toPasteboard: each additional type is added as a type on demand. Normally you will
///					decalrea the writeable type so that the pasteboard is initially cleared.
///
///********************************************************************************************************************

+ (NSArray*)			writablePasteboardTypes
{
	static NSArray *types = nil;
	if (types == nil)
	{
		types = [[NSArray arrayWithObject:GPGradientPasteboardType] retain];
	}
	
	return types;
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			canInitalizeFromPasteboard:
/// scope:			public class method
/// overrides:		
/// description:	checksif the pastebaord containsdata we can use to create a gradient
/// 
/// parameters:		<pboard> the pasteboard to check
/// result:			YES if can initialize, NO otherwise
///
/// notes:			
///
///********************************************************************************************************************

+ (BOOL)				canInitalizeFromPasteboard:(NSPasteboard*)pboard;
{
	NSString *bestType = [pboard availableTypeFromArray:[self readablePasteboardTypes]];
	return (bestType != nil);
}


///*********************************************************************************************************************
///
/// method:			setPasteboardImageSize:
/// scope:			public class method
/// overrides:		
/// description:	sets the preferred size for the image versions of the gradient copied to the pasteboard
/// 
/// parameters:		<pbiSize> the preferred size
/// result:			none
///
/// notes:			
///
///********************************************************************************************************************

+ (void)				setPasteboardImageSize:(NSSize) pbiSize
{
	sGradientPasteboardImageSize = pbiSize;
}

///*********************************************************************************************************************
///
/// method:			gradientWithPasteboard:
/// scope:			public class method
/// overrides:		
/// description:	returns a gradient created from pasteboard data if valid
/// 
/// parameters:		<pboard> the pasteboard to read
/// result:			a gradient object, or nil if there was no suitable data on the pasteboard 
///
/// notes:			
///
///********************************************************************************************************************

+ (DKGradient*)		gradientWithPasteboard:(NSPasteboard*) pboard
{
	NSString *bestType = [pboard availableTypeFromArray:[self readablePasteboardTypes]];
	
//	LogEvent_(kReactiveEvent, @"gradient from pb, best type = %@", bestType );
//	LogEvent_(kReactiveEvent, @"pb types = %@", [pboard types]);
	
	if ([GPGradientPasteboardType isEqualToString:bestType])
	{
		NSData* data = [pboard dataForType:GPGradientPasteboardType];
		return [NSKeyedUnarchiver unarchiveObjectWithData:data];
	}
	else if ([NSFilenamesPboardType isEqualToString:bestType])
	{
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
		// Can't handle more than one.
		if ([files count] != 1)
			return nil;

        NSString *filePath = [files objectAtIndex:0];
		if ([[filePath pathExtension] isEqualToString:GradientFileExtension])
		{
			NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
			id val = [dict unarchiveFromPropertyListFormat];
			return val;
        }
    }
	return nil;
}


///*********************************************************************************************************************
///
/// method:			gradientWithPlist:
/// scope:			public class method
/// overrides:		
/// description:	returns a gradient created from plist data if valid
/// 
/// parameters:		<plist> a dictionary with plist representation of the gradient object
/// result:			a gradient object, or nil if the plist was invalid 
///
/// notes:			
///
///********************************************************************************************************************

+ (DKGradient*)			gradientWithPlist:(NSDictionary*) plist
{
	return [plist unarchiveFromPropertyListFormat];
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			writeToPasteboard:
/// scope:			public instance method
/// overrides:		
/// description:	writes the gradient to the pasteboard
/// 
/// parameters:		<pboard> the pasteboard to write to
/// result:			YES if the data was written OK, NO otherwise 
///
/// notes:			also writes a TIFF image version for export
///
///********************************************************************************************************************

- (BOOL)			writeToPasteboard:(NSPasteboard*) pboard
{
	[pboard declareTypes: [NSArray arrayWithObject:GPGradientPasteboardType] owner:self];
	[self writeType:GPGradientPasteboardType toPasteboard:pboard];
	[self writeType:NSPDFPboardType toPasteboard:pboard];
	//[self writeType:NSPostScriptPboardType toPasteboard:pboard];
	[self writeType:NSTIFFPboardType toPasteboard:pboard];
	return YES;
}


///*********************************************************************************************************************
///
/// method:			writeType:toPasteboard:
/// scope:			public instance method
/// overrides:		
/// description:	places data of the requested type on the given pasteboard
/// 
/// parameters:		<type> the data type to write
///					<pboard> the pasteboard to write it to
/// result:			YES if the type could be written, NO otherwise 
///
/// notes:			
///
///********************************************************************************************************************

- (BOOL)	writeType:(NSString*)type toPasteboard:(NSPasteboard*) pboard
{
    BOOL result = NO;
	
	// GPC: always add the requested type - thus we don't need to have separate type and write methods. However,
	// caller must declare *something* to clear pb first
	
//	LogEvent_(kReactiveEvent, @"writing type = %@", type);
	
	[pboard addTypes:[NSArray arrayWithObject:type] owner:self];
	
	if ([GPGradientPasteboardType isEqualToString:type])
	{
		NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self];
		result = [pboard setData:data forType:GPGradientPasteboardType];
	}
	else if ([NSTIFFPboardType isEqualToString:type])
	{
		NSImage* image = [self swatchImageWithSize:sGradientPasteboardImageSize withBorder:NO];
		result = [pboard setData:[image TIFFRepresentation] forType:NSTIFFPboardType];
	}
	else if ([NSPDFPboardType isEqualToString:type])
	{
		NSData* pdf = [self pdf];
		result = [pboard setData:pdf forType:NSPDFPboardType];
	}
	else if ([NSPostScriptPboardType isEqualToString:type])
	{
		NSData* eps = [self eps];
		result = [pboard setData:eps forType:NSPostScriptPboardType];
	}
	else if ([NSFilesPromisePboardType isEqualToString:type])
	{
		result = [pboard setPropertyList:[NSArray arrayWithObject:GradientFileExtension] 
								 forType:NSFilesPromisePboardType];
	}
	else if ([NSFilenamesPboardType isEqualToString:type])
	{
		// we do not have a file already in existence, so we wish to handle this 
		// type lazily to delay file creation until actually requested
		result = YES;
	}
	else if ([NSFileContentsPboardType isEqualToString:type])
	{
		result = [pboard writeFileWrapper:[self fileWrapperRepresentation]];
	}
	
	
    return result;
}


#pragma mark -
- (NSData*)				pdf
{
	// return gradient as PDF data
	
	NSRect				fr;
	
	fr.origin = NSZeroPoint;
	fr.size = sGradientPasteboardImageSize;
	
	//GCGradientView*		gv = [[GCGradientView alloc] initWithFrame:fr];
	//[gv setGradient:self];
	
	//NSData* pdf = [gv dataWithPDFInsideRect:fr];
	
	//[gv release];

	return nil;//pdf;
}


- (NSData*)				eps
{
	// return gradient as EPS data
	
	NSRect				fr;
	
	fr.origin = NSZeroPoint;
	fr.size = sGradientPasteboardImageSize;
	
	//GCGradientView*		gv = [[GCGradientView alloc] initWithFrame:fr];
	//[gv setGradient:self];
	
	//NSData* eps = [gv dataWithEPSInsideRect:fr];
	
	//[gv release];

	return nil;//eps;
}


#pragma mark -
///*********************************************************************************************************************
///
/// method:			gradientWithContentsOfFile:
/// scope:			public class method
/// overrides:		
/// description:	create a gradient object from a gradient file
/// 
/// parameters:		<path> the path to the file
/// result:			the gradient object, or nil if the file could not be read 
///
/// notes:			
///
///********************************************************************************************************************

+ (DKGradient*)			gradientWithContentsOfFile:(NSString*) path
{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
	return [dict unarchiveFromPropertyListFormat];
}


///*********************************************************************************************************************
///
/// method:			writeToFile:atomically:
/// scope:			public instance method
/// overrides:		
/// description:	write the gradient object to a gradient file
/// 
/// parameters:		<path> the path to the file
///					<flag> YES to write via a safe save, NO to write directly
/// result:			YES if the file was written succesfully, NO otherwise 
///
/// notes:			
///
///********************************************************************************************************************

- (BOOL)				writeToFile:(NSString*) path atomically:(BOOL) flag
{
	return [[self fileWrapperRepresentation] writeToFile:path atomically:flag updateFilenames:YES];
}


///*********************************************************************************************************************
///
/// method:			fileRepresentation
/// scope:			public instance method
/// overrides:		
/// description:	file representation of the gradient
/// 
/// parameters:		none
/// result:			a data object containing the file representation of the gradient 
///
/// notes:			
///
///********************************************************************************************************************

- (NSData*)				fileRepresentation
{
	return [NSPropertyListSerialization dataFromPropertyList:[self plistRepresentation]
										format:NSPropertyListXMLFormat_v1_0
										errorDescription:nil];
}


///*********************************************************************************************************************
///
/// method:			fileWrapperRepresentation
/// scope:			public instance method
/// overrides:		
/// description:	file wrapper representation of the gradient
/// 
/// parameters:		none
/// result:			a file wrapper object containing the file representation of the gradient 
///
/// notes:			
///
///********************************************************************************************************************

- (NSFileWrapper*)		fileWrapperRepresentation
{
	NSFileWrapper*	wrap = [[NSFileWrapper alloc] initRegularFileWithContents:[self fileRepresentation]];
	[wrap setPreferredFilename:@"untitled gradient.gradient"];
	
	NSDictionary*	attributes = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSNumber numberWithBool:YES], NSFileExtensionHidden,
										NSFileTypeRegular, NSFileType,
										[NSNumber numberWithUnsignedLong:420], NSFilePosixPermissions, // <--- 0644 octal (-wrr) -> 420 decimal
										nil];
	
	[wrap setFileAttributes:attributes];
	
	return [wrap autorelease];
}


- (NSDictionary*)		plistRepresentation
{
	return [NSDictionary archiveToPropertyListForRootObject:self];
}


#pragma mark -

///*********************************************************************************************************************
///
/// method:			writeFileToPasteboard:
/// scope:			public instance method
/// overrides:		
/// description:	writes the gradient file representation to the pasteboard
/// 
/// parameters:		<pboard> the pasteboard to write to
/// result:			none 
///
/// notes:			
///
///********************************************************************************************************************

- (BOOL)				writeFileToPasteboard:(NSPasteboard*) pboard
{
	[pboard declareTypes: [DKGradient writablePasteboardTypes] owner:self];
	[self writeType:NSFileContentsPboardType toPasteboard:pboard];		// <-- very important that this is first
	[self writeType:GPGradientPasteboardType toPasteboard:pboard];
	[self writeType:NSPDFPboardType toPasteboard:pboard];
	[self writeType:NSFilesPromisePboardType toPasteboard:pboard];		// <--- may create temporary or real file if requested
	//[self writeType:NSFilenamesPboardType toPasteboard:pboard];		// <--- may create temporary file if requested
	
//	LogEvent_(kReactiveEvent, @"pboard types written = %@", [pboard types]);
	return YES;
}


#pragma mark -
#pragma mark As an NSPasteboard delegate
- (void)				pasteboard:(NSPasteboard *) pboard provideDataForType:(NSString *) type
{	
	if ([NSFilenamesPboardType isEqualToString:type])
	{
	//	LogEvent_(kReactiveEvent, @"creating temporary file for filenames pasteboard");
		
		NSFileManager *fm = [NSFileManager defaultManager];
		NSString *path = [fm writeContents:[self fileRepresentation] toUniqueTemporaryFile:@"untitled gradient.gradient"];
		
		if ( path )
			[pboard setPropertyList:[NSArray arrayWithObject:path] forType:NSFilenamesPboardType];
	}
	else if ([NSFileContentsPboardType isEqualToString:type])
	{
		[pboard writeFileWrapper:[self fileWrapperRepresentation]];
	}
}


@end
