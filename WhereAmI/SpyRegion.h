//
//  SpyRegions.h
//  WhereAmI
//
//  Created by asamii on 2/13/15.
//  Copyright (c) 2015 adobe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SpyRegion : NSObject

// What is the name of this region?
@property (strong, nonatomic) NSString* name;

// What are the GPS coordinates of this location?
@property (strong, nonatomic) CLLocation* location;

// Is this a private location? If so, we will not broadcast your location
// on weekends, or on weekdays outside of [5am, 11am].
@property bool isPrivate;

- (SpyRegion*) initWithName:(NSString*)name
                andLocation:(CLLocation*)location
                  isPrivate:(bool)isPrivate;

- (CLCircularRegion*) getSurroundingRegion;

@end
