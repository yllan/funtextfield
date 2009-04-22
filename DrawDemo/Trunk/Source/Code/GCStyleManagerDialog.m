#import "GCStyleManagerDialog.h"
#import "GCBasicDialogController.h"

#import <GCDrawKit/DKStyle.h>
#import <GCDrawKit/DKStyleRegistry.h>
#import <GCDrawKit/LogEvent.h>

@implementation GCStyleManagerDialog
#pragma mark As a GCStyleManagerDialog

- (IBAction)			addCategoryAction:(id)sender
{
#pragma unused (sender)
	static int catSeed = 0;
	
	NSString* newCat = [NSString stringWithFormat:@"untitled category %d", ++catSeed];
	
	[[self styles] addCategory:newCat];
	[mStyleCategoryList reloadData];
	
	int indx = [[[self styles] allCategories] indexOfObject:newCat];
	
	[mStyleCategoryList selectRow:indx byExtendingSelection:NO];
	[mStyleCategoryList editColumn:1 row:indx withEvent:nil select:YES];	// TO DO - !! look up column in case user has reordered them
}


- (IBAction)			deleteCategoryAction:(id)sender
{
#pragma unused (sender)
	if (![mSelectedCategory isEqualToString:kGCDefaultCategoryName])
	{
		[[self styles] removeCategory:mSelectedCategory];
		[self updateUIForCategory:kGCDefaultCategoryName];
	}
}


- (IBAction)			styleIconMatrixAction:(id) sender
{
	mSelectedStyle = [[sender selectedCell] representedObject];
	
	[self updateUIForStyle:mSelectedStyle];
	
}


- (IBAction)	styleKeyChangeAction:(id) sender
{
#pragma unused (sender)
}


- (void)				sheetDidEnd:(NSWindow*) sheet returnCode:(int) returnCode  contextInfo:(void*) contextInfo
{
#pragma unused (returnCode)
	NSString* context = (NSString*)contextInfo;
	
	if([context isEqualToString:@"save"])
	{
		NSString* path = [(NSSavePanel*)sheet filename];
		[[DKStyleRegistry sharedStyleRegistry] writeToFile:path atomically:YES];
	}
	else if ([context isEqualToString:@"open"])
	{
		// just overwrite the current reg from the file
		
		NSString* path = [(NSOpenPanel*)sheet filename];
		BOOL result = [[DKStyleRegistry sharedStyleRegistry] readFromFile:path mergeOptions:kDKReplaceExistingStyles mergeDelegate:self];
		
		if ( result )
		{
			[mStyleCategoryList reloadData];
			[self updateUIForCategory:kGCDefaultCategoryName];
		}
	}
}


- (void)		alertDidEnd:(NSAlert*) alert returnCode:(int) returnCode contextInfo:(void*) contextInfo
{
#pragma unused (alert)
	if(returnCode == NSAlertDefaultReturn )
	{
		NSString* op = (NSString*)contextInfo;
		
		// do the deed
		
		if ([op isEqualToString:@"remove"])
		{
			[DKStyleRegistry unregisterStyle:mSelectedStyle];
			[self updateUIForCategory:mSelectedCategory];
		}
		else if ([op isEqualToString:@"reset"])
		{
			// remove all styles except the defaults - this restores the registry to the "first run" state
			
			[DKStyleRegistry resetRegistry];
			[mStyleCategoryList reloadData];
			[self updateUIForCategory:kGCDefaultCategoryName];
		}
	}
}


- (IBAction)			styleDeleteAction:(id) sender
{
#pragma unused (sender)
	// remove the style from the registry. If the style is in use nothing bad happens - the style is simply unregistered.
	
	// check this is OK with user
	
	NSAlert* alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Really Remove '%@' From Registry?", [mSelectedStyle name]]
						defaultButton:@"Remove"
						alternateButton:@"Cancel"
						otherButton:nil
						informativeTextWithFormat:@"Removing the style from the registry does not affect any object that might be using the style, but it may prevent the style being used in another document later."];
	
	[alert beginSheetModalForWindow:[self window]
			modalDelegate:self
			didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
			contextInfo:@"remove"];
}


