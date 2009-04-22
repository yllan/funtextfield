//
//  NSFolderManagerAdditions.m
//  CrosswordForge
//
//  Created by graham on 07/07/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "NSFolderManagerAdditions.h"

#import <GCDrawKit/LogEvent.h>


@implementation NSFileManager (FindFolder)
#pragma mark As a NSFileManager
- (NSString*)	pathToFolderOfType:(const OSType) folderType shouldCreateFolder:(BOOL) create
{
	OSErr		err;
	FSRef		ref;
	NSString* path = nil;
	
	err = FSFindFolder( kUserDomain, folderType, create, &ref);
	
	if ( err == noErr )
	{
		// convert to CFURL and thence to path
		
		CFURLRef url = CFURLCreateFromFSRef( kCFAllocatorSystemDefault, &ref );
		path = (NSString*) CFURLCopyFileSystemPath( url, kCFURLPOSIXPathStyle );
	}
	
	return path;
}


- (NSString*)	applicationSupportFolder
{
	// returns the path to the general app support folder for the current user
	
	return [self pathToFolderOfType:kApplicationSupportFolderType shouldCreateFolder:YES];
}


- (NSString*)	thisApplicationsSupportFolder
{
	// returns a path to a folder within the applicaiton support folder having the same name as the app
	// itself. This is a good place to place support files.
	
	NSString* appname = [[NSBundle mainBundle] bundleIdentifier];
	NSString* path = [[self applicationSupportFolder] stringByAppendingPathComponent:appname];
	
	// create this folder if it doesn't exist
	
	BOOL result = NO;
	
	if (! [self fileExistsAtPath:path])
		result = [self createDirectoryAtPath:path attributes:nil];
	
	if ( ! result )
		NSBeep();
		
	return path;
}


#pragma mark -
- (NSString*)	writeContents:(NSData*) data toUniqueTemporaryFile:(NSString*) fileName
{
	return [self writeContents:data toUniqueFile:fileName inDirectory:NSTemporaryDirectory()];
}
		

- (NSString*)	writeContents:(NSData*)data toUniqueFile:(NSString*) fileName inDirectory:(NSString*) path
{
	NSDictionary*	attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSFileExtensionHidden, nil];
	NSString*		unique = [self uniqueFilenameForFilename:fileName inDirectory:path];

	path = [path stringByAppendingPathComponent:unique];
	
//	LogEvent_(kFileEvent, @"creating file: '%@'", path);
	
	if (![self createFileAtPath:path contents:data attributes:attributes])
	{
		[NSException raise:@"Create File Error" format:@"The file '%@' could not be created", path ];
		return nil;
	}
	
	return path;
}


#pragma mark -
- (NSString*)	uniqueFilenameForFilename:(NSString*) name inDirectory:(NSString*) path
{
	NSString*	root;
	NSString*	extension;
	NSString*	fullPath;
	NSString*	newName;
	BOOL		nameOK = YES;
	int			renameIndex = 0;
	
	root = [name stringByDeletingPathExtension];
	extension = [name pathExtension];
	
	do
	{
		if ( renameIndex > 0 )
			newName = [[NSString stringWithFormat:@"%@ %d", root, renameIndex] stringByAppendingPathExtension:extension];
		else
			newName = [root stringByAppendingPathExtension:extension];
			
	//	LogEvent_(kReactiveEvent, @"checking filename '%@' is unique...", newName );
		
		fullPath = [path stringByAppendingPathComponent:newName];
		nameOK = ![self fileExistsAtPath:fullPath];
		
		++renameIndex;
		
		if ( renameIndex > 999 )
			[NSException raise:@"Too Many Files!" format:@">999 files in '%@' - are you nuts?", path];
	}
	while( !nameOK );
	
	return newName;
}

@end
