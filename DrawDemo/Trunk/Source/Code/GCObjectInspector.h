/* GCObjectInspector */

#import <GCDrawKit/DKDrawkitInspectorBase.h>


@class DKDrawableObject;
@class DKShapeGroup;


@interface GCObjectInspector : DKDrawkitInspectorBase
{
    IBOutlet id mGenInfoAngleField;
    IBOutlet id mGenInfoHeightField;
    IBOutlet id mGenInfoLocationXField;
    IBOutlet id mGenInfoLocationYField;
    IBOutlet id mGenInfoStyleNameField;
    IBOutlet id mGenInfoTypeField;
    IBOutlet id mGenInfoWidthField;
	IBOutlet id mGenInfoCoordinateRadioButtons;
	
	IBOutlet id	mMultiInfoItemCountField;
	IBOutlet id mGroupInfoItemCountField;
    IBOutlet id mMainTabView;
    IBOutlet id mMetaAddItemButton;
    IBOutlet id mMetaRemoveItemButton;
    IBOutlet id mMetaTableView;
    IBOutlet id mObjectTabView;
	
	IBOutlet id	mLockIconImageWell;
	
	DKDrawableObject*	mSel;
	BOOL				mConvertCoordinates;
}


- (void)			updateTabAtIndex:(int) tab withSelection:(NSArray*) sel;
- (void)			updateGroupTabWithObject:(DKShapeGroup*) group;
- (void)			updateSingleItemTabWithObject:(DKDrawableObject*) obj;

- (void)			objectChanged:(NSNotification*) note;
- (void)			styleChanged:(NSNotification*) note;

- (IBAction)		addMetaItemAction:(id)sender;
- (IBAction)		removeMetaItemAction:(id)sender;
- (IBAction)		ungroupButtonAction:(id)sender;

- (IBAction)		changeCoordinatesAction:(id) sender;

- (IBAction)		changeLocationAction:(id) sender;
- (IBAction)		changeSizeAction:(id) sender;
- (IBAction)		changeAngleAction:(id) sender;

@end



enum
{
	kGCObjectInspectorTabNoItems		= 0,
	kGCObjectInspectorTabMultipleItems	= 1,
	kGCObjectInspectorTabSingleItem		= 2,
	kGCObjectInspectorTabGroupItem		= 3
};


enum
{
	kGCMetaDataItemTypeString			= 0,
	kGCMetaDataItemTypeInteger			= 1,
	kGCMetaDataItemTypeFloat			= 2
};