- (IBAction)			registryResetAction:(id) sender
{
#pragma unused (sender)
	// warn the user of the consequences, then remove everything from the registry except the defaults
	
	NSAlert* alert = [NSAlert alertWithMessageText:[NSString stringWithFormat:@"Really Remove All Styles From Registry?", [mSelectedStyle name]]
						defaultButton:@"Clear"
						alternateButton:@"Cancel"
						otherButton:nil
						informativeTextWithFormat:@"Removing styles from the registry does not affect any object that might be using them, but it may prevent the styles being used in another document later."];
	
	[alert beginSheetModalForWindow:[self window]
			modalDelegate:self
			didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
			contextInfo:@"reset"];
}


- (IBAction)			saveStylesToFileAction:(id) sender
{
#pragma unused (sender)
	NSSavePanel* sp = [NSSavePanel savePanel];
	
	[sp setRequiredFileType:@"styles"];
	
	[sp beginSheetForDirectory:nil
		file:nil
		modalForWindow:[self window]
		modalDelegate:self
		didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		contextInfo:@"save"];
}


- (IBAction)			loadStylesFromFileAction:(id) sender
{
#pragma unused (sender)
	NSOpenPanel* op = [NSOpenPanel openPanel];
	
	[op beginSheetForDirectory:nil
		file:nil
		types:[NSArray arrayWithObject:@"styles"]
		modalForWindow:[self window]
		modalDelegate:self
		didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:)
		contextInfo:@"open"];
}




#pragma mark -
- (DKStyleRegistry*)	styles
{
	return [DKStyleRegistry sharedStyleRegistry];
}


- (void)				populateMatrixWithStyleInCategory:(NSString*) cat
{
	NSEnumerator*	iter = [[[self styles] objectsInCategory:cat] objectEnumerator];
	DKStyle*	style;
	NSImage*		swatch;
	NSImageCell*	cell;
	int				rows, cols, x, y, num;
	NSSize			cellSize;
	
	for( cols = 0; cols < [mStyleIconMatrix numberOfColumns]; ++cols )
		[mStyleIconMatrix removeColumn:cols];
	
	num = [[[self styles] objectsInCategory:cat] count];
	cols = 4;
	rows = (num / cols);
	
	if (( num % cols ) > 0 )
		++rows;
		
	x = y = 0;
	
	LogEvent_(kReactiveEvent, @"setting up matrix for '%@' (%d items)", cat, num );
	
	[mStyleIconMatrix renewRows:rows columns:cols];
	[mStyleIconMatrix sizeToCells];
	cellSize = [mStyleIconMatrix cellSize];
	
	if ( num > 0 )
	{
		while( (style = [iter nextObject]) != nil)
		{
			swatch = [[style standardStyleSwatch] copy];
			[swatch setScalesWhenResized:YES];
			[swatch setSize:cellSize];
						
			cell = [mStyleIconMatrix cellAtRow:y column:x];
			[cell setImage:swatch];
			[swatch release];
			
			[cell setRepresentedObject:style];
			[mStyleIconMatrix setToolTip:[style name] forCell:cell];
			[cell setEnabled:YES];
			
			if( ++x >= cols )
			{
				x = 0;
				
				if (( y * cols ) < num )
				{
					[mStyleIconMatrix addRow];
					++y;
				}
			}
			else
				[mStyleIconMatrix addColumn];
		}
		
		while( x < cols )
		{
			cell = [mStyleIconMatrix cellAtRow:y column:x++];
			[cell setImage:nil];
			[cell setRepresentedObject:nil];
			[mStyleIconMatrix setToolTip:nil forCell:cell];
			[cell setEnabled:NO];
		}
	}
	[mStyleIconMatrix setNeedsDisplay:YES];
}


