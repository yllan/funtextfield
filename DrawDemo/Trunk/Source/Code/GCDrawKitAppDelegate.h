/* GCDrawKitAppDelegate */

#import <Cocoa/Cocoa.h>


@interface GCDrawKitAppDelegate : NSObject
{
	id					mStyleInspector;
	id					mToolPalette;
	id					mObjectInspector;
	id					mLayersController;
	id					mStyleManager;
	id					mPrefsController;
	IBOutlet NSMenu*	mUserToolMenu;
}


- (IBAction)		showStyleInspector:(id) sender;
- (IBAction)		showToolPalette:(id) sender;
- (IBAction)		showObjectInspector:(id) sender;
- (IBAction)		showLayersPalette:(id) sender;
- (IBAction)		showStyleManagerDialog:(id) sender;
- (IBAction)		openPreferences:(id) sender;

- (IBAction)		temporaryPrivateChangeFontAction:(id) sender;

- (void)			openStyleInspector;
- (void)			drawingToolRegistrationNote:(NSNotification*) note;

- (void)			openToolPalette;
- (void)			openObjectInspector;

@end
