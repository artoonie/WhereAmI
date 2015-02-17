//
//  ViewController.m
//  WhereAmI
//
//  Created by asamii on 2/12/15.
//  Copyright (c) 2015 adobe. All rights reserved.
//

#import "config.h"
#import "GeofenceManager.h"
#import "SpyRegion.h"
#import "ViewController.h"

NSString* PERSISTENT_PRIVATE_MODE_KEY = @"WHEREAMI_PRIVATEMODE";

@interface ViewController ()

@property (strong, nonatomic) GeofenceManager *geofenceManager;
@property bool isPrivateModeOn;
@property CLLocation* lastTouchedLocation;

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

- (void)createMapMarkerForRegion:(SpyRegion*)spyRegion
{
    CLLocationCoordinate2D position = spyRegion.location.coordinate;
    GMSMarker *marker = [GMSMarker markerWithPosition:position];
    marker.title = spyRegion.name;
    marker.map = mapView;
    
    GMSCircle *circ = [GMSCircle circleWithPosition:position
                                             radius:1000];
    circ.fillColor = [UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.1];
    circ.strokeColor = [UIColor redColor];
    circ.strokeWidth = 1;
    circ.map = mapView;
}

- (void)loadView
{
    [GMSServices provideAPIKey:[WhereAmIConfig getGoogleMapsAPIKey]];

    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.35
                                                            longitude:-122.0
                                                                 zoom:9];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView.delegate = self;

    self.view = mapView;

    NSMutableSet* spyRegions = [WhereAmIConfig getSpyRegions];
    for(SpyRegion* spyRegion in spyRegions)
    {
        [self createMapMarkerForRegion:spyRegion];
    }
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

#pragma mark - GMSMapViewDelegate

- (void)mapView:(GMSMapView *)mapView
        didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
    self.lastTouchedLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude
                                                          longitude:coordinate.longitude];

    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"New Geofence"
                                                     message:@"Location Name"
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Create", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIAlertViewStylePlainTextInput;
    alertTextField.placeholder = @"Name of Location";
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        NSLog(@"Canceled");
    }
    else
    {
        assert(self.lastTouchedLocation != nil);
        
        NSString* name = [[alertView textFieldAtIndex:0] text];
        SpyRegion* region = [[SpyRegion alloc] initWithName:name
                                                andLocation:self.lastTouchedLocation
                                                  isPrivate:false];
        [self createMapMarkerForRegion:region];
    }
}

@end
