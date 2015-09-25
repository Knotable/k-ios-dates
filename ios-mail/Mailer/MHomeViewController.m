//
//  MHomeViewController.m
//  Mailer
//
//  Created by Mac 7 on 21/01/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import "MHomeViewController.h"
#import "MControllerManager.h"
#import "MAppDelegate.h"
#import "MMailManager.h"
#import "Account.h"
#import "MDataManager.h"
#import "MDesignManager.h"
#import "MSettingsViewController.h"
#import "MTutorialViewController.h"
#import "AccountInfo.h"
#import "MSwipedButtonManager.h"
#import "Debug.h"

@interface MHomeViewController ()<FPPopoverControllerDelegate>
@property (nonatomic, strong) FPPopoverController *popover;
@property (nonatomic, assign) BOOL popoverShow;

@end

@implementation MHomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        MAppDelegate *delegate = (MAppDelegate *) [[UIApplication sharedApplication]delegate];
        delegate.parentViewCntrllr = self;
    }
    return self;
}
-(void)awakeFromNib
{
    MAppDelegate *delegate = (MAppDelegate *) [[UIApplication sharedApplication]delegate];
    delegate.parentViewCntrllr = self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.navigationItem setHidesBackButton:YES animated:YES];
    
//    UIEdgeInsets inset = UIEdgeInsetsMake(20, 0, 0, 0);
//    listtableView.contentInset = inset;
    self.navigationController.toolbar.hidden = YES;
    
    listtableView.contentInset = UIEdgeInsetsMake(-36, 0, 0, 0);

    
    UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings.png"] style:UIBarButtonItemStylePlain target:self action:@selector(settingsAction:)];
    self.navigationItem.leftBarButtonItem = settings;
    
    UIButton *kLogoButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [kLogoButton setImage:[UIImage imageNamed:@"kLogo.png"] forState:UIControlStateNormal];
    
    [kLogoButton addTarget:self action:@selector(kButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [kLogoButton sizeToFit];
    
//    UIBarButtonItem *kLogoBarButton = [[UIBarButtonItem alloc] initWithCustomView:kLogoButton];
//    
//    self.navigationItem.rightBarButtonItem = kLogoBarButton;
    
    UIBarButtonItem *addBut = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addAccount)];
    
    self.navigationItem.rightBarButtonItem = addBut;
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gettingUsers) name:@"ReloadHomeList" object:nil];
    
    [self gettingUsers];

    //first comming need into inbox
    for (int i = 0; i<[[MMailManager sharedManager].allAccount count]; i++) {
        AccountInfo *actInfo = [[MMailManager sharedManager].allAccount objectAtIndex:i];
        [actInfo.cell setNewEmailHidden:YES];
        actInfo.showNewEmail = NO;
        
    }
    [MMailManager sharedManager].currentFetType = FetchCurrent;
//    [self performSelector:@selector(showListDelay) withObject:nil afterDelay:1.];
}
-(void)showListDelay
{
    [self.navigationController pushViewController:(UIViewController *)[[MControllerManager sharedManager] setupAllInbox] animated:NO];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[MSwipedButtonManager sharedManager] setHidden:YES];
    [MSwipedButtonManager sharedManager].delegate = nil;

