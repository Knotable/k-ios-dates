//
//  MAllInboxViewController.m
//  Mailer
//
//  Created by Mac 7 on 28/03/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import "MAllInboxViewController.h"
#import "MInboxDetailViewController.h"
#import "MDesignManager.h"

@interface MAllInboxViewController ()

@end

@implementation MAllInboxViewController

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

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return 7;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
            switch (indexPath.row) {
                    
                case 0:
                    cell.textLabel.text = @"Social";
                    break;
                    
                case 1:
                    cell.textLabel.text = @"Promotions";
                    break;
                    
                case 2:
                    cell.textLabel.text = @"Flagged";
                    break;
                    
                case 3:
                    cell.textLabel.text = @"Drafts";
                    break;
                    
                case 4:
                    cell.textLabel.text = @"Sent";
                    break;
                    
                case 5:
                    cell.textLabel.text = @"Junk";
                    break;
                    
                case 6:
                    cell.textLabel.text = @"Trash";
                    break;
                    
                case 7:
                    cell.textLabel.text = @"All mail";
                    break;
                    
                default:
                    break;
            }
    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    [self performSegueWithIdentifier:@"MovingToInboxDetail" sender:self];
    
//    [tableView deselectRowAtIndexPath:indexPath animated:UITableViewRowAnimationFade];

    
}
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
//    if ([segue.identifier isEqualToString:@"MovingToInboxDetail"]) {
    
         NSIndexPath *indexPath = [_inxoxListTableVw indexPathForSelectedRow];
        
        UITableViewCell *cell = [_inxoxListTableVw cellForRowAtIndexPath:indexPath];
        
        NSString *textStr = cell.textLabel.text;
    
        NSLog(@"textStr =%@",textStr);

//        UINavigationController *replyNavController = (UINavigationController *)segue.destinationViewController;
//        
//        replyNavController.view.tintColor = [MDesignManager tintColor];
//        replyNavController.navigationBar.barTintColor = [MDesignManager tintColor];
//        replyNavController.navigationBar.tintColor = [MDesignManager highlightColor];
//        replyNavController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[MDesignManager highlightColor]};
//        
//        MInboxDetailViewController *detailController = (MInboxDetailViewController *)replyNavController.topViewController;

        
        MInboxDetailViewController *detailController = [segue destinationViewController];
        detailController.titleStr = textStr;
//
////    }
}


@end
