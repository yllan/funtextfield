///**********************************************************************************************************************************
///  GCESRIFile.h
///  GCDrawKit
///
///  Created by graham on 25/08/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>

@class GCDrawableObject;




typedef struct
{
	SInt32			recordNumber;		// big endian
	UInt32			contentlength;		// big endian, length expressed as # of 16-bit words
	SInt32			shapeType;			// little endian
}
ESRIRecordHeader, *ESRIRecordHeaderPtr;





@interface GCESRIFile : NSObject
{
	NSString*	_path;
	NSData*		_data;
	NSData*		_dbfData;
}

+ (NSArray*)		createDrawingObjectsFromESRIFile:(NSString*) filePath;

- (id)				initWithFile:(NSString*) filePath;
- (NSRect)			bounds;
- (BOOL)			checkHeader;
- (NSString*)		dBaseFilePath;
- (NSDictionary*)	metadataForRecord:(int) recordNumber;

- (NSArray*)		parse;
- (NSArray*)		parseUsingTransform:(NSAffineTransform*) tfm tolerance:(float) tol;
- (id)				makeObjectType:(int) shapeType forESRIRecord:(ESRIRecordHeaderPtr) er dataLength:(unsigned) len transform:(NSAffineTransform*) tfm tolerance:(float) tol;
- (NSBezierPath*)	bezierPathFromESRIPoint:(ESRIRecordHeaderPtr) er transform:(NSAffineTransform*) tfm size:(NSSize) size shape:(int) shape;
- (NSBezierPath*)	bezierPathFromESRIPolyline:(ESRIRecordHeaderPtr) er tolerance:(float) tol transform:(NSAffineTransform*) tfm;
- (NSBezierPath*)	bezierPathFromESRIPolygon:(ESRIRecordHeaderPtr) er tolerance:(float) tol transform:(NSAffineTransform*) tfm;
- (NSBezierPath*)	bezierPathFromESRIMultipoint:(ESRIRecordHeaderPtr) er transform:(NSAffineTransform*) tfm size:(NSSize) size shape:(int) shape;

- (void)			preprocessObject:(GCDrawableObject*) obj;

@end


// shapefile structures; a crappy format:

typedef struct
{
	SInt32			fileCode;			// 9994, big endian
	SInt32			unused[5];
	UInt32			fileLength;			// big endian, length expressed as # of 16-bit words, including header
	SInt32			version;			// little endian, = 1000
	UInt32			shapeType;			// all little endian from here on
	double			xMin;				// bbox
	double			yMin;
	double			xMax;
	double			yMax;
	double			zMin;
	double			zMax;
	double			mMin;
	double			mMax;
}
ESRIFileHeader, *ESRIFileHeaderPtr;


typedef struct
{
	double			x;					// little endian, really a double fp
	double			y;					// little endian
}
ESRIPoint, *ESRIPointPtr;

typedef struct
{
	double			bbox[4];			// little endian, xmin, ymin, xmax, ymax
	SInt32			pointCount;			// le
	ESRIPoint		points[];			// array of <pointCount> points
}
ESRIMultiPoint, *ESRIMultiPointPtr;

typedef struct
{
	double			bbox[4];			// bounding box
	SInt32			partCount;			// count of parts
	SInt32			pointCount;			// count of total points
	SInt32			parts[];			// array of <partCount> parts, holds starting index of each polyline
	// the list of points follows this directly, indexed by the parts array
}
ESRIPolyline, *ESRIPolylinePtr;

typedef struct
{
	double			bbox[4];			// bounding box
	SInt32			partCount;			// count of parts
	SInt32			pointCount;			// count of total points
	SInt32			parts[];			// array of <partCount> parts, holds starting index of each polygon
}
ESRIPolygon, *ESRIPolygonPtr;

typedef struct
{
	double			x;					
	double			y;
	double			m;					// "measure"
}
ESRIMPoint, *ESRIMPointPtr;


