///**********************************************************************************************************************************
///  DKGridLayer.h
///  DrawKit
///
///  Created by graham on 12/08/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKLayer.h"


typedef enum
{
	kGCMetricDrawingGrid			= 0,
	kGCImperialDrawingGrid,
	kGCImperialDrawingGridPCB
}
DKGridMeasurementSystem;


@interface DKGridLayer : DKLayer <NSCoding>
{
	NSColor*				m_spanColour;					// the colour of the spans grid
	NSColor*				m_divisionColour;				// the colour of the divisions grid
	NSColor*				m_majorColour;					// the colour of the majors grid
	NSBezierPath*			m_divsCache;					// the path for the divisions grid
	NSBezierPath*			m_spanCache;					// the path for the spans grid
	NSBezierPath*			m_majorsCache;					// the path for the majors grid
	NSPoint					m_zeroDatum;					// where "zero" is supposed to be
	double					m_spanDistance;					// the actual quartz distance for a single span
	float					m_spanLineWidth;				// the line width to draw the spans
	float					m_divisionLineWidth;			// the line width to draw the divisions
	float					m_majorLineWidth;				// the line width to draw the majors
	int						m_divisionsPerSpan;				// the number of divisions per span
	int						m_spansPerMajor;				// the number of spans per major
	int						m_rulerStepUpCycle;				// the ruler step-up cycle to use
	DKGridMeasurementSystem	m_msys;							// the general measurement system in use
	BOOL					m_cacheInLayer;					// YES if the grid is cache dusing a CGLayer
	CGLayerRef				m_cgl;							// the CGLayer when the grid is cached there
}

// setting class defaults:

+ (void)					setDefaultSpanColour:(NSColor*) colour;
+ (NSColor*)				defaultSpanColour;

+ (void)					setDefaultDivisionColour:(NSColor*) colour;
+ (NSColor*)				defaultDivisionColour;

+ (NSColor*)				defaultMajorColour;
+ (void)					setDefaultMajorColour:(NSColor*) colour;

+ (void)					setGridThemeColour:(NSColor*) colour;

+ (DKGridLayer*)			standardMetricGridLayer;
+ (DKGridLayer*)			standardImperialGridLayer;
+ (DKGridLayer*)			standardImperialPCBGridLayer;

// setting up the grid

- (void)					setMetricDefaults;
- (void)					setImperialDefaults;

// one-stop shop for setting grid, drawing and rulers in one hit:

- (void)					setSpan:(float) span
							unitToPointsConversionFactor:(float) conversionFactor
							measurementSystem:(DKGridMeasurementSystem) sys
							drawingUnits:(NSString*) units
							divisions:(int) divs
							majors:(int) majors
							rulerSteps:(int) steps;

// other settings:

- (void)					setSpan:(float) span divisions:(int) divs majors:(int) maj;
- (NSPoint)					divisionDistance;
- (void)					setZeroPoint:(NSPoint) zero;
- (NSPoint)					zeroPoint;
- (double)					span;
- (int)						divisions;
- (int)						majors;

// setting the measurement system (imperial/metric)

- (void)					setMeasurementSystem:(DKGridMeasurementSystem) sys;
- (DKGridMeasurementSystem)	measurementSystem;

// managing rulers and margins

- (void)					setRulerSteps:(int) steps;
- (int)						rulerSteps;
- (void)					synchronizeRulers;
- (void)					tweakDrawingMargins;

// colours for grid display

- (void)					setSpanColour:(NSColor*) colour;
- (NSColor*)				spanColour;
- (void)					setDivisionColour:(NSColor*) colour;
- (void)					setMajorColour:(NSColor*) colour;
- (void)					setGridThemeColour:(NSColor*) colour;

// converting between the base (Quartz) coordinate system and the grid

- (NSPoint)					nearestGridIntersectionToPoint:(NSPoint) p;
- (NSSize)					nearestGridIntegralToSize:(NSSize) size;
- (NSSize)					nearestGridSpanIntegralToSize:(NSSize) size;
- (NSPoint)					gridLocationForPoint:(NSPoint) pt;
- (NSPoint)					pointForGridLocation:(NSPoint) gpt;
- (float)					gridDistanceForQuartzDistance:(float) qd;
- (float)					quartzDistanceForGridDistance:(float) gd;

// private:

- (void)					invalidateCache;
- (void)					createGridCacheInRect:(NSRect) r;

// user actions

- (IBAction)				copy:(id) sender;
- (IBAction)				setMeasurementSystemAction:(id) sender;


@end


// fundamental constants for grid setup - do not change:

#define				kGCGridDrawingLayerMetricInterval		28.346456692913		// 1cm, = 72 / 2.54
#define				kGCGridDrawingLayerImperialInterval		72.00				// 1 inch


extern NSString*	kGCGridDrawingLayerStandardMetric;
extern NSString*	kGCGridDrawingLayerStandardImperial;
extern NSString*	kGCGridDrawingLayerStandardImperialPCB;



/*

This class is a layer that draws a grid like a piece of graph paper. In addition it can modify a point to lie at the intersection of
any of its "squares" (for snap to grid, etc).

The master interval is called the graph's span. It will be set to the actual number of coordinate units representing the main unit
of the grid. For example, a 1cm grid has a span of ~28.35.

The span is divided into an integral number of smaller divisions, for example 10 divisions of 1cm gives 1mm small squares.

A integral number of spans is called the major interval. This is drawn in a darker colour and bolder width. For example you could
highlight every 10cm by setting the spans per major to 10. The same style is also used to draw a border around the whole thing
allowing for the set margins.

Class methods exist to return a number of "standard" grids.

The spans, minor and major intervals are all drawn in different colours, but more typically you'll set a single "theme" colour which
derives the three colours such that they form a coherent set.

Grid Layers work with methods in DKDrawing to manage the rulers in an NSRulerView. Generally the rulers are set to align with the
span interval of the grid and allow for the drawing's margins. Because a ruler's settings require a name, you need to set this up along
with the grid's parameters. To help make this easy for a client application (that will probably want to present a user interface for
setting this all up), the "one stop shop" method -setSpan:unitToPointsConversionFactor:measurementSystem:drawingUnits:divisions:majors:rulerSteps:
will set up the grid AND the rulers provided the layer has already been added to a drawing. Due to limitations in NSRuler regarding its step up
and step down ratios, this method also imposes similar limits on the span divisions.

General-purpose "snap to grid" type methods are implemented by DKDrawing using the grid as a basis - the grid itself doesn't implement snapping.

Note: caching in a CGLayer is not recommended - the code is here but it doesn't draw nicely at high zooms. Turned off by default.

*/

