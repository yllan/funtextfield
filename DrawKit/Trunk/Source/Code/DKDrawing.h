///**********************************************************************************************************************************
///  DKDrawing.h
///  DrawKit
///
///  Created by graham on 14/08/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKLayerGroup.h"


@class DKGridLayer, DKGuideLayer, DKKnob, DKViewController;


@interface DKDrawing : DKLayerGroup <NSCoding, NSCopying>
{
	NSSize					m_size;					// dimensions of the drawing
	float					m_leftMargin;			// margins
	float					m_rightMargin;
	float					m_topMargin;
	float					m_bottomMargin;
	float					m_unitConversionFactor;	// how many pixels does 1 unit cover?
	NSString*				m_units;				// user readable drawing units string, i.e. "millimetres"
	DKLayer*				m_activeRef;			// which one is active for editing, etc
	NSColor*				m_paperColour;			// underlying colour of the "paper"
	NSUndoManager*			m_undoManager;			// undo manager to use for data changes
	NSMutableDictionary*	m_meta;					// drawing info
	BOOL					mFlipped;				// YES if Y coordinates increase downwards, NO if they increase upwards
	BOOL					m_snapsToGrid;			// YES if grid snapping enabled
	BOOL					m_snapsToGuides;		// YES if guide snapping enabled
	BOOL					m_clipToInterior;		// YES to clip drawing to inside the interior region
	BOOL					m_useQandDRendering;	// if YES, renderers have the option to use a fast but low quality drawing method
	BOOL					m_isForcedHQUpdate;		// YES while refreshing to HQ after a LQ series
	BOOL					m_qualityModEnabled;	// YES if the quality modulation is enabled
	NSTimer*				m_renderQualityTimer;	// a timer used to set up high or low quality rendering dynamically
	NSTimeInterval			m_lastRenderTime;		// time the last render operation occurred
	NSTimeInterval			mTriggerPeriod;			// the time interval to use to trigger low quality rendering
	NSRect					m_lastRectUpdated;		// for refresh in HQ mode
	NSMutableSet*			mControllers;			// the set of current controllers
	NSString*				mUniqueKey;				// a key unique to this object
}

+ (int)						drawkitVersion;
+ (NSString*)				drawkitReleaseStatus;

+ (DKDrawing*)				defaultDrawingWithSize:(NSSize) aSize;

+ (DKDrawing*)				drawingWithContentsOfFile:(NSString*) filepath;
+ (DKDrawing*)				drawingWithData:(NSData*) drawingData;
+ (DKDrawing*)				drawingWithData:(NSData*) drawingData fromFileAtPath:(NSString*) filepath;

+ (NSMutableDictionary*)	defaultDrawingInfo;

+ (void)					saveDefaults;
+ (void)					loadDefaults;

// designated initializer:

- (id)						initWithSize:(NSSize) size;

// basic drawing parameters:

- (void)					setDrawingSize:(NSSize) aSize;
- (NSSize)					drawingSize;
- (void)					setDrawingSizeWithPrintInfo:(NSPrintInfo*) printInfo;

- (void)					setMarginsLeft:(float) l top:(float) t right:(float) r bottom:(float) b;
- (void)					setMarginsWithPrintInfo:(NSPrintInfo*) printInfo;
- (float)					leftMargin;
- (float)					rightMargin;
- (float)					topMargin;
- (float)					bottomMargin;
- (NSRect)					interior;
- (NSPoint)					pinPointToInterior:(NSPoint) p;

- (void)					setFlipped:(BOOL) flipped;
- (BOOL)					isFlipped;

// setting the rulers to the grid:

- (void)					setDrawingUnits:(NSString*) units unitToPointsConversionFactor:(float) conversionFactor;
- (NSString*)				drawingUnits;
- (NSString*)				abbreviatedDrawingUnits;
- (float)					unitToPointsConversionFactor;
- (void)					synchronizeRulersWithUnits:(NSString*) unitString;

// the drawing's view controllers

- (NSSet*)					controllers;
- (void)					addController:(DKViewController*) aController;
- (void)					removeController:(DKViewController*) aController;
- (void)					removeAllControllers;

- (void)					invalidateCursors;
- (void)					scrollToRect:(NSRect) rect;
- (void)					updateRulerMarkersForRect:(NSRect) rect;
- (void)					hideRulerMarkers;

- (void)					objectDidNotifyStatusChange:(id) object;
- (NSString*)				uniqueKey;

// dynamically adjusting the rendering quality:

- (void)					setDynamicQualityModulationEnabled:(BOOL) qmEnabled;
- (BOOL)					dynamicQualityModulationEnabled;

- (void)					setLowRenderingQuality:(BOOL) quickAndDirty;
- (BOOL)					lowRenderingQuality;
- (void)					checkIfLowQualityRequired;
- (void)					qualityTimerCallback:(NSTimer*) timer;
- (void)					setLowQualityTriggerInterval:(NSTimeInterval) t;
- (NSTimeInterval)			lowQualityTriggerInterval;