typedef struct
{
	double			bbox[4];			// bounding box
	SInt32			pointCount;			// count of points
	ESRIPoint		points[];			// array of points, <pointCount> long
	
	// followed by mMin, mMax (2 x double) then double[numPoints] for the m array
}
ESRIMultiPointM, *ESRIMultiPointMPtr;

// shape constants for making paths of single points

enum
{
	kCreateRectanglePath = 0,
	kCreateOvalPath		= 1
};

typedef enum
{
	kESRINullShape		= 0,
	kESRIPoint			= 1,
	kESRIPolyline		= 3,
	kESRIPolygon		= 5,
	kESRIMultiPoint		= 8,
	kESRIPointZ			= 11,
	kESRIPolylineZ		= 13,
	kESRIPolygonZ		= 15,
	kESRIMultiPointZ	= 18,
	kESRIPointM			= 21,
	kESRIPolylineM		= 23,
	kESRIPolygonM		= 25,
	kESRIMultiPointM	= 28,
	kESRIMultiPatch		= 31
}
ESRIShapeType;

// dbase file stuctures; another crappy format:

typedef struct
{
	char		fieldName[11];				// null terminated string
	char		fieldType;					// data type code
	UInt32		fieldDataAddress;			// unreliable
	UInt8		fieldLength;				// 
	UInt8		decimalCount;				// sometimes combined with field above to give 16-bit length for non-numeric fields
	UInt16		reservedMultiUser;			
	UInt8		workAreaID;					// usually = 1
	UInt16		reservedMulti2;
	UInt8		setFieldsFlag;				
	UInt8		reserved[6];
	UInt8		indexFieldFlag;				// 0 or 1
}
dBaseFieldDescriptor, *dBaseFieldDescriptorPtr;

typedef struct
{
	UInt8					version;					// largely depends on specific software that wrote the file
	UInt8					dateUpdated[3];				// le; YYMMDD, year + 1900
	UInt32					recordCount;				// le
	UInt16					headerLength;				// le
	UInt16					recordLength;				// le
	UInt8					reserved[2];
	UInt8					incompleteTransactFlag;		// 0 or 1
	UInt8					encryptionFlag;				// 0 or 1
	UInt32					freeRecordThread;			// unused
	UInt32					reservedMultiUser[2];		// unused
	UInt8					mdxFlag;					// le
	UInt8					languageDriver;				// a motley collection of random languages/code pages
	UInt8					reserved2[2];				// unused
	dBaseFieldDescriptor	fd[32];						// variable length, definitely NOT 32 - used for debugging display only
}
dBaseHeader, *dBaseHeaderPtr;

// note: never use sizeof(dBaseHeader) - use the stored headerLength value

enum
{
	dBaseHeaderOffsetToFieldDescriptor		= 32
};

typedef struct
{
	UInt8		recordDeleteFlag;
	char		data[];
}
dBaseRecord, *dBaseRecordPtr;

enum
{
	dBaseFieldDescriptorTerminator	= 0x0D,
	dBaseEndOfFileTerminator		= 0x1A,
	dBaseValidRecordMarker			= 0x20,
	dBaseDeletedRecordMarker		= 0x2A
};

// data type of fields:

enum
{
	dBaseDataTypeCharacter			= 'C',		// length <254
	dBaseDataTypeNumber				= 'N',		// <18
	dBaseDataTypeLogical			= 'L',		// 1
	dBaseDataTypeDate				= 'D',		// 8, YYYYMMDD
	dBaseDataTypeMemo				= 'M',		// 10
	dBaseDataTypeFloat				= 'F',		// 20
	dBaseDataTypeInteger			= 'I',		// 4 byte little endian
	dBaseDataTypeVarifield			= 'V',		// 2-10
	dBaseDataTypeTimestamp			= '@',		// 8
	dBaseDataTypeDouble				= 'O'		// 8
};

/*

This class allows an ESRI/.shp file to be parsed and converted to a set of drawables.

ESRI files are a widely supported GIS data format, also called "shapefiles".




*/