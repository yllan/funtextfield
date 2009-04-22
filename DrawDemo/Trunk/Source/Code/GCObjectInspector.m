#import "GCObjectInspector.h"

#import <GCDrawKit/DKDrawKit.h>


@implementation GCObjectInspector
#pragma mark As a GCObjectInspector
- (void)		updateTabAtIndex:(int) tab withSelection:(NSArray*) sel
{
	mSel = nil;
	
	switch( tab )
	{
		case kGCObjectInspectorTabNoItems:
			break;
			
		case kGCObjectInspectorTabMultipleItems:
			[mMultiInfoItemCountField setIntValue:[sel count]];
			break;
			
		case kGCObjectInspectorTabGroupItem:
			[self updateGroupTabWithObject:[sel lastObject]];
			break;
			
		case kGCObjectInspectorTabSingleItem:
			mSel = [sel lastObject];
			[self updateSingleItemTabWithObject:mSel];
			break;
		default:
			break;
	}
}


- (void)		updateGroupTabWithObject:(DKShapeGroup*) group
{
	[mGroupInfoItemCountField setIntValue:[[group groupObjects] count]];
}


- (void)		updateSingleItemTabWithObject:(DKDrawableObject*) obj
{
    float		cFactor = 1.0;
	NSPoint		loc = [obj location];
	
	if ( mConvertCoordinates )
	{
		cFactor = 1.0 / [[obj drawing] unitToPointsConversionFactor];
		loc = [[[obj drawing] gridLayer] gridLocationForPoint:loc];
	}
	
	if([obj isKindOfClass:[DKDrawablePath class]] || [obj locked])
	{
		[mGenInfoAngleField setEnabled:NO];
		[mGenInfoWidthField setEnabled:NO];
		[mGenInfoHeightField setEnabled:NO];
	}
	else
	{
		[mGenInfoAngleField setEnabled:YES];
		[mGenInfoWidthField setEnabled:YES];
		[mGenInfoHeightField setEnabled:YES];
	}
	
	[mGenInfoAngleField setFloatValue:[obj angleInDegrees]];
	[mGenInfoWidthField setFloatValue:[obj size].width * cFactor];
	[mGenInfoHeightField setFloatValue:[obj size].height * cFactor];

    [mGenInfoLocationXField setFloatValue:loc.x];
    [mGenInfoLocationYField setFloatValue:loc.y];
	[mGenInfoTypeField setStringValue:NSStringFromClass([obj class])];
	
	if([obj locked])
	{
		[mGenInfoLocationXField setEnabled:NO];
		[mGenInfoLocationYField setEnabled:NO];
		[mLockIconImageWell setImage:[NSImage imageNamed:@"locked_symbol"]];
		[mMetaTableView setEnabled:NO];
		[mMetaAddItemButton setEnabled:NO];
		[mMetaRemoveItemButton setEnabled:NO];
	}
	else
	{
		[mGenInfoLocationXField setEnabled:YES];
		[mGenInfoLocationYField setEnabled:YES];
		[mLockIconImageWell setImage:nil];
		[mMetaTableView setEnabled:YES];
		[mMetaAddItemButton setEnabled:YES];
		[mMetaRemoveItemButton setEnabled:YES];
	}
	
	if([obj isKindOfClass:[DKShapeGroup class]])
		[mGroupInfoItemCountField setIntValue:[[(DKShapeGroup*)obj groupObjects] count]];
	else
		[mGroupInfoItemCountField setStringValue:@"n/a"];
	
	DKStyle*	style = [obj style];
	
	if ( style != nil )
	{
		NSString* cs = [style name];
	
		if ( cs != nil )
			[mGenInfoStyleNameField setStringValue:cs];
		else
			[mGenInfoStyleNameField setStringValue:@"(unnamed)"];
	}
	else
		[mGenInfoStyleNameField setStringValue:@"none"];
	
	// refresh the metadata table
			
	[mMetaTableView reloadData];
}


- (void)		objectChanged:(NSNotification*) note
{
	if ([note object] == mSel )
		[self updateSingleItemTabWithObject:mSel];
}


- (void)		styleChanged:(NSNotification*) note
{
	if([note object] == [mSel style])
		[self updateSingleItemTabWithObject:mSel];
}


#pragma mark -
- (IBAction)	addMetaItemAction:(id)sender
{
	static int keySeed = 1;
	
	int tag = [[sender selectedItem] tag];
	
	NSString* key = [NSString stringWithFormat:@"** change me %d **", keySeed++];
	
	switch( tag )
	{
		case kGCMetaDataItemTypeString:
			[mSel setString:@"" forKey:key];
			break;
			
		case kGCMetaDataItemTypeInteger:
			[mSel setIntValue:0 forKey:key];
			break;
			
		case kGCMetaDataItemTypeFloat:
			[mSel setFloatValue:0.0 forKey:key];
			break;
		default:
			break;
	}
	
	[mMetaTableView reloadData];
}


- (IBAction)	removeMetaItemAction:(id)sender
{
#pragma unused (sender)
	int			sel = [mMetaTableView selectedRow];
	NSArray*	keys = [[[mSel userInfo] allKeys] sortedArrayUsingSelector:@selector(compare:)];
	NSString*	oldKey = [keys objectAtIndex:sel];
	
	[mSel removeMetadataForKey:oldKey];
	[mMetaTableView reloadData];
}


