//
//  NSFolderManagerAdditions.h
//  CrosswordForge
//
//  Created by graham on 07/07/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSFileManager (FindFolder)

- (NSString*)	pathToFolderOfType:(const OSType) folderType shouldCreateFolder:(BOOL) create;
- (NSString*)	applicationSupportFolder;
- (NSString*)	thisApplicationsSupportFolder;

- (NSString*)	writeContents:(NSData*) data toUniqueTemporaryFile:(NSString*) fileName;
- (NSString*)	writeContents:(NSData*) data toUniqueFile:(NSString*) fileName inDirectory:(NSString*) path;

- (NSString*)	uniqueFilenameForFilename:(NSString*) name inDirectory:(NSString*) path;

@end
