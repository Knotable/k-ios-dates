//
//  MSignInViewController.m
//  Mailer
//
//  Created by Martin Ceperley on 9/30/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MSignInViewController.h"
#import "MMailManager.h"
#import "MDataManager.h"
#import "AccountInfo.h"
#import "Account.h"
#import "TestFlight.h"
#import "MControllerManager.h"
#import "MHomeViewController.h"
@interface MSignInViewController ()

@end

@implementation MSignInViewController

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
    UIColor *color = [UIColor lightGrayColor];
    self.usernameField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Username or email address" attributes:@{NSForegroundColorAttributeName: color}];
    self.passwordField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"Password" attributes:@{NSForegroundColorAttributeName: color}];
    
    //Modified by 3E ------START------
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
//        NSLog(@"I'm definitely an iPad");
        
        [_mailerLab setFont:[UIFont boldSystemFontOfSize:80]];
    }
    
    //Modified by 3E ------END------
    
//    Account* account = [MMailManager sharedManager].currentAccount;
//    
//    if (account) {
//        self.usernameField.text = account.username;
//        self.passwordField.text = account.password;
//        [self updateSignInEnabled];
//    }
   
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [[MMailManager sharedManager] stopFetchingMail];
    
    self.navigationItem.leftBarButtonItem = nil;
    
//     [MMailManager sharedManager].currentAccount = Nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL checkLogin = [defaults boolForKey:@"IsLogin"] ;
    
    NSLog(@"checkLogin= %d",checkLogin);
    
    if (checkLogin) {
        
        UIBarButtonItem *settings = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"paper_clip.png"] style:UIBarButtonItemStylePlain target:self action:@selector(HomeAction)];
        self.navigationItem.leftBarButtonItem = settings;
    }

}

-(void)HomeAction{
    
     [self performSegueWithIdentifier:@"showHome" sender:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) didEnterText:(id) sender
{
//    NSLog(@"didEnterText");
}

-(void)updateSignInEnabled
{
    [self updateSignInEnabledUsername:self.usernameField.text password:self.passwordField.text];
}

-(void)updateSignInEnabledUsername:(NSString *)username password:(NSString *)password
{
    BOOL signInEnbaled = username.length > 0 && password.length > 0;
    if(signInEnbaled != self.signInButton.enabled){
        [self.signInButton setEnabled:signInEnbaled];
    }
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *username = self.usernameField.text;
    NSString *password = self.passwordField.text;
    
    if(textField == self.usernameField){
        username = newString;
    } else if(textField == self.passwordField){
        password = newString;
    }
    
    [self updateSignInEnabledUsername:username password:password];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if(textField == self.usernameField){
        
        NSString* username = self.usernameField.text;
        if([[username componentsSeparatedByString:@"@"] count] == 1){
            
            username = [username stringByAppendingString:@"@gmail.com"];
            self.usernameField.text = username;
        };
    }

}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    
    if(nextResponder){
        [nextResponder becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
        [self signIn:self];
    }
    return NO;
}

-(IBAction) signIn:(id)sender
{
    
//    NSLog(@"signIn");
    [self.activityIndicator startAnimating];
    [self.signInButton setEnabled:NO];
    [self.usernameField setEnabled:NO];
    [self.passwordField setEnabled:NO];
    [self.signInButton setTitle:@"Signing in.." forState:UIControlStateDisabled];
    
    NSString* username = self.usernameField.text;
    NSString* password = self.passwordField.text;
    
    AccountInfo * actInfo = [[MMailManager sharedManager] connectGmailWithUsername:username password:password];
    
    [[MMailManager sharedManager] checkAccount:actInfo Success:^(void) {
        NSLog(@"success testing credentials");
        
        //Checking account availability
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"username = %@",username];
        NSPredicate* predicate2 = [NSPredicate predicateWithFormat:@"status = YES"];
        Account *account = [Account MR_findFirstWithPredicate:predicate];
        
        if (account) {
            
            if (account.status) {
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Mailable" message:@"User already exists!" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
                [alert show];
            
            } else {
                
                account.status = YES;
                account.lastLoggedIn = [NSDate date];
                actInfo.account = account;
                [Account setAccount:account WithUsername:username password:password];
                
                //Reload Home List View
                
                NSLog(@"Account count: %lu", (unsigned long)[Account countOfEntitiesWithPredicate:predicate2]);
                
                if ([Account countOfEntitiesWithPredicate:predicate2] > 1) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadHomeList" object:nil];
                }
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                MHomeViewController *homeVc = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
                [self.navigationController pushViewController:homeVc animated:NO];
                MMessageListController *listVc = [[MControllerManager sharedManager] setupAllInbox];
                [homeVc.navigationController pushViewController:(UIViewController *)listVc animated:YES];

                self.usernameField.text = @"";
                self.passwordField.text = @"";
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setBool:YES forKey:@"IsLogin"];
                [defaults setValue:username forKey:@"Username"];
                [defaults synchronize];

            }
           
        } else {
            
            // Adding New Account
            
            Account* account = [Account gmailAccountWithUsername:username password:password];
            actInfo.account = account;
            
            NSLog(@"Account count: %lu", (unsigned long)[Account countOfEntities]);
            
            if ([Account countOfEntitiesWithPredicate:predicate2] > 1) {
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadHomeList" object:nil];
                
            }
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MHomeViewController *homeVc = [storyboard instantiateViewControllerWithIdentifier:@"HomeViewController"];
            [self.navigationController pushViewController:homeVc animated:NO];
            MMessageListController *listVc = [[MControllerManager sharedManager] setupAllInbox];
            [homeVc.navigationController pushViewController:(UIViewController *)listVc animated:YES];

            
            self.usernameField.text = @"";
            self.passwordField.text = @"";
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:YES forKey:@"IsLogin"];
            [defaults setValue:username forKey:@"Username"];
            [defaults synchronize];

        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setInteger:kAllAccountIndex forKey:@"selectedIndex"];
        [defaults synchronize];
        [[MDataManager sharedManager] saveContextAsync];
        
        
        [TestFlight passCheckpoint:@"SIGNED_IN"];
        
        [self.activityIndicator stopAnimating];
        
        [self.signInButton setEnabled:YES];
        [self.usernameField setEnabled:YES];
        [self.passwordField setEnabled:YES];
        [self.signInButton setTitle:@"Sign in" forState:UIControlStateNormal];
        [[MMailManager sharedManager] beginFetchingAllMail];
        
    } failure:^(NSError *error) {
        NSLog(@"failed credentials");

        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Problem Signing in" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        
        [alert show];
        
        [self resetStateFromError];

    }];
    
}

-(void) resetStateFromError
{
    [self.activityIndicator stopAnimating];
    [self.usernameField setEnabled:YES];
    [self.passwordField setEnabled:YES];
    [self.signInButton setEnabled:YES];
    [self.signInButton setTitle:@"Sign in" forState:UIControlStateDisabled];
    
}

@end
