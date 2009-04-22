///**********************************************************************************************************************************
///  DKPrintDrawingView.h
///  DrawKit
///
///  Created by graham on 16/10/2006.
///  Released under the Creative Commons license 2006 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKDrawingView.h"


@interface DKPrintDrawingView : DKDrawingView
{
	NSPrintInfo*	m_printInfo;
}

- (void)			setPrintInfo:(NSPrintInfo*) ip;
- (NSPrintInfo*)	printInfo;

@end
