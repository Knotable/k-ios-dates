//
//  ContactManager.m
//  Knotable
//
//  Created by Martin Ceperley on 5/6/14.
//
//

#import "ContactManager.h"
#import "DesignManager.h"
#import "DataManager.h"
#import "PostingManager.h"
#import "AnalyticsManager.h"
#import "CombinedViewController.h"
#import "ContactEmailTableTableViewController.h"
#import "CustomABPeoplePickerNavigationController.h"
#import "AccountEntity.h"
#import "UserEntity.h"
#import "ContactsEntity.h"

#import <OMPromises/OMPromises.h>
#import <AddressBook/ABAddressBook.h>
#import "NSString+Knotes.h"
#import "ObjCMongoDB.h"
#import "ThreadViewController.h"
#import "TopicInfo.h"

static NSString *knotableErrorDomain = @"knotable";
static int deniedAuthCode = 70;
static int cancelledAdressBookCode = 71;

#define From_Address_Book 0
#define Enter_An_Email 1
#define Enter_A_Username 2
#define Cancel_Index 4
#define Copy_Link 0

@interface ContactManager()

@property (nonatomic) BOOL addingPersonBymail;
@property (nonatomic, strong) UIActionSheet* addContactActionSheet;
@property (nonatomic, strong) NSArray* addressBookUserEmails;
@property (nonatomic, strong) NSArray* contacts;
@property (nonatomic) BOOL enteringContactByEmail;
@property (nonatomic, strong) ContactEmailTableTableViewController * contactEmailTableTableViewController;
@property (nonatomic, strong) CustomABPeoplePickerNavigationController *peoplePicker;

@property (nonatomic, strong) NSMutableArray * addPersonDeferreds;
@property (nonatomic, strong) UITextField * auxFireTextField;
@property (nonatomic, strong) MLPAutoCompleteTextField * customTextFieldForAddPerson;

@end

@implementation ContactManager{
@private
    OMDeferred *_addPersonDeferred;
    OMDeferred *_prePermissionDeferred;
    OMDeferred *_peoplePickerDeferred;
    UIAlertView *_prePermissionAlert;
    UIAlertView *_noEmailsAlert;
    UIViewController *_viewController;
    
    NSString *_tempUsername;
    UIAlertView *_addPersonAlert;
    UIAlertView *_preInviteAlert;
    UIAlertView *_invitePersonAlert;
    
    UIActionSheet *_selectEmailActionSheet;
    NSMutableDictionary *_addressBookEmailIndexes;
}

-(NSMutableArray *)addPersonDeferreds{
    if(!_addPersonDeferreds){
        _addPersonDeferreds = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return _addPersonDeferreds;
}

+ (ContactManager *)sharedInstance
{
    static ContactManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[ContactManager alloc] init];
    });
    return _sharedInstance;
}

+ (OMPromise *)doesUserExist:(NSString *)emailOrUsername
{
    return [self callMeteorMethod:@"isExistingUser" parameters:@[emailOrUsername]];
}

+ (OMPromise *)addNewContact:(NSString *)email username:(NSString *)username
{
    //We always have an email, but may need to get unique username from server
    if (!username)
    {
        OMPromise *chain = [[self generateUniqueUsername:email] then:^id(id result) {
            NSString *generatedUsername = result;
            NSLog(@"got unique username: %@", generatedUsername);
            
            return [self actualAddNewContact:email username:generatedUsername];
        }];
        
        return chain;
    }
    else
    {
        return [self actualAddNewContact:email username:username];
    }
}

+ (OMPromise *)generateUniqueUsername:(NSString *)email
{
    NSLog(@"generating unique username");
    
    NSArray *components = [email componentsSeparatedByString:@"@"];
    NSString *baseUsername = [components.firstObject stringByReplacingOccurrencesOfString:@"." withString:@"_"];
    
    OMDeferred *deferred = [OMDeferred deferred];
    
    [[self doesUserExist:baseUsername] fulfilled:^(NSNumber *existResultNumber) {
        BOOL exists = existResultNumber.boolValue;
        
        if (exists)
        {
            [[self callMeteorMethod:@"build_unique_username_by_email"
                         parameters:@[email]]
             fulfilled:^(id result)
             {
                 [deferred fulfil:result];
             }];
        } else {
            [deferred fulfil:baseUsername];
        }
    }];
    
    return deferred;
}

