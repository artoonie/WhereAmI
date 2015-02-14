//
//  ViewController.m
//  WhereAmI
//
//  Created by asamii on 2/12/15.
//  Copyright (c) 2015 adobe. All rights reserved.
//

#import "ViewController.h"
#import "GeofenceManager.h"

@interface ViewController ()

@property (strong, nonatomic) GeofenceManager *geofenceManager;

@end

@implementation ViewController

- (void)awakeFromNib {
    [super awakeFromNib];

    self.geofenceManager = [[GeofenceManager alloc] init];

    // Handle a doubletap gesture
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender
{
    NSLog(@"Convenience function: doubletap!");
}

@end
