///**********************************************************************************************************************************
///  NSBezierPath-Geometry.h
///  DrawKit
///
///  Created by graham on 22/10/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>


@interface NSBezierPath (Geometry)

// simple transformations

- (NSBezierPath*)		scaledPath:(float) scale;
- (NSBezierPath*)		scaledPath:(float) scale aboutPoint:(NSPoint) cp;
- (NSBezierPath*)		rotatedPath:(float) angle;
- (NSBezierPath*)		rotatedPath:(float) angle aboutPoint:(NSPoint) cp;
- (NSBezierPath*)		insetPathBy:(float) amount;
- (NSBezierPath*)		horizontallyFlippedPathAboutPoint:(NSPoint) cp;
- (NSBezierPath*)		verticallyFlippedPathAboutPoint:(NSPoint) cp;
- (NSBezierPath*)		horizontallyFlippedPath;
- (NSBezierPath*)		verticallyFlippedPath;

- (NSPoint)				centreOfBounds;

- (NSBezierPath*)		paralleloidPathWithOffset:(float) delta;
- (NSBezierPath*)		paralleloidPathWithOffset2:(float) delta;
- (NSBezierPath*)		offsetPathWithStartingOffset:(float) delta1 endingOffset:(float) delta2;
- (NSBezierPath*)		offsetPathWithStartingOffset2:(float) delta1 endingOffset:(float) delta2;

// roughening and randomising paths

- (NSBezierPath*)		bezierPathByRandomisingPoints:(float) maxAmount;
- (NSBezierPath*)		bezierPathWithRoughenedStrokeOutline:(float) amount;
- (NSBezierPath*)		bezierPathWithFragmentedLineSegments:(float) flatness;

// zig-zags and waves

- (NSBezierPath*)		bezierPathWithZig:(float) zig zag:(float) zag;
- (NSBezierPath*)		bezierPathWithWavelength:(float) lambda amplitude:(float) amp spread:(float) spread;

// getting the outline of a stroked path:

- (NSBezierPath*)		strokedPath;
- (NSBezierPath*)		strokedPathWithStrokeWidth:(float) width;

// breaking a path apart:

- (NSArray*)			subPaths;
- (int)					countSubPaths;

// getting text layout rects for running text within a shape

- (NSArray*)			intersectingPointsWithHorizontalLineAtY:(float) yPosition;
- (NSArray*)			lineFragmentRectsForFixedLineheight:(float) lineHeight;
- (NSRect)				lineFragmentRectForProposedRect:(NSRect) aRect remainingRect:(NSRect*) rem;
- (NSRect)				lineFragmentRectForProposedRect:(NSRect) aRect remainingRect:(NSRect*) rem datumOffset:(float) dOffset;

// converting to and from Core Graphics paths

- (CGPathRef)			quartzPath;
- (CGMutablePathRef)	mutableQuartzPath;
- (CGContextRef)		setQuartzPath;
- (void)				setQuartzPathInContext:(CGContextRef) context isNewPath:(BOOL) np;

+ (NSBezierPath*)		bezierPathWithCGPath:(CGPathRef) path;
+ (NSBezierPath*)		bezierPathWithPathFromContext:(CGContextRef) context;

- (NSPoint)				pointOnPathAtLength:(float) length slope:(float*) slope;
- (float)				slopeStartingPath;

// drawing text along a path:

- (void)				drawTextOnPath:(NSAttributedString*) str yOffset:(float) dy;
- (void)				drawStringOnPath:(NSString*) str;
- (void)				drawStringOnPath:(NSString*) str attributes:(NSDictionary*) attrs;

- (NSBezierPath*)		bezierPathWithTextOnPath:(NSAttributedString*) str yOffset:(float) dy;
- (NSBezierPath*)		bezierPathWithStringOnPath:(NSString*) str;
- (NSBezierPath*)		bezierPathWithStringOnPath:(NSString*) str attributes:(NSDictionary*) attrs;

// drawing/placing/moving anything along a path:

- (NSArray*)			placeObjectsOnPathAtInterval:(float) interval factoryObject:(id) object userInfo:(void*) userInfo;
- (NSBezierPath*)		bezierPathWithObjectsOnPathAtInterval:(float) interval factoryObject:(id) object userInfo:(void*) userInfo;
- (NSBezierPath*)		bezierPathWithPath:(NSBezierPath*) path atInterval:(float) interval;

// placing "chain links" along a path:

- (NSArray*)			placeLinksOnPathWithLinkLength:(float) ll factoryObject:(id) object userInfo:(void*) userInfo;
- (NSArray*)			placeLinksOnPathWithEvenLinkLength:(float) ell oddLinkLength:(float) oll factoryObject:(id) object userInfo:(void*) userInfo;

// easy motion method:

- (void)				moveObject:(id) object atSpeed:(float) speed loop:(BOOL) loop userInfo:(id) userInfo;
- (void)				motionCallback:(NSTimer*) timer;

// clipping utilities:

- (void)				addInverseClip;

- (NSPoint)				firstPoint;
- (NSPoint)				lastPoint;

// trimming utilities - modified source originally from A J Houghton, see copyright notice below

- (NSBezierPath*)		bezierPathByTrimmingToLength:(float) trimLength;
- (NSBezierPath*)		bezierPathByTrimmingToLength:(float) trimLength withMaximumError:(float) maxError;

- (NSBezierPath*)		bezierPathByTrimmingFromLength:(float) trimLength;
- (NSBezierPath*)		bezierPathByTrimmingFromLength:(float) trimLength withMaximumError:(float) maxError;

- (NSBezierPath*)		bezierPathByTrimmingFromBothEnds:(float) trimLength;
- (NSBezierPath*)		bezierPathByTrimmingFromBothEnds:(float) trimLength withMaximumError:(float) maxError;

- (NSBezierPath*)		bezierPathByTrimmingFromCentre:(float) trimLength;
- (NSBezierPath*)		bezierPathByTrimmingFromCentre:(float) trimLength withMaximumError:(float) maxError;

- (NSBezierPath*)		bezierPathWithArrowHeadForStartOfLength:(float) length angle:(float) angle closingPath:(BOOL) closeit;
- (NSBezierPath*)		bezierPathWithArrowHeadForEndOfLength:(float)length angle:(float) angle closingPath:(BOOL) closeit;

- (void)				appendBezierPathRemovingInitialMoveToPoint:(NSBezierPath*) path;

- (float)				length;
- (float)				lengthWithMaximumError:(float) maxError;

@end


// informal protocol for placing objects at linear intervals along a bezier path. Will be called from placeObjectsOnPathAtInterval:withObject:userInfo:
// the <object> is called with this method if it implements it.

// the second method can be used to implement fluid motion along a path using the moveObject:alongPathDistance:inTime:userInfo: method.

// the links method is used to implement chain effects from the "placeLinks..." method.

@interface NSObject (BezierPlacement)

- (id)					placeObjectAtPoint:(NSPoint) p onPath:(NSBezierPath*) path position:(float) pos slope:(float) slope userInfo:(void*) userInfo;
- (BOOL)				moveObjectTo:(NSPoint) p position:(float) pos slope:(float) slope userInfo:(id) userInfo;
- (id)					placeLinkFromPoint:(NSPoint) pa toPoint:(NSPoint) pb onPath:(NSBezierPath*) path linkNumber:(int) lkn userInfo:(void*) userInfo;

@end

// undocumented Core Graphics:

extern CGPathRef	CGContextCopyPath( CGContextRef context );

/*
 * Bezier path utility category (trimming)
 *
 * (c) 2004 Alastair J. Houghton
 * All Rights Reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   1. Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *
 *   2. Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *
 *   3. The name of the author of this software may not be used to endorse
 *      or promote products derived from the software without specific prior
 *      written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER "AS IS" AND ANY EXPRESS
 * OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE COPYRIGHT OWNER BE LIABLE FOR ANY DIRECT, INDIRECT,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA OR PROFITS;
 * OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */


void	subdivideBezierAtT(const NSPoint bez[4], NSPoint bez1[4], NSPoint bez2[4], float t);