- (IBAction)	ungroupButtonAction:(id)sender
{
#pragma unused (sender)
}


- (IBAction)	changeCoordinatesAction:(id) sender
{
	mConvertCoordinates = [[sender selectedCell] tag] == 0;
	[self updateSingleItemTabWithObject:mSel];
}


- (IBAction)		changeLocationAction:(id) sender
{
	#pragma unused(sender)
	NSPoint loc = NSMakePoint([mGenInfoLocationXField floatValue], [mGenInfoLocationYField floatValue]);
	
	if ( mConvertCoordinates )
		loc = [[[mSel drawing] gridLayer] pointForGridLocation:loc];

	[mSel moveToPoint:loc];
	[[[mSel drawing] undoManager] setActionName:NSLocalizedString(@"Position Object", @"undo for position object")];
}


- (IBAction)		changeSizeAction:(id) sender
{
	#pragma unused(sender)
	NSSize size = NSMakeSize([mGenInfoWidthField floatValue], [mGenInfoHeightField floatValue]);
	float cFactor = 1.0;
	
	if ( mConvertCoordinates )
	{
		cFactor = [[mSel drawing] unitToPointsConversionFactor];
		size.width *= cFactor;
		size.height *= cFactor;
	}

	[mSel setSize:size];
	[[[mSel drawing] undoManager] setActionName:NSLocalizedString(@"Set Object Size", @"undo for size object")];
}


- (IBAction)		changeAngleAction:(id) sender
{
	#pragma unused(sender)
	
	float radians = ([sender floatValue] * pi / 180.0 );
	[mSel rotateToAngle:radians];
	[[[mSel drawing] undoManager] setActionName:NSLocalizedString(@"Set Object Angle", @"undo for angle object")];
}



#pragma mark -
#pragma mark As a DKDrawkitInspectorBase
- (void)		redisplayContentForSelection:(NSArray*) selection
{
	// this inspector really needs to work with the unfiltered selection, so fetch it:
	
	DKLayer* layer = [self currentActiveLayer];
	
	if([layer isKindOfClass:[DKObjectDrawingLayer class]])
	{
		selection = [[(DKObjectDrawingLayer*)layer selection] allObjects];
	}
	
	int tab, oc = [selection count];
	
	if ( oc == 0 )
	{
		mSel = nil;
		tab = kGCObjectInspectorTabNoItems;
	}
	else if ( oc > 1 )
	{
		mSel = nil;
		tab = kGCObjectInspectorTabMultipleItems;
	}
	else
	{
		tab = kGCObjectInspectorTabSingleItem;
	}
	[mMetaTableView reloadData];
	[self updateTabAtIndex:tab withSelection:selection];
	[mMainTabView selectTabViewItemAtIndex:tab];
}


#pragma mark -
#pragma mark As an NSWindowController

- (void)		windowDidLoad
{
	[(NSPanel*)[self window] setFloatingPanel:YES];
	[(NSPanel*)[self window] setBecomesKeyOnlyIfNeeded:YES];
	[mMainTabView selectTabViewItemAtIndex:kGCObjectInspectorTabNoItems];
	
	mConvertCoordinates = YES;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(objectChanged:) name:kGCDrawableDidChangeNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(styleChanged:) name:kDKStyleNameChangedNotification object:nil];
}


#pragma mark -
#pragma mark As part of NSTableDataSource Protocol

- (int)			numberOfRowsInTableView:(NSTableView*) aTableView
{
	#pragma unused (aTableView)

	return [[mSel userInfo] count];
}


- (id)			tableView:(NSTableView*) aTableView objectValueForTableColumn:(NSTableColumn*) aTableColumn row:(int) rowIndex
{
	#pragma unused (aTableView)

	NSArray*	keys = [[[mSel userInfo] allKeys] sortedArrayUsingSelector:@selector(compare:)];
	NSString*	key =  [keys objectAtIndex:rowIndex];
	
	if ([[aTableColumn identifier] isEqualToString:@"key"])
		return key;
	else
		return [[mSel userInfo] objectForKey:key];
}


- (void)		tableView:(NSTableView*) aTableView setObjectValue:(id) anObject forTableColumn:(NSTableColumn*) aTableColumn row:(int) rowIndex
{
	#pragma unused (aTableView)

	NSArray*	keys = [[[mSel userInfo] allKeys] sortedArrayUsingSelector:@selector(compare:)];
	NSString*	oldKey = [keys objectAtIndex:rowIndex];
	
	if ([[aTableColumn identifier] isEqualToString:@"key"])
	{
		id value = [[mSel metadataObjectForKey:oldKey] retain];
		
		[mSel removeMetadataForKey:oldKey];
		[mSel setMetadataObject:value forKey:anObject];
		[value release];
	}
	else
		[mSel setMetadataObject:anObject forKey:oldKey];

}


- (BOOL)		tableView:(NSTableView*) aTableView shouldEditTableColumn:(NSTableColumn*) aTableColumn row:(int) rowIndex
{
	#pragma unused(aTableView)
	#pragma unused(aTableColumn)
	#pragma unused(rowIndex)
	
	return ![mSel locked];
}


@end
