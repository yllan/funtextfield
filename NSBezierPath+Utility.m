//
//  NSBezierPath+Utility.m
//  FunTextField
//
//  Created by Yung-Luen Lan on 6/22/08.
//  Copyright 2008 yllan.org. All rights reserved.
//

#import "NSBezierPath+Utility.h"
#import <ApplicationServices/ApplicationServices.h>

static inline CGFloat slopeBetweenTwoPoints(const NSPoint a, const NSPoint b)
{    
    return atan2f(b.y - a.y, b.x - a.x);
}

static inline CGFloat distanceBetween(NSPoint a, NSPoint b)
{
    return (CGFloat) hypot(a.x - b.x, a.y - b.y);
}

static void subdivideBezier(const NSPoint bez[4], NSPoint bez1[4], NSPoint bez2[4])
{
    NSPoint q;
    
    // Subdivide the Bezier further
    bez1[0].x = bez[0].x;
    bez1[0].y = bez[0].y;
    bez2[3].x = bez[3].x;
    bez2[3].y = bez[3].y;
    
    q.x = (bez[1].x + bez[2].x) / 2.0;
    q.y = (bez[1].y + bez[2].y) / 2.0;
    bez1[1].x = (bez[0].x + bez[1].x) / 2.0;
    bez1[1].y = (bez[0].y + bez[1].y) / 2.0;
    bez2[2].x = (bez[2].x + bez[3].x) / 2.0;
    bez2[2].y = (bez[2].y + bez[3].y) / 2.0;
    
    bez1[2].x = (bez1[1].x + q.x) / 2.0;
    bez1[2].y = (bez1[1].y + q.y) / 2.0;
    bez2[1].x = (q.x + bez2[2].x) / 2.0;
    bez2[1].y = (q.y + bez2[2].y) / 2.0;
    
    bez1[3].x = bez2[0].x = (bez1[2].x + bez2[1].x) / 2.0;
    bez1[3].y = bez2[0].y = (bez1[2].y + bez2[1].y) / 2.0;
}


static CGFloat lengthOfBezier(const  NSPoint bez[4], CGFloat acceptableError)
{
    CGFloat polyLen = 0.0;
    CGFloat chordLen = distanceBetween(bez[0], bez[3]);
    CGFloat retLen, errLen;
    unsigned n;
    
    for (n = 0; n < 3; ++n)
        polyLen += distanceBetween(bez[n], bez[n + 1]);
    
    errLen = polyLen - chordLen;
    
    if (errLen > acceptableError) {
        NSPoint left[4], right[4];
        subdivideBezier(bez, left, right);
        retLen = (lengthOfBezier(left, acceptableError) + lengthOfBezier(right, acceptableError));
    } else {
        retLen = 0.5 * (polyLen + chordLen);
    }
    
    return retLen;
}


void subdivideBezierAtT(const NSPoint bez[4], NSPoint bez1[4], NSPoint bez2[4], float t)
{
    NSPoint q;
    float mt = 1 - t;
    
    // Subdivide the Bezier further
    bez1[0].x = bez[0].x;
    bez1[0].y = bez[0].y;
    bez2[3].x = bez[3].x;
    bez2[3].y = bez[3].y;
    
    q.x = mt * bez[1].x + t * bez[2].x;
    q.y = mt * bez[1].y + t * bez[2].y;
    bez1[1].x = mt * bez[0].x + t * bez[1].x;
    bez1[1].y = mt * bez[0].y + t * bez[1].y;
    bez2[2].x = mt * bez[2].x + t * bez[3].x;
    bez2[2].y = mt * bez[2].y + t * bez[3].y;
    
    bez1[2].x = mt * bez1[1].x + t * q.x;
    bez1[2].y = mt * bez1[1].y + t * q.y;
    bez2[1].x = mt * q.x + t * bez2[2].x;
    bez2[1].y = mt * q.y + t * bez2[2].y;
    
    bez1[3].x = bez2[0].x = mt * bez1[2].x + t * bez2[1].x;
    bez1[3].y = bez2[0].y = mt * bez1[2].y + t * bez2[1].y;
}

// Split a Bezier curve at a specific length
static float subdivideBezierAtLength (const NSPoint bez[4],
                                      NSPoint bez1[4],
                                      NSPoint bez2[4],
                                      float length,
                                      float acceptableError)
{
    float top = 1.0, bottom = 0.0;
    float t, prevT;
    
    prevT = t = 0.5;
    for (;;) {
        float len1;
        
        subdivideBezierAtT(bez, bez1, bez2, t);
        
        len1 = lengthOfBezier(bez1, 0.5 * acceptableError);
        
        if (fabs(length - len1) < acceptableError)
            return len1;
        
        if (length > len1) {
            bottom = t;
            t = 0.5 * (t + top);
        } else if (length < len1) {
            top = t;
            t = 0.5 * (bottom + t);
        }
        
        if (t == prevT)
            return len1;
        
        prevT = t;
    }
}

