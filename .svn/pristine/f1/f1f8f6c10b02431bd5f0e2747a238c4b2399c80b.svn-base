//
//  ViewControllerPortrait.h
//  parkassist
//
//  Created by Michael Mackowiak on 18/03/13.
//  Copyright (c) 2013 Michael Mackowiak. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MyCLController.h"
#import "PlaceMark.h"
#import "OneFingerRotationGestureRecognizer.h"
#import "AppDelegate.h"
#import "MapView.h"
#import <MessageUI/MessageUI.h>

#define AnchorTop   0
#define AnchorMiddle   1
#define AnchorBelow     2
@interface ParkAssistViewController: UIViewController <OneFingerRotationGestureRecognizerDelegate, MFMailComposeViewControllerDelegate>
{
    CGFloat imageAngle;
    OneFingerRotationGestureRecognizer *gestureRecognizer;
    IBOutlet UILabel* lbl_distance;
    IBOutlet UISegmentedControl* seg_bell;
    IBOutlet UISegmentedControl* seg_measure;
    IBOutlet UIView* touchView;
    IBOutlet UIButton* btn_park;
    IBOutlet UIImageView* img_mask;
    IBOutlet UIImageView* img_background;
    
    IBOutlet UILabel* lbl_altitude;
    IBOutlet UIImageView* img_arrow;

    NSString* strMeasure;
    BOOL m_bFinished;
    float startY;
    float offsetY;
    float movedPos;
    float curY;
    CGRect posArray[15];
    int anchorState;
    BOOL m_bSetPark;
    CLLocationDistance m_distance;
    CLLocationDistance m_altitude;
    NSTimer*    m_waiterTimer;
    float       m_waiterAngle;
@public
    int settingMin;
    int countingMin;
    int secCount;
    
    NSTimer* downCounter;
}
@property (strong, nonatomic) IBOutlet MapView *_mapView;
@property (nonatomic, strong) IBOutlet UIImageView *_imgCounter;
@property (nonatomic, strong) IBOutlet UIImageView *img_bell;
@property (nonatomic, strong) IBOutlet UILabel *_lblMinutesLeft;
@property (nonatomic, strong) IBOutlet UILabel *_lblSecondsLeft;
@property (nonatomic, strong) IBOutlet UIButton *btn_help;
@property (nonatomic, strong) IBOutlet UILabel *lbl_minutes;
@property (nonatomic, strong) IBOutlet UIImageView *img_alarm;
@property (nonatomic, strong) IBOutlet UIImageView *img_waiter;
@property (nonatomic, strong) IBOutlet UIButton *btn_email;

-(void)SetTimeOnTimer;
-(void)SetAltitude:(CLLocationDistance)alDiff distance:(CLLocationDistance)distDiff;
-(void)HideWaiter;
-(void)ShowLocationServiceWarning;
@end