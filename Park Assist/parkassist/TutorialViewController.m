//
//  HelpViewController.m
//  parkassist
//
//  Created by     on 10/27/13.
//  Copyright (c) 2013 RUHE. All rights reserved.
//

#import "TutorialViewController.h"
#import "AppDelegate.h"
#import "ParkAssistViewController.h"

@implementation TutorialViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        m_bFromHelp = false;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    [_scrollVw setContentSize:CGSizeMake(_scrollVw.frame.size.width * 4, _scrollVw.contentSize.height)];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"SetTutorial"] boolValue] && !m_bFromHelp)
    {
        [self ShowMainViewController:NO];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger pageIndex = round(scrollView.contentOffset.x / scrollView.bounds.size.width);
    if (scrollView.contentOffset.x / scrollView.frame.size.width >= 3.3f)
    {
        if (m_bFromHelp)
            [self Back];
        else
            [self ShowMainViewController:YES];
    }
    else if (scrollView.contentOffset.x / scrollView.frame.size.width <= -0.2f)
    {
        [self Back];
    }
    if (_pageCtrl.currentPage != pageIndex)
        _pageCtrl.currentPage = pageIndex;
}

-(void)ShowMainViewController:(BOOL)animation
{
    ParkAssistViewController* mainVw = (ParkAssistViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"sb_park_assist"];
    [self.navigationController pushViewController:mainVw animated:animation];
}

-(void)Back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)OnClose:(id)sender
{
    if (m_bFromHelp)
        [self Back];
    else
        [self ShowMainViewController:YES];
}
@end
