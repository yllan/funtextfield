#import "GCCheckboxCell.h"

#import <GCDrawKit/LogEvent.h>


@implementation GCCheckboxCell

#pragma mark -
#pragma mark As an NSCell
- (BOOL)	trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)untilMouseUp
{
#pragma unused (theEvent, untilMouseUp)
//	LogEvent_(kReactiveEvent, @"tracking in checkbox starting");
	
	[self setHighlighted:YES];
	[controlView setNeedsDisplayInRect:cellFrame];

	// keep control until mouse up
	
	NSEvent*	evt;
	BOOL		loop = YES;
	BOOL		wasIn, isIn;
	int			mask = NSLeftMouseUpMask | NSLeftMouseDraggedMask;
	
	wasIn = YES;
	
	while( loop )
	{
		evt = [[controlView window] nextEventMatchingMask:mask];
	
		switch([evt type])
		{
			case NSLeftMouseDragged:
			{
				NSPoint p = [controlView convertPoint:[evt locationInWindow] fromView:nil];
				isIn = NSPointInRect( p, cellFrame );
				
				if ( isIn != wasIn )
				{
					[self setHighlighted:isIn];
					[controlView setNeedsDisplayInRect:cellFrame];
					wasIn = isIn;
				}
			}
			break;
			
			case NSLeftMouseUp:
				loop = NO;
				break;
		
			default:
				break;
		}
	
	}

	[self setHighlighted:NO];
	
	// if the mouse was in the cell when it was released, flip the checkbox state
	
	if ( wasIn )
		[self setIntValue:![self intValue]];
		
	[controlView setNeedsDisplayInRect:cellFrame];

//	LogEvent_(kReactiveEvent, @"tracking in checkbox ended");
	
	return wasIn;
}


- (char)	charValue
{
	return (char)[self intValue];
}

@end
