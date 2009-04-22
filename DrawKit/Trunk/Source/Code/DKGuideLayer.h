///**********************************************************************************************************************************
///  DKGuideLayer.h
///  DrawKit
///
///  Created by graham on 28/08/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************


#import "DKLayer.h"


@class DKGuide;


@interface DKGuideLayer : DKLayer <NSCoding>
{
	NSMutableArray*		m_hGuides;					// the list of horizontal guides
	NSMutableArray*		m_vGuides;					// the list of vertical guides
	BOOL				m_snapToGrid;				// YES if snap to grid is enabled
	BOOL				m_showDragInfo;				// YES if dragging a guide displays the floating info window
	DKGuide*			m_dragGuideRef;				// the current drag being dragged
	float				m_snapTolerance;			// the current snap tolerance value
}


// default snpping tolerance:

+ (void)				setSnapTolerance:(float) tol;
+ (float)				snapTolerance;

// adding and removing guides:

- (void)				addGuide:(DKGuide*) guide;
- (void)				removeGuide:(DKGuide*) guide;
- (void)				removeAllGuides;
- (DKGuide*)			createVerticalGuideAndBeginDraggingFromPoint:(NSPoint) p;
- (DKGuide*)			createHorizontalGuideAndBeginDraggingFromPoint:(NSPoint) p;

- (NSArray*)			guides;
- (void)				setGuides:(NSArray*) guides;

// finding guides close to a given position

- (DKGuide*)			nearestVerticalGuideToPosition:(float) pos;
- (DKGuide*)			nearestHorizontalGuideToPosition:(float) pos;
- (NSArray*)			verticalGuides;
- (NSArray*)			horizontalGuides;

// setting a common colour for the guides:

- (void)				setGuideColour:(NSColor*) colour;
- (NSColor*)			guideColour;

// set whether guides snap to grid or not

- (void)				setGuidesSnapToGrid:(BOOL) gridsnap;
- (BOOL)				guidesSnapToGrid;

// set the snapping tolerance for this layer

- (void)				setSnapTolerance:(float) tol;
- (float)				snapTolerance;

// set whether the info window is displayed or not

- (void)				setShowsDragInfoWindow:(BOOL) showsIt;
- (BOOL)				showsDragInfoWindow;

// snapping points and rects to the guides:

- (NSPoint)				snapPointToGuide:(NSPoint) p;
- (NSRect)				snapRectToGuide:(NSRect) r;
- (NSRect)				snapRectToGuide:(NSRect) r includingCentres:(BOOL) centre;
- (NSSize)				snapPointsToGuide:(NSArray*) arrayOfPoints;
- (NSSize)				snapPointsToGuide:(NSArray*) arrayOfPoints verticalGuide:(DKGuide**) gv horizontalGuide:(DKGuide**) gh;

// redrawing the guides

- (void)				refreshGuide:(DKGuide*) guide;
- (NSRect)				guideRect:(DKGuide*) guide;

// user actions:

- (IBAction)			clearGuides:(id) sender;

@end

// each guide is implemented by an instance of DKGuide:


@interface DKGuide : NSObject <NSCoding>
{
	float				m_position;
	BOOL				m_isVertical;
	NSColor*			m_colour;
}

- (void)				setPosition:(float) pos;
- (float)				position;
- (void)				setIsVerticalGuide:(BOOL) vert;
- (BOOL)				isVerticalGuide;
- (void)				setGuideColour:(NSColor*) colour;
- (NSColor*)			guideColour;


@end


/*

A guide layer implements any number of horizontal and vertical guidelines and provides methods for snapping points and rectangles
to them.

A drawing typically has one guide layer, though you are not limited to just one - however since DKDrawing will generally provide
snapping to both guides and grid as a high-level method, having more than one guide layer can create ambiguities for the user
unless your client code takes account of the possibility of multiple guide layers.

The default snap tolerance for guides is 6 points.

By default guides don't snap to the grid. You can force a guide to snap to the grid even if this setting is off by dragging with
the shift key down.

*/

