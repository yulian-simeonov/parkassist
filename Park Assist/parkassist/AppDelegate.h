//
//  AppDelegate.h
//  parkassist
//
//  Created by Michael Mackowiak on 18/03/13.
//  Copyright (c) 2013 Michael Mackowiak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AVFoundation/AVFoundation.h>
#import "KeepAlive.h"

@class ParkAssistViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSTimer* backgroundTimer;
    KeepAlive* m_keepAlive;
    CLLocationManager*          m_fakeLocationManager;
@public
    BOOL m_isBell;
    int bellMin;
    ParkAssistViewController* m_mainVw;
    NSMutableArray* m_history;
}
@property (strong, nonatomic) UIWindow *window;
@end
