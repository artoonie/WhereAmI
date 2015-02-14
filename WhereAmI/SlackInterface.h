//
//  SlackInterface.h
//  WhereAmI
//
//  Created by asamii on 2/13/15.
//  Copyright (c) 2015 adobe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SlackInterface : NSObject

+ (void)postMessageToSlack:(NSString*)message;

@end
