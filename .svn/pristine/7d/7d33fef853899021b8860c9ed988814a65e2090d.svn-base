//
//  HIstoryMapViewController.m
//  parkassist
//
//  Created by     on 11/6/13.
//  Copyright (c) 2013 RUHE. All rights reserved.
//

#import "HIstoryMapViewController.h"

@interface HIstoryMapViewController ()

@end

@implementation HIstoryMapViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=0.007f;
    span.longitudeDelta=0.007f;
    region.span = span;
    region.center = ((CLLocation*)[m_data objectForKey:@"location"]).coordinate;
    carPin = [[MKPointAnnotation alloc] init];
    carPin.title = [m_data objectForKey:@"address"];
    carPin.coordinate = ((CLLocation*)[m_data objectForKey:@"location"]).coordinate;
    [m_mapView addAnnotation:carPin];
    [m_mapView setRegion:region animated:TRUE];
    [m_mapView regionThatFits:region];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation
{
    MKAnnotationView *annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"carAnnotationViewID"];
    if (annotationView == nil)
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"carAnnotationViewID"];
    annotationView.image = [UIImage imageNamed:@"marker.png"];
    annotationView.annotation = annotation;
    annotationView.canShowCallout = true;
    return annotationView;
}

@end