+ (OMPromise *)actualAddNewContact:(NSString *)email username:(NSString *)username
{
    NSDictionary *contactData = @{
                                  @"email":email,
                                  @"name":username,
                                  @"username":username,
                                  };
    
    return [[PostingManager sharedInstance] enqueueMeteorMethod:@"add_new_contact"
                                                     parameters:@[contactData, [DataManager sharedInstance].currentAccount.user.user_id, [DataManager sharedInstance].currentAccount.account_id]];
}


+ (OMPromise *)callMeteorMethod:(NSString *)methodName parameters:(NSArray *)params
{
    NSLog(@"method: %@ params: %@", methodName, params);
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    MeteorClient *meteor = app.meteor;
    
    if (meteor && meteor.connected)
    {
        OMDeferred *deferred = [OMDeferred deferred];
        
        [meteor callMethodName:methodName
                    parameters:params
              responseCallback:^(NSDictionary *response, NSError *error)
         {
             if (error)
             {
                 NSLog(@"Meteor error received: %@", error);
                 [deferred fail:error];
             }
             else
             {
                 id result = response[@"result"];
                 [deferred fulfil:result];
             }
         }];
        
        return deferred;
        
    }
    else
    {
        return [OMPromise promiseWithError:[NSError errorWithDomain:@"knotable" code:101 userInfo:@{@"code":@"not_connected",@"message":@"Not connected to Knotable"}]];
    }
}

-(OMPromise *)startAddPersonAddressBook
{
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    
    NSLog(@"Address book auth status: %ld", authStatus);
    
    if (authStatus == kABAuthorizationStatusAuthorized) {
        return [self presentPeoplePicker];
    } else if (authStatus == kABAuthorizationStatusDenied || authStatus == kABAuthorizationStatusRestricted) {
        return [self addressBookDeniedAuth];
    } else {
        return [self askForAddressBookPermissions];
    }
}

-(OMPromise *)presentPeoplePicker
{
    NSLog(@"presentPeoplePicker");
    
    _peoplePickerDeferred = [OMDeferred deferred];
    //self.peoplePicker=nil;
    if (self.peoplePicker==nil)
    {
        self.peoplePicker = [[CustomABPeoplePickerNavigationController alloc] init];
    }
    self.peoplePicker.navigationBar.barTintColor = [DesignManager navBarBackgroundColor];
    self.peoplePicker.navigationBar.tintColor = [DesignManager knoteHeaderTextColor];
    self.peoplePicker.displayedProperties = @[@(kABPersonEmailProperty)];
    
    
    self.peoplePicker.peoplePickerDelegate = self;
    self.peoplePicker.delegate = self;
    
    [[UIBarButtonItem appearanceWhenContainedIn:[ABPeoplePickerNavigationController class], nil] setTintColor:[UIColor whiteColor]];
    [_viewController presentViewController:self.peoplePicker animated:YES completion:^{
        
    }];
    
    return _peoplePickerDeferred;
}

-(void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person{
    self.contactEmailTableTableViewController = [[ContactEmailTableTableViewController alloc] init];
    
    ABMultiValueRef emailMultiValue = ABRecordCopyValue(person, kABPersonEmailProperty);
    NSArray *emailAddresses = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailMultiValue);
    NSMutableArray * aux = [[NSMutableArray alloc] initWithCapacity:3];
    for(NSString * mail in emailAddresses){
        if([mail rangeOfString:@"@"].location != NSNotFound){
            [aux addObject:mail];
        }
    }
    
    self.contactEmailTableTableViewController.mails = [aux copy];
    [peoplePicker pushViewController:self.contactEmailTableTableViewController animated:YES];
}

/*
 -(void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier{
 
 }
 */

// Called after a person has been selected by the user.
// Return YES if you want the person to be displayed.
// Return NO  to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person
{
    //ABMultiValueRef emails = ABRecordCopyValue(person, kABPersonEmailProperty);
    
    NSArray *emails = (__bridge_transfer NSArray *)(ABMultiValueCopyArrayOfAllValues(ABRecordCopyValue(person, kABPersonEmailProperty)));
    
    NSString *name = (__bridge_transfer NSString *)ABRecordCopyCompositeName(person);
    
    //CFIndex index = ABMultiValueGetIndexForIdentifier(emails, identifier);
    //NSString *email = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(emails, index);
    //NSLog(@"got name: %@ emails: %@", name, emails);
    
    self.addressBookUserEmails = emails;
    
    [_viewController dismissViewControllerAnimated:YES completion:^{
        
        [self gotEmailsFromAddressBook];
        
        //[_peoplePickerDeferred fulfil:emails];
        
        
    }];
    
    return NO;
    
}

