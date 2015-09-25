 /*
 
 Copyright (c) 2011, Philip Kluz (Philip.Kluz@zuui.org)
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of Philip Kluz, 'zuui.org' nor the names of its contributors may 
 be used to endorse or promote products derived from this software 
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL PHILIP KLUZ BE LIABLE FOR ANY DIRECT, 
 INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 */

#import "AppDelegate.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

#import "LoginViewController.h"
#import "CombinedViewController.h"
#import "GameUnit.h"

#import "AccountEntity.h"
#import "ContactsEntity.h"
#import "MessageEntity.h"
#import "TopicsEntity.h"
#import "UserEntity.h"
#import "ObjCMongoDB.h"
#import "MeteorClient+Private.h"
#import "ServerConfig.h"
#import "FileEntity.h"
#import "DataManager.h"
#import "ReachabilityManager.h"
#import "WelcomeViewController.h"
#import "CUtil.h"
#import "DesignManager.h"
#import "PostingManager.h"
#import <OMPromises/OMPromises.h>
#import "MCAWSS3Client.h"
#import "SDWebImageManager.h"
#import "Constant.h"
#import "Global.h"

#import "MyProfileController.h"
#import "UITabBarController+HideTabbar.h"
#import "AnalyticsManager.h"
#import "CachedUrlsEntity.h"
#import "ContactManager.h"
#import <Lookback/Lookback.h>
#import "NSString+Knotes.h"
#import "MeteorClient.h"
#import <ObjectiveDDP/MeteorClient.h>
#import "ThreadCommon.h"
#import "M13OrderedDictionary.h"
#import <AudioToolbox/AudioServices.h>
#import "KnotesNavigationController.h"
#import "BWStatusBarOverlay.h"
#if New_DrawerDesign
#import "SideMenuViewController.h"
#endif

#include "InitialComposeViewController.h"
#include "ComposeThreadViewController.h"

#define DOWNLOAD_SERVER_FROM_S3         1
#define DELAY_TO_LOAD_USER_FROM_SERVER  5.0

@interface AppDelegate(){
    
}
@property (nonatomic, strong) NSString * meteorUsername;
@property (nonatomic, strong) NSString * meteorPassword;
@property (nonatomic, strong) NSDate * sessionLeftDate;
@property (nonatomic, strong) NSDate *lastSeenDate;
@property (nonatomic, assign) BOOL backgroundMeteorLogin;
@end

@implementation AppDelegate
//@synthesize window = _window;
//@synthesize navController = _navController;
//@synthesize appUserAccountID = _appUserAccountID;
//@synthesize loadFromGoogleConnect;

static const int sessionKeepAliveTimeout = 30;

+ (AppDelegate*)sharedDelegate
{
    return (AppDelegate*)[UIApplication sharedApplication].delegate;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    DLog(@"application didFinishLaunchingWithOptions: %@", launchOptions);
    
    _hasLogin = NO;
    
    self.user_active_topics = 0;
    self.user_archived_topics = 0;
    
    self.calendarEventManager = [[CalendarEventManager alloc] init];
    
    // CrashlticsKit SDK
    
    [Fabric with:@[CrashlyticsKit]];
    [Crashlytics startWithAPIKey:CRASHLYTICS_KNOTABLE_APIKEY];
    
    // Lookback.IO Frmaework
    
    [Lookback_Weak setupWithAppToken:LOOKBACK_KNOTABLE_TOKEN];
    
#if DEBUG || ADHOC
    
    [Lookback_Weak lookback].shakeToRecord = YES;
    
#endif
    
    // Automatically put an experience's URL on the user's pasteboard when recording ends and upload starts.
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LookbackStartedUploadingNotificationName
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
        
        NSDate *when = [note userInfo][LookbackExperienceStartedAtUserInfoKey];
        
        if(fabs([when timeIntervalSinceNow]) < 60)
        {
            // Only if it's for an experience we just recorded
            
            NSURL *url = [note userInfo][LookbackExperienceDestinationURLUserInfoKey];
            
            DLog(@"Lookback URL : %@", url.absoluteString);
            
            [UIPasteboard generalPasteboard].URL = url;
            
            [self HideAlert:@"Lookback User Experience"
             messageContent:@"Lookback User Experience's link was copid in Pasteboard"
                  withDelay:5.0];
        }
    }];
       
    float   currentVesion = 6.0;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= currentVesion)
    {
        [[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
    }
    
    glbAppdel =self;
    
    self.firstIn = YES;
    
    [[PostingManager sharedInstance] startMonitoring];
    [[ReachabilityManager sharedInstance] registerNotifier];
    
    [self startSession];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [self loadServerConfig];

    [DataManager sharedInstance];

    SQLiteMagicalRecordStack *stack =
        [SQLiteMagicalRecordStack
            stackWithStoreNamed:[NSString stringWithFormat:@"%@.db", kDBName]
                          model:[NSManagedObjectModel mergedModelFromBundles:nil]];
    
    stack.shouldDeletePersistentStoreOnModelMismatch = YES;
    
    [MagicalRecordStack setDefaultStack:stack];
    
#if DEBUG // for simulate
    
    NSPersistentStoreCoordinator *psc = [stack coordinator];
    
    NSError *error = nil;
    
    NSMutableDictionary *sqliteOptions = [NSMutableDictionary dictionary];
    [sqliteOptions setObject:@"DELETE" forKey:@"journal_mode"];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption,
                             sqliteOptions, NSSQLitePragmasOption,
                             nil];

    
    NSURL *url = [NSPersistentStore MR_fileURLForStoreNameIfExistsOnDisk:[NSString stringWithFormat:@"%@.db", kDBName]];
    [psc removePersistentStore:stack.store error:&error];
    
    NSPersistentStore *persistentStore = [psc addPersistentStoreWithType:NSSQLiteStoreType
                                                           configuration:nil
                                                                     URL:url
                                                                 options:options
                                                                   error:&error];
    
    if (! persistentStore)
    {
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        
        abort();
    }
    
    stack.store = persistentStore;
    
#endif
    
    [self connectServer:[self.server meteorWebsocketURL]];
    
    //[[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setDefaultTextAttributes: @{NSForegroundColorAttributeName : [UIColor blackColor]}];

    //DLog(@"core data stack: %@", stack);
    
    g_GameUnit = [[GameUnit alloc] init];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    // Lin - Added for Global Initialization
    
    gScreenSize = self.window.frame.size;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        gDeviceType = DEVICE_IPAD;
    }
    else if (self.window.frame.size.height == 568)
    {
        gDeviceType = DEVICE_IPHONE_40INCH;
    }
    else if ((self.window.frame.size.height == 1024) || (self.window.frame.size.height == 768))
    {
        gDeviceType = DEVICE_IPAD;
    }
    else
    {
        gDeviceType = DEVICE_IPHONE_35INCH;
    }
    
    float iosversion = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if ( iosversion >= 7.0f)
    {
        gIOSVersion = IOS_7;
    }
    else if (iosversion >= 6.0f && iosversion < 7.0f)
    {
        gIOSVersion = IOS_6;
    }
    else if (iosversion >= 5.0f && iosversion < 6.0f)
    {
        gIOSVersion = IOS_5;
    }
    else if (iosversion >= 4.0f && iosversion < 5.0f)
    {
        gIOSVersion = IOS_4;
    }
    
    gDeviceOrientation = UIInterfaceOrientationPortrait;
    
    UIGraphicsBeginImageContext(self.window.bounds.size);
    
    [[UIImage imageNamed:@"background"] drawInRect:self.window.bounds];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    self.window.backgroundColor = [UIColor colorWithPatternImage:image];
    
    UIStoryboard* board = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
    self.loginController = [board instantiateViewControllerWithIdentifier: @"LoginView"];
    
    
//    self.loginController = [[LoginViewController alloc] init];
//
    self.navController = [[KnotableNavigationController alloc] initWithRootViewController:self.loginController];
    
    self.navController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navController;
    
    AccountEntity* lastAccount = [AccountEntity MR_findFirstOrderedByAttribute:@"lastLoggedIn" ascending:NO];
    
    [DataManager sharedInstance].currentAccount = lastAccount;
    
    DLog(@"set currentAccount to %@", lastAccount);
    
   /* if (lastAccount != nil) {
        NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] init];
        
        [userInfo setObject:lastAccount.user.email forKey:@"email"];
        [userInfo setObject:lastAccount.user.name forKey:@"name"];
        [userInfo setObject:lastAccount.hashedToken forKey:@"sessionToken"];
        
        NSUserDefaults *extensionUserDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.knotable.knotedev.share"];
        [extensionUserDefaults setObject:userInfo forKey:@"userInfo"];
        [extensionUserDefaults synchronize];
    }*/
    
    
    
#if true
    
    self.backgroundMeteorLogin = NO;

    if (lastAccount
        && lastAccount.loggedIn.boolValue
        && lastAccount.account_id)
    {
        //Logged in
//        UIStoryboard *storybord = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
//        UIViewController *knotesScreenVC = [storybord instantiateViewControllerWithIdentifier: @"KnotesScreen"];
//        [self.navController pushViewController: knotesScreenVC animated: NO];
        
        [self login:NO];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(meteorClientConnectionReady:)
                                                     name:MeteorClientConnectionReadyNotification
                                                   object:nil];
        self.backgroundMeteorLogin = YES;
    }
    else
    {
        // show pre-login walkthrough
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        BOOL bFirstUser = YES;
        
        if ([[[userDefault dictionaryRepresentation] allKeys] containsObject:kFirstUserKey])
        {
            if ([userDefault objectForKey:kFirstUserKey] != Nil)
            {
                bFirstUser = [userDefault boolForKey:kFirstUserKey];
            }
            else
            {
                [userDefault setObject:@YES forKey:kFirstUserKey];
            }
            
            bFirstUser = [[userDefault objectForKey:kFirstUserKey] boolValue];
            
            if (bFirstUser)
            {
                // show pre-login walkthrough
                WelcomeViewController *welcomeController = [[WelcomeViewController alloc] init];
                
                [self.navController pushViewController:welcomeController animated:NO];
            }
        }
        else
        {
            [userDefault setObject:@YES forKey:kFirstUserKey];
            
            [userDefault synchronize];
            
            bFirstUser = [userDefault boolForKey:kFirstUserKey];
            
            if (bFirstUser)
            {
                // show pre-login walkthrough
                
                WelcomeViewController *welcomeController = [[WelcomeViewController alloc] init];
                
                [self.navController pushViewController:welcomeController animated:NO];
            }
        }
        
    }
    
#else
    
    WelcomeViewController *welcomeController = [[WelcomeViewController alloc] init];
    
    [self.navController pushViewController:welcomeController animated:NO];
    
#endif
    
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(meteorError:)
                                                 name:MeteorClientTransportErrorDomain
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(meteorAdded:)
                                                 name:@"added"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(meteorRemoved:)
                                                 name:@"removed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(popUpMessage:)
                                                 name:KnotebleShowPopUpMessage
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needChangeMogoDbServer:)
                                                 name:kNeedChangeMongoDbServer
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needChangeApplicationHost:)
                                                 name:kNeedChangeApplicationHost
                                               object:nil];

    

    self.loadFromGoogleConnect = NO;
    
    [self deleteOldTemporaryTopic];
    
    return YES;
}

- (void)deleteOldTemporaryTopic {
    NSString *topicId = [[NSUserDefaults standardUserDefaults] objectForKey:@"Knotable_TemporaryTopicId_To_Delete"];
    if (topicId) {
        [[TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:topicId] MR_deleteEntity];
        [AppDelegate saveContext];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Knotable_TemporaryTopicId_To_Delete"];
    }
}

-(void)closePreMeteor
{
    // App would crash due to pending responses if meteor reference is not kept around. Any other way to prevent this?
    self.meteorOld = self.meteor;
    [self.meteor removeObserver:self forKeyPath:@"websocketReady"];
    //self.meteor.ddp.delegate = nil;
    //self.meteor.ddp.webSocket.delegate = nil;
    //self.meteor.ddp = nil;
    [self.meteor disconnect];
    self.meteor = nil;
}
-(void)connectServer:(NSString *)server
{
    if (!self.meteor) {
        self.meteor = [[MeteorClient alloc] initWithDDPVersion:@"pre2"];
        ObjectiveDDP *ddp = [[ObjectiveDDP alloc] initWithURLString:server delegate:self.meteor];
        self.meteor.ddp = ddp;
        [self.meteor.ddp connectWebSocket];
        [self.meteor addObserver:self
                      forKeyPath:@"websocketReady"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    } else if (![self.meteor.ddp.urlString isEqualToString:server]) {
        [self closePreMeteor];
        self.meteor = [[MeteorClient alloc] initWithDDPVersion:@"pre2"];
        ObjectiveDDP *ddp = [[ObjectiveDDP alloc] initWithURLString:server delegate:self.meteor];
        self.meteor.ddp = ddp;
        [self.meteor.ddp connectWebSocket];
        [self.meteor addObserver:self
                      forKeyPath:@"websocketReady"
                         options:NSKeyValueObservingOptionNew
                         context:nil];
    } else if (!self.meteor.connected) {
        [self.meteor reconnect];
    }
}
+ (void) setNotFirstUser
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [userDefault setObject:@NO forKey:kFirstUserKey];
    
    [userDefault synchronize];
}

-(void) meteorNotification:(NSNotification *)note
{
    DLog(@"METEOR NOTIFICATION: %@", note.name);
    //DLog(@"NOTIFICATION: %@ %@", note.name, note.userInfo);
}

-(void) login:(BOOL)animated
{
    //[DataManager sharedInstance].lastAccountOnDevice = [DataManager sharedInstance].currentAccount;
    
    [[DataManager sharedInstance].currentAccount saveUserPassword:_meteorPassword];
    [[DataManager sharedInstance].currentAccount checkIfUserHasGoogle];
    
    if ([DataManager sharedInstance].currentAccount.account_id) {
        
        // Lookback User Experience
        
        if ([DataManager sharedInstance].currentAccount)
        {
            [Crashlytics setUserIdentifier:[DataManager sharedInstance].currentAccount.account_id];
            [Crashlytics setUserName:[DataManager sharedInstance].currentAccount.user.name];
            [Crashlytics setUserEmail:[DataManager sharedInstance].currentAccount.user.email];
            
            //[Lookback_Weak lookback].userIdentifier = [DataManager sharedInstance].currentAccount.user.name;
        }
        
        if (animated==NO)
        {
            [DataManager sharedInstance].userLogin = NO;
            [self entryMainView:animated];
        }
    }
}

