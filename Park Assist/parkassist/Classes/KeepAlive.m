//
//  KeepAlive.m
//  TrackOmeter
//
//  Created by dev1 on 8/06/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "KeepAlive.h"

@implementation KeepAlive

- (id)init
{
    self = [super init];
    if (self)
    {
        m_bgTask = UIBackgroundTaskInvalid;
    }
    return self;
}

- (void)start
{
    if (m_bgTask == UIBackgroundTaskInvalid)
    {
        UIApplication* app = [UIApplication sharedApplication];
      
        // Start a background task...
        m_bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
            [app endBackgroundTask:m_bgTask];
            m_bgTask = UIBackgroundTaskInvalid;

        }];
        
        /*
            Don't terminate the task at this point. Let control return to the system
            but leave the task active.
        */
    }
}

- (void)stop
{
    if (m_bgTask != UIBackgroundTaskInvalid)
    {
        UIApplication* app = [UIApplication sharedApplication];
        
        // Stop the background task to allow the app to be suspended...
        [app endBackgroundTask:m_bgTask];
        m_bgTask = UIBackgroundTaskInvalid;
    }
}

- (BOOL)isRunning
{
    return m_bgTask != UIBackgroundTaskInvalid;
}

//------------------------------------------------------------------------------
// CLLocationManagerDelegate...

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{

}

- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return NO;
}

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{

}

@end
