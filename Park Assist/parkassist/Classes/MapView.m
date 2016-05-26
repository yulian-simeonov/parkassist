//
//  MapViewController.m
//  Miller
//
//  Created by kadir pekel on 2/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MapView.h"
#import "ParkAssistViewController.h"
@implementation MapView

@synthesize lineColor;

- (void)initWithParent:(ParkAssistViewController*)parent
{
    m_parent = parent;
    m_bParkedCar = true;
    _mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    _mapView.showsUserLocation = YES;
    [_mapView setDelegate:self];
    [self addSubview:_mapView];
    self.lineColor = [UIColor redColor];
    carPin = [[MKPointAnnotation alloc] init];
    m_jsonDecoder = [[JSONDecoder alloc] init];
    m_webMgr = [[JSWebManager alloc] initWithAsyncOption:NO];
    m_counter = 0;
    [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(UpdateLocation) userInfo:nil repeats:NO];
}

-(void)UpdateLocation
{
    if (m_userPin)
    {
        if (!m_bParkedCar)
            [self Park:m_userPin.location];
        
        BOOL hasCarPin = false;
        MKCoordinateRegion region;
        MKCoordinateSpan span;
        CLLocationCoordinate2D carPos;
        CLLocationDistance dist = CLLocationDistanceMax;
        myPos = m_userPin.coordinate;
        m_userAl = m_userPin.location.altitude;
        
        if (m_counter == 0)
            m_userPin.title = [self getAddressFromLatLon:myPos.latitude withLongitude:myPos.longitude fromUser:YES];
        m_counter++;
        if (m_counter > 4)
            m_counter = 0;
        
        for(MKPointAnnotation* pin in [_mapView annotations])
        {
            if (pin == carPin)
            {
                carPos = [carPin coordinate];
                hasCarPin = true;
                break;
            }
        }
        if (!hasCarPin)
        {
            span.latitudeDelta=0.007f;
            span.longitudeDelta=0.007f;
            region.span = span;
            region.center = myPos;
            if (myPos.latitude >= -89 && myPos.latitude <= 89 && myPos.longitude <= 179 && myPos.longitude >= -179)
            {
                [_mapView setRegion:region animated:TRUE];
                [_mapView regionThatFits:region];
            }
            else
                NSLog(@"crash issue");
        }
        else
        {
            CLLocation* carLoc = [[CLLocation alloc] initWithLatitude:carPos.latitude longitude:carPos.longitude];
            dist = [carLoc distanceFromLocation:[[CLLocation alloc] initWithLatitude:myPos.latitude longitude:myPos.longitude]];
            [m_parent SetAltitude:m_carAl - m_userAl  distance:dist];
            double maxTop = -90, maxLeft = 180, maxRight = -180, maxBottom = 90;
            if (myPos.latitude > carPos.latitude)
            {
                maxTop = myPos.latitude;
                maxBottom = carPos.latitude;
            }
            else
            {
                maxTop = carPos.latitude;
                maxBottom = myPos.latitude;
            }
            if (myPos.longitude > carPos.longitude)
            {
                maxRight = myPos.longitude;
                maxLeft = carPos.longitude;
            }
            else
            {
                maxLeft = myPos.longitude;
                maxRight = carPos.longitude;
            }
            
            double deltaX = (maxTop - maxBottom) * 1.2f;
            if (deltaX < 0.007f)
                deltaX = 0.007f;
            double deltaY = (maxRight - maxLeft) * 1.2f;
            if (deltaY < 0.007f)
                deltaY = 0.007f;
            if (deltaX < 180 && deltaY < 90)
            {
                region = MKCoordinateRegionMake(CLLocationCoordinate2DMake((maxTop + maxBottom) / 2, (maxRight + maxLeft) / 2), MKCoordinateSpanMake(deltaX, deltaY));            
                [_mapView setRegion:region animated:TRUE];
                [_mapView regionThatFits:region];
            }
            else
                NSLog(@"crash issue");
        }
    }
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(UpdateLocation) userInfo:nil repeats:NO];
}