- (void)entryMainView:(BOOL)animated {
    if (!_hasLogin) {
        _hasLogin = YES;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNeedGoBackToLoginView object:nil];

        if (!animated) {
            [self.loginController hideLoadingProcess];
            if (![self.navController.topViewController isKindOfClass:[CombinedViewController class]]) {
                [self showCombinedVC:animated];
            }
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.loginController hideLoadingProcess];

                if (![self.navController.topViewController isKindOfClass:[CombinedViewController class]]) {
                    [self showCombinedVC:animated];
                }
            });
        }
    }
}

- (void)showCombinedVC:(BOOL)animated {
    
    NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.knotable.knotedev.share"];
    NSMutableDictionary *userInfo = [[userDefaults objectForKey:@"userInfo"] mutableCopy];
    
    
    if (userInfo == nil) {
        userInfo = [[NSMutableDictionary alloc] init];
    }
    
    NSString *username = [DataManager sharedInstance].currentAccount.user.name;
    NSString *email = [DataManager sharedInstance].currentAccount.user.email;
    
    if (username != nil && email != nil) {
        [userInfo setObject:username forKey:@"name"];
        [userInfo setObject:email forKey:@"email"];
    }
    
    NSUserDefaults *extensionUserDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.knotable.knotedev.share"];
    [extensionUserDefaults setObject:userInfo forKey:@"userInfo"];
    [extensionUserDefaults synchronize];
    
    userDefaults = [NSUserDefaults standardUserDefaults];
    NSNumber* permissionState = [userDefaults objectForKey: kPermissionSetState];
    if (permissionState)
    {
        CombinedViewController *combinedVC = [[CombinedViewController alloc] initWithNibName:@"PeopleViewController" bundle:nil account:[DataManager sharedInstance].currentAccount];
        combinedVC.view.backgroundColor = [UIColor whiteColor];
        [self.navController pushViewController:combinedVC animated:NO];
    }
    else
    {
        [self.loginController showPermissionScreens];
    }
}

- (void)emptyDBCache
{
    [CachedUrlsEntity MR_truncateAll];
    [ContactsEntity MR_truncateAll];
    
    NSFetchRequest *request = [MessageEntity MR_requestAllWhere:@"need_send" isEqualTo:@(NO)];
    
    [request setReturnsObjectsAsFaults:YES];
    [request setIncludesPropertyValues:NO];
    
    [self.managedObjectContext lock];
    
    NSArray *objectsToDelete = [MessageEntity MR_executeFetchRequest:request
                                                           inContext:self.managedObjectContext];
    
    for (NSManagedObject *objectToDelete in objectsToDelete)
    {
        [objectToDelete MR_deleteEntityInContext:self.managedObjectContext];
    }
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"needSend = '%@'", @(NO)]];
    
    [TopicsEntity MR_deleteAllMatchingPredicate:predicate inContext:self.managedObjectContext];

    [self.managedObjectContext unlock];
    
    [FileEntity MR_truncateAll];
}

- (void)restoreAppData
{
    _hasLogin = NO;
    
    NSUserDefaults* plist = [NSUserDefaults standardUserDefaults];
    
    [plist setDouble:(NSInteger)0 forKey:kTimeStamp];
    [plist setDouble:(NSInteger)0 forKey:kMuteTimeStamp];
    [plist synchronize];
    
    [self emptyDBCache];
    
    self.appUserAccountID = Nil;

    [[DataManager sharedInstance] reset];

    [self saveContextAndWait];
    
    [self removeAccountSettings];

    [self.loginController reset];


}

- (void)logout
{
    DLog(@".");
    
    [DataManager sharedInstance].current_user_id = @"";
    [DataManager sharedInstance].currentAccount.user.logout = @(YES);
    
    [self restoreAppData];
    
    [self performSelector:@selector(checkPopToRoot) withObject:nil afterDelay:0.5];
    
    if (self.meteor.connected)
    {
        [self.meteor logout];
    }
    [self closePreMeteor];
    [self connectServer:[self.server meteorWebsocketURL]];
}

- (void)checkPopToRoot
{
    DLog(@".%d",(int)self.navController.viewControllers.count);
    
    if ([self.navController.viewControllers count]>0)
    {
        [self.navController popToRootViewControllerAnimated:YES];
    }
}

-(void)removeAccountSettings
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    
    [defaults synchronize];
}

//- (void)applicationWillTerminate:(UIApplication *)application
//{
//    UIViewController* noteView = ((UINavigationController*)application.keyWindow.rootViewController).topViewController;
//    
////  NSLog(@"TopViewController %@", noteView);
//    
//    if ([noteView isKindOfClass: [InitialComposeViewController class]])
//    {
//        InitialComposeViewController* initView = (InitialComposeViewController*)noteView;
//        NSString* note = initView.contentText;
//        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setObject: note forKey: @"last_content"];
//    }
//    else if ([noteView isKindOfClass: [ComposeThreadViewController class]])
//    {
//        ComposeThreadViewController* composeView = (ComposeThreadViewController*)noteView;
//        NSString* note = composeView.contentText;
//        NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
//        [defaults setObject: note forKey: @"last_content"];
//    }
//}


- (void)applicationWillResignActive:(UIApplication *)application
{
    DLog(@"applicationWillResignActive");
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSDate date] forKey:@"last_usage_date"];
    [userDefault synchronize];
    

    
    [self saveContextAndWait];
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    DLog(@"applicationDidEnterBackground");
    self.firstIn = YES;
    [self saveContextAndWait];
    
    _sessionLeftDate = [NSDate date];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    DLog(@"applicationDidBecomeActive");
    
#if DOWNLOAD_SERVER_FROM_S3
    
    [self loadServerConfig];
    
    [self loadServerConfigFromNet];
    
#endif
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    DLog(@"applicationWillEnterForeground");
    
    [self connectServer:[self.server meteorWebsocketURL]];

    [self startSession];

    if([self.navController.topViewController isKindOfClass:[CombinedViewController class]])
    {
        CombinedViewController *combined = (CombinedViewController *)self.navController.topViewController;
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSDate * dateForTimeSinceLastUse = [userDefault objectForKey:@"last_usage_date"];
        if(dateForTimeSinceLastUse){
            NSDate * currentDate = [NSDate date];
            NSInteger hours = [Utilities hoursBetween:dateForTimeSinceLastUse and:currentDate];
            if(hours > 1){
                combined.view.hidden = YES;
                [combined startAddTopic:YES];
            }
        }
        
        [combined reloadData];
    }
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)(void))completionHandler{

}

- (void)startSession
{
    if (!_sessionLeftDate
        || -1.0 * [_sessionLeftDate timeIntervalSinceNow] >= sessionKeepAliveTimeout)
    {
        self.sessionStart = [NSDate date];
    }
}

#pragma mark - Core Data methods

/* Synchronous save (Wait for it to finish) */
- (void)saveContextAndWait
{
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
}

/* Asynchronous save (Don't wait) */
+ (void)saveContext
{
    [glbAppdel saveContext];
}

- (void)saveContext
{
    [self.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        
        if (success)
        {
//            DLog(@"You successfully saved your context.");
            DLog(@"...");
        }
        else if (error)
        {
            DLog(@"Error saving context: %@", error.description);
        }
    }];
}

- (NSManagedObjectContext *) managedObjectContext
{
    return [[MagicalRecordStack defaultStack] context];
}

#pragma mark <NSKeyValueObserving>

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"websocketReady"] && self.meteor.websocketReady)
    {
        DLog(@"Can send message to Meteor");
    }
    else
    {
        DLog(@"Info : %@", keyPath);
    }
}

#pragma mark - Meteor methods

- (void) AddSubscriptionMeteorCollection:(NSString*)collection
{
    if (_meteor)
    {
        NSMutableDictionary*    addedCollections = _meteor.collections;
        
        if ([addedCollections objectForKey:collection])
        {
            // Will not add subscription here
        }
        else
        {
            // Will Add meteor collection here
     
            if ([collection isEqualToString:METEORCOLLECTION_USERPRIVATEDATA])
            {
                if (_meteor.userId)
                {
                    [_meteor addSubscription:collection
                              withParameters:@[_meteor.userId]];
                    
                    // Lin - Added to
                    /*
                     As soon as login, we will try to subscribe Hot Knotes from
                     server
                     
                     param : We will pull enough hot knotes from server so we can 
                     made the quick user action whenever user change mute/unmute
                     
                     */
                    
//                    NSArray *param = @[@(20), @(0)];
                    
//                    [_meteor addSubscription:METEORCOLLECTION_HOTKNOTES
//                              withParameters:param];
//                    
//                    [_meteor addSubscription:METEORCOLLECTION_MUTEKNOTES
//                              withParameters:param];
                    
                    // Lin - Ended
                    
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(userPrivateDataReady:)
                                                                 name:@"userPrivateData_ready"
                                                               object:nil];
                }
            }
            else
            {
                [_meteor addSubscription:collection];
            }
        }
    }
}

-(void)userPrivateDataReady:(NSNotification *)note
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"userPrivateData_ready" object:nil];
    
    M13MutableOrderedDictionary *users = _meteor.collections[METEORCOLLECTION_USERS];
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(_id == %@)", _meteor.userId];
    
    DLog(@"Things : %@", users);
    DLog(@"Filtered things : %@", [users.allObjects filteredArrayUsingPredicate:pred]);
    
    NSDictionary* user = [[users.allObjects filteredArrayUsingPredicate:pred] firstObject];
    
    DLog(@"Have the user: %@", user);
    
    // Lin - Added to
    
    DLog(@"User Account : %@", self.meteor.collections[METEORCOLLECTION_ACCOUNTS]);
    DLog(@"User Contact Info : %@", self.meteor.collections[METEORCOLLECTION_PEOPLE]);
    
    M13MutableOrderedDictionary *contact_info = _meteor.collections[METEORCOLLECTION_PEOPLE];
    NSDictionary* contact_dict = [contact_info.allObjects firstObject];
    
    if (contact_dict[@"account_id"])
    {
        self.appUserAccountID = contact_dict[@"account_id"];
    }
    
    // Lin - Ended
    
    [DataManager sharedInstance].userLogin = YES;
    
    if (!([[DataManager sharedInstance] lastAccountIsLoggedIn]))
    {
        [[DataManager sharedInstance] saveUserObject:user];
        
        [self.loginController loginNetworkResult:nil withCode:NetworkSucc];
        
        [DataManager sharedInstance].currentAccount.user.logout = @(NO);
    }
    else
    {
        DLog(@"METEOR IS GOOD TO GO, Have already logged in!!!");
        
        [DataManager sharedInstance].currentAccount.user.logout = @(NO);
        
        [ContactManager findContactFromServerByAccountId:[DataManager sharedInstance].currentAccount.account_id
                                          withNofication:@"Detailfetched"
                                       withCompleteBlock:nil];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"meteor_logged_in"
                                                            object:user];
    }
}
- (void)checkMeteorNeedLogin
{
    if (self.backgroundMeteorLogin)
    {
        self.backgroundMeteorLogin = NO;
        if ([[DataManager sharedInstance] lastAccountIsLoggedIn])
        {
            NSDate* expireDate = [DataManager sharedInstance].currentAccount.expireDate;
            
            if (expireDate && ([[NSDate date] compare:expireDate] == NSOrderedAscending))
            {
                NSString* sessionToken = [DataManager sharedInstance].currentAccount.hashedToken;
                if (sessionToken)
                {
                    if (!self.meteor.sessionToken || [sessionToken isEqualToString:self.meteor.sessionToken])
                    {
                        [self meteorLoginWithSessionToken:sessionToken];
                    }
                }
            }
            else
            {
                NSString* username = [DataManager sharedInstance].currentAccount.user.name;
                NSString* password = [DataManager sharedInstance].currentAccount.user.password;
                
                if (username && password)
                {
                    DLog(@"_meteorLoggingIn session expired have username and password");
                    [self meteorLoginWithUsername:username password:password];
                }
                else
                {
                    DLog(@"_meteorLoggingIn session expired dont have username and password");
                }
            }
        }
    }

}

-(void)meteorLoginWithUsername:(NSString *)inputUsername password:(NSString *)inputPassword
{
    //Starting a login, set retry count
    
    
    DLog(@"sending login username: %@", inputUsername);
    
    _meteorUsername = inputUsername;
    _meteorPassword = inputPassword;
    
    if (!_meteorUsername || !_meteorPassword)
    {
        return;
    }
    
    NSDate *loginStart = [NSDate date];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needGoBackLoginView:)
                                                 name:kNeedGoBackToLoginView
                                               object:nil];
    
    [self.meteor logonWithUsernameOrEmail:_meteorUsername
                                 password:_meteorPassword
                         responseCallback:^(NSDictionary *response, NSError *error)
    {
        NSTimeInterval timeTook = -[loginStart timeIntervalSinceNow];
        
        DLog(@"login took: %f", timeTook);
        
        [DataManager sharedInstance].forceStopFetchTopic = NO;
        
        DLog(@"login error: %@ response: %@", error, response);
        
        if (error)
        {
            NSString *reason = nil;
            
            NSDictionary *dic = error.userInfo[NSLocalizedDescriptionKey];
            ///////// Chunji  #copy #UI ///////////////
            if (error.code == 0 || error.code == 403)
                reason = @"Please try the login credentials again.";
            ///////////////////////////////////////////
            else if ([dic isKindOfClass:[NSDictionary class]])
            {
                reason = dic[@"reason"];
            }
            else if ([dic isKindOfClass:[NSString class ]])
            {
                reason = (NSString *)dic;
            }
            
            DLog(@"error reason: %@", reason);
            
            DLog(@"authenticationFailed currectAccount: %@ loggedIn: %d reason: %@", [DataManager sharedInstance].currentAccount, [DataManager sharedInstance].currentAccount.loggedIn.boolValue, reason);
            
            if (!reason)
            {
                reason = @"We're sorry, there was a problem logging you in.";
            }
            
            [self.loginController loginNetworkResult:reason withCode:NetworkFailure];
//            [self.loginController getLinkActivate];
            [self logout];
        }
        else
        {
            [self emptyDBCache];
            
            NSDictionary *result = response[@"result"];
            NSString *user_id = result[@"id"];
            
            [DataManager sharedInstance].current_user_id = user_id;
            
            
            /********************************************************
             
             At this time, we can subscribe userprivate data and load some
             inportant collections from server.
             
             ********************************************************/
            
            if (_meteor && _meteor.userId)
            {
                [self AddSubscriptionMeteorCollection:METEORCOLLECTION_USERPRIVATEDATA];
            }
            
            if ([DataManager sharedInstance].currentAccount == Nil)
            {
                AccountEntity* lastAccount = [AccountEntity MR_findFirstOrderedByAttribute:@"lastLoggedIn" ascending:NO];
                
                if (lastAccount)
                {
                    [DataManager sharedInstance].currentAccount = lastAccount;
                }
            }
            
//            if([DataManager sharedInstance].currentAccount){
//                [[DataManager sharedInstance].currentAccount setTokenInfo:result];
//            }else{
//                [DataManager sharedInstance].accountTokenBackup = result;
//            }
            
            [[DataManager sharedInstance].currentAccount setTokenInfo:result];
            [DataManager sharedInstance].accountTokenBackup = result;
            
            //Sharing sessionToken with Share extension via NSUserDefaults
            
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.knotable.knotedev.share"];
            NSMutableDictionary *userInfo = [[userDefaults objectForKey:@"userInfo"] mutableCopy];
            
            NSString *hashedToken = [result objectForKey:@"token"];
            
            if (userInfo == nil) {
                userInfo = [[NSMutableDictionary alloc] init];
            }
            
            NSString *username = [DataManager sharedInstance].currentAccount.user.name;
            NSString *email = [DataManager sharedInstance].currentAccount.user.email;
            
            [userInfo setObject:hashedToken forKey:@"sessionToken"];
            //[userInfo setObject:username forKey:@"name"];
            //[userInfo setObject:email forKey:@"email"];
            
            NSUserDefaults *extensionUserDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.knotable.knotedev.share"];
            [extensionUserDefaults setObject:userInfo forKey:@"userInfo"];
            [extensionUserDefaults synchronize];
            
            // fired when first logged in
            // fired when logged out and re logged in
            [[AnalyticsManager sharedInstance] notifyUserLoggedIn:@"login"];
            [[AnalyticsManager sharedInstance] notifyUserLoggedIn:@"session"];
            
        }
    }];
    
    DLog(@"sent login");
}

