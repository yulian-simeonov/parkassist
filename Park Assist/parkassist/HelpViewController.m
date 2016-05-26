//
//  HelpViewController.m
//  parkassist
//
//  Created by     on 11/3/13.
//  Copyright (c) 2013 RUHE. All rights reserved.
//

#import "HelpViewController.h"
#import "SuggestionViewController.h"

@implementation HelpViewController

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Park Assist" style:UIBarButtonItemStylePlain target:self action:@selector(OnBack)];
}

-(void)OnBack
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"test"];
    switch (indexPath.row) {
        case 0:
            [cell.textLabel setText:@"About"];
            break;
        case 1:
            [cell.textLabel setText:@"Parking History"];
            break;
        case 2:
            [cell.textLabel setText:@"Original trackOmeter App"];
            break;
        case 3:
            [cell.textLabel setText:@"Website"];
            break;
        case 4:
            [cell.textLabel setText:@"Help"];
            break;
        case 5:
            [cell.textLabel setText:@"Feedback"];
            break;
        default:
            break;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:22.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
            [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"sb_about"] animated:YES];
            break;
        case 1:
            [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"sb_history"] animated:YES];
            break;
        case 2:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://itunes.apple.com/au/app/gps-tracker-trackometer/id540159351?mt=8"]];
            break;
        case 3:
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.trackometer.net"]];
            break;
        case 4:
            tutVw = (TutorialViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"sb_tutorial"];
            tutVw->m_bFromHelp = YES;
            [self.navigationController pushViewController:tutVw animated:YES];
            break;
        case 5:
            [self.navigationController pushViewController:[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"sb_suggestion"] animated:YES];
            break;
        default:
            break;
    }
}

-(void)SendEmail
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
        mailer.mailComposeDelegate = self;
        [mailer setSubject:@"Park Assist Suggestions"];
        [mailer setToRecipients:[NSArray arrayWithObjects:@"parkassistapp@trackometer.net", nil]];
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
