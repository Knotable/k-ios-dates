//
//  ProfileDetailVC.m
//  Knotable
//
//  Created by darshana on 09/08/14.
//
//

#import "ProfileDetailVC.h"

#import "Constant.h"
#import "CUtil.h"
#import "SDImageCache.h"

#import "UserEntity.h"
#import "AccountEntity.h"
#import "ContactsEntity.h"

#import "KNCustomAlertView.h"
#import "GBPathImageView.h"

#import "DataManager.h"
#import "FileManager.h"
#import "DesignManager.h"
#import "AnalyticsManager.h"

#import "UIImage+Retina4.h"
#import "NSString+Knotes.h"
#import "UIImage+ImageEffects.h"
#import <Masonry/View+MASAdditions.h>

#import <pop/POP.h>
#import <SDWebImage/UIImageView+WebCache.h>

@interface ProfileDetailVC ()
{
    
@private
    
    UIResponder *currentResponder;
}

#define MESSAGE_FOR_NEW_MAIL        @"Add another email"
#define MESSAGE_FOR_PHONE           @"Enter your phone"
#define MESSAGE_FOR_SITE            @"example.com"
#define MESSAGE_FOR_PASSWORD        @"Enter your password"
#define MESSAGE_FOR_PASSWORD_NEW    @"New"
#define MESSAGE_FOR_PASSWORD_REPEAT @"Repeat"

#define OLD_PASSWORD        @"OLD_PASSWORD"
#define NEW_PASSWORD        @"NEW_PASSWORD"
#define REPEAT_PASSWORD     @"REPEAT_PASSWORD"


#define UPLOAD_PHOTO_TEXT   @""

#define EDIT_IMAGE_CENTER_PADDING   20
#define LABEL_BASIC_X               5
#define CONTROL_BASIC_X             91

#define CLOSE_IMAGE_RIGHT_PADDING   6
#define MAIL_PADDING                16
#define CLOSE_IMAGE_SIZE            18
#define USER_IMAGE_DIAMETER         120
#define QUICKTYPE_HEIGHT            38
#define SWIPED_DOWN_QUICKTYPE_HEIGHT    8



@property (nonatomic, strong) ContactsEntity    *contact;

@property (nonatomic, strong) GBPathImageView   *userImageView;
@property (nonatomic, strong) UIImage *         userImageAfterChange;

@property (nonatomic, weak)   IBOutlet UILabel            *usernameLabel;
@property (weak, nonatomic)     IBOutlet UILabel            *emailLabel;
@property (nonatomic, weak)   IBOutlet UIButton           *connectGoogleButton;
@property (nonatomic, weak)   IBOutlet UIImageView        *backgroundImageView;
@property (nonatomic, weak)   IBOutlet UIScrollView       *scrollViewContent;
@property (weak, nonatomic)     IBOutlet UIImageView        *frostGlassProfileImageVIew;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong)   NSString                * site;
@property (nonatomic, strong)   NSString                * phone;
@property (nonatomic, strong)   UILabel                 * editImageLabel;
@property (nonatomic)           CGRect                  keyboardEndFrame;
@property (nonatomic, strong)   UIButton                * editImageBut;
@property (nonatomic, strong)   NSMutableDictionary     * passwordDictionary;
@property (nonatomic, weak)     UITextField             * passwordRepeatTextField;
@property (nonatomic, weak)     UITextField             * passwordNewTextField;
@property (nonatomic, strong)   UITextField             * currentTextField;

@property (nonatomic) BOOL      editing;
@property (nonatomic) BOOL      oldPasswordCorrectlyEntered;
@property (nonatomic) BOOL      checkingForQuickType;

@end

@implementation ProfileDetailVC

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (id)initWithAccount:(AccountEntity *)account
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self)
    {
        self.account = account;
        self.user = account.user;
    }
    return self;
}

- (id)initWithContact:(ContactsEntity *)contact
{
    self = [super initWithNibName:nil bundle:nil];
    
    if (self)
    {
        //self.contact = contact;
    }
    return self;
}

- (void)dealloc
{
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver: self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    
    [nc addObserver:self
           selector:@selector(keyboardWillShow:)
               name:UIKeyboardWillShowNotification object:self.view.window];
    
    [nc addObserver:self
           selector:@selector(keyboardWillHide:)
               name:UIKeyboardWillHideNotification object:nil];
    
    if(!self.contact)
    {                                                           
        self.contact = [ContactsEntity MR_findFirstByAttribute:@"mainEmail"
                                                     withValue:[[self.user.email componentsSeparatedByString:@","] firstObject]];
        
        if(!self.contact){
            self.contact = [ContactsEntity MR_findFirstByAttribute:@"mainEmail"
                                                         withValue:[[self.user.email componentsSeparatedByString:@","] lastObject]];
        }
    }
    
    if(!self.contact)
    {
        self.contact = self.user.contact;
    }
    
    [self updateProfileImage];
    self.view.backgroundColor = [DesignManager appBackgroundColor];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTap:)];
    tap.cancelsTouchesInView = NO;

    [self.tableView addGestureRecognizer:tap];
    
    if(!self.user)
    {
        //Read-only profile
        self.navigationItem.rightBarButtonItem = nil;
        self.connectGoogleButton.hidden = YES;
    }
    else
    {
        [self updateGoogleButtonLink:!self.account.google_linked.boolValue];
        
    }
    
    // tableviews
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 100;
    
    [self setupImageRefreshControl];
    
    isPhotoUpdated = NO;
    
    [self onEdit];
}