@implementation NSBezierPath (YLUtility)

- (NSBezierPath*) paralleloidPathWithOffset: (float)delta
{
    // returns a copy of the receiver modified by offsetting all of its control points by <delta> in the direction of the
    // normal of the path at the location of the on-path control point. This will create a parallel-ish offset path that works
    // for most non-pathological paths. Given that there is no known mathematically correct way to do this, this works well enough in
    // many practical situations. Positive delta moves the path below or to the right, -ve is up and left.
    
    NSBezierPath* newPath = [NSBezierPath bezierPath];
    
    if (![self isEmpty]) {
        int i, count = [self elementCount];
        NSPoint ap[3], np[3], p0, p1;
        NSBezierPathElement kind, nextKind;
        CGFloat slope, dx, dy, pdx, pdy;
        
        pdx = pdy = 0;
        
        for (i = 0; i < count; ++i) {
            kind = [self elementAtIndex:i associatedPoints: ap];
            
            if (i < count - 1) {
                nextKind = [self elementAtIndex: i + 1 associatedPoints: np];
                
                // calculate the slope of the on-path point
                if (kind != NSCurveToBezierPathElement) {
                    p0 = ap[0];
                    p1 = np[0];
                } else {
                    p0 = ap[2];
                    p1 = np[0];
                }
            } else {
                if (kind == NSCurveToBezierPathElement) {
                    p1 = ap[2];
                    p0 = ap[1];
                } else {
                    p1 = ap[0];
                    
                    nextKind = [self elementAtIndex:i - 1 associatedPoints:np];
                    
                    if (nextKind != NSCurveToBezierPathElement)
                        p0 = np[0];
                    else
                        p0 = np[2];
                }
            }
            
            slope = atan2f(p1.y - p0.y, p1.x - p0.x) + (pi * 0.5);
            
            // calculate the position of the modified point
            dx = delta * cosf(slope);
            dy = delta * sinf(slope);
            
            switch( kind ) {
                case NSMoveToBezierPathElement:
                    ap[0].x += dx;
                    ap[0].y += dy;
                    [newPath moveToPoint: ap[0]];
                    break;
                    
                case NSLineToBezierPathElement:
                    ap[0].x += dx;
                    ap[0].y += dy;
                    [newPath lineToPoint: ap[0]];
                    break;
                    
                case NSCurveToBezierPathElement:
                    ap[0].x += pdx;
                    ap[0].y += pdy;
                    ap[1].x += dx;
                    ap[1].y += dy;
                    ap[2].x += dx;
                    ap[2].y += dy;
                    [newPath curveToPoint: ap[2] controlPoint1: ap[0] controlPoint2: ap[1]];
                    break;
                    
                case NSClosePathBezierPathElement:
                    [newPath closePath];
                    break;
                    
                default:
                    break;
            }
            
            pdx = dx;
            pdy = dy;
        }
    }
    
    return newPath;
}

#pragma mark -
- (NSBezierPath*) bezierPathByStrippingRedundantElements
{    
    NSBezierPath* newPath = [self copy];
    
    if (![self isEmpty]) {
        int    i, count = [self elementCount];
        NSPoint ap[3];
        NSPoint    pp;
        NSBezierPathElement    kind;
        
        pp = NSMakePoint(-1, -1);
        [newPath removeAllPoints];
        
        for (i = 0; i < count; ++i) {
            kind = [self elementAtIndex:i associatedPoints:ap];
            
            switch (kind) {
                default:
                case NSMoveToBezierPathElement:
                    // redundant if this is the last element
                    if (i < (count - 1))
                        [newPath moveToPoint:ap[0]];
                    pp = ap[0];
                    break;
                    
                case NSLineToBezierPathElement:
                    // redundant if its length is zero                    
                    if ( !NSEqualPoints( ap[0], pp ))
                        [newPath lineToPoint:ap[0]];
                    pp = ap[0];
                    break;
                    
                case NSCurveToBezierPathElement:
                    // redundant if its endpoint and control points are the same as the previous point                    
                    if (!(NSEqualPoints(pp, ap[0]) && NSEqualPoints(pp, ap[1]) && NSEqualPoints(pp, ap[2])))
                        [newPath curveToPoint:ap[2] controlPoint1:ap[0] controlPoint2:ap[1]];
                    pp = ap[2];
                    break;
                    
                case NSClosePathBezierPathElement:
                    [newPath closePath];
                    break;
            }
        }
    }
    return [newPath autorelease];
}

