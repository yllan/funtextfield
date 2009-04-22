///**********************************************************************************************************************************
///  GCESRIFile.m
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

#import "GCESRIFile.h"
#import "GCDrawKit/GCDrawablePath.h"
#import "GCDrawKit/GCDrawableShape.h"


@implementation GCESRIFile


+ (NSArray*)	createDrawingObjectsFromESRIFile:(NSString*) filePath
{
	GCESRIFile* shp = [[GCESRIFile alloc] initWithFile:filePath];
	NSArray*	result = [shp parse];
	
	[shp release];
	
	return result;
}



- (id)			initWithFile:(NSString*) filePath
{
	if ((self = [super init]) != nil )
	{
		_path = [filePath retain];
		_data = [[NSData dataWithContentsOfMappedFile:filePath] retain];
		_dbfData = [[NSData dataWithContentsOfMappedFile:[self dBaseFilePath]] retain];
	}
	
	return self;
}


- (void)		dealloc
{
	[_path release];
	[_data release];
	[_dbfData release];
	[super dealloc];
}


- (NSRect)		bounds
{
	// return the overall bounds of the file by reading the header
	
	ESRIFileHeaderPtr header = (ESRIFileHeaderPtr)[_data bytes];
	
	NSRect		bbox;
	
	float x1, y1, x2, y2;
	
	x1 = NSSwapLittleDoubleToHost(*(NSSwappedDouble*)&header->xMin);
	y1 = NSSwapLittleDoubleToHost(*(NSSwappedDouble*)&header->yMin);
	x2 = NSSwapLittleDoubleToHost(*(NSSwappedDouble*)&header->xMax);
	y2 = NSSwapLittleDoubleToHost(*(NSSwappedDouble*)&header->yMax);
	
	bbox.origin.x = MIN( x1, x2 );
	bbox.origin.y = MIN( y1, y2 );
	bbox.size.width = ABS( x2 - x1 );
	bbox.size.height = ABS( y2 - y1 );
	
	return bbox;
}


- (BOOL)		checkHeader
{
	// sanity checks the header - returns YES if it looks OK, NO otherwise
	BOOL ok = NO;
	ESRIFileHeaderPtr header = (ESRIFileHeaderPtr)[_data bytes];
	
	int fileCode = CFSwapInt32BigToHost(header->fileCode);
	
	if ( fileCode == 9994 )
	{
		int version = CFSwapInt32LittleToHost(header->version);
		
		if ( version == 1000 )
		{
			// check file length against actual length of the data
			
			unsigned len = CFSwapInt32BigToHost(header->fileLength) * 2;	// length stored in words, x2 for bytes
	
			if( len == [_data length])
				ok = YES;
		}
	}
	
	return ok;
}

- (NSString*)	dBaseFilePath
{
	NSString* str = [_path stringByDeletingPathExtension];
	return [str stringByAppendingPathExtension:@"dbf"];
}


