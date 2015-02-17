//
//  GeofenceManager.h
//  WhereAmI
//
//  Created by asamii on 2/13/15.
//  Copyright (c) 2015 adobe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "SpyRegion.h"

@interface GeofenceManager : NSObject<CLLocationManagerDelegate>
{
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableSet* spyRegions;

- (instancetype) init;

// Enable and disable geofences without modifying the spyRegion member
- (void) disableGeofences;
- (void) enableGeofences;

// Create a new geofence
- (void) addGeofence:(SpyRegion*)region;
- (void) removeGeofence:(SpyRegion*)region;
- (void) removeGeofenceAtCoordinate:(CLLocationCoordinate2D)coordinate;

// Save state
- (NSMutableSet*) loadSpyRegions;
- (void) saveSpyRegions;

@end