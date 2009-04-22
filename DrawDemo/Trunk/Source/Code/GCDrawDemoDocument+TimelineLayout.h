///**********************************************************************************************************************************
///  GCDrawDemoDocument+TimelineLayout.h
///  GCDrawKit
///
///  Created by graham on 07/07/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "GCDrawDemoDocument.h"


@class DKObjectDrawingLayer, DKDrawablePath, DKStyle;



@interface GCDrawDemoDocument (TimelineLayout)

- (void)				performTimelineLayoutWithLayer:(DKObjectDrawingLayer*) layer showAsYouGo:(BOOL) showIt;

- (DKDrawablePath*)		leaderLineFromPoint:(NSPoint) p1 toPoint:(NSPoint) p2;
- (NSBezierPath*)		leaderLinePathFromPoint:(NSPoint) p1 toPoint:(NSPoint) p2;
- (DKStyle*)			leaderLineStyle;

- (IBAction)			timelineAction:(id) sender;


@end