-(OMPromise *)addressBookDeniedAuth
{
    NSString *deniedMessage = @"Knotable has been denied permission to read from your address book. Please go into System Settings > Privacy > Contacts to give permission.";
    UIAlertView *deniedAlert = [[UIAlertView alloc] initWithTitle:@"No Permission"
                                                          message:deniedMessage
                                                         delegate:nil
                                                cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [deniedAlert show];
    
    return [OMPromise promiseWithError:[NSError errorWithDomain:knotableErrorDomain code:deniedAuthCode userInfo:nil]];
}

-(OMPromise *)askForAddressBookPermissions
{
    _prePermissionAlert = [[UIAlertView alloc] initWithTitle:@"Let Knotable Access Address Book?"
                                                     message:@"This lets you choose a contact to add to Knotable."
                                                    delegate:self
                                           cancelButtonTitle:@"Not Now"
                                           otherButtonTitles:@"Give Access",nil];
    [_prePermissionAlert show];
    
    _prePermissionDeferred = [OMDeferred deferred];
    [_prePermissionDeferred fulfilled:^(id result) {
        NSLog(@"_prePermissionDeferred presentPeoplePicker");
        [self presentPeoplePicker];
    }];
    
    
    
    return _prePermissionDeferred;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UIAlertView * auxUIAlertViewCasted = (UIAlertView *)_addPersonAlert;
    
    if (alertView == _prePermissionAlert)
    {
        NSLog(@"_prePermissionAlert");
        
        if (buttonIndex == 1)
        {
            NSLog(@"show actual permission deferred: %@", _prePermissionDeferred);
            [_prePermissionDeferred fulfil:nil];
        }
        else
        {
            //user doesn't want to be asked permission
            NSLog(@"cancel");
            
            [_prePermissionDeferred fail:[NSError errorWithDomain:knotableErrorDomain code:deniedAuthCode userInfo:nil]];
        }
    }
    else if (alertView == auxUIAlertViewCasted)
    {
        if (buttonIndex == 1)
        {
            NSString *username_or_email = self.customTextFieldForAddPerson.text;
            _tempUsername = username_or_email;
            [self addPersonNamed:username_or_email];
            
        }
    }
    else if (alertView == _noEmailsAlert)
    {
        if (buttonIndex == 1)
        {
            [self startAddPersonEnter];
        }
    }
    else if (alertView == _invitePersonAlert & buttonIndex == 1)
    {
        NSString *email = [alertView textFieldAtIndex:0].text;
        
        [self inviteEmail:email];
    }
    else if(alertView == _preInviteAlert)
    {
        if (buttonIndex == 0)
        {
            //back to add person alert
            [self startAddPersonEnter];
        }
        else if (buttonIndex == 1)
        {
            //show invite alert
            [self invitePerson];
        }
    }
}

-(IBAction)invitePerson
{
    _invitePersonAlert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Invite %@", _tempUsername]
                                                    message:@"Enter their email"
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Invite",nil];
    
    _invitePersonAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    UITextField *textField = [_invitePersonAlert textFieldAtIndex:0];
    
    textField.keyboardType = UIKeyboardTypeEmailAddress;
    
    [_invitePersonAlert show];
}

// Called after the user has pressed cancel
// The delegate is responsible for dismissing the peoplePicker
- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker
{
    NSLog(@"people picker cancelled");
    [_viewController dismissViewControllerAnimated:YES completion:^{
        if ([_viewController isKindOfClass:[ThreadViewController class]])
        {
            [(ThreadViewController *)_viewController ShowAfterDismiss];
        }
    }];
    [_peoplePickerDeferred fail:[NSError errorWithDomain:knotableErrorDomain code:cancelledAdressBookCode userInfo:nil]];
}

- (void)gotEmailsFromAddressBook
{
    if (!self.addressBookUserEmails || self.addressBookUserEmails.count == 0) {
        _noEmailsAlert = [[UIAlertView alloc] initWithTitle:@"No Emails"
                                                    message:@"That person in your address book does not have any emails saved. Please enter their email."
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Enter email",nil];
        [_noEmailsAlert show];
        return;
    }
    
    if (self.addressBookUserEmails.count >= 1) {
        NSString *email = _addressBookUserEmails[0];
        [self addEmailFromAddressBook:email];
        return;
    }
    
    //More than one email
    
    _selectEmailActionSheet = [[UIActionSheet alloc] initWithTitle:@"Pick an Email"
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                            destructiveButtonTitle:nil
                                                 otherButtonTitles:nil];
    
    _addressBookEmailIndexes = [[NSMutableDictionary alloc] initWithCapacity:_addressBookUserEmails.count];
    
    for (NSString *email in _addressBookUserEmails)
    {
        NSInteger index = [_selectEmailActionSheet addButtonWithTitle:email];
        _addressBookEmailIndexes[@(index)] = email;
    }
    
    NSInteger cancelIndex = [_selectEmailActionSheet addButtonWithTitle:@"Cancel"];
    _selectEmailActionSheet.cancelButtonIndex = cancelIndex;
    
    [_selectEmailActionSheet showFromBarButtonItem:_viewController.navigationItem.rightBarButtonItem animated:YES];
}

- (void)didSelectAdressBookEmail:(NSInteger)index
{
    NSString *email = _addressBookEmailIndexes[@(index)];
    if (email) {
        [self addEmailFromAddressBook:email];
    }
}

- (void)addEmailFromAddressBook:(NSString *)email
{
    NSLog(@"did select email: %@", email);
    [self addPersonNamed:email];
}


// Called after a value has been selected by the user.
// Return YES if you want default action to be performed.
// Return NO to do nothing (the delegate is responsible for dismissing the peoplePicker).
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    [peoplePicker popToRootViewControllerAnimated:YES];
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
        [_viewController dismissViewControllerAnimated:YES completion:^{
        }];
    }];
    if ([_viewController isKindOfClass:[ThreadViewController class]])
    {
        [(ThreadViewController *)_viewController ShowAfterDismiss];
    }
    [CATransaction commit];
    return NO;
}