-(void)viewWillAppear:(BOOL)animated
{
//    self.parentViewController.navigationItem.rightBarButtonItem = Nil;
//    
#if !New_DrawerDesign
    [self.navigationController setNavigationBarHidden:YES];
#endif
    
    [super viewWillAppear: animated];

}

-(void)removeFromParentViewController
{
    [self.navigationController setNavigationBarHidden:NO];
    
    [super removeFromParentViewController];
}

//-(void)viewWillDisappear:(BOOL)animated
//{
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIKeyboardWillShowNotification
//                                                  object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIKeyboardWillHideNotification
//                                                  object:nil];
//    [super viewWillDisappear: animated];
//}
//
//- (void)viewDidDisappear:(BOOL)animated
//{
//    [super viewDidDisappear:animated];
//}
//
#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Delegates

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    
    // Only COMPILE this if compiled against BaseSDK iOS8.0 or greater
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
#endif
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    switch (section) {
        case 0:
            numberOfRows = 1;
            break;
        case 1:
        {
            NSArray* array = [self.user.email componentsSeparatedByString:@","];
            NSInteger mailCount = array.count;
            numberOfRows = mailCount + 1;
        }
            break;
        case 2:
            numberOfRows = 4;
            break;
        case 3:
            numberOfRows = 1;
            break;
            
        default:
            break;
    }
//    if([tableView isEqual:self.mailTableView])
//    {
//        if(self.editing)
//        {
//            return ([self.user.email componentsSeparatedByString:@","].count + 1);
//        }
//        else
//        {
//            return ([self.user.email componentsSeparatedByString:@","].count);
//        }
//    }
//    else if([tableView isEqual:self.inputsTableView])
//    {
//        if(self.oldPasswordCorrectlyEntered)
//        {
//            return 6;
//        }
//        else
//        {
//            if(self.editing)
//            {
//                return 4;
//            }
//            else
//            {
//                return 3;
//            }
//        }
//        
//    }
//    else
//        return 0;
    
    return numberOfRows;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    
    switch (indexPath.section) {
        case 0: // Profile Image and name
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"ProfileImageCell" forIndexPath:indexPath];
                if (self.frostGlassProfileImageVIew == nil)
                {
                    self.frostGlassProfileImageVIew = (UIImageView*)[cell viewWithTag: 1];
                    self.userImageView = (GBPathImageView*)[cell viewWithTag: 3];
                    [self updateProfileImage];
                }
                self.usernameLabel = (UILabel*)[cell viewWithTag: 2];
                if (self.usernameLabel)
                {
                    self.usernameLabel.text = self.contact.name;
                }
            }
            break;
        case 1: // Email:
            {
                NSArray* array = [self.user.email componentsSeparatedByString:@","];
                NSInteger mailCount = array.count;
                
                if (indexPath.row < mailCount)
                {
                    NSString* cellIdentifier = @"EmailCell";
                    if (indexPath.row > 0)
                        cellIdentifier = @"OtherEmailCell";
                    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
                    
                    UILabel* mail = (UILabel*)[cell viewWithTag: 1];
                    mail.text = array[indexPath.row];
                }
                else
                {
                    cell = [tableView dequeueReusableCellWithIdentifier:@"AddEmailCell" forIndexPath:indexPath];
                }
            }
            break;
        case 2://notificatoin, phone, Site, Pass
            {
                switch (indexPath.row) {
                    case 0:
                        {
                            cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell" forIndexPath:indexPath];
                            UISwitch * notificationSwitch = (UISwitch *)[cell viewWithTag: 1];
                            notificationSwitch.on = [DataManager sharedInstance].currentAccount.notificationStatus.boolValue;
                        }
                        break;
                    case 1:
                        {
                            cell = [tableView dequeueReusableCellWithIdentifier:@"PhoneCell" forIndexPath:indexPath];
                            UITextField* phoneText = (UITextField*)[cell viewWithTag: 3];
                            phoneText.text = self.contact.phone;
                        }
                        break;
                    case 2:
                        {
                            cell = [tableView dequeueReusableCellWithIdentifier:@"SiteCell" forIndexPath:indexPath];
                            UITextField* siteText = (UITextField*)[cell viewWithTag: 4];
                            siteText.text = self.contact.website;
                        }
                        break;
                    case 3:
                        {
                            cell = [tableView dequeueReusableCellWithIdentifier:@"PassCell" forIndexPath:indexPath];
//                            UITextField* passText = (UITextField*)[cell viewWithTag: 5];

                        }
                        break;
                }
            }
            break;
        case 3://logout, help, line
            {
                cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonsCell" forIndexPath:indexPath];
                CGFloat cellWidth = CGRectGetWidth(tableView.frame);
                cell.separatorInset = UIEdgeInsetsMake(0, cellWidth / 2, 0, cellWidth / 2);
            }
            break;
        default:
            break;
    }
    

    return cell;
}

- (IBAction) notificationSwitchValueChanged:(UISwitch *)sender
{
    [DataManager sharedInstance].currentAccount.notificationStatus=@(sender.on);
    
    [AppDelegate saveContext];
}

