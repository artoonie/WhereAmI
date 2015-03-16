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

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super init]) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.location = [decoder decodeObjectForKey:@"location"];
        self.isPrivate = [decoder decodeBoolForKey:@"isPrivate"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.location forKey:@"location"];
    [encoder encodeBool:self.isPrivate forKey:@"isPrivate"];
}

- (CLCircularRegion*) getSurroundingRegion
{
    CLCircularRegion *region = [[CLCircularRegion alloc]
                                initWithCenter:[self.location coordinate]
                                radius: 1000.
                                identifier:[[NSUUID UUID] UUIDString]];
    return region;
}

@end
