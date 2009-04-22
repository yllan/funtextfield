///**********************************************************************************************************************************
///  GCOneShotEffectTimer.h
///  DrawKit
///
///  Created by graham on 24/04/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>


@interface GCOneShotEffectTimer : NSObject
{
	NSTimer*			mTimer;
	NSTimeInterval		mStart;
	NSTimeInterval		mTotal;
	id					mDelegate;
}

+ (id)			oneShotWithStandardFadeTimeForDelegate:(id) del;
+ (id)			oneShotWithTime:(NSTimeInterval) t forDelegate:(id) del;

@end



@interface NSObject (OneShotDelegate)

- (void)		oneShotWillBegin;
- (void)		oneShotHasReached:(float) relpos;
- (void)		oneShotComplete;

@end


#define			kGCStandardFadeTime		0.15


/* This class wraps up a very simple piece of timer functionality. It sets up a timer that will call the
	delegate frequently with a value from 0..1. Once 1 is reached, it stops. The total time interval to
	complete the action is set by the caller.
	
	This is useful for one-shot type animations such as fading out a window or similar.
	
	The timer starts as soon as it is created.
	
	The timer attempts to maintain a 60fps rate, and is capped at this value. On slower systems, it will drop
	frames as needed.
	
	The oneshot effectively retains and releases itself, so there is nothing to do - just call the class
	method. You can generally ignore the return value. The oneshot retains the delegate, and releases it when
	it releases itself at the end of the effect, so the caller can happily release the delegate if it wishes
	after setting up the timer without worrying about what happens during the effect. It is also an error to
	release self (the delegate) when the completion method is called. Short version: it just works - don't
	try and retain/release anything in any different way from usual.
	
*/
