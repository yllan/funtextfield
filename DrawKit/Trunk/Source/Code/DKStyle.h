///**********************************************************************************************************************************
///  DKStyle.h
///  DrawKit
///
///  Created by graham on 13/08/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************


#import "DKRastGroup.h"


@class	DKDrawableObject;

// swatch types that can be passed to -styleSwatchWithSize:type:


typedef enum
{
	kGCStyleSwatchAutomatic			= -1,
	kGCStyleSwatchRectanglePath		= 0,
	kGCStyleSwatchCurvePath			= 1
}
DKStyleSwatchType;


// options that can be passed to -derivedStyleWithPasteboard:withOptions:


typedef enum
{
	kDKDerivedStyleDefault			= 0,
	kDKDerivedStyleForPathHint		= 1,
	kDKDerivedStyleForShapeHint		= 2
}
DKDerivedStyleOptions;



#define STYLE_SWATCH_SIZE		NSMakeSize( 128.0, 128.0 )

// n.b. for style registry API, see DKStyleRegistry.h



@interface DKStyle : DKRastGroup <NSCoding, NSCopying, NSMutableCopying>
{
	NSDictionary*			m_textAttributes;		// supports text additions
	NSUndoManager*			m_undoManagerRef;		// style's undo manager
	BOOL					m_shared;				// YES if the style is shared
	BOOL					m_locked;				// YES if style can't be edited
	id						m_renderClientRef;		// valid only while actually drawing
	NSString*				m_uniqueKey;			// unique key, set once for all time
	BOOL					m_mergeFlag;			// set to YES when a style is read in from a file and was saved in a registered state.
	NSTimeInterval			m_lastModTime;			// timestamp to determine when styles have been updated
	unsigned				m_clientCount;			// keeps count of the clients using the style
	NSMutableDictionary*	mSwatchCache;			// cache of swatches at various sizes previously requested
}

// basic standard styles:

+ (DKStyle*)			defaultStyle;			// very boring, black stroke and light gray fill
+ (DKStyle*)			defaultTrackStyle;		// grey stroke over wider black stroke, no fill

// easy construction of other simple styles:

+ (DKStyle*)			styleWithFillColour:(NSColor*) fc strokeColour:(NSColor*) sc;
+ (DKStyle*)			styleWithFillColour:(NSColor*) fc strokeColour:(NSColor*) sc strokeWidth:(float) sw;
+ (DKStyle*)			styleWithScript:(NSString*) spec;
+ (DKStyle*)			styleFromPasteboard:(NSPasteboard*) pb;

// pasted styles - separate non-persistent registry

+ (DKStyle*)			styleWithPasteboardName:(NSString*) name;
+ (void)				registerStyle:(DKStyle*) style withPasteboardName:(NSString*) pbname;

// default sharing flag

+ (void)				setStylesAreSharableByDefault:(BOOL) share;
+ (BOOL)				stylesAreSharableByDefault;

// convenient handy things:

+ (NSShadow*)			defaultShadow;

// updating & notifying clients:

- (void)				notifyClientsBeforeChange;
- (void)				notifyClientsAfterChange;
- (void)				styleWasAttached:(DKDrawableObject*) toObject;
- (void)				styleWillBeRemoved:(DKDrawableObject*) fromObject;
- (unsigned)			countOfClients;

// (text) attributes - basic support

- (void)				setTextAttributes:(NSDictionary*) attrs;
- (NSDictionary*)		textAttributes;
- (BOOL)				hasTextAttributes;
- (void)				removeTextAttributes;

// shared and locked status:

- (void)				setStyleSharable:(BOOL) share;
- (BOOL)				isStyleSharable;
- (void)				setLocked:(BOOL) lock;
- (BOOL)				locked;

// registry info:

- (BOOL)				isStyleRegistered;
- (NSArray*)			registryKeys;
- (NSString*)			uniqueKey;
- (void)				assignUniqueKey;
- (BOOL)				requiresRemerge;
- (void)				clearRemergeFlag;
- (NSTimeInterval)		lastModificationTimestamp;

// undo:

- (void)				setUndoManager:(NSUndoManager*) undomanager;
- (NSUndoManager*)		undoManager;
- (void)				changeKeyPath:(NSString*) keypath ofObject:(id) object toValue:(id) value;

// stroke utilities:

- (void)				scaleStrokeWidthsBy:(float) scale withoutInformingClients:(BOOL) quiet;
- (float)				maxStrokeWidth;
- (float)				maxStrokeWidthDifference;
- (void)				applyStrokeAttributesToPath:(NSBezierPath*) path;

// clipboard:

- (void)				copyToPasteboard:(NSPasteboard*) pb;
- (DKStyle*)			derivedStyleWithPasteboard:(NSPasteboard*) pb;
- (DKStyle*)			derivedStyleWithPasteboard:(NSPasteboard*) pb withOptions:(DKDerivedStyleOptions) options;

// new query methods:

- (BOOL)				hasStroke;
- (BOOL)				hasFill;
- (BOOL)				hasHatch;
- (BOOL)				hasTextAdornment;

// swatch images:

- (NSImage*)			styleSwatchWithSize:(NSSize) size type:(DKStyleSwatchType) type;
- (NSImage*)			standardStyleSwatch;
- (NSString*)			swatchCacheKeyForSize:(NSSize) size type:(DKStyleSwatchType) type;

// currently rendering client (may be queried by renderers)

- (id)					currentRenderClient;

// getting a style for drawing a hit-test bitmap based on this style

- (DKStyle*)			hitTestingStyle;


@end

// pasteboard types:

extern NSString*		kDKStylePasteboardType;
extern NSString*		kDKStyleKeyPasteboardType;

// notifications:

extern NSString*		kDKStyleWillChangeNotification;
extern NSString*		kDKStyleDidChangeNotification;
extern NSString*		kDKStyleWasAttachedNotification;
extern NSString*		kDKStyleWillBeDetachedNotification;
extern NSString*		kDKStyleLockStateChangedNotification;
extern NSString*		kDKStyleSharableFlagChangedNotification;
extern NSString*		kDKStyleNameChangedNotification;

