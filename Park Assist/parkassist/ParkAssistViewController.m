//
//  ViewControllerPortrait.m
//  parkassist
//
//  Created by Michael Mackowiak on 18/03/13.
//  Copyright (c) 2013 Michael Mackowiak. All rights reserved.
//

#import <math.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ParkAssistViewController.h"
#import "TutorialViewController.h"
#import "HelpViewController.h"
#import <math.h>

#define METERS_PER_MILE 1609.344

@implementation ParkAssistViewController
@synthesize _mapView;
@synthesize _imgCounter;
@synthesize _lblMinutesLeft;
@synthesize _lblSecondsLeft;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        imageAngle = 0;
    }
    return self;
}

// Addes gesture recognizer to the view (or any other parent view of image. Calculates midPoint
// and radius, based on the image position and dimension.
- (void) setupGestureRecognizer
{
    // calculate center and radius of the control
    CGPoint midPoint = CGPointMake(_imgCounter.frame.origin.x + _imgCounter.frame.size.width / 2,
                                   _imgCounter.frame.origin.y + _imgCounter.frame.size.height / 2);
    
    gestureRecognizer = [[OneFingerRotationGestureRecognizer alloc] initWithMidPoint:midPoint target:self];
    [touchView addGestureRecognizer: gestureRecognizer];
}