-(IBAction) removeCellData:(UIButton *)sender
{
    switch (sender.tag)
    {
        case 1:
        {
            UITableViewCell * cell = (UITableViewCell *)sender.superview;
            
            for(UIView * v in cell.subviews)
            {
                if([v isKindOfClass:[UILabel class]])
                {
                    // Remove mail from contact and from table
                    NSString * mailToRemove = ((UILabel *)v).text;
                    NSMutableArray * mails = [[self.user.email componentsSeparatedByString:@","] mutableCopy];
                    [mails removeObject:mailToRemove];
                    self.user.email = [mails componentsJoinedByString:@","];
                    self.contact.mainEmail = [mails objectAtIndex:0];
                    
                    [self.tableView reloadData];
                    
                    // Lin - Added to update user contact information on DB
                    
                    [[AppDelegate sharedDelegate] sendUpdatedContact:self.contact];
                    
                    // Lin - Ended
                    
                }
            }
            break;
        }
        case 2:
        {
            UITableViewCell * cell = (UITableViewCell *)sender.superview;
            
            for(UIView * v in cell.subviews)
            {
                if([v isKindOfClass:[UITextField class]])
                {
                    // Check if email or phone label and edit
                    NSString * text = ((UITextField *)v).text;
                    if([text isValidURL])
                    {
                        ((UITextField *)v).placeholder = MESSAGE_FOR_SITE;
                        self.site = @"";
                        
                        self.contact.website = @"";
                        
                    }
                    else if([text isPhoneNumber])
                    {
                        ((UITextField *)v).placeholder = MESSAGE_FOR_PHONE;
                        self.phone = @"";
                        
                        self.contact.phone = @"";
                    }
                    
                    [((UITextField *)v) setTextColor:[UIColor lightGrayColor]];
                    sender.hidden = YES;
                    
                }
            }
            break;
        }
            
        default:
            break;
    }
    
    // Lin - Added to update user contact information on DB
    
    [[AppDelegate sharedDelegate] sendUpdatedContact:self.contact];
    
    // Lin - Ended
}

#pragma mark - Utility Functions

- (void) SaveProfileInfo
{
    /********************************************************
     
     Function : When user try to change any fields or try to leave 
                Profile view, app would save current user's change 
                on Profile view.
     
     ********************************************************/
    
    DLog(@"Check Point!!!\n------------Saving User Profile Information------------");
    
    if(self.userImageAfterChange)
    {
        if (self.contact.fullURL)
        {
            [[SDImageCache sharedImageCache] storeImage:self.userImageAfterChange
                                                 forKey:GET_CACHE_KEY_FOR_FULLURL(self.contact.account_id)
                                                 toDisk:YES];
        }
        else
        {
            [[SDImageCache sharedImageCache] storeImage:self.userImageAfterChange
                                                 forKey:self.contact.account_id
                                                 toDisk:YES];
        }
        
        NSString *path  = [CUtil pathForCachedImage:self.contact.email];
        
        [[NSFileManager defaultManager] createFileAtPath:path
                                                contents:UIImagePNGRepresentation(self.userImageAfterChange)
                                              attributes:nil];
        
        AppDelegate *shareinst = [AppDelegate sharedDelegate];
        
        if (shareinst.SharedFile)
        {
            [[NSNotificationCenter defaultCenter]removeObserver:self
                                                           name:@"RefreshingEndsForProfile"
                                                         object:nil];
            
            NSDictionary *dic=@{@"path" : shareinst.SharedFile.full_url,
                                @"mini" : shareinst.SharedFile.thumbnail_url};
            
            shareinst.SharedFile=nil;
            
            [[AppDelegate sharedDelegate] sendUpdatedContactWithImage:self.contact
                                                                  URL:dic];
        }
    }
    else
    {
        [[AppDelegate sharedDelegate] sendUpdatedContact:self.contact];
    }
}

- (NSMutableDictionary *) passwordDictionary
{
    if(!_passwordDictionary) _passwordDictionary = [[NSMutableDictionary alloc] init];
    return _passwordDictionary;
}

- (IBAction)logoutButtonPressed:(id)sender
{
    [_logOUTInstance loggingOutExtras];
    [DataManager sharedInstance].fetchedContacts = NO;
    
    [glbAppdel logout];
    
    [glbAppdel.navController popToRootViewControllerAnimated:YES];
}

-(void)updateGoogleButtonLink:(BOOL)shouldLink
{
    [self.connectGoogleButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
    
    NSString *title = shouldLink ? @"Link Gmail" : @"Unlink Gmail";
    SEL action = shouldLink ? @selector(connectGoogle) : @selector(unlinkGoogle);
    
    [self.connectGoogleButton setTitle:title forState:UIControlStateNormal];
    [self.connectGoogleButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void) updateProfileImage
{
    /********************************************************
     
     Function :
     
     1. check the user profile image.
     2. If there is not user profile image, then try to find gravatar image
     3. In other case, app would use
     
     ********************************************************/
    [self setupImageRefreshControl];
    //[self.view bringSubviewToFront:Spinnerview];
    [Spinnerview startAnimating];
    [ContactsEntity getAsyncImage:self.contact WithBlock:^(id img, BOOL flag) {
        [self loadProfileImage:img];
    }];
}

- (void) loadProfileImage : (UIImage* )img
{
    self.frostGlassProfileImageVIew.image = [img applyDarkEffect];

    UIColor *edgeColor = [UIColor grayColor];
    self.userImageAfterChange = img;
    
    [self.userImageView setImage:img
                        pathType:GBPathImageViewTypeCircle
                       pathColor:edgeColor
                     borderColor:edgeColor
                       pathWidth:1.5];

//    [self.userImageView.superview bringSubviewToFront: self.userImageView];
    [self EndRefreshing];
}

- (UIImage* ) generatePlaceHolderImage
{
    UIImage* retImg = Nil;
    
    if (self.contact.gravatar_exist)
    {
        NSString *path  = [CUtil pathForCachedImage:self.contact.email];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            retImg = [UIImage imageWithData:[NSData dataWithContentsOfFile:path] scale:[UIScreen mainScreen].scale];
        }
    }
    else
    {
        retImg =  [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:_account.account_id];
    }
    
    if(!retImg)
    {
        if (_contact.name && [_contact.name length]>0)
        {
            retImg = [CUtil imageText:[[_contact.name substringWithRange:NSMakeRange(0,1)] uppercaseString]
                       withBackground:_contact.bgcolor
                                 size:CGSizeMake(120, 120)
                                 rate:0.6];
        }
    }
    
    
    return retImg;
}

#pragma mark Keyboard Methods

- (void)keyboardWillShow:(NSNotification *)note
{
    NSDictionary* info = note.userInfo;
    NSNumber *duration = info[UIKeyboardAnimationDurationUserInfoKey];
    CGSize keyboardSize = ((NSValue *)info[UIKeyboardFrameEndUserInfoKey]).CGRectValue.size;
    
    [UIView animateWithDuration:duration.floatValue animations:^{
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.height, 0);
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    } completion:^(BOOL finished) {

    }];
}