-(void)ResizeMapView
{
    [_mapView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

-(void)RemoveAnnotations
{
    [_mapView removeAnnotations:[_mapView annotations]];
    m_bParkedCar = true;
}

-(void)UpdateCarePos
{
    m_bParkedCar = false;
}

-(BOOL)IsSetPark
{
    for(MKPointAnnotation* pin in [_mapView annotations])
    {
        if (pin == carPin)
        {
            return true;
        }
    }
    return false;
}

- (void)Park:(CLLocation *)location
{
    m_bParkedCar = true;
    carPin.title = [self getAddressFromLatLon:[location coordinate].latitude withLongitude:[location coordinate].longitude fromUser:NO];
    NSString* strAddress;
    if ([carPin.title isEqualToString:@"My Car Location"])
        strAddress = [NSString stringWithFormat:@"%f, %f", location.coordinate.latitude, location.coordinate.longitude];
    else
        strAddress = carPin.title;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd MMM yyyy HH:mm"];
    [dateFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    NSString* localTime = [dateFormatter stringFromDate:[NSDate date]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString* utcTime = [dateFormatter stringFromDate:[NSDate date]];
    NSDictionary* dic = [NSDictionary dictionaryWithObjectsAndKeys:strAddress, @"address", localTime, @"time", utcTime, @"utctime", nil];
    if (APP->m_history.count > 0)
    {
        if (![[APP->m_history objectAtIndex:APP->m_history.count - 1] isEqual:dic])
            [APP->m_history addObject:dic];
    }
    else
        [APP->m_history addObject:dic];
    
    [[NSUserDefaults standardUserDefaults] setObject:APP->m_history forKey:@"history"];
    [NSUserDefaults resetStandardUserDefaults];

    carPin.coordinate = location.coordinate;
    m_carAl = location.altitude;
    [_mapView removeAnnotation:carPin];
    [_mapView addAnnotation:carPin];
    [m_parent HideWaiter];
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    m_userPin = userLocation;
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
    [m_parent ShowLocationServiceWarning];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    if (![annotation isKindOfClass:[MKUserLocation class]])
    {
        MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"carAnnotationViewID"];
        if (annotationView == nil)
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"carAnnotationViewID"];
        annotationView.image = [UIImage imageNamed:@"marker.png"];
        annotationView.annotation = annotation;
        annotationView.canShowCallout = true;
        return annotationView;
    }
    else
        return nil;
}

-(NSString *)getAddressFromLatLon:(double)pdblLatitude withLongitude:(double)pdblLongitude fromUser:(BOOL)fromUsr
{
    NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true",pdblLatitude, pdblLongitude];
    ASIHTTPRequest* ret = [m_webMgr->m_jsonManager JSONRequest:urlString params:nil requestMethod:GET];
    if (ret)
    {
        NSDictionary* dic = [m_webMgr->m_jsonManager->m_jsonDecoder objectWithData:[ret responseData]];
        if ([[dic valueForKey:@"status"] isEqualToString:@"OK"])
        {
            NSArray* ary = [dic valueForKey:@"results"];
            if (ary)
            {
                if ([ary isKindOfClass:[NSArray class]])
                {
                    if (ary.count > 0)
                    {
                        return [[ary objectAtIndex:0] valueForKey:@"formatted_address"];
                    }
                }
            }
        }
    }
    if (fromUsr)
        return @"My Location";
    else
        return @"My Car Location";
}

- (void)ShowRoute
{
    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:carPin.coordinate addressDictionary:nil];
    MKPlacemark *destPlacemark = [[MKPlacemark alloc] initWithCoordinate:myPos addressDictionary:nil];
    
    MKMapItem *carPosition = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    MKMapItem *actualPosition = [[MKMapItem alloc] initWithPlacemark:destPlacemark];
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = actualPosition;
    request.destination = carPosition;
    request.requestsAlternateRoutes = YES;
    
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (!error) {
            [self showDirections:response];
        }
    }];
}

- (void)showDirections:(MKDirectionsResponse *)response
{
    [_mapView removeOverlays:[_mapView overlays]];
    for (MKRoute *route in response.routes) {
        [_mapView addOverlay:route.polyline level:MKOverlayLevelAboveRoads];
    }
}

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *routeRenderer = [[MKPolylineRenderer alloc] initWithPolyline:route];
        routeRenderer.strokeColor = [UIColor blueColor];
        routeRenderer.lineWidth = 2;
        return routeRenderer;
    }
    else return nil;
}

-(void) centerMap {
	MKCoordinateRegion region;
    
	CLLocationDegrees maxLat = -90;
	CLLocationDegrees maxLon = -180;
	CLLocationDegrees minLat = 90;
	CLLocationDegrees minLon = 180;
	for(int idx = 0; idx < routes.count; idx++)
	{
		CLLocation* currentLocation = [routes objectAtIndex:idx];
		if(currentLocation.coordinate.latitude > maxLat)
			maxLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.latitude < minLat)
			minLat = currentLocation.coordinate.latitude;
		if(currentLocation.coordinate.longitude > maxLon)
			maxLon = currentLocation.coordinate.longitude;
		if(currentLocation.coordinate.longitude < minLon)
			minLon = currentLocation.coordinate.longitude;
	}
	region.center.latitude     = (maxLat + minLat) / 2;
	region.center.longitude    = (maxLon + minLon) / 2;
	region.span.latitudeDelta  = maxLat - minLat;
	region.span.longitudeDelta = maxLon - minLon;
	
	[_mapView setRegion:region animated:YES];
}

@end