#pragma Delegates of UIView
-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SetTutorial"];
    [NSUserDefaults resetStandardUserDefaults];
    NSUserDefaults* setting = [NSUserDefaults standardUserDefaults];
    
    APP->m_isBell = [setting boolForKey:@"SetAlert"];
    APP->bellMin = [setting integerForKey:@"AlertTime"];
    m_altitude = 0;
    m_distance = 0;
    [seg_bell addTarget:self action:@selector(SegAction:) forControlEvents:UIControlEventValueChanged];
    [seg_measure addTarget:self action:@selector(SegMeasure:) forControlEvents:UIControlEventValueChanged];
    
    strMeasure = [setting objectForKey:@"Measure"];
    if (!strMeasure)
        strMeasure = @"ft";
    if ([strMeasure isEqualToString:@"ft"])
        seg_measure.selectedSegmentIndex = 0;
    else
        seg_measure.selectedSegmentIndex = 1;
    if (APP->m_isBell)
    {
        if (APP->bellMin == 0)
            APP->bellMin = 5;
        switch(APP->bellMin)
        {
            case 5:
                seg_bell.selectedSegmentIndex = 1;
                break;
            case 10:
                seg_bell.selectedSegmentIndex = 2;
                break;
        }
    }
    else
    {
        seg_bell.selectedSegmentIndex = 0;
        [_img_bell setHidden:YES];
    }
    
    [_lblMinutesLeft setHidden:YES];
    [_lblSecondsLeft setHidden:YES];
    [self setupGestureRecognizer];
    [self updateTextDisplay];
    
    anchorState = AnchorMiddle;
    
    posArray[0] = touchView.frame;
    posArray[1] = btn_park.frame;
    posArray[2] = img_mask.frame;
    posArray[3] = img_background.frame;
    posArray[4] = _mapView.frame;
    posArray[5] = _lblMinutesLeft.frame;
    posArray[6] = _lblSecondsLeft.frame;
    posArray[7] = seg_measure.frame;
    posArray[8] = _lbl_minutes.frame;
    posArray[9] = _img_alarm.frame;
    posArray[10] = seg_bell.frame;
    posArray[11] = lbl_altitude.frame;
    posArray[12] = img_arrow.frame;
    posArray[13] = lbl_distance.frame;
    posArray[14] = _btn_email.frame;
    
    [_mapView initWithParent:self];
    APP->m_mainVw = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self rotation:0];
    if (!m_bSetPark)
    {
        [lbl_altitude setHidden:YES];
        [lbl_distance setHidden:YES];
        [img_arrow setHidden:YES];
    }
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma User Actions
- (IBAction)SetLocationAndStartTimer:(id)sender
{
    [self AnchorViews];
    if (movedPos > 5)
        return;
    
    if(![CLLocationManager locationServicesEnabled])
    {
        [[[UIAlertView alloc] initWithTitle:@"Location Services" message:@"Please turn on Location Services in the settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    if (anchorState == AnchorTop)
    {
        curY = 200;
        [self AnchorViews];
        return;
    }
    
    if (downCounter)
    {
        [[[UIAlertView alloc] initWithTitle:@"Reset Timer" message:@"Are you sure you want to\nreset the timer?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
        return;
    }
    
    if (m_bFinished)
    {
        [[[UIAlertView alloc] initWithTitle:@"Reset Location" message:@"Are you sure you want to\nreset your location?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil] show];
        return;
    }
    
    [self ShowWaiter];
    [_mapView RemoveAnnotations];
    [_mapView UpdateCarePos];
}

-(IBAction)OnTouchExit:(id)sender
{
    [self AnchorViews];
}

-(IBAction)OnTouchDown:(id)sender event:(UIEvent *)event
{
    NSArray* touches = [[event allTouches] allObjects];
    UITouch* myTouch = [touches objectAtIndex:0];
    startY = [myTouch locationInView:self.view].y;
    curY = [myTouch locationInView:self.view].y;
    offsetY = 0;
    movedPos = 0;
}

-(IBAction)OnTouchDragInside:(id)sender event:(UIEvent *)event
{
    NSArray* touches = [[event allTouches] allObjects];
    UITouch* myTouch = [touches objectAtIndex:0];
    curY = [myTouch locationInView:self.view].y;
    offsetY = curY - startY;
    movedPos += ABS(offsetY);
    [self MoveView];
}

-(IBAction)OnHelp:(id)sender
{
    HelpViewController* vw = (HelpViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"sb_help"];
    [self.navigationController pushViewController:vw animated:YES];
}

-(void)SegAction:(id)sender
{
    APP->m_isBell = TRUE;
    [self.img_bell setHidden:NO];
    switch(seg_bell.selectedSegmentIndex)
    {
        case 0:
            APP->m_isBell = FALSE;
            [self.img_bell setHidden:YES];
            break;
        case 1:
            APP->bellMin = 5;
            break;
        case 2:
            APP->bellMin = 10;
            break;
    }
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"SetAlert"];
    [[NSUserDefaults standardUserDefaults] setInteger:APP->bellMin forKey:@"AlertTime"];
    [NSUserDefaults resetStandardUserDefaults];
    [self rotation:0];
}

-(void)SegMeasure:(id)sender
{
    switch(seg_measure.selectedSegmentIndex)
    {
        case 0:
            strMeasure = @"ft";
            break;
        case 1:
            strMeasure = @"m";
            break;
    }
    [[NSUserDefaults standardUserDefaults] setObject:strMeasure forKey:@"Measure"];
    [NSUserDefaults resetStandardUserDefaults];
    
    [self SetAltitude:m_altitude distance:m_distance];
}

#pragma Logic functions
-(void)TimeCounter
{
    if (countingMin == 0 && secCount == 0)
    {
        [downCounter invalidate];
        downCounter = nil;
        m_bFinished = true;
        [_lblMinutesLeft setHidden:YES];
        [_lblSecondsLeft setHidden:YES];
        [btn_park setBackgroundImage:[UIImage imageNamed:@"park_on_finished.png"] forState:UIControlStateNormal];
    }
    else
    {
        if (secCount == 0)
        {
            if (countingMin > 0)
                countingMin--;
            secCount = 60;
        }
        secCount--;
    }
    [self SetTimeOnTimer];
}

-(void)SetTimeOnTimer
{
    if (countingMin == 0 && secCount == 0)
        imageAngle = 0;
    else
        imageAngle = -(countingMin + 1) * 2;

    [self rotation:0];

    if (countingMin >= 10)
    {
        if (secCount >= 10)
        {
            _lblMinutesLeft.text = [NSString stringWithFormat: @"%d", countingMin];
            _lblSecondsLeft.text = [NSString stringWithFormat: @"%d", secCount];
        }
        else
        {
            _lblMinutesLeft.text = [NSString stringWithFormat: @"%d", countingMin];
            _lblSecondsLeft.text = [NSString stringWithFormat: @"%d", secCount];
        }
    }
    else
    {
        if (secCount >= 10)
        {
            _lblMinutesLeft.text = [NSString stringWithFormat: @"%d", countingMin];
            _lblSecondsLeft.text = [NSString stringWithFormat: @"%d", secCount];
        }
        else
        {
            _lblMinutesLeft.text = [NSString stringWithFormat: @"%d", countingMin];
            _lblSecondsLeft.text = [NSString stringWithFormat: @"%d", secCount];
        }
    }
}

-(void)SetAltitude:(CLLocationDistance)alDiff distance:(CLLocationDistance)distDiff
{
    [lbl_altitude setHidden:YES];
    [img_arrow setHidden:YES];
    m_distance = distDiff;
    m_altitude = alDiff;
    float dist;
    if (distDiff < 30)
    {
        if(alDiff > 2 || alDiff < -2)
        {
            [lbl_altitude setHidden:NO];
            [img_arrow setHidden:NO];
            if (alDiff > 2)
                [img_arrow setImage:[UIImage imageNamed:@"arrow_up.png"]];
            else
                [img_arrow setImage:[UIImage imageNamed:@"arrow_down.png"]];
            
            if ([strMeasure isEqualToString:@"ft"])
                dist = ABS(alDiff) * 3.2808399f;
            else
                dist = ABS(alDiff);
            [lbl_altitude setText:[NSString stringWithFormat:@"%.0f %@", ABS(dist), strMeasure]];
        }
    }
    if ([strMeasure isEqualToString:@"ft"])
        dist = ABS(distDiff) * 3.2808399f;
    else
        dist = ABS(distDiff);
    [lbl_distance setText:[NSString stringWithFormat:@"%.0f %@", ABS(dist), strMeasure]];
}

// Updates the text field with the current rotation angle.
- (void) updateTextDisplay
{
    settingMin = -imageAngle / 2;
    if (settingMin >= 10)
    {
        _lblMinutesLeft.text = [NSString stringWithFormat: @"%d", countingMin];
        _lblSecondsLeft.text = [NSString stringWithFormat: @"%d", secCount];
        _lbl_minutes.text = [NSString stringWithFormat: @"%d", settingMin];
    }
    else
    {
        _lblMinutesLeft.text = [NSString stringWithFormat: @"%d", countingMin];
        _lblSecondsLeft.text = [NSString stringWithFormat: @"%d", secCount];
        _lbl_minutes.text = [NSString stringWithFormat: @"0%d", settingMin];
    }
}

#pragma Delegates of  Meter
- (void) rotation: (CGFloat) angle
{
    // calculate rotation angle
    if (angle != 0 && m_bSetPark)
    {
        [[[UIAlertView alloc] initWithTitle:@"Reset Timer" message:@"Are you sure you want to\nreset the timer?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
        return;
    }
    imageAngle += angle;
    if (imageAngle > 360)
        imageAngle = 0;
    else if (imageAngle < -360)
        imageAngle = 0;
    
    // Prevent the time from being set to a negative value
    // or from rotating past the maximum value
    if (imageAngle > 0)
    {
        gestureRecognizer.state = UIGestureRecognizerStateFailed;
        _imgCounter.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, offsetY), 0);
        imageAngle = 0;
    }
    else if (imageAngle < -330)
    {
        gestureRecognizer.state = UIGestureRecognizerStateFailed;
        _imgCounter.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, offsetY), -330 *  M_PI / 180);
        imageAngle = -330;
    }
    else
    {
        // rotate image and update text field
        _imgCounter.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, offsetY), imageAngle *  M_PI / 180);
    }
    self.img_bell.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, offsetY), (imageAngle + APP->bellMin * 2) *  M_PI / 180);
    
    [self updateTextDisplay];
}