- (BOOL)isPredictiveTextEnabledForTextField:(UITextField *)textField
{
    if (textField.autocorrectionType == UITextSpellCheckingTypeNo)
    {
        return NO;
    }
    else
    {
        return YES;
    }
    
    BOOL isFirstResponder = [textField isFirstResponder];
    BOOL autoCorrectionType = [textField autocorrectionType];
    
    [textField resignFirstResponder];
    
    // Get the frame with possibly including predictive text
    [textField becomeFirstResponder];
    CGRect predictiveKeyboardEndFrame = self.keyboardEndFrame;
    [textField resignFirstResponder];
    
    // Get the keyboard frame without predictive text
    textField.autocorrectionType = UITextSpellCheckingTypeNo;
    [textField becomeFirstResponder];
    CGRect defaultKeyboardEndFrame = self.keyboardEndFrame;
    [textField resignFirstResponder];
    
    // Restore state
    textField.autocorrectionType = autoCorrectionType;
    if (isFirstResponder) {
        [textField becomeFirstResponder];
    }
    
    BOOL isPredictiveTextEnabled = !CGPointEqualToPoint(predictiveKeyboardEndFrame.origin, defaultKeyboardEndFrame.origin);
    
    if(isPredictiveTextEnabled)
    {
        /*
        if(defaultKeyboardEndFrame.size.height < predictiveKeyboardEndFrame.size.height)
            isPredictiveTextEnabled = NO;
         */
    }
    
    isPredictiveTextEnabled = NO;
    
    if( (defaultKeyboardEndFrame.size.height + SWIPED_DOWN_QUICKTYPE_HEIGHT) < predictiveKeyboardEndFrame.size.height)
        isPredictiveTextEnabled = YES;
    
    self.checkingForQuickType = NO;
    return isPredictiveTextEnabled;
}


- (void)keyboardWillHide:(NSNotification *)note
{
    NSDictionary* info = note.userInfo;
    NSNumber *duration = info[UIKeyboardAnimationDurationUserInfoKey];
    
    [UIView animateWithDuration:duration.floatValue animations:^{
        self.tableView.contentInset = UIEdgeInsetsZero;
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    } completion:^(BOOL finished) {
        
    }];
}


- (void)backgroundTap:(UITapGestureRecognizer *)backgroundTap {

    if(CGRectContainsPoint(self.editImageBut.frame, [backgroundTap locationInView:self.userImageView]))
    {
        [self uploadProfilePhoto];
    }
    
    NSLog(@"backgroundTap");
    
    if(currentResponder)
    {
        [currentResponder resignFirstResponder];
    }
}

#pragma mark - UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.currentTextField = textField;
    
//    // Assuming we will keep al rows height equal. Else, needs to be changed.
//    float contentOffsetScrollConstant = [self tableView:self.mailTableView heightForRowAtIndexPath:0];
//    self.toScroll = contentOffsetScrollConstant * ([self.mailTableView numberOfRowsInSection:0] - 2) - 15;
//    
//    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
//    
//    if(screenSize.height <= 480.0f)
//    {
//        self.toScroll += (2 * contentOffsetScrollConstant);
//    }
//    
//    self.toScroll -= self.scrollViewContent.contentOffset.y;
//    
//    textField.textColor = [UIColor blackColor];
    currentResponder = textField;
//    if( (textField.tag == 1) || (textField.tag == 2) )
//    {
//        textField.text = @"";
//        if(self.toScroll > 0)
//            [self.scrollView setContentOffset:CGPointMake(0, self.toScroll) animated:YES];
//    }
//    else if (textField.tag == 3)
//    {
//        if ([textField.text isEqualToString:MESSAGE_FOR_PHONE])
//            textField.text = @"";
//        self.toScroll += (2 * contentOffsetScrollConstant);
//        [self.scrollView setContentOffset:CGPointMake(0, self.toScroll) animated:YES];
//    }
//    else if ( textField.tag == 4)
//    {
//        if ([textField.text isEqualToString:MESSAGE_FOR_SITE])
//            textField.text = @"";
//        self.toScroll += (3 * contentOffsetScrollConstant);
//        [self.scrollView setContentOffset:CGPointMake(0, self.toScroll) animated:YES];
//    }
//    else if (textField.tag == 5)
//    {
//        if([textField.text isEqualToString:MESSAGE_FOR_PASSWORD])
//            textField.text = @"";
//        self.toScroll += (4 * contentOffsetScrollConstant);
//        [self.scrollView setContentOffset:CGPointMake(0, self.toScroll) animated:YES];
//        [textField setSecureTextEntry:YES];
//    }
//    else if (textField.tag == 6)
//    {
//        textField.text = @"";
//        [textField setBackgroundColor:[UIColor whiteColor]];
//        self.toScroll += (5 * contentOffsetScrollConstant);
//        [self.scrollView setContentOffset:CGPointMake(0, self.toScroll) animated:YES];
//        [textField setSecureTextEntry:YES];
//    }
//    else if (textField.tag == 7)
//    {
//        textField.text = @"";
//        [textField setBackgroundColor:[UIColor whiteColor]];
//        self.toScroll += (6 * contentOffsetScrollConstant);
//        [self.scrollView setContentOffset:CGPointMake(0, self.toScroll) animated:YES];
//        [textField setSecureTextEntry:YES];
//    }
}

