//
//  KeepAlive.h
//  TrackOmeter
//
//  Created by dev1 on 8/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface KeepAlive : NSObject <CLLocationManagerDelegate>
{
@public
    UIBackgroundTaskIdentifier  m_bgTask;
}

- (void)start;
- (void)stop;
- (BOOL)isRunning;

@end

