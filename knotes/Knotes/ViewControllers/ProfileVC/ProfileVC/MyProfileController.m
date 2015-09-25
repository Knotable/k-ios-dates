//
//  MyProfileController.m
//  Knotable
//
//  Created by Martin Ceperley on 1/2/14.
//
//


#import <Masonry/View+MASAdditions.h>
#import "MyProfileController.h"
#import "AccountEntity.h"
#import "UserEntity.h"
#import "ContactsEntity.h"
#import "CUtil.h"
#import "GBPathImageView.h"
#import "UIImage+Retina4.h"
#import "NSString+Knotable.h"
#import "single_mongodb.h"
#import "EmailEditorView.h"
#import "DesignManager.h"
#import "SDImageCache.h"
#import "ProfileDetailVC.h"
#import "SettingsVC.h"
#import "Constant.h"

@interface MyProfileController (){
@private
    UIResponder *currentResponder;
}
@property (nonatomic, strong) KnoteBMBV*    bottomMenuBar;
@property (nonatomic, strong) AccountEntity *account;
@property (nonatomic, strong) UserEntity *user;
@property (nonatomic, strong) ContactsEntity *contact;
@property (nonatomic, strong) IBOutlet UITableView *tblProfile;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIView *scrollViewContent;
@property (nonatomic, strong) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, strong) IBOutlet UINavigationItem *navItem;

@property (nonatomic, strong) IBOutlet UILabel *usernameLabel;
@property (nonatomic, strong) IBOutlet GBPathImageView *userImageView;

@property (nonatomic, strong) IBOutlet EmailEditorView *emailEditorView;

@property (nonatomic, strong) IBOutlet UITextField *emailField;
@property (nonatomic, strong) IBOutlet UITextField *phoneField;
@property (nonatomic, strong) IBOutlet UITextField *websiteField;
@property (nonatomic, strong) IBOutlet UITextField *passwordOldField;
@property (nonatomic, strong) IBOutlet UITextField *passwordNewField;
@property (nonatomic, strong) IBOutlet UITextField *passwordNew2Field;
@property (nonatomic, strong) IBOutlet UIButton *saveButton;

@property (nonatomic, strong) IBOutlet UILabel *changePasswordLabel;
@property (nonatomic, strong) IBOutlet UIView *passwordOldBlock;
@property (nonatomic, strong) IBOutlet UIView *passwordNewBlock;
@property (nonatomic, strong) IBOutlet UIView *passwordNew2Block;

@property (nonatomic, strong) IBOutlet UIButton *connectGoogleButton;
@property (nonatomic, strong) IBOutlet UIButton *connectFacebookButton;
@property (nonatomic,strong)NSArray *profileMenuButtons;

-(IBAction)saveForm;

-(IBAction)connectGoogle;


@end

@implementation MyProfileController

- (id)initWithAccount:(AccountEntity *)account
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.account = account;
        self.user = account.user;
        self.contact = account.user.contact;
    }
    return self;
}

- (id)initWithContact:(ContactsEntity *)contact {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.contact = contact;
    }
    return self;
}

