///**********************************************************************************************************************************
///  DKColourQuantizer.h
///  DrawKit
///
///  Created by graham on 25/06/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>


// generic interface and simple quantizer which performs uniform quantization. Results with this quantizer are generally only
// barely acceptable - colours may be mapped to something grossly different from the original since this does not take any notice of
// the pixels actually used in the image, only the basic size of the RGB colour space it is given.

@interface DKColourQuantizer : NSObject
{
	unsigned		m_maxColours;
	unsigned		m_nBits;
	NSSize			m_imageSize;
	NSMutableArray*	m_cTable;
}

- (id)				initWithBitmapImageRep:(NSBitmapImageRep*) rep maxColours:(unsigned) maxColours colourBits:(unsigned) nBits;
- (unsigned)		indexForRGB:(unsigned[]) rgb;
- (NSColor*)		colourForIndex:(unsigned int) index;
- (NSArray*)		colourTable;
- (int)				numberOfColours;

- (void)			analyse:(NSBitmapImageRep*) rep;

@end



#pragma mark -


// octree quantizer which does a much better job
// this code is mostly a port of CQuantizer (c)  1996-1997 Jeff Prosise

typedef struct _NODE
{
    BOOL			bIsLeaf;               // YES if node has no children
    unsigned		nPixelCount;           // Number of pixels represented by this leaf
    unsigned		nRedSum;               // Sum of red components
    unsigned		nGreenSum;             // Sum of green components
    unsigned		nBlueSum;              // Sum of blue components
    unsigned		nAlphaSum;             // Sum of alpha components
    struct _NODE*	pChild[8];				// Pointers to child nodes
    struct _NODE*	pNext;					// Pointer to next reducible node
	int				indexValue;				// for looking up RGB->index
}
NODE;

typedef struct _rgb_triple
{
	float r;
	float g;
	float b;
}
rgb_triple;


@interface DKOctreeQuantizer : DKColourQuantizer
{
    NODE*		m_pTree;
    unsigned	m_nLeafCount;
    NODE*		m_pReducibleNodes[9];
    unsigned	m_nOutputMaxColors;
}


- (void)		addNode:(NODE**) ppNode colour:(unsigned[]) rgb level:(unsigned) level leafCount:(unsigned*) leafCount reducibleNodes:(NODE**) redNodes;
- (NODE*)		createNodeAtLevel:(unsigned) level leafCount:(unsigned*) leafCount reducibleNodes:(NODE**) redNodes;
- (void)		reduceTreeLeafCount:(unsigned*) leafCount reducibleNodes:(NODE**) redNodes;
- (void)		deleteTree:(NODE**) ppNode;
- (void)		paletteColour:(NODE*) pTree index:(unsigned*) pIndex colour:(rgb_triple[]) rgb;
- (void)		lookUpNode:(NODE*) pTree level:(unsigned) level colour:(unsigned[]) rgb index:(int*) index;

@end