#pragma mark Add or Invite a Contact

-(void)showAlertSheetControllerForCombinedViewController
{
    UIAlertController * view = [UIAlertController alertControllerWithTitle:@"Add a Contact" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* fromAddressBook = [UIAlertAction actionWithTitle:@"From Address Book" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                      {
                                          [self addContactActionSheetPressed:From_Address_Book];
                                      }];
    
    UIAlertAction* enterAnEmail = [UIAlertAction actionWithTitle:@"Enter an Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                   {
                                       [self addContactActionSheetPressed:Enter_An_Email];
                                   }];
    
    UIAlertAction* enterAusername = [UIAlertAction actionWithTitle:@"Enter a Username" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                     {
                                         [self addContactActionSheetPressed:Enter_A_Username];
                                     }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [view addAction:fromAddressBook];
    [view addAction:enterAnEmail];
    [view addAction:enterAusername];
    [view addAction:cancel];
    [_viewController presentViewController:view animated:YES completion:nil];
}

-(void)showAlertSheetControllerForThreadViewController
{
    UIAlertController * view = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* copyLink = [UIAlertAction actionWithTitle:@"Copy Link" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                               {
                                   [self addContactActionSheetPressed:Copy_Link];
                               }];
    
    UIAlertAction* fromAddressBook = [UIAlertAction actionWithTitle:@"From Address Book" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                      {
                                          [self addContactActionSheetPressed:From_Address_Book+1];
                                      }];
    
    UIAlertAction* enterAnEmail = [UIAlertAction actionWithTitle:@"Enter an Email" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                   {
                                       [self addContactActionSheetPressed:Enter_An_Email+1];
                                   }];
    
    UIAlertAction* enterAusername = [UIAlertAction actionWithTitle:@"Enter a Username" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action)
                                     {
                                         [self addContactActionSheetPressed:Enter_A_Username+1];
                                     }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault  handler:^(UIAlertAction * action)
                             {
                                 [self addContactActionSheetPressed:Cancel_Index];
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [view addAction:copyLink];
    [view addAction:fromAddressBook];
    [view addAction:enterAnEmail];
    [view addAction:enterAusername];
    [view addAction:cancel];
    [_viewController presentViewController:view animated:YES completion:nil];
}

-(OMPromise *)startAddPerson:(UIViewController *)vc
{
    OMDeferred *d = [OMDeferred deferred];
    
    [self.addPersonDeferreds addObject:d];
    
    _viewController = vc;
    
    float iosversion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if ([_viewController isKindOfClass:[CombinedViewController class]])
    {
        if ( iosversion >= 8.0f)
        {
            [self showAlertSheetControllerForCombinedViewController];
        }
        else
        {
            self.addContactActionSheet = [[UIActionSheet alloc] initWithTitle:@"Add a Contact"
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"From Address Book", @"Enter an Email", @"Enter a Username", nil];
            
            [self.addContactActionSheet showInView:_viewController.view];
        }
        
    }
    else
    {
        if ( iosversion >= 8.0f)
        {
            [self showAlertSheetControllerForThreadViewController];
        }
        else
        {
            self.addContactActionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                                     delegate:self
                                                            cancelButtonTitle:@"Cancel"
                                                       destructiveButtonTitle:nil
                                                            otherButtonTitles:@"Copy Link",@"Add From Address Book", @"Enter an Email", @"Enter a Username", nil];
            
            [self.addContactActionSheet showInView:_viewController.view];
        }
    }
    
    return d;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    //In case of IOS8 we are bypassing this method and calling directly addContactActionSheetPressed & didSelectAdressBookEmail From blocks. @Malik
    
    if (_addContactActionSheet && _addContactActionSheet == actionSheet) {
        [self addContactActionSheetPressed:buttonIndex];
    } else if (_selectEmailActionSheet && _selectEmailActionSheet == actionSheet) {
        [self didSelectAdressBookEmail:buttonIndex];
    }
}

-(void)addContactActionSheetPressed:(NSInteger)index
{
    if ([_viewController isKindOfClass:[CombinedViewController class]])
    {
        if (index == 0) {
            //Address book
            [self startAddPersonAddressBook];
        } else if (index == 1) {
            //Enter an email
            self.enteringContactByEmail = YES;
            self.addingPersonBymail = YES;
            [self startAddPersonEnter];
        } else if (index == 2) {
            self.enteringContactByEmail = NO;
            [self startAddPersonEnter];
        }
    }
    else
    {
        if (index == 0) {
            Utilities *util=[[Utilities alloc]init];
            
            NSString *newURL= [util getTopicURLFrom:[[(ThreadViewController *)_viewController tInfo] entity]];
            if (newURL.length>0)
            {
                [AJNotificationView showNoticeInView:[[[UIApplication sharedApplication] delegate] window]
                                                type:AJNotificationTypeGreen
                                               title:[NSString stringWithFormat:@"Link Copied!"]
                                     linedBackground:AJLinedBackgroundTypeAnimated
                                           hideAfter:1.0f
                                              offset:64.0f
                                               delay:0.0f
                                            response:^{
                                            }];
                
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string=newURL;
            }
            
        }else if (index == 1) {
            //Address book
            [self startAddPersonAddressBook];
        } else if (index == 2) {
            //Enter an email
            self.enteringContactByEmail = YES;
            [self startAddPersonEnter];
        } else if (index == 3) {
            //Enter an email
            self.enteringContactByEmail = NO;
            [self startAddPersonEnter];
        }
        else if (index==4)
        {
            [(ThreadViewController *)_viewController performSelector:@selector(ShowAfterDismiss) withObject:nil afterDelay:0.5];
            /*[(ThreadViewController *)_viewController ShowAfterDismiss];*/
        }
    }
    
}

-(void)startAddPersonEnter {
    
    NSString * message;
    if(self.enteringContactByEmail){
        message = @"Please enter an email";
    }else{
        message = @"Please enter a username";
    }
    
    _tempUsername = nil;
    _addPersonAlert = [[UIAlertView alloc] initWithTitle:@"Add a Person"
                                                 message:message
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Add", nil];
    
    _addPersonAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    self.customTextFieldForAddPerson = [[MLPAutoCompleteTextField alloc] initWithFrame:CGRectMake(10, 0, 250, 20)];
    self.customTextFieldForAddPerson.backgroundColor = [UIColor whiteColor];
    self.customTextFieldForAddPerson.autoCompleteDataSource = self;
    self.customTextFieldForAddPerson.autoCompleteTableAppearsAsKeyboardAccessory = YES;
    self.customTextFieldForAddPerson.userInteractionEnabled = YES;
    
    UIView * auxContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 40)];
    auxContainerView.backgroundColor = [UIColor clearColor];
    [auxContainerView addSubview:self.customTextFieldForAddPerson];
    
    self.auxFireTextField = [_addPersonAlert textFieldAtIndex:0];
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        [_addPersonAlert setValue:auxContainerView forKey:@"accessoryView"];
    }else
    {
        [_addPersonAlert addSubview:auxContainerView];
    }
    
    [_addPersonAlert show];
}

