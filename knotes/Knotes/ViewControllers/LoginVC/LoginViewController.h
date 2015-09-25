//
//  ViewController.h
//  Knote
//
//  Created by JYN on 9/19/13.
//  Copyright (c) 2013 jackiejin. All rights reserved.
//
#import <CoreData/CoreData.h>
#import <UIKit/UIKit.h>
#import <ObjectiveDDP/MeteorClient.h>
#import "LoginProcessViewController.h"
#import <MessageUI/MessageUI.h>

#define kDBName @"Knotable18"
#define kContactsCache @"kContactsCache"

@class AccountEntity, MeteorClient;

@interface LoginViewController : UIViewController<UITextFieldDelegate,MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) LoginProcessViewController *loginProcess;
-(void)loginNetworkResult:(id)obj withCode:(NSInteger)code;
-(void)reset;
-(void)getLinkActivate;
-(void)updateServerName;

// Lin - Added to fix wrong login scenario
- (void) hideLoadingProcess;
// Lin - Ended

- (void) showPermissionScreens;

- (void)delayLogin;
@end