- (NSBezierPath *) bezierPathByTrimmingToLength: (float)trimLength
{
    return [self bezierPathByTrimmingToLength:trimLength withMaximumError: 0.1];
}


/* Return an NSBezierPath corresponding to the first trimLength units
 of this NSBezierPath. */
- (NSBezierPath *) bezierPathByTrimmingToLength:(float)trimLength withMaximumError:(float) maxError
{
    NSBezierPath *newPath = [NSBezierPath bezierPath];
    int    elements = [self elementCount];
    int    n;
    float length = 0.0;
    NSPoint pointForClose = NSZeroPoint;
    NSPoint lastPoint = NSZeroPoint;
    
    for (n = 0; n < elements; ++n) {
        NSPoint    points[3];
        NSBezierPathElement element = [self elementAtIndex: n associatedPoints: points];
        float elementLength;
        float remainingLength = trimLength - length;
        
        switch (element) {
            case NSMoveToBezierPathElement:
                [newPath moveToPoint: points[0]];
                pointForClose = lastPoint = points[0];
                continue;
                
            case NSLineToBezierPathElement:
                elementLength = distanceBetween(lastPoint, points[0]);
                
                if (length + elementLength <= trimLength)
                    [newPath lineToPoint:points[0]];
                else
                {
                    float f = remainingLength / elementLength;
                    [newPath lineToPoint: NSMakePoint(lastPoint.x + f * (points[0].x - lastPoint.x), lastPoint.y + f * (points[0].y - lastPoint.y))];
                    return newPath;
                }
                
                length += elementLength;
                lastPoint = points[0];
                break;
                
            case NSCurveToBezierPathElement:
            {
                NSPoint bezier[4] = {lastPoint, points[0], points[1], points[2]};
                elementLength = lengthOfBezier (bezier, maxError);
                
                if (length + elementLength <= trimLength)
                    [newPath curveToPoint: points[2] controlPoint1: points[0] controlPoint2: points[1]];
                else
                {
                    NSPoint bez1[4], bez2[4];
                    subdivideBezierAtLength(bezier, bez1, bez2, remainingLength, maxError);
                    [newPath curveToPoint: bez1[3] controlPoint1: bez1[1] controlPoint2: bez1[2]];
                    return newPath;
                }
                
                length += elementLength;
                lastPoint = points[2];
                break;
            }
                
            case NSClosePathBezierPathElement:
                elementLength = distanceBetween(lastPoint, pointForClose);
                
                if (length + elementLength <= trimLength) {
                    [newPath closePath];
                } else {
                    float f = remainingLength / elementLength;
                    [newPath lineToPoint: NSMakePoint(lastPoint.x + f * (pointForClose.x - lastPoint.x), lastPoint.y + f * (pointForClose.y - lastPoint.y))];
                    return newPath;
                }
                
                length += elementLength;
                lastPoint = pointForClose;
                break;
                
            default:
                break;
        }
    } 
    return newPath;
}


// Convenience method
- (NSBezierPath *) bezierPathByTrimmingFromLength: (float)trimLength
{
    return [self bezierPathByTrimmingFromLength: trimLength withMaximumError: 0.1];
}