- (void)displayErrorAndRestPasswords:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( (textField.tag == 1) || (textField.tag == 2) || (textField.tag == 3) || (textField.tag == 4) )
    {
        [textField resignFirstResponder];
    }
    else if (textField.tag == 5)
    {
        [textField resignFirstResponder];
        [self.passwordNewTextField becomeFirstResponder];
    }
    else if (textField.tag == 6)
    {
        [self.passwordRepeatTextField becomeFirstResponder];
    }
    else if (textField.tag == 7)
    {
        [textField resignFirstResponder];
    }
    
    return NO;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    currentResponder = nil;
    
    switch (textField.tag)
    {
        case 1: // User Email Setting
        {
            if([textField.text isEqualToString:@""])
            {
                textField.placeholder  = MESSAGE_FOR_NEW_MAIL;
            }
            else
            {
                if(![textField.text isValidEmail])
                {
                    textField.placeholder = MESSAGE_FOR_NEW_MAIL;
                    
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Email"
                                                                        message:@"Please enter a valid email"
                                                                       delegate:nil
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil];
                    [alertView show];
                }
                else
                {
                    [self.contact addNewMail:textField.text];
                    
                    // Lin - Added to update user contact information on DB
                    
                    [[AppDelegate sharedDelegate] sendUpdatedContact:self.contact];
                    
                    // Lin - Ended
                    
                    [self.tableView reloadData];
                    
                    textField.text = @"";
                }
            }
            break;
        }
        case 2:
        {
            if([textField.text isEqualToString:@""])
            {
                textField.placeholder  = MESSAGE_FOR_NEW_MAIL;
                
                [textField setTextColor:[UIColor lightGrayColor]];
            }
            else
            {
                [textField setTextColor:[UIColor blackColor]];
            }
            break;
        }
        case 3:
        {
            if (([textField.text isEqualToString:@""]) || (![textField.text isPhoneNumber]) )
            {
                textField.placeholder  = MESSAGE_FOR_PHONE;
                
                [textField setTextColor:[UIColor lightGrayColor]];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid Phone number"
                                                                    message:@"Please enter a valid Phone number"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
                
                if (self.contact.phone)
                {
                    textField.text = self.contact.phone;
                }
                else
                {
                    textField.text = @"";
                }
                
                self.phone = @"";
            }
            else
            {
                [textField setTextColor:[UIColor blackColor]];
                
                self.phone = textField.text;
                
                for(UIView * v in textField.superview.subviews)
                {
                    if([v isKindOfClass:[UIButton class]])
                    {
                        v.hidden = NO;
                    }
                }
                
                // Lin - Added to update user contact information on DB
                
                self.contact.phone = self.phone;
                
                [[AppDelegate sharedDelegate] sendUpdatedContact:self.contact];
                
                // Lin - Ended
                
            }
            break;
        }
        case 4: // User Site information
        {
            if( ([textField.text isEqualToString:@""]) || (![textField.text isValidURL]) )
            {
                textField.placeholder  = MESSAGE_FOR_SITE;
                [textField setTextColor:[UIColor lightGrayColor]];
                
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invalid site address"
                                                                    message:@"Please enter a valid site address"
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                [alertView show];
                
                if (self.contact.website)
                {
                    textField.text = self.contact.website;
                }
                else
                {
                    textField.text = @"";
                }
                
                self.site = @"";
            }
            else
            {
                [textField setTextColor:[UIColor blackColor]];
                
                self.site = textField.text;
                
                for(UIView * v in textField.superview.subviews)
                {
                    if([v isKindOfClass:[UIButton class]])
                    {
                        v.hidden = NO;
                    }
                }
                
                // Lin - Added to update user contact information on DB
                
                self.contact.website = self.site;
                
                [[AppDelegate sharedDelegate] sendUpdatedContact:self.contact];
                
                // Lin - Ended
                
            }
            break;
        }
        case 5:
        {
            if([textField.text isEqualToString:@""])
            {
                textField.placeholder  = MESSAGE_FOR_PASSWORD;
                
                [textField setTextColor:[UIColor lightGrayColor]];
                [textField setSecureTextEntry:NO];
                [self enableNewPasswordEntry:NO];
                [textField setTextColor:[UIColor blackColor]];
            }
            else
            {
                DLog(@"Two Password - %@ : %@", textField.text, self.user.password);
                
                if([textField.text isEqualToString:self.user.password])
                {
                    [self.passwordDictionary setObject:textField.text forKey:OLD_PASSWORD];
                    [self enableNewPasswordEntry:YES];
                }
                else
                {
                    [self displayErrorAndRestPasswords:@"Wrong Password" message:@"Please check the password entered"];
                    [textField setTextColor:[UIColor lightGrayColor]];
                    
                    return;
                }
                
            }
            break;
        }
        case 6:
        {
            if([textField.text isEqualToString:@""])
            {
                [textField setSecureTextEntry:NO];
                [textField setTextColor:[UIColor lightGrayColor]];
            }
            else
            {
                [textField setTextColor:[UIColor blackColor]];
                [self.passwordDictionary setObject:textField.text forKey:NEW_PASSWORD];
            }
            break;
        }
        case 7:
        {
            if([textField.text isEqualToString:@""])
            {
                [textField setSecureTextEntry:NO];
                [textField setTextColor:[UIColor lightGrayColor]];
            }
            else
            {
                [self.passwordDictionary setObject:textField.text forKey:REPEAT_PASSWORD];
                
                [textField setTextColor:[UIColor blackColor]];
                
                BOOL passwordStarted = ([self.passwordDictionary objectForKey:OLD_PASSWORD]) || ([self.passwordDictionary objectForKey:NEW_PASSWORD]) || ([self.passwordDictionary objectForKey:REPEAT_PASSWORD]);
                
                if (passwordStarted)
                {
                    BOOL validated = [self changePassword];
                    
                    if(!validated)
                    {
                        DLog(@"Error occured to update password");
                    }
                }
                
            }
            break;
        }
            
        default:
            break;
    }
}

