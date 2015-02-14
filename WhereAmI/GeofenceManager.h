//
//  GeofenceManager.h
//  WhereAmI
//
//  Created by asamii on 2/13/15.
//  Copyright (c) 2015 adobe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GeofenceManager : NSObject<CLLocationManagerDelegate>
{
}

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableSet *circularRegions;

- (void)clearAllGeofences;
- (void)recreateGeofences;

@end