- (void)AdjustStep
{
    // circular gesture ended, update text field
    int integerAngle = (int)imageAngle;
    if (integerAngle % 2)
        imageAngle = (int)imageAngle + 1;
    else
        imageAngle = (int)imageAngle;
    
    [self rotation:0];
    [self updateTextDisplay];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        if (downCounter)
        {
            [downCounter invalidate];
            downCounter = nil;
            [self updateTextDisplay];
            countingMin = 0;
            secCount = 0;
        }
        m_bFinished = false;
        m_bSetPark = false;
        [_lblMinutesLeft setHidden:YES];
        [_lblSecondsLeft setHidden:YES];
        [lbl_distance setHidden:YES];
        [lbl_altitude setHidden:YES];
        [img_arrow setHidden:YES];
        [btn_park setBackgroundImage:[UIImage imageNamed:@"park_off.png"] forState:UIControlStateNormal];
        [_mapView RemoveAnnotations];
    }
}

-(void)MoveView
{
    float offset = 0;
    switch (anchorState) {
        case AnchorTop:
            offset = -261;
            if (offsetY > 340)
                return;
            break;
        case AnchorBelow:
            offset = 80;
            if (offsetY > 0)
                return;
            break;
        case AnchorMiddle:
            if (offsetY > 80)
                return;
            break;
        default:
            break;
    }
    [touchView setFrame:CGRectMake(posArray[0].origin.x, posArray[0].origin.y + offsetY + offset, posArray[0].size.width, posArray[0].size.height)];
    [btn_park setFrame:CGRectMake(posArray[1].origin.x, posArray[1].origin.y + offsetY + offset, posArray[1].size.width, posArray[1].size.height)];
    [img_mask setFrame:CGRectMake(posArray[2].origin.x, posArray[2].origin.y + offsetY + offset, posArray[2].size.width, posArray[2].size.height)];
    [img_background setFrame:CGRectMake(posArray[3].origin.x, posArray[3].origin.y + offsetY + offset, posArray[3].size.width, posArray[3].size.height)];
    [_mapView setFrame:CGRectMake(posArray[4].origin.x, posArray[4].origin.y + offsetY + offset, posArray[4].size.width, posArray[4].size.height + 300)];
    [_mapView ResizeMapView];
    _imgCounter.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, offsetY + offset), imageAngle *  M_PI / 180);
    self.img_bell.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, offsetY + offset), (imageAngle + APP->bellMin * 2) *  M_PI / 180);
    [_lblMinutesLeft setFrame:CGRectMake(posArray[5].origin.x, posArray[5].origin.y + offsetY + offset, posArray[5].size.width, posArray[5].size.height)];
    [_lblSecondsLeft setFrame:CGRectMake(posArray[6].origin.x, posArray[6].origin.y + offsetY + offset, posArray[6].size.width, posArray[6].size.height)];
    [seg_measure setFrame:CGRectMake(posArray[7].origin.x, posArray[7].origin.y + offsetY + offset, posArray[7].size.width, posArray[7].size.height)];
    [_lbl_minutes setFrame:CGRectMake(posArray[8].origin.x, posArray[8].origin.y + offsetY + offset, posArray[8].size.width, posArray[8].size.height)];
    [_img_alarm setFrame:CGRectMake(posArray[9].origin.x, posArray[9].origin.y + offsetY + offset, posArray[9].size.width, posArray[9].size.height)];
    [seg_bell setFrame:CGRectMake(posArray[10].origin.x, posArray[10].origin.y + offsetY + offset, posArray[10].size.width, posArray[10].size.height)];
    [lbl_altitude setFrame:CGRectMake(posArray[11].origin.x, posArray[11].origin.y + offsetY + offset, posArray[11].size.width, posArray[11].size.height)];
    [img_arrow setFrame:CGRectMake(posArray[12].origin.x, posArray[12].origin.y + offsetY + offset, posArray[12].size.width, posArray[12].size.height)];
    [lbl_distance setFrame:CGRectMake(posArray[13].origin.x, posArray[13].origin.y + offsetY + offset, posArray[13].size.width, posArray[13].size.height)];
    _img_waiter.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, offsetY + offset), m_waiterAngle *  M_PI / 180);
    [_btn_email setFrame:CGRectMake(posArray[14].origin.x, posArray[14].origin.y + offsetY + offset, posArray[14].size.width, posArray[14].size.height)];

}

