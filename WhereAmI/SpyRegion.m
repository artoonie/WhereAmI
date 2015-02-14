//
//  SpyRegions.m
//  WhereAmI
//
//  Created by asamii on 2/13/15.
//  Copyright (c) 2015 adobe. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import "SpyRegion.h"

@implementation SpyRegion

- (SpyRegion*) initWithName:(NSString*)name
                andLocation:(CLLocation*)location
                  isPrivate:(bool)isPrivate
{
    if (self = [super init])
    {
        self.name = name;
        self.location = location;
        self.isPrivate = isPrivate;
    }
    return self;
}

@end