- (NSArray *)autoCompleteTextField:(MLPAutoCompleteTextField *)textField
      possibleCompletionsForString:(NSString *)string
{
    
    NSMutableArray * toRet = [NSMutableArray array];
    
    if( (self.enteringContactByEmail) && ((!self.addressBookUserEmails) || (self.addressBookUserEmails.count <= 1)) ){
        self.addressBookUserEmails = [self getMyPhoneContacts];
    }else if( (!self.enteringContactByEmail) && (!self.contacts) ){
        self.contacts = [self findAllContacts];
    }
    
    if(self.enteringContactByEmail){
        for(NSMutableDictionary * personDic in self.addressBookUserEmails){
            if([personDic objectForKey:@"email"]){
                if( [[[personDic objectForKey:@"email"] lowercaseString] rangeOfString:[string lowercaseString]].location != NSNotFound ){
                    // contact is a viable option
                    [toRet addObject:[personDic objectForKey:@"email"]];
                }
            }
            
        }
    }
    else
    {
        for(ContactsEntity * contact in self.contacts){
            if(contact && contact.name){
                if( [[contact.name lowercaseString] rangeOfString:[string lowercaseString]].location != NSNotFound ){
                    [toRet addObject:contact.name];
                }
            }
        }
    }
    
    [self.auxFireTextField sendActionsForControlEvents:UIControlEventEditingChanged];
    
    return [toRet copy];
}

