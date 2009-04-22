//
//  DKSelectionPDFView.h
//  DrawingArchitecture
//
//  Created by graham on 30/09/2006.
//  Copyright 2006 __MyCompanyName__. All rights reserved.
//

#import "DKDrawingView.h"



@interface DKSelectionPDFView : DKDrawingView
@end


@interface DKGridLayerPDFView : DKDrawingView
@end



@class DKObjectOwnerLayer, DKShapeGroup;


@interface DKObjectLayerPDFView : DKDrawingView
{
	DKObjectOwnerLayer* mLayerRef;
}

- (id)		initWithFrame:(NSRect) frame withLayer:(DKObjectOwnerLayer*) aLayer;

@end


@interface DKGroupPDFView : DKDrawingView
{
	DKShapeGroup*		mGroupRef;
}

- (id)		initWithFrame:(NSRect) frame withGroup:(DKShapeGroup*) aGroup;

@end

/* these objects are never used to make a visible view. Their only function is to allow parts of a drawing to be
 selectively written to a PDF. This is made by DKObjectDrawingLayer internally and is private to the DrawKit.
 
 */