/* Return an NSBezierPath corresponding to the part *after* the first trimLength units of this NSBezierPath. */
- (NSBezierPath *) bezierPathByTrimmingFromLength: (float)trimLength withMaximumError: (float)maxError
{
    NSBezierPath *newPath = [NSBezierPath bezierPath];
    int elements = [self elementCount];
    int n;
    float length = 0.0;
    NSPoint pointForClose = NSMakePoint (0.0, 0.0);
    NSPoint lastPoint = NSMakePoint (0.0, 0.0);
    
    for (n = 0; n < elements; ++n) {
        NSPoint    points[3];
        NSBezierPathElement element = [self elementAtIndex:n associatedPoints:points];
        float elementLength;
        float remainingLength = trimLength - length;
        
        switch (element) {
            case NSMoveToBezierPathElement:
                if (length > trimLength)
                    [newPath moveToPoint: points[0]];
                pointForClose = lastPoint = points[0];
                continue;
                
            case NSLineToBezierPathElement:
                elementLength = distanceBetween(lastPoint, points[0]);
                
                if (length > trimLength)
                    [newPath lineToPoint: points[0]];
                else if (length + elementLength > trimLength) {
                    float f = remainingLength / elementLength;
                    [newPath moveToPoint: NSMakePoint(lastPoint.x + f * (points[0].x - lastPoint.x), lastPoint.y + f * (points[0].y - lastPoint.y))];
                    [newPath lineToPoint: points[0]];
                }
                
                length += elementLength;
                lastPoint = points[0];
                break;
                
            case NSCurveToBezierPathElement:
            {
                NSPoint bezier[4] = { lastPoint, points[0], points[1], points[2] };
                elementLength = lengthOfBezier (bezier, maxError);
                
                if (length > trimLength)
                    [newPath curveToPoint:points[2] controlPoint1:points[0] controlPoint2:points[1]];
                else if (length + elementLength > trimLength) {
                    NSPoint bez1[4], bez2[4];
                    subdivideBezierAtLength(bezier, bez1, bez2, remainingLength, maxError);
                    [newPath moveToPoint: bez2[0]];
                    [newPath curveToPoint: bez2[3] controlPoint1: bez2[1] controlPoint2: bez2[2]];
                }
                
                length += elementLength;
                lastPoint = points[2];
                break;
            }
                
            case NSClosePathBezierPathElement:
                elementLength = distanceBetween(lastPoint, pointForClose);
                
                if (length > trimLength) {
                    [newPath lineToPoint: pointForClose];
                    [newPath closePath];
                } else if (length + elementLength > trimLength) {
                    float f = remainingLength / elementLength;
                    [newPath moveToPoint: NSMakePoint(lastPoint.x + f * (points[0].x - lastPoint.x), lastPoint.y + f * (points[0].y - lastPoint.y))];
                    [newPath lineToPoint: points[0]];
                }
                
                length += elementLength;
                lastPoint = pointForClose;
                break;
                
            default:
                break;
        }
    } 
    return newPath;
}


- (NSPoint) pointOnPathAtLength: (CGFloat)length slope: (CGFloat*)slope
{
    // Given a length in terms of the distance from the path start, this returns the point and slope of the path at that position. This works for any path made up of line or curve segments or combinations of them. This should be used with paths that have no subpaths. If the path has less than two elements, the result is NSZeroPoint.
    
    NSPoint p = NSZeroPoint;
    NSPoint ap[3], lp[3];
    NSBezierPathElement    pre, elem;
    
    if ([self elementCount] < 2)
        return p;
    
    if (length <= 0.0) {
        [self elementAtIndex:0 associatedPoints:ap];
        p = ap[0];
        
        [self elementAtIndex:1 associatedPoints:lp];
        
        if (slope)
            *slope = slopeBetweenTwoPoints(ap[0], lp[0]);
    } else {
        NSBezierPath* temp = [self bezierPathByTrimmingToLength:length];
        
        // given the trimmed path, the desired point is at the end of the path.
        int    ec = [temp elementCount];
        float slp = 1;
        
        if (ec > 1) {
            elem = [temp elementAtIndex: ec - 1 associatedPoints: ap];
            pre = [temp elementAtIndex: ec - 2 associatedPoints: lp];
            
            if (pre == NSCurveToBezierPathElement)
                lp[0] = lp[2];
            
            if (elem == NSCurveToBezierPathElement) {
                slp = slopeBetweenTwoPoints( ap[1], ap[2] );
                p = ap[2];
            } else {
                slp = slopeBetweenTwoPoints( lp[0], ap[0] );
                p = ap[0];
            }
        }
        
        if (slope)
            *slope = slp;
    }
    return p;
}

#pragma mark -