- (void)meteorLoginWithSessionToken:(NSString *)token
{
    [self.meteor logonWithSessionToken:token responseCallback:^(NSDictionary *response, NSError *error) {
        
        NSTimeInterval timeTook = -[[NSDate date] timeIntervalSinceNow];
        
        DLog(@"login took: %f login error: %@ response: %@", timeTook,error, response);
        //DLog(@"login took: %f login error: %@ response: %@", timeTook,error, response);
        if (error)
        {
            NSString *reason = nil;
            
            NSDictionary *dic = error.userInfo[NSLocalizedDescriptionKey];
            
            if ([dic isKindOfClass:[NSDictionary class]])
            {
                reason = dic[@"reason"];
            }
            else if ([dic isKindOfClass:[NSString class ]])
            {
                reason = (NSString *)dic;
            }
            
            DLog(@"error reason: %@", reason);
            
            self.meteor.authState = AuthStateNoAuth;
            
            if (!reason)
            {
                reason = @"We're sorry, there was a problem logging you in.";
            }
            NSString* username = [DataManager sharedInstance].currentAccount.user.name;
            NSString* password = [DataManager sharedInstance].currentAccount.user.password;
            if (username && password)
            {
                DLog(@"1have username and password");
                [self meteorLoginWithUsername:username password:password];
            }
            else
            {
                DLog(@"1dont have username and password");
                
                AccountEntity* lastAccount = [AccountEntity MR_findFirstOrderedByAttribute:@"lastLoggedIn" ascending:NO];
                
                if (lastAccount)
                {
                    [DataManager sharedInstance].currentAccount = lastAccount;
                }
            }
        }
        else
        {
            NSDictionary *result = response[@"result"];
            NSString *user_id = result[@"id"];
            NSString *token = result[@"token"];
            
            self.meteor.authState = AuthStateLoggedIn;
            self.meteor.userId = user_id;
            self.meteor.sessionToken = token;
            [DataManager sharedInstance].finishFetchTopic = YES;
            [DataManager sharedInstance].current_user_id = user_id;
            
            
            NSUserDefaults *userDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.knotable.knotedev.share"];
            NSMutableDictionary *userInfo = [[userDefaults objectForKey:@"userInfo"] mutableCopy];
            
           // NSString *hashedToken = [result objectForKey:@"token"];
            if (userInfo == nil) {
                userInfo = [[NSMutableDictionary alloc] init];
            }
            NSString *username = [DataManager sharedInstance].currentAccount.user.name;
            NSString *email = [DataManager sharedInstance].currentAccount.user.email;
            
            [userInfo setObject:token forKey:@"sessionToken"];
            [userInfo setObject:username forKey:@"name"];
            [userInfo setObject:email forKey:@"email"];
            
            NSUserDefaults *extensionUserDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.knotable.knotedev.share"];
            [extensionUserDefaults setObject:userInfo forKey:@"userInfo"];
            [extensionUserDefaults synchronize];

            // Lin - Added to download user data
            
            if (_meteor && _meteor.userId)
            {
                [self AddSubscriptionMeteorCollection:METEORCOLLECTION_USERPRIVATEDATA];
            }
            
//            if([DataManager sharedInstance].currentAccount){
//                [[DataManager sharedInstance].currentAccount setTokenInfo:result];
//            }else{
//                [DataManager sharedInstance].accountTokenBackup = result;
//            }
            
            [[DataManager sharedInstance].currentAccount setTokenInfo:result];
            [DataManager sharedInstance].accountTokenBackup = result;

            // Lin - Ended
            
            // Fired when re-enters
            [[AnalyticsManager sharedInstance] notifyUserLoggedIn:@"session"];
            
        }
    }];
}

#pragma mark - <DDPAuthDelegate>

- (void)authenticationWasSuccessful
{
    //moved to callback

}
- (void)authenticationFailedWithError:(NSError *)reason
{
    NSLog(@"authenticationFailed currectAccount: %@ loggedIn: %d reason: %@", [DataManager sharedInstance].currentAccount, [DataManager sharedInstance].currentAccount.loggedIn.boolValue, reason);
    id _reason = reason;
    if (!reason)
    {
        _reason = (id)@"We're sorry, there was a problem logging you in.";
    }
    
    if([[reason description] rangeOfString:@"you were disconnected"].location != NSNotFound){
        [self.loginController loginNetworkResult:_reason withCode:NetworkFailure];
        [self logout];
    }else{
        NSLog(@"%@", @"This course of action needs to be handled properly: so far, user was kicked out of the app. Investigate.");
    }
}

- (void)authenticationFailed:(NSString *)reason
{
    DLog(@"authenticationFailed currectAccount: %@ loggedIn: %d reason: %@", [DataManager sharedInstance].currentAccount, [DataManager sharedInstance].currentAccount.loggedIn.boolValue, reason);

    if (!reason)
    {
        reason = @"We're sorry, there was a problem logging you in.";
    }

    [self.loginController loginNetworkResult:reason withCode:NetworkFailure];
    
    [self logout];
    
}

-(void)meteorError: (NSNotification *)note
{
    DLog(@"meteorError: %@ %@", note.userInfo, note.object);
}

-(void)meteorAdded:(NSNotification *)note
{
    //DLog(@"meteorAdded: %@", note);
}

-(void)meteorRemoved:(NSNotification *)note
{
    //DLog(@"meteorRemoved: %@", note);
}

// Lin - Added to Convert DB Call to Meteor based API Calls
#pragma mark
#pragma mark - New Meteor Functions instead of DB Calls

- (NSString*)mongo_id_generator
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    int i = 0;
    
    char result[20] = {0};
    
    const char *str = "23456789ABCDEFGHJKLMNPQRSTWXYZabcdefghijkmnopqrstuvwxyz";
    
    for (i=0; i< 17; i++)
    {
        uint32_t bytes[4]={0x00};
        
        if (0 != SecRandomCopyBytes(0, 10, (uint8_t*)bytes))
        {
            return nil;
        }
        
        double_t index = bytes[0] * 2.3283064365386963e-10 * strlen(str);
        
        result[i] = str[ (int)floor(index) ];
    }
    
    NSString *retID = [[NSString alloc] initWithBytes:result length:strlen(result) encoding:NSASCIIStringEncoding];
    
    DLog(@"Mongo_id_generator: %@ ", retID);
    
    return retID;
}

- (void)sendTopicBookMarkStatusToServer:(NSString *)topic_id
                            withContent:(BOOL)bookMarkFlag
                      withCompleteBlock:(MeteorClientMethodCallback)block
{
    /********************************************************
     
     Workin State : Working
     
     ********************************************************/
    
    if (!((topic_id && topic_id.length > 0)))
    {
        block(Nil, Nil);
        
        return;
    }
    
    NSString*   buildMethodNameStr = Nil;
    
    buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_TOPICS, @"update"];
    
//  id objID = [BSONObjectID objectIDWithString:topic_id];
    
    id objID = [[BSONObjectID objectIDWithString:topic_id] stringValue];
    
    if (!objID)
    {
        objID = topic_id;
    }
    
    if (objID)
    {
        NSArray *parameters = @[@{@"_id"    : objID},
                                @{@"$set"   :@{ @"bookmarked"  : [NSNumber numberWithBool:bookMarkFlag]
                                                
                                                }}];
        
        [self.meteor callMethodName:buildMethodNameStr
                         parameters:parameters
                   responseCallback:^(NSDictionary *response, NSError *error) {
                       
                       DLog(@"Server response : %@", response);
                       
                       if (error)
                       {
                           DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                           
                           block(Nil, Nil);
                           
                           return ;
                       }
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           block(response, error);
                       });
                   }];
    }
}

- (void)sendUpdatedTopicSubject:(NSString *)topic_id
                    withContent:(NSString *)subject
              withCompleteBlock:(MeteorClientMethodCallback)block
{
    /********************************************************
     
     Workin State : Working
     
     ********************************************************/
    
    if (!((topic_id && topic_id.length > 0)
          && (subject && subject.length > 0)))
    {
        block(Nil, Nil);
        
        return;
    }
    
    subject = (subject.length > 0) ? subject : @"Untitled";
    
    NSString*   buildMethodNameStr = Nil;
    
    buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_TOPICS, @"update"];
    
    id objID = [BSONObjectID objectIDWithString:topic_id];
    
    if (!objID)
    {
        objID = topic_id;
    }
    
    if(!subject){
        subject = @"untitled";
    }
    
    if (objID)
    {
        NSArray *parameters = @[@{@"_id"    : objID},
                                @{@"$set"   :@{@"original_subject"  : subject,
                                               @"changed_subject"   : subject,
                                               @"subject"           : subject}}];
        
        [self.meteor callMethodName:buildMethodNameStr
                         parameters:parameters
                   responseCallback:^(NSDictionary *response, NSError *error) {
                       
                       DLog(@"Server response : %@", response);
                       
                       if (error)
                       {
                           DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                           
                           block(Nil, Nil);
                           
                           return ;
                       }
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           block(response, error);
                       });
                   }];
    }
}

- (void)sendUpdatedTopicViewed:(NSString *)topic_id
                     accountID:(NSString *)account_id
                         reset:(BOOL)shouldReset
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    if(!(topic_id && account_id))
    {
        DLog(@"Error: sendUpdatedTopicViewed without enough data topic: %@ account: %@", topic_id, account_id);
        
        return;
    }
    
    NSString*   buildMethodNameStr = Nil;
    
    buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_TOPICS, @"update"];
    
    if ([topic_id hasPrefix:kKnoteIdPrefix])
    {
        return;
    }
    
    id objID = [BSONObjectID objectIDWithString:topic_id];
    
    if (!objID)
    {
        objID = topic_id;
    }
    
    if (objID)
    {
        NSArray *parameters = Nil;
        
        if (shouldReset)
        {
            parameters = @[@{@"_id"    : objID},
                           @{@"$set"  :@{@"viewers"   : @[account_id]}}];
        }
        else
        {
            parameters = @[@{@"_id"    : objID},
                           @{@"$push"  :@{@"viewers"   : account_id}}];
        }
        
        
        [self.meteor callMethodName:buildMethodNameStr
                         parameters:parameters
                   responseCallback:^(NSDictionary *response, NSError *error) {
                       
                       DLog(@"Success : %@", response);
                       
                       if (error)
                       {
                           DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                           
                           return ;
                       }
                       
                   }];
    }
}

- (void) sendUpdatedTopicOrder:(NSString *)topic_id
                     accountID:(NSString *)account_id
                     OrderRank:(NSString*)order
                         reset:(BOOL)shouldReset
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    if(!(topic_id && account_id))
    {
        DLog(@"Error: sendUpdatedTopicOrderRank without enough data topic: %@ account: %@", topic_id, account_id);
        
        return;
    }
    
    id objID = [BSONObjectID objectIDWithString:topic_id];
    
    if (!objID)
    {
        objID = topic_id;
    }
    
    if (objID)
    {
        NSString*   buildMethodNameStr = Nil;
        
        buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_TOPICS, @"update"];
        
        id objID = [BSONObjectID objectIDWithString:topic_id];
        
        if (!objID)
        {
            objID = topic_id;
        }
        
        if (objID)
        {
            NSArray *parameters = @[@{@"_id"    : objID},
                                    @{@"$set"   :@{@"order"   : order}}];
            
            [self.meteor callMethodName:buildMethodNameStr
                             parameters:parameters
                       responseCallback:^(NSDictionary *response, NSError *error) {
                           
                           if (error)
                           {
                               DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                               
                               return ;
                           }
                           
                       }];
        }
    }
}

- (void) sendRequestMessages:(NSString *)topic_id
           withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    WM_NetworkStatus ret = NetworkFailure;
    
    if(topic_id == nil || [topic_id isEqualToString:@""])
    {
        DLog(@"ERROR: sendRequestMessages called with topic_ids empty: %@", topic_id);
        
        block(ret, nil, nil);
        
        return;
    }
    
    NSArray *resultDocArray = Nil;
    
    M13MutableOrderedDictionary *mongo_Messages = Nil;
    
    mongo_Messages = _meteor.collections[METEORCOLLECTION_MESSAGES];
    
    if (mongo_Messages)
    {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(topic_id like %@)", topic_id];
        
        resultDocArray = [mongo_Messages.allObjects filteredArrayUsingPredicate:pred];
    }

    ret = NetworkSucc;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        block(ret, nil, resultDocArray);
        
    });
    
}