- (void)				updateUIForStyle:(DKStyle*) style
{
	[mStyleNameTextField setStringValue:[style name]];
	[mStyleNameTextField setEnabled:YES];
	[mPreviewImageWell setImage:[style standardStyleSwatch]];
	
	// reload table which will set the checkboxes for categories containing this style
	
	[mStyleCategoryList reloadData];
}


- (void)				updateUIForCategory:(NSString*) category
{
	
	[category retain];
	[mSelectedCategory release];
	mSelectedCategory = category;
	
	[self populateMatrixWithStyleInCategory:category];
	[mStyleBrowserList reloadData];
	[mStyleBrowserList selectRow:0 byExtendingSelection:NO];
	
	if ([[[self styles] allKeysInCategory:category] count] > 0 )
	{
		[mStyleIconMatrix selectCellAtRow:0 column:0];
		[mStyleIconMatrix sendAction];
	}
	else
	{
		mSelectedStyle = nil;
		[mStyleCategoryList reloadData];
		[mStyleCategoryList selectRow:0 byExtendingSelection:NO];
	}
	
	// if the default category, disable the "delete" button
	
	if ([category isEqualToString:kGCDefaultCategoryName])
		[mDeleteCategoryButton setEnabled:NO];
	else
		[mDeleteCategoryButton setEnabled:YES];
}


#pragma mark -
#pragma mark As an NSWindowController 
- (void)				windowDidLoad
{
	int row = [mStyleCategoryList selectedRow];
	
	if ( row == -1 )
	{
		row = [[[self styles] allCategories] indexOfObject:kGCDefaultCategoryName];
		[mStyleCategoryList selectRow:row byExtendingSelection:NO];
	}
}


#pragma mark -
#pragma mark As an NSTableView delegate
- (void)				tableViewSelectionDidChange:(NSNotification*) aNotification
{
	if([aNotification object] == mStyleCategoryList)
	{
		// when the user selects a different category in the list, the matrix is repopulated with the styles in that category
		
		int			catItem = [mStyleCategoryList selectedRow];
		
		LogEvent_(kReactiveEvent, @"selection change: %d", catItem );
		
		if ( catItem != -1 )
		{
			NSString*	cat = [[[self styles] allCategories] objectAtIndex:catItem];
			[self updateUIForCategory:cat];
		}
	}
	else if([aNotification object] == mStyleBrowserList)
	{
		int rowIndex = [mStyleBrowserList selectedRow];
		NSArray* sortedKeys = [[self styles] allSortedKeysInCategory:mSelectedCategory];
		
		if ( rowIndex >= 0 && rowIndex < (int)[sortedKeys count])
		{
			NSString* key = [sortedKeys objectAtIndex:rowIndex];
		
			mSelectedStyle = [[self styles] objectForKey:key];
			[self updateUIForStyle:mSelectedStyle];
		}
	}
}


- (void)			tableView:(NSTableView*) aTableView willDisplayCell:(id) aCell forTableColumn:(NSTableColumn*) aTableColumn row:(int) rowIndex
{
#pragma unused (aTableColumn)
	if ( aTableView == mStyleCategoryList )
	{
		NSString*	cat = [[[self styles] allCategories] objectAtIndex:rowIndex];
		[aCell setEnabled:![cat isEqualToString:kGCDefaultCategoryName]];
	}
}


- (BOOL)			tableView:(NSTableView*) aTableView shouldEditTableColumn:(NSTableColumn*) aTableColumn row:(int) rowIndex
{
#pragma unused (aTableColumn)
	if ( aTableView == mStyleCategoryList )
	{
		NSString*	cat = [[[self styles] allCategories] objectAtIndex:rowIndex];
		return ![cat isEqualToString:kGCDefaultCategoryName];
	}
	
	return YES;
}