-(void)updateGoogleButtonLink:(BOOL)shouldLink
{
    [_connectGoogleButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];

    NSString *title = shouldLink ? @"Link Gmail" : @"Unlink Gmail";
    SEL action = shouldLink ? @selector(connectGoogle) : @selector(unlinkGoogle);

  
       
    [_connectGoogleButton setTitle:title forState:UIControlStateNormal];
    [_connectGoogleButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title=@"Profile";
     [self updateViewFormat];
    if([glbAppdel.currentAccount.user.user_id isEqualToString:_contact.user.user_id])
        self.profileMenuButtons =[[NSArray alloc] initWithObjects:@"Profile Information", @"Notifications",@"Account settings", nil];
    
    else
         self.profileMenuButtons =[[NSArray alloc] initWithObjects:@"Profile Information",   nil];
        //_backgroundImageView.image = [UIImage retina4ImageNamed:@"people-bg"];
    self.view.backgroundColor = [DesignManager appBackgroundColor];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave
                                                                                           target:self
                                                                                           action:@selector(saveForm)];

    _usernameLabel.text = _contact.name;
    [self insertUserImage];


    _emailEditorView.editable = self.user != nil;
    _emailEditorView.textFieldDelegate = self;
    _emailEditorView.contact = _contact;

    _websiteField.text = _contact.website;
    _phoneField.text = _contact.phone;


    _passwordNewField.enabled = NO;
    _passwordNew2Field.enabled = NO;
      self.removeFromPad.layer.cornerRadius=6;
    if(![self.delegate isKindOfClass:[SettingsVC class]])
    {
  
        self.removeFromPad.hidden=NO;
    }
    else
        self.removeFromPad.hidden=YES;
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
//    [self.view addGestureRecognizer:tap];

    
    if(!self.user){
        //Read-only profile

        self.navigationItem.rightBarButtonItem = nil;
        _phoneField.enabled = _websiteField.enabled = NO;
        _phoneField.borderStyle = _websiteField.borderStyle = UITextBorderStyleNone;

        [_changePasswordLabel removeFromSuperview];
        [_passwordOldBlock removeFromSuperview];
        [_passwordNewBlock removeFromSuperview];
        [_passwordNew2Block removeFromSuperview];
        [_saveButton removeFromSuperview];


        [_scrollViewContent mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.greaterThanOrEqualTo(_websiteField).with.offset(40.0);
        }];

        _connectGoogleButton.hidden = YES;
    } else {
        [self updateGoogleButtonLink:!self.account.google_linked.boolValue];

    }
   
    self.tblProfile.backgroundColor=[UIColor clearColor];
    self.tblProfile.delegate=self;
    [self.tblProfile reloadData];
}
-(void)updateViewFormat
{
    if(!self.bDisplayMenu)
//    {
//        for(UIView *view in [self.scrollView subviews])
//        {
//            view.hidden=YES;
//        }
//        self.tblProfile.hidden=NO;
//        self.usernameLabel.hidden=NO;
//        self.userImageView.hidden=NO;
//    }
//    else
    {
        for(UIView *view in [self.scrollView subviews])
        {
            view.hidden=NO;
            if([view isKindOfClass:[UIView class]])
            {
                 for(UIView *vw in [view subviews])
                     vw.hidden=NO;

            }
         }
        self.tblProfile.hidden=YES;
        self.usernameLabel.hidden=NO;
        
    }
}
- (void)insertUserImage {
    UIImage *userImage = nil;

    if (_contact.gravatar_exist) {
        NSString *path  = [CUtil pathForCachedImage:_contact.email];
        if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            userImage = [UIImage imageWithData:[NSData dataWithContentsOfFile:path] scale:[UIScreen mainScreen].scale];
        }
    }
    else {
        userImage =  [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_account.account_id];

    }
    
  
 
 
    if(!userImage){
        if (_contact.name && [_contact.name length]>0) {
            userImage = [CUtil imageText:[[_contact.name substringWithRange:NSMakeRange(0,1)] uppercaseString]
                          withBackground:_contact.bgcolor
                                    size:CGSizeMake(80, 80)
                                    rate:0.6];
        }
    }

    if(userImage){
        //UIColor *edgeColor = [UIColor colorWithRed:0.99 green:0.82 blue:0.77 alpha:1.0];
        UIColor *edgeColor = [UIColor grayColor];

        _userImageView = [[GBPathImageView alloc] initWithFrame:CGRectMake(0, 0, 80.0, 80.0)
                                                          image:userImage
                                                       pathType:GBPathImageViewTypeCircle
                                                      pathColor:edgeColor
                                                    borderColor:edgeColor
                                                      pathWidth:1.5];
        [_scrollViewContent addSubview:_userImageView];
        [_userImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(@80.0);
            make.top.equalTo(@-40.0);
            make.centerX.equalTo(@0.0);
        }];
        [_userImageView draw];
    }

}

#pragma mark View appearing

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark Keyboard Methods

- (void)keyboardWillShow:(NSNotification *)note {
    NSDictionary* info = note.userInfo;
    NSNumber *duration = info[UIKeyboardAnimationDurationUserInfoKey];
    CGRect endFrame = ((NSValue *)info[UIKeyboardFrameEndUserInfoKey]).CGRectValue;

    UIEdgeInsets insets = _scrollView.contentInset;
    insets.bottom = endFrame.size.height;

    [UIView animateWithDuration:duration.floatValue animations:^{
        _scrollView.contentInset = insets;
    } completion:^(BOOL finished) {

    }];
}


- (void)keyboardWillHide:(NSNotification *)note {
    NSDictionary* info = note.userInfo;
    NSNumber *duration = info[UIKeyboardAnimationDurationUserInfoKey];

    UIEdgeInsets insets = _scrollView.contentInset;
    insets.bottom = 0;

    [UIView animateWithDuration:duration.floatValue animations:^{
        _scrollView.contentInset = insets;
    } completion:^(BOOL finished) {

    }];
}