- (NSArray *)getMyPhoneContacts{
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    
    __block BOOL accessGranted = NO;
    
    if (ABAddressBookRequestAccessWithCompletion != NULL) { // We are on iOS 6
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            accessGranted = granted;
            dispatch_semaphore_signal(semaphore);
        });
        
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        //dispatch_release(semaphore);
    }
    
    else { // We are on iOS 5 or Older
        accessGranted = YES;
        return [self getContactsWithAddressBook:addressBook];
    }
    
    if (accessGranted) {
        return [self getContactsWithAddressBook:addressBook];
    }
    
    return [[NSArray alloc] init];
    
}

- (NSArray *)getContactsWithAddressBook:(ABAddressBookRef )addressBook {
    
    NSMutableArray *contactList = [[NSMutableArray alloc] init];
    CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    CFIndex nPeople = ABAddressBookGetPersonCount(addressBook);
    
    for (int i=0;i < nPeople;i++) {
        NSMutableDictionary *dOfPerson=[NSMutableDictionary dictionary];
        
        ABRecordRef ref = CFArrayGetValueAtIndex(allPeople,i);
        
        //For username and surname
        ABMultiValueRef phones =(__bridge ABMultiValueRef)((__bridge NSString*)ABRecordCopyValue(ref, kABPersonPhoneProperty));
        
        CFStringRef firstName, lastName;
        
        firstName = ABRecordCopyValue(ref, kABPersonFirstNameProperty);
        lastName  = ABRecordCopyValue(ref, kABPersonLastNameProperty);
        if (firstName == nil) {
            [dOfPerson setObject:@"" forKey:@"name"];
        }else if(lastName == nil){
            [dOfPerson setObject:[NSString stringWithFormat:@"%@", firstName] forKey:@"name"];
        }else{
            [dOfPerson setObject:[NSString stringWithFormat:@"%@ %@", firstName,lastName] forKey:@"name"];
        }
        
        
        //For Email ids
        ABMutableMultiValueRef eMail  = ABRecordCopyValue(ref, kABPersonEmailProperty);
        if(ABMultiValueGetCount(eMail) > 0) {
            [dOfPerson setObject:(__bridge NSString *)ABMultiValueCopyValueAtIndex(eMail, 0) forKey:@"email"];
            
        }
        
        //For Phone number
        NSString* mobileLabel;
        
        for(CFIndex i = 0; i < ABMultiValueGetCount(phones); i++) {
            mobileLabel = (__bridge NSString*)ABMultiValueCopyLabelAtIndex(phones, i);
            if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
            }
            else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel])
            {
                [dOfPerson setObject:(__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, i) forKey:@"Phone"];
                break ;
            }
            
        }
        //For Contact Image
        if (ABPersonHasImageData(ref)) {
            NSData *contactImageData = (__bridge NSData *)ABPersonCopyImageDataWithFormat(ref, kABPersonImageFormatThumbnail);
            
            [dOfPerson setObject:contactImageData forKey:@"image"];
        }
        
        [contactList addObject:dOfPerson];
        
    }
    
    return [contactList copy];
}

- (void)addPersonNamed:(NSString *)name
{
    NSLog(@"addPersonNamed: %@", name);
    
    name = [name trimmed];
    
    if(!name || name.length == 0){
        NSLog(@"empty name!");
        [self displayValidationErrorMessage:@"Invalid email address"];
        return;
    }
    
    __block NSString *username = nil;
    __block NSString *email = nil;
    
    NSArray *emailParts = [name componentsSeparatedByString:@"@"];
    NSLog(@"emailParts: %@", emailParts);
    if(emailParts.count == 2){
        //an email address was entered (not a username)
        email = [name copy];
        
        if(![email isValidEmail]){
            [self displayValidationErrorMessage:@"Invalid email address"];
            return;
        }
        
        if([self haveContactWithEmail:email]){
            [self displayValidationErrorMessage:@"That person is already present"];
            return;
        }
        
        [self enqueueRemoteEmailAdd:email];
        
        
        
    } else if(emailParts.count == 1){
        if(self.addingPersonBymail){
            [self displayValidationErrorMessage:@"Invalid email address"];
        }else{
            //a username was entered (not an email address)
            username = [name copy];
            [self enqueueRemoteUsernameAdd:username];
        }
    } else {
        //invalid input
        [self displayValidationErrorMessage:@"Invalid email address"];
        return;
    }
}