-(void) enableNewPasswordEntry:(BOOL)enable
{
    UIColor * color;
    if(enable) color = [UIColor whiteColor];
    else color = [UIColor grayColor];
    
    self.passwordRepeatTextField.enabled = enable;
    self.passwordNewTextField.enabled = enable;
    [self.passwordNewTextField setBackgroundColor:color];
    [self.passwordRepeatTextField setBackgroundColor:color];
    
    if(enable)
    {
        self.oldPasswordCorrectlyEntered = enable;
        [self.tableView reloadData];
    }
}

#pragma mark - ImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{
       
        /*
        if (self.parentViewController)
        {
            self.parentViewController.navigationItem.rightBarButtonItem = Nil;
        }
         */
        
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:^{
        
        UIImage *img = [info objectForKey:UIImagePickerControllerEditedImage];
        
        if(!img) img = [info objectForKey:UIImagePickerControllerOriginalImage];
        
        
        if(img)
        {
            if(img.size.width > self.view.frame.size.width){
                CGSize newSize =CGSizeMake(self.view.frame.size.width, (self.view.frame.size.width/img.size.width)*img.size.height);
                UIGraphicsBeginImageContext(newSize);
                
                [img drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
                img = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:MenubarDisableNotification
                                                                object:nil];
            
            [self loadProfileImage: img];
            
            ALAssetsLibraryAssetForURLResultBlock resultblock = ^(ALAsset *myasset){
            
                NSMutableArray *fInfoArray = [[NSMutableArray alloc] initWithCapacity:3];
                
                FileInfo *fInfo = [FileInfo fileInfoForAsset:myasset];
                
                [fInfoArray addObject:fInfo];
                
                [Spinnerview startAnimating];
                
                self.navigationController.navigationBar.userInteractionEnabled=NO;
                
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(EndRefreshing) name:@"RefreshingEndsForProfile" object:nil];
                
                [FileManager beginUploadingFile:fInfo];
            };
            
            ALAssetsLibraryAccessFailureBlock failureblock  = ^(NSError *myerror){
                NSLog(@"Cannot get image - %@",[myerror localizedDescription]);
            };
            
            ALAssetsLibrary* assetslibrary = [[ALAssetsLibrary alloc] init] ;
            
            if( [picker sourceType] == UIImagePickerControllerSourceTypeCamera )
            {
                [assetslibrary writeImageToSavedPhotosAlbum:img.CGImage orientation:(ALAssetOrientation)img.imageOrientation completionBlock:^(NSURL *assetURL, NSError *error )
                 {
                     [assetslibrary assetForURL:assetURL resultBlock:resultblock failureBlock:failureblock];
                 }];
            }
            else
            {
                NSURL *url=[info objectForKey:UIImagePickerControllerReferenceURL];
                
                [assetslibrary assetForURL:url resultBlock:resultblock failureBlock:failureblock];

            }
            
            isPhotoUpdated = YES;
        }
        else
        {
            isPhotoUpdated = NO;
        }
        
        if (isPhotoUpdated)
        {
            if(self.editing)
            {
                [self.editImageBut removeFromSuperview];
            }
        }
        
        if (self.parentViewController)
        {
            self.parentViewController.navigationItem.rightBarButtonItem = Nil;
        }
        
    }];
}


- (void) setupImageRefreshControl
{
    if(Spinnerview == nil){
        Spinnerview = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    }
   // Spinnerview.transform = CGAffineTransformMakeScale(3, 3);
    Spinnerview.center = CGPointMake(160, 122);
    Spinnerview.hidesWhenStopped = YES;
    [self.view addSubview:Spinnerview];
}

-(void)EndRefreshing
{
    [Spinnerview stopAnimating];
    
    self.navigationController.navigationBar.userInteractionEnabled=YES;
    self.parentViewController.navigationItem.rightBarButtonItem = Nil;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MenubarEnableNotification
                                                        object:nil];
    
    // Lin - Added to update contact information on DB
    
    if(self.userImageAfterChange)
    {
        if (self.contact.fullURL)
        {
            [[SDImageCache sharedImageCache] storeImage:self.userImageAfterChange forKey:GET_CACHE_KEY_FOR_FULLURL(self.contact.account_id) toDisk:YES];
        }
        else
        {
            [[SDImageCache sharedImageCache] storeImage:self.userImageAfterChange forKey:self.contact.account_id toDisk:YES];
        }
        
        NSString *path  = [CUtil pathForCachedImage:self.contact.email];
        
        [[NSFileManager defaultManager] createFileAtPath:path contents:UIImagePNGRepresentation(self.userImageAfterChange) attributes:nil];
        
        AppDelegate *shareinst=[AppDelegate sharedDelegate];
        
        if (shareinst.SharedFile)
        {
            [[NSNotificationCenter defaultCenter]removeObserver:self name:@"RefreshingEndsForProfile" object:nil];
            
            if (shareinst.SharedFile.thumbnail_url == nil)
                return;
            NSDictionary *dic=@{@"path": shareinst.SharedFile.full_url,@"mini":shareinst.SharedFile.thumbnail_url};
            
            shareinst.SharedFile=nil;
            
            [[AppDelegate sharedDelegate] sendUpdatedContactWithImage:self.contact URL:dic];
        }
    }
    
    // Lin - Ended
}

