//
//  ViewController.m
//  WhereAmI
//
//  Created by asamii on 2/12/15.
//  Copyright (c) 2015 adobe. All rights reserved.
//

#import "config.h"
#import "GeofenceManager.h"
#import "ViewController.h"
#import <GoogleMaps/GoogleMaps.h>

NSString* PERSISTENT_PRIVATE_MODE_KEY = @"WHEREAMI_PRIVATEMODE";

@interface ViewController ()

@property (strong, nonatomic) GeofenceManager *geofenceManager;
@property bool isPrivateModeOn;

@end

@implementation ViewController

GMSMapView* mapView;

- (void) awakeFromNib {
    [super awakeFromNib];

    self.geofenceManager = [[GeofenceManager alloc] init];

    // Handle a doubletap gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];

    // Default value of boolForKey is false, which is what we want.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.isPrivateModeOn = [defaults boolForKey:PERSISTENT_PRIVATE_MODE_KEY];
    [self updatePrivateMode:self.isPrivateModeOn];
}


- (void)loadView {
    [GMSServices provideAPIKey:[WhereAmIConfig getGoogleMapsAPIKey]];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:1.285
                                                            longitude:103.848
                                                                 zoom:12];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    self.view = mapView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    [self updatePrivateMode:!self.isPrivateModeOn];
}

- (void) updatePrivateMode:(bool)isOn
{
    self.isPrivateModeOn = isOn;

    if(isOn)
    {
        NSLog(@"Private mode on: clearing geofences.");
        [self.geofenceManager clearAllGeofences];
        self.view.backgroundColor = [UIColor blackColor];
    }
    else
    {
        NSLog(@"Private mode off: recreating geofences.");
        [self.geofenceManager recreateGeofences];
        self.view.backgroundColor = [UIColor redColor];
    }

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isOn forKey:PERSISTENT_PRIVATE_MODE_KEY];
}

@end