//    UIEdgeInsets inset = UIEdgeInsetsMake(10, 0, 0, 0);
//    listtableView.contentInset = inset;
//    
//    [listtableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
//    [listtableView reloadData];
    
    CGFloat verticalOffset = -4.0f;
    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:verticalOffset forBarMetrics:UIBarMetricsDefault];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults boolForKey:@"IsLogin"]) {
        
         [self.navigationController popToRootViewControllerAnimated:YES];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:nil forKey:@"LastSelectedAccount"];
        [defaults synchronize];
       
    }
    else{
        
     
    if ([defaults integerForKey:@"selectedIndex"] > 0) {
        
        NSInteger selection = [defaults integerForKey:@"selectedIndex"];
        
//        NSLog(@"selection = %d",selection);
        
        switch (selection) {
            case kAllAccountIndex:
            {
                [MMailManager sharedManager].currentFetType = FetchAll;
                NSIndexPath *defaultIndexPath = [NSIndexPath indexPathForRow:[[MMailManager sharedManager].allAccount count] inSection:0];
                
//                [listtableView.delegate tableView:listtableView didSelectRowAtIndexPath:defaultIndexPath];
                
                [listtableView selectRowAtIndexPath:defaultIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
                break;
                
            default:{
                [MMailManager sharedManager].currentFetType = FetchCurrent;

                NSIndexPath *defaultIndexPath = [NSIndexPath indexPathForRow:selection-1 inSection:0];
                
                [listtableView selectRowAtIndexPath:defaultIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
                
                
//                NSString *indexStr = [NSString stringWithFormat:@"%d",defaultIndexPath.row];
                
//                [self performSelector:@selector(loadDetaliPage:) withObject:indexStr  afterDelay:0];
                
//                [listtableView.delegate tableView:listtableView didSelectRowAtIndexPath:defaultIndexPath];
                
                
            }
                
                break;
        }
        
    }
        
    else{
        [MMailManager sharedManager].currentFetType = FetchAll;
        [defaults setInteger:kAllAccountIndex forKey:@"selectedIndex"];
        [defaults synchronize];
        
        NSIndexPath *defaultIndexPath = [NSIndexPath indexPathForRow:[[MMailManager sharedManager].allAccount count] inSection:0];
        
        [listtableView selectRowAtIndexPath:defaultIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        
    }
    }
    
     [listtableView reloadData];
    
//    [defaults setInteger:0 forKey:@"selectedIndex"];
    
   
    
    
//    [listtableView didSelectRowAtIndexPath:defaultIndexPath];
    
   
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    if([spinner isDescendantOfView:[self view]]) {
        
//        NSLog(@"Present");
        
        [spinner stopAnimating];
        [spinner removeFromSuperview];
    }
    
}

-(IBAction)kButtonAction:(id)sender{
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mailable" message:@"Need clarification!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
    [alert show];
    
//    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://alpha.knotable.com/login"]];
    
}

-(void)gettingUsers
{
    NSArray *_allAccounts = [[MMailManager sharedManager].allAccount copy];

    if ([_allAccounts count]==1) {
        AccountInfo *accnt = [_allAccounts objectAtIndex:0];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:accnt.account.username forKey:@"LastSelectedAccount"];
        [defaults synchronize];
    }
}

#pragma mark - UIBarButtonAction

-(void)addAccount{
    
     [self.navigationController popToRootViewControllerAnimated:YES];
    
}
- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController
{
    self.popoverShow = NO;
}
- (void)handleBtnLongPressgesture:(UILongPressGestureRecognizer *)recognizer{
    if (!self.popoverShow) {
        self.popoverShow = YES;
        //the controller we want to present as a popover
        DemoTableController *controller = [[DemoTableController alloc] initWithStyle:UITableViewStylePlain];
        self.popover = [[FPPopoverController alloc] initWithViewController:controller];
        //popover.arrowDirection = FPPopoverArrowDirectionAny;
        self.popover.tint = FPPopoverDefaultTint;
        self.popover.contentSize = CGSizeMake(260, 300);

        self.popover.arrowDirection = FPPopoverArrowDirectionAny;
        //sender is the UIButton view
        NSLog(@">>>>>>>>>>>>>>>");
        self.popover.delegate = self;
        [self.popover presentPopoverFromView:recognizer.view];
    }

    return;
}
#pragma mark - UIActionSheet Delegate

-(void)settingsAction:(id) sender {

    [[MMailManager sharedManager] stopFetchingMail];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(addAccount) name:@"NewAccount" object:nil];
    
    [self performSegueWithIdentifier:@"goToSettings" sender:[MMailManager sharedManager].allAccount];
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0) {
        
        Account* account =  [[MMailManager sharedManager] getCurrentAccount];
        account.status = NO;
        
        [[MMailManager sharedManager] stopFetchingMail];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:NO forKey:@"IsLogin"];
        [defaults synchronize];
        [self.navigationController popToRootViewControllerAnimated:YES];

    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger cellCount = 0;
    switch (section) {
        case 0:{
            if ([[[MMailManager sharedManager] allAccount] count]) {
                 cellCount = [[[MMailManager sharedManager] allAccount] count]+1;
            }
            else{
                cellCount = 0;
            }
        }
           
            break;
            
        default:
            cellCount = 9;
            break;
    }
    return cellCount;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    MAccountViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        
        cell = [[MAccountViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] ;
        
    }
    
    
//    UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(0, cell.contentView.frame.size.height-2, cell.contentView.frame.size.width, 0.5)];
//    seperatorView.backgroundColor = [UIColor whiteColor];
//    [cell.contentView addSubview:seperatorView];

    cell.textLabel.textColor = [UIColor blackColor];
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    
    
    switch (indexPath.section) {
        case 0:
        {
            if ([[MMailManager sharedManager].allAccount count]-1 < indexPath.row) {
                
                cell.textLabel.text = @"All Accounts";
                return cell;
            }
            AccountInfo *actInfo =  [[MMailManager sharedManager].allAccount objectAtIndex:indexPath.row];
            cell.textLabel.text = actInfo.account.username;
            [cell setNewEmailHidden:!actInfo.showNewEmail];
            actInfo.cell = cell;
//            cell.accessoryType = UITableViewCellAccessoryNone;
            
        }
            break;
            
        default:
            [cell setNewEmailHidden:YES];

            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILongPressGestureRecognizer *btn_LongPress_gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleBtnLongPressgesture:)];
            [cell addGestureRecognizer:btn_LongPress_gesture];
            switch (indexPath.row) {
                
                case 1:
                    cell.textLabel.text = @"Short Mail";
                    break;
                case 2:
                    cell.textLabel.text = @"Long Mail";
                    break;
                case 3:
                    cell.textLabel.text = @"Pictures";
                    break;
                case 4:
                    cell.textLabel.text = @"Files";
                    break;
                case 5:
                    cell.textLabel.text = @"People";
                    break;
                
                case 0:
                {
                    cell.textLabel.text = @"Inbox";
      
                    
//                    UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(15, cell.contentView.frame.size.height-4, cell.contentView.frame.size.width-15, 0.5)];
//                    
//                    seperatorView.backgroundColor = listtableView.separatorColor;
//                    [cell.contentView addSubview:seperatorView];
//                    
//                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                    
                    break;
                    
                case 6:
                    cell.textLabel.text = @"Knotes";
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                    
                case 7:
                    cell.textLabel.text = @"Tutorial";
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                case 8:
                    cell.textLabel.text = @"Log View";
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    break;
                default:
                    break;
            }
            
            

            break;
    }
    
    return cell;
}

