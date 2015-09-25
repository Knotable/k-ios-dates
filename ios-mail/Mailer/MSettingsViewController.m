//
//  MSettingsViewController.m
//  Mailer
//
//  Created by Mac 7 on 30/01/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import "MSettingsViewController.h"
#import "MMailManager.h"
#import "MDataManager.h"
#import "Account.h"
#import "Message.h"
#import "Folder.h"
#import "Attachment.h"
#import "MFileManager.h"
@interface MSettingsViewController ()
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@end

@implementation MSettingsViewController

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
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"paper_clip.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    self.navigationItem.leftBarButtonItem = backButton;
    
    UIBarButtonItem *addBut = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAccountAndBack)];
    
    self.navigationItem.rightBarButtonItem = addBut;
    
//    //NSLog(@"listArray===%@",listArray);
    
}


-(void)addAccountAndBack{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewAccount" object:nil];
    
     [self.navigationController dismissViewControllerAnimated:NO completion:nil];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:_home name:@"NewAccount"  object:nil];

}

-(IBAction)backAction:(id)sender{
    
   
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    
//    [self.navigationController setToolbarHidden:YES animated:NO];
    
    
    //    MAppDelegate *delegate = (MAppDelegate *)[[UIApplication sharedApplication]delegate];
    //
    //    [self.navigationController popToViewController:delegate.homeView animated:YES];
    //    [self.navigationController popToRootViewControllerAnimated:YES];
    
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
    return [self.userArray count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
//        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    AccountInfo *actInfo = [self.userArray objectAtIndex:indexPath.row];
    cell.textLabel.text = actInfo.account.username;
    cell.textLabel.textColor = [UIColor blackColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:UITableViewRowAnimationFade];
    
    UIActionSheet *settingsAction = [[UIActionSheet alloc]initWithTitle:@"Mailable" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Logout", nil];
    settingsAction.tag = indexPath.row;
    
    [settingsAction showInView:self.view];
    
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        NSInteger indexTag = actionSheet.tag;
        if (indexTag>=[self.userArray count]) {
            return;
        }

        AccountInfo* actInfo = [self.userArray objectAtIndex:indexTag];
        if (!self.spinner) {
            self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            self.spinner.color = [UIColor blackColor];
        }
        self.spinner.center = userTableVw.center;
        [self.spinner startAnimating];
        [userTableVw addSubview:self.spinner];
        userTableVw.userInteractionEnabled = NO;
    
            [[MMailManager sharedManager] logout:actInfo completion:^(BOOL success, NSString *msg, NSError *error) {
            [self.userArray removeObjectAtIndex:actionSheet.tag];
            [userTableVw reloadData];
            [self.spinner stopAnimating];
            [self.spinner removeFromSuperview];
            self.spinner = nil;
            userTableVw.userInteractionEnabled = YES;
        }];


    }
}

@end