-(void)AnchorViews
{
    [_lblMinutesLeft setHidden:NO];
    [_lblSecondsLeft setHidden:NO];
    if (curY < 140)
    {
        [_lblMinutesLeft setHidden:YES];
        [_lblSecondsLeft setHidden:YES];
        [btn_park setBackgroundImage:[UIImage imageNamed:@"park_top_on.png"] forState:UIControlStateNormal];
        anchorState = AnchorTop;
        offsetY = -261;
    }
    else if (curY > 140 && curY < 330)
    {
        [_lblMinutesLeft setHidden:YES];
        [_lblSecondsLeft setHidden:YES];
        if (m_bFinished)
            [btn_park setBackgroundImage:[UIImage imageNamed:@"park_on_finished.png"] forState:UIControlStateNormal];
        else if (downCounter)
        {
            [btn_park setBackgroundImage:[UIImage imageNamed:@"park_on.png"] forState:UIControlStateNormal];
            [_lblMinutesLeft setHidden:NO];
            [_lblSecondsLeft setHidden:NO];
        }
        else
            [btn_park setBackgroundImage:[UIImage imageNamed:@"park_off.png"] forState:UIControlStateNormal];
        offsetY = 0;
        anchorState = AnchorMiddle;
    }
    else
    {
        [_lblMinutesLeft setHidden:YES];
        [_lblSecondsLeft setHidden:YES];
        if (m_bFinished)
            [btn_park setBackgroundImage:[UIImage imageNamed:@"park_on_finished.png"] forState:UIControlStateNormal];
        else if (downCounter)
        {
            [btn_park setBackgroundImage:[UIImage imageNamed:@"park_on.png"] forState:UIControlStateNormal];
            [_lblMinutesLeft setHidden:NO];
            [_lblSecondsLeft setHidden:NO];
        }
        else
            [btn_park setBackgroundImage:[UIImage imageNamed:@"park_off.png"] forState:UIControlStateNormal];
        anchorState = AnchorBelow;
        offsetY = 80;
    }
    
    [ UIView beginAnimations:nil context:(__bridge void*)touchView];
    [ UIView beginAnimations:nil context:(__bridge void*)btn_park];
    [ UIView beginAnimations:nil context:(__bridge void*)img_mask];
    [ UIView beginAnimations:nil context:(__bridge void*)img_background];
    [ UIView beginAnimations:nil context:(__bridge void*)_imgCounter];
    [ UIView beginAnimations:nil context:(__bridge void*)_img_bell];
    [ UIView beginAnimations:nil context:(__bridge void*)_lblMinutesLeft];
    [ UIView beginAnimations:nil context:(__bridge void*)_lblSecondsLeft];
    [ UIView beginAnimations:nil context:(__bridge void*)seg_measure];
    [ UIView beginAnimations:nil context:(__bridge void*)_lbl_minutes];
    [ UIView beginAnimations:nil context:(__bridge void*)_img_alarm];
    [ UIView beginAnimations:nil context:(__bridge void*)seg_bell];
    [ UIView beginAnimations:nil context:(__bridge void*)lbl_altitude];
    [ UIView beginAnimations:nil context:(__bridge void*)img_arrow];
    [ UIView beginAnimations:nil context:(__bridge void*)_img_waiter];
    [ UIView beginAnimations:nil context:(__bridge void*)lbl_distance];
    [ UIView beginAnimations:nil context:(__bridge void*)_btn_email];

    [touchView setFrame:CGRectMake(posArray[0].origin.x, posArray[0].origin.y + offsetY, posArray[0].size.width, posArray[0].size.height)];
    [btn_park setFrame:CGRectMake(posArray[1].origin.x, posArray[1].origin.y + offsetY, posArray[1].size.width, posArray[1].size.height)];
    [img_mask setFrame:CGRectMake(posArray[2].origin.x, posArray[2].origin.y + offsetY, posArray[2].size.width, posArray[2].size.height)];
    [img_background setFrame:CGRectMake(posArray[3].origin.x, posArray[3].origin.y + offsetY, posArray[3].size.width, posArray[3].size.height)];
    [_mapView setFrame:CGRectMake(posArray[4].origin.x, posArray[4].origin.y + offsetY, posArray[4].size.width, posArray[4].size.height - offsetY)];
    [_mapView ResizeMapView];
    _imgCounter.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, offsetY), imageAngle *  M_PI / 180);
    self.img_bell.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, offsetY), (imageAngle + APP->bellMin * 2) *  M_PI / 180);
    [_lblMinutesLeft setFrame:CGRectMake(posArray[5].origin.x, posArray[5].origin.y + offsetY, posArray[5].size.width, posArray[5].size.height)];
    [_lblSecondsLeft setFrame:CGRectMake(posArray[6].origin.x, posArray[6].origin.y + offsetY, posArray[6].size.width, posArray[6].size.height)];
    [seg_measure setFrame:CGRectMake(posArray[7].origin.x, posArray[7].origin.y + offsetY, posArray[7].size.width, posArray[7].size.height)];
    [_lbl_minutes setFrame:CGRectMake(posArray[8].origin.x, posArray[8].origin.y + offsetY, posArray[8].size.width, posArray[8].size.height)];
    [_img_alarm setFrame:CGRectMake(posArray[9].origin.x, posArray[9].origin.y + offsetY, posArray[9].size.width, posArray[9].size.height)];
    [seg_bell setFrame:CGRectMake(posArray[10].origin.x, posArray[10].origin.y + offsetY, posArray[10].size.width, posArray[10].size.height)];
    [lbl_altitude setFrame:CGRectMake(posArray[11].origin.x, posArray[11].origin.y + offsetY, posArray[11].size.width, posArray[11].size.height)];
    [img_arrow setFrame:CGRectMake(posArray[12].origin.x, posArray[12].origin.y + offsetY, posArray[12].size.width, posArray[12].size.height)];
    [lbl_distance setFrame:CGRectMake(posArray[13].origin.x, posArray[13].origin.y + offsetY, posArray[13].size.width, posArray[13].size.height)];
    _img_waiter.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, offsetY), m_waiterAngle *  M_PI / 180);
    [_btn_email setFrame:CGRectMake(posArray[14].origin.x, posArray[14].origin.y + offsetY, posArray[14].size.width, posArray[14].size.height)];

    [UIView commitAnimations];
}

