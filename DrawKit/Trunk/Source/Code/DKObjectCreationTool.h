///**********************************************************************************************************************************
///  DKObjectCreationTool.h
///  DrawKit
///
///  Created by graham on 09/06/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKDrawingTool.h"


@class DKStyle;



@interface DKObjectCreationTool : DKDrawingTool
{
	id		m_prototypeObject;
	id		m_protoObject;
}

+ (void)				registerDrawingToolForObject:(id <NSCopying>) shape withName:(NSString*) name;
+ (void)				setStyleForCreatedObjects:(DKStyle*) aStyle;
+ (DKStyle*)			styleForCreatedObjects;

- (id)					initWithPrototypeObject:(id <NSObject>) aPrototype;

- (void)				setPrototype:(id <NSObject>) aPrototype;
- (id)					prototype;
- (id)					objectFromPrototype;

- (NSImage*)			image;

@end


#define  kGCDefaultToolSwatchSize		(NSMakeSize( 64, 64 ))

extern NSString*		kGCDrawingToolWillMakeNewObjectNotification;


/*

This tool class is used to make all kinds of drawable objects. It works by copying a prototype object which will be some kind of drawable, adding
it to the target layer as a pending object, then proceeding as for an edit operation. When complete, if the object is valid it is committed to
the layer as a permanent item.

The prototype object can have all of its parameters set up in advance as required, including an attached style.

You can also set up a style to be applied to all new objects initially as an independent parameter.



*/
