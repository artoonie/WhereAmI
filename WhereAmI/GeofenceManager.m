//
//  GeofenceManager.m
//  WhereAmI
//
//  Created by asamii on 2/13/15.
//  Copyright (c) 2015 adobe. All rights reserved.
//

#import "config.h"
#import "GeofenceManager.h"
#import "SlackInterface.h"
#import "spyRegion.h"

NSString* keySpyList = @"WHEREAMI_COORDINATES";

@implementation GeofenceManager

- (instancetype) init
{
    if (self = [super init])
    {
        assert([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]);

        // Initialize properties
        self.locationManager = [CLLocationManager new];
        self.spyRegions = [self loadSpyRegions];

        // Request authorization to register regions
        [self requestAuthorization];

        // Configure Location Manager
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];

        // Enable these geofences
        [self enableGeofences];
    }
    return self;
}

#pragma mark Reading, writing, and modifying geofences

- (void) enableGeofences
{
    // Always clear first to prevent ghosts if someone repeatedly calls this function
    [self disableGeofences];

    // Create circular regions and monitor them
    for(SpyRegion* spyRegion in self.spyRegions)
    {
        [self.locationManager startMonitoringForRegion:[spyRegion getSurroundingRegion]];
    }
}

- (void) disableGeofences
{
    for (CLRegion *region in self.locationManager.monitoredRegions)
    {
        [self.locationManager stopMonitoringForRegion:region];
    }
}

- (void) addGeofence:(SpyRegion *)region
{
    [self.spyRegions addObject:region];
    [self saveSpyRegions];
}

- (void) removeGeofence:(SpyRegion*)region
{
    [self.spyRegions removeObject:region];
    [self saveSpyRegions];
}

- (void) removeGeofenceAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    SpyRegion* region = [self getSpyRegionAtCoordinate:coordinate];
    assert(region != nil);
    [self removeGeofence:region];
}

- (void)saveSpyRegions
{
    NSData* data = [NSKeyedArchiver archivedDataWithRootObject:self.spyRegions];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:keySpyList];
}

- (NSMutableSet*) loadSpyRegions
{
    NSData* data = [[NSUserDefaults standardUserDefaults] objectForKey:keySpyList];
    NSMutableSet* spyRegions = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    if([spyRegions count] == 0)
        return [WhereAmIConfig getSpyRegions];
    else
        return spyRegions;
}


#pragma mark Convenience functions

- (SpyRegion*) getSpyRegionAtCoordinate:(CLLocationCoordinate2D) coordinate;
{
    for(SpyRegion* spyRegion in self.spyRegions)
    {
        if([[spyRegion getSurroundingRegion] containsCoordinate:coordinate])
        {
            return spyRegion;
        }
    }

    return nil;
}

- (SpyRegion*) getSpyRegionInRegion:(CLCircularRegion*) region
{
    for(SpyRegion* spyRegion in self.spyRegions)
    {
        if([region containsCoordinate:spyRegion.location.coordinate])
        {
            return spyRegion;
        }
    }

    return nil;
}

- (void)requestAuthorization
{
    // Request permissions
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    switch(authorizationStatus)
    {
        case kCLAuthorizationStatusNotDetermined:
            if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
            {
                NSLog(@"Requesting authorization...");
                [self.locationManager requestAlwaysAuthorization]; //or requestWhenInUseAuthorization
            }
            break;

        case kCLAuthorizationStatusDenied:
            NSLog(@"User has denied authorization");
            break;

        case kCLAuthorizationStatusAuthorizedAlways:
            NSLog(@"Great! We have the necessary permissions.");
            break;

        default:
            NSLog(@"Some other auth status...(%d)", authorizationStatus);
            break;
    }
}

#pragma mark Location Manager Delegates

- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state
              forRegion:(CLRegion *)region
{
    NSLog(@"Did determine state");
}


- (void)locationManager:(CLLocationManager *)manager
	 didUpdateLocations:(NSArray *)locations
{
    NSLog(@"Did update locations");
}

- (void)locationManager:(CLLocationManager *)manager
	monitoringDidFailForRegion:(CLRegion *)region
	withError:(NSError *)error
{
    NSLog(@"Did fail to start monitoring region: %@", [error description]);
}

- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region
{
    CLCircularRegion* circularRegion = (CLCircularRegion*)region;
    SpyRegion* spyRegion = [self getSpyRegionInRegion:circularRegion];
    assert(spyRegion != nil);

    NSString *message = [NSString stringWithFormat:@"%@%@.",
                         @"Armin is now working from ",
                         spyRegion.name];

    // Do not post about home offices or other private info unless it's between
    // 5am and 11am on a weekday
    if(spyRegion.isPrivate)
    {
        NSDate *date = [NSDate date];
        NSDateComponents *components = [[NSCalendar currentCalendar]
                                        components:NSCalendarUnitHour
                                          fromDate:date];

        if([[NSCalendar currentCalendar] isDateInWeekend:date])
        {
            NSLog(@"It's the weekend - not posting location.");
            return;
        }
        else if([components hour] < 5 || [components hour] > 11)
        {
            NSLog(@"It's not the morning - not posting location.");
            return;
        }
    }
    [SlackInterface postMessageToSlack:message];
    return;
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    NSLog(@"Did exit region");
}

@end
