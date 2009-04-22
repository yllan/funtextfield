///**********************************************************************************************************************************
///  GCObservableObject.h
///  DrawKit
///
///  Created by graham on 27/05/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import <Cocoa/Cocoa.h>


@interface GCObservableObject : NSObject
{
	NSMutableDictionary*	m_oldArrayValues;
}

+ (void)			registerActionName:(NSString*) na forKeyPath:(NSString*) kp objClass:(Class) cl;
+ (NSString*)		actionNameForKeyPath:(NSString*) kp objClass:(Class) cl;

+ (NSArray*)		observableKeyPaths;

- (BOOL)			setUpKVOForObserver:(id) object;
- (BOOL)			tearDownKVOForObserver:(id) object;

- (void)			setUpObservables:(NSArray*) keypaths forObserver:(id) object;
- (void)			tearDownObservables:(NSArray*) keypaths forObserver:(id) object;

- (void)			registerActionNames;
- (NSString*)		actionNameForKeyPath:(NSString*) keypath;
- (NSString*)		actionNameForKeyPath:(NSString*) keypath changeKind:(NSKeyValueChange) kind;

- (void)			setActionName:(NSString*) name forKeyPath:(NSString*) keypath;
- (NSArray*)		oldArrayValueForKeyPath:(NSString*) keypath;

@end


#define				kGCChangeKindStringMarkerTag		#kind#

// the observer relay is a simple object that can liaise between any undo manager instance and any class
// set up as an observer. It also implements the above protocol so that observees are easily able to hook up to it.

@interface GCObserverUndoRelay : NSObject
{
	NSUndoManager*		m_um;
}

- (void)				setUndoManager:(NSUndoManager*) um;
- (NSUndoManager*)		undoManager;
- (void)				changeKeyPath:(NSString*) keypath ofObject:(id) object toValue:(id) value;

@end

extern NSString*		kGCObserverRelayDidReceiveChange;
extern NSString*		kGCObservableKeyPath;

/*

This is used to permit setting up KVO in a simpler manner than comes as standard.

The idea is that each class simply publishes a list of the observable properties that an observer can observe. When the observer wants to
start observing all of these published properties, it calls setUpKVOForObserver: conversely, tearDownKVOForObserver: will stop the
observer watching all the published properties.

Subclasses can also override these methods to be more selective about which properties are observed, or to propagate the message to
additional observable objects they own.

This class also works around a bug or oversight in the KVO implementation (in 10.4 at least). When an array is changed, the old
value isn't sent to the observer. To allow this, we record the old value locally. An observer can then call us back to get this
old array if it needs to (for example, when building an Undo invocation).

The undo relay class provides a standard implementation for using KVO to implement Undo when using GCObservables. The relay needs
to be added as an observer to any observable and given an undo manager. Then it will relay undoable actions from the observed
objects to the undo manager and vice versa, implementing undo for all keypaths declared by the observee.

*/