- (NSDictionary*)	metadataForRecord:(int) recordNumber
{
	// reads metadata for record #<recordNumber> from the associated dbase file, converts it to a dictionary and returns it. The dictionary can
	// then be attached to the object as metadata
	
	dBaseHeaderPtr			dh = (dBaseHeaderPtr)[_dbfData bytes];
	unsigned				recCount, recLength, headerLength, fieldCount, i;
	unsigned char			term;
	NSMutableDictionary*	meta = nil;
	
	recLength = CFSwapInt16LittleToHost(dh->recordLength);
	
	// sanity check record length
	
	if ( recLength < 1 || recLength > 32768 )
		return nil;
	
	headerLength = CFSwapInt16LittleToHost(dh->headerLength);
	recCount = CFSwapInt32LittleToHost(dh->recordCount);
	
	// sanity check file length
	
	if( headerLength + ( recCount * recLength ) != [_dbfData length])
		return nil;
	
	// point to the record
	
	dBaseRecordPtr	rec = (dBaseRecordPtr)([_dbfData bytes] + headerLength + (recLength * recordNumber));
	
	// to interpret <rec> properly we need the field descriptor array which gives us names and types for each
	// field in the record and most importantly the field's length
	
	// count the number of fields per record
	
	i = 0;
	do
	{
		term = dh->fd[i++].fieldName[0];
	}
	while( term != dBaseFieldDescriptorTerminator );
	
	fieldCount = i - 1;
	
	NSLog(@"record %d, field count = %d", recordNumber, fieldCount);
	
	// if there is at least one record, with at least one field, we have something we can use:
	
	if ( recCount > 0 && fieldCount > 0 && rec->recordDeleteFlag == dBaseValidRecordMarker )
	{
		meta = [NSMutableDictionary dictionaryWithCapacity:fieldCount];
		
		NSString*		key;
		NSString*		asciiVal;
		id				value;
		char			type;
		unsigned		len;
		const char*		dptr = (const char*)(rec->data);	// points to each data item in the record as we iterate
	
		// iterate over the field descriptor to establish the keys for the metadata, and extract the actual values as we go
		
		for( i = 0; i < fieldCount; ++i )
		{
			key = [NSString stringWithCString:dh->fd[i].fieldName encoding:NSASCIIStringEncoding];
			type = dh->fd[i].fieldType;
			len = dh->fd[i].fieldLength;	// only 8 bits so don't care about endianness
			
			asciiVal = [NSString stringWithCString:dptr length:len];
			
			switch( type )
			{
				case dBaseDataTypeFloat:
				case dBaseDataTypeNumber:
					value = [NSNumber numberWithFloat:[asciiVal floatValue]];
					break;
				
				case dBaseDataTypeCharacter:
					value = asciiVal;
					break;
					
				case dBaseDataTypeLogical:
				{
					NSCharacterSet* cs = [NSCharacterSet characterSetWithCharactersInString:@"TtYy1"];
					unichar			v = [asciiVal characterAtIndex:0];
					
					value = [NSNumber numberWithBool:[cs characterIsMember:v]? YES : NO];
				}
				break;
					
				case dBaseDataTypeDate:
					value = [NSCalendarDate dateWithString:asciiVal calendarFormat:@"%Y%m%d"];
					break;
					
				default:
					value = nil;
					break;
			}
			
			NSLog(@"\t field #%d, key = %@, value = %@", i, key, value);
			
			if( value )
				[meta setObject:value forKey:key];
			
			// point to next data item in the record
				
			dptr += len;
		}
	}

	return meta;
}


- (NSArray*)	parse
{
	NSAffineTransform* tfm = [NSAffineTransform transform];
	[tfm scaleXBy:10 yBy:-10];
	
	return [self parseUsingTransform:tfm tolerance:1.0];
}

- (NSArray*)	parseUsingTransform:(NSAffineTransform*) tfm tolerance:(float) tol
{
	// reads the file and returns a list of objects
	
	NSRect				bbox;
	NSMutableArray*		objects = nil;
	unsigned char*		p;
	unsigned char*		eof;
	BOOL				done = NO;
	int					shapeType, recNum;
	ESRIRecordHeaderPtr	recP;
	unsigned			recLength;
	id					obj;

	if([self checkHeader])
	{
		bbox = [self bounds];
		
		bbox.origin = [tfm transformPoint:bbox.origin];
		bbox.size = [tfm transformSize:bbox.size];
		
		NSLog(@"bbox = %@", NSStringFromRect( bbox ));
		
		objects = [NSMutableArray array];
		
		p = (unsigned char*)[_data bytes];
		eof = p + [_data length];
		p += sizeof( ESRIFileHeader );
	
		while( !done )
		{
			// parse the record header
			
			recP = (ESRIRecordHeaderPtr) p;
			recNum = CFSwapInt32BigToHost(recP->recordNumber);
			recLength = CFSwapInt32BigToHost(recP->contentlength) * 2;
			shapeType = CFSwapInt32LittleToHost(recP->shapeType);
			
			NSLog( @"record #%d, length=%d, type=%d", recNum, recLength, shapeType );
			
			// make a suitable object for this record's data
			
			obj = [self makeObjectType:shapeType forESRIRecord:recP dataLength:recLength transform:tfm tolerance:tol];
			
			if ( obj )
			{
				// see if there's any metadata in the associated dbase file and attach it
				
				NSDictionary* meta = [self metadataForRecord:recNum - 1];
				
				if ( meta )
					[obj setUserInfo:meta];
				
				// give subclasses a chance to prettify the object or do anything, including modifying its appearance according
				// to the metadata:
				
				[self preprocessObject:obj];
				
				// add to the list
				
				[objects addObject:obj];
			}
				
			p += ( 8 + recLength );
			done = (p >= eof);
		}
	}
	
	return objects;
}