- (void) sendRequestContactByAccountId:(NSString *)account_id
                     withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    id resultDoc = nil;
    
    WM_NetworkStatus ret =  NetworkFailure;
    
    [self AddSubscriptionMeteorCollection:METEORCOLLECTION_PEOPLE];
    
    M13MutableOrderedDictionary *mongo_Peoples = self.meteor.collections[METEORCOLLECTION_PEOPLE];
    
    if (mongo_Peoples)
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"(type LIKE %@)", @"me"];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"(account_id LIKE %@)", account_id];
        
        NSArray *subPredicates = [NSArray arrayWithObjects:predicate1, predicate2, nil];
        
        NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        
        resultDoc = [mongo_Peoples.allObjects filteredArrayUsingPredicate:finalPredicate];
        
        ret = NetworkSucc;
        
        if ([(NSArray*)resultDoc count] > 0)
        {
            DLog(@"Got result : !!!!!!!!!!!");
        }
        else
        {
            //fixed bug for missing contacts show in thread
            predicate2 = [NSPredicate predicateWithFormat:@"(belongs_to_account_id LIKE %@)", account_id];
            
            subPredicates = [NSArray arrayWithObjects: predicate2, nil];
            
            finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
            resultDoc = [mongo_Peoples.allObjects filteredArrayUsingPredicate:finalPredicate];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            block(ret, nil, resultDoc);
            
        });
    }
    else
    {
        block(ret, nil, nil);
    }
}

- (void) sendRequestContactByEmail:(NSString *)email
                 withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    if (!(email && email.length>0))
    {
        return;
    }
    
    id resultDoc = nil;
    
    WM_NetworkStatus ret =  NetworkFailure;
    
    [self AddSubscriptionMeteorCollection:METEORCOLLECTION_PEOPLE];
    
    M13MutableOrderedDictionary *mongo_Peoples = self.meteor.collections[METEORCOLLECTION_PEOPLE];
    
    if (mongo_Peoples)
    {
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"(type LIKE %@)", @"me"];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"(emails IN %@)", @[email]];
        
        NSArray *subPredicates = [NSArray arrayWithObjects:predicate1, predicate2, nil];
        
        NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        
        resultDoc = [mongo_Peoples.allObjects filteredArrayUsingPredicate:finalPredicate];
        
        ret = NetworkSucc;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            block(ret, nil, resultDoc);
            
        });
        
    }
    else
    {
        block(ret, nil, nil);
    }
}

- (void) sendRequestKnotes:(NSString *)topic_id
         withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    NSArray *resultDocArray = nil;
    WM_NetworkStatus ret =  NetworkFailure;
    
    M13MutableOrderedDictionary *mongo_Knotes = self.meteor.collections[METEORCOLLECTION_KNOTES];
    
    ret = NetworkSucc;

    if(mongo_Knotes != nil)
    {
    
        NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"(topic_id LIKE %@)", topic_id];
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"(NOT type LIKE %@) AND (NOT type LIKE %@)", @"lock", @"unlock"];
        
        NSArray *subPredicates = [NSArray arrayWithObjects:predicate1, predicate2, nil];
        
        NSPredicate *finalPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
        
        resultDocArray = [mongo_Knotes.allObjects filteredArrayUsingPredicate:finalPredicate];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        block(ret, nil, resultDocArray);
        
    });
    
}

- (void) sendRequestAccountID:(NSString *)user_id
            withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    NSString *account_id = Nil;
    
    if (self.appUserAccountID != Nil)
    {
        account_id = self.appUserAccountID;
    }
    else
    {
        account_id = [self getAccountID:user_id];
    }
    
    if (account_id)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            block(NetworkSucc, nil, account_id);
            
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            block(NetworkFailure, nil, Nil);
            
        });
    }
}

- (void) sendRequestUser:(NSString *)username
                   email:(NSString *)email
       withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    if (username && (email == Nil))
    {
        NSArray *resultDocArray = nil;
        
        M13MutableOrderedDictionary* meteor_Contacts = _meteor.collections[METEORCOLLECTION_PEOPLE];
        
        if (meteor_Contacts)
        {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(username LIKE %@)", username];
            
            resultDocArray = [meteor_Contacts.allObjects filteredArrayUsingPredicate:predicate];
            
            if (resultDocArray)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    block(NetworkSucc, nil, resultDocArray.firstObject);
                    
                });
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            block(NetworkSucc, nil, Nil);
            
        });
    }
    else if ((username == Nil) && email)
    {
        __block WM_NetworkStatus ret = NetworkFailure;
        
        NSArray *inviteParams = @[email, @"Please accept this invitation for Knotable"];
        
        [self.meteor callMethodName:@"addNewOrExistingContactByEmailShared"
                         parameters:inviteParams
                   responseCallback:^(NSDictionary *response, NSError *error)
         {
             DLog(@"Server Response : %@", response);
             
             if (error == Nil)
             {
                 ret = NetworkSucc;
             }
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 
                 block(NetworkSucc, nil, response);
                 
             });
             
         }];
    }
}

- (void) sendUpdateKnotesFileIds:(NSMutableDictionary *)knote
                   withAccountId:(NSString *)account_id
                     withUseData:(id)userData
               withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    DLog(@". knote id: %@ file ids: %@",knote[@"_id"],knote[@"file_ids"]);
    
    int key = 0;
    
    [knote setObject:account_id forKey:@"account_id"];
    
    NSString*   buildMethodNameStr = Nil;
    
    if ([[knote objectForKey:@"type"] isEqualToString:@"key_knote"] == YES )
    {
        key = 1;
        
        buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_KEY, @"update"];
    }
    else
    {
        buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_KNOTES, @"update"];
    }
    
    NSNumber* limitCount = [NSNumber numberWithInt:1];
    
    NSArray *parameters = Nil;
    
    NSString *pre_id = [knote objectForKey:@"_id"];
    
    id matchKey = Nil;
    
    if ( [pre_id length] == 17)
    {
        matchKey = pre_id;
    }
    else
    {
        matchKey = [BSONObjectID objectIDWithString:pre_id];
    }
    
    id fileIDs = Nil;
    id htmlBodyID = Nil;
    id bodyID = Nil;
    
    if ([knote objectForKey:@"file_ids"])
    {
        fileIDs = [knote objectForKey:@"file_ids"];
    }
    else
    {
        fileIDs = @"";
    }
    
    if ([knote objectForKey:@"htmlBody"])
    {
        htmlBodyID = [knote objectForKey:@"htmlBody"];
        bodyID = [knote objectForKey:@"htmlBody"];
    }
    else
    {
        htmlBodyID = @"";
        bodyID = @"";
    }
    
    parameters = @[@{@"_id"     : matchKey},
                   @{@"$set"    : @{@"file_ids" : fileIDs,
                                    @"htmlBody" : htmlBodyID,
                                    @"body"     : bodyID}},
                   @{@"$limit"     : limitCount}];
    
    __block WM_NetworkStatus ret = NetworkFailure;
    
    [self.meteor callMethodName:buildMethodNameStr
                     parameters:parameters
               responseCallback:^(NSDictionary *response, NSError *error) {
                   
                   if (error)
                   {
                       DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                       
                       ret = NetworkFailure;
                   }
                   else
                   {
                       ret = NetworkSucc;
                   }
                   
                   dispatch_async(dispatch_get_main_queue(), ^{
                       
                       block(ret, nil, knote);
                       
                   });
                   
               }];
    
}

- (void) sendInsertKnotes:(NSMutableDictionary *)knote
               withUserId:(NSString *)userId
              withUseData:(id)userData
        withCompleteBlock:(MongoCompletion3)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    NSMutableDictionary *postDic = knote;
    id uData = userData;
    
    NSArray *parameters = Nil;
    
    int key = 0;
    __block WM_NetworkStatus ret = NetworkFailure;
    __block NSString *new_id = nil;
    NSString*   buildMethodNameStr = Nil;
    
    if (self.appUserAccountID == nil)
    {
        self.appUserAccountID = [self getAccountID:userId];
    }
    
    DLog(@"%@", self.appUserAccountID);
    
    if (self.appUserAccountID)
    {
        [knote setObject:self.appUserAccountID forKey:@"account_id"];
        
        if ([[knote objectForKey:@"type"] isEqualToString:@"key_knote"] == YES )
        {
            key = 1;
            buildMethodNameStr = [NSString stringWithFormat:@"/%@", METEORCOLLECTION_KEY];
        }
        else
        {
            buildMethodNameStr = [NSString stringWithFormat:@"/%@", METEORCOLLECTION_KNOTES];
        }
        
        NSString *item_id = [knote objectForKey:@"_id"];
        
        if ( item_id != nil && ![item_id hasPrefix:kKnoteIdPrefix])
        {
            DLog(@"Updating existing knote");
            
            buildMethodNameStr = [NSString stringWithFormat:@"%@/%@", buildMethodNameStr, @"update"];
            
            new_id = item_id;
            
            NSString *pre_id = [knote objectForKey:@"_id"];
            
            // To avoid the crash
            if (pre_id.length == 0) {
                
                return;
            }
            
            if ( [pre_id length] == 17)
            {
                parameters = [NSArray arrayWithObject:@{@"_id": pre_id}];
            }
            else
            {
                parameters = [NSArray arrayWithObject:@{@"_id": [BSONObjectID objectIDWithString:pre_id]}];
            }
            
            NSMutableDictionary* setParamsDict = [[NSMutableDictionary alloc] initWithCapacity:5];;
            
            [setParamsDict setObject:[knote objectForKey:@"timestamp"] forKey:@"timestamp"];
             [setParamsDict setObject:[knote objectForKey:@"archived"] forKey:@"archived"];
            if (key)
            {
                [setParamsDict setObject:[knote objectForKey:@"note"] forKey:@"note"];
            }
            else if ([[knote objectForKey:@"type"] isEqualToString:@"poll"] == YES
                     || [[knote objectForKey:@"type"] isEqualToString:@"checklist"] == YES )
            {
                [setParamsDict setObject:[knote objectForKey:@"options"] forKey:@"options"];
                [setParamsDict setObject:[knote objectForKey:@"title"] forKey:@"title"];
                [setParamsDict setObject:[knote objectForKey:@"message_subject"] forKey:@"message_subject"];
            }
            else if ([[knote objectForKey:@"type"] isEqualToString:@"deadline"] == YES )
            {
                [setParamsDict setObject:[knote objectForKey:@"deadline"] forKey:@"deadline"];
                [setParamsDict setObject:[knote objectForKey:@"local_deadline"] forKey:@"local_deadline"];
                [setParamsDict setObject:[knote objectForKey:@"deadline_subject"] forKey:@"deadline_subject"];
                [setParamsDict setObject:[knote objectForKey:@"message_subject"] forKey:@"message_subject"];
            }
            else
            {
                [setParamsDict setObject:[knote objectForKey:@"body"] forKey:@"body"];
                [setParamsDict setObject:[knote objectForKey:@"htmlBody"] forKey:@"htmlBody"];
                if (knote[@"title"]) {
                    [setParamsDict setObject:[knote objectForKey:@"title"] forKey:@"title"];
                }
            }
            
            if ([knote objectForKey:@"file_ids"])
            {
                [setParamsDict setObject:[knote objectForKey:@"file_ids"] forKey:@"file_ids"];
            }
            
            if ([knote objectForKey:@"usertags"])
            {
                [setParamsDict setObject:[knote objectForKey:@"usertags"] forKey:@"usertags"];
            }
            
            parameters = [parameters arrayByAddingObject:@{@"$set" : setParamsDict}];
            parameters =[parameters arrayByAddingObject:@{@"$addtoset": @{@"date": @{@"$date": [knote objectForKey:@"date"]}}}];
            NSLog(@"%@",parameters);
            [self.meteor callMethodName:buildMethodNameStr
                             parameters:parameters
                       responseCallback:^(NSDictionary *response, NSError *error)
            {
                DLog(@"Success : %@", response);
                
                if (error)
                {
                    DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                    
                    ret = NetworkFailure;
                    
                    DLog(@"update result[%@]",error);
                }
                else
                {
                    ret = NetworkSucc;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    block(ret,nil,new_id,uData,postDic);
                    
                });
            }];
            
            
            
        }
        else
        {
            DLog(@"Creating new knote item_id: %@", item_id);
            
            buildMethodNameStr = [NSString stringWithFormat:@"%@/%@", buildMethodNameStr, @"insert"];
            
            new_id = [item_id noPrefix:kKnoteIdPrefix];
            
            if (!new_id || [new_id length]<10)
            {
                new_id = [self mongo_id_generator];
            }
            
            DLog(@"item_id no prefix: %@", [item_id noPrefix:kKnoteIdPrefix]);
            
            parameters = Nil;
            
            [knote setObject:new_id forKey:@"_id"];
            
            parameters = @[knote];
            
            [self.meteor callMethodName:buildMethodNameStr
                             parameters:@[knote]
                       responseCallback:^(NSDictionary *response, NSError *error) {
                           
                           DLog(@"Success : %@", response);
                           
                           if (error)
                           {
                               DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                               
                               ret = NetworkFailure;
                           }
                           
                           ret = NetworkSucc;
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               
                               block(ret,nil,new_id,uData,postDic);
                               
                           });
                           
                       }];
        }
        
        DLog(@">>>>>>>>debug:new_id:%@", new_id);
    }
}

- (NSString*) getAccountID:(NSString *)user_id
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    __block NSDictionary *resultDict = nil;
    __block NSArray* resultDocArray = Nil;
    __block NSString *_id = Nil;
    
    if (_meteor && _meteor.userId)
    {
        [self AddSubscriptionMeteorCollection:METEORCOLLECTION_USERPRIVATEDATA];
        
        M13MutableOrderedDictionary* meteor_UserAccounts = nil;
        
        while (!(meteor_UserAccounts = self.meteor.collections[METEORCOLLECTION_ACCOUNTS]))
        {
            DLog(@"Count : %lu", (unsigned long)[self.meteor.collections count]);
            DLog(@"Collections : %@", self.meteor.collections.allKeys);
            
            if ([self.meteor.collections count] == 1)
            {
                 DLog(@"Values : %@", self.meteor.collections.allValues);
            }
            
            [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:2]];
        }
        
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"(user_ids CONTAINS %@)", user_id];
        
        if (meteor_UserAccounts)
        {
            DLog(@"%@", meteor_UserAccounts);
            
            resultDocArray = [meteor_UserAccounts.allObjects filteredArrayUsingPredicate:pred];
            
            if ( [resultDocArray count] > 0)
            {
                resultDict = [resultDocArray firstObject];
                
                if ([resultDict objectForKey:@"_id"])
                {
                    _id = [resultDict objectForKey:@"_id"];
                }
                
                DLog(@"account_id[%@]", _id);
            }
        }
    }
    
    return _id;    
}

