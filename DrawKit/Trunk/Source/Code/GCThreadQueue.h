//
//  GCThreadQueue.h
//  GCDrawKit
//
//  Created by graham on 03/05/2008.
//  Copyright 2008 Apptree.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface GCThreadQueue : NSObject
{
	NSMutableArray*		mQueue;
	NSConditionLock*	mLock;
}


-(void)		enqueue:(id) object;
-(id)		dequeue;						// Blocks until there is an object to return
-(id)		tryDequeue;						// Returns NULL if the queue is empty


@end


