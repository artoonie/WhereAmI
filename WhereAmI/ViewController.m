//
//  ViewController.m
//  WhereAmI
//
//  Created by asamii on 2/12/15.
//  Copyright (c) 2015 adobe. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate> {
    BOOL _didStartMonitoringRegion;
    CLLocation* sanJose;
    CLCircularRegion *sanJoseRegion;
    CLLocation* sanFrancisco;
    CLLocation* berkeley;
}

@property (strong, nonatomic) CLLocationManager *locationManager;

@end

@implementation ViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    assert([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]);

    // Initialize Location Manager
    self.locationManager = [CLLocationManager new];

    // Request permissions
    if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)])
    {
        [self.locationManager requestAlwaysAuthorization]; //or requestWhenInUseAuthorization
    }


    // Configure Location Manager
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];

    // Clear existing regions
    NSLog(@"We are monitoring %d locations", (int)self.locationManager.monitoredRegions.count);
    for (CLRegion *region in self.locationManager.monitoredRegions) {
        [self.locationManager stopMonitoringForRegion:region];
    }
    NSLog(@"We are monitoring %d locations", (int)self.locationManager.monitoredRegions.count);

    // Initialize regions
    sanJose = [[CLLocation alloc] initWithLatitude:37.3294 longitude:-121.8951];
    sanFrancisco = [[CLLocation alloc] initWithLatitude:37.3294 longitude:-121.8951];
    berkeley = [[CLLocation alloc] initWithLatitude:37.3294 longitude:-121.8951];

    // Initialize Region to Monitor
    sanJoseRegion = [[CLCircularRegion alloc]
        initWithCenter:[sanJose coordinate]
                radius:fmin(self.locationManager.maximumRegionMonitoringDistance, 150.)
            identifier:[[NSUUID UUID] UUIDString]];

    // Start Monitoring Region
    [self.locationManager startMonitoringForRegion:sanJoseRegion];

    // Handle a doubletap gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];

    NSLog(@"We are monitoring %d locations", (int)self.locationManager.monitoredRegions.count);
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
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

    [self.locationManager requestStateForRegion:sanJoseRegion];
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
    NSLog(@"Did enter region");
}

- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region
{
    NSLog(@"Did exit region");
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