- (void) sendUpdatedTopicOrders:(NSArray *)messages
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    for(NSManagedObject *message in messages)
    {
        NSString *topicid = [message valueForKey:@"topic_id"];
        NSNumber *order = [message valueForKey:@"order"];
        
        if(!topicid)
            continue;
        
        if(!order)
            continue;
        
        NSString*   buildMethodNameStr = Nil;
        
        buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_TOPICS, @"update"];
        
        if (topicid)
        {
            NSArray *parameters = Nil;
            
            parameters = @[@{@"_id"     : topicid},
                           @{@"$set"    : @{@"order"   : order}}];
            
            [self.meteor callMethodName:buildMethodNameStr
                             parameters:parameters
                       responseCallback:^(NSDictionary *response, NSError *error) {
                           
                           DLog(@"Success : %@", response);
                           
                           if (error)
                           {
                               DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                               
                               return ;
                           }
                           
                           DLog(@"Updated");
                           
                       }];
        }
    }
}

- (void) sendUpdatedKnoteOrders:(NSArray *)messages
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    NSArray *knotes = [messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %d", C_KNOTE]];
    NSArray *emails = [messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %d", C_MESSAGE]];
    
    for(NSManagedObject *message in knotes)
    {
        NSString *knoteID = [message valueForKey:@"message_id"];
        NSNumber *order = [message valueForKey:@"order"];
        
        DLog(@"Updating knote order to %@ on %@", order, knoteID);
        
        NSString*   buildMethodNameStr = Nil;
        
        buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_KNOTES, @"update"];
        
        id objID = [BSONObjectID objectIDWithString:knoteID];
        
        if (!objID)
        {
            objID = knoteID;
        }
        if (objID)
        {
            NSArray *parameters = Nil;
            
            parameters = @[@{@"_id"     : objID},
                           @{@"$set"    : @{@"order"   : order}}];
            
            [self.meteor callMethodName:buildMethodNameStr
                             parameters:parameters
                       responseCallback:^(NSDictionary *response, NSError *error) {
                           
                           DLog(@"Success : %@", response);
                           
                           if (error)
                           {
                               DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                               
                               return ;
                           }
                           
                           DLog(@"Updated");
                           
                       }];
        }
    }
    
    for(NSManagedObject *message in emails)
    {
        NSString *knoteID = [message valueForKey:@"message_id"];
        NSNumber *order = [message valueForKey:@"order"];
        DLog(@"Updating email order to %@ on %@", order, knoteID);
        
        NSString*   buildMethodNameStr = Nil;
        
        buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_MESSAGES, @"update"];
        
        id objID = [BSONObjectID objectIDWithString:knoteID];
        
        if (!objID)
        {
            objID = knoteID;
        }
        
        if (objID)
        {
            NSArray *parameters = Nil;
            
            parameters = @[@{@"_id"     : objID},
                           @{@"$set"    : @{@"order"   : order}}];
            
            [self.meteor callMethodName:buildMethodNameStr
                             parameters:parameters
                       responseCallback:^(NSDictionary *response, NSError *error) {
                           
                           DLog(@"Success : %@", response);
                           
                           if (error)
                           {
                               DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                               
                               return ;
                           }
                           
                           DLog(@"Updated");
                           
                       }];
        }
    }
}

// chunji added 20150812
- (void) sendUpdatedKnoteOrderMaps:(NSArray *)messages
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    for (NSDictionary* orderInfo in messages)
    {
        NSString *knoteID = orderInfo[@"message_id"];
        NSNumber *order = orderInfo[@"newOrder"];
        
        DLog(@"Updating knote order to %@ on %@", order, knoteID);
        
        NSString*   buildMethodNameStr = Nil;
        
        buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_KNOTES, @"update"];
        
        id objID = [BSONObjectID objectIDWithString:knoteID];
        
        if (!objID)
        {
            objID = knoteID;
        }
        if (objID)
        {
            NSArray *parameters = Nil;
            
            parameters = @[@{@"_id"     : objID},
                           @{@"$set"    : @{@"order"   : order}}];
            
            [self.meteor callMethodName:buildMethodNameStr
                             parameters:parameters
                       responseCallback:^(NSDictionary *response, NSError *error) {
                           
                           DLog(@"Success : %@", response);
                           
                           if (error)
                           {
                               DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                               
                               return ;
                           }
                           
                           DLog(@"Updated");
                           
                       }];
        }
    }
}

- (void) sendUpdatedContact:(NSManagedObject *)contactEntity
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    ContactsEntity *contact = (ContactsEntity *)contactEntity;
    NSString *contactID = contact.contact_id;
    
    NSArray *emails = [[NSOrderedSet orderedSetWithArray:[contact.email componentsSeparatedByString:@","]] array];
    
    id objID = [BSONObjectID objectIDWithString:contactID];
    
    if (!objID)
    {
        objID = contactID;
    }
    
    NSString* contact_website = Nil;
    NSString* contact_phone = Nil;
    
    if (contact.website)
    {
        contact_website = contact.website;
    }
    else
    {
        contact_website = @"";
    }
    
    if (contact.phone)
    {
        contact_phone = contact.phone;
    }
    else
    {
        contact_phone = @"";
    }
    
    if (objID)
    {
        NSArray *parameters = Nil;
        
        parameters = @[@{@"_id"     : objID},
                       @{@"$set"    : @{@"website"  : contact_website,
                                        @"phone"    : contact_phone,
                                        @"emails"   : emails}}];
        
        NSString*   buildMethodNameStr = Nil;
        
        buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_PEOPLE, @"update"];
        
        [self.meteor callMethodName:buildMethodNameStr
                         parameters:parameters
                   responseCallback:^(NSDictionary *response, NSError *error) {
                       
                       DLog(@"Success : %@", response);
                       
                       if (error)
                       {
                           DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                           
                           return ;
                       }
                       
                       DLog(@"Updated User Contact information");
                       
                   }];
    }
}

- (void) sendUpdatedContactWithImage:(NSManagedObject *)contactEntity
                                 URL:(NSDictionary *)Urls
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    M13MutableOrderedDictionary *mongo_People = self.meteor.collections[METEORCOLLECTION_PEOPLE];
    
    if (mongo_People != nil)
    {
        ContactsEntity *contact = (ContactsEntity *)contactEntity;
        NSString *contactID = contact.contact_id;
        NSArray *emails = [[NSOrderedSet orderedSetWithArray:[contact.email componentsSeparatedByString:@","]] array];
        
        id objID = [BSONObjectID objectIDWithString:contactID];
        
        if (!objID)
        {
            objID = contactID;
        }
        
        NSString* contact_website = Nil;
        NSString* contact_phone = Nil;
        
        if (contact.website)
        {
            contact_website = contact.website;
        }
        else
        {
            contact_website = @"";
        }
        
        if (contact.phone)
        {
            contact_phone = contact.phone;
        }
        else
        {
            contact_phone = @"";
        }
        
        if (objID)
        {
            NSArray *parameters = Nil;
            
            parameters = @[@{@"_id"     : objID},
                           @{@"$set"    : @{@"website"  : contact_website,
                                            @"phone"    : contact_phone,
                                            @"avatar"   : Urls,
                                            //@"gravatar_exist"   : @"2", -> breaks service sometimes
                                            @"avatar"  : Urls,
                                            @"emails"   : emails}}];
            
            NSString*   buildMethodNameStr = Nil;
            
            buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_PEOPLE, @"update"];
            
            if (!(self.meteor && self.meteor.connected))
            {
                DLog(@"Need to connect to meteor before logging in");
                
                return;
            }
            
            [self.meteor callMethodName:buildMethodNameStr
                             parameters:parameters
                       responseCallback:^(NSDictionary *response, NSError *error) {
                           
                           DLog(@"Success : %@", response);
                           
                           if (error)
                           {
                               DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                               
                               return ;
                           }
                           
                           DLog(@"Updated");
                           
                       }];
        }
    }
}

- (WM_NetworkStatus)postedKnotesTopicID:(NSString *)topicID
                                 userID:(NSString *)userID
                                knoteID:(NSString *)knoteID
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    DLog(@"postedKnotesTopicID: %@ userID: %@ knoteID: %@", topicID, userID, knoteID);
    
    //new format -- not yet live?
    NSString *strUrl = [NSString stringWithFormat:@"http://%@/post_knotes/%@/%@/%@", self.server.application_host, topicID, userID, knoteID];
    
    DLog(@"post_knotes URL: %@", strUrl);
    
    NSURL *url = [NSURL URLWithString:strUrl];
    if(url){
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
        
        [request setHTTPMethod:@"POST"];
        
        NSData *received = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        NSString *str = [[NSString alloc]initWithData:received encoding:NSUTF8StringEncoding];
        
        if ([[str lowercaseString] isEqualToString:@"success"])
        {
            DLog(@"post_knotes successfull");
            
            return NetworkSucc;
        }
        else
        {
            DLog(@"post_knotes not successfull: %@", str);
            
            return NetworkSucc;
        }
    }else{
        return NetworkErr;
    }
    
    
}

- (void)sendRequestLockInfo:(NSString *)_id
          withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Not using
     
     ********************************************************/
    
    NSArray*    resultDocArray = Nil;
    NSDictionary *resultDict = nil;
    BSONDocument *resultDoc = nil;
    WM_NetworkStatus ret = NetworkFailure;
    
    M13MutableOrderedDictionary *mongo_Knotes = self.meteor.collections[METEORCOLLECTION_KNOTES];
    
    if(mongo_Knotes != nil)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(_id LIKE %@)", _id];
        
        resultDocArray = [mongo_Knotes.allObjects filteredArrayUsingPredicate:predicate];
        
        resultDict = [resultDocArray firstObject];
        
        DLog(@"lockInfo fafter findOne");
        
        if (resultDict != nil)
        {
            ret = NetworkSucc;
            DLog(@"htmlBody[%@]",[resultDict objectForKey:@"htmlBody"]);
        }
    }
    
    resultDoc = (BSONDocument*)resultDict;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        block(ret, nil, resultDoc);
    });
    
}

-(int)sendRequestUpdateTopicLockedIdKeyId:(NSString *)topic_id
                                    field:(NSString *)_id
                                 keyValue:(NSString*)value
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    if (topic_id == Nil || topic_id.length == 0 )
    {
        return NetworkErr;
    }
    
    if (_id == Nil || _id.length == 0)
    {
        return NetworkErr;
    }
    
    if (value == Nil || value.length == 0)
    {
        return NetworkErr;
    }
    
    NSArray *parameters = @[@{@"_id"    : topic_id},
                            @{@"$set"   :@{_id  :   value}}];
    
    NSString*   buildMethodNameStr = Nil;
    
    buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_TOPICS, @"update"];
    
    [self.meteor callMethodName:buildMethodNameStr
                     parameters:parameters
               responseCallback:Nil];
    
    return NetworkSucc;
    
}

- (void) sendRequestTopic:(NSString *)topic_id
               withUserId:(NSString *)userId
        withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    if (topic_id == Nil || topic_id.length == 0)
    {
        return;
    }
    
    if (userId == Nil || userId.length == 0)
    {
        return;
    }
    
    WM_NetworkStatus ret = NetworkSucc;
    
    __block NSArray *results = nil;
    
    M13MutableOrderedDictionary *mongo_Topics = self.meteor.collections[METEORCOLLECTION_TOPICS];
    
    if (self.appUserAccountID == nil)
    {
        self.appUserAccountID = [self getAccountID:userId];
    }
    
    if (mongo_Topics)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(_id LIKE %@)", topic_id];
        
        results = [mongo_Topics.allObjects filteredArrayUsingPredicate:predicate];
    }
    
    ret = NetworkSucc;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        block(ret, nil, results);
        
    });
    
}

- (void) sendRequestlockAction:(NSMutableDictionary *)knote
                    withUserId:(NSString *)userId
                       topicId:(NSString *)topic_id
                   withUseData:(id)data
             withCompleteBlock:(MongoCompletion3)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    if (topic_id == Nil || topic_id.length == 0)
    {
        return;
    }
    
    id uData = data;
    
    NSDictionary *postDic = knote;
    
    __block WM_NetworkStatus ret = NetworkSucc;
    
    __block NSString *new_id = nil;
    
    if (self.appUserAccountID == nil)
    {
        self.appUserAccountID = [self getAccountID:userId];
    }
    
    [knote setObject:self.appUserAccountID forKey:@"account_id"];
    
    new_id = [self mongo_id_generator];
    
    [knote setObject: new_id  forKey:@"_id"];
    
    NSArray *parameters = Nil;
    
    parameters = @[knote];
    
    NSString*   buildMethodNameStr = Nil;
    
    buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_KNOTES, @"insert"];
    
    [self.meteor callMethodName:buildMethodNameStr
                     parameters:parameters
               responseCallback:^(NSDictionary *response, NSError *error) {
                   
                   DLog(@"Success : %@", response);
                   
                   if (error)
                   {
                       DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                       
                       ret = NetworkFailure;
                   }
                   
                   DLog(@"Updated");
                   
                   if ( [self sendRequestUpdateTopicLockedIdKeyId:topic_id
                                                            field:@"locked_id"
                         
                                                         keyValue:new_id] != 0 )
                   {
                       ret = NetworkFailure;
                   }
                   
                   if(ret == NetworkSucc)
                   {
                       ret = [self postedKnotesTopicID:postDic[@"topic_id"] userID:userId knoteID:postDic[@"_id"]];
                       
                       if (ret != NetworkSucc)
                       {
                           new_id = nil;
                       }
                       
                   }
                   
                   dispatch_async(dispatch_get_main_queue(), ^{
                       block(ret, nil, new_id, uData, knote);
                   });
                   
               }];
    
}

- (void) sendRequestUnlockAction:(NSMutableDictionary *)knote
                      withUserId:(NSString *)userId
                         topicId:(NSString *)topic_id
               withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    if (topic_id == Nil || topic_id.length == 0)
    {
        return;
    }
    
    NSDictionary *postDic = knote;
    
    __block WM_NetworkStatus ret = NetworkFailure;
    
    if (self.appUserAccountID == nil)
    {
        self.appUserAccountID = [self getAccountID:userId];
    }
    
    [knote setObject:self.appUserAccountID forKey:@"account_id"];
    
    __block NSString *new_id = nil;
    
    new_id = [self mongo_id_generator];
    
    [knote setObject: new_id  forKey:@"_id"] ;
    
    NSArray *parameters = Nil;
    
    parameters = @[knote];
    
    NSString*   buildMethodNameStr = Nil;
    
    buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_KNOTES, @"insert"];
    
    [self.meteor callMethodName:buildMethodNameStr
                     parameters:parameters
               responseCallback:^(NSDictionary *response, NSError *error) {
                   
                   DLog(@"Success : %@", response);
                   
                   if (error)
                   {
                       DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                       
                       ret = NetworkFailure;
                   }
                   
                   DLog(@"Updated");
                   
                   if ( [self sendRequestUpdateTopicLockedIdKeyId:topic_id
                                                            field:@"locked_id"
                                                         keyValue:@""] != 0)
                   {
                       ret = NetworkFailure;
                   }
                   else
                   {
                       ret = NetworkSucc;
                   }
                   
                   if( ret == NetworkSucc)
                   {
                       ret = [self postedKnotesTopicID:postDic[@"topic_id"]
                                                userID:userId
                                               knoteID:postDic[@"_id"]];
                   }
                   
                   dispatch_async(dispatch_get_main_queue(), ^{
                       block(ret,nil,nil);
                   });
                   
                   
               }];
    
}

