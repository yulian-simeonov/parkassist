//
//  SuggestionViewController.m
//  parkassist
//
//  Created by     on 11/3/13.
//  Copyright (c) 2013 RUHE. All rights reserved.
//

#import "SuggestionViewController.h"
#import "XMLReader.h"

@interface SuggestionViewController ()

@end

@implementation SuggestionViewController

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
    self.navigationController.navigationBarHidden = NO;
    
    [txt_content becomeFirstResponder];
    [txt_content.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [txt_content.layer setBorderWidth:0];
    
    //The rounded corner part, where you specify your view's corner radius:
    txt_content.layer.cornerRadius = 5;
    txt_content.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)OnSubmit
{
    [txt_email resignFirstResponder];
    [txt_content resignFirstResponder];
    
    if (txt_content.text.length < 1)
    {
        UIAlertView* alertVw = [[UIAlertView alloc] initWithTitle:@"No feedback" message:@"Please enter your feedback" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alertVw.tag = 0;
        [alertVw show];
        return;
    }
    
    if (![self IsValidEmail:txt_email.text] && txt_email.text.length > 0)
    {
        UIAlertView* alertVw = [[UIAlertView alloc] initWithTitle:@"Invalid email" message:@"Please enter a valid address" delegate:self cancelButtonTitle:@"Try again" otherButtonTitles:nil];
        alertVw.tag = 1;
        [alertVw show];
        return;
    }
    [JSWaiter ShowWaiter:self title:@"Submiting" type:0];
    [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(SendFeedback) userInfo:nil repeats:NO];
}

-(IBAction)OnLike:(id)sender
{
    str_feedback = @"I like it";
    [self OnSubmit];
}

-(IBAction)OnDislike:(id)sender
{
    str_feedback = @"I don't like it";
    [self OnSubmit];
}

-(void)SendFeedback
{
    JSWebManager* webMgr = [[JSWebManager alloc] initWithAsyncOption:NO];
    [webMgr SubmitFeedback:[NSString stringWithFormat:@"%@\n%@", str_feedback, txt_content.text] email:txt_email.text];
    [JSWaiter HideWaiter];

    if ([str_feedback isEqualToString:@"I like it"])
        [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"sb_like"] animated:YES];
    else
        [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"sb_dislike"] animated:YES];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
    if (touch.view == self.view)
    {
        [txt_email resignFirstResponder];
        [txt_content resignFirstResponder];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 0)
        [txt_content becomeFirstResponder];
    else if (alertView.tag == 1)
        [txt_email becomeFirstResponder];
}

-(BOOL)IsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [txt_email resignFirstResponder];
    return true;
}
@end
