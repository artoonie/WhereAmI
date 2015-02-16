// The interface for private configuration data
// You must implement this interface to get things running

#pragma once

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface WhereAmIConfig : NSObject

// A string in a format like https://hooks.slack.com/services/<custom-info>
+ (NSString*) getSlackServerURL;

// A mutable set of SpyRegion objects
+ (NSMutableSet*) getSpyRegions;

// API key for Google Maps iOS API. Generate one here:
// https://developers.google.com/maps/documentation/ios/start
+ (NSString*) getGoogleMapsAPIKey;

@end