- (void) sendRequestArchiveKnote:(NSString *)_id
                        Archived:(BOOL)arhived
                       isMessage:(BOOL)isMessage
               withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State :
     
     ********************************************************/
    
    NSString*   buildMethodNameStr = Nil;
    
    buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_KNOTES, @"update"];
    __block WM_NetworkStatus ret = NetworkFailure;
    
//  id objID = [BSONObjectID objectIDWithString:_id];
    
    NSString *objID = [[BSONObjectID objectIDWithString:_id] stringValue];
    
    if (!objID)
    {
        objID = _id;
    }
    
    if (objID)
    {
        NSArray *parameters = Nil;
        
        parameters = @[@{@"_id"    : objID},
                       @{@"$set"  :@{@"archived"   : [NSNumber numberWithBool:YES]}}];
        
        [self.meteor callMethodName:buildMethodNameStr
                         parameters:parameters
                   responseCallback:^(NSDictionary *response, NSError *error) {
                       
                       DLog(@"Success : %@", response);
                       
                       if (error)
                       {
                           DLog(@"Error : %@",error.description);
                           
                           ret = NetworkFailure;
                       }
                       else
                       {
                           DLog(@"Updated");
                           
                           ret = NetworkSucc;
                       }
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           block(ret,nil,nil);
                       });
                       // Finally End
                   }];
        
    }
}

- (void) sendRequestUpdateKeyNote:(NSMutableDictionary *)knote
                       withUserId:(NSString *)userId
                          topicId:(NSString *)topic_id
                      withUseData:(id)data
                withCompleteBlock:(MongoCompletion3)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    if (topic_id == Nil || topic_id.length == 0 )
    {
        return;
    }
    
    id uData = data;
    NSDictionary *postDic = knote;
    
    __block WM_NetworkStatus ret = NetworkSucc;
    __block NSString *new_id = nil;
    
    if (self.appUserAccountID == nil)
    {
        self.appUserAccountID = [self getAccountID:userId];
    }
    
    [knote setObject:self.appUserAccountID forKey:@"account_id"];
    
    new_id = [self mongo_id_generator];
    
    [knote setObject: new_id  forKey:@"_id"] ;
    
    NSString*   buildMethodNameStr = Nil;
    
    buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_KEY, @"insert"];
    
    NSArray *parameters = @[knote];
    
    [self.meteor callMethodName:buildMethodNameStr
                     parameters:parameters
               responseCallback:^(NSDictionary *response, NSError *error) {
                   
                   DLog(@"Success : %@", response);
                   
                   if (error)
                   {
                       DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                       
                       ret = NetworkFailure;
                       
                       new_id = nil;
                   }
                   
                   if ( [self sendRequestUpdateTopicLockedIdKeyId:topic_id
                                                            field:@"key_id"
                                                         keyValue:new_id] != 0)
                   {
                       ret = NetworkSucc;
                   }
                   
                   DLog(@"Updated");
                   
                   
                   
                   if( ret == NetworkSucc)
                   {
                       ret = [self postedKnotesTopicID:postDic[@"topic_id"] userID:userId knoteID:knote[@"_id"]];
                       
                       if (ret != NetworkSucc)
                       {
                           ret = NetworkFailure;
                           new_id = nil;
                       }
                   }
                   
                   dispatch_async(dispatch_get_main_queue(), ^{
                       block(ret,nil,new_id,uData,postDic);
                   });
                   
               }];
    
}

- (void) sendRequestDeleteKeyNote:(NSString *)_id
                          topicId:topic_id
                withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    __block WM_NetworkStatus ret = NetworkFailure;
    
    NSString*   buildMethodNameStr = Nil;
    
    buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_KEY, @"update"];
    
    if (_id)
    {
        NSNumber*   archivedVal = [NSNumber numberWithBool:YES];
        
        NSArray *parameters = @[@{@"_id"    : _id},
                                @{@"$set"   :@{@"archived"  : archivedVal}}];
        
        [self.meteor callMethodName:buildMethodNameStr
                         parameters:parameters
                   responseCallback:^(NSDictionary *response, NSError *error) {
                       
                       DLog(@"Success : %@", response);
                       
                       if (error)
                       {
                           DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                           
                           ret = NetworkFailure;
                       }
                       
                       DLog(@"Updated");
                       
                       if ( [self sendRequestUpdateTopicLockedIdKeyId:topic_id
                                                                field:@"key_id"
                                                             keyValue:@""] == 0)
                       {
                           ret = NetworkSucc;
                       }
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           block(ret,nil,nil);
                       });
                       
                   }];
    }
}

- (void) sendUpdatedKnoteCurrentlyEditing:(NSArray *)messages ContactID:(NSString *)ContactID
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    NSArray *knotes = [messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %d", C_KNOTE]];
    
    NSString*   buildMethodNameStr = Nil;
    
    buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_KNOTES, @"update"];
    
    for( NSManagedObject *message in knotes)
    {
        NSString *knoteID = [message valueForKey:@"message_id"];
        
        id objID = [[BSONObjectID objectIDWithString:knoteID] stringValue];
        
        if (!objID)
        {
            objID = knoteID;
        }
        
        if (objID)
        {
            NSArray *parameters = Nil;
            
            parameters = @[@{@"_id"    : objID},
                           @{@"$set"  :@{@"currently_contact_edit"   : ContactID}}];
            
            [self.meteor callMethodName:buildMethodNameStr
                             parameters:parameters
                       responseCallback:^(NSDictionary *response, NSError *error) {
                           
                           if (error)
                           {
                               DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                               
                               return ;
                           }
                           
                           DLog(@"Success to update Meteor Collection - knotes");
                           
                           // Finally End
                       }];
            
        }
    }
    
    
}
- (void) sendUpdatedKnoteUnArchiveWithID:(NSString *)knoteID withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    /*NSArray *knotes = [messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %d", C_KNOTE]];*/
    
    NSString*   buildMethodNameStr = Nil;
    
    buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_KNOTES, @"update"];
    __block WM_NetworkStatus ret = NetworkFailure;

    /*for( NSManagedObject *message in knotes)
    {*/
        //NSString *knoteID = [message valueForKey:@"message_id"];
    
        id objID = [BSONObjectID objectIDWithString:[knoteID noPrefix:@"tempId."]];
    NSLog(@"sendUpdatedKnoteUnArchiveWithID:%@",objID);
    
        if (!objID)
        {
            objID = knoteID;
        }
        
        if (objID)
        {
            NSArray *parameters = Nil;
            
            parameters = @[@{@"_id"    : objID},
                           @{@"$set"  :@{@"archived"   : [NSNumber numberWithBool:NO]}}];
            
            [self.meteor callMethodName:buildMethodNameStr
                             parameters:parameters
                       responseCallback:^(NSDictionary *response, NSError *error) {
                           
                           DLog(@"Success : %@", response);
                           
                           if (error)
                           {
                               DLog(@"Error : %@",error.description);
                               
                               ret = NetworkFailure;
                           }
                           else
                           {
                               DLog(@"Updated");
                               
                               ret = NetworkSucc;
                           }
                           
                           dispatch_async(dispatch_get_main_queue(), ^{
                               block(ret,nil,nil);
                           });
                           // Finally End
                       }];
            
        }
    //}
    
    
}
- (void) sendUpdatedKnoteUnsetCurrentlyEditing:(NSArray *)messages
{
    /********************************************************
     
     Working State :
     
     ********************************************************/
    
    //NSArray *knotes = [messages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"type == %d", C_KNOTE]];
    NSArray *knotes = messages;
    
    NSString*   buildMethodNameStr = Nil;
    
    buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_KNOTES, @"update"];
    
    for( NSManagedObject *message in knotes)
    {
        NSString *knoteID = [message valueForKey:@"message_id"];
        
        id objID = [[BSONObjectID objectIDWithString:knoteID] stringValue];
        
        if (!objID)
        {
            objID = knoteID;
        }
        
        if (objID)
        {
            NSArray *parameters = Nil;
            
            parameters = @[@{@"_id"    : objID},
                           @{@"$set"  :@{@"currently_contact_edit"   : @""}}];
            
            [self.meteor callMethodName:buildMethodNameStr
                             parameters:parameters
                       responseCallback:^(NSDictionary *response, NSError *error) {
                           
                           if (error)
                           {
                               DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                               
                               return ;
                           }
                           
                           DLog(@"Success to update Meteor Collection - knotes");
                           
                           // Finally End
                       }];
            
        }
    }
    
}

#if 0

- (void) sendRequestFile:(NSString *)file_id
             withMessage:(MessageEntity *)message
       withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    if (file_id == Nil
        || file_id.length == 0)
    {
        return;
    }
    
    __block WM_NetworkStatus ret = NetworkFailure;
    __block FileEntity* file = nil;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:message.file_url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
        NSString *name;
        /*********Dhruv : Crash Fixes**************/
        if ([message.body containsString:@"\n"])
        {
            name = [message.body substringToIndex:[message.body rangeOfString:@"\n"].location];
        }
        else
        {
        name=@"";
        }
        
        [[MagicalRecordStack defaultStack] saveWithBlock:^(NSManagedObjectContext *localContext) {
            
            file = [FileEntity MR_findFirstByAttribute:@"file_id"
                                             withValue:file_id
                                             inContext:localContext];
            
            if (file == nil)
            {
                file = [FileEntity MR_createEntity];
                
                file.file_id = file_id;
                
                DLog(@"creating new FileEntity: %@", file_id);
            }
            
            if ([file isFault])
            {
                [file MR_refresh];
            }
            
            NSString *extension = [name pathExtension];
            
            if (extension == nil || extension.length == 0)
            {
                extension = @"jpg";
            }
            else
            {
                extension = [extension lowercaseString];
            }
            
            BOOL isImage = NO;
            BOOL isPNG = NO;
            BOOL isPDF = NO;
            
            if ([@[@"jpg",@"jpeg"] containsObject:extension])
            {
                isImage = YES;
            }
            else if([extension isEqualToString:@"png"])
            {
                isImage = YES;
                isPNG = YES;
            }
            else if([extension isEqualToString:@"pdf"])
            {
                isPDF = YES;
            }
            
            file.name = name;
            file.isImage = @(isImage);
            file.isPNG = @(isPNG);
            file.isPDF = @(isPDF);
            file.ext = extension;
            file.size = @([data length]);
            file.full_url = message.file_url;
            
            file.sendFlag = @(SendSuc);
            file.belongId = @"";
            file.downloading = NO;
            
            if (data && [data length]>0)
            {
                [FileManager saveData:data fileID:file_id extension:extension];
            }
            
            file.isDownloaded = @(YES);
            
            ret = NetworkSucc;
            
        } completion:^(BOOL success, NSError *error) {
            
            if (block)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    block(ret,nil,file_id);
                });
            }
        }];
    }];
}

#else

- (void) sendRequestFile:(NSString *)file_id
             withMessage:(MessageEntity *)message
       withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    if (file_id == Nil
        || file_id.length == 0)
    {
        return;
    }
    
    __block WM_NetworkStatus ret = NetworkFailure;
    __block FileEntity* file = nil;
    
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:message.file_url]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse* response, NSData* data, NSError* error) {
        NSString *name;
        /*********Dhruv : Crash Fixes**************/
        if ([message.body containsString:@"\n"])
        {
            name = [message.body substringToIndex:[message.body rangeOfString:@"\n"].location];
        }
        else
        {
            name=@"";
        }
        
        [self.managedObjectContext performBlock:^{
            file = [FileEntity MR_findFirstByAttribute:@"file_id"
                                             withValue:file_id];
            
            if (file == nil)
            {
                file = [FileEntity MR_createEntity];
                
                file.file_id = file_id;
                
                DLog(@"creating new FileEntity: %@", file_id);
            }
            
            if ([file isFault])
            {
                [file MR_refresh];
            }
            
            NSString *extension = [name pathExtension];
            
            if (extension == nil || extension.length == 0)
            {
                extension = @"jpg";
            }
            else
            {
                extension = [extension lowercaseString];
            }
            
            BOOL isImage = NO;
            BOOL isPNG = NO;
            BOOL isPDF = NO;
            
            if ([@[@"jpg",@"jpeg"] containsObject:extension])
            {
                isImage = YES;
            }
            else if([extension isEqualToString:@"png"])
            {
                isImage = YES;
                isPNG = YES;
            }
            else if([extension isEqualToString:@"pdf"])
            {
                isPDF = YES;
            }
            
            file.name = name;
            file.isImage = @(isImage);
            file.isPNG = @(isPNG);
            file.isPDF = @(isPDF);
            file.ext = extension;
            file.size = @([data length]);
            file.full_url = message.file_url;
            
            file.sendFlag = @(SendSuc);
            file.belongId = @"";
            file.downloading = NO;
            
            if (data && [data length]>0)
            {
                [FileManager saveData:data fileID:file_id extension:extension];
            }
            
            file.isDownloaded = @(YES);
            
            ret = NetworkSucc;
            
            [self.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
                if (success && block != nil)
                {
                    block(ret, nil, file);
                }
                
            }];
            

        }];
    }];
}

#endif