- (void)backgroundTap:(UITapGestureRecognizer *)backgroundTap {
    NSLog(@"backgroundTap");
    if(currentResponder){
        [currentResponder resignFirstResponder];
    }
}


#pragma mark UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    currentResponder = textField;
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //NSLog(@"shouldChangeCharactersInRange: %@ current: %@ replacement: %@ new text: %@", NSStringFromRange(range), textField.text, string, newText);

    if(textField == _passwordOldField || textField == _passwordNewField){
        NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];

        BOOL haveText = newText.length > 0;

        if(textField == _passwordOldField && haveText != _passwordNewField.enabled){
            _passwordNewField.enabled = haveText;
            if(!haveText){
                _passwordNew2Field.enabled = NO;
            }
        }
        else if(textField == _passwordNewField && haveText != _passwordNew2Field.enabled) {
            _passwordNew2Field.enabled = haveText;
        }

    }

    return YES;
}

- (void)displayErrorAndRestPasswords:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
            message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    _passwordOldField.text = @"";
    _passwordNewField.text = @"";
    _passwordNew2Field.text = @"";

    _passwordNewField.enabled = YES;
    _passwordNew2Field.enabled = NO;

}


- (void)textFieldDidEndEditing:(UITextField *)textField {
    currentResponder = nil;
    /*
    if(textField == _passwordNew2Field){
        if(![_passwordNewField.text isEqualToString:_passwordNew2Field.text]){
            [self displayErrorAndRestPasswords:@"Passwords Don't Match" message:@"Please enter the new passwords again."];
        }
    }
    */
}

#pragma mark Saving Form
-(IBAction)RemoveFromPad:(UIButton*)sender{
   
    if(self.delegate && [self.delegate respondsToSelector:@selector(updateSharedTopicContact:Removed:)])
        [self.delegate updateSharedTopicContact:self.contact Removed:!sender.selected];
     sender.selected=!sender.selected;
}
- (IBAction)saveForm {
    if(currentResponder){
        [currentResponder resignFirstResponder];
    }

    BOOL passwordStarted = _passwordOldField.text.length > 0 || _passwordNewField.text.length > 0 || _passwordNew2Field.text.length > 0;
    if (passwordStarted){
        BOOL validated = [self changePassword];
        if(!validated){
            return;
        }
    }

    NSArray *deletedEmails = _emailEditorView.deletedEmails;
    NSArray *addedEmails = _emailEditorView.addedEmails;

    if(deletedEmails && deletedEmails.count > 0){
        [self deleteEmails:deletedEmails];
    }

    if((addedEmails && addedEmails.count > 0) || (deletedEmails && deletedEmails.count > 0)){
        NSOrderedSet *set = [NSOrderedSet orderedSetWithArray:[_contact.email componentsSeparatedByString:@","]];
        NSMutableArray *newEmails = [[NSMutableArray alloc] initWithArray:[set array]];

        if(deletedEmails && deletedEmails.count > 0){
            for(NSString *deletedEmail in deletedEmails){
                if([newEmails containsObject:deletedEmail]){
                    [newEmails removeObject:deletedEmail];
                }
            }
        }

        for(NSString *addedEmail in addedEmails){
            if(![newEmails containsObject:addedEmail]){
                [newEmails addObject:addedEmail];
            }
        }
        _contact.email = [newEmails componentsJoinedByString:@","];
    }


    _contact.website = _websiteField.text = [_websiteField.text trimmed];
    _contact.phone = _phoneField.text = [_phoneField.text trimmed];

    [single_mongodb sendUpdatedContact:_contact];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deleteEmails:(NSArray *)emails {
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;

    for(NSString *email in emails){
        //      Meteor.call 'remove_contact_email', contact._id, emailNeedRemove
        [app.meteor callMethodName:@"remove_contact_email" parameters:@[_contact.contact_id, email]
                  responseCallback:^(NSDictionary *response, NSError *error) {

              if(error){
                  NSLog(@"Error deleting email: %@", error);
              }
        }];
    }
}

-(BOOL)changePassword {

    BOOL passwordDone = _passwordOldField.text.length > 0 && _passwordNewField.text.length > 0 && _passwordNew2Field.text.length > 0;
    NSString *oldPassword = _passwordOldField.text;
    NSString *newPassword = _passwordNewField.text;

    if(![oldPassword isEqualToString:_user.password]){
        [self displayErrorAndRestPasswords:@"Current Password Not Correct" message:@"Your current password is incorrect. If you have forgotten it, Logout of the app and press the Password button."];
        return NO;
    }
    if(!passwordDone){
        [self displayErrorAndRestPasswords:@"Incomplete" message:@"Please enter your current password, your new password, and repeat your new password."];
        return NO;
    }
    if(![newPassword isEqualToString:_passwordNew2Field.text]){
        [self displayErrorAndRestPasswords:@"Passwords Don't Match" message:@"Please enter the passwords again."];
        return NO;
    }
    if(newPassword.length < 6){
        [self displayErrorAndRestPasswords:@"Password Not Long Enough" message:@"You password must be at least 6 characters long."];
        return NO;
    }

    //Change the password
    //Meteor.call("resetPasswordFromiOS", "newpassword", function(err, result){ if(err){console.log(err)} else {console.log("success");console.log(result);}});

    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;

    [app.meteor callMethodName:@"resetPasswordFromiOS" parameters:@[newPassword] responseCallback:^(NSDictionary *response, NSError *error) {
        if(error){
            NSLog(@"changePassword error: %@", error);
            id info = error.userInfo[NSLocalizedDescriptionKey];
            NSLog(@"error info: %@", info);
            [self displayErrorAndRestPasswords:@"Error Changing Passwords" message:@"We're sorry, there was a problem changing your password."];
        }
        if(response){
            [_user setPassword:newPassword];
        }
    }];

    return YES;

}

#pragma mark Memory Management


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Connect Google Account

-(IBAction)connectGoogle
{
    NSLog(@"connectGoogle");
    ConnectGoogleController *controller = [[ConnectGoogleController alloc] initWithNibName:nil bundle:nil];
    controller.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    [self presentViewController:navController animated:YES completion:^{
        NSLog(@"completed connectGoogle presentViewController");
        
    }];
}

-(void)cancelConnectGoogle
{
    NSLog(@"cancelConnectGoogle");

    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"completed cancelConnectGoogle dismissViewControllerAnimated");
    }];
}