- (void)enqueueRemoteEmailAdd:(NSString *)email
{
    [[PostingManager sharedInstance] enqueueLocalMethod:ADD_CONTACT_FROM_EMAIL parameters:email];
}

- (void)enqueueRemoteUsernameAdd:(NSString *)username
{
    [[PostingManager sharedInstance] enqueueLocalMethod:ADD_CONTACT_FROM_USERNAME parameters:username];
}

- (void)performRemoteUsernameAdd:(NSString *)username
{
    [self sendAddPerson:username];
    
}

- (void)performRemoteEmailAdd:(NSString *)email
{
    //Look up the email adress in Mongo
    __block NSString *username;
    
    [[AppDelegate sharedDelegate] sendRequestUser:nil
                                            email:email
                                withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
     {
         if (success == NetworkSucc)
         {
             NSDictionary *userDict = nil;
             
             if (userData)
             {
                 userDict = [(NSDictionary *)userData copy];
             }
             
             // Lin - Added new scenario from new API
             
             if (userDict)
             {
                 if ([userDict objectForKey:@"username"])
                 {
                     //User exists, we can just add them
                     
                     username = userDict[@"username"];
                     
                     [self sendAddPerson:username];
                 }
                 else
                 {
                     //No user present, invite them with new username from first part of email address
                     NSArray *emailParts = [email componentsSeparatedByString:@"@"];
                     
                     username = emailParts.firstObject;
                     
                     [self meteorAddContact:nil email:email];
                 }
             }
             
             // Lin - Ended
             
         }
         else
         {
             [self displayValidationErrorMessage:@"Add Person Failure."];
         }
     }];
    
}

- (void)inviteEmail:(NSString *)email
{
    if(![email isValidEmail]){
        [self displayValidationErrorMessage:@"Invalid email address"];
        return;
    }
    
    NSString *username = [email componentsSeparatedByString:@"@"].firstObject;
    
    if (_tempUsername && _tempUsername.length > 0)
    {
        username = _tempUsername;
    }
    
    [self meteorAddContact:nil email:email];
}


- (void)meteorAddContact:(NSString *)username email:(NSString *)email
{
    NSLog(@"calling addNewContact with username: %@ email: %@", username, email);
    
    [[[ContactManager addNewContact:email username:username] fulfilled:^(id result) {
        
        NSDictionary *parameters = @{@"contactEmail": email};
        
        [[AnalyticsManager sharedInstance] notifyContactWasAddedWithParameters:parameters];
        
        NSLog(@"addNewContact result: %@", result);
        
        for(OMDeferred * deferred in self.addPersonDeferreds){
            if(deferred.state == OMPromiseStateUnfulfilled){
                [deferred fulfil:email];
                break;
            }
        }
        
        //[_addPersonDeferred fulfil:email];
        
        
    }] failed:^(NSError *error) {
        NSLog(@"failure calling add_new_contact: %@", error);
        
        for(OMDeferred * deferred in self.addPersonDeferreds){
            if(deferred.state == OMPromiseStateUnfulfilled){
                [deferred fail:error];
                break;
            }
        }
        //[_addPersonDeferred fail:error];
    }];
}