-(void)ShowWaiter
{
    [self.view setUserInteractionEnabled:NO];
    [_img_waiter setHidden:FALSE];
    m_waiterAngle = 0;
    [_img_waiter setImage:[UIImage imageNamed:@"park_wait.png"]];
    m_waiterTimer = [NSTimer scheduledTimerWithTimeInterval:0.05f target:self selector:@selector(AnimateWaiter) userInfo:Nil repeats:YES];
}

-(void)AnimateWaiter
{
    [btn_park setBackgroundImage:[UIImage imageNamed:@"park_on.png"] forState:UIControlStateNormal];
    m_waiterAngle += 5;
    _img_waiter.transform = CGAffineTransformRotate(CGAffineTransformMakeTranslation(0, offsetY), m_waiterAngle *  M_PI / 180);
    if (m_waiterAngle > 360 * 5)
    {
        [self ShowLocationServiceWarning];
    }
}

-(void)HideWaiter
{
    [self.view setUserInteractionEnabled:YES];
    [_img_waiter setHidden:YES];
    [m_waiterTimer invalidate];
    m_waiterTimer = nil;
    [lbl_distance setHidden:FALSE];

    m_bSetPark = true;
    if (settingMin == 0)
    {
        [btn_park setBackgroundImage:[UIImage imageNamed:@"park_on_finished.png"] forState:UIControlStateNormal];
        [_lblMinutesLeft setHidden:YES];
        [_lblSecondsLeft setHidden:YES];
        m_bFinished = true;
    }
    else
    {
        [btn_park setBackgroundImage:[UIImage imageNamed:@"park_on.png"] forState:UIControlStateNormal];
        [_lblMinutesLeft setHidden:NO];
        [_lblSecondsLeft setHidden:NO];
        countingMin = settingMin;
        countingMin--;
        secCount = 60;
        downCounter = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(TimeCounter) userInfo:nil repeats:YES];
    }
}