// setting the undo manager:

- (void)					setUndoManager:(NSUndoManager*) um;
- (NSUndoManager*)			undoManager;

// drawing meta-data:

- (void)					setDrawingInfo:(NSMutableDictionary*) info;
- (NSMutableDictionary*)	drawingInfo;

// rendering the drawing:

- (void)					setClipsDrawingToInterior:(BOOL) clip;
- (BOOL)					clipsDrawingToInterior;

- (void)					setPaperColour:(NSColor*) colour;
- (NSColor*)				paperColour;

- (void)					exitTemporaryTextEditingMode;

// active layer

- (BOOL)					setActiveLayer:(DKLayer*) aLayer;
- (BOOL)					setActiveLayer:(DKLayer*) aLayer withUndo:(BOOL) undo;
- (DKLayer*)				activeLayer;
- (id)						activeLayerOfClass:(Class) aClass;

// high level methods that help support a UI

- (void)					addLayer:(DKLayer*) aLayer andActivateIt:(BOOL) activateIt;
- (void)					removeLayer:(DKLayer*) aLayer andActivateLayer:(DKLayer*) anotherLayer;
- (NSString*)				uniqueLayerNameForName:(NSString*) aName;

// interaction with grid and guides

- (void)					setSnapsToGrid:(BOOL) snaps;
- (BOOL)					snapsToGrid;
- (void)					setSnapsToGuides:(BOOL) snaps;
- (BOOL)					snapsToGuides;

- (NSPoint)					snapToGrid:(NSPoint) p withControlFlag:(BOOL) snapControl;
- (NSPoint)					snapToGrid:(NSPoint) p ignoringUserSetting:(BOOL) ignore;
- (NSPoint)					snapToGuides:(NSPoint) p;
- (NSRect)					snapRectToGuides:(NSRect) r includingCentres:(BOOL) cent;
- (NSSize)					snapPointsToGuide:(NSArray*) points;

- (NSPoint)					nudgeOffset;

- (DKGridLayer*)			gridLayer;
- (DKGuideLayer*)			guideLayer;
- (float)					convertLength:(float) len;
- (NSPoint)					convertPoint:(NSPoint) pt;

// export:

- (void)					writeToFile:(NSString*) filename atomically:(BOOL) atom;
- (NSData*)					drawingAsXMLDataAtRoot;
- (NSData*)					drawingAsXMLDataForKey:(NSString*) key;
- (NSData*)					drawingData;
- (NSData*)					pdf;
- (void)					writePDFDataToPasteboard:(NSPasteboard*) pb;

@end

// notifications:

extern NSString*		kDKDrawingActiveLayerWillChange;
extern NSString*		kDKDrawingActiveLayerDidChange;
extern NSString*		kDKDrawingWillChangeSize;
extern NSString*		kDKDrawingDidChangeSize;
extern NSString*		kDKDrawingUnitsWillChange;
extern NSString*		kDKDrawingUnitsDidChange;
extern NSString*		kDKDrawingWillChangeMargins;
extern NSString*		kDKDrawingDidChangeMargins;

// keys for standard metadata items:

extern NSString*		kDKDrawingInfoDrawingNumber;			// data type NSString
extern NSString*		kDKDrawingInfoDrawingRevision;			// data type NSString
extern NSString*		kDKDrawingInfoDraughter;				// data type NSString
extern NSString*		kDKDrawingInfoCreationDate;				// data type NSDate
extern NSString*		kDKDrawingInfoLastModificationDate;		// data type NSDate
extern NSString*		kDKDrawingInfoModificationHistory;		// data type NSArray
extern NSString*		kDKDrawingInfoOriginalFilename;			// data type NSString

/*

A DKDrawing is the model data for the drawing system. Usually a document will own one of these. A drawing consists of one or more DKLayers,
each of which contains any number of drawable objects, or implements some special feature such as a grid or guides, etc.

A drawing can have multiple views, though typically it will have only one. Each view is managed by a single view controller, either an instance
or subclass of DKViewController. Drawing updates refersh all views via their controllers, and input from the views is directed to the current
active layer through the controller. The drawing owns the controllers, but the views are owned as normal by their respective superviews. The controller
provides only weak references to both drawing and view to prevent potential retain cycles when a view owns a drawing for the automatic backend scenario.
 
The drawing and the attached views must all have the same bounds size (though the views are free to have any desired frame). Setting the
drawing size will adjust the views' bounds automatically.

The active layer will receive mouse events from any of the attached views via its controller. (Because the user can't mouse in more than one view
at a time, there is no contention here.) The commands will go to whichever view is the current responder and be passed on appropriately.

Drawings can be saved simply by archiving them, thus all parts of the drawing need to adopt the NSCoding protocol.

*/


// this helper is used when unarchiving to translate class names from older files to their modern equivalents

@interface DKUnarchivingHelper : NSObject
{
	unsigned mChangeCount;
}

- (unsigned)  changeCount;	

@end

