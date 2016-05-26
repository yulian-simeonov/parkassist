//
//  HistoryViewController.m
//  parkassist
//
//  Created by     on 11/6/13.
//  Copyright (c) 2013 RUHE. All rights reserved.
//

#import "HistoryViewController.h"
#import "AppDelegate.h"
#import "HIstoryMapViewController.h"
#import "HistoryCell.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 60;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return APP->m_history.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString* strCellId = [NSString stringWithFormat:@"cell%d", indexPath.row];
    
    HistoryCell* cell = [tableView dequeueReusableCellWithIdentifier:strCellId];
    if (!cell)
    {
        NSArray* xib = [[NSBundle mainBundle] loadNibNamed:@"HistoryCell" owner:Nil options:nil];
        cell = (HistoryCell*)[xib objectAtIndex:0];
    }
    
    NSDictionary* dic = [APP->m_history objectAtIndex:APP->m_history.count - indexPath.row - 1];
    cell.lbl_address.text = [dic objectForKey:@"address"];
    cell.lbl_date.text = [dic objectForKey:@"time"];
    
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    HIstoryMapViewController* vw = (HIstoryMapViewController*)[[UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil] instantiateViewControllerWithIdentifier:@"sb_history_map"];
//    vw->m_data = [APP->m_history objectAtIndex:indexPath.row];
//    [self.navigationController pushViewController:vw animated:YES];
}

-(IBAction)OnClear:(id)sender
{
    [[[UIAlertView alloc] initWithTitle:@"" message:@"Are you sure you want to clear the entire history?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex != buttonIndex)
    {
        [APP->m_history removeAllObjects];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"history"];
        [NSUserDefaults resetStandardUserDefaults];
        [m_table reloadData];
    }
}
@end