#pragma mark - UITableView Header

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    
//    if (section == 0) {
//        
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0,10,tableView.frame.size.width,30)] ;
//    
//    UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setTitle:@"Inbox" forState:UIControlStateNormal];
//    btn.tintColor = [UIColor whiteColor];
//        
//    //Setting button text to left
//    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    btn.contentEdgeInsets = UIEdgeInsetsMake(0, 13, 0, 0);
//        
//    btn.backgroundColor = [UIColor clearColor];
//    [btn setFrame:CGRectMake(0, 0, tableView.frame.size.width, 30)];
//    [headerView addSubview:btn];
//    [btn addTarget:self action:@selector(allInboxAction:) forControlEvents:UIControlEventTouchDown];
//        
//        
//    UIView *seperatorView = [[UIView alloc] initWithFrame:CGRectMake(15, 30, tableView.frame.size.width-15, 0.5)];
//    
//    seperatorView.backgroundColor = listtableView.separatorColor;
//    [headerView addSubview:seperatorView];
//        
//    return headerView;
//        
//    }
//    
//    return nil;
//    
//}
//
//-(float)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    
//   if (section == 0) {
//    
//       return  30.0;
//     }
//    
//    return 0.0;
//}

#pragma mark - UITableView Did Select

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    [tableView deselectRowAtIndexPath:indexPath animated:UITableViewRowAnimationFade];
//    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
//    spinner.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2));
//    [self.view addSubview:spinner];
//    [spinner startAnimating];
    BIDERROR("home didSelectRowAtIndexPath:row=%ld,section:%ld",indexPath.row,(long)indexPath.section);

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

        switch (indexPath.section) {
            
            case 0:{
                
                if ([[[MMailManager sharedManager] allAccount] count]-1 < indexPath.row) {
                   
                    [defaults setInteger:kAllAccountIndex forKey:@"selectedIndex"];
                    [defaults synchronize];
                    
                    break;
                }
                
                [defaults setInteger:indexPath.row+1 forKey:@"selectedIndex"];
                
                [defaults synchronize];
                
                
//                [defaults setInteger:indexPath.row+1 forKey:@"selectedIndex"];
//                [defaults synchronize];
                
                
//        NSLog(@"************** Assign  dispatch_async ***************");
//                NSInteger *indexPath = indexPath.row ;
                
//                NSString *indexStr = [NSString stringWithFormat:@"%d",indexPath.row];
//                
//                [self performSelector:@selector(loadDetaliPage:) withObject:indexStr  afterDelay:0];
                
//                dispatch_async(dispatch_queue_create("myqueue2", 0), ^{
//                
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        
//                        [[MControllerManager sharedManager] showFirstControllerFrom:self];
//
//                    });
//                    
//                });
                
            }
                
            break;
            
        default:
            [tableView deselectRowAtIndexPath:indexPath animated:UITableViewRowAnimationFade];
            switch (indexPath.row) {
                
                case 1:
                    [[MControllerManager sharedManager] showSecondControllerFrom:self];
                    break;
                    
                case 2:
                    [[MControllerManager sharedManager] showThirdControllerFrom:self];
                    break;
                    
                case 3:
                    [[MControllerManager sharedManager] showFourthControllerFrom:self];
                    break;
                    
                case 4:
                    [[MControllerManager sharedManager] showFifthControllerFrom:self];
                    break;
                    
                case 5:
                    [[MControllerManager sharedManager] showSixthControllerFrom:self];
                    
                    break;
                    
                case 0:{
                    
                    switch ([defaults integerForKey:@"selectedIndex"]) {
                        case kAllAccountIndex:
                            for (int i = 0; i<[[MMailManager sharedManager].allAccount count]; i++) {
                                AccountInfo *actInfo = [[MMailManager sharedManager].allAccount objectAtIndex:i];
                                [actInfo.cell setNewEmailHidden:YES];
                                actInfo.showNewEmail = NO;

                            }
                            [MMailManager sharedManager].currentFetType = FetchCurrent;
                            [[MControllerManager sharedManager] showSeventhControllerFrom:self];
                            break;
                            
                        default:
                            
                            if ([defaults integerForKey:@"selectedIndex"] > 0) {
                                
                                NSString *indexStr = [NSString stringWithFormat:@"%ld",(long)[defaults integerForKey:@"selectedIndex"]-1];
                                
//                                [self loadDetaliPage:indexStr];
                                NSInteger indexAct = [indexStr integerValue];
                                if (indexAct < [[MMailManager sharedManager].allAccount count]) {
                                    AccountInfo *actInfo = [[[MMailManager sharedManager] allAccount] objectAtIndex:indexAct];
                                    [actInfo.cell setNewEmailHidden:YES];
                                    actInfo.showNewEmail = NO;
                                }
                                [MMailManager sharedManager].currentFetType = FetchCurrent;

                                [self performSelector:@selector(loadDetaliPage:) withObject:indexStr  afterDelay:0];
                                
//                                [[MControllerManager sharedManager] showFirstControllerFrom:self];
                            }
                            else{
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select an inbox" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
                                [alert show];
                            }
                            
                            break;
                    }
 
                }
                    break;
                    
                case 6:
                    [self performSegueWithIdentifier:@"goingToKnotes" sender:self];
                     [tableView deselectRowAtIndexPath:indexPath animated:UITableViewRowAnimationFade];
                    break;
                case 8:
                    [self performSegueWithIdentifier:@"showLogView" sender:self];
                    [tableView deselectRowAtIndexPath:indexPath animated:UITableViewRowAnimationFade];
                    break;
                default:
                    //7
                    [self performSegueWithIdentifier:@"GoingToTutorial" sender:self];
                     [tableView deselectRowAtIndexPath:indexPath animated:UITableViewRowAnimationFade];
                    break;
            }
            
            break;
    }
    
    [defaults synchronize];
    
}