#pragma mark -
#pragma mark As part of NSTableDataSource Protocol
- (int)					numberOfRowsInTableView:(NSTableView*) aTableView
{
	if ( aTableView == mStyleCategoryList )
	{
		return [[[self styles] allCategories] count ];
	}
	else if ( aTableView == mStyleBrowserList )
	{
		return [[[self styles] allKeysInCategory:mSelectedCategory] count];
	}
	else
		return 0;
}


- (id)					tableView:(NSTableView*) aTableView objectValueForTableColumn:(NSTableColumn*) aTableColumn row:(int) rowIndex
{
	id identifier = [aTableColumn identifier];
	
	if ( aTableView == mStyleCategoryList )
	{
		if([identifier isEqualToString:@"catName"])
			return [[[self styles] allCategories] objectAtIndex:rowIndex];
		else if([identifier isEqualToString:@"keyInCat"])
		{
			// checkbox for inclusion in category for the selected style
			
			NSString*	cat = [[[self styles] allCategories] objectAtIndex:rowIndex];
			NSString*	key = [mSelectedStyle uniqueKey];
			
			BOOL include = [[self styles] key:key existsInCategory:cat];

			return [NSNumber numberWithInt:include];
		}
		else
			return nil;
	}
	else if ( aTableView == mStyleBrowserList )
	{
		NSArray* sortedKeys = [[self styles] allSortedKeysInCategory:mSelectedCategory];
		NSString* key = [sortedKeys objectAtIndex:rowIndex];

		if ([identifier isEqualToString:@"name"])
		{
			return [[self styles] styleNameForKey:key];
		}
		else if([identifier isEqualToString:@"image"])
		{
			DKStyle* style = [[self styles] styleForKey:key];
			NSImage*		swatch = [[style standardStyleSwatch] copy];
		
			[swatch setScalesWhenResized:YES];
			[swatch setSize:NSMakeSize( 22, 22 )];
			
			return [swatch autorelease];
		}
	}
	
	return nil;
}


- (void)				tableView:(NSTableView*) aTableView setObjectValue:(id) anObject forTableColumn:(NSTableColumn*) aTableColumn row:(int) rowIndex
{
	id identifier = [aTableColumn identifier];
	
	if ( aTableView == mStyleCategoryList )
	{
		if([identifier isEqualToString:@"catName"])
		{
			LogEvent_(kReactiveEvent, @"renaming category '%@' to '%@'", mSelectedCategory, anObject );
			
			[[self styles] renameCategory:mSelectedCategory to:anObject];
			[aTableView abortEditing];
			// renaming will reorder the category list, so need to reload the list and change selection
			
			[aTableView reloadData];
			
			int indx = [[[self styles] allCategories] indexOfObject:anObject];
			[aTableView selectRow:indx byExtendingSelection:NO];
			[mStyleBrowserList reloadData];
		}
		else if([identifier isEqualToString:@"keyInCat"])
		{
			// the user hit the "included" checkbox. This will add or remove the selected style from the selected category
			// accordingly
			
			if ( rowIndex != -1 )
			{
				NSString*	cat = [[[self styles] allCategories] objectAtIndex:rowIndex];
				NSString*	key = [mSelectedStyle uniqueKey];
				
				// the "all items" category can't be edited
				
				if ([cat isEqualToString:kGCDefaultCategoryName])
					return;
				
				if([anObject intValue] == 0 )
				{
					// remove from category
					
					LogEvent_(kReactiveEvent, @"the style key '%@' is being removed from category '%@'", key, cat);

					[[self styles] removeKey:key fromCategory:cat];
				}
				else
				{
					// add to category (which must exist as it's listed in the table, so pass NO for create)
					
					LogEvent_(kReactiveEvent, @"the style key '%@' is being added to category '%@'", key, cat);
					
					[[self styles] addKey:key toCategory:cat createCategory:NO];
				}
				
				[aTableView reloadData];
				
				if([cat isEqualToString:mSelectedCategory])
					[self populateMatrixWithStyleInCategory:cat];
			}
		}
	}
}


@end