- (void) sendRequestAddFile:(id)fileInfo
              withAccountId:(NSString *)account_id
                withUseData:(id)userData
          withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    FileInfo *fInfo = fileInfo;
    __block WM_NetworkStatus ret = NetworkFailure;
    
    [self AddSubscriptionMeteorCollection:METEORCOLLECTION_FILES];
    
    M13MutableOrderedDictionary *mongo_Files = self.meteor.collections[METEORCOLLECTION_FILES];
    
    NSString *mime = [[fInfo.imageName lowercaseString] hasSuffix:@"png"] ? @"image/png" : @"image/jpg";
    
    NSString *full_url = [NSString stringWithFormat:@"https://%@.s3.amazonaws.com/uploads/%@_%@",self.server.s3_bucket,fInfo.imageId,fInfo.imageName];
    
    // If no name is setn, use imageID. If no ID is set, abort.
    NSString * imageID = fInfo.imageId;
    NSString * imageName = fInfo.imageName;
    if(!imageName){
        imageName = imageID;
    }
    if(imageName){
        
        NSDictionary *postDic = @{
                                  @"_id":imageID,
                                  @"account_id":account_id,
                                  @"name":imageName,
                                  @"type":mime,
                                  @"s3_url":full_url,
                                  @"size":@(fInfo.imageSize)
                                  };
        
        NSString*   buildMethodNameStr = Nil;
        
        buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_FILES, @"insert"];
        
        NSArray *parameters = @[postDic];
        
        [self.meteor callMethodName:buildMethodNameStr
                         parameters:parameters
                   responseCallback:^(NSDictionary *response, NSError *error) {
                       
                       DLog(@"Success : %@", response);
                       
                       if (error)
                       {
                           DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                           
                           ret = NetworkFailure;
                           
                           DLog(@"error writing mongo file object: %@", error);
                           
                           NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(_id LIKE %@)", fInfo.imageId];
                           
                           NSArray * resultDocArray = [mongo_Files.allObjects filteredArrayUsingPredicate:predicate];
                           
                           if ([resultDocArray count]>0)
                           {
                               ret = NetworkSucc;
                           }
                           else
                           {
                               DLog(@"error writing mongo file object: %@", error);
                           }
                       }
                       else
                       {
                           ret = NetworkSucc;
                           
                           DLog(@"FILE WROTE IN MONGO:\n%@", postDic);
                           
                           DLog(@"wrote file in mongo");
                       }
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           block(ret,nil,nil);
                           
                       });
                       
                       
                   }];
        
    }
    
    
}

- (void) sendRequestAddPin:(BOOL )pinned
                  itemType:(CItemType)type
                   knoteId:(NSString *)knote_id
                     order:(int64_t)neworder
         withCompleteBlock:(MongoCompletion)block
{
    
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    __block WM_NetworkStatus ret = NetworkFailure;
    
    NSString*   buildMethodNameStr = Nil;
    
    if (type != C_KEYKNOTE)
    {
        buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_KNOTES, @"update"];
    }
    else
    {
        buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_KEY, @"update"];
    }
    
    NSNumber*   pingedVal = [NSNumber numberWithBool:pinned];
    
    NSArray *parameters = @[@{@"_id"    : knote_id},
                            @{@"$set"   :@{@"pinned"  : pingedVal}}];
    
    [self.meteor callMethodName:buildMethodNameStr
                     parameters:parameters
               responseCallback:^(NSDictionary *response, NSError *error) {
                   
                   DLog(@"Success : %@", response);
                   
                   if (error)
                   {
                       DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                       
                       ret = NetworkFailure;
                   }
                   else
                   {
                       ret = NetworkSucc;
                   }
                   
                   dispatch_async(dispatch_get_main_queue(), ^{
                       
                       block(ret, nil, nil);
                       
                   });
                   
               }];
    
}

- (void) sendRequestAddLike:(NSMutableArray *)liked_array
                   itemType:(CItemType)type
                    knoteId:(NSString *)knote_id
          withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
    
    Working State : Working
     
    ********************************************************/
    
    if (knote_id == Nil || knote_id.length == 0 )
    {
        return;
    }
    
    __block WM_NetworkStatus ret = NetworkFailure;
    
    NSString*   buildMethodNameStr = Nil;
    
    if (type != C_KEYKNOTE)
    {
        buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_KNOTES, @"update"];
    }
    else
    {
        buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_KEY, @"update"];
    }
    
    NSArray *parameters = @[@{@"_id"    : knote_id},
                            @{@"$set"   :@{@"liked_account_ids"  : liked_array}}];
    
    [self.meteor callMethodName:buildMethodNameStr
                     parameters:parameters
               responseCallback:^(NSDictionary *response, NSError *error) {
                   
                   DLog(@"Success : %@", response);
                   
                   if (error)
                   {
                       DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                       
                       ret = NetworkFailure;
                   }
                   else
                   {
                       ret = NetworkSucc;
                   }
                   
                   dispatch_async(dispatch_get_main_queue(), ^{
                       
                       block(ret, nil, nil);
                       
                   });
                   
               }];
}

- (void) sendRequestUpdteParticipators:(NSMutableArray *)new_participators
                           withTopicId:(NSString *)topicId
                           withUseData:(id)userData
                     withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Not using
     
     ********************************************************/
    
    if (topicId == Nil || topicId.length == 0)
    {
        return;
    }
    
    __block WM_NetworkStatus ret = NetworkFailure;
    
    NSString*   buildMethodNameStr = Nil;
    
    buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_TOPICS, @"update"];
    
    NSArray *parameters = @[@{@"_id"    : topicId},
                            @{@"$set"   :@{@"participators"  : new_participators}}];
    
    [self.meteor callMethodName:buildMethodNameStr
                     parameters:parameters
               responseCallback:^(NSDictionary *response, NSError *error) {
                   
                   DLog(@"Success : %@", response);
                   
                   if (error)
                   {
                       DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                       
                       ret = NetworkFailure;
                   }
                   
                   ret = NetworkSucc;
                   
                   dispatch_async(dispatch_get_main_queue(), ^{
                       
                       block(ret, nil, nil);
                       
                   });
                   
               }];
}

- (void) sendRequestDeleteTopic:(NSString *)_id
                   withArchived:(NSArray*)archived
              withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    __block WM_NetworkStatus ret = NetworkFailure;
    
    [self.meteor callMethodName:@"markPadAsDone"
                     parameters:@[_id]
               responseCallback:^(NSDictionary *response, NSError *error) {
                   
                   DLog(@"Success : %@", response);
                   
                   if (error)
                   {
                       DLog(@"Error : %@", error.description);
                       
                       ret = NetworkFailure;
                   }
                   else
                   {
                       ret = NetworkSucc;
                   }
                                      
                   dispatch_async(dispatch_get_main_queue(), ^{
                       
                       block(ret, nil, archived);
                       
                   });
                   
               }];

}

- (void) sendRequestDeleteCommentFrom:(NSString *)knoteId
                        withCommentID:(NSString*)commentId
                    withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    __block WM_NetworkStatus ret = NetworkFailure;
    
    NSArray *requestParameters = @[knoteId, commentId];
    
    [self.meteor callMethodName:@"remove_reply_message"
                     parameters:requestParameters
               responseCallback:^(NSDictionary *response, NSError *error) {
                   
                   if (error)
                   {
                       ret = NetworkFailure;
                   }
                   else
                   {
                       ret = NetworkSucc;
                   }
                   
                   dispatch_async(dispatch_get_main_queue(), ^{
                       
                       block(ret, nil, nil);
                       
                   });
    }];
}

- (void) sendRequestUpdateList:(NSString *)_id
               withOptionArray:(NSArray *)array
             withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Function :
     
     Algorighm : Working
     
     ********************************************************/
    
    if (_id == Nil || _id.length == 0 )
    {
        return;
    }
    
    if (array == Nil || [array count] == 0)
    {
        return;
    }
    
    __block WM_NetworkStatus ret = NetworkFailure;
    
    if (_id)
    {
        NSString*   buildMethodNameStr = Nil;
        
        buildMethodNameStr = [NSString stringWithFormat:@"/%@/%@", METEORCOLLECTION_KNOTES, @"update"];
        
        NSArray *parameters = @[@{@"_id"    : _id},
                                @{@"$set"   :@{@"options" : array}}];
        
        [self.meteor callMethodName:buildMethodNameStr
                         parameters:parameters
                   responseCallback:^(NSDictionary *response, NSError *error) {
                       
                       DLog(@"Success : %@", response);
                       
                       if (error)
                       {
                           DLog(@"Func : %@ : Error : %@", buildMethodNameStr, error.description);
                           
                           ret = NetworkFailure;
                       }
                       else
                       {
                           ret = NetworkSucc;
                       }
                       
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           block(ret, nil, nil);
                           
                       });
                       
                   }];
    }
}

- (void) checkIfUserHasGoogle:(NSString *)account_id
            withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    if (account_id == Nil || account_id.length == 0 )
    {
        return;
    }
    
    // Step 1.get userIDs
    
    WM_NetworkStatus ret = NetworkFailure;
    NSArray* resultDocArray = Nil;
    
    NSDictionary *accountDoc = Nil;
    
    if (_meteor && _meteor.userId)
    {
        [self AddSubscriptionMeteorCollection:METEORCOLLECTION_USERPRIVATEDATA];
    }
        
    M13MutableOrderedDictionary *mongo_Accounts = self.meteor.collections[METEORCOLLECTION_ACCOUNTS];
    
    if(!mongo_Accounts)
    {
        DLog(@"Dont have users and user_accounts collections");
        
        block(ret, Nil, Nil);
        
        return;
    }
    
    NSPredicate *accountPredicate = [NSPredicate predicateWithFormat:@"(_id LIKE %@)", account_id];
    
    resultDocArray = [mongo_Accounts.allObjects filteredArrayUsingPredicate:accountPredicate];
    
    if ([resultDocArray count] > 0)
    {
        accountDoc = [resultDocArray firstObject];
    }
    
    if(!accountDoc)
    {
        DLog(@"couldnt find account with id: %@", account_id);
        
        block(NetworkSucc,nil,nil);
        
        return;
    }
    
    // NotificationStatus
    
    NSDictionary *account = accountDoc;
    
    __block  NSArray *userIDs = [account[@"user_ids"] copy];
    
    if(!userIDs && [userIDs isKindOfClass:[NSArray class]] && [userIDs count]<1){
        
        DLog(@"no userIds for account: %@", account_id);
        
        block(NetworkSucc,nil,nil);
        
        return;
    }
    
    // Step 2.get google_id and user_id by userIDs
    
    M13MutableOrderedDictionary *mongo_Users = self.meteor.collections[METEORCOLLECTION_USERS];
    
    if(!(mongo_Users))
    {
        DLog(@"Dont have users and user_accounts collections");
        
        block(NetworkSucc,nil,nil);
        
        return;
    }
    
    if(!account_id || account_id.length == 0)
    {
        DLog(@"Dont have account_id");
        
        block(NetworkSucc,nil,nil);
        
        return;
    }
    
    NSPredicate *usersPredicate1 = [NSPredicate predicateWithFormat:@"(_id IN %@)", userIDs];
    
    NSArray *googleUserDocs = [mongo_Users.allObjects filteredArrayUsingPredicate:usersPredicate1];
    
    NSString *notification =account[@"notificationStatus"];
    
    if(googleUserDocs && googleUserDocs.count > 0)
    {
        NSDictionary *googleUser = [googleUserDocs firstObject];
        
        NSString *user_id = googleUser[@"_id"];
        
        NSDictionary *googleDict = googleUser[@"services"][@"google"];
        
        if (googleDict)
        {
            NSString *google_id = googleDict[@"id"];
            
            NSMutableDictionary *userData = [NSMutableDictionary new];
            
            if (google_id)
            {
                [userData setObject:google_id forKey:@"google_id"];
            }
            
            if (user_id)
            {
                [userData setObject:user_id forKey:@"user_id"];
            }
            
            if (notification)
            {
                [userData setObject:notification forKey:@"notificationStatus"];
            }
            
            DLog(@"User DOES have a google account linked, ids: %@", userData);
            
            block(NetworkSucc, nil, [userData copy]);
        }
        else
        {
            block(NetworkSucc, Nil, Nil);
        }
        
        
    }
    else
    {
        DLog(@"User DOES NOT have a google account linked");
        
        NSDictionary *userData = nil;
        
        if(notification)
        {
            userData = @{@"notificationStatus":notification};
        }
        
        block(NetworkSucc, nil, userData);
    }
    
}

- (void) sendRequestSaveGoogle:(NSDictionary *)serviceData
                     accountID:(NSString *)account_id
             withCompleteBlock:(MongoCompletion)block
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    NSString*   google_id = Nil;
    NSString*   buildMethodNameStr = Nil;
    
    if ([serviceData objectForKey:@"id"])
    {
        google_id = serviceData[@"id"];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            block(NetworkFailure, Nil, Nil);
        });
    }
    
    buildMethodNameStr = @"updateGoogleServicesInfo";
    
    M13MutableOrderedDictionary* meteor_User = _meteor.collections[METEORCOLLECTION_USERS];
    
    if ( meteor_User != nil
        && account_id != nil
        && google_id != nil )
    {
        NSPredicate *existingUserPredicate = [NSPredicate predicateWithFormat:@"(services.google.id == %@)", google_id];
        NSArray *filteredUser = [meteor_User.allObjects filteredArrayUsingPredicate:existingUserPredicate];
        
        NSDictionary *existingUserDict = [filteredUser firstObject];
        
        NSString *user_id = nil;
        
        if (existingUserDict)
        {
            if ([existingUserDict objectForKey:@"_id"])
            {
                user_id = existingUserDict[@"_id"];
            }
            else
            {
                DLog(@"\nThere is not UserID key in google user dictionary.Try again later.");
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    block(NetworkFailure, Nil, Nil);
                    
                });
            }
        }
        else
        {
            user_id = [self mongo_id_generator];
        }
        
        [self.meteor callMethodName:buildMethodNameStr
                         parameters:@[serviceData]
                   responseCallback:^(NSDictionary *response, NSError *error) {
                       
                       DLog(@"Success : %@", response);
                       
                       if (error)
                       {
                           dispatch_async(dispatch_get_main_queue(), ^{
                               block(NetworkFailure, Nil, Nil);
                           });
                           
                           return ;
                       }
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           
                           block(NetworkSucc, Nil, user_id);
                           
                       });
                       
                   }];
        
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            block(NetworkFailure, Nil, Nil);
            
        });
    }
}



- (ContactsEntity*)sendRequestContactByContactID:(NSString *)ContactID
{
    /********************************************************
     
     Working State : Working
     
     ********************************************************/
    
    NSDictionary *resultDict = nil;
    
    ContactsEntity *contact = nil;

    M13MutableOrderedDictionary* meteor_Contact = _meteor.collections[METEORCOLLECTION_PEOPLE];
    
    if (meteor_Contact)
    {
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"(account_id LIKE %@)", ContactID];
        
        NSArray* filteredArray = [meteor_Contact.allObjects filteredArrayUsingPredicate:predicate];
        
        if (filteredArray)
        {
            resultDict = filteredArray.firstObject;
            
            contact = [ContactsEntity contactWithDict:resultDict];
        }
        
        DLog(@"ContactsEntity : %@ ", contact);
    }
    
    return contact;
}