-(void)ShowLocationServiceWarning
{
    [self.view setUserInteractionEnabled:YES];
    [_img_waiter setHidden:YES];
    [m_waiterTimer invalidate];
    m_waiterTimer = nil;
    [btn_park setBackgroundImage:[UIImage imageNamed:@"park_off.png"] forState:UIControlStateNormal];
    [[[UIAlertView alloc] initWithTitle:@"Location Services" message:@"Please turn on Location Service in the settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

-(IBAction)OnEmail
{
    if (!_mapView->m_userPin)
    {
        [[[UIAlertView alloc] initWithTitle:@"Location Services" message:@"Please turn on Location Service in the settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        
        mailer.mailComposeDelegate = self;
        
        [mailer setSubject:@"My location"];
        NSString* msg = @"Hi<br /><br />I'm sending you my location through the Park Assist app.<br /><br />I can be found at the link below<br /><br />";
        NSString* mapUrl = [NSString stringWithFormat:@"https://maps.google.com/maps?q=My Location @%f,%f", _mapView->m_userPin.coordinate.latitude, _mapView->m_userPin.coordinate.longitude];
        
        NSString* urlTextEscaped = [mapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        msg = [NSString stringWithFormat:@"%@%@", msg, urlTextEscaped];
        [mailer setMessageBody:msg isHTML:YES];
        
        [self presentViewController:mailer animated:YES completion:nil];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	switch (result)
	{
		case MFMailComposeResultCancelled:
			NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued");
			break;
		case MFMailComposeResultSaved:
			NSLog(@"Mail saved: you saved the email message in the Drafts folder");
			break;
		case MFMailComposeResultSent:
			NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send the next time the user connects to email");
			break;
		case MFMailComposeResultFailed:
			NSLog(@"Mail failed: the email message was nog saved or queued, possibly due to an error");
			break;
		default:
			NSLog(@"Mail not sent");
			break;
	}
    
	[self dismissViewControllerAnimated:NO completion:nil];
}
@end