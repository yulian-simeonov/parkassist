//
//  MapViewController.h
//  Miller
//
//  Created by kadir pekel on 2/7/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Place.h"
#import "PlaceMark.h"
#import "MyCLController.h"
#import "JSWebManager.h"

@class ParkAssistViewController;

@interface MapView : UIView<MKMapViewDelegate> {

	MKMapView* _mapView;
	NSArray* routes;
    MKPointAnnotation* carPin;
    CLLocationCoordinate2D myPos;
    JSONDecoder* m_jsonDecoder;
    CLLocationDistance m_userAl;
    CLLocationDistance m_carAl;
    BOOL    m_bParkedCar;
    int     m_counter;
    JSWebManager* m_webMgr;
@public
    MKUserLocation* m_userPin;
    ParkAssistViewController* m_parent;
}

@property (nonatomic, retain) UIColor* lineColor;
- (void)initWithParent:(ParkAssistViewController*)parent;
-(void)ResizeMapView;
-(void)RemoveAnnotations;
-(void)UpdateCarePos;
@end