- (NSBezierPath*) bezierPathWithTextOnPath: (NSAttributedString*)str yOffset: (float)dy
{
    // returns a new path consisting of the glyphs laid out along the current path from <str>
    if ([self elementCount] < 2 || [str length] < 1)
        return nil;    // nothing useful to do
    
    NSBezierPath *newPath = [NSBezierPath bezierPath];
    NSPoint    start;

    [self elementAtIndex: 0 associatedPoints: &start];
    [newPath moveToPoint: start];

    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSBezierPath *temp, *glyphTemp;

    // get the first line
    CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString((CFAttributedStringRef)str);
    CFIndex count = CTTypesetterSuggestLineBreak(typesetter, 0, [self length]);
    CTLineRef line = CTTypesetterCreateLine(typesetter, CFRangeMake(0, count));
    
    CFIndex glyphCount = CTLineGetGlyphCount(line);
    if (glyphCount == 0) 
        goto finalize;    
    
    CFArrayRef runArray = CTLineGetGlyphRuns(line);
    CFIndex runCount = CFArrayGetCount(runArray);
    CFIndex glyphOffset = 0;
    CFIndex runIndex = 0;
    
    for (; runIndex < runCount; runIndex++) {
        CTRunRef run = (CTRunRef)CFArrayGetValueAtIndex(runArray, runIndex);
        CFIndex runGlyphCount = CTRunGetGlyphCount(run);
        CTFontRef runFont = CFDictionaryGetValue(CTRunGetAttributes(run), kCTFontAttributeName);

        CFIndex runGlyphIndex = 0;
        CGGlyph *glyphs = (CGGlyph *) malloc(sizeof(CGGlyph) * runGlyphCount);
        CTRunGetGlyphs(run, CFRangeMake(0, runGlyphCount), glyphs);
        
        for (; runGlyphIndex < runGlyphCount; runGlyphIndex++) {
            CFRange glyphRange = CFRangeMake(runGlyphIndex, 1);
            CGFloat width = CTRunGetTypographicBounds(run, glyphRange, NULL, NULL, NULL);
            CGFloat halfWidth = width / 2;
            if (width < 0.00001) 
                continue;
            
            CGPoint position;
            CTRunGetPositions(run, glyphRange, &position);
            
            temp = [self bezierPathByTrimmingFromLength: position.x + halfWidth];
            if ([temp length] < halfWidth)
                continue;
            
            NSPoint viewLocation = NSZeroPoint;
            [temp elementAtIndex: 0 associatedPoints: &viewLocation];
            CGFloat angle = [temp slopeStartingPath];
            
            // view location needs to be projected back along the baseline tangent by half the character width to align
            // the character based on the middle of the glyph instead of the left edge            
            viewLocation.x -= halfWidth * cosf(angle);
            viewLocation.y -= halfWidth * sinf(angle);
            
            NSAffineTransform *transform = [NSAffineTransform transform];
            [transform translateXBy: viewLocation.x yBy: viewLocation.y];
            [transform rotateByRadians: angle];
                        
            glyphTemp = [[NSBezierPath alloc] init];
            [glyphTemp moveToPoint: NSMakePoint(0, dy)];
            [glyphTemp appendBezierPathWithGlyph: (NSGlyph)glyphs[runGlyphIndex] inFont: (NSFont *)runFont];
            [glyphTemp transformUsingAffineTransform: transform];
            
            [newPath appendBezierPath: glyphTemp];
            [glyphTemp release];
        }
        free(glyphs);
        glyphOffset += runGlyphCount;
    }

finalize:
    
    [pool release];

    CFRelease(typesetter);
    CFRelease(line);

    return newPath;
}


- (NSBezierPath*) bezierPathWithStringOnPath: (NSString*)str
{
    return [self bezierPathWithStringOnPath:str attributes:nil];
}


- (NSBezierPath*) bezierPathWithStringOnPath: (NSString*)str attributes: (NSDictionary*)attrs
{
    NSAttributedString* as = [[NSAttributedString alloc] initWithString: str attributes: attrs];
    NSBezierPath* np = [self bezierPathWithTextOnPath: as yOffset: 0];
    [as release];
    return np;
}

#pragma mark -
- (CGFloat) slopeStartingPath
{
    // returns the slope starting the path
    if ([self elementCount] > 1) {
        NSPoint    ap[3], lp[3];

        [self elementAtIndex: 0 associatedPoints: ap];
        [self elementAtIndex: 1 associatedPoints: lp];
        
        return slopeBetweenTwoPoints(ap[0], lp[0]);
    }
    else
        return 0;
}


- (CGFloat) length
{
    return [self lengthWithMaximumError: 0.1];
}

// Estimate the total length of a Bezier path
- (CGFloat) lengthWithMaximumError: (float)maxError
{
    int elements = [self elementCount];
    int n;
    CGFloat length = 0.0;
    NSPoint pointForClose = NSMakePoint(0.0, 0.0);
    NSPoint lastPoint = NSMakePoint(0.0, 0.0);
    
    for (n = 0; n < elements; ++n) {
        NSPoint    points[3];
        NSBezierPathElement element = [self elementAtIndex: n associatedPoints: points];
        
        switch (element) {
            case NSMoveToBezierPathElement:
                pointForClose = lastPoint = points[0];
                break;
                
            case NSLineToBezierPathElement:
                length += distanceBetween(lastPoint, points[0]);
                lastPoint = points[0];
                break;
                
            case NSCurveToBezierPathElement:
            {
                NSPoint bezier[4] = { lastPoint, points[0], points[1], points[2] };
                length += lengthOfBezier(bezier, maxError);
                lastPoint = points[2];
                break;
            }
                
            case NSClosePathBezierPathElement:
                length += distanceBetween(lastPoint, pointForClose);
                lastPoint = pointForClose;
                break;

            default:
                break;
        }
    }
    
    return length;
}


@end
