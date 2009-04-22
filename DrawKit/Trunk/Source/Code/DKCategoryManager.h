///**********************************************************************************************************************************
///  DKCategoryManager.h
///  DrawKit
///
///  Created by graham on 21/03/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>


@interface DKCategoryManager : NSObject <NSCoding>
{
	NSMutableDictionary*	m_masterList;
	NSMutableDictionary*	m_categories;
	NSMutableArray*			m_recentlyAdded;
	NSMutableArray*			m_recentlyUsed;
	int						m_maxRecentlyAddedItems;
	int						m_maxRecentlyUsedItems;
}

+ (DKCategoryManager*)	categoryManager;
+ (DKCategoryManager*)	categoryManagerWithDictionary:(NSDictionary*) dict;

// initialization

- (id)					initWithData:(NSData*) data;
- (id)					initWithDictionary:(NSDictionary*) dict;

// adding and retrieving objects

- (void)				addObject:(id) obj forKey:(NSString*) name toCategory:(NSString*) catName createCategory:(BOOL) cg;
- (void)				addObject:(id) obj forKey:(NSString*) name toCategories:(NSArray*) catNames createCategories:(BOOL) cg;
- (void)				removeObjectForKey:(NSString*) key;
- (void)				removeObjectsForKeys:(NSArray*) keys;

- (BOOL)				containsKey:(NSString*) name;
- (unsigned)			count;

- (id)					objectForKey:(NSString*) key;
- (id)					objectForKey:(NSString*) key addToRecentlyUsedItems:(BOOL) add;

- (NSArray*)			keysForObject:(id) obj;
- (NSDictionary*)		dictionary;

// retrieving lists of objects by category

- (NSArray*)			objectsInCategory:(NSString*) catName;
- (NSArray*)			objectsInCategories:(NSArray*) catNames;
- (NSArray*)			allKeysInCategory:(NSString*) catName;
- (NSArray*)			allKeysInCategories:(NSArray*) catNames;
- (NSArray*)			allKeys;
- (NSArray*)			allObjects;
- (NSArray*)			allSortedKeysInCategory:(NSString*) catName;

- (NSArray*)			recentlyAddedItems;
- (NSArray*)			recentlyUsedItems;

// category management - creating, deleting and renaming categories

- (void)				addCategory:(NSString*) catName;
- (void)				addCategories:(NSArray*) catNames;
- (void)				removeCategory:(NSString*) catName;
- (void)				renameCategory:(NSString*) catName to:(NSString*) newname;

- (void)				addKey:(NSString*) key toCategory:(NSString*) catName createCategory:(BOOL) cg;
- (void)				addKey:(NSString*) key toCategories:(NSArray*) catNames createCategories:(BOOL) cg;
- (void)				removeKey:(NSString*) key fromCategory:(NSString*) catName;
- (void)				removeKey:(NSString*) key fromCategories:(NSArray*) catNames;
- (void)				removeKeyFromAllCategories:(NSString*) key;
- (void)				fixUpCategories;
- (void)				renameKey:(NSString*) key to:(NSString*) newKey;

// getting lists, etc. of the categories

- (NSArray*)			allCategories;
- (NSArray*)			categoriesContainingKey:(NSString*) key;

- (BOOL)				categoryExists:(NSString*) catName;
- (unsigned)			countOfObjectsInCategory:(NSString*) catName;
- (BOOL)				key:(NSString*) key existsInCategory:(NSString*) catName;

// managing recent lists

- (BOOL)				addKey:(NSString*) key toRecentList:(int) whichList;
- (void)				removeKey:(NSString*) key fromRecentList:(int) whichList;
- (void)				setRecentList:(int) whichList maxItems:(int) max;

// archiving

- (NSData*)				data;

// supporting UI:
// menus of just the categories:

- (NSMenu*)				categoriesMenuWithSelector:(SEL) sel target:(id) target;
- (NSMenu*)				categoriesMenuWithSelector:(SEL) sel target:(id) target options:(int) options;
- (void)				checkItemsInMenu:(NSMenu*) menu forCategoriesContainingKey:(NSString*) key;

// a menu with everything, organised hierarchically by category. Callback is called for each new item - see protocol below

- (NSMenu*)				createItemMenuWithItemCallback:(id) callback isPopUpMenu:(BOOL) isPopUp;

@end

// various constants:

enum
{
	kGCDefaultMaxRecentArraySize	= 12,
	kGCListRecentlyAdded			= 0,
	kGCListRecentlyUsed				= 1
};

// menu creation options:

enum
{
	kGCIncludeRecentlyAddedItems	= ( 1 << 0 ),
	kGCIncludeRecentlyUsedItems		= ( 1 << 1 ),
	kGCIncludeAllItems				= ( 1 << 2 ),
	kGCDontAddDividingLine			= ( 1 << 3 )
};

// standard name for "All items" category:

extern NSString*	kGCDefaultCategoryName;

extern NSString*	kGCRecentlyAddedUserString;
extern NSString*	kGCRecentlyUsedUserString;

extern NSString*	kGCCategoryManagerWillAddObject;
extern NSString*	kGCCategoryManagerDidAddObject;
extern NSString*	kGCCategoryManagerWillRemoveObject;
extern NSString*	kGCCategoryManagerDidRemoveObject;
extern NSString*	kGCCategoryManagerDidRenameCategory;
extern NSString*	kGCCategoryManagerWillAddKeyToCategory;
extern NSString*	kGCCategoryManagerDidAddKeyToCategory;
extern NSString*	kGCCategoryManagerWillRemoveKeyFromCategory;
extern NSString*	kGCCategoryManagerDidRemoveKeyFromCategory;

// informal protocol used by the createItemMenuWithItemCallback method:

@interface NSObject (CategoryManagerMenuCallback)

- (void)			menuItem:(NSMenuItem*) item wasAddedForObject:(id) object inCategory:(NSString*) category;

@end

/*

This is a useful container class that is like a "super dictionary" or maybe a "micro-database". As well as storing an object using a key,
it allows the object to be associated with none, one or more categories. An object can be a member of any number of categories.

As objects are added and used, they are automatically tracked in a "recently added" and "recently used" list, which can be retreived at any time.

As with a dictionary, an object is associated with a key. In addition to storing the object against that key, the key is added to the categories
that the object is a member of. This facilitates category-oriented lookups of objects.


*/