-(IBAction)allInboxAction:(id)sender{
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    switch (selectedIndex) {
        case 10:
            [[MControllerManager sharedManager] showSeventhControllerFrom:self];
            break;
            
        case 20:
             [[MControllerManager sharedManager] showFirstControllerFrom:self];
            break;
            
        default:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select an inbox" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [alert show];
            
//            [defaults setInteger:0 forKey:@"selectedIndex"];
        }
            break;
    }
    
//    [defaults synchronize];
    
//    [self performSegueWithIdentifier:@"moveToAllBoxes" sender:self];
    
}

-(void)loadDetaliPage : (NSString *)indexPathStr{
    
    int indexPath = [indexPathStr intValue];
    if (indexPath >= [[MMailManager sharedManager].allAccount count]) {
        indexPath = 0;
    }
    [MMailManager sharedManager].currentAccoutIndex = indexPath;
    
    [[MMailManager sharedManager] stopFetchingMail];
    [[MDataManager sharedManager] saveContextAsync];
    
    Account *testAccount =  [[MMailManager sharedManager] getCurrentAccount];
    
    MAppDelegate *delegate = (MAppDelegate *) [[UIApplication sharedApplication]delegate];
    delegate.isChangeLogin = NO;
    
    AccountInfo* actInfo = [[MMailManager sharedManager].allAccount objectAtIndex:indexPath];
//    [Account selectedUser:[_userListArray objectAtIndex:indexPath]];
    
//    NSLog(@"account=%@",account);
    
    if(actInfo){
        
        [MMailManager sharedManager].currentAccoutIndex = indexPath;
        
        if (testAccount != actInfo.account) {
            delegate.isChangeLogin = YES;
        }
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        AccountInfo *actInfo = [[MMailManager sharedManager].allAccount objectAtIndex:indexPath];
        [defaults setValue:actInfo.account.username forKey:@"Username"];
        [defaults setValue:actInfo.account.username forKey:@"LastSelectedAccount"];
        
//        [self performSelectorOnMainThread:@selector(fetchMail) withObject:nil waitUntilDone:YES];
        
        dispatch_async(dispatch_queue_create("myqueue2", 0), ^{
        
           [[MMailManager sharedManager] beginFetchingMail];
            
            dispatch_async(dispatch_get_main_queue(), ^{

                    });
                });
        
        [defaults setInteger:indexPath+1 forKey:@"selectedIndex"];
        
        [defaults synchronize];
        
        [[MControllerManager sharedManager] showFirstControllerFrom:self];
        
        //NSLog(@"[MMailManager sharedManager].currentAccount  = %@",[MMailManager sharedManager].currentAccount );
        //NSLog(@"[MMailManager sharedManager].currentFolder  = %@",[MMailManager sharedManager].currentFolder );
        
    }
    
}

-(void)fetchMail{
    
    [[MMailManager sharedManager] beginFetchingMail];
}

- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
{
    NSLog(@"unwindToThisViewController");
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    if ([segue.identifier isEqualToString:@"goToSettings"]) {
        
        UINavigationController *replyNavController = (UINavigationController *)segue.destinationViewController;
        
        replyNavController.view.tintColor = [MDesignManager tintColor];
        replyNavController.navigationBar.barTintColor = [MDesignManager tintColor];
        replyNavController.navigationBar.tintColor = [MDesignManager highlightColor];
        replyNavController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[MDesignManager highlightColor]};
        
        MSettingsViewController *setngController = (MSettingsViewController *)replyNavController.topViewController;
        setngController.userArray = sender;
        
    }
    else if ([segue.identifier isEqualToString:@"goingToKnotes"]) {
        
        UINavigationController *replyNavController = (UINavigationController *)segue.destinationViewController;
        
        replyNavController.view.tintColor = [MDesignManager tintColor];
        replyNavController.navigationBar.barTintColor = [MDesignManager tintColor];
        replyNavController.navigationBar.tintColor = [MDesignManager highlightColor];
        replyNavController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName:[MDesignManager highlightColor]};
        
    }
    
}

@end
