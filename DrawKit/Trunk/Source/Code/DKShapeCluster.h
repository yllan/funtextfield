///**********************************************************************************************************************************
///  DKShapeCluster.h
///  DrawKit
///
///  Created by graham on 10/08/2007.
///  Released under the Creative Commons license 2007 Apptree.net.
///
/// 
///  This work is licensed under the Creative Commons Attribution-ShareAlike 2.5 License.
///  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/2.5/ or send a letter to
///  Creative Commons, 543 Howard Street, 5th Floor, San Francisco, California, 94105, USA.
///
///**********************************************************************************************************************************

#import "DKShapeGroup.h"


@interface DKShapeCluster : DKShapeGroup
{
	DKDrawableShape*		m_masterObjRef;
}


+ (DKShapeCluster*)		clusterWithObjects:(NSArray*) objects masterObject:(DKDrawableShape*) master;

- (void)				setMasterObject:(DKDrawableShape*) master;
- (DKDrawableShape*)	masterObject;


@end

/*

A CLUSTER is a specialised form of group. The idea is to allow a set of shapes to be associated with a main "master" object
around which the others are subordinated. Selecting the cluster selects the main object, but the subordinate objects
will be sized to match as needed.

One use for this is to allow automatic dimensioning of objects to work while the shape itself is edited - the shape itself is
the master and the dimensions are subordinate objects within the cluster. As the shape's size and angle change, the dimensions
adjust to match.

The main differences from a group are that when selected the main object acts as a proxy for the cluster as a whole, and the
cluster size and angle are controlled by the user's hits on the main object. Clusters need to be programatically created
since the master object must be nominated when creating the cluster.

*/
