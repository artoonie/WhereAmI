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

@implementation GeofenceManager

- (instancetype)init
{
    if (self = [super init])
    {
        assert([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]);

        // Initialize properties
        self.locationManager = [CLLocationManager new];
        self.circularRegions = [NSMutableSet new];

        // Request authorization to register regions
        [self requestAuthorization];

        // Configure Location Manager
        [self.locationManager setDelegate:self];
        [self.locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];

        // Clear existing regions
        for (CLRegion *region in self.locationManager.monitoredRegions) {
            [self.locationManager stopMonitoringForRegion:region];
        }

        // Initialize locations
        NSMutableSet* spyRegions = [WhereAmIConfig getSpyRegions];

        for(SpyRegion* spyRegion in spyRegions)
        {
            CLCircularRegion *region = [[CLCircularRegion alloc]
                initWithCenter:[spyRegion.location coordinate]
                        radius:fmin(self.locationManager.maximumRegionMonitoringDistance, 150.)
                    identifier:[[NSUUID UUID] UUIDString]];
            [self.circularRegions addObject:region];
        }

        // Start Monitoring Region
        for(CLCircularRegion* region in self.circularRegions)
        {
            [self.locationManager startMonitoringForRegion:region];
        }
    }
    return self;
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
    NSMutableSet* spyRegions = [WhereAmIConfig getSpyRegions];
    CLCircularRegion* circularRegion = (CLCircularRegion*)region;
    for(SpyRegion* spyRegion in spyRegions)
    {
        if([circularRegion containsCoordinate:spyRegion.location.coordinate])
        {
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
    }

    NSLog(@"Yikes! We entered an unknown region.....somebody help us.");

    return;
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    NSLog(@"Did exit region");
}

@end