// Lin - Ended

#pragma mark Server Config methods

+ (NSString *) applicationDocumentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (NSString *)currentServerPlistPath
{
    NSString *current_server_plist_filename = @"current_server.plist";
    
    return [[AppDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:current_server_plist_filename];
}
- (void) needGoBackLoginView:(id)userData
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkPopToRoot];
    });
}
- (void) needChangeMogoDbServer:(id)userData
{
    NSMutableDictionary *dic = [self.server.dic mutableCopy];
    NSInteger current = [dic[@"mongodb_host_index"] integerValue];
    current++;
    dic[@"mongodb_host_index"] = @(current);
    
    if (dic[@"mongodb_host_index"]) {
        NSInteger index = [dic[@"mongodb_host_index"] integerValue];
        NSArray *serArr = dic[@"mongodb_host1"];
        if(!serArr)
            serArr=[dic[@"mongodb_host"] componentsSeparatedByString:@","];
        if (index < [serArr count]) {
            self.server.mongodb_host = serArr[index];
        } else {
            self.server.mongodb_host = serArr[0];
            NSMutableDictionary *tDic = [dic mutableCopy];
            tDic[@"mongodb_host_index"] = @(0);
            dic = [tDic copy];
        }
        if (!self.server.mongodb_host) {
            self.server.mongodb_host = dic[@"mongodb_host"];
        }
        if (!self.server.application_host) {
            self.server.application_host = dic[@"application_host"];
        }
        
    } else {
        DLog(@"check");
    }
    
    self.server.dic = [dic copy];
}
- (void) needChangeApplicationHost:(id)userData
{
    NSMutableDictionary *dic = [self.server.dic mutableCopy];
    NSInteger current = [dic[@"application_host_index"] integerValue];
    current++;
    dic[@"application_host_index"] = @(current);
    self.server = [[ServerConfig alloc] initWithDictionary:[dic copy]];
}

- (void)meteorClientConnectionReady:(NSNotification *)note
{
    [self checkMeteorNeedLogin];
}
- (NSString *)currentSavedServerID
{
    //Locking it on Alpha
    //return @"alpha";
    
#if K_SERVER_DEV
    
    return @"Dev";
    
#elif K_SERVER_BETA
    
    return @"beta";
    
#elif K_SERVER_STAGING
    
    return @"staging";
    
#endif
    
}

-(void)loadServerConfigFromNet
{
    MCAWSS3Client* client = [[MCAWSS3Client alloc] init];
    
    client.accessKey = self.server.s3_access_key;
    client.secretKey = self.server.s3_secret_key;
    client.bucket = self.server.s3_bucket;
    
    if (!self.server.s3_bucket)
    {
        return;
    }
    
    NSString *awsFilename = @"config/ios/servers.plist";
    NSString *downloadedPath = [self serverConfigPlistPath];
    
    NSData *oldServerData = nil;
    
    __block BOOL needChangeServer = NO;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadedPath])
    {
        oldServerData = [NSData dataWithContentsOfFile:downloadedPath];
    }
    else
    {
        needChangeServer = YES;
    }

    
    if (DIRECT_AWS_DOWNLOAD)
    {
        NSString* configt_path = Nil;
        
        if ([self generateConfigAWSPath])
        {
            configt_path = [NSString stringWithFormat:@"%@%@", [self generateConfigAWSPath], awsFilename];
        }
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:configt_path]];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        NSString *path = Nil;
        
        path = downloadedPath;
        
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
            DLog(@"Successfully downloaded file to %@", path);
            
//            [self AutoHiddenAlert:Nil messageContent:@"Successfully downloaded server config file"];
            
            NSData *newServerData = nil;
            NSArray *newServerDicts = nil;
            
            if ([[NSFileManager defaultManager] fileExistsAtPath:downloadedPath])
            {
                if (!needChangeServer)
                {
                    newServerData = [NSData dataWithContentsOfFile:downloadedPath];
                }
                newServerDicts = [NSArray arrayWithContentsOfFile:downloadedPath];
            }
            if (!needChangeServer)
            {
                if (![oldServerData isEqual:newServerData])
                {
                    needChangeServer = YES;
                }
            }
            
            DLog(@"download server.plist:%@",newServerDicts);
            
            if (needChangeServer && newServerDicts)
            {
                [self setServerByDic:newServerDicts];
            }
            
            
        } failure:^(AFHTTPRequestOperation* operation, NSError* error) {
            
            DLog(@"Error: %@", error);
            
            [self loadServerConfig];
            
        }];
        
        [operation start];
    }
    else
    {
        [client getObjectToFileAtPath:downloadedPath
                                  key:awsFilename
                              success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                  
                                  NSData *newServerData = nil;
                                  NSArray *newServerDicts = nil;
                                  
                                  if ([[NSFileManager defaultManager] fileExistsAtPath:downloadedPath])
                                  {
                                      if (!needChangeServer)
                                      {
                                          newServerData = [NSData dataWithContentsOfFile:downloadedPath];
                                      }
                                      newServerDicts = [NSArray arrayWithContentsOfFile:downloadedPath];
                                  }
                                  if (!needChangeServer)
                                  {
                                      if (![oldServerData isEqual:newServerData])
                                      {
                                          needChangeServer = YES;
                                      }
                                  }
                                  
                                  DLog(@"download server.plist:%@", newServerDicts);
                                  
                                  if (needChangeServer && newServerDicts)
                                  {
                                      [self setServerByDic:newServerDicts];
                                  }
                              } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                  
                                  DLog(@"@%@", error);
                                  
                                  [self loadServerConfig];
                                  
                              }];
    }
}

- (void)loadServerConfig
{
    
    //try to load downloaded configuration first, if that fails load packaged config
    NSArray *serverDicts = nil;

    NSString *downloadedPath = [self serverConfigPlistPath];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:downloadedPath])
    {
        serverDicts = [NSArray arrayWithContentsOfFile:downloadedPath];
        
        DLog(@"loaded server configs from downloaded file");
    }
    
    if (!serverDicts)
    {
#if K_SERVER_DEV
        NSString *bundledConfigPath = [[NSBundle mainBundle] pathForResource:@"servers_dev" ofType:@"plist"];
#elif K_SERVER_BETA
        NSString *bundledConfigPath = [[NSBundle mainBundle] pathForResource:@"servers_beta" ofType:@"plist"];
#elif K_SERVER_STAGING
        NSString *bundledConfigPath = [[NSBundle mainBundle] pathForResource:@"servers_staging" ofType:@"plist"];
#endif
    
        serverDicts = [NSArray arrayWithContentsOfFile:bundledConfigPath];
        
        DLog(@"loaded server configs from packaged file");
    }
    [self setServerByDic:serverDicts];

}
-(void)setServerByDic:(NSArray *)serverDicts
{
    NSMutableArray *servers = [[NSMutableArray alloc] initWithCapacity:serverDicts.count];
    
    for (NSDictionary *d in serverDicts)
    {
        [servers addObject:[[ServerConfig alloc] initWithDictionary:d]];
    }
    
    NSString *current_server_id = [self currentSavedServerID];
    
    ServerConfig *current_server_data = nil;
    
    if (current_server_id)
    {
        for (ServerConfig *s in servers)
        {
            NSString *server_id = s.server_id;
        
            if (server_id && [server_id isEqualToString:current_server_id])
            {
                current_server_data = s;
            
                break;
            }
        }
    }
    
    if (!current_server_data)
    {
        current_server_data = [servers firstObject];
    }
    
    NSAssert(current_server_data != nil, @"NO SERVER CONFIG FOUND!!");

    _allServerConfigs = [servers copy];
    
    [self setServer:current_server_data];
}

-(void)setServer:(ServerConfig *)server
{
    BOOL first_server = (_server == nil);
    BOOL server_changed = NO;
    if (![server.server_id isEqualToString:_serverID] )
    {
        _server = server;
        _serverID = server.server_id;
        server_changed = YES;
        [self saveCurrentServer];
    }
    
    // Lin - Added to Explain login issue to Angus
    
    /*
     
     About current implementation, app trys to init whenever change server,
     I think we need to init service even we are first to use app.
     So we can check services' state as well.
     I'd like we would discuss this problem with other guys
     
     Problem : relogin time, maybe we need to reload all data from server.
     
     */
    
    // Lin - Ended
    
    if ((!first_server) && (server_changed) )
    {
        [self closePreMeteor];
        
        //clear core data
        if (![DataManager sharedInstance].currentAccount)
        {
            [AccountEntity MR_truncateAll];
            [ContactsEntity MR_truncateAll];
            [FileEntity MR_truncateAll];

            NSFetchRequest *request = [MessageEntity MR_requestAllWhere:@"need_send" isEqualTo:@(NO)];
            [request setReturnsObjectsAsFaults:YES];
            [request setIncludesPropertyValues:NO];
            
            [self.managedObjectContext lock];
            
            NSArray *objectsToDelete = [MessageEntity MR_executeFetchRequest:request inContext:self.managedObjectContext];
            
            for (NSManagedObject *objectToDelete in objectsToDelete)
            {
                [objectToDelete MR_deleteEntityInContext:self.managedObjectContext];
            }
            
            NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"needSend = '%@'", @(NO)]];
            
            [TopicsEntity MR_deleteAllMatchingPredicate:predicate inContext:self.managedObjectContext];

            [self.managedObjectContext unlock];

            [UserEntity MR_truncateAll];
        }
        else
        {
            DLog(@"############ change server no need truncate DB when account is logdIn: %@", [DataManager sharedInstance].currentAccount);
        }
        
        self.appUserAccountID = Nil;
        
        //[DataManager sharedInstance].currentAccount = nil;
        
        [self.loginController reset];
        [self.loginController updateServerName];
        
        [self connectServer:[self.server meteorWebsocketURL]];

    }
}

-(void)saveCurrentServer
{
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.serverID, @"id", nil];
    NSString *path = [self currentServerPlistPath];
    BOOL wrote = [dict writeToFile:path atomically:YES];
    if (!wrote) {
        DLog(@"Problem writing current server dict: %@ to path: %@", dict, path);
    }
}

- (NSString *)serverConfigPlistPath
{
#if K_SERVER_DEV
    NSString *server_config_plist_filename = @"servers_dev.plist";
#elif K_SERVER_BETA
    NSString *server_config_plist_filename = @"servers_beta.plist";
#elif K_SERVER_STAGING
    NSString *server_config_plist_filename = @"servers_staging.plist";
#endif
    
    return [[AppDelegate applicationDocumentsDirectory] stringByAppendingPathComponent:server_config_plist_filename];
}

- (NSString *)generateConfigAWSPath
{
    NSString* configPath = Nil;
    
    if (self.server)
    {
        if (self.server.s3_bucket)
        {
            configPath = [NSString stringWithFormat:@"%@/%@/", @"http://s3.amazonaws.com", self.server.s3_bucket];
            
            return configPath;
        }
        else
        {
#if K_SERVER_DEV
            NSString *static_configPath = @"http://s3.amazonaws.com/knotable-assets-dev/";
#elif K_SERVER_BETA
            NSString *static_configPath = @"http://s3.amazonaws.com/knotable-assets-alpha/";
#elif K_SERVER_STAGING
            NSString *static_configPath = @"http://s3.amazonaws.com/knotable-assets-staging/";
#endif
            
            return static_configPath;
        }
        
        
    }
    else
    {
#if K_SERVER_DEV
        NSString *static_configPath = @"http://s3.amazonaws.com/knotable-assets-dev/";
#elif K_SERVER_BETA
        NSString *static_configPath = @"http://s3.amazonaws.com/knotable-assets-alpha/";
#elif K_SERVER_STAGING
        NSString *static_configPath = @"http://s3.amazonaws.com/knotable-assets-staging/";
#endif
        
        return static_configPath;
    }
}


-(void)saveServerConfig:(NSData *)configData
{
    NSString *path = [self serverConfigPlistPath];
    BOOL wrote = [configData writeToFile:path atomically:YES];
    if (!wrote) {
        DLog(@"Problem writing server config: %@ to path: %@", configData, path);
    } else {
        DLog(@"wrote downloaded server configs to path: %@", path);
    }
}

-(void)popUpMessage:(NSNotification *)note
{
    NSString *str = note.object;
    [SVProgressHUD showErrorWithStatus:str duration:2];
}

#pragma mark -
#pragma mark - Utility Function

- (void)ShowAlert:(NSString*)title messageContent:(NSString *)content
{
    UIAlertView* confirm = [[UIAlertView alloc] initWithTitle:title
                                                      message:nil
                                                     delegate:nil
                                            cancelButtonTitle:Nil
                                            otherButtonTitles:@"Ok", nil];
    
	confirm.message = [NSString stringWithFormat:@"%@", content];
	
    confirm.delegate = self;
    
	[confirm show];
    
}

- (void)autoHide:(UIAlertView*)alert
{
    [alert dismissWithClickedButtonIndex:-1 animated:YES];
}

- (void) AutoHiddenAlert:(NSString*)title messageContent:(NSString *)content
{
    UIAlertView *autoAlert = [[UIAlertView alloc] initWithTitle:title message:content delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [autoAlert show];
    
    double delayInSeconds = 1.0;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self autoHide:autoAlert];
    });
}

- (void) HideAlert:(NSString*)title messageContent:(NSString *)content withDelay:(double)delay
{
    UIAlertView *autoAlert = [[UIAlertView alloc] initWithTitle:title message:content delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    [autoAlert show];
    
    double delayInSeconds = delay;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self autoHide:autoAlert];
    });
}

- (CGFloat)heightOfTextForString:(NSString *)aString andFont:(UIFont *)aFont maxSize:(CGSize)aSize
{
    // iOS7
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
    {
        CGSize sizeOfText = [aString boundingRectWithSize: aSize
                                                  options: (NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                               attributes: [NSDictionary dictionaryWithObject:aFont
                                                                                       forKey:NSFontAttributeName]
                                                  context: nil].size;
        
        return ceilf(sizeOfText.height);
    }
    
    // iOS6
    CGSize textSize = [aString sizeWithFont:aFont
                          constrainedToSize:aSize
                              lineBreakMode:NSLineBreakByWordWrapping];
    
    return ceilf(textSize.height);
                 
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        if(buttonIndex == 0) // Your Profile
        {
            
        }
        else if(buttonIndex == 1) // Logout
        {
            
        }
        else    // Cancel
        {
            
        }
    }
}


@end