-(void)successConnectingGoogle:(NSString *)google_id user_id:(NSString *)google_user_id;
{
    self.account.google_linked = @(YES);
    self.account.google_id = google_id;
    self.account.google_user_id = google_user_id;
    [self updateGoogleButtonLink:NO];

    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [app saveContext];

    NSLog(@"successConnectingGoogle");
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"completed successConnectingGoogle dismissViewControllerAnimated");
    }];
}

-(void)unlinkGoogle
{
    AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
    MeteorClient *meteor = app.meteor;
    if(self.account.google_user_id && self.account.google_user_id.length > 0){
        NSLog(@"Removing google oauth with user ID: %@", self.account.google_user_id);
    } else {
        NSLog(@"Dont have google user ID to remove %@", self.account.google_user_id);
        return;
    }


    [meteor callMethodName:@"remove_google_oauth" parameters:@[self.account.google_user_id] responseCallback:^(NSDictionary *response, NSError *error) {
        if(error){
            NSLog(@"Error removing google oauth: %@", error);
        } else {
            NSLog(@"Success removing google oath, response: %@", response);

            self.account.google_linked = @(NO);
            self.account.google_id = nil;
            self.account.google_user_id = nil;

            [self updateGoogleButtonLink:YES];

            [app saveContext];

        }

    }];


}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.profileMenuButtons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
      UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    UIButton *btn=[[UIButton alloc] initWithFrame:cell.frame];
    btn.tag=indexPath.row;
    [btn addTarget:self action:@selector(SelectedProfileMenu:) forControlEvents:UIControlEventTouchUpInside];
    [cell addSubview:btn];
    [btn setTitle:@"" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor clearColor]];
    cell.backgroundColor=[UIColor clearColor];
    cell.textLabel.text= [self.profileMenuButtons objectAtIndex:indexPath.row];
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
-(void)SelectedProfileMenu:(UIButton*)MenuItem
{
    [self.delegate SelectedProfileMenu:MenuItem];
    
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row ==0)
    {
        ProfileDetailVC *profileInfo =[[ProfileDetailVC alloc] initWithAccount:self.account];
        [self.navigationController pushViewController:profileInfo animated:YES];
    }
}





@end