-(void)sendAddPerson:(NSString *)username
{
    if([self haveContactWithName:username])
    {
        [self displayValidationErrorMessage:@"That person is already your contact"];
        
        return;
    }
    
    __block NSString *email = nil;
    
    [[AppDelegate sharedDelegate] sendRequestUser:username
                                            email:nil
                                withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData) {
                                    
                                    if (success == NetworkSucc)
                                    {
                                        NSDictionary *userDict = [(NSDictionary *)userData copy];
                                        
                                        NSLog(@"sendRequestUser received userDict: %@", userDict);
                                        
                                        if(userDict)
                                        {
                                            NSArray *emailData = userDict[@"emails"];
                                            
                                            if(emailData.count > 0)
                                            {
                                                id firstObject  =emailData.firstObject;
                                                if ([firstObject isKindOfClass:[NSString class]])
                                                {
                                                    email = (NSString *)firstObject;
                                                }
                                                else if ([firstObject isKindOfClass:[NSDictionary class]])
                                                {
                                                    email = (NSString *)emailData.firstObject[@"address"];
                                                }
                                            }
                                            
                                            //Finally, save the new contact to meteor
                                            if(username && email && username.length > 0 && email.length > 0)
                                            {
                                                [self meteorAddContact:username email:email];
                                            }
                                        }
                                        else
                                        {
                                            //Username not present
                                            
                                            _preInviteAlert = [[UIAlertView alloc] initWithTitle:@""
                                                                                         message:@"That person doesn't use Knotable yet"
                                                                                        delegate:self
                                                                               cancelButtonTitle:@"Try again"
                                                                               otherButtonTitles:@"Invite them", nil];
                                            [_preInviteAlert show];
                                            
                                        }
                                    }
                                    else
                                    {
                                        NSLog(@"sendRequestUser with username: %@ got result code: %d error: %@", username, success, error);
                                        [self displayValidationErrorMessage:@"Add Person Failure."];
                                    }
                                    
                                }];
}

- (void)displayValidationErrorMessage:(NSString *)message
{
    NSLog(@"Validation error: %@", message);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't Add Person"
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}

- (NSArray *) findAllContacts{
    return [ContactsEntity MR_findAll];
}

- (BOOL)haveContactWithName:(NSString *)name
{
    return [ContactsEntity MR_findFirstByAttribute:@"name" withValue:name] != nil;
}

- (BOOL)haveContactWithEmail:(NSString *)email
{
    return [ContactsEntity MR_findFirstByAttribute:@"email" withValue:email] != nil;
}

+ (void)findContactFromServerByAccountId:(NSString *)account_id
                          withNofication:(NSString *)notiStr
                       withCompleteBlock:(DownloadContactCompletion)block
{
    if (account_id)
    {
        [[AppDelegate sharedDelegate] sendRequestContactByAccountId:account_id
                                                  withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
         {
             switch (success)
             {
                 case NetworkSucc:
                 {
                     NSArray *resultDoc = (NSArray *)userData;
                     
                     if (resultDoc && [resultDoc isKindOfClass:[NSArray class]])
                     {
                         if ([resultDoc count]>0)
                         {
                             [[MagicalRecordStack defaultStack] saveWithBlock:^(NSManagedObjectContext *localContext) {
                                 
                                 for(BSONDocument *bsonDocument in resultDoc)
                                 {
                                     NSDictionary *dict = (NSDictionary*)bsonDocument;
                                     
                                     [ContactsEntity contactWithDict:dict inContext:localContext];
                                 }
                                 
                             } completion:^(BOOL success, NSError *error) {
                                 
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     
                                     if (block)
                                     {
                                         block(NetworkSucc,nil,nil);
                                     }
                                     else
                                     {
                                         [[NSNotificationCenter defaultCenter] postNotificationName:notiStr object:nil];
                                     }
                                 });
                             }];
                         }
                         
                     }
                     
                 }
                     break;
                     
                 default:
                     break;
             }
             
         }];
    }
}

+ (void)findContactFromServerByEmail:(NSString *)email
{
    [[AppDelegate sharedDelegate] sendRequestContactByEmail:email
                                          withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData) {
                                              switch (success) {
                                                  case NetworkSucc:
                                                  {
                                                      NSMutableArray *add_contacts = [NSMutableArray new];
                                                      
                                                      NSDictionary *resultDoc = (NSDictionary *)userData;
                                                      
                                                      [[MagicalRecordStack defaultStack] saveWithBlock:^(NSManagedObjectContext *localContext) {
                                                          
                                                          for(BSONDocument *bsonDocument in resultDoc)
                                                          {
                                                              NSDictionary *dict = [bsonDocument dictionaryValue];
                                                              
                                                              ContactsEntity *savedContact =[ContactsEntity  contactWithDict:dict inContext:localContext];
                                                              
                                                              if (savedContact && ![savedContact isFault] && savedContact.name)
                                                              {
                                                                  [add_contacts addObject:savedContact.name];
                                                              }
                                                          }
                                                          
                                                      } completion:^(BOOL success, NSError *error) {
                                                          
                                                          dispatch_async(dispatch_get_main_queue(), ^{
                                                              
                                                              [[NSNotificationCenter defaultCenter] postNotificationName:NEW_CONTACT_DOWNLOADED_NOTIFICATION object:nil];
                                                              
                                                          });
                                                      }];
                                                  }
                                                      break;
                                                  default:
                                                      break;
                                              }
                                          }];
}


@end
