///**********************************************************************************************************************************
///  DKRasterizer.h
///  DrawKit
///
///  Created by graham on 23/11/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKRasterizerProtocol.h"
#import "GCObservableObject.h"


@class DKRastGroup;


@interface DKRasterizer : GCObservableObject <DKRasterizer, NSCoding, NSCopying>
{
	DKRastGroup*	mContainerRef;
	NSString*		m_name;
	BOOL			m_enabled;
}

+ (DKRasterizer*)	rasterizerFromPasteboard:(NSPasteboard*) pb;

- (DKRastGroup*)	container;
- (void)			setContainer:(DKRastGroup*) container;

- (void)			setName:(NSString*) name;
- (NSString*)		name;
- (NSString*)		label;

- (BOOL)			isValid;
- (NSString*)		styleScript;

- (void)			setEnabled:(BOOL) enable;
- (BOOL)			enabled;

- (NSBezierPath*)	renderingPathForObject:(id) object;

- (void)			copyToPasteboard:(NSPasteboard*) pb;

@end


extern NSString*	kDKRasterizerPasteboardType;



/*
 DKRasterizer is an abstract base class that implements the DKRasterizer protocol. Concrete subclasses
 include DKStroke, DKFill, DKHatching, DKFillPattern, DKGradient, etc.
 
 A renderer is given an object and renders it according to its behaviour to the current context. It can
 do whatever it wants. Normally it will act upon the object's path so as a convenience the renderPath method
 is called by default. Subclasses can override at the object or the path level, as they wish.
 
 Renderers are obliged to accurately return the extra space they need to perform their rendering, over and
 above the bounds of the path. For example a standard stroke is aligned on the path, so the extra space should
 be half of the stroke width in both width and height. This additional space is used to compute the correct bounds
 of a shape when a set of rendering operations is applied to it.

*/


@interface NSObject (DKRendererDelegate)

- (NSBezierPath*)	renderer:(DKRasterizer*) aRenderer willRenderPath:(NSBezierPath*) aPath;

@end


/*
 Renderers can now have a delegate attached which is able to modify behaviours such as changing the path rendered, etc.

*/