#pragma mark - Action Sheet Delegate

- (IBAction)tapOnHelp:(id)sender
{
    
    if ([MFMailComposeViewController canSendMail]) {
        
        [[self logOUTInstance] makeupstakenil];
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.mailComposeDelegate = self;
        //[mailViewController setSubject:@"Subject Goes Here."];
        
        //[mailViewController setMessageBody:@"Your message goes here." isHTML:NO];
        [mailViewController setToRecipients:@[@"help@knote.com"]];
        [self presentViewController:mailViewController animated:YES completion:nil];
        
        
    }
    
    else {
        
        NSLog(@"Device is unable to send email in its current state.");
        
    }
   
}
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    UIAlertView *alert;
    switch (result)
    {
        case MFMailComposeResultCancelled:
            break;
        case MFMailComposeResultSaved:
            alert = [[UIAlertView alloc] initWithTitle:@"Draft Saved" message:@"Composed Mail is saved in draft." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            break;
        case MFMailComposeResultSent:
            alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"You have successfully sent mail." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            break;
        case MFMailComposeResultFailed:
            alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"Sorry! Failed to send." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [controller dismissViewControllerAnimated:YES completion:nil];
}
- (void) uploadProfilePhoto
{
    NSLog(@"%@", @"CHANGE PHOTO");
    
    UIActionSheet * photoActionSheet = [[UIActionSheet alloc] initWithTitle:Nil
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                     destructiveButtonTitle:Nil
                                                          otherButtonTitles:@"Take a Photo",  @"Choose From Library", Nil];
    
    [photoActionSheet showInView:self.view.superview];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = NO;
    picker.delegate = self;
    
    if(buttonIndex == 0)
    {
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:^{}];
    }
    else if(buttonIndex == 1)
    {
        picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
        
        [self presentViewController:picker animated:YES completion:^{}];
    }
    else
    {
        NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];
        
        if  ([buttonTitle isEqualToString:@"Cancel"])
        {
            NSLog(@"Cancel pressed --> Cancel Action");
        }
    }
}

-(void)turnViewEditable:(BOOL)editable
{
    if(editable)
    {
        self.editImageBut = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.editImageBut setFrame:CGRectMake(self.userImageView.frame.origin.x, self.userImageView.frame.origin.y - 64, USER_IMAGE_DIAMETER, USER_IMAGE_DIAMETER)];
        
        self.editImageBut.userInteractionEnabled = YES;
        [self.editImageBut setBackgroundColor:[UIColor clearColor]];
        
        [self.userImageView addSubview:self.editImageBut];
        
    }
    else
    {
        [self.editImageBut removeFromSuperview];
        
        [self.tableView reloadData];
    }
}

- (void)onEdit
{   
    if(!self.editing)
    {
        self.editing = YES;
        [self turnViewEditable:self.editing];
        
        [self.tableView reloadData];
        
        if (self.parentViewController)
        {
            self.parentViewController.navigationItem.rightBarButtonItem = Nil;
        }
        
    }
    else if(self.editing)
    {
        self.editing = NO;
        
        [self turnViewEditable:self.editing];
        
        if(currentResponder)
        {
            [currentResponder resignFirstResponder];
        }
        
        BOOL passwordStarted = ([self.passwordDictionary objectForKey:OLD_PASSWORD]) || ([self.passwordDictionary objectForKey:NEW_PASSWORD]) || ([self.passwordDictionary objectForKey:REPEAT_PASSWORD]);
        
        if (passwordStarted)
        {
            BOOL validated = [self changePassword];
            
            if(!validated)
            {
                return;
            }
        }
        
        // Mails are already in place
        // web & phone cannot be nil
        if(self.site)
        {
            self.contact.website = self.site;
        }
        else
        {
            self.contact.website = @"";
        }
        
        if(self.phone)
        {
            self.contact.phone = self.phone;
        }
        else
        {
            self.contact.phone = @"";
        }
        
        if(self.userImageAfterChange)
        {
            if (self.contact.fullURL)
            {
                [[SDImageCache sharedImageCache] storeImage:self.userImageAfterChange forKey:GET_CACHE_KEY_FOR_FULLURL(self.contact.account_id) toDisk:YES];
            }
            else
            {
                [[SDImageCache sharedImageCache] storeImage:self.userImageAfterChange forKey:self.contact.account_id toDisk:YES];
            }
            
            NSString *path  = [CUtil pathForCachedImage:self.contact.email];
            
            [[NSFileManager defaultManager] createFileAtPath:path contents:UIImagePNGRepresentation(self.userImageAfterChange) attributes:nil];
            
            AppDelegate *shareinst=[AppDelegate sharedDelegate];
            
            if (shareinst.SharedFile)
            {
                [[NSNotificationCenter defaultCenter]removeObserver:self name:@"RefreshingEndsForProfile" object:nil];
                
                NSDictionary *dic=@{@"path": shareinst.SharedFile.full_url,@"mini":shareinst.SharedFile.thumbnail_url};
                
                shareinst.SharedFile=nil;
                
                [[AppDelegate sharedDelegate] sendUpdatedContactWithImage:self.contact URL:dic];
            }
            else
            {
                [[AppDelegate sharedDelegate] sendUpdatedContact:self.contact];
            }
        }
        else
        {
            // Update contact
            [[AppDelegate sharedDelegate] sendUpdatedContact:self.contact];
        }
        
        KNCustomAlertView * alertView = [[KNCustomAlertView alloc] init];
        [self.view addSubview:alertView];
        [alertView animate];
        
    }
}

