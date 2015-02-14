//
//  SlackInterface.m
//  WhereAmI
//
//  Created by asamii on 2/13/15.
//  Copyright (c) 2015 adobe. All rights reserved.
//

#import "config.h"
#import "SlackInterface.h"

@implementation SlackInterface

+ (void)postMessageToSlack:(NSString*)message
{
    // Get the Server URL from the config file
    NSString* serverURL = [WhereAmIConfig getSlackServerURL];

    // Generate the request
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[NSURL URLWithString:serverURL]
                                cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                            timeoutInterval:10];
    [request setHTTPMethod: @"POST"];

    // Create the JSON data to be sent with the request
    NSString* payload = [NSString stringWithFormat:@"%@%@%@",
                            @"payload={\"channel\": \"#integrations\", \
                                       \"username\": \"stalkerbot\", \
                                              \"text\": \"", message, @"\", \
                                              \"icon\": \"http://i.imgur.com/fVKz2tA.jpg\"}"];
    [request setHTTPBody:[[payload stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]
                          dataUsingEncoding:NSUTF8StringEncoding
                          allowLossyConversion:YES]];


    // Shoot out the response and handle any errors
    NSError* requestError = nil;
    NSURLResponse* urlResponse = nil;
    NSData *response = [NSURLConnection sendSynchronousRequest:request
                                             returningResponse:&urlResponse
                                                         error:&requestError];
    if(requestError)
    {
        NSLog(@"Error posting to slack: %@", [requestError description]);
    }
    else
    {
        NSLog(@"Successfully sent the message. Server says %@", [response description]);
    }
}

@end
