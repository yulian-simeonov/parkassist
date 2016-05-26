//
//  AppDelegate.m
//  parkassist
//
//  Created by Michael Mackowiak on 18/03/13.
//  Copyright (c) 2013 Michael Mackowiak. All rights reserved.
//

#import "AppDelegate.h"
#import "ParkAssistViewController.h"
#import "TutorialViewController.h"

@implementation AppDelegate
@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"history"])
        m_history = [[NSUserDefaults standardUserDefaults] objectForKey:@"history"];
    else
        m_history = [[NSMutableArray alloc] init];
    
    m_keepAlive = [[KeepAlive alloc] init];
    
    m_fakeLocationManager = [[CLLocationManager alloc] init];
    m_fakeLocationManager.delegate = m_keepAlive;
    m_fakeLocationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    ParkAssistViewController* mainController = [self GetMainViewController];
    if (mainController->secCount > 0)
        [UIApplication sharedApplication].applicationIconBadgeNumber = mainController->countingMin + 1;
    else
        [UIApplication sharedApplication].applicationIconBadgeNumber = mainController->countingMin;
    
    if (mainController->countingMin == 0 && mainController->secCount == 0)
        return;
    
    [m_keepAlive start];
    dispatch_async(dispatch_get_main_queue(), ^{
        backgroundTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(BackgroundTimer) userInfo:nil repeats:YES];
        [m_fakeLocationManager startUpdatingLocation];
    });
}

-(ParkAssistViewController*)GetMainViewController
{
    return m_mainVw;
}

-(void)BackgroundTimer
{
    UILocalNotification* notify = nil;
    NSDictionary *infoDict = nil;
    ParkAssistViewController* mainController = [self GetMainViewController];
    if (mainController->secCount > 0)
        [UIApplication sharedApplication].applicationIconBadgeNumber = mainController->countingMin + 1;
    else
        [UIApplication sharedApplication].applicationIconBadgeNumber = mainController->countingMin;
    if (mainController->countingMin == 0 && mainController->secCount == 0)
    {
        if (APP->m_isBell)
        {
            notify = [[UILocalNotification alloc] init];
            notify.repeatInterval = NSYearCalendarUnit;
            notify.soundName = UILocalNotificationDefaultSoundName;
            notify.applicationIconBadgeNumber = 0;
            notify.alertBody = @"The meter has expired";
            infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"expired", @"type", nil];
            notify.userInfo = infoDict;
            [[UIApplication sharedApplication] presentLocalNotificationNow:notify];
        }
        [backgroundTimer invalidate];
        backgroundTimer = nil;
        [m_keepAlive stop];
        if (mainController->downCounter)
        {
            [mainController->downCounter invalidate];
            mainController->downCounter = nil;
        }
    }
    else
    {
        if (mainController->secCount == 0)
        {
            if (mainController->countingMin > 0)
                mainController->countingMin--;
           mainController->secCount = 60;
        }
        mainController->secCount--;
    }
    
    if (mainController->countingMin == APP->bellMin && mainController->secCount == 0 && APP->m_isBell)
    {
        notify = [[UILocalNotification alloc] init];
        notify.repeatInterval = NSYearCalendarUnit;
        notify.soundName = UILocalNotificationDefaultSoundName;
        notify.alertBody = [NSString stringWithFormat:@"%d minutes left", APP->bellMin];
        infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"warning", @"type", nil];
        notify.userInfo = infoDict;
        [[UIApplication sharedApplication] presentLocalNotificationNow:notify];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [m_keepAlive stop];
    [m_fakeLocationManager stopUpdatingLocation];
    if (backgroundTimer)
    {
        [backgroundTimer invalidate];
        backgroundTimer = nil;
    }
    [[self GetMainViewController] SetTimeOnTimer];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

@end