- (id)		makeObjectType:(int) shapeType forESRIRecord:(ESRIRecordHeaderPtr) er dataLength:(unsigned) len transform:(NSAffineTransform*) tfm tolerance:(float) tol
{
	if ( len == 0 )
		return nil;
		
	id				obj = nil;
	NSBezierPath*	path;
		
	switch( shapeType )
	{
		default:
		case kESRINullShape:
			break;
			
		case kESRIPoint:
			path = [self bezierPathFromESRIPoint:er transform:tfm size:NSMakeSize( 6, 6 ) shape:kCreateOvalPath];
			obj = [GCDrawablePath drawablePathWithPath:path];
			break;
			
		case kESRIPolyline:
			path = [self bezierPathFromESRIPolyline:er tolerance:tol transform:tfm];
			obj = [GCDrawablePath drawablePathWithPath:path];
			break;
			
		case kESRIPolygon:
			path = [self bezierPathFromESRIPolygon:er tolerance:tol transform:tfm];
			if ( path && ![path isEmpty])
				obj = [GCDrawableShape drawableShapeWithPath:path];
			break;
			
		case kESRIMultiPoint:
			path = [self bezierPathFromESRIMultipoint:er transform:tfm size:NSMakeSize( 6,6 ) shape:kCreateOvalPath];
			if ( path && ![path isEmpty])
				obj = [GCDrawableShape drawableShapeWithPath:path];
	}
	
	return obj;
}


- (NSBezierPath*)	bezierPathFromESRIPoint:(ESRIRecordHeaderPtr) er transform:(NSAffineTransform*) tfm size:(NSSize) size shape:(int) shape
{
	ESRIPointPtr	pp = (ESRIPointPtr)((unsigned)er + sizeof(ESRIRecordHeader));
	NSPoint			p;
	
	p.x = NSSwapLittleDoubleToHost(*(NSSwappedDouble*)&pp->x);
	p.y = NSSwapLittleDoubleToHost(*(NSSwappedDouble*)&pp->y);
	
	p = [tfm transformPoint:p];
	
	NSRect	pr;
	
	pr.size = size;
	pr.origin.x = p.x - size.width / 2;
	pr.origin.y = p.y - size.height / 2;
	
	NSBezierPath* path;
	
	switch( shape )
	{
		default:
		case kCreateRectanglePath:
			path = [NSBezierPath bezierPathWithRect:pr];
			break;
			
		case kCreateOvalPath:
			path = [NSBezierPath bezierPathWithOvalInRect:pr];
			break;
	}
	
	return path;
}


- (NSBezierPath*)	bezierPathFromESRIPolyline:(ESRIRecordHeaderPtr) er tolerance:(float) tol transform:(NSAffineTransform*) tfm
{
	ESRIPolylinePtr pp = (ESRIPolylinePtr)((unsigned)er + sizeof(ESRIRecordHeader));
	int				parts, i, j, k;
	ESRIPointPtr	pointList;
	NSBezierPath*	path = nil;
	NSPoint			p, lp;
	
	parts = CFSwapInt32LittleToHost(pp->partCount);
	lp = NSMakePoint( -10000, -10000 );
	if ( parts > 0 )
	{
		// compute location of the points list
		
		pointList = (ESRIPointPtr)((unsigned)pp + 40 + (4 * parts));
		
		path = [NSBezierPath bezierPath];
		
		// k is the total number of points
		
		k = CFSwapInt32LittleToHost( pp->pointCount );
		j = 0;
		
		for( i = 0; i < k; ++i )
		{
			// i counts through the points as a single list. whenever i is equal to a listed index in the
			// parts array, we start a new subpath. j tracks the parts index
			
			p.x = NSSwapLittleDoubleToHost(*(NSSwappedDouble*)&pointList[i].x);
			p.y = NSSwapLittleDoubleToHost(*(NSSwappedDouble*)&pointList[i].y);
			
			p = [tfm transformPoint:p];

			if ( i == pp->parts[j] )
			{
				[path moveToPoint:p];
				++j;
				lp = p;
			}
			else
			{
				float dist = hypotf( p.x - lp.x, p.y - lp.y );
				
				if ( dist > tol )
				{
					[path lineToPoint:p];
					lp = p;
				}
			}
		}
	}
	
	return path;
}


