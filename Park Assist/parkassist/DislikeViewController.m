//
//  DislikeViewController.m
//  parkassist
//
//  Created by     on 11/3/13.
//  Copyright (c) 2013 RUHE. All rights reserved.
//

#import "DislikeViewController.h"
#import "HelpViewController.h"

@interface DislikeViewController ()

@end

@implementation DislikeViewController

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
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)OnClose:(id)sender
{
    HelpViewController* helpVw = [self.navigationController.viewControllers objectAtIndex:2];
    [self.navigationController popToViewController:helpVw animated:YES];
}
@end
