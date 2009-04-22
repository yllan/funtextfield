/* GCStyleManagerDialog */

#import <Cocoa/Cocoa.h>


@class DKStyleRegistry, DKStyle;


@interface GCStyleManagerDialog : NSWindowController
{
    IBOutlet id mAddCategoryButton;
    IBOutlet id mDeleteCategoryButton;
    IBOutlet id mStyleCategoryList;
    IBOutlet id mStyleIconMatrix;
    IBOutlet id mStyleNameTextField;
	IBOutlet id	mPreviewImageWell;
	IBOutlet id	mStyleListTabView;
	IBOutlet id	mStyleBrowserList;
	IBOutlet id	mDeleteStyleButton;
	IBOutlet id mKeyChangeDialogController;
	
	DKStyle*	mSelectedStyle;
	NSString*		mSelectedCategory;
}
- (IBAction)	addCategoryAction:(id)sender;
- (IBAction)	deleteCategoryAction:(id)sender;
- (IBAction)	styleIconMatrixAction:(id)sender;
- (IBAction)	styleKeyChangeAction:(id)sender;
- (IBAction)	styleDeleteAction:(id) sender;
- (IBAction)	registryResetAction:(id) sender;
- (IBAction)	saveStylesToFileAction:(id) sender;
- (IBAction)	loadStylesFromFileAction:(id) sender;

- (DKStyleRegistry*)	styles;
- (void)				populateMatrixWithStyleInCategory:(NSString*) cat;
- (void)				updateUIForStyle:(DKStyle*) style;
- (void)				updateUIForCategory:(NSString*) category;

- (void)		sheetDidEnd:(NSWindow*) sheet returnCode:(int) returnCode  contextInfo:(void*) contextInfo;
- (void)		alertDidEnd:(NSAlert*) alert returnCode:(int) returnCode contextInfo:(void*) contextInfo;

@end