- (NSBezierPath*)	bezierPathFromESRIPolygon:(ESRIRecordHeaderPtr) er tolerance:(float) tol transform:(NSAffineTransform*) tfm
{
	ESRIPolygonPtr	pp = (ESRIPolygonPtr)((unsigned)er + sizeof(ESRIRecordHeader));
	int				parts, i, j, k;
	ESRIPointPtr	pointList;
	NSBezierPath*	path = nil;
	NSPoint			p, lp;
	
	parts = CFSwapInt32LittleToHost(pp->partCount);
	lp = NSMakePoint( -10000,-10000 );
	
	if ( parts > 0 )
	{
		// compute location of the points list
		
		pointList = (ESRIPointPtr)((unsigned)pp + 40 + (4 * parts));
		
		path = [NSBezierPath bezierPath];
		
		// k is the total number of points
		
		k = CFSwapInt32LittleToHost( pp->pointCount );
		j = 0;
		
		for( i = 0; i < k; ++i )
		{
			// i counts through the points as a single list. whenever i is equal to a listed index in the
			// parts array, we start a new subpath. j tracks the parts index
			
			p.x = NSSwapLittleDoubleToHost(*(NSSwappedDouble*)&pointList[i].x);
			p.y = NSSwapLittleDoubleToHost(*(NSSwappedDouble*)&pointList[i].y);
			
			p = [tfm transformPoint:p];
			
			if ( i == pp->parts[j] )
			{
				if ( i != 0 )
					[path closePath];
					
				[path moveToPoint:p];
				++j;
				
				lp = p;
			}
			else
			{
				// is the point's distance from the last point greater than tolerance? If so, include it
				
				float dist = hypotf( p.x - lp.x, p.y - lp.y );
				
				if ( dist > tol )
				{
					[path lineToPoint:p];
					lp = p;
				}
			}
		}
		
		[path closePath];
	}
	
	return path;
}


- (NSBezierPath*)	bezierPathFromESRIMultipoint:(ESRIRecordHeaderPtr) er transform:(NSAffineTransform*) tfm size:(NSSize) size shape:(int) shape
{
	ESRIMultiPointPtr	pp = (ESRIMultiPointPtr)((unsigned)er + sizeof(ESRIRecordHeader));
	int					pc, i;
	NSBezierPath*		path = nil;
	NSPoint				p;
	NSRect				pr;
			
	pr.size = size;
	pc = CFSwapInt32LittleToHost(pp->pointCount);
	
	if ( pc > 0 )
	{
		path = [NSBezierPath bezierPath];
		
		for( i = 0; i < pc; ++i )
		{
			p.x = NSSwapLittleDoubleToHost(*(NSSwappedDouble*)&pp->points[i].x);
			p.y = NSSwapLittleDoubleToHost(*(NSSwappedDouble*)&pp->points[i].y);
			
			p = [tfm transformPoint:p];

			pr.origin.x = p.x - size.width / 2;
			pr.origin.y = p.y - size.height / 2;
			
			NSBezierPath* temp;
			
			switch( shape )
			{
				default:
				case kCreateRectanglePath:
					temp = [NSBezierPath bezierPathWithRect:pr];
					break;
					
				case kCreateOvalPath:
					temp = [NSBezierPath bezierPathWithOvalInRect:pr];
					break;
			}
			
			[path appendBezierPath:temp];
		}
	}
	
	return path;
}


- (void)			preprocessObject:(GCDrawableObject*) obj
{
	// called after an object has been created from a record - you can override this to set the style or any other aspect of
	// the object
	
	
}



@end
