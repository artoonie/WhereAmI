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

NSString* keyPrivateMode = @"WHEREAMI_PRIVATEMODE";

@interface ViewController ()

@property (strong, nonatomic) GeofenceManager *geofenceManager;
@property bool isPrivateModeOn;

// Properties saved for event calls
@property CLLocation* lastTouchedLocation;
@property GMSMarker* lastTouchedMarker;
enum AlertTags {
    DeleteGeofence,
    CreateGeofence
};

@end

@implementation ViewController

GMSMapView* mapView;
UILabel* privateModeStatusLabel;

- (void) awakeFromNib {
    [super awakeFromNib];

    [GMSServices provideAPIKey:[WhereAmIConfig getGoogleMapsAPIKey]];

    self.geofenceManager = [[GeofenceManager alloc] init];

    // Create our view
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    self.view = [[UIView alloc] initWithFrame:frame];

    // Handle a doubletap gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];

    // Default value of boolForKey is false, which is what we want.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.isPrivateModeOn = [defaults boolForKey:keyPrivateMode];

    // Create map view
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:37.35
                                                            longitude:-122.0
                                                                 zoom:9];
    mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    [mapView.settings setMyLocationButton:YES];
    [mapView setMyLocationEnabled:YES];
    [mapView setDelegate:self];

    // Move the map view to the bottom 3/4 of the screen
    CGRect mapFrame = frame;
    mapFrame.origin.y += 1.0*mapFrame.size.height/4;
    mapFrame.size.height = 3.0*mapFrame.size.height/4;
    [mapView setFrame:mapFrame];
    [self.view addSubview:mapView];

    // Set up the status label
    CGRect labelFrame = frame;
    labelFrame.size.height = 1.0*labelFrame.size.height/4;
    privateModeStatusLabel = [[UILabel alloc] initWithFrame:labelFrame];
    privateModeStatusLabel.adjustsFontSizeToFitWidth = YES;
    privateModeStatusLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:privateModeStatusLabel];

    // Initialize with current private mode
    [self updatePrivateMode:self.isPrivateModeOn];

    // Add markers to the map
    [self createMapMarkers];
}

- (void)loadView
{
}

- (void)viewDidLoad {
    [super viewDidLoad];

    NSMutableSet* spyRegions = [self.geofenceManager spyRegions];

    for(SpyRegion* spyRegion in spyRegions)
    {
        [self createMapMarkerForRegion:spyRegion];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    [self updatePrivateMode:!self.isPrivateModeOn];
}

- (void)createMapMarkers
{
    [mapView clear];
    NSMutableSet* spyRegions = [self.geofenceManager spyRegions];

    for(SpyRegion* spyRegion in spyRegions)
    {
        [self createMapMarkerForRegion:spyRegion];
    }
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

- (void) updatePrivateMode:(bool)isOn
{
    self.isPrivateModeOn = isOn;

    if(isOn)
    {
        NSLog(@"Private mode on: clearing geofences.");
        [self.geofenceManager disableGeofences];
        self.view.backgroundColor = [UIColor blackColor];
        privateModeStatusLabel.text = @"Big Brother is Taking a Nap";
    }
    else
    {
        NSLog(@"Private mode off: recreating geofences.");
        [self.geofenceManager enableGeofences];
        self.view.backgroundColor = [UIColor redColor];
        privateModeStatusLabel.text = @"Big Brother is Watching";
    }
    privateModeStatusLabel.textColor = [UIColor whiteColor];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:isOn forKey:keyPrivateMode];
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
    alert.tag = CreateGeofence;
    [alert show];
}

- (void)mapView:(GMSMapView *)mapView
    didTapInfoWindowOfMarker:(GMSMarker *)marker;
{
    self.lastTouchedMarker = marker;
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Delete Geofence?"
                                                     message:@""
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Delete", nil];
    alert.tag = DeleteGeofence;
    [alert show];
}

#pragma mark Responders
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 0)
    {
        NSLog(@"Canceled");
    }
    else
    {
        switch(alertView.tag)
        {
            case DeleteGeofence:
            {
                assert(self.lastTouchedMarker != nil);
                [self.geofenceManager removeGeofenceAtCoordinate:self.lastTouchedMarker.position];
                [self createMapMarkers];
            }
                break;

            case CreateGeofence:
            {
                assert(self.lastTouchedLocation != nil);

                NSString* name = [[alertView textFieldAtIndex:0] text];
                SpyRegion* region = [[SpyRegion alloc] initWithName:name
                                                        andLocation:self.lastTouchedLocation
                                                          isPrivate:false];
                [self.geofenceManager addGeofence:region];
                [self createMapMarkerForRegion:region];
            }
                break;
        }
    }
}

@end
