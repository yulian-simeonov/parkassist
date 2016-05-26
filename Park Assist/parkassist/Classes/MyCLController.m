//
//  MyCLController.m
//  GpsPhoto
//
//  Created by 陈玉亮 on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MyCLController.h"

@implementation MyCLController

@synthesize locationManager;
@synthesize delegate;

- (id) init {
	self = [super init];
	if (self != nil) {
		self.locationManager = [[CLLocationManager alloc] init];
		self.locationManager.delegate = self; // send loc updates to myself
	}
	return self;
}

- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
    if (self.delegate)
        [self.delegate locationUpdate:self Location:newLocation];
}


- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
    if (self.delegate)
        [self.delegate locationError:self Error:error];
}

@end