- (void)deleteEmails:(NSArray *)emails
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    for(NSString *email in emails)
    {
        [app.meteor callMethodName:@"removeself.contact_email"
                        parameters:@[self.contact.contact_id, email]
                  responseCallback:^(NSDictionary *response, NSError *error)
        {
            if(error)
            {
                NSLog(@"Error deleting email: %@", error);
            }
        }];
    }
}

-(BOOL)changePassword
{
    NSString *oldPassword = [self.passwordDictionary objectForKey:OLD_PASSWORD];
    NSString *newPassword = [self.passwordDictionary objectForKey:NEW_PASSWORD];
    NSString *repeatPassword = [self.passwordDictionary objectForKey:REPEAT_PASSWORD];
    
    BOOL passwordDone = oldPassword.length > 0 && newPassword.length > 0 && repeatPassword.length > 0;
    
    if(![oldPassword isEqualToString:self.user.password])
    {
        [self displayErrorAndRestPasswords:@"Current Password Not Correct"
                                   message:@"Your current password is incorrect. If you have forgotten it, Logout of the app and press the Password button."];
        
        return NO;
    }
    
    if(!passwordDone)
    {
        [self displayErrorAndRestPasswords:@"Incomplete"
                                   message:@"Please enter your current password, your new password, and repeat your new password."];
        return NO;
    }
    
    if(![newPassword isEqualToString:repeatPassword])
    {
        [self displayErrorAndRestPasswords:@"Passwords Don't Match"
                                   message:@"Please enter the passwords again."];
        
        return NO;
    }
    
    if(newPassword.length < 6)
    {
        [self displayErrorAndRestPasswords:@"Password Not Long Enough"
                                   message:@"You password must be at least 6 characters long."];
        
        return NO;
    }
    
    [[AppDelegate sharedDelegate].meteor callMethodName:@"resetPasswordFromiOS"
                                             parameters:@[newPassword]
                                       responseCallback:^(NSDictionary *response, NSError *error)
     {
        if(error)
        {
            NSLog(@"changePassword error: %@", error);
            
            id info = error.userInfo[NSLocalizedDescriptionKey];
            
            NSLog(@"error info: %@", info);
            
            [self displayErrorAndRestPasswords:@"Error Changing Passwords"
                                       message:@"We're sorry, there was a problem changing your password."];
            
        }
        
        if(response)
        {
            NSDictionary *parameters = @{@"isInitialSet": @NO};
            
            [[AnalyticsManager sharedInstance] notifyUserChangedPasswordWithParameters:parameters];
            
            [self.user setPassword:newPassword];
        }
    }];
    
    return YES;
    
}

#pragma mark -
#pragma mark Connect Google Account

-(IBAction)connectGoogle
{
    NSLog(@"connectGoogle");
    
    ConnectGoogleController *controller = [[ConnectGoogleController alloc] initWithNibName:nil bundle:nil];
    
    controller.delegate = self;
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
    
    [self presentViewController:navController animated:YES completion:^
    {
        NSLog(@"completed connectGoogle presentViewController");
        
    }];
}

-(void)cancelConnectGoogle
{
    NSLog(@"cancelConnectGoogle");
    
    [self dismissViewControllerAnimated:NO completion:^{
        self.parentViewController.navigationItem.rightBarButtonItem = Nil;
        NSLog(@"completed cancelConnectGoogle dismissViewControllerAnimated");
    }];
}

-(void)successConnectingGoogle:(NSString *)google_id user_id:(NSString *)google_user_id;
{
    self.account.google_linked = @(YES);
    self.account.google_id = google_id;
    self.account.google_user_id = google_user_id;
    [self updateGoogleButtonLink:NO];
    
    [AppDelegate saveContext];
    
    NSLog(@"successConnectingGoogle");
    
    [AppDelegate sharedDelegate].loadFromGoogleConnect = YES;
    
    [self dismissViewControllerAnimated:NO completion:^{
        self.parentViewController.navigationItem.rightBarButtonItem = Nil;
        NSLog(@"completed successConnectingGoogle dismissViewControllerAnimated");
    }];
}

- (void)unlinkGoogle
{
    MeteorClient *meteor = [AppDelegate sharedDelegate].meteor;
    
    
    if(self.account.google_user_id && self.account.google_user_id.length > 0)
    {
        NSLog(@"Removing google oauth with user ID: %@", self.account.google_user_id);
    }
    else
    {
        NSLog(@"Dont have google user ID to remove %@", self.account.google_user_id);
        
        return;
    }
    
    [meteor callMethodName:@"remove_google_oauth"
                parameters:@[self.account.google_user_id]
          responseCallback:^(NSDictionary *response, NSError *error)
    {
        if(error)
        {
            NSLog(@"Error removing google oauth: %@", error);
        }
        else
        {
            NSLog(@"Success removing google oath, response: %@", response);
            
            self.account.google_linked = @(NO);
            self.account.google_id = nil;
            self.account.google_user_id = nil;
            
            [self updateGoogleButtonLink:YES];
            
            [AppDelegate saveContext];
            
        }
        
    }];
    
}


@end
