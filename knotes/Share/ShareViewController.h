//
//  ShareViewController.h
//  Share
//
//  Created by Nicolas  on 13/5/15.
//
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <ObjectiveDDP/MeteorClient.h>
#import "FileEntity.h"
#import "constant.h"
#import "ContactsEntity.h"
#import "ThreadCommon.h"

#define kDateFormat1 @"MMM dd yyyy, hh:mm:ss aa"

@class ServerConfig, MeteorClient, AccountEntity;

@interface ShareViewController : UIViewController<UITextViewDelegate,UITableViewDelegate,UITableViewDataSource>


@property (weak, nonatomic) IBOutlet UITableView *tableView;



- (IBAction)createNewPad:(id)sender;

- (IBAction)cancelAction:(id)sender;

@property (strong, atomic) MeteorClient *meteor;
@property (strong, atomic) MeteorClient *meteorOld;
@property (nonatomic, strong) ServerConfig *server;
@property (nonatomic, readonly) NSString *serverID;
@property (nonatomic, readonly) NSArray *allServerConfigs;
@property (weak, nonatomic) IBOutlet UIView *sharedView;
@property (weak, nonatomic) IBOutlet UIView *notiView;

@property (strong, nonatomic) NSString* appUserAccountID;

@end
