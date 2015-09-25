//
//  CombinedViewController.m
//  Knote
//
//  Created by JYN on 9/19/13.
//  Copyright (c) 2013 jackiejin. All rights reserved.
//

#import "CombinedViewController.h"
#import "MZFormSheetController.h"
#import "ThreadViewController.h"
#import "MyProfileController.h"
#import "ProfileDetailVC.h"
#import "CEditHeaderInfoView.h"

#import "ContactsEntity.h"
#import "TopicsEntity.h"
#import "AccountEntity.h"
#import "MessageEntity.h"

#import <Lookback/Lookback.h>
#import <OMPromises/OMPromises.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ObjCMongoDB.h"
#import "CUtil.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "AnalyticsManager.h"
#import "Utilities.h"

#import "UIImage+Tint.h"
#import "UIImage+Retina4.h"
#import "NSString+Knotes.h"
#import "UIImage+ImageEffects.h"
#import "UIView+SubviewHunting.h"
#import "NSString+FontAwesome.h"
#import "UIImage+FontAwesome.h"

#import "DeadlineCell.h"
#import "LockCell.h"
#import "KeyKnoteCell.h"
#import "VoteCell.h"
#import "KnoteCell.h"
#import "PictureCell.h"
#import "NewKnoteCell.h"
#import "PadOwnerCell.h"
#import "MCSwipeTableViewCell.h"
#import "MuteTableViewCell.h"

#import "DesignManager.h"
#import "DataManager.h"
#import "TopicManager.h"
#import "ContactManager.h"
#import "ThreadItemManager.h"
#import "CustomSideBar.h"
#import "SideMenuViewController.h"


#import "CVoteItem.h"
#import "CDateItem.h"

#import "KnoteBMBV.h"
#import "KnoteNMV.h"
#import "KnoteNMTV.h"
#import "KnoteNSMV.h"

#import "TopicInfo.h"
#import "CustomSegmentedControl.h"
#import "KnotesProgressView.h"
#import "M13OrderedDictionary.h"
#import "YLProgressBar.h"
#import "LoginProcessViewController.h"
#import "InitialComposeViewController.h"
#import "CalendarEventManager.h"
#import "BWStatusBarOverlay.h"

#define kUseFetchedController 0//kUserAddSubscribe

#define kInfoBarHeight 33.0f
#define kCombinedNewFeature 1
#define kCombineAnimation @"kCombineAnimation"
#define KeepEmilsMode           0

#define DARK_BACKGROUND [UIColor colorWithRed:52.0/255.0 green:60.0/255.0 blue:69.0/255.0 alpha:1.0]

// ints
#define TABLEVIEW_INITIAL_Y_POSITION 66
#define SHARED_WITH_VIEW_HEIGHT 76

// Strings
#define ALL_BUTTON_TITLE        @"All"
#define DONE_BUTTON_TITLE       @"Done"
#define DOING_BUTTON_TITLE      @"Doing"
#define FAVORITES_BUTTON_TITLE  @"Favorites"

@interface CombinedViewController (KnoteBMBDelegate)<KnoteBMBDelegate>
@end

@interface CombinedViewController (KnoteNMDelegate)<KnoteNMDelegate>
@end

@interface CombinedViewController (KnoteNMTDelegate)<KnoteNMTDelegate>
@end

@interface CombinedViewController (KnoteNSMDelegate)<KnoteNSMDelegate>
@end

@interface CombinedViewController (PadOwnerCellDelegate)<PadOwnerCellDelegate>
@end

@interface CombinedViewController (ContactCellDelegate)<ContactCellDelegate>
@end

@interface CombinedViewController ()<
NSFetchedResultsControllerDelegate,
TopicInfoDelegate,
ThreadViewControllerDelegate,
CTitleInfoBarDelegate,
CUserPictureDelegate,
MZFormSheetBackgroundWindowDelegate,
MCSwipeTableViewCellDelegate,
//CEditHeaderInfoViewDelegate,
UIAlertViewDelegate,
MyProfileDelegateProtocol
#if New_DrawerDesign
,MozAlertDelegate
//,SideMenuDelegate
//,CustomSidebarDelegate
//,UPStackMenuDelegate
#endif
>

@property (nonatomic, assign)   BOOL  sortAlphabetically;   // non necessary for recent
@property (nonatomic, assign)   BOOL  showArchived;         // non necessary for recent
@property (nonatomic, assign)   BOOL  showMutedItems;
@property (nonatomic, assign)   BOOL  recent_showMutedItems_Flag;
@property (nonatomic, assign)   BOOL  justAddedContact;                     //
@property (nonatomic, assign)   BOOL  justAddedContactFromNotification;
@property (nonatomic, assign)   BOOL  reorderFlag;
@property (nonatomic, assign)   BOOL  autoKnote;
@property (nonatomic, assign)   BOOL  justLoaded;
@property (nonatomic, assign)   BOOL  firstLoad;
@property (nonatomic, assign)   BOOL  dontAutoKnoteNewContact;
@property (nonatomic, assign)   BOOL  searchMode;
@property (nonatomic, assign)   BOOL  showOwner;
@property (nonatomic, assign)   BOOL  animateMuteCell;
@property (nonatomic, assign)   BOOL  transitioningData;
@property (nonatomic, assign)   BOOL  isCurrentShow;
@property (nonatomic, assign)   BOOL  isRefreshAnimating;
@property (nonatomic, assign)   BOOL  isNopadAvailable;
@property (nonatomic, assign)   BOOL  searchingPeople;
@property (nonatomic)           BOOL  isUpdateSearch;
@property (nonatomic, assign)   BOOL  searchCancelClicked;
@property (nonatomic, assign)   BOOL  showFavoriteContacts;

@property (nonatomic, assign)   int editingCount;

@property (nonatomic, strong)   NSNumber* tablewViewCurrentYPosition;

@property (nonatomic, strong)   NSDate*         startAddedContactDate;
@property (nonatomic, assign)   NSInteger       dataSourceCount;
@property (nonatomic, strong)   NSIndexPath*    editingIndexPath;
@property (strong, atomic)      NSIndexPath*    expIndexPath;
@property (nonatomic, copy)     NSString*       searchString;

@property (nonatomic, strong)   NSMutableArray      *newlyAddedEmails;
@property (nonatomic, strong)   NSMutableArray      *peopleSearchResults;
@property (nonatomic, strong)   NSMutableArray      *topicSearchResults;
@property (nonatomic, strong)   NSMutableArray      *filteredArray;

@property (nonatomic, strong)   NSMutableDictionary *padsCache;

@property (strong, atomic)      NSMutableDictionary *userData;
@property (nonatomic, strong)   NSMutableDictionary *swipedHotTopics;

@property (nonatomic, strong) UIBarButtonItem *leftCustomMenu;      // Pads View
#if !New_DrawerDesign
@property (nonatomic, strong) UIBarButtonItem *addButton;
@property (nonatomic, strong) UIBarButtonItem *editButton;          // Recent & Pads View
#endif
#if New_DrawerDesign
@property (nonatomic, strong) UIBarButtonItem *leftDrowerMenu;
#endif
@property (nonatomic, strong) UIBarButtonItem *rightSrchBtn;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation * currentLocation;
@property (nonatomic, strong) NSDictionary * fullAddress;
@property (nonatomic, strong) NSString * cityAddress;

@property (nonatomic, strong) UIImageView                   *snapshotImageView;
@property (nonatomic, strong) UISearchBar                   *searchBar;
@property (nonatomic, strong) UISearchDisplayController     *searchController;
@property (nonatomic, strong) NSFetchedResultsController    *fetchedResultsController;
@property (nonatomic, strong) UIView                        *auxiliarScrollViewForProfileInfoView;
@property (nonatomic, strong) UIButton                      *filterButton;

@property (nonatomic, strong) UITapGestureRecognizer    *tapGestureRecognizer;

@property (nonatomic, strong) ContactCell           *editingCell;
@property (nonatomic, retain) SwipeTableView        *tableView;
#if !New_DrawerDesign
@property (nonatomic, strong) KnoteBMBV             *bottomMenuBar;
#endif
@property (nonatomic, strong) KnoteNMV              *navigationLeftMenu;
@property (nonatomic, strong) KnoteNSMV             *navigationSortMenu;
@property (nonatomic, strong) KnoteNMTV             *navigationMuteMenu;
@property (nonatomic, strong) MCSwipeTableViewCell  *cellToDelete;
@property (nonatomic, strong) ProfileDetailVC       *profileInfo;

@property (nonatomic, strong) UIView * peopleFilterBackgroundView;
@property (nonatomic, strong) UIView * filterAreaBackgroundView;
@property (nonatomic, strong) UIButton * readButton;
@property (nonatomic, strong) UIButton * unreadButton;

@property (nonatomic, strong) UIView * opaqueBlackBackgroundView;
@property (nonatomic, strong) BubbleView * bubbleDialog;
@property (nonatomic, strong) CEditHeaderInfoView *footerInfoView;
@property (nonatomic, strong) KnotableProgressView  *spinnerImageView;
@property BOOL willSegueAfterRowTap;

@property (nonatomic, strong) ContactsEntity* userContact;
@property (nonatomic, strong) ContactsEntity* currentContact;
@property (nonatomic, strong) ContactsEntity* padOwnerContact;

@property (nonatomic, assign) DisplayMode oldDisplayMode;

@property (nonatomic, strong) MZFormSheetController* formSheetControl;

@property (nonatomic) CGRect searchTableViewRect;
#if New_DrawerDesign
@property(nonatomic,strong)CustomSideBar *sideBar;
//@property (nonatomic, strong)UPStackMenu *  stack;
#endif
#if kCombinedNewFeature

@property (nonatomic, strong) UIButton *recordBtn;
@property (nonatomic, strong) UIView *searchBgView;

@property (nonatomic) BOOL isPresentThreadView;
@property (nonatomic) BOOL isViewDidAppear;
@property (nonatomic) int  topicCount;

@property (nonatomic) NSTimer* meterConnectTimer;
@property (nonatomic) BOOL isLoadingTopicInfo;

#endif

@end

@implementation CombinedViewController

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil account:(AccountEntity *)account
{
    self = [super init];

    if (self)
    {
//        self.title = RECENT_TITLE;
        self.isCurrentShow = NO;
        self.currentAccount = account;

        self.justLoaded = YES;
        self.firstLoad = YES;
        self.editingCount = 0;
        self.sortAlphabetically = NO;
        self.showArchived = NO;
        
        self.reorderFlag = NO;
        
        self.showMutedItems = NO;
        
        self.recent_showMutedItems_Flag = self.showMutedItems;
        
        self.autoKnote = NO;
        self.dontAutoKnoteNewContact = NO;
        self.displayMode = DisplayModePads;
        self.peopleSearchResults = [[NSMutableArray alloc] init];
        self.topicSearchResults = [[NSMutableArray alloc] init];
        self.newlyAddedEmails = [[NSMutableArray alloc] init];

        self.topicArray = [[NSMutableArray alloc] init];
        self.peopleData = [self fetchAllContactsExcludingSelfForSortFlag:self.sortAlphabetically
                                                             archiveFlag:self.showArchived];
        
        self.swipedHotTopics = [[NSMutableDictionary alloc] init];
        
        [self logCounts];
        
//        [self manageNotificatioObservers:YES];
        
        if([DataManager sharedInstance].fetchedContacts)
        {
            NSLog(@"already have contacts fetched");
            
            [self fetchedContacts];
        }
        
        NSLog(@"waiting for contacts fetched notification");
        
        self.searchMode = NO;
        self.showOwner = NO;
        self.dataSourceCount = 0;
    }
    
//    [self removeLoginSplashFromNavArray];
    
    return self;
}

- (void) removeLoginSplashFromNavArray
{
    NSMutableArray* allVCs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    
    int i;
    
    for (i = 1; i < [allVCs count] ; i++ )
    {
        UIViewController*   vc =  [allVCs objectAtIndex:i];
        
        if ([vc isKindOfClass:[LoginProcessViewController class]])
        {
            if (((LoginProcessViewController*)vc).vcTag == LOGIN_PROCESS_VC)
            {
                [allVCs removeObjectAtIndex:i];
                
                break;
            }
        }
    }
    
    self.navigationController.viewControllers = allVCs;
}

- (void) viewDidLoad
{
    [super viewDidLoad];
//    self.isPresentThreadView = NO;
//    self.isViewDidAppear = NO;
//    self.topicCount = -1;
//    
//    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//    
//    __weak typeof (center) weakCenter = center;
//    NSOperationQueue *mainQueue = [NSOperationQueue mainQueue];
//    __block id topciCountObserver = [center addObserverForName: @"topic_count_update" object: nil queue: mainQueue usingBlock:^(NSNotification *note) {
//        NSDictionary* userInfo = note.userInfo;
//        if (userInfo != nil && userInfo[@"count"] != nil)
//            self.topicCount = ((NSNumber*)userInfo[@"count"]).intValue;
//        else
//            self.topicCount = 0;
//
//        if (self.topicCount == 0)
//        {// no topic,
//            [self showInitViewController];
//        }
//        
//        [weakCenter removeObserver: topciCountObserver];
//    }];
//    
//    UIImage* splash = [UIImage imageNamed: @"ComposeScreen"];
    UIImage* splash = [UIImage imageNamed: @"ComposeScreenN"];
    CGRect rect = self.view.bounds;
    CGFloat offset = 0;// 20 + 44;//status bar + navigation height;
    rect.origin.y += offset;
    rect.size.height -= offset;
    UIImageView* imageView = [[UIImageView alloc] initWithImage: splash];
//    imageView.contentMode = UIViewContentModeCenter;
    
    imageView.frame = rect;
    imageView.alpha = 0.7;
    [self.view addSubview: imageView];
//
//    self.tablewViewCurrentYPosition = [NSNumber numberWithInt:TABLEVIEW_INITIAL_Y_POSITION];
//    
//    [self performSelector:@selector(requestAccessToEvents) withObject:nil afterDelay:0.4];
//
//    if (!self.footerInfoView)
//    {
//        self.footerInfoView = [[CEditHeaderInfoView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 36)];
//        self.footerInfoView.delegate = self;
//        self.footerInfoView.showArchived = _showArchived;
//        self.footerInfoView.contentDic = [[NSMutableDictionary alloc] init];
//        
//        self.footerInfoView.hidden = YES;
//    }
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(cellExpanded:)
//                                                 name:NEWS_CELL_EXPAND
//                                               object:nil];
//    
//    
//
//    self.view.backgroundColor = [DesignManager appBackgroundColor];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];

    // Define Edit Buttons
//#if !New_DrawerDesign
//    self.editButton = [self customBarButtonItem];
//    
//    self.navigationItem.rightBarButtonItem = self.editButton;
//#endif
//    // Define Navigation Sort Button
//    
//    if (self.navigationSortMenu == Nil)
//    {
//        self.navigationSortMenu = [[KnoteNSMV alloc] init];
//        
//        self.navigationSortMenu.targetDelegate = self;
//        
//        [self.navigationSortMenu.m_btnSort setTitleColor:[DesignManager KnoteNormalColor] forState:UIControlStateNormal];
//        [self.navigationSortMenu.m_btnSort.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]];
//    }
//#if !New_DrawerDesign
//    if (self.bottomMenuBar==nil)
//    {
//        self.bottomMenuBar = [[KnoteBMBV alloc] init];
//        [self.bottomMenuBar setFrame:CGRectMake(0, self.view.bounds.size.height- 64 - BottomMenuHeight, 320, BottomMenuHeight)];
//        self.bottomMenuBar.backgroundColor = [DesignManager knoteNavigationBarTintColor];
//        self.bottomMenuBar.targetDelegate = self;
//        [self.view addSubview:self.bottomMenuBar];
//    }
//#endif
    
    // Define Navigation Menu View
    
//    if (self.navigationLeftMenu == Nil)
//    {
//        self.navigationLeftMenu = [[KnoteNMV alloc] init];
//        
//        self.navigationLeftMenu.targetDelegate = self;
//        
//        UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapOnce:)];
//        UITapGestureRecognizer *tapTwice = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapTwice:)];
//        
//        tapOnce.numberOfTapsRequired = 1;
//        tapTwice.numberOfTapsRequired = 2;
//        
//        [tapOnce requireGestureRecognizerToFail:tapTwice];
//        
//        [self.navigationLeftMenu.m_btnReorder addGestureRecognizer:tapOnce];
//        [self.navigationLeftMenu.m_btnReorder addGestureRecognizer:tapTwice];
//        
//    }
//    
//    // Define Navigation Mute Menu View
//    
//    if (self.navigationMuteMenu == Nil)
//    {
//        self.navigationMuteMenu = [[KnoteNMTV alloc] init];
//        
//        self.navigationMuteMenu.targetDelegate = self;
//    }
//    
//    if ([self respondsToSelector:@selector(setAutomaticallyAdjustsScrollViewInsets:)])
//    {
//        self.automaticallyAdjustsScrollViewInsets = YES;
//    }
//    
//    [self fetchedAllPeopleTopics: NO];
//    [self fetchedValidTopic];
//
//    [self createTableView];
//    if (![self shouldShowQuickNoteViewController]) {
//        [self showQuickNoteViewController];
//    }
//    else
//    {
//        [self showInitialComposeViewController];
//    }
//    
//    self.searchBar = [[UISearchBar alloc] init];
//    if ([self.searchBar respondsToSelector:@selector(setSearchBarStyle:)])
//    {
//        self.searchBar.searchBarStyle = UISearchBarStyleDefault;
//    }
//    
//    self.searchBar.tintColor = [UIColor whiteColor];
//    self.searchBar.showsCancelButton = YES;
//    
//    self.searchController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar
//                             
//                                                              contentsController:self];
//    self.searchController.searchBar.delegate=self;
//    self.searchController.delegate = self;
//    self.searchController.searchResultsDelegate = self;
//    self.searchController.searchResultsDataSource = self;
//    self.extendedLayoutIncludesOpaqueBars = YES;
//    
//    
//    self.displayMode = DisplayModePads;
//    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchTableViewTaped:)];
//    self.tapGestureRecognizer.delegate = self;
//    
//    self.spinnerImageView = [[KnotableProgressView alloc] init];
//    
//    self.isRemovedNow=YES;
//    self.isUpdatedTopic=YES;
//    if (self.peopleData.count == 0)
//    {
//        [[DataManager sharedInstance] forceFetchRemoteContacts];
//    }
//#if kUseFetchedController	
//    NSError *error = nil;
//    if (![[self fetchedResultsController] performFetch:&error])
//    {
//        /*
//         Replace this implementation with code to handle the error appropriately.
//         
//         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
//         */
//        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
//        abort();
//    }
//#endif
//    _isUpdateSearch=YES;
//#if kCombinedNewFeature
//    [self scrollUp];
//#endif
//    [self setSearchBarVisibleDisplayMode:self.displayMode Visible:YES];
//    [self CreateSideBar];
    
    self.isLoadingTopicInfo = NO;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear: animated];
    NSArray* vcs = self.navigationController.viewControllers;
    UIViewController* stackVC = vcs[vcs.count - 2];
    
#if K_SERVER_BETA
    lastTopicId = [[NSUserDefaults standardUserDefaults] stringForKey: @"lastTopicID"];
    TopicInfo* topicInfo = [CombinedViewController lastSessionTopic];
    
    if (topicInfo)
    {
        if ([stackVC isKindOfClass: [LoginProcessViewController class]])
        {
            [self showThreadViewControllerWithTopicInfo: topicInfo];
        }
        else
        {
            [self performSelector: @selector(showThreadViewControllerWithTopicInfo:)
                       withObject: topicInfo afterDelay: 2];
        }
    }
    else
    {
        self.meterConnectTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                                  target: self
                                                                selector: @selector(setMeterConnectionWithTimer)
                                                                userInfo: nil
                                                                 repeats: YES];
        
        [self.meterConnectTimer fire];
    }

#else
    if ([stackVC isKindOfClass: [LoginProcessViewController class]])
    {
        [self showThreadViewController];
    }
    else
    {
        [self performSelector: @selector(showThreadViewController)
                   withObject: nil afterDelay: 2];
    }
    //    [self showThreadViewController];
    
#endif
}

- (void) setMeterConnectionWithTimer
{
    if (self.isLoadingTopicInfo == YES)
    {
        return;
    }
    
    MeteorClient* client = [AppDelegate sharedDelegate].meteor;
    if (client.connected && client.userId != nil)
    {
        [self showKnotesWithChrome];
    }
}

- (void) showKnotesWithChrome
{
    self.isLoadingTopicInfo = YES;
    MeteorClient* meteor = [AppDelegate sharedDelegate].meteor;
    
    NSString* subject = @"Knotes";//[TopicInfo defaultName];
    
    NSDictionary* params = @{@"userId" : meteor.userId,
                             @"subject" : subject,
                             @"participator_account_ids" : @[meteor.userId],
                             @"permissions" : @[@"read", @"write", @"upload"]};

    
    [meteor callMethodName: @"getNewTabTopicId" parameters: @[params] responseCallback:^(NSDictionary *response, NSError *error) {
        if (error)
        {
            DLog(@"Meter %@", error.description);
            self.isLoadingTopicInfo = NO;
            return;
        }

        NSString* topicID = response[@"result"];
        lastTopicId = topicID;
        TopicInfo* localTopicInfo = [CombinedViewController lastSessionTopic];
        if (localTopicInfo)
        {
            [self showThreadViewControllerWithTopicInfo: localTopicInfo];
        }
        else
        {
            __weak NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
            [nc addObserverForName: TOPICS_ADDEDED_NOTIFICATION object: nil
                             queue: [NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
                 NSDictionary* topic_info = note.userInfo;
                 NSString* topic_id = topic_info[@"_id"];
                 if ([topicID isEqual: lastTopicId])
                 {
                     [nc removeObserver: self name: note.name object:nil];
                     
                     TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:topic_id];
                     
                     TopicInfo *newInfo = [[TopicInfo alloc] initWithTopicEntity:topic];
                     [self showThreadViewControllerWithTopicInfo: newInfo];
                 }
             }];
        }
    }];
}

- (void) showThreadViewController
{
    TopicInfo* lastTopic = [CombinedViewController lastSessionTopic];
    [self showThreadViewControllerWithTopicInfo: lastTopic];
}

- (void) showThreadViewControllerWithTopicInfo: (TopicInfo*) info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.meterConnectTimer){
            [self.meterConnectTimer invalidate];
            self.meterConnectTimer = nil;
        };
        
        NSUserDefaults* userInfo = [NSUserDefaults standardUserDefaults];
        [userInfo setObject: lastTopicId forKey: @"lastTopicID"];
        [userInfo synchronize];
        
        ThreadViewController* threadViewController = [[ThreadViewController alloc] initWithTopic: info];
        threadViewController.delegate              = self;
        //        threadViewController.isNewTopicAdded       = YES;
        threadViewController.isAutoCreated         = YES;
        [self.navigationController pushViewController: threadViewController animated: NO];
        threadViewController.title = @"Knotes";
        [threadViewController showComposeViewController: YES animated: NO];
    });
}

- (BOOL)shouldShowQuickNoteViewController {
    int minMinutesToShowQuickNoteViewController = 10;
    
    NSUserDefaults *userDefault     = [NSUserDefaults standardUserDefaults];
    NSDate *lastTimeAppWasSentToBackgroundDate = [userDefault objectForKey:@"last_usage_date"];
    
    if (lastTimeAppWasSentToBackgroundDate) {
        NSDate *currentDate = [NSDate date];
        NSInteger minutesSinceLastTimeAppWasSentToBackground = [Utilities minutesBetween:currentDate and:lastTimeAppWasSentToBackgroundDate];
        if (minutesSinceLastTimeAppWasSentToBackground >= minMinutesToShowQuickNoteViewController) {
            return YES;
        }
    } else {
        return YES;
    }
    
    return NO;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if([touch.view isEqual:self.opaqueBlackBackgroundView]){
        return YES;
    }else{
        return  NO;
    }
}

- (void) showInitViewController
{
    return;
    NSArray* topicArray = self.topicArray;

    if (self.isPresentThreadView == YES || self.isViewDidAppear == NO/* || self.topicCount == -1*/)
        return;

    if (topicArray.count > 0) {
        self.isPresentThreadView = YES;
        [self showQuickNoteViewController: topicArray[0]];
    }
    else
    {
        BOOL offline = [ReachabilityManager sharedInstance].currentNetStatus == NotReachable;
        
        if (offline == NO && self.topicCount == -1) // connection is success, but databass not connect yet
            return;

        self.isPresentThreadView = YES;
        [self showInitialComposeViewController];// Init : Create new topic and new
    }
    
//    if (self.isPresentThreadView == NO && self.topicCount == topicArray.count)// "Knotes from iOS" pad not exist after load all data
//    {
//        [self showInitialComposeViewController];// Init : Create new topic and new
//        self.isPresentThreadView = YES;
//    }
}

- (void)showQuickNoteViewController {
    self.view.hidden = YES;
    self.shouldPopToMainView = YES;
    [self startAddTopic:YES];
}

- (void)showQuickNoteViewController:(TopicInfo*) info {
    self.view.hidden = YES;
    self.shouldPopToMainView = YES;
//    [self startAddTopic:YES];
    {
//        [[Lookback_Weak lookback] enteredView:@"Add Topic View"];
        
        ThreadViewController* threadViewController = [[ThreadViewController alloc] initWithTopic: info];
        threadViewController.delegate              = self;
//        threadViewController.isNewTopicAdded       = YES;
        threadViewController.isAutoCreated         = YES;
        threadViewController.shouldPopToMainView   = self.shouldPopToMainView;
        
#if New_DrawerDesign
//        self.stack.hidden=YES;
#endif
        [self.navigationController pushViewController:threadViewController animated:NO];
        self.shouldPopToMainView = NO;
    }
}

- (void)showInitialComposeViewController {
    [[Lookback_Weak lookback] enteredView:@"Initial Compose View"];
    
    self.view.hidden = YES;
    self.shouldPopToMainView = YES;
    
    ThreadViewController * threadviewcontroller = [[ThreadViewController alloc] init];
    threadviewcontroller.view.hidden = YES;
    [self.navigationController pushViewController:threadviewcontroller animated:NO];
    InitialComposeViewController *initialComposeVC = [[InitialComposeViewController alloc] init];
    [self.navigationController pushViewController:initialComposeVC animated:NO];
    self.shouldPopToMainView = NO;
    
    [threadviewcontroller.knoteLoadingView stopProgressBar];
    
//    NSDate * date = [NSDate date];
//    
//    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
//    NSDateComponents *componentsDate = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
//    
//    NSString * minuteS = [NSString stringWithFormat:@"%ld", (long)[components minute]];
//    if(minuteS.length <= 1){
//        minuteS = [@"0" stringByAppendingString:minuteS];
//    }
//    
//    NSString * amORpm = @"am";
//    NSInteger hour = [components hour];
//    if([components hour] >= 13){
//        amORpm = @"pm";
//        if(hour > 12){
//            hour -= 12;
//        }
//    }
//    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"MMMM"];
//    NSString *monthStringFromDate = [formatter stringFromDate:date];
//    formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"EEEE"];
//    NSString *dayStringFromDate = [formatter stringFromDate:date];
//    
//    NSInteger dayNumber = [componentsDate day];
//    NSString *dayNumberString = [NSString stringWithFormat:@"%ld", (long)dayNumber];
//    
//    [self.tableView tapped:nil];
//    
//    // Get current location as text somehow
//    
//    // if(isAutoCreated) -> won't be saved until it has a knote: if left empty, it won't be saved.
//    NSString * sublocality = [self.fullAddress objectForKey:@"SubLocality"] ? [self.fullAddress objectForKey:@"SubLocality"] : @"";
//    NSString * subadministrativeOrCity = [self.fullAddress objectForKey:@"SubAdministrativeArea"] ?
//    [self.fullAddress objectForKey:@"SubAdministrativeArea"] : ([self.fullAddress objectForKey:@"City"]) ? [self.fullAddress objectForKey:@"City"] : @"";
//    
//    /*
//     NSString * address = (sublocality.length > 0 && subadministrativeOrCity.length > 0) ? address = [NSString stringWithFormat:@"%@, %@", sublocality, subadministrativeOrCity] : @"";
//     */
//    
//    NSString * address = (sublocality.length > 0) ? address = [NSString stringWithFormat:@"%@, ", sublocality] : ( (subadministrativeOrCity.length > 0)  ? address = [NSString stringWithFormat:@"%@, ", subadministrativeOrCity] : @"");
//    
//    NSString *padTitle = [NSString stringWithFormat:@"%@%@ %@, %@ %@",address, monthStringFromDate, dayNumberString, [NSString stringWithFormat:@"%ld:%@",(long)hour,minuteS], amORpm];
//    
//    BOOL haveAccessToCalendar = [[AppDelegate sharedDelegate].calendarEventManager eventsAccessGranted];
//    if (haveAccessToCalendar) {
//        BOOL validEventFound = [[AppDelegate sharedDelegate].calendarEventManager getNextEventTitle];
//        if (validEventFound) {
//            padTitle = [[AppDelegate sharedDelegate].calendarEventManager getNextEventTitle];
//        }
//    }
    
//    [[TopicManager sharedInstance] generateNewTopic:padTitle
//                                            account:[DataManager sharedInstance].currentAccount
//                                     sharedContacts:@[] andBeingAutocreated:YES withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
//     {
//         TopicInfo *tInfo= userData;
//         //self.tInfo = userData;
//         tInfo.entity = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:tInfo.topic_id];
//         tInfo.entity.contact_id = [DataManager sharedInstance].currentAccount.user.contact.contact_id;
//         tInfo.item.userData = [MessageEntity MR_findFirstByAttribute:@"message_id" withValue:tInfo.message_id];
//         tInfo.entity.hasNewActivity = @(YES);
//         
//         if ([DataManager sharedInstance].currentAccount.user.contact)
//         {
//             NSMutableSet *topicContacts = [[NSMutableSet alloc] init];
//             
//             [topicContacts addObject:[DataManager sharedInstance].currentAccount.user.contact];
//             
//             tInfo.entity.contacts = [topicContacts copy];
//         }
//         [self needChangeTopicTitle:tInfo];
//         
//         
//         ThreadViewController* threadController = [[ThreadViewController alloc] initWithTopic:tInfo];
//         threadController.delegate = self;
//         
//         // if(isAutoCreated) -> won't be saved until it has a knote: if left empty, it won't be saved.
//         threadController.isAutoCreated = YES;//isAutoCreated;
//         threadController.shouldPopToMainView = self.shouldPopToMainView;
//         
//#if New_DrawerDesign
//         self.stack.hidden=YES;
//#endif
//         threadController.isNewTopicAdded=@"yes";
//         [self.navigationController pushViewController:threadController animated:NO];
//         
//     }];
}

-(void)CreateSideBar
{
    self.sideBar=[[CustomSideBar alloc]initSideBarisShowingFromRight:NO withDelegate:self];
    
}
-(void)addScreenGesturein
{
    
    UIScreenEdgePanGestureRecognizer *panRecognizer =
    [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(handleScreenEdge:)];
    panRecognizer.edges = UIRectEdgeLeft;
    NSLog(@"%@",[[_sideBar getMainViewController] class]);
    [[_sideBar getMainViewController].view addGestureRecognizer:panRecognizer];
}
-(void)handleScreenEdge:(UIScreenEdgePanGestureRecognizer *)gesture
{
    NSInteger index;
    SideMenuViewController  *contentView;
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
            
            if (_displayMode==DisplayModePads)
            {
                index=1;
            }
            else if (_displayMode==DisplayModePeople)
            {
                index=0;
            }
            else if (_displayMode==DisplayModeSettings)
            {
                index=2;
            }
            else
            {
                index=1;
            }
            contentView = [[SideMenuViewController alloc] init];
            contentView.Cur_account=[DataManager sharedInstance].currentAccount;
            contentView.targetDelegate=self;
            contentView.selectedRow=index;
            self.sideBar.ContainerInSidebar=contentView;
            [self.sideBar handlePanning:gesture];
            break;
            
        case UIGestureRecognizerStateChanged:
            [self.sideBar handlePanning:gesture];
            break;
            //u won't need following cases
        case UIGestureRecognizerStateEnded:
             [self.sideBar handlePanning:gesture];
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            
            break;
            
        default:
            break;
    }
}

-(void)createTableView
{
    [self.tableView removeFromSuperview];
    [self.readButton removeFromSuperview];
    [self.unreadButton removeFromSuperview];
    
    CGRect frame = (self.tableView.frame.size.width == 0) ? self.view.bounds : self.tableView.frame;
    
    self.tableView = [[SwipeTableView alloc] initWithFrame:frame];
    
#if kCombinedNewFeature
    
    self.tableView.forceUpdateMinHeight = YES;
    
#endif
    
    self.tableView.swipeDelegate = self;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setBackgroundColor:[UIColor clearColor]];

    self.tableView.tableFooterView=nil;

    self.tableView.opaque = NO;
    self.tableView.backgroundView = nil;
    
    [self.view addSubview:self.tableView];

    self.tableView.translatesAutoresizingMaskIntoConstraints = YES;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tablewViewCurrentYPosition);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
#if !New_DrawerDesign
         make.bottom.equalTo(@(-49));
#else
        make.bottom.equalTo(@0);
#endif
    }];
    
    [self configureQuickFilterButton];
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets=NO;
    
}

-(void)configureQuickFilterButton{
    
    [self.readButton removeFromSuperview];
    [self.unreadButton removeFromSuperview];
    [self.filterButton removeFromSuperview];
    [self.filterAreaBackgroundView removeFromSuperview];

    self.filterAreaBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, [self.tablewViewCurrentYPosition intValue] - TABLEVIEW_INITIAL_Y_POSITION , [UIScreen mainScreen].bounds.size.width, 66)];
    
    self.filterAreaBackgroundView.backgroundColor = [UIColor colorWithWhite:0.941 alpha:1.000];
    self.filterAreaBackgroundView.userInteractionEnabled = YES;
    [self.view addSubview:self.filterAreaBackgroundView];
    
    self.readButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.readButton.tag = 0;
    self.readButton.selected = YES;
    [self.readButton setBackgroundImage:[UIImage imageNamed:@"quickFilterSelected.png"] forState:UIControlStateSelected];;
    [self.readButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0]];
    [self.readButton setTitle:DOING_BUTTON_TITLE forState:UIControlStateNormal];
    [self.readButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.readButton.frame = CGRectMake(10, 18, 60, 30);
    [self.readButton addTarget:self action:@selector(readUnreadChanged:) forControlEvents: UIControlEventTouchDown];
    self.unreadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.unreadButton.tag = 1;
    [self.unreadButton setBackgroundImage:[UIImage imageNamed:@"quickFilterSelected.png"] forState:UIControlStateSelected];;
    [self.unreadButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:13.0]];
    [self.unreadButton setTitle:DONE_BUTTON_TITLE forState:UIControlStateNormal];
    [self.unreadButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.unreadButton.frame = CGRectMake(70, 18, 60, 30);
    [self.unreadButton addTarget:self action:@selector(readUnreadChanged:) forControlEvents: UIControlEventTouchDown];
    
    if(self.filterButton.superview){
        [self.filterButton removeFromSuperview];
    }
    self.filterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.filterButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.filterButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.filterButton setImage:[UIImage imageNamed:@"filterButton.png"] forState:UIControlStateNormal];
    
    self.filterButton.frame = CGRectMake(self.view.frame.size.width - 10 - 120, 18, 100, 30);
    [self.filterButton addTarget:self action:@selector(showHideQuickFilterDialog:) forControlEvents:UIControlEventTouchDown];
    
    [self.filterAreaBackgroundView addSubview:self.filterButton];
    [self.filterAreaBackgroundView addSubview:self.readButton];
    [self.filterAreaBackgroundView addSubview:self.unreadButton];
    //[self.view bringSubviewToFront:self.filterAreaBackgroundView];
}

-(void)showHideQuickFilterDialog:(UIButton *)sender{
    if(self.filterButton.currentBackgroundImage){
        [self configureQuickFilterButton];
        self.filteredArray = nil;
        [self.tableView reloadData];
    }else{
        if(self.filterButton.tag != 0){
            [self.bubbleDialog removeFromSuperview];
            [self.opaqueBlackBackgroundView removeFromSuperview];
            self.opaqueBlackBackgroundView = nil;
            self.bubbleDialog = nil;
            self.filteredArray = nil;
            [self.tableView reloadData];
            self.filterButton.tag = 0;
        }else if(!self.bubbleDialog.superview){
            CGRect frame = sender.frame;
            int width = frame.size.width * 1.3;
            CGRect dialogRect = CGRectMake((frame.origin.x + frame.size.width / 2) - width / 2,
                                           frame.origin.y + frame.size.height + 12 + 64, width, 140);
            [self drawOpaqueBlackBackgroundView];
            [self drawBubble:dialogRect];
            //[self.view bringSubviewToFront:self.bubbleDialog];
        }
    }
    
    
}

-(void)drawOpaqueBlackBackgroundView{
    
    self.opaqueBlackBackgroundView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.opaqueBlackBackgroundView.backgroundColor = [UIColor blackColor];
    self.opaqueBlackBackgroundView.alpha = 0.6;
    [self.navigationController.view addSubview:self.opaqueBlackBackgroundView];
    
    UITapGestureRecognizer *tapInView = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapInView)];
    tapInView.numberOfTapsRequired = 1;
    tapInView.delegate = self;
    [self.opaqueBlackBackgroundView addGestureRecognizer:tapInView];
}

-(void)drawBubble:(CGRect)bubbleRect
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIWindow *window = appDelegate.window;
    
    if(self.showOwner){
        bubbleRect = CGRectMake(bubbleRect.origin.x, bubbleRect.origin.y + 64, bubbleRect.size.width, bubbleRect.size.height);
    }
    
    self.bubbleDialog = [[BubbleView alloc] initWithFrame:bubbleRect];
    self.bubbleDialog.delegate = self;
    
    [window addSubview:self.bubbleDialog];
}

-(void)filterWithFilter:(int)filter{
    
    switch (filter) {
        case UNREAD:
        {
            self.filteredArray = nil;
            
            NSArray *topicArray = [self dataForTable:self.tableView];
            self.filteredArray = [[NSMutableArray alloc] init];
            for(TopicInfo *tInfo in topicArray){
                if(tInfo.entity.hasNewActivity.boolValue){
                    [self.filteredArray addObject:tInfo];
                }
            }
            
            self.filterButton.tag = UNREAD;
            [self.filterButton setBackgroundImage:[UIImage imageNamed:@"filterOnButton.png"] forState:UIControlStateNormal];
            [self.filterButton setImage:nil forState:UIControlStateNormal];
            self.filterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            self.filterButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            [self.filterButton.titleLabel setTextColor:[UIColor whiteColor]];
            NSMutableAttributedString *buttonTittle = [[NSMutableAttributedString alloc] initWithString:
                                                       [NSString stringWithFormat:@"%@%@",
                                                        [NSString fontAwesomeIconStringForEnum:FACircle],
                                                        @"  Unread"]];
            
            [buttonTittle addAttribute:NSFontAttributeName
                            value:[UIFont fontWithName:kFontAwesomeFamilyName size:12]
                            range:NSMakeRange(0,1)];
            
            [self.filterButton setAttributedTitle:buttonTittle forState:UIControlStateNormal];
            
            break;
        }
            
        case BOOKMARKED:
        {
            self.filteredArray = nil;
            
            NSArray *topicArray = [self dataForTable:self.tableView];
            self.filteredArray = [[NSMutableArray alloc] init];
            for(TopicInfo *tInfo in topicArray){
                if(tInfo.entity.isBookMarked.boolValue){
                    [self.filteredArray addObject:tInfo];
                }
            }
            
            self.filterButton.tag = BOOKMARKED;
            [self.filterButton setBackgroundImage:[UIImage imageNamed:@"filterOnButton.png"] forState:UIControlStateNormal];
            [self.filterButton setImage:nil forState:UIControlStateNormal];
            self.filterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            self.filterButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
            [self.filterButton.titleLabel setTextColor:[UIColor whiteColor]];
            NSMutableAttributedString *buttonTittle = [[NSMutableAttributedString alloc] initWithString:
                                                       [NSString stringWithFormat:@"%@%@",
                                                        [NSString fontAwesomeIconStringForEnum:FAFlagO],
                                                        @"   Book..."]];
            
            [buttonTittle addAttribute:NSFontAttributeName
                                 value:[UIFont fontWithName:kFontAwesomeFamilyName size:12]
                                 range:NSMakeRange(0,1)];
            
            [self.filterButton setAttributedTitle:buttonTittle forState:UIControlStateNormal];
            
            break;
        }
            
        case FILES:
        {
            self.filteredArray = nil;
            
            NSArray *topicArray = [self dataForTable:self.tableView];
            self.filteredArray = [[NSMutableArray alloc] init];
            for(TopicInfo *tInfo in topicArray){
                
                NSMutableString *predicateString = [@"topic_id = %@" mutableCopy];
                NSMutableArray *arguments = [[NSMutableArray alloc] initWithObjects:[tInfo.entity.topic_id noPrefix:kKnoteIdPrefix],
                                             nil];
                NSArray *archivedArray = [MessageEntity MR_findAllWithPredicate:[NSPredicate predicateWithFormat:predicateString argumentArray:arguments]];
                
                if(archivedArray.count > 0){
                    MessageEntity * mEntity = ((MessageEntity *)[archivedArray objectAtIndex:0]);
                    if(mEntity.file_ids.length > 0){
                        [self.filteredArray addObject:tInfo];
                    }
                }
            }
            
            self.filterButton.tag = FILES;
            [self.filterButton setBackgroundImage:[UIImage imageNamed:@"filterOnButton.png"] forState:UIControlStateNormal];
            [self.filterButton setImage:nil forState:UIControlStateNormal];
            self.filterButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            self.filterButton.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 0);
            [self.filterButton.titleLabel setTextColor:[UIColor whiteColor]];
            NSMutableAttributedString *buttonTittle = [[NSMutableAttributedString alloc] initWithString:
                                                       [NSString stringWithFormat:@"%@%@",
                                                        [NSString fontAwesomeIconStringForEnum:FAPaperclip],
                                                        @"  Files"]];
            
            [buttonTittle addAttribute:NSFontAttributeName
                                 value:[UIFont fontWithName:kFontAwesomeFamilyName size:12]
                                 range:NSMakeRange(0,1)];
            
            [self.filterButton setAttributedTitle:buttonTittle forState:UIControlStateNormal];
            
            break;
        }
            
        default:
            break;
    }
    
    [self.opaqueBlackBackgroundView removeFromSuperview];
    self.opaqueBlackBackgroundView = nil;
    self.bubbleDialog = nil;
    [self.tableView reloadData];
    
}

-(void)readUnreadChanged:(UIButton *)sender{
    BOOL readButtonPressed = [sender isEqual:self.readButton];
    if(self.displayMode == DisplayModePeople){
        self.showFavoriteContacts = !readButtonPressed;
        [self.tableView reloadData];
    }else if(self.displayMode == DisplayModePads){
        [self showArchivedPads:!readButtonPressed];
    }
    self.readButton.selected = readButtonPressed;
    self.unreadButton.selected = !readButtonPressed;
}

#if New_DrawerDesign
-(void)createFloatingMenu
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIWindow *window = appDelegate.window;    
    
//    if (_stack==nil)
//    {
//        //tmd
//        _stack=[[UPStackMenu alloc]initWithImage:[UIImage imageNamed:@"ios7-plus"] inSelection:YES];
//        //_stack=[[UPStackMenu alloc]initWithImage:[UIImage imageWithIcon:@"fa-pencil-square-o" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] fontSize:40] inSelection:YES];
//
//        [_stack setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.height-40)];
//        [_stack setDelegate:self];
//        if (_displayMode == DisplayModeSettings)
//        {
//            _stack.hidden=YES;
//        }
//        [window addSubview:_stack];
//       
//    }
//    else
//    {
//        if (_displayMode!=DisplayModeSettings)
//        {
//            if ([window.subviews containsObject:_stack])
//            {
//                self.stack.hidden=NO;
//            }
//            else
//            {
//                [window addSubview:_stack];
//                self.stack.hidden=NO;
//
//            }
//        }
//        else
//        {
//            self.stack.hidden=YES;
//        }
//    }
    
}
#endif
-(NSMutableArray *) topicArray
{
    if(!_topicArray) _topicArray = [[NSMutableArray alloc] init];
    return _topicArray;
}

-(NSMutableDictionary *) topicArrayDictionary
{
    if(!_topicArrayDictionary) _topicArrayDictionary = [[NSMutableDictionary alloc] init];
    return _topicArrayDictionary;
}

#pragma mark LocationManager

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@", [error description]);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    self.currentLocation = (CLLocation *)[locations lastObject];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    CLLocationCoordinate2D coordinate = [self.currentLocation coordinate];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error){
        
        if((!error) && (placemarks.count > 0)){
            
            CLPlacemark * placemark = [placemarks objectAtIndex:0];
            self.fullAddress = placemark.addressDictionary;
        }
    }];
}

- (void)requestAccessToEvents {
    [[AppDelegate sharedDelegate].calendarEventManager.eventStore requestAccessToEntityType:EKEntityTypeEvent
         completion:^(BOOL granted, NSError *error) {
             if (error == nil) {
                 [AppDelegate sharedDelegate].calendarEventManager.eventsAccessGranted = granted;
             } else {
                 // In case of error, just log its description to the debugger.
                 NSLog(@"%@", [error localizedDescription]);
             }
         }
     ];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    
    //[self resetAnimation];
    //NSLog(@"%f", scrollView.contentOffset.y);
}
#if New_DrawerDesign
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if (!_sideBar.isOpen)
//    {
//        [self setHiddenAnimated:![self isContentoffsetisNear:scrollView.contentOffset] forView:self.stack];
//    }
    
    if(self.displayMode != DisplayModePads){
        if((scrollView.contentOffset.y > 0) && (scrollView.contentOffset.y != 60) ){
            if(self.tableView.contentInset.top != 0){
                [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            }
        }
    }
}
-(BOOL)isContentoffsetisNear:(CGPoint)offset
{
    if (offset.y<=_searchBgView.frame.size.height+20)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
-(void)setHiddenAnimated:(BOOL)hide forView:(UIView *)vw 
{
    if (hide)
    {
        if (!vw.hidden)
        {
            [UIView animateWithDuration:1
                             animations:^{vw.alpha = 0.0;}
                             completion:^(BOOL finished){[vw setHidden:YES];}];
        }
    }
    else
    {
        if (vw.hidden)
        {
            vw.alpha = 0;
            vw.hidden = NO;
            [UIView animateWithDuration:0.5 animations:^{
                vw.alpha = 1;
            }];
        }
    }
}
#endif
- (void)resetAnimation
{
    // Reset our flags and background color
    self.isRefreshAnimating = NO;
//    self.spinnerImageView.alpha = 0;
}



- (void) manageNotificatioObservers:(BOOL) addflag
{
    if (addflag)
    {
        // Notifications for Contact view
        
        [self managePeopleNotificationObservers:addflag];
        
        // Notifications for Recent view
        
        [self managePadsNotificationObservers:addflag];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadDataTableView)
                                                     name:Pad_BookMarked_Notification
                                                   object:nil];
        
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(hideLoadingView)
                                                     name:HIDE_NOTIFYVIEW_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(TouchableMenu)
                                                     name:MenubarEnableNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(NonTouchableMenu)
                                                     name:MenubarDisableNotification
                                                   object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void) managePeopleNotificationObservers:(BOOL) addflag
{
    if (addflag)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fetchedContacts)
                                                     name:NEW_CONTACT_DOWNLOADED_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fetchedContacts)
                                                     name:CONTACTS_DOWNLOADED_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fetchedContactImage)
                                                     name:CONTACT_IMAGE_DOWNLOADED_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(addedNewContact:)
                                                     name:NEW_CONTACT_ADDED_NOTIFICATION
                                                   object:nil];
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}



- (void) managePadsNotificationObservers:(BOOL) addflag
{
    
    NSLog(@"Flag---->%d",addflag);
    
    if (addflag)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fetchedTopics:)
                                                     name:TOPICS_DOWNLOADED_NOTIFICATION
                                                   object:nil];
        // Added by Lin
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(addedTopic:)
                                                     name:TOPICS_ADDEDED_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(changedTopic:)
                                                     name:TOPICS_CHANGED_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(removedTopic:)
                                                     name:TOPICS_REMOVED_NOTIFICATION
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:FORCE_RELOAD_PAD_FOR_ACTIVE_TOPICS
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                     (unsigned long)NULL), ^(void){
                
//                [self fetchedAllPeopleTopics:self.showArchived];
//                [self reloadData];
                [self fetchedValidTopic];
            });
            
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:FORCE_RELOAD_PAD_FOR_ACTIVE_TOPICS
                                                          object:Nil];
        }];
        
    }
    else
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /*********Navigation Bar changes as per New Design************/
//    NSDictionary *navBarTitleAttr =[NSDictionary dictionaryWithObjectsAndKeys:
//                                    [DesignManager knoteTitleFont],NSFontAttributeName,
//                                    [UIColor blackColor], NSForegroundColorAttributeName, nil];
//    
//    [self.navigationController.navigationBar setTitleTextAttributes: navBarTitleAttr];
    self.navigationController.navigationBarHidden = YES;
//    self.navigationItem.hidesBackButton = YES;
    self.title = @"Knotes";
//
//    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
//    {
//        /*for iOS 7 and newer*/
//        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithWhite:0.941 alpha:1.000]];
//    }
//    else
//    {
//        /*for older versions than iOS 7*/
//        [self.navigationController.navigationBar setTintColor:[UIColor colorWithWhite:0.941 alpha:1.000]];
//    }
//    [(KnotableNavigationController *)self.navigationController navBorder].hidden=NO;
//    /*********************/
//    
//    self.view.hidden = NO;
//    
//    self.willSegueAfterRowTap = NO;
//    [self.view.layer removeAnimationForKey:kCombineAnimation];
//    
//    [self manageNotificatioObservers:YES];
//    
//    NSLog(@"CombinedViewController viewWillAppear");
//    [DataManager sharedInstance].combinedVC = self;
//
////    if(self.snapshotImageView) self.snapshotImageView.hidden = YES;
////    
////    self.isCurrentShow = YES;
////    
////    self.navigationController.navigationBar.translucent = NO;
////    self.navigationController.navigationBarHidden = NO;
////
////    [self clearEditingCell];
////    
////    self.showMutedItems = self.recent_showMutedItems_Flag;
////    
////    if(self.editingCell)
////    {
////        NSLog(@"resetting self.editingCell in viewWillAppear");
////        [self clearEditingCell];
////    }
////    
////    
////    if (!self.firstLoad)
////    {
////        if (self.displayMode == DisplayModePads)
////        {
////            [self UpdateNavigationBarIndex:2];
////#if !New_DrawerDesign
////            [self.bottomMenuBar UpdateButtonStateIndex:2];
////#endif
////            [self reloadData];
////            
////        }
////        else if(self.displayMode == DisplayModeSettings)
////        {
////            [self UpdateNavigationBarIndex:3];
////#if !New_DrawerDesign
////            [self.bottomMenuBar UpdateButtonStateIndex:3];
////#endif
////        }
////    }
////    else
////    {
////        
////#if New_DrawerDesign
////        
////        if (_displayMode==DisplayModePads)
////        {
////            [self BottomMenuActionIndex:2];
////            
////            if (![[self getTitleForTopLoadingBar] isEqual:@""])
////            {
////                [self.spinnerImageView startProgressWithTitle:[self getTitleForTopLoadingBar]];
////                
////            }
////        }
////        else if (_displayMode==DisplayModePeople)
////        {
////            [self BottomMenuActionIndex:1];
////            
////            if (![[self getTitleForTopLoadingBar] isEqual:@""])
////            {
////                [self.spinnerImageView startProgressWithTitle:[self getTitleForTopLoadingBar]];
////
////            }
////        }
////        else if (_displayMode==DisplayModeSettings)
////        {
////            [self BottomMenuActionIndex:3];
////        }
////#else
////        [self BottomMenuActionIndex:2];
////        [self.bottomMenuBar UpdateButtonStateIndex:2];
////#endif
////        [self.navigationSortMenu.m_btnSort setTitleColor:[DesignManager KnoteNormalColor] forState:UIControlStateNormal];
////        
////        self.firstLoad = NO;
////        [AppDelegate sharedDelegate].barstyleloaderCombine=self.spinnerImageView.statusBarLoaderView;
////
////        [[AppDelegate sharedDelegate].barstyleloaderCombine setBackgroundColor:[UIColor colorWithWhite:0.941 alpha:1.000]];
////        [self scrollUp];
////    }
////    self.isUpdatedTopic = YES;
////  
////#if New_DrawerDesign
////    [self createFloatingMenu];
////#endif
////    [self addScreenGesturein];
//}
//- (void) viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear: animated];
//    
//    self.isViewDidAppear = YES;
//    
////    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
//    
//    [self showInitViewController];
//
////    if(!self.snapshotImageView)
////    {
////        CGRect fullScreen = [[UIScreen mainScreen] bounds];
////        UIImage *img = [Utilities takeSnapshotFromWholeView];
////        self.snapshotImageView = [[UIImageView alloc] initWithFrame:fullScreen];
////        self.snapshotImageView.image = img;
////        self.snapshotImageView.hidden = YES;
////        [self.view addSubview:self.snapshotImageView];
////        [self.snapshotImageView mas_makeConstraints:^(MASConstraintMaker *make) {
////            make.width.equalTo([NSNumber numberWithFloat:fullScreen.size.width]);
////            make.bottom.equalTo([NSNumber numberWithFloat:0]);
////            make.top.equalTo([NSNumber numberWithFloat:0]);
////            make.centerX.equalTo(@0.0);
////        }];
////    }
////    
////    self.showMutedItems = self.recent_showMutedItems_Flag;
////    
////    if(self.autoKnote)
////    {
////        self.autoKnote = NO;
////        
////        [self performSelector:@selector(startAddTopic)
////                   withObject:nil
////                   afterDelay:0.25];
////    }
////    
////    if (self.displayMode == DisplayModePeople)
////    {
////        [self UpdateNavigationBarIndex:1];
////#if !New_DrawerDesign
////        [self.bottomMenuBar UpdateButtonStateIndex:1];
////#endif
////    }
////    else if (self.displayMode == DisplayModePads)
////    {
////        [self UpdateNavigationBarIndex:2];
////#if !New_DrawerDesign
////        [self.bottomMenuBar UpdateButtonStateIndex:2];
////#endif
////    }
////    else if(self.displayMode == DisplayModeSettings)
////    {
////        [self UpdateNavigationBarIndex:3];
////#if !New_DrawerDesign
////        [self.bottomMenuBar UpdateButtonStateIndex:3];
////#endif
////    }
////    
////    [self fetchedAllPeopleTopics:NO];
////    
////    // Check if we should display "Doing" or "Done" list
////    if(self.unreadButton.selected){
////        self.showArchived = NO;
////        [self readUnreadChanged:self.unreadButton];
////    }
}

-(void) viewWillDisappear:(BOOL)animated
{
    for (UIGestureRecognizer *recognizer in [_sideBar getMainViewController].view.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
        {
            [[_sideBar getMainViewController].view removeGestureRecognizer:recognizer];
        }
    }
    [DataManager sharedInstance].combinedVC = nil;

    [self manageNotificatioObservers:NO];
    
//    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
    CGRect fullScreen = [[UIScreen mainScreen] bounds];
    [self.view setFrame:fullScreen];
    
    [super viewWillDisappear:animated];
    self.title=@"";
    self.isCurrentShow = NO;
    self.snapshotImageView.hidden = NO;
    
    [self.spinnerImageView stopProgressBar];
    
//#if New_DrawerDesign
//    self.stack.hidden=YES;
//#endif
    
//    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMAGE_DOWNLOADED_NOTIFICATION object:file];
}

- (void)logCounts
{

    NSLog(@"topicData: %d peopleData: %d", (int)self.topicArray.count, (int)self.peopleData.count);
    NSLog(@"total topic count: %d", (int)[TopicsEntity MR_countOfEntities]);
    
    if ([AppDelegate sharedDelegate].user_active_topics == 0)
    {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        [AppDelegate sharedDelegate].user_active_topics = [userDefault integerForKey:kUserTopicCount];
    }
    
    if ([AppDelegate sharedDelegate].user_archived_topics == 0)
    {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        [AppDelegate sharedDelegate].user_archived_topics = [userDefault integerForKey:kUserArchivedTopicCount];
    }
}
#if New_DrawerDesign
-(void)sidebarwillShowOnScreenAnimated:(BOOL)animatedYesOrNo
{
//    if (self.stack)
//    {
//        self.stack.hidden=YES;
//    }
}
-(void)sidebardidDismissFromScreenAnimated:(BOOL)animatedYesOrNo
{
//    if (self.stack)
//    {
//        if (_displayMode!=DisplayModeSettings)
//        {
//            self.stack.hidden=NO;
//        }
//        
//    }
}
-(void)makeupstakenil
{
//    if (self.stack)
//    {
//        self.stack=nil;
//
//    }
}
#pragma mark - moz delegate
-(void)mozAlertViewWillDisplay
{
//    [UIView animateWithDuration:0.5
//                     animations:^{
//                         CGRect frame = self.stack.frame;
//                         frame.origin.y -= 36;
//                         self.stack.frame = frame;
//                     }
//                     completion:^(BOOL finished){
//                         // whatever you need to do when animations are complete
//                     }];
}
-(void)mozAlertViewWillhide
{
//    [UIView animateWithDuration:0.5
//                     animations:^{
//                         CGRect frame = self.stack.frame;
//                         frame.origin.y += 36;
//                         self.stack.frame = frame;
//                     }
//                     completion:^(BOOL finished){
//                         // whatever you need to do when animations are complete
//                     }];
}
#pragma mark - StackDelegate
-(void)openStackwithSelector
{
    self.searchBar.showsCancelButton = NO;
    self.searchController.displaysSearchBarInNavigationBar = NO;
    [self.searchController setActive:NO animated:NO];
    [self addPressed];
}
#endif
#pragma mark - barbutton item method

- (UIBarButtonItem *) customBarButtonItem
{
UIImage *barButtonBgImage = [UIImage imageNamed:@"new-topic-icon"];
    UIButton *customBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customBarButton.bounds = CGRectMake( 0, 0, barButtonBgImage.size.width, barButtonBgImage.size.height);
    [customBarButton setImage:barButtonBgImage forState:UIControlStateNormal];
    [customBarButton addTarget:self action:@selector(addPressed) forControlEvents:UIControlEventTouchUpInside];
    return [[UIBarButtonItem alloc] initWithCustomView:customBarButton];
}

#pragma mark - Notification Functions

-(void)reloadData
{
    if (self.isCurrentShow)
    {
        [self.tableView reloadData];
    }
}

-(void)reloadDataTableView{
    
    if (self.tableView) {
        
        [self.tableView reloadData];
    }

}

- (NSString *)documentsPathForFileName:(NSString *)name {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsPath = [paths objectAtIndex:0];
    
    return [documentsPath stringByAppendingPathComponent:name];
}

- (void) fetchedContacts
{
    if (![[self getTitleForTopLoadingBar] isEqual:@""])
    {
        [self.spinnerImageView startProgressWithTitle : [self getTitleForTopLoadingBar]];
    }
    
    self.peopleData = [self fetchAllContactsExcludingSelfForSortFlag:NO archiveFlag:NO];
    
    if(self.displayMode == DisplayModePeople)
    {
        [self hideLoadingView];
        
        [self reloadData];
    }
    
    if(self.currentAccount.user.contact)
    {
        self.userContact = self.currentAccount.user.contact;
        
        if(!self.currentContact)
        {
            [self setCurrentContact:self.userContact];
        }
    }
    
    if ([self canHideTopProgressLoading]) {
        
        [self.spinnerImageView stopProgressBar];
    }
    
    // Need to check to count notification
}

- (void) fetchedContactImage
{
    NSLog(@"fetchedContactImage");
    
    if(self.displayMode == DisplayModePeople)
    {
        [self reloadData];
    }
    
    // Need to check to count notification
}

-(NSMutableDictionary *) padsCache
{
    if(!_padsCache) _padsCache = [[NSMutableDictionary alloc] init];
    
    return _padsCache;
}

// Lin - Added to

#define PERCENTAJE_PADS_LOAD_TOLLERANCE 0.30

-(float)fetchedTopicsStep
{
    NSString* accountID = Nil;
    
    if ([[AppDelegate sharedDelegate].appUserAccountID length] > 0)
    {
        accountID = [AppDelegate sharedDelegate].appUserAccountID;
    }
    else if ([[DataManager sharedInstance].currentAccount.account_id length] > 0)
    {
        accountID = [DataManager sharedInstance].currentAccount.account_id;
    }
    
    NSUInteger local_active_topic_count = 0;
    NSUInteger local_archived_topic_count = 0;
    
    NSPredicate *predicate_active = [NSPredicate predicateWithFormat:@"(isArchived == %@)",
                                     @(NO)];
    
    NSPredicate *predicate_archived = [NSPredicate predicateWithFormat:@"(isArchived == %@)",
                                     @(YES)];
    
    local_active_topic_count = [TopicsEntity MR_countOfEntitiesWithPredicate:predicate_active];
    local_archived_topic_count = [TopicsEntity MR_countOfEntitiesWithPredicate:predicate_archived];
    
    float progress_active = 0 ;
    float progress_archive = 0 ;
    
    if ([AppDelegate sharedDelegate].user_active_topics)
    {
        progress_active = local_active_topic_count / (float)[AppDelegate sharedDelegate].user_active_topics;
        
        DLog(@">>> Active Pads %ld : %lu (%f %%)", (long)[AppDelegate sharedDelegate].user_active_topics, (unsigned long)local_active_topic_count, progress_active * 100);
    }
    
    if ([AppDelegate sharedDelegate].user_archived_topics)
    {
        progress_archive = local_archived_topic_count / (float)[AppDelegate sharedDelegate].user_archived_topics;
        
        DLog(@">>> Archived Pads %ld : %lu (%f %%)", (long)[AppDelegate sharedDelegate].user_archived_topics, (unsigned long)local_archived_topic_count, progress_archive * 100);
    }
    
    if ( progress_active >= 1)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                 (unsigned long)NULL), ^(void){
            
//            [self fetchedAllPeopleTopics:self.showArchived];
            [self fetchedValidTopic];
        });
    }
    
    return progress_active;
}

- (void) addedTopic:(NSNotification *) notification
{
    [self fetchedTopicsStep];
    
    NSDictionary* topic_info = notification.userInfo;
    
    NSString *topic_id = topic_info[@"_id"];
    
    TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:topic_id];
    
    TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:topic];
    
    NSUInteger local_active_topic_count = 0;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isArchived == %@)",
                              @(NO)];
    
    local_active_topic_count = [TopicsEntity MR_countOfEntitiesWithPredicate:predicate];
    
    NSString *my_account_id = self.currentAccount.account_id;
    
    if (my_account_id)
    {
        tInfo.my_account_id = my_account_id;
    }
    else
    {
        tInfo.my_account_id = topic.account_id;
    }

    if (topic)
    {
        // Data source update

        if (local_active_topic_count > [AppDelegate sharedDelegate].user_active_topics)
        {
            [self.topicArray insertObject:tInfo atIndex:0];
        }
        else
        {
            [self.topicArray addObject:tInfo];
        }
        
        [self.topicArrayDictionary setObject:tInfo forKey:tInfo.topic_id];
        
        if (self.displayMode != DisplayModePads)
        {
            return;
        }
        
        int offest = 0;
        
        if (self.showOwner)
        {
            //offest = 1;
        }
        else
        {
            offest = 0;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //Table View Crash Issue
            
            NSIndexPath *changeIndex = Nil;
            
            if (self.isUpdatedTopic)
            {
                self.isUpdatedTopic=NO;
                [CATransaction begin];
                
                [CATransaction setCompletionBlock:^{
                    self.isUpdatedTopic=YES;
                }];
                
                
               // [self.tableView beginUpdates];
                
                if (local_active_topic_count > [AppDelegate sharedDelegate].user_active_topics)
                {
                    DLog(@"Checkpint : %ld ****** %lu", (long)[AppDelegate sharedDelegate].user_active_topics, (unsigned long)local_active_topic_count);

                    changeIndex = [NSIndexPath indexPathForRow:offest inSection:0];
                    
                    // UItableview reload
                   /* [self.tableView insertRowsAtIndexPaths:@[changeIndex]
                                          withRowAnimation:UITableViewRowAnimationTop];*/
                }
                else
                {

                    changeIndex = [NSIndexPath indexPathForRow:(offest + [self.topicArray count] - 1) inSection:0];
                    // UItableview reload
                   /* [self.tableView insertRowsAtIndexPaths:@[changeIndex]
                                          withRowAnimation:UITableViewRowAnimationTop];*/
                }
                [self updateData];
                //[self.tableView endUpdates];
                
                [CATransaction commit];
            }
            
        });
    }
}

- (void) changedTopic:(NSNotification *) notification
{
    //Dhruv : For now commented Pad loading issue Specify why it is repeatedly executing here...???
    // [self fetchedTopicsStep];
    
    if (self.displayMode != DisplayModePads)
    {
        return;
    }
    
    NSDictionary* topic_info = notification.userInfo;
    
    NSString *topic_id = topic_info[@"_id"];
    
    [glbAppdel.managedObjectContext lock];
    
    TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:topic_id];
    
    [glbAppdel.managedObjectContext unlock];
    
    TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:topic];
    
    
        if (topic)
        {
            
            int offest = 0;
            
            if (self.showOwner)
            {
                //offest = 1;
            }
            else
            {
                offest = 0;
            }
            self.view.userInteractionEnabled=NO;
            if (self.topicArray)
            {
                for (int i = 0; i < [self.topicArray count] ; i ++)
                {
                    if ((i - offest)<0)
                    {
                        offest=0;
                    }
                    TopicInfo* p = (TopicInfo*)( self.topicArray[i - offest] );
                    if ([p.topic_id isEqualToString:topic_id])
                    {
                        if ([self.topicArray count] > (i - offest))
                        {
                           
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                                    
                               
                                NSIndexPath *changeIndex = Nil;
                                
                                changeIndex = [NSIndexPath indexPathForRow:(i - offest) inSection:0];
                                
                                if( (i - offest) >= 0)
                                {
                                    if (p.cell)
                                    {
                                        tInfo.cell = p.cell;
                                        tInfo.indexPath = changeIndex;
                                        tInfo.delegate = self;
                                    }
                                        [CATransaction begin];
                                        [CATransaction setCompletionBlock:^{
                                            
                                             [self.tableView reloadData];
                                        }];
                                    
                                    if([self.topicArray count] > 0)
                                        [self.topicArray replaceObjectAtIndex:(i - offest) withObject:tInfo];
                                        [CATransaction commit];

                            
                                    //Table View Crash Issue
                                    
                                   /* [CATransaction begin];
                                    
                                    [CATransaction setCompletionBlock:^{
                                        
                                        self.isUpdatedTopic=YES;
                                        
                                    }];
                                    
                                    [self.tableView beginUpdates];
                                    
                                    [self.topicArray replaceObjectAtIndex:(i - offest) withObject:tInfo];
                                    
                                    [self.tableView reloadRowsAtIndexPaths:@[changeIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
                                    
                                    [self.tableView endUpdates];
                                    
                                    [CATransaction commit];*/
                                    
                                }
                                
                            });
                            
                        }
                        
                        break;
                    }
                }
            
        }
            self.view.userInteractionEnabled=YES;

    }
}

- (void) removedTopic:(NSNotification *) notification
{
    NSDictionary* topic_info = notification.userInfo;
    NSString *topic_id = topic_info[@"_id"];
    [self removeTopicWithTopicID:topic_id];
    
    /*
    dispatch_async(dispatch_get_main_queue(), ^{
        [self reloadData];
    });
     */
    
    return;
}

- (void) removedAutoGeneratedTopic:(NSString *) topicID{

    TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:topicID];
    [topic MR_deleteEntity];
    [AppDelegate saveContext];
    
}



- (void) removeTopicWithTopicID:(NSString*)topic_id
{

    if (self.displayMode != DisplayModePads)
    {
        return;
    }
    if (!_isRemovedNow)
    {
        _isRemovedNow=YES;
        return;
    }
    [self clearEditingCell];

    TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:topic_id];
    
    if (topic)
    {
        int offest = 0;
        
        if (self.showOwner)
        {
            //offest = 1;
        }
        else
        {
            offest = 0;
        }
                    if (self.topicArray)
                    {
                        for (int i = 0; i < [self.topicArray count] ; i ++)
                        {
                            if (i-offest<0)
                            {
                                offest=0;
                            }
                            TopicInfo* p = (TopicInfo*)( self.topicArray[i - offest] );
                            
                            if([p.topic_id rangeOfString:topic_id].location != NSNotFound)
                                //if ([p.topic_id isEqualToString:topic_id])
                            {
                                if ([self.topicArray count] > (i - offest))
                                {
                                    NSLog(@"Data source count : %lu", (unsigned long)[self.topicArray count]);
                                    [p udpateSelfTopicArchive:btnOperDelete];
                                    _tempEntity=p;
                                    NSLog(@"%d",p.archived);
                                    NSLog(@"%@",p.entity.isArchived);
                                    
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        
                                        NSIndexPath *changeIndex = Nil;
                                        
                                        changeIndex = [NSIndexPath indexPathForRow:(i - offest) inSection:0];
                                        
                                        NSLog(@"%d : %ld", (i - offest), (long)p.indexPath.row);
                                        
                                        //Table View Crash Issue
                                        if (self.isUpdatedTopic )
                                        {
                                            _isUpdatedTopic=NO;
                                            NSLog(@"inside table remove.");
                                            
                                            [CATransaction begin];
                                            [CATransaction setCompletionBlock:^{
                                                self.isUpdatedTopic=YES;
                                                if (!self.showArchived)
                                                {
                                                    NSLog(@"inside show archived.");
                                                    
                                                    //Dhruv Code for UNDO function on pad list
                                                    [MozTopAlertView showWithType:MozAlertTypeWarning text:[NSString stringWithFormat:@"Pad Archived."] doText:@"UNDO" andDelegate:self doBlock:^{
                                                        NSLog(@"do undo");
                                                        NSLog(@"inside MozTopAlertView");
                                                        
                                                        [_tempEntity udpateSelfTopicArchive:btnOperDelete];
                                                        AppDelegate *app = [AppDelegate sharedDelegate];
                                                        
                                                        if ([ReachabilityManager sharedInstance].currentNetStatus==NotReachable)
                                                        {
                                                            _tempEntity.entity.needToSync=@(YES);
                                                        }
                                                        else
                                                        {
                                                        [app.meteor callMethodName:@"topic.restore"
                                                                        parameters:@[_tempEntity.topic_id]
                                                                  responseCallback:^(NSDictionary *response, NSError *error)
                                                         {
                                                             NSLog(@"before");
                                                             if (!error)
                                                             {
                                                                 
                                                                 NSLog(@"after");
                                                                 
                                                             }
                                                             
                                                         }];
                                                        }
                                                        if (_tempEntity.entity && ![_tempEntity.entity isFault])
                                                        {
                                                            _tempEntity.entity.isArchived = @(NO);
                                                        }
                                                        
                                                        _tempEntity.archived = NO;
                                                        _isRemovedNow=NO;
                                                        [AppDelegate saveContext];
                                                        
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            NSIndexPath *changeIndex = Nil;
                                                            changeIndex = [NSIndexPath indexPathForRow:(i - offest) inSection:0];
                                                            NSLog(@"%d : %ld", (i - offest), (long)_tempEntity.indexPath.row);
                                                            
                                                            if (_tempEntity.entity.isArchived)
                                                            {
                                                                if (self.isUpdatedTopic)
                                                                {
                                                                    NSLog(@"inside table add");
                                                                    
                                                                    _isUpdatedTopic=NO;
                                                                    [CATransaction begin];
                                                                    [CATransaction setCompletionBlock:^{
                                                                        self.isUpdatedTopic=YES;
                                                                        NSLog(@"inside table add after");
                                                                    }];
                                                                    if (_displayMode==DisplayModePads)
                                                                    {
                                                                        [self.tableView beginUpdates];
                                                                        
                                                                        [self.topicArray insertObject:_tempEntity atIndex:changeIndex.row];
                                                                        [self.tableView insertRowsAtIndexPaths:@[changeIndex] withRowAnimation:UITableViewRowAnimationLeft];
                                                                        
                                                                        [self.tableView endUpdates];
                                                                    }
                                                                    else
                                                                    {
                                                                        [self.topicArray insertObject:_tempEntity atIndex:changeIndex.row];
                                                                    }
                                                                    
                                                                    
                                                                    
                                                                    [CATransaction commit];
                                                                }
                                                            }
                                                        });
                                                        [MozTopAlertView hideViewWithParentView:self.view];
                                                    } parentView:self.view];
                                                }
                                            }];
                                            
                                            if(changeIndex.row < self.topicArray.count){
                                                NSLog(@"before crash changeIndex %ld,topic array %lu",(long)changeIndex.row,(unsigned long)self.topicArray.count);
                                                if (self.topicArray.count==1)
                                                {
                                                    [self.topicArray removeObjectAtIndex:changeIndex.row];
                                                    [self.tableView reloadData];

                                                }
                                                else
                                                {
                                                [self.tableView beginUpdates];
                                                [self.topicArray removeObjectAtIndex:changeIndex.row];
                                                [self.tableView deleteRowsAtIndexPaths:@[changeIndex] withRowAnimation:UITableViewRowAnimationLeft];
                                                [self.tableView endUpdates];
                                                }
                                                
                                            }
                                            
                                            [CATransaction commit];
                                            
                                        }
                                    });
                                }
                    
                    break;
                }
            }
        }
    }
}

- (void) fetchedSubTopics:(NSNotification *)note
{
    NSLog(@"fetchedSubTopics");
 
    if (self.displayMode != DisplayModePads)
    {
        return;
    }
    
    M13OrderedDictionary * topic_ids = Nil;
    
    if (note.userInfo)
    {
        topic_ids = [note.userInfo objectForKey:@"topic_ids"];
        
        NSLog(@"Topic IDs : %@", topic_ids);
    }
    
    for (int i = 0 ; i < [topic_ids count] ; i ++)
    {
        NSString* topic_id = [topic_ids objectAtIndex:i];
        
        TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:topic_id];
        
        if ( [self.topicArrayDictionary objectForKey:topic_id] )
        {
            // This is the existing topic.
            
            TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:topic];
            
            if (topic)
            {
                int offest = 0;
                
                if (self.showOwner)
                {
                    //offest = 1;
                }
                else
                {
                    offest = 0;
                }
                                if (self.topicArray)
                                {
                                    for (int i = 0; i < [self.topicArray count] ; i ++)
                                    {
                                        TopicInfo* p = (TopicInfo*)( self.topicArray[i - offest] );
                                        
                                        if ([p.topic_id isEqualToString:topic_id])
                                        {
                                            if ([self.topicArray count] > (i - offest))
                                            {
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    
                                                    NSIndexPath *changeIndex = Nil;
                                                    
                                                    changeIndex = [NSIndexPath indexPathForRow:(i - offest) inSection:0];
                                                    
                                                    if (p.cell)
                                                    {
                                                        tInfo.cell = p.cell;
                                                        
                                                        tInfo.indexPath = changeIndex;
                                                        
                                                        tInfo.delegate = self;
                                                    }
                                                    //Table View Crash Issue
                                                    if (self.isUpdatedTopic)
                                                    {
                                                        [CATransaction begin];
                                                        [CATransaction setCompletionBlock:^{
                                                            self.isUpdatedTopic=YES;
                                                        }];
                                                        [self.tableView beginUpdates];
                                                        
                                                        [self.topicArray replaceObjectAtIndex:(i - offest) withObject:tInfo];
                                                        
                                                        [self.tableView reloadRowsAtIndexPaths:@[changeIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
                                                        
                                                        [self.tableView endUpdates];
                                                        [CATransaction commit];
                                                    }
                                                });
                                
                            }
                            
                            break;
                        }
                    }
                }
            }
        }
        else
        {
            // This is the new topic from server.
            
            TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:topic];
            
            NSString *my_account_id = self.currentAccount.account_id;
            
            if (my_account_id)
            {
                tInfo.my_account_id = my_account_id;
            }
            else
            {
                tInfo.my_account_id = topic.account_id;
            }
            
            if (topic)
            {
                int offest = 0;
                
                if (self.showOwner)
                {
                    //offest = 1;
                }
                else
                {
                    offest = 0;
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSArray *topics = [self fetchTopicsForContact:self.currentContact];
                    
                    NSInteger newIndex = [topics indexOfObject:topic];
                    NSInteger change_index_row = 0;
                    
                    if (newIndex > 0)
                    {
                            for (int i = 0 ; i < [self.topicArray count] ; i ++ )
                            {
                                NSString* focused_topic_id = Nil;
                                
                                TopicInfo* topic_info = [self.topicArray objectAtIndex:i];
                            focused_topic_id = topic_info.topic_id;
                            
                            TopicsEntity* topic_entity = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:focused_topic_id];
                            
                            if ( [topics indexOfObject:topic_entity] < newIndex)
                            {
                                
                            }
                            else
                            {
                                change_index_row = i;
                                
                                break;
                            }
                            
                        }
                        
                    }
                    
                    NSIndexPath *changeIndex = Nil;
                    
                    changeIndex = [NSIndexPath indexPathForRow:(offest + change_index_row) inSection:0];
                    //Table View Crash Issue
                    if (self.isUpdatedTopic)
                    {
                        [CATransaction begin];
                        [CATransaction setCompletionBlock:^{
                            self.isUpdatedTopic=YES;
                        }];
                    [self.tableView beginUpdates];
                    
                    // Data source update
                    [self.topicArrayDictionary setObject:tInfo forKey:tInfo.topic_id];

                    [self.topicArray insertObject:tInfo atIndex:change_index_row];
                    // UItableview reload
                    [self.tableView insertRowsAtIndexPaths:@[changeIndex] withRowAnimation:UITableViewRowAnimationTop];
                    
                    [self.tableView endUpdates];
                        [CATransaction commit];
                    }
                });
            }
        }
        
    }
    
    
    
}

// Lin - Ended

- (void) fetchedTopics:(NSNotification *)note
{
    NSLog(@"fetchedTopics");
    
#if kUseFetchedController
    
    return;
    
#endif
    
    if (self.displayMode != DisplayModePads)
    {
        return;
    }
    
    if (note.userInfo)
    {
        NSDictionary* topic_ids = [note.userInfo objectForKey:@"topic_ids"];
        
        NSLog(@"Topic IDs : %@", topic_ids);
    }
    
    if (self.currentContact == Nil)
    {
        [self setCurrentContact:self.currentAccount.user.contact];
    }
    
    if (self.currentContact)
    {
        if (self.isUpdatedTopic)
        {

        [self.topicArray removeAllObjects];
        [self.topicArrayDictionary removeAllObjects];
        
        NSArray *topics = [self fetchTopicsForContact:self.currentContact];
        
        NSString *my_account_id = self.currentAccount.account_id;
        
        for (int i = 0; i<[topics count]; i++)
        {
            TopicsEntity *entity = [topics objectAtIndex:i];
            
            TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:entity];
            
            //NSLog(@"%@", tInfo.topic_id);
            
            if (my_account_id)
            {
                tInfo.my_account_id = my_account_id;
            }
            else
            {
                tInfo.my_account_id = entity.account_id;
            }
            
            if([self.topicArrayDictionary objectForKey:tInfo.topic_id])
            {
                int pos = 0;

                for(int i = 0; i < self.topicArray.count; i++)
                {
                    pos = i;
                    
                    TopicInfo * auxtInfo = [self.topicArray objectAtIndex:pos];
                    
                    if([tInfo.topic_id isEqualToString:auxtInfo.topic_id])
                        break;
                }
                
                [self.topicArray replaceObjectAtIndex:pos withObject:tInfo];
            }
            else
            {
                [self.topicArrayDictionary setObject:tInfo forKey:tInfo.topic_id];
                [self.topicArray addObject:tInfo];
                
                if(self.displayMode == DisplayModePeople)
                {
                    /*
                    if(self.knoteProgressBar.superview)
                    {
                        float progress = self.topicArray.count / ((float)[TopicsEntity MR_countOfEntities]);
                        
                        [self.knoteProgressBar setProgress:progress animated:YES];
                    }
                     */
                    
                }
            }
        }

        NSLog(@"%lu - %lu", (unsigned long)[self.topicArray count], (unsigned long)[self.topicArrayDictionary count]);
        if(self.displayMode == DisplayModePads)
        {
            [self reloadData];
        }
        
    }
    }
    else
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                 (unsigned long)NULL), ^(void){
            
//            [self fetchedAllPeopleTopics:self.showArchived];
            [self fetchedValidTopic];
        });
    }
    
    // Need to check to count notification
    
}

+ (TopicInfo*) lastSessionTopic
{
    if (lastTopicId.length == 0)
        return nil;
#if K_SERVER_BETA

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isArchived == 0 && topic_id != nil && topic_id == %@)", lastTopicId];

    NSArray* topics = [TopicsEntity MR_findAllSortedBy:@"updated_time" ascending:NO withPredicate:predicate];
    
    TopicInfo* lastTopic = nil;
    
    for (TopicsEntity *entity in topics)
    {
        if (entity.isFault)
            [entity MR_refresh];
        if (lastTopicId == nil) // not history for last jobs
        {
            if ([entity.topic_id hasPrefix: kKnoteIdPrefix])
                continue;
        }
        
        TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:entity];
        tInfo.my_account_id = entity.account_id;
        lastTopic = tInfo;
        break;
    }
    return lastTopic;

    
#else
    lastTopicId = [[NSUserDefaults standardUserDefaults] stringForKey: @"lastTopicID"];
    NSMutableArray* topics = [NSMutableArray array];
    NSPredicate *predicate = nil;
    NSMutableArray* predicates = [NSMutableArray array];
    if (lastTopicId.length > 0)
    {// last edit topic
        predicate = [NSPredicate predicateWithFormat:@"(isArchived == %@ && topic_id == %@)", @(NO), lastTopicId];
        [predicates addObject: predicate];
    }
    
    // get by default name
    predicate = [NSPredicate predicateWithFormat:@"(isArchived == %@ && topic_id != nil && topic == %@)", @(NO), defaultTopicName];
    [predicates addObject: predicate];
    // all valide
    predicate = [NSPredicate predicateWithFormat:@"(isArchived == %@ && topic_id != nil)", @(NO)];
    [predicates addObject: predicate];
    
    for (NSPredicate* subPredicate in predicates) {
        NSArray* subTopicArray = [TopicsEntity MR_findAllSortedBy:@"updated_time" ascending:NO withPredicate:subPredicate];
        [topics addObjectsFromArray: subTopicArray];
    }
    
    TopicInfo* lastTopic = nil;
    
    for (TopicsEntity *entity  in topics)
    {
        if (lastTopicId == nil) // not history for last jobs
        {
            if ([entity.topic_id hasPrefix: kKnoteIdPrefix])
                continue;
        }
        
        TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:entity];
        tInfo.my_account_id = entity.account_id;
        lastTopic = tInfo;
        break;
    }
    return lastTopic;
#endif
}


- (void) fetchedValidTopic
{
    [self.topicArray removeAllObjects];
    [self.topicArrayDictionary removeAllObjects];
    
#if 0
    lastTopicId = [[NSUserDefaults standardUserDefaults] stringForKey: @"lastTopicID"];
    
    NSMutableArray* topics = [NSMutableArray array];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isArchived == %@ && topic_id != nil)",
                              @(NO)];

    // select able topics
    NSArray* allTopcis = [TopicsEntity MR_findAllSortedBy:@"updated_time" ascending:NO withPredicate:predicate];

    if (lastTopicId.length > 0)
    {
        predicate = [NSPredicate predicateWithFormat:@"(isArchived == %@ && topic_id == %@)", @(NO), lastTopicId];
        // last edit topic
        NSArray* matchIDArray = [TopicsEntity MR_findAllSortedBy:@"updated_time" ascending:NO withPredicate:predicate];
        [topics addObjectsFromArray: matchIDArray];
    }
    
    [topics addObjectsFromArray: allTopcis];
#else
    NSMutableArray* topics = [NSMutableArray array];
    NSString* userName = [DataManager sharedInstance].currentAccount.user.name;
    NSString* topicName  = [userName stringByAppendingString: @"'s Knotes from Chrome"];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isArchived == 0 && topic_id != nil && topic == %@)", topicName];
    
    // select able topics
    NSArray* allTopcis = [TopicsEntity MR_findAllSortedBy:@"updated_time" ascending:NO withPredicate:predicate];
    
    [topics addObjectsFromArray: allTopcis];
#endif
//    topics = [self orderedTopics:topics];

    static NSLock *checkLock = nil;
    if (checkLock == nil) {
        checkLock = [[NSLock alloc] init];
    }

    for (TopicsEntity *entity  in topics)
    {
        if (lastTopicId == nil) // not history for last jobs
        {
            if ([entity.topic_id hasPrefix: kKnoteIdPrefix])
                continue;
        }
        
        [checkLock lock];

        TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:entity];

        [checkLock unlock];
        
        tInfo.my_account_id = entity.account_id;
        
        if([self.topicArrayDictionary objectForKey:[NSString stringWithFormat:@"%@",tInfo.topic_id]])
        {
            int pos = 0;
            for(int j = 0; j < self.topicArray.count; j++)
            {
                pos = j;
                
                TopicInfo * auxtInfo = (TopicInfo *)[self.topicArray objectAtIndex:pos];
                
                if(auxtInfo){
                    if(auxtInfo.topic_id != nil && [tInfo.topic_id isEqualToString:auxtInfo.topic_id])
                        break;
                }
                
            }
            
            [self.topicArray replaceObjectAtIndex:pos withObject:tInfo];
        }
        else
        {
            [self.topicArrayDictionary setObject:tInfo forKey:tInfo.topic_id];
            
            [self.topicArray addObject:tInfo];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if(self.displayMode == DisplayModePads)
        {
            [self reloadData];
            [self enableSwitchView];
            [self showInitViewController];
        }
    });
}

//- (void) fetchedAllPeopleTopics:(BOOL)f_showArchivedPad
//{
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        if (![[self getTitleForTopLoadingBar] isEqual:@""])
//        {
//            [self.spinnerImageView startProgressWithTitle:[self getTitleForTopLoadingBar]];
//        }
//    });
//
//    [self.topicArray removeAllObjects];
//    [self.topicArrayDictionary removeAllObjects];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isArchived == %@)",
//                              @(f_showArchivedPad)];
//    
//    NSArray *topics = [TopicsEntity MR_findAllSortedBy:@"updated_time" ascending:NO withPredicate:predicate];
//    
//    topics = [topics filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TopicsEntity *topic, NSDictionary *bindings) {
//    
//        BOOL topic_id_not_nil = topic.topic_id != nil;
//        
//        BOOL not_profile_notes = topic.topic && ![topic.topic isEqualToString:@"Profile Notes"];
//        
//        return topic_id_not_nil && not_profile_notes;
//    }]];
//    
//    topics = [self orderedTopics:topics];
//    
//    for (int i = 0; i<[topics count]; i++)
//    {
//        TopicsEntity *entity = [topics objectAtIndex:i];
//        
//        NSLock *checkLock = [[NSLock alloc] init];
//        
//        [checkLock lock];
//        
//        TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:entity];
//        
//        [checkLock unlock];
//        
//        tInfo.my_account_id = entity.account_id;
//        
//        if([self.topicArrayDictionary objectForKey:[NSString stringWithFormat:@"%@",tInfo.topic_id]])
//        {
//            int pos = 0;
//            for(int j = 0; j < self.topicArray.count; j++)
//            {
//                pos = j;
//                
//                TopicInfo * auxtInfo = (TopicInfo *)[self.topicArray objectAtIndex:pos];
//                
//                if(auxtInfo){
//                    if(auxtInfo.topic_id != nil && [tInfo.topic_id isEqualToString:auxtInfo.topic_id])
//                        break;                    
//                }
//                
//            }
//            
//            [self.topicArray replaceObjectAtIndex:pos withObject:tInfo];
//        }
//        else
//        {
//            [self.topicArrayDictionary setObject:tInfo forKey:tInfo.topic_id];
//
//            [self.topicArray addObject:tInfo];
//
//            
//            // Lin - Added
//            
//            float progress = 0;
//            
//            if (f_showArchivedPad)
//            {
//            progress = self.topicArray.count / (float)[AppDelegate sharedDelegate].user_archived_topics;
//            
//            DLog(@"*** (%lu / %ld) %f %% Loaded", (unsigned long)self.topicArray.count , (long)[AppDelegate sharedDelegate].user_archived_topics, progress * 100);
//            
//        }
//        else
//        {
//            progress = self.topicArray.count / (float)[AppDelegate sharedDelegate].user_active_topics;
//            
//            DLog(@" @Malik *** (%lu / %ld) %f %% Loaded", (unsigned long)self.topicArray.count , (long)[AppDelegate sharedDelegate].user_active_topics, progress * 100);
//            
//        }
//      }
//    }
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        if(self.displayMode == DisplayModePads)
//        {
//            [self reloadData];
//            
//            [self enableSwitchView];
//            
//            [self showInitViewController];
//        }
//    });
//    
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        
//        if ([self canHideTopProgressLoading])
//        {
//          [self.spinnerImageView stopProgressBar];
//        }
//        
////        if(self.topicArray.count > 0){
////            [self.spinnerImageView stopAnimating];
////        }
//    });
//}

- (void)cellExpanded:(NSNotification *)note
{
    BaseKnoteCell *cell = note.object;
    
    if (cell.expandeMode == YES)
    {
        self.expIndexPath = [self.tableView indexPathForCell:cell];
    }
    else
    {
        self.expIndexPath = nil;
    }
    
    [self reloadData];
    
    // Need to check to count notification
}

-(void)addedNewContact:(NSNotification *)note
{
    NSLog(@".");
    self.justAddedContactFromNotification = YES;
    [self addedNewContactWithEmail:note.object];
}

- (void)clearEditingCell
{
    if(self.editingCell && self.editingIndexPath)
    {
        [self setEditing:NO atIndexPath:self.editingIndexPath cell:self.editingCell animate:NO];
    }
    
}

- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
}

- (void)setDisplayMode:(DisplayMode)displayMode
{
    [self setDisplayMode:displayMode animated:YES];
}

- (void)setDisplayMode:(DisplayMode)displayMode animated:(BOOL)animated
{
    DisplayMode oldDisplayMode = _displayMode;
    
    switch (displayMode)
    {
        case DisplayModePeople:
            
            // Close profile filter view if it's open
            if(self.peopleFilterBackgroundView.superview){
                self.tablewViewCurrentYPosition = [NSNumber numberWithInt:TABLEVIEW_INITIAL_Y_POSITION];
                [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.tablewViewCurrentYPosition);
                    make.left.equalTo(@0);
                    make.right.equalTo(@0);
                    make.bottom.equalTo(@0);
                }];
                [self configureQuickFilterButton];
                [self.peopleFilterBackgroundView removeFromSuperview];
            }
            
            [self clearEditingCell];
            
            [self setSearchBarVisibleDisplayMode:displayMode Visible:YES];
            
            if (!self.searchingPeople)
            {
                [_peopleSearchResults removeAllObjects];
            }
            
            if ([self.peopleData count] == 0)
            {
                [self showLoadingViewWhile];
            }
            
            [self hideLoadingView];
            
            break;
            
        case DisplayModePads:
            
            [self setSearchBarVisibleDisplayMode:displayMode Visible:YES];
            
            [_topicSearchResults removeAllObjects];
            
            if(self.autoKnote)
            {
                self.autoKnote = NO;
                
                [self performSelector:@selector(startAddTopic)
                           withObject:nil
                           afterDelay:0.25];
            }
            
#if kUseFetchedController
            
            [self hideLoadingView];
            
#endif
            
            break;
            
        case DisplayModeSettings:
            break;
    }
    
    _displayMode = displayMode;
    
#if kPeopleProcess
    
    [self contactsUpdateProgress:[DataManager sharedInstance].contactsCount];
    
#endif
    
#if kCombinedNewFeature
    
    [self scrollUp];
    
#endif
    
    if (displayMode == DisplayModePeople && self.searchingPeople)
    {
        //[self.searchBar resignFirstResponder];
        
        [self.searchBar becomeFirstResponder];
        self.searchBar.text = self.searchString;
        self.searchingPeople = NO;
    }
    
    self.oldDisplayMode = oldDisplayMode;
    
    if(!animated)
    {
        self.transitioningData = YES;

        if (_displayMode == DisplayModePads)
        {
            [self fetchedTopics:nil];
        }
        else
        {
            [self reloadData];
        }
        
        if (_displayMode != DisplayModePads)
        {
            //Switch to Spaces
            
            if (!self.currentContact)
            {
                [self setCurrentContact:self.currentAccount.user.contact];
            }
#if !New_DrawerDesign
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [button setBackgroundImage:[UIImage imageNamed:@"add_people_normal"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"add_people_selected"] forState:UIControlStateSelected];
            [button setBackgroundImage:[UIImage imageNamed:@"add_people_selected"] forState:UIControlStateHighlighted];
            
            button.frame = CGRectMake(0, 0, 22.0f, 22.0f);
            
            [button addTarget:self action:@selector(addPressed) forControlEvents:UIControlEventTouchUpInside];

            self.addButton = [[UIBarButtonItem alloc] initWithCustomView:button];
            
            self.navigationItem.rightBarButtonItem = self.addButton;
#endif
            self.displayMode = DisplayModePads;
            
        }
        else
        {
            [self scrollUp];
        }
    }
    else
    {
        if (self.isCurrentShow)
        {
            [_tableView reloadData];
        }
    }
}

- (void)scrollUp
{
    if (self.displayMode == DisplayModePeople
        || self.displayMode == DisplayModePads)
    {
        //[self.tableView setContentOffset:CGPointMake(0, _searchBgView.frame.size.height) animated:NO];
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];

    }
}

-(void)UpdatenewOrderrank{
    
    NSLog(@"updateKnoteOrders");

    NSMutableArray *changedKnotes = [[NSMutableArray alloc] initWithCapacity:self.topicArray.count];
    int currentOrder = 1;
    

        for(int i = (int)(self.topicArray.count-1);i>=0;i--)
        {
            TopicInfo *info =[self.topicArray objectAtIndex:i];
        if ([info.entity.order integerValue] != currentOrder) {
            {
                info.entity.order= [NSNumber numberWithInt:currentOrder];
                info.entity.order_to_set =[NSNumber numberWithInt:currentOrder];
                info.entity.order_user_id =self.userContact.user.user_id;
                info.entity.position=currentOrder;
                [changedKnotes addObject:info.entity];
            }
            currentOrder++;
        }
    }
    NSLog(@"Updating orders on %d knotes", (int)changedKnotes.count);
    
    [[AppDelegate sharedDelegate] sendUpdatedTopicOrders:[changedKnotes copy]];
    
    [AppDelegate saveContext];
    
    [self reloadData];
    
    // Need to check to count notification
}

-(void)updateButtonStatus:(NSInteger)displayMode
{
    if (displayMode == DisplayModePads)
    {
        if (!self.showArchived)
        {
            [self.recordBtn setImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor grayColor]]
                            forState:UIControlStateNormal];
        }
        else
        {
            [self.recordBtn setImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor blueColor]]
                            forState:UIControlStateNormal];
        }
    }
    else
    {
        if (!self.sortAlphabetically)
        {
            [self.recordBtn setImage:[UIImage imageNamed:@"alphabetical_sorting-48-gray"]
                            forState:UIControlStateNormal];
        }
        else
        {
            [self.recordBtn setImage:[[UIImage imageNamed:@"alphabetical_sorting-48-gray"] imageTintedWithColor:[UIColor blueColor]] forState:UIControlStateNormal];
        }
    }
    
    [self.recordBtn setHitTestEdgeInsets:UIEdgeInsetsMake(-20, -20, -20, -20)];
}

- (void)updateContactData
{
    [self updateButtonStatus:_displayMode];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"archived == %@ && isMe == NO", @(NO)];
    
    NSString *sortFields = _sortAlphabetically ? @"name:YES" : @"position:NO,total_topics:YES";
    _fetchedResultsController.delegate = nil;
    _fetchedResultsController = [ContactsEntity MR_fetchAllSortedBy:sortFields ascending:YES withPredicate:predicate groupBy:nil delegate:self];

    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
//    [self logCounts];

    if (_displayMode == DisplayModePeople)
    {
        [self reloadData];
    }
}

- (void)updateTopicsData
{
    [self updateButtonStatus:_displayMode];
    
    NSString *sortFields =  @"isPlaceHold:NO,updated_time:NO,order:NO";
    
    NSPredicate *predicate = nil;
    
    if (self.currentContact)
    {
        predicate = [NSPredicate predicateWithFormat:@"(ANY contacts == %@) && (isArchived == %@) || isPlaceHold = %d",
                     self.currentContact, @(_showArchived),kInvalidatePosition];
    }
    else
    {
        sortFields =  @"updated_time:NO,order:NO";
        predicate = [NSPredicate predicateWithFormat:@"(isArchived == %@ AND isPlaceHold != %d)",
                     @(_showArchived),kInvalidatePosition];
    }
    
    _fetchedResultsController.delegate = nil;
    _fetchedResultsController = [TopicsEntity MR_fetchAllSortedBy:sortFields ascending:YES withPredicate:predicate groupBy:nil delegate:self];
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    [self logCounts];
    
    /*if (_displayMode == DisplayModePads)
    {
        [self reloadData];
    }*/
}

- (void) updateData
{
    
    // Lin - Added to check people load issue between pad and people UI
    
    [self updateButtonStatus:self.displayMode];
    
    self.peopleData = [self fetchAllContactsExcludingSelfForSortFlag:self.sortAlphabetically archiveFlag:NO];
    
    // Lin - Ended
    
    if (self.displayMode == DisplayModePads)
    {
        [self.topicArray removeAllObjects];
        [self.topicArrayDictionary removeAllObjects];
        
//        NSArray *topics = [self fetchTopicsForContact:self.currentContact];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isArchived == %@)",
                                  @(self.showArchived)];
        
        NSArray *topics =  [TopicsEntity MR_findAllSortedBy:@"updated_time"
                                                  ascending:NO
                                              withPredicate:predicate];
        
        topics = [topics filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TopicsEntity *topic, NSDictionary *bindings) {
            
            BOOL topic_id_not_nil = topic.topic_id != nil;
            
            BOOL not_profile_notes = topic.topic && ![topic.topic isEqualToString:@"Profile Notes"];
            
            return topic_id_not_nil && not_profile_notes;
        }]];
        
        topics = [self orderedTopics:topics];
        
        NSString *my_account_id = self.currentAccount.account_id;
        self.view.userInteractionEnabled=NO;
        for (int i = 0; i<[topics count]; i++)
        {
            TopicsEntity *entity = [topics objectAtIndex:i];
            
            TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:entity];
            
            tInfo.entity = entity;
            
            if (my_account_id)
            {
                tInfo.my_account_id = my_account_id;
            }
            else
            {
                tInfo.my_account_id = entity.account_id;
            }
            
            if([self.topicArrayDictionary objectForKey:tInfo.topic_id])
            {
                int pos = 0;

                for(int i = 0; i < self.topicArray.count; i++)
                {
                    pos = i;
                    TopicInfo * auxtInfo = [self.topicArray objectAtIndex:pos];
                    if([tInfo.topic_id isEqualToString:auxtInfo.topic_id])
                        break;
                }
                
                [self.topicArray replaceObjectAtIndex:pos withObject:tInfo];
            }
            else
            {
                [self.topicArrayDictionary setObject:tInfo forKey:tInfo.topic_id];

                [self.topicArray addObject:tInfo];
                
                if(self.displayMode == DisplayModePeople)
                {
                    /*
                    if(self.knoteProgressBar.superview)
                    {
                        float progress = self.topicArray.count / ((float)[TopicsEntity MR_countOfEntities]);
                        
                        [self.knoteProgressBar setProgress:progress animated:YES];
                    }
                     */
                    
                }
                else if (self.displayMode == DisplayModePads)
                {

                    float progress = self.topicArray.count / (float)[topics count];
                    
                    DLog(@"*** (%lu / %ld) %f %% Loaded", (unsigned long)self.topicArray.count , (long)[topics count], progress * 100);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        /*
                        int progressAsInteger = progress * 100;
                        self.padProgressBar.indicatorTextLabel.text = [NSString stringWithFormat:@"%i%%", progressAsInteger];
                        [self.padProgressBar setProgress:progress];
                        [self.padProgressBar setProgress:progress animated:YES];
                         */
                        
                    });
                }
                
            }
        }
        self.view.userInteractionEnabled=YES;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(self.displayMode == DisplayModePads)
            {
                [self reloadData];
                
                [self enableSwitchView];
            }
            
        });
    }

    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.displayMode != DisplayModePads)
        {
            NSLog(@"updateData");
            
            [self reloadData];
        }
    });
    
    
}

-(void)tapInView{
    [self.bubbleDialog removeFromSuperview];
    [self.opaqueBlackBackgroundView removeFromSuperview];
    self.opaqueBlackBackgroundView = nil;
    self.bubbleDialog = nil;
}

-(void)tapOnce:(UIGestureRecognizer *)gestureRecognizer
{
    self.navigationLeftMenu.m_btnReorder.selected = !self.navigationLeftMenu.m_btnReorder.selected;
    [self floatingTraysetOneReorder:self.navigationLeftMenu.m_btnReorder.selected];
}

-(void)tapTwice:(UIGestureRecognizer *)gestureRecognizer
{
    self.navigationLeftMenu.m_btnReorder.selected = !self.navigationLeftMenu.m_btnReorder.selected;
    [self floatingTraysetReorder:self.navigationLeftMenu.m_btnReorder.selected];
}

-(void)floatingTraysetOneReorder:(BOOL)reorder
{
    self.tableView.isReordering=reorder;
    self.tableView.isReorderingAll = NO;
    
    self.tableView.editing=reorder;
    
    [self reloadData];
    
    // Need to check to count notification
    
    if(!reorder)
    {
        self.reorderFlag = reorder;
        
        [self UpdatenewOrderrank];
    }
}

-(void)floatingTraysetReorder:(BOOL)reorder
{
    self.tableView.isReordering=reorder;
    self.tableView.isReorderingAll =reorder;
    
    self.tableView.editing=reorder;
    
    [self reloadData];
    // Need to check to count notification
    
    if(!reorder)
    {
        [self UpdatenewOrderrank];
    }
}

- (void)floatingTraySetAlphabetical:(BOOL)alphabetical
{
    if(alphabetical != self.sortAlphabetically)
    {

        _sortAlphabetically = alphabetical;
#if  1// kUseFetchedController
        [self updateContactData];
#else
        [self updateData];
#endif
    }
    
    if (self.navigationSortMenu)
    {
        if (self.sortAlphabetically)
        {
            [self.navigationSortMenu.m_btnSort setTitleColor:[DesignManager KnoteSelectedColor] forState:UIControlStateNormal];
        }
        else
        {
            [self.navigationSortMenu.m_btnSort setTitleColor:[DesignManager KnoteNormalColor] forState:UIControlStateNormal];
        }
    }
}

- (void) showArchivedPads:(BOOL)archived
{
    if(archived != self.showArchived)
    {
        self.footerInfoView.showArchived = archived;
        
        if (_displayMode == DisplayModePads)
        {
            if (archived)
            {
                self.title = ARCHIVE_TITLE;
                
                [self.recordBtn setImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor blueColor]]
                                forState:UIControlStateNormal];
            }
            else
            {
                self.title = PADS_TITLE;
                
                [self.recordBtn setImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor grayColor]]
                                forState:UIControlStateNormal];
            }
        }
        _showArchived = archived;
        
#if   kUseFetchedController
        
        [self updateTopicsData];
        
#else
        
        if (_displayMode == DisplayModePads)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                     (unsigned long)NULL), ^(void){
                [self updateData];
            });
        }
        else
        {
            [self updateData];
        }
#endif
        
    }
}

#pragma mark - Fetching Contacts

- (NSMutableArray *)fetchAllContactsExcludingSelfForSortFlag:(BOOL)sortFlag archiveFlag:(BOOL)archiveFlag
{
#if kContactUserFetchedController
    return nil;
#else
    
#endif
    
    // App crashed when "[DataManager sharedInstance].currentAccount.user.email" wasn't set at this point: adding fallback
    
    NSMutableArray *contactsArray = [NSMutableArray new];
    
    if([DataManager sharedInstance].currentAccount.user.email){
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"archived == %@ && NOT(mainEmail like %@)", @(archiveFlag),[DataManager sharedInstance].currentAccount.user.email];
#if 0//fixed bug for people position
        NSString *sortFields = sortFlag ? @"name:YES" : @"position:YES,total_topics:NO";
#else
        NSString *sortFields = sortFlag ? @"name:YES" : @"position:NO,total_topics:YES";
        //NSString *sortFields = sortFlag ? @"name:YES" : @"order:YES";
#endif
        [glbAppdel.managedObjectContext lock];
        NSManagedObjectContext *backgroundMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [backgroundMOC setPersistentStoreCoordinator:[glbAppdel.managedObjectContext persistentStoreCoordinator]];
        
        NSMutableArray *contacts = [[ContactsEntity MR_findAllSortedBy:sortFields ascending:YES withPredicate:predicate inContext:backgroundMOC] mutableCopy];
        
        //sort newly added to top
        
        ContactsEntity *contactJustAdded;
        
        
        NSMutableArray * newlyAddedMails = _newlyAddedEmails;
        for(NSString *addedEmail in newlyAddedMails)
        {
            NSString *addedEmailLower = [addedEmail lowercaseString];
            
            ContactsEntity *matchingContact = nil;
            
            for(ContactsEntity *c in contacts)
            {
                NSString *lowerContactEmail = [c.email lowercaseString];
                
                if([lowerContactEmail rangeOfString:addedEmailLower].length > 0)
                {
                    matchingContact = c;
                    
                    break;
                }
            }
            
            if(matchingContact && ![matchingContact isFault])
            {
                [contacts removeObject:matchingContact];
                
                [contacts insertObject:matchingContact atIndex:0];
                
                if(self.justAddedContact
                   && [_newlyAddedEmails indexOfObject:addedEmail] == _newlyAddedEmails.count - 1)
                {
                    contactJustAdded = matchingContact;
                    self.justAddedContact = NO;
                }
            }
        }
        
        if(contactJustAdded)
        {
            if (self.dontAutoKnoteNewContact
                || self.justAddedContactFromNotification)
            {
                self.dontAutoKnoteNewContact = NO;
                self.justAddedContactFromNotification = NO;
            }
            else
            {
                [self performSelector:@selector(openContact:)
                           withObject:contactJustAdded
                           afterDelay:0.5];
            }
        }
        
        for (ContactsEntity *c in contacts)
        {
            ContactsEntity *entity = (ContactsEntity *)[glbAppdel.managedObjectContext existingObjectWithID:[c objectID]
                                                                                                      error:nil];
            
            [contactsArray addObject:entity];
        }
        
        [glbAppdel.managedObjectContext unlock];
    }
    
    return contactsArray;
}

//- (void)setCurrentContact:(ContactsEntity *)currentContact
//{
//    //    NSLog(@"setCurrentContact to %@", currentContact);
//    _currentContact = currentContact;
//
//    if(_currentContact)
//    {
//        [self.topicArray removeAllObjects];
//        [self.topicArrayDictionary removeAllObjects];
//        
//        NSArray *topics = [self fetchTopicsForContact:_currentContact];
//
//#if kUseFetchedController
//        return;
//#endif
//        NSString *my_account_id = _currentAccount.account_id;
//        
//        for (int i = 0; i<[topics count]; i++)
//        {
//            TopicsEntity *entity = [topics objectAtIndex:i];
//            
//            TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:entity];
//            
//            if (my_account_id)
//            {
//                tInfo.my_account_id = my_account_id;
//            }
//            else
//            {
//                tInfo.my_account_id = entity.account_id;
//            }
//            
//            if([self.topicArrayDictionary objectForKey:tInfo.topic_id])
//            {
//                int pos = 0;
//                for(int i = 0; i < self.topicArray.count; i++)
//                {
//                    pos = i;
//                    TopicInfo * auxtInfo = [self.topicArray objectAtIndex:pos];
//                    if([tInfo.topic_id isEqualToString:auxtInfo.topic_id])
//                        break;
//                }
//                
//                [self.topicArray replaceObjectAtIndex:pos withObject:tInfo];
//            }
//            else
//            {
//                [self.topicArrayDictionary setObject:tInfo forKey:tInfo.topic_id];
//                [self.topicArray addObject:tInfo];
//                
//                if(self.displayMode == DisplayModePeople)
//                {
//                    /*
//                    if(self.knoteProgressBar.superview){
//                        float progress = self.topicArray.count / ((float)[TopicsEntity MR_countOfEntities]);
//                        [self.knoteProgressBar setProgress:progress animated:YES];
//                    }
//                     */
//                    
//                }
//            }
//        }
//    }
//    else
//    {
//        DLog(@"Updated array");
//        
//        self.topicArray = [[NSMutableArray alloc] init];
//    }
//}

#pragma mark - Fetching Topics

- (NSArray *)fetchTopicsForContact:(ContactsEntity *)contact
{
#if 0
    NSString *sortFields =  @"isPlaceHold:NO,updated_time:NO,order:NO";
    NSPredicate *predicate = nil;
    
    if (contact)
    {
        predicate = [NSPredicate predicateWithFormat:@"(ANY contacts == %@) && (isArchived == %@) || isPlaceHold = %d",
                     contact, @(_showArchived),kInvalidatePosition];
    }
    else
    {
        predicate = [NSPredicate predicateWithFormat:@"(isArchived == %@ || isPlaceHold = %d)", @(_showArchived),kInvalidatePosition];
    }

    _fetchedResultsController.delegate = nil;
    _fetchedResultsController = [TopicsEntity MR_fetchAllSortedBy:sortFields ascending:YES withPredicate:predicate groupBy:nil delegate:self];

	return nil;
#else
    //    NSLog(@"fetchTopicsForContact: %@", contact);
    NSPredicate *predicate = nil;
    
    if (contact)
    {
        NSString *regex = [NSString stringWithFormat:@"(.*,)?%@(,.*)?", contact.account_id];
        
        predicate = [NSPredicate predicateWithFormat:@"(shared_account_ids MATCHES %@) && (isArchived == %@)",
                     
                     regex, @(self.showArchived)];
    }
    else
    {
        predicate = [NSPredicate predicateWithFormat:@"(isArchived == %@)", @(self.showArchived)];
    }
    
    [glbAppdel.managedObjectContext lock];
    
    NSManagedObjectContext *backgroundMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [backgroundMOC setPersistentStoreCoordinator:[glbAppdel.managedObjectContext persistentStoreCoordinator]];
    
    NSArray *topics =  [TopicsEntity MR_findAllSortedBy:@"updated_time" ascending:NO withPredicate:predicate inContext:backgroundMOC];
    //NSArray *topics =  [TopicsEntity MR_findAllWithPredicate:predicate inContext:backgroundMOC];
    topics = [topics filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(TopicsEntity *topic, NSDictionary *bindings) {
        
        BOOL topic_id_not_nil = topic.topic_id != nil;
        
        BOOL not_profile_notes = topic.topic && ![topic.topic isEqualToString:@"Profile Notes"];
        
        return topic_id_not_nil && not_profile_notes;
        
    }]];
    
    NSArray *temp_sorted = [self orderedTopics:topics];
    
    NSMutableArray *sorted = [NSMutableArray new];

    for (ContactsEntity *c in temp_sorted) {
        TopicsEntity *entity = (TopicsEntity *)[glbAppdel.managedObjectContext existingObjectWithID:[c objectID] error:nil];
        [sorted addObject:entity];
    }
    [glbAppdel.managedObjectContext unlock];
    
    return [sorted copy];
    
#endif
}

- (NSArray *)orderedTopics:(NSArray *)topics
{
    NSSortDescriptor *positionDescriptor = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:NO];
    NSSortDescriptor *updatedDescriptor = [[NSSortDescriptor alloc] initWithKey:@"updated_time" ascending:NO];
    
    NSArray *sorted = [topics sortedArrayUsingDescriptors:@[positionDescriptor, updatedDescriptor]];
    
    return sorted;
}

- (void)openContact:(ContactsEntity *)contact
{
    NSIndexPath *idx = [NSIndexPath indexPathForRow:[self.peopleData indexOfObject:contact] inSection:0];
    
    [self.tableView selectRowAtIndexPath:idx animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    [self openContactRowInTableView:self.tableView atIndexPath:idx autoStartKnote:YES];
    
}

- (BOOL)deleteContact:(NSString*)contact_id
{
    ContactsEntity *contact = nil;
    
    if (contact_id && contact_id.length > 0)
    {
        contact = [ContactsEntity MR_findFirstByAttribute:@"contact_id" withValue:contact_id];
    }
    
    if (contact)
    {
        return [contact MR_deleteEntity];
    }
    
    return YES;
}

#pragma mark Add Topic
#if New_DrawerDesign
-(void)showDrawer
{

    NSInteger index=1;
    if (_displayMode==DisplayModePads)
    {
        index=1;
    }
    else if (_displayMode==DisplayModePeople)
    {
        index=0;
    }
    else if (_displayMode==DisplayModeSettings)
    {
        index=2;
    }
  SideMenuViewController  *contentView = [[SideMenuViewController alloc] init];
    contentView.Cur_account=[DataManager sharedInstance].currentAccount;
    contentView.targetDelegate=self;
    contentView.selectedRow=index;
    [_sideBar ShowSideBarWithAnimationWithController:contentView animated:YES];
}
#endif
- (void) addPressed
{
    if(self.displayMode == DisplayModePeople)
    {
        [self startAddPerson];
    }
    else
    {
        [self showInitialComposeViewController];
        //[self startAddTopic:NO];
    }
}

-(void)startAddPerson
{
    [[Lookback_Weak lookback] enteredView:@"Add Person View"];
    
    OMPromise *addPersonPromise = [[ContactManager sharedInstance] startAddPerson:self];
    
    [addPersonPromise progressed:^(float progress) {
        
        //Called when the user submits the info
        if (progress == 0.5) {
            NSLog(@"startAddPerson PROGRESS %f", progress);
            self.startAddedContactDate = [NSDate date];
        }
    }];
    [addPersonPromise fulfilled:^(id result) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@%@", result, @" added."] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
        NSLog(@"startAddPerson FULFILLED email: %@", result);
        self.justAddedContactFromNotification = NO;
        [self addedNewContactWithEmail:result];
    }];
}

-(void)addedNewContactWithEmail:(NSString *)email
{
    NSTimeInterval interval = 0.0;
    if (self.startAddedContactDate) {
        interval = -[self.startAddedContactDate timeIntervalSinceNow];
    }
    NSLog(@"interval: %f", interval);
    
    if (interval <= 5.0) {
        self.justAddedContactFromNotification = NO;
    } else {
        self.justAddedContactFromNotification = YES;
    }
    
    self.justAddedContact = YES;
    [_newlyAddedEmails addObject:email];
    [[DataManager sharedInstance] fetchRemoteContacts];
}

- (void)startAddTopic:(BOOL)isAutoCreated {
    [[Lookback_Weak lookback] enteredView:@"Add Topic View"];
    
    ThreadViewController* threadViewController = [[ThreadViewController alloc] initWithTopic:nil];
    threadViewController.delegate              = self;
    threadViewController.isNewTopicAdded       = YES;
    threadViewController.isAutoCreated         = YES;
    threadViewController.shouldPopToMainView   = self.shouldPopToMainView;
    
//    #if New_DrawerDesign
//    self.stack.hidden=YES;
//    #endif
    
    [self.navigationController pushViewController:threadViewController animated:NO];
    self.shouldPopToMainView = NO;
    
//    if (isAutoCreated) {

//    } else {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isArchived == %@)", @(NO)];
//        TopicsEntity *topicEntity = [TopicsEntity MR_findFirstWithPredicate:predicate];
//        TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:topicEntity];
//        tInfo.entity = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:tInfo.topic_id];
//        tInfo.entity.contact_id = [DataManager sharedInstance].currentAccount.user.contact.contact_id;
//        tInfo.item.userData = [MessageEntity MR_findFirstByAttribute:@"message_id" withValue:tInfo.message_id];
//        tInfo.entity.hasNewActivity = @(YES);
//        
//        if ([DataManager sharedInstance].currentAccount.user.contact)
//        {
//            NSMutableSet *topicContacts = [[NSMutableSet alloc] init];
//            
//            [topicContacts addObject:[DataManager sharedInstance].currentAccount.user.contact];
//            
//            tInfo.entity.contacts = [topicContacts copy];
//        }
//        [self needChangeTopicTitle:tInfo];
//        
//        
//        ThreadViewController* threadController = [[ThreadViewController alloc] initWithTopic:tInfo];
//        threadController.delegate = self;
//        
//        // if(isAutoCreated) -> won't be saved until it has a knote: if left empty, it won't be saved.
//        threadController.isAutoCreated = NO;//isAutoCreated;
//        threadController.shouldPopToMainView = self.shouldPopToMainView;
//        
//#if New_DrawerDesign
//        self.stack.hidden=YES;
//#endif
//        threadController.isNewTopicAdded=@"yes";
//        [self.navigationController pushViewController:threadController animated:NO];
//    }
    
//    } else {
//        [[TopicManager sharedInstance] generateNewTopic:padTitle
//                                                account:[DataManager sharedInstance].currentAccount
//                                         sharedContacts:@[] andBeingAutocreated:NO withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
//         {
//             TopicInfo *tInfo= userData;
//             //self.tInfo = userData;
//             tInfo.entity = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:tInfo.topic_id];
//             tInfo.entity.contact_id = [DataManager sharedInstance].currentAccount.user.contact.contact_id;
//             tInfo.item.userData = [MessageEntity MR_findFirstByAttribute:@"message_id" withValue:tInfo.message_id];
//             tInfo.entity.hasNewActivity = @(YES);
//             
//             if ([DataManager sharedInstance].currentAccount.user.contact)
//             {
//                 NSMutableSet *topicContacts = [[NSMutableSet alloc] init];
//                 
//                 [topicContacts addObject:[DataManager sharedInstance].currentAccount.user.contact];
//                 
//                 tInfo.entity.contacts = [topicContacts copy];
//             }
//             [self needChangeTopicTitle:tInfo];
//             
//             
//             ThreadViewController* threadController = [[ThreadViewController alloc] initWithTopic:tInfo];
//             threadController.delegate = self;
//             
//             // if(isAutoCreated) -> won't be saved until it has a knote: if left empty, it won't be saved.
//             threadController.isAutoCreated = NO;//isAutoCreated;
//             threadController.shouldPopToMainView = self.shouldPopToMainView;
//             
//#if New_DrawerDesign
//             self.stack.hidden=YES;
//#endif
//             threadController.isNewTopicAdded=@"yes";
//             [self.navigationController pushViewController:threadController animated:NO];
//             
//         }];
//    }
}

#pragma mark -
#pragma mark EditorViewControllerDelegate

- (void)insertItem:(CItem *)item withInfo:(id)info withOpType:(ItemOpType)type
{
    //not used
}

- (void)insertItem:(CItem *)item withInfo:(id)info withOpType:(ItemOpType)type files:(NSArray *)files contacts:(NSArray *)contacts
{
    NSLog(@"item: %@ info: %@", item, info);
    
    NSDictionary *dict = info;
    NSString *topicTitle = dict[@"message_subject"];
    
    [[TopicManager sharedInstance] generateNewTopic:topicTitle content:dict files:files account:self.currentAccount sharedContacts:contacts andBeingAutocreated:NO withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
    {
        TopicInfo *tInfo = userData;
        
        if (tInfo)
        {
            tInfo.entity = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:tInfo.topic_id];
            tInfo.item.userData = [MessageEntity MR_findFirstByAttribute:@"message_id" withValue:tInfo.message_id];
            
            NSMutableSet *topicContacts = [[NSMutableSet alloc] init];
            
            if (self.currentAccount.user.contact)
            {
                tInfo.entity.contact_id = self.currentAccount.user.contact.contact_id;
                [topicContacts addObject:self.currentAccount.user.contact];
            }
            
            if (self.currentContact)
            {
                [topicContacts addObject:self.currentContact];
            }
            
            if (contacts)
            {
                [topicContacts addObjectsFromArray:contacts];
            }
            
            tInfo.entity.contacts = [topicContacts copy];
            
            if (self.displayMode == DisplayModePads)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    //Table View Crash Issue
                    
                    if (self.isUpdatedTopic)
                    {
                        [CATransaction begin];
                        [CATransaction setCompletionBlock:^{
                            self.isUpdatedTopic=YES;
                        }];
                        
                        NSIndexPath *firstIndex = [NSIndexPath indexPathForRow:0 inSection:0];
                        
                        [self.tableView beginUpdates];
                        
                        if (self.topicArray.count == 0)
                        {
                            //Delete "create a pad" row
                            [self.tableView deleteRowsAtIndexPaths:@[firstIndex] withRowAnimation:UITableViewRowAnimationNone];
                        }
                        
                        [self.topicArray insertObject:tInfo atIndex:0];
                        
                        [self.tableView insertRowsAtIndexPaths:@[firstIndex] withRowAnimation:UITableViewRowAnimationNone];
                        
                        [self.tableView endUpdates];
                        
                        //[self.tableView reloadRowsAtIndexPaths:self.tableView.indexPathsForVisibleRows withRowAnimation:UITableViewRowAnimationFade];
                        
                        [self openTopicRowInTableView:self.tableView atIndexPath:firstIndex animated:NO];
                        
                        [CATransaction commit];
                    }
                });
            }
            else
            {
                dispatch_async(dispatch_get_main_queue(), ^{

                    [self.topicArray insertObject:tInfo atIndex:0];
                });
            }
        }
    }];
}

- (void)gotItem:(CItem *)item withInfo:(id)info withOpType:(ItemOpType)type
{
    //not used
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSMutableArray*) specificUserPadsDataSource
{
    NSMutableArray * toRet = [NSMutableArray array];
    if(self.currentContact){
        NSArray * auxArr = [self fetchTopicsForContact:self.currentContact];
        for(int i = 0; i < auxArr.count; i++){
            TopicsEntity *entity = [auxArr objectAtIndex:i];
            TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:entity];
            tInfo.my_account_id = entity.account_id;
            [toRet addObject:tInfo];
        }
    }
    return toRet;
}

- (NSMutableArray *)dataSpacesForTable:(UITableView *)tableView
{
    DisplayMode mode = self.displayMode;
    
    if(self.transitioningData)
    {
        mode = self.oldDisplayMode;
    }
    
    if (tableView == self.tableView)
    {
        return self.topicArray;
    }
    else if (tableView == self.searchController.searchResultsTableView)
    {
        return _topicSearchResults;
    }
    return [[NSMutableArray alloc] init];
}

- (NSMutableArray *)dataForTable:(UITableView *)tableView
{
    DisplayMode mode = self.displayMode;
    
    if(self.transitioningData)
    {
        mode = self.oldDisplayMode;
    }
    
    if (tableView == self.tableView)
    {
        switch (mode){
            case DisplayModePeople:
                return self.peopleData;
            case DisplayModePads:
            {
                if(self.filteredArray){
                    return self.filteredArray;
                }else{
                    
                    NSMutableArray * toRet = [NSMutableArray array];
                    if(self.currentContact){
                        NSArray * auxArr = [self fetchTopicsForContact:self.currentContact];
                        for(int i = 0; i < auxArr.count; i++){
                            TopicsEntity *entity = [auxArr objectAtIndex:i];
                            TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:entity];
                            tInfo.my_account_id = entity.account_id;
                            [toRet addObject:tInfo];
                        }
                        return toRet;
                    }else{
                        
                        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
                        NSString * topicID = [userDefaults objectForKey:@"auto_padID_to_remove"];
                        if(([topicID isKindOfClass:[NSString class]]) && (topicID.length > 0)){
                            int pos = -1;
                            for (int i = 0; i<self.topicArray.count; i++) {
                                
                                TopicInfo* tInfo = (TopicInfo*) self.topicArray[i];
                                
                                if([tInfo.topic_id isEqualToString:topicID]){
                                    pos = i;
                                    break;
                                }
                            }
                            
                            if(pos >= 0){
                                [self.topicArray removeObjectAtIndex:pos];
                                [self.topicArrayDictionary removeObjectForKey:topicID];
                                [[DataManager sharedInstance] deleteTopicWithTopicID:topicID];
                                [[DataManager sharedInstance] saveIfNeeded];
                            }
                            
                            [userDefaults removeObjectForKey:@"auto_padID_to_remove"];
                            [userDefaults synchronize];
                            
                        }
                        
                        return self.topicArray;
                    }
                    
                }
                
                
            }

                default:
                break;
        }
    }
    else if (tableView == self.searchController.searchResultsTableView)
    {
        switch (mode){
            case DisplayModePeople:
                return _peopleSearchResults;
            case DisplayModePads:
                return _topicSearchResults;
            default:
                break;
                
        }
    }
    return [[NSMutableArray alloc] init];
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = UITableViewAutomaticDimension;

    if(self.displayMode == DisplayModePads)
    {
        height = 60.0f;
    }
    else
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            return 60.0;
        }
        else
        {
            return 100;
        }
    }
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.displayMode == DisplayModePads)
    {
        if (self.topicArray.count==0)
        {
            return tableView.frame.size.height-_searchBgView.frame.size.height;
        }
        return [self tableView:tableView topicHeightForRowAtIndexPath:indexPath];
    }
    else
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            return 60.0;
        }
        else
        {
            return 100;
        }
    }
}

- (CGFloat) tableView:(UITableView *)tableView topicHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if kUseFetchedController
    if (_searchMode)
    {
        return 60;
    }
    else
    {
        TopicsEntity *entity = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        if (entity)
        {
            CGRect labelRect = [CUtil getTextRect:(entity ? entity.topic : @"") Font:[UIFont systemFontOfSize:17.0] Width:MAXLABELWIDTH];
            
            float h = BASESIZE + ONELINEHEIGHT * ((labelRect.size.height / ONELINEHEIGHT) - 1);
            
            return h;
        }
        else
        {
            return 60;
        }
    }
#endif
    if (_showOwner)
    {
        if (indexPath.row == 0)
        {
            return 60.0f;
        }
        else
        {
            if ((indexPath.row-1)< [[self dataForTable:tableView] count])
            {
                float h = 60;
                
                TopicInfo* p = (TopicInfo*) [self dataForTable:tableView][indexPath.row - 1];
                
                if ([p isKindOfClass:[TopicInfo class]])
                {
                    CGRect labelRect = [CUtil getTextRect:(p.entity ? p.entity.topic : @"")
                                                     Font:[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0]
                                                    Width:MAXLABELWIDTH];
                    
                    h = BASESIZE + ONELINEHEIGHT * ((labelRect.size.height / ONELINEHEIGHT) - 1);
                }

                return h;
                
            }
            else
            {
                return 60;
            }
        }
    }
    else
    {
        if (indexPath.row< [[self dataForTable:tableView] count])
        {
            return 60;
        }
        else
        {
            return 0;
        }
        
    }
}

- (BaseKnoteCell *)cellForMessage:(MessageEntity *)message
{
    BaseKnoteCell * cellClass;
    
    switch (message.type) {
        case C_DATE:
            cellClass = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([DeadlineCell class])];
            if (!cellClass)
            {
                cellClass = [[DeadlineCell alloc] init];
            }
            break;
        case C_LOCK:
            cellClass = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LockCell class])];
            if (!cellClass)
            {
                cellClass = [[LockCell alloc] init];
            }
            break;
        case C_KEYKNOTE:
            cellClass = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([KeyKnoteCell class])];
            if (!cellClass)
            {
                cellClass = [[KeyKnoteCell  alloc] init];
            }
            break;
        case C_VOTE:
        case C_LIST:
            cellClass = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([VoteCell class])];
            if (!cellClass)
            {
                cellClass = [[VoteCell  alloc] init];
            }
            break;
        default:
            if([message hasPhotoAvailable]
               || [message.loadedEmbeddedImages count]>0)
            {
                cellClass = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([PictureCell class])];
                
                if (!cellClass)
                {
                    cellClass = [[PictureCell  alloc] init];
                }
            } else {
                cellClass = [self.tableView dequeueReusableCellWithIdentifier:NSStringFromClass([KnoteCell class])];
                if (!cellClass)
                {
                    cellClass = [[KnoteCell  alloc] init];
                }
            }
            break;
    }
    
    return cellClass;
}

- (BOOL)needUpdateTableView:(NSFetchedResultsController *)controller
{
    if (_searchMode)
	{
        return NO;
    }
#if kContactUserFetchedController
    if ([controller isEqual:_fetchedResultsController]
        && ([controller.fetchRequest.entityName isEqualToString:NSStringFromClass([ContactsEntity class])]
            && _displayMode == DisplayModePeople))
    {
        return YES;
    }
#endif
    
    return NO;
}

#pragma mark -
#pragma mark - Table view delegate
- (void)setEditing:(BOOL)editing atIndexPath:indexPath cell:(UITableViewCell *)cell
{
    [self setEditing:editing atIndexPath:indexPath cell:cell animate:YES];
}

- (void)setEditing:(BOOL)editing atIndexPath:(NSIndexPath *)indexPath cell:(UITableViewCell *)cell animate:(BOOL)animate
{
    if ([cell isKindOfClass:[ContactCell class]] || [cell isKindOfClass:[TopicCell class]]) {
        ContactCell *cCell = (ContactCell *)cell;
        if ([cCell respondsToSelector:@selector(setEditor:animate:)]) {
            [cCell setEditor:editing animate:animate];
        }
        if (editing)
        {
            if ( [cell isKindOfClass:[ContactCell class]] )
            {
                if (cCell.contactItem)
                {
                    [[cCell targetDelegate] ShowProfile:cCell.contactItem];
                    
                }
                else
                {
                    [[AppDelegate sharedDelegate] AutoHiddenAlert:@"Error Occured" messageContent:Nil];
                }
            }
        }
        NSInteger _oldEditingCount = self.editingCount;
        self.editingCount += editing ? 1 : -1;
        if(self.editingCount < 0) self.editingCount = 0;
        
        NSLog(@"CombinedViewController setEditing? %d atIndexPath: %d editing count old: %d new: %d", editing, (int)indexPath.row, (int)_oldEditingCount, (int)self.editingCount);
        
        if(editing){
            self.editingCell = cCell;
            self.editingIndexPath = indexPath;
        } else if(self.editingCount == 0){
            self.editingCell = nil;
            self.editingIndexPath = nil;
        }
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[BaseKnoteCell class]])
    {
        BaseKnoteCell *baseCell = (BaseKnoteCell *)cell;
        [baseCell willAppear];
    }
    
    /*
    if([cell isKindOfClass:[TopicCell class]]){
        ((TopicCell *)cell).activityCircle.hidden = YES;        
    }
     */
    
    if([cell isKindOfClass:[TopicCell class]] && self.tableView.isReordering)
    {
        //	Grip customization code goes in here...
        UIView* reorderControl = [cell huntedSubviewWithClassName:@"UITableViewCellReorderControl"];
        
        UIView* resizedGripView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(reorderControl.frame), CGRectGetMaxY(reorderControl.frame))];
        [resizedGripView addSubview:reorderControl];
        [cell addSubview:resizedGripView];
        
        CGSize sizeDifference = CGSizeMake(resizedGripView.frame.size.width - reorderControl.frame.size.width, resizedGripView.frame.size.height - reorderControl.frame.size.height);
        CGSize transformRatio = CGSizeMake(resizedGripView.frame.size.width / reorderControl.frame.size.width, resizedGripView.frame.size.height / reorderControl.frame.size.height);
        
        //	Original transform
        CGAffineTransform transform = CGAffineTransformIdentity;
        
        //	Scale custom view so grip will fill entire cell
        transform = CGAffineTransformScale(transform, transformRatio.width, transformRatio.height);
        
        //	Move custom view so the grip's top left aligns with the cell's top left
        transform = CGAffineTransformTranslate(transform, -sizeDifference.width / 2.0, -sizeDifference.height / 2.0);
        
        [resizedGripView setTransform:transform];
        
        NSArray * subViews = reorderControl.subviews;
        for(UIImageView* cellGrip in subViews)
        {
            if([cellGrip isKindOfClass:[UIImageView class]])
                [cellGrip setImage:nil];
        }
        
        //	Grip customization code goes in here...
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[BaseKnoteCell class]]) {
        BaseKnoteCell *baseCell = (BaseKnoteCell *)cell;
        if ([baseCell respondsToSelector:@selector(didDissapear)]) {
            [baseCell didDissapear];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#if kContactUserFetchedController
    if (!_searchMode)
	{
        if ([self needUpdateTableView:_fetchedResultsController])
		{
            NSInteger count = [self.fetchedResultsController sections].count;
            
            if (count == 0)
			{
                count = 1;
            }
            return count;
        }
    }
    else
    {
        return 1;
    }
#endif
#if kCombinedNewFeature
    if (self.topicArray.count==0&&_displayMode==DisplayModePads)
    {
        return 1;
    }
    return 1;
#else
    return 0;
#endif
}

-(NSArray*)filterFavoriteContacts{
    NSMutableArray * filteredContacts = [NSMutableArray array];
    ContactsEntity* entity = nil;
    ContactsEntity* selfContact = nil;
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    NSUInteger numberOfRows = [sectionInfo numberOfObjects];
    for(int i=0; i<numberOfRows; i++){
        NSIndexPath * index = [NSIndexPath indexPathForRow:i inSection:0];
        entity = (ContactsEntity*)[self.fetchedResultsController objectAtIndexPath:index];
        if([entity.isMe boolValue]){
            selfContact = entity;
            break;
        }
    }
    
    for(int i=0; i<numberOfRows; i++){
        NSIndexPath * index = [NSIndexPath indexPathForRow:i inSection:0];
        entity = (ContactsEntity*)[self.fetchedResultsController objectAtIndexPath:index];
        if(![entity.isMe boolValue] && [entity.contact_id isEqualToString:selfContact.contact_id]){
            [filteredContacts addObject:selfContact];
        }
        
        if([entity.contact_id isEqualToString:@"u6nqEfxtWyaedRS9v"]){
            NSLog(@"%@", @"DSA");
        }
    }
    
    return [filteredContacts copy];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#if kContactUserFetchedController
    
    if(!_searchMode)
    {
        if ([self needUpdateTableView:_fetchedResultsController])
        {
            NSInteger numberOfRows = 0;
            
            if ([self.fetchedResultsController sections].count > 0)
            {
                if(self.showFavoriteContacts){
                    numberOfRows = [self filterFavoriteContacts].count;
                }else{
                    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
                    numberOfRows = [sectionInfo numberOfObjects];
                }

            }
            
            return numberOfRows;
        }
    }
    else
    {
        return [self dataForTable:tableView].count;
    }
#endif
    if(self.transitioningData)
    {
        self.transitioningData = NO;
        NSLog(@"Done transitioningData");
    }
    
    int offset = 0;
    
    if (self.displayMode == DisplayModePads
        && self.topicArray.count == 0)
    {
        if ([DataManager sharedInstance].fetchedTopics)
        {
            offset = 1;
        }
        else
        {
            offset = 0;
        }
        
        NSLog(@"offset 1 for create a pad button");
    }
    else if (self.displayMode == DisplayModePeople)
    {
        offset = 0;
    }
    
    if (self.displayMode == DisplayModePads && self.showOwner)
    {
        //offset = offset + 1;    // Add +1 to show Pad Owner
    }
    
    NSInteger   retRowCount = 0;
    
    if (section == 0)
    {
        retRowCount = [self dataForTable:tableView].count + offset;
    }
    else
    {
        retRowCount = 0;
    }
    
    self.dataSourceCount = retRowCount;
    
    if (self.dataSourceCount != 0) {
        
        // Prevent changes on self.topicArray from crashing the app.
        NSArray * topicArrayReference = [self.topicArray copy];
        NSMutableArray *topicsArray = [[NSMutableArray alloc] init];
        for (TopicInfo *topic in topicArrayReference) {
           // NSLog(topic.content);
            NSMutableDictionary *topicDic = [[NSMutableDictionary alloc] init];
            
            // Prevent unnamed topics from crashing the app.
            NSString * topicName = topic.entity.topic;
            if(topicName.length == 0)
            {
                topicName = @"Unnamed";
                [topicDic setObject:topicName forKey:@"topic_name"];
            }
            else
            {
                [topicDic setObject:topic.entity.topic forKey:@"topic_name"];
            }
            
            if (!(topic.entity.topic_id == nil || [topic.entity.topic_id length]==0)) {
                [topicDic setObject:topic.entity.topic_id forKey:@"topic_id"];
                [topicsArray addObject:topicDic];
            }

        }
        
        NSUserDefaults *extensionUserDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.knotable.knotedev.share"];
        [extensionUserDefaults setObject:topicsArray forKey:@"Knotes"];
        [extensionUserDefaults synchronize];
    }
    
    /*if(retRowCount > 0)
    {*/
        //[self.spinnerImageView stopAnimating];
    //}
    if (retRowCount==0&& self.displayMode==DisplayModePads)
    {
        self.tableView.forceUpdateMinHeight=NO;
        //[tableView setContentSize:CGSizeMake(320, 568)];
        return 0;
    }
    else
    {
     self.tableView.forceUpdateMinHeight=YES;
    }
    
    return retRowCount;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DisplayMode mode = self.displayMode;
    
    if(self.transitioningData)
    {
        mode = self.oldDisplayMode;
    }
    
    UITableViewCell *cell = nil;
    
    switch (mode){
            
        case DisplayModePeople:
            
            //tmd
            cell = [self tableView:tableView contactCellForRowAtIndexPath:indexPath];
            cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageWithIcon:@"fa-angle-right" backgroundColor:[UIColor clearColor] iconColor:[UIColor grayColor] fontSize:26]];
            
            break;
            
        case DisplayModePads:
            
            cell = [self tableView:tableView topicCellForRowAtIndexPath:indexPath];
            
            break;
            
        case DisplayModeSettings:
            
            break;
    }
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView contactCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ContactCell *cell = (ContactCell*)[tableView dequeueReusableCellWithIdentifier:ContactCellIdentifier];
    
    if (cell == nil)
    {
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ContactCellIdentifier];
    }
    
    cell.indexPath = indexPath;

    // Configure the cell...
    
    ContactsEntity* entity = nil;
    if(self.showFavoriteContacts){
        entity = [[self filterFavoriteContacts] objectAtIndex:indexPath.row];
    }else{
        if (indexPath.row < [self dataForTable:tableView].count)
        {
            entity = (ContactsEntity*)[self dataForTable:tableView][indexPath.row];
        }
        
        if (!_searchMode)
        {
            if (indexPath.row<[self.fetchedResultsController fetchedObjects].count)
            {
                entity = (ContactsEntity*)[self.fetchedResultsController objectAtIndexPath:indexPath];
            }
        }
    }
    
    if (![entity isKindOfClass:[ContactsEntity class]])
    {
        return cell;
    }
    
    if (entity.name && [entity.name length]>0)
    {
        cell.lbTitle.text = entity.name;
    }
    else if (entity.username && [entity.username length]>0)
    {
        cell.lbTitle.text = entity.username;
    }
    
    // If there is not image to show at once, then app will show the
    // avatar image generated from contact's name
    [cell.imgView setOriginalImage:[entity getImageByUserName]];

    // After download real image, will update the placeholder image
    [ContactsEntity getAsyncImage:entity WithBlock:^(id img, BOOL flag) {
        
        [cell.imgView setOriginalImage:img];
        [cell.imgView draw];
        
    }];
    
    cell.lbDescription.text = @"";
    
    cell.targetDelegate = self;
    cell.contactItem = entity;
    
    [cell setArchived:self.showArchived];
    
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    [cell setNeedsUpdateConstraints];
    
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView topicCellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#if kUseFetchedController
    TopicCell *padcell = nil;
    TopicsEntity *entity = nil;
    if (indexPath.row < self.fetchedResultsController.fetchedObjects.count)
    {
        entity = [self.fetchedResultsController objectAtIndexPath:indexPath];

    }
    if ([entity isKindOfClass:[TopicsEntity class]] && entity.isPlaceHold == kInvalidatePosition)
    {
        PadOwnerCell *ownercell = (PadOwnerCell*)[tableView dequeueReusableCellWithIdentifier:PadOwnerCellIdentifier];
        
        if (ownercell == nil)
        {
            ownercell = [[PadOwnerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PadOwnerCellIdentifier];
        }
        
        if (_showOwner)
        {
            if (self.padOwnerContact && [self.padOwnerContact isKindOfClass:[ContactsEntity class]])
            {
                ownercell.lbTitle.text = self.padOwnerContact.name;
                
                ownercell.lbDescription.text = @"";
                
                [self.padOwnerContact getAsyncImageWithBlock:^(id img, BOOL flag) {
                    [ownercell.imgView setOriginalImage:img];
                    [ownercell.imgView draw];
                }];
                
                [ownercell setArchived:_showArchived];  // Need to check about this flag.
                
                ownercell.selectionStyle = UITableViewCellSelectionStyleGray;
                ownercell.accessoryType = UITableViewCellAccessoryNone;
                
                ownercell.targetDelegate = self;
                
                [ownercell setNeedsUpdateConstraints];
            }
        }
         return  ownercell;
    }
    else
    {
        padcell = (TopicCell*)[tableView dequeueReusableCellWithIdentifier:TopicCellIdentifier];
        
        if (padcell == nil)
        {
            padcell = [[TopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TopicCellIdentifier];
        }
    }

    if ([entity.needSend boolValue] && ![entity.isSending boolValue])
    {
        TopicInfo *p = [[TopicInfo alloc] initWithTopicEntity:entity];
        p.cell = padcell;
        
        p.indexPath = indexPath;
        
        p.delegate = self;
        NSLog(@"uploading Topic from topicCellForRowAtIndexPath %@", p.topic_id);
        [p recordSelfToServer];
    }
    else if([entity.needSend boolValue] && [entity.isSending boolValue])
    {
        NSLog(@"not uploading because already sending at topicCellForRowAtIndexPath %@", entity.topic_id);
        
    }
    [padcell setEntity:entity];

#else
    if (self.topicArray.count==0&&_displayMode==DisplayModePads)
    {
        static NSString *strEmty=@"EmptyPad";
        UITableViewCell *emptycell=[tableView dequeueReusableCellWithIdentifier:strEmty];
        if (emptycell==nil)
        {
            emptycell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strEmty];
            /*UILabel *lbl=[[UILabel alloc]initWithFrame:CGRectMake(5, 220, 310, 30)];
            lbl.text=[NSString stringWithFormat:@"No %@ pads with %@",self.showArchived?@"archived":@"active",self.currentAccount.user.name];
            lbl.font=[UIFont fontWithName:@"HelveticaNeue-Bold" size:17.0];
            lbl.textAlignment=UITextAlignmentCenter;
            lbl.textColor=[UIColor grayColor];
            [emptycell addSubview:lbl];*/
        }
        //emptycell.textLabel.frame=CGRectMake(5, (tableView.frame.size.height-_searchBgView.frame.size.height)/2-15, 310, 30);
        emptycell.textLabel.font=[UIFont fontWithName:@"HelveticaNeue-Light" size:17.0];
        emptycell.textLabel.textAlignment = NSTextAlignmentCenter;
        emptycell.textLabel.textColor=[UIColor grayColor];
        emptycell.textLabel.text=[NSString stringWithFormat:@"No %@ pads with %@",self.showArchived?@"archived":@"active",self.currentAccount.user.name];
        emptycell.selectionStyle = UITableViewCellSelectionStyleNone;

        return emptycell;
    }
    
    PadOwnerCell *ownercell = (PadOwnerCell*)[tableView dequeueReusableCellWithIdentifier:PadOwnerCellIdentifier];
    
    if (ownercell == nil)
    {
        ownercell = [[PadOwnerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PadOwnerCellIdentifier];
    }
    
    if (self.showOwner)
    {
        /*
        if (self.padOwnerContact)
        {
            ownercell.lbTitle.text = [NSString stringWithFormat:@"Shared with: %@",self.padOwnerContact.name];
            
            ownercell.lbDescription.text = @"";

            ownercell.backgroundColor=[UIColor colorWithRed:0.327 green:0.389 blue:0.471 alpha:1.000];
            ownercell.lbTitle.textColor=[UIColor whiteColor];

            [ownercell setArchived:self.showArchived];  // Need to check about this flag.
            
            ownercell.selectionStyle = UITableViewCellSelectionStyleGray;
            ownercell.accessoryType = UITableViewCellAccessoryNone;
            
            ownercell.targetDelegate = self;
            
            [ownercell setNeedsUpdateConstraints];
        }
         */
    }
    
    TopicCell *padcell = (TopicCell*)[tableView dequeueReusableCellWithIdentifier:TopicCellIdentifier];
    
    if (padcell == nil)
    {
        padcell = [[TopicCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TopicCellIdentifier];
    }

    if (tableView == self.tableView && self.topicArray.count == 0)
    {
        //Start a new pad cell
        
        NSLog(@"current user : %@", self.currentContact);
        
        if (self.currentContact)
        {
            if (self.currentContact.username)
            {
                padcell.titleLabel.text = [NSString stringWithFormat:@"New pad with %@",self.currentContact.username];
            }
            else
            {
                padcell.titleLabel.text = [NSString stringWithFormat:@"New pad with %@",self.currentContact.name];
            }
        }
        else
        {
            padcell.titleLabel.text = [NSString stringWithFormat:@"New pad with %@",self.currentAccount.user.name];
        }
        
        [padcell setNeedsUpdateConstraints];

        self.footerInfoView.hidden = NO;
        if (self.showOwner)
        {
            return padcell;
        }
        else
        {
            return  padcell;
        }
        
    }
    
    // Should avoid getting data for the whole tableview, inside cellforrow...
    NSArray *topicArray = [self dataForTable:tableView];
    
    int offest = 0;
    self.footerInfoView.hidden = NO;
    
    if ([topicArray count] > (indexPath.row - offest))
    {
        TopicInfo* p = (TopicInfo*) topicArray[indexPath.row - offest];
        
        p.cell = padcell;
        
        p.indexPath = indexPath;
        
        p.delegate = self;
        
        if(p.topic_id && ![self.padsCache objectForKey:p.topic_id])
        {
            if (!p.entity)
            {
                p.entity = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:p.topic_id];
            }
            else
            {
                if ([p.entity isFault])
                {
                    [p.entity MR_refresh];
                    
                    p.entity = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:p.topic_id];
                }
            }
            if (p.entity)
            {
                [self.padsCache setObject:p.entity forKey:p.topic_id];
            }
        }
        else
        {
            if (p.topic_id)
            {
                p.entity = [self.padsCache objectForKey:p.topic_id];
            }
        }
        
        if ([p.entity.needSend boolValue] && ![p.entity.isSending boolValue])
        {
            NSLog(@"uploading Topic from topicCellForRowAtIndexPath %@", p.topic_id);
            [p recordSelfToServer];
        }
        else if([p.entity.needSend boolValue] && [p.entity.isSending boolValue])
        {
            NSLog(@"not uploading because already sending at topicCellForRowAtIndexPath %@", p.topic_id);
            
        }
        
        [padcell setTInfo:p];
    }
    else
    {
        NSLog(@"ERROR check!!!!");
    }
#endif
    
    [padcell setNeedsUpdateConstraints];
    
    padcell.showsReorderControl=NO;
    
    if(self.tableView.isReordering)
    {
        UIView *vw =[padcell viewWithTag:400];
        [vw removeFromSuperview];
        padcell.layer.shadowOffset = CGSizeMake(2, 5);
        padcell.layer.shadowColor = [[UIColor blackColor] CGColor];
        padcell.layer.shadowRadius = 3;
        padcell.layer.shadowOpacity = .25;
        
        CGRect shadowFrame = padcell.layer.bounds;
        CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
        padcell.layer.shadowPath = shadowPath;
        vw =[[UIView alloc] initWithFrame:padcell.layer.bounds];
        vw.backgroundColor=[UIColor clearColor];
        vw.tag =400;
        [padcell addSubview:vw];
        [padcell sendSubviewToBack:vw];
    }
    else
    {
        UIView *vw =[padcell viewWithTag:400];
        [vw removeFromSuperview];
        padcell.layer.shadowPath = nil;;
        //        cell.layer.shadowOffset = CGSizeMake(1, 0);
        padcell.layer.shadowColor = [[UIColor clearColor] CGColor];
        padcell.layer.shadowRadius = 0;
        padcell.layer.shadowOpacity = 0;
    }
    self.footerInfoView.hidden = NO;
    if (self.showOwner)
    {
        return padcell;
        /*
        if (indexPath.row != 0 )
        {
            return padcell;
        }
         */
    }
    else
    {
        return padcell;
    }
    
    return padcell;
    
}

-(void)deleteButtonClicked
{
    _showArchived = !_showArchived;
    self.footerInfoView.showArchived = _showArchived;
    if (_displayMode == DisplayModePads)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
                                                 (unsigned long)NULL), ^(void){
            
            
            [self updateData];
            
        });
    }
    else
    {
        [self updateData];
    }
    
    if (_displayMode == DisplayModePads)
    {
        if (_showArchived)
        {
            self.title = ARCHIVE_TITLE;
            
            [self.recordBtn setImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor blueColor]]
                            forState:UIControlStateNormal];
        }
        else
        {
            self.title = PADS_TITLE;
            
            [self.recordBtn setImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor grayColor]]
                            forState:UIControlStateNormal];
        }
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    /*
    if(self.displayMode==DisplayModePads){
        if((tableView.numberOfSections - 1) == section){
            if(self.footerInfoView){
                return self.footerInfoView.frame.size.height;
            }else{
                return 0;
            }
        }else{
            return 0;
        }
    }else{
        return 0;
    }
     */
    return 0;
    
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    /*
    if(self.displayMode==DisplayModePads){
        if((tableView.numberOfSections - 1) == section){
            if(self.footerInfoView){
                return self.footerInfoView;
            }else{
                return nil;
            }
        }else{
            return nil;
        }
    }else{
        return nil;
    }
     */
    return nil;
}

- (BOOL) tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    if(!self.tableView.isReorderingAll)
    {
        self.tableView.isReordering=NO;
        self.navigationLeftMenu.m_btnReorder.selected=NO;
        self.tableView.editing=NO;

        TopicInfo *info =[self.topicArray objectAtIndex:0];
        info =[self.topicArray objectAtIndex:0];
        [self.topicArray exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
        info =[self.topicArray objectAtIndex:0];
        [self UpdatenewOrderrank];
    }
    
    return ;
}

- (void)openContactRowInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath autoStartKnote:(BOOL)autoKnote
{
    // Lin - Menu Change work
    
    [self UpdateNavigationBarIndex:2];
#if !New_DrawerDesign
    [self.bottomMenuBar UpdateButtonStateIndex:2];
#endif
    
    // Lin - Ended
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];


#if   kUseFetchedController
    ContactsEntity* contact = (ContactsEntity*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    if ([contact isKindOfClass:[ContactsEntity class]])
    {
        self.currentContact = contact;
        self.padOwnerContact = contact;
    }
#else
    
#if kContactUserFetchedController
    
    ContactsEntity* contact = nil;
    
    if (tableView == self.searchController.searchResultsTableView)
    {
        NSArray *data = [self dataForTable:tableView];
        if(data.count < indexPath.row)
        {
            NSLog(@"Error: data length %d looking for index %d", (int)data.count, (int)indexPath.row);
            return;
        }
        else
        {
           contact = (ContactsEntity*)data[indexPath.row];
        }
    }
    else
    {
        if([self.fetchedResultsController fetchedObjects].count > indexPath.row){
            contact = (ContactsEntity*)[self.fetchedResultsController objectAtIndexPath:indexPath];
        }
        
    }
    
    if ([contact isKindOfClass:[ContactsEntity class]])
    {
        self.currentContact = contact;
        self.padOwnerContact = contact;
        
        self.tablewViewCurrentYPosition = [NSNumber numberWithInt:[self.tablewViewCurrentYPosition intValue] + SHARED_WITH_VIEW_HEIGHT];
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y + [self.tablewViewCurrentYPosition intValue], self.tableView.frame.size.width, self.tableView.frame.size.height);
        
        [self initPeopleFilterView];
    }
    
#else
    
    NSArray *data = [self dataForTable:tableView];
    
    if(data.count < indexPath.row)
    {
        NSLog(@"Error: data length %d looking for index %d", (int)data.count, (int)indexPath.row);
        return;
    }
    else
    {
        ContactsEntity* contact = (ContactsEntity*)data[indexPath.row];
        
        self.currentContact = contact;
        
        self.padOwnerContact = contact;
    }
    
#endif
    
#endif
    
    if(autoKnote)
    {
        self.autoKnote = YES;
    }
    
    self.searchingPeople = self.searchController.active;
    
    if(self.searchController.active)
    {
        NSLog(@"self.searchController active, hide it");
        
        [self.searchController setActive:NO animated:YES];
        [self setDisplayMode:DisplayModePads animated:NO];
    }
    else
    {
        
        [self setDisplayMode:DisplayModePads animated:YES];
        [self performSelector:@selector(performActionToShowUser) withObject:nil afterDelay:0.3];

        
    }
}

-(void)initPeopleFilterView{
    
    self.peopleFilterBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 76)];
    self.peopleFilterBackgroundView.backgroundColor = [UIColor colorWithWhite:0.941 alpha:1.000];
    [self.view addSubview:self.peopleFilterBackgroundView];
    
    UIButton * peopleFilterCloseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [peopleFilterCloseButton setImage:[UIImage imageNamed:@"peopleFilterCloseButton"] forState:UIControlStateNormal];
    peopleFilterCloseButton.frame = CGRectMake(self.peopleFilterBackgroundView.frame.size.width - 30, (self.peopleFilterBackgroundView.frame.size.height - 20)/2, 20, 20);
    [peopleFilterCloseButton addTarget:self action:@selector(CloseContactOwner) forControlEvents:UIControlEventTouchDown];
    
    GBPathImageView * profileImageView = [[GBPathImageView alloc] initWithFrame:CGRectMake(30, (self.peopleFilterBackgroundView.frame.size.height - 41)/2, 41, 41)];
    
    [profileImageView setOriginalImage:[self.currentContact getImageByUserName]];
    
    // After download real image, will update the placeholder image
    [ContactsEntity getAsyncImage:self.currentContact WithBlock:^(id img, BOOL flag) {
        
        [profileImageView setOriginalImage:img];
        [profileImageView draw];
        
    }];
    
    UILabel * nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileImageView.frame.origin.x + profileImageView.frame.size.width + 20, profileImageView.frame.origin.y, 200, 20)];
    nameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    nameLabel.text = self.currentContact.name;
    
    UILabel * mailLabel = [[UILabel alloc] initWithFrame:CGRectMake(profileImageView.frame.origin.x + profileImageView.frame.size.width + 20, profileImageView.frame.origin.y + 20, 200, 20)];
    mailLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    mailLabel.text = self.currentContact.email;
    NSRange range = [self.currentContact.email rangeOfString:@","];
    if(range.location != NSNotFound){
        mailLabel.text = [self.currentContact.email substringToIndex:range.location];
    }
    
    [self.peopleFilterBackgroundView addSubview:nameLabel];
    [self.peopleFilterBackgroundView addSubview:mailLabel];
    [self.peopleFilterBackgroundView addSubview:peopleFilterCloseButton];
    [self.peopleFilterBackgroundView addSubview:profileImageView];
    
}

-(void)performActionToShowUser
{
    _searchMode=NO;
    [self reloadData];
    [self performSelector:@selector(performOnTapPeopleLoaded) withObject:nil afterDelay:0.3];

}

-(void)performOnTapPeopleLoaded
{
    [self setDisplayMode:DisplayModePads animated:YES];

}
- (void)openTopicRowInTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

#if   kUseFetchedController
    
    TopicsEntity *entity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if (entity.isPlaceHold == kInvalidatePosition)
    {
        [self startAddTopic];
        return;
    }
    
    TopicInfo* topic = [[TopicInfo alloc] initWithTopicEntity:entity];
    
#else
        if (tableView == self.tableView && self.topicArray.count == 0)
        {
        //Create a new pad cell
            //[self startAddTopic:NO];
    
        return;
    }
    
    if(self.searchController.active)
    {
        NSLog(@"self.searchController active, dont hide it");
    }
    
    NSArray *data = nil;
    
    if (self.currentContact && !self.searchController.active)
    {
        // This Method will Return specific user shared PADs data source. @Malik
        data = [self specificUserPadsDataSource];
    }
    else if(self.filteredArray.count > 0){
        data = [self.filteredArray copy];
    }
    else
    {
        data = [self dataSpacesForTable:tableView];
    }
    
    TopicInfo* topic = (TopicInfo*)data[indexPath.row];
    
    TopicsEntity *entity = topic.entity;
    
    if( entity.hasNewActivity.boolValue )
    {
        [entity markViewed];

        [tableView reloadData];
    }
    
    topic.cell.processRetainCount = 1;
    
    [topic.cell stopProcess];
    
#endif
    
    if(!self.willSegueAfterRowTap){
        self.willSegueAfterRowTap = YES;
        ThreadViewController* threadController = [[ThreadViewController alloc] initWithTopic:topic];
        threadController.delegate = self;
        
        CATransition *transition = [CATransition animation];
        transition.duration = 5.8;
        transition.timingFunction = [CAMediaTimingFunction
                                     functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        transition.fillMode = kCAFillModeForwards;
        transition.delegate = self;
        [self.view.layer addAnimation:transition forKey:kCombineAnimation];
        
        [self.navigationController pushViewController:threadController animated:animated];
    }
}

- (void) navigateToThreadWithTopicInfo:(NSString *)ti animated:(BOOL)animated{
    
    self.navigationItem.leftBarButtonItem = nil;
    self.navigationItem.rightBarButtonItem = Nil;
    self.navigationItem.title = @"";
    self.navigationItem.rightBarButtonItem.tag = 1;
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    
    if(!self.willSegueAfterRowTap){
        self.willSegueAfterRowTap = YES;
        
        TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:ti];
        TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:topic];
        ThreadViewController* threadController = [[ThreadViewController alloc] initWithTopic:tInfo];
        threadController.delegate = self;
        
        CATransition *transition = [CATransition animation];
        transition.duration = 5.8;
        transition.timingFunction = [CAMediaTimingFunction
                                     functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromRight;
        transition.fillMode = kCAFillModeForwards;
        transition.delegate = self;
//#if New_DrawerDesign
//        self.stack.hidden=YES;
//#endif
        [self.view.layer addAnimation:transition forKey:kCombineAnimation];
        
        [self.navigationController pushViewController:threadController animated:animated];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.expIndexPath = nil;
    
    switch (self.displayMode)
    {
        case DisplayModePeople:
            
            self.showOwner = YES;
            
            // Lin - Added to init Pad UI
            
            self.showArchived = NO;
            
            self.navigationLeftMenu.archiveSelectedFlag = NO;
            [self.navigationLeftMenu.m_btnArchive setBackgroundImage:[UIImage imageNamed:@"trash_normal.png"] forState:UIControlStateNormal];
            
            self.navigationLeftMenu.m_btnReorder.selected = NO;
            
            // Lin - Ended
            
            [[Lookback_Weak lookback] enteredView:@"People -> Detail"];
            [self.searchController setActive:NO animated:YES];
            [self openContactRowInTableView:tableView atIndexPath:indexPath autoStartKnote:NO];
            
            break;
            
        case DisplayModePads:
            
            if (self.showOwner)
            {
                /*self.showOwner = NO;
                self.displayMode=DisplayModePeople;
                [self BottomMenuActionIndex:1];*/
            }
            [[Lookback_Weak lookback] enteredView:@"Pads View"];
            
            [self openTopicRowInTableView:tableView atIndexPath:indexPath animated:YES];
            
            break;
            
        case DisplayModeSettings:
            NSLog(@"settings pressed");
            break;
    }
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSLog(@"commitEditingStyle Delete %@,%d",[self dataForTable:tableView],(int)indexPath.row);
        
        // Delete the row from the data source
        if ([tableView isEqual:self.tableView])
        {
            NSMutableArray * dataForTable = [self dataForTable:tableView];
            if(dataForTable.count > indexPath.row){
                [dataForTable removeObjectAtIndex:indexPath.row];
            }
        }
        else
        {
            TopicInfo *object = [self dataForTable:tableView][indexPath.row];
            
            if (self.displayMode == DisplayModePads)
            {
                NSMutableArray * dataForTable = [self dataForTable:tableView];
                if(dataForTable.count > indexPath.row){
                    [dataForTable removeObjectAtIndex:indexPath.row];
                }

                for (int i = 0 ; i<[self.topicArray count]; i++)
                {
                    TopicInfo *tInfo = self.topicArray[i];
                    
                    if ([tInfo.topic_id isEqualToString:object.topic_id])
                    {
                        if(self.topicArray.count > i){
                            [self.topicArray removeObjectAtIndex:i];
                        }
                        if([self.topicArrayDictionary objectForKey:tInfo.topic_id]){
                            [self.topicArrayDictionary removeObjectForKey:tInfo.topic_id];
                        }
                        
                        break;
                    }
                }
            }
        }
        
        if (tableView == self.tableView
            && self.displayMode == DisplayModePads

            && self.topicArray.count == 0)
        {
            if (self.isCurrentShow)
            {
                [tableView reloadData];
            }
        }
        else
        {
            if (self.isCurrentShow)
            {
                [tableView beginUpdates];
                
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                [tableView endUpdates];
            }
            
            [self performSelector:@selector(reloadData) withObject:nil afterDelay:0];
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.displayMode == DisplayModePeople)
    {
        if (indexPath.row == 0)
        {
            return NO;
        }
    }
    return YES;
}

// Lin - Added to show Muted Items

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    CGFloat sectionHeight = 0.0f;
    
#if kCombinedNewFeature
    
#else
    
    return 0.0f;
    
#endif
    
    return sectionHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
#if kCombinedNewFeature
    UIView *view = [UIView new];
    
    CGFloat buttonH = 18.0f;
    CGFloat gap = 10;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
    UIImageView *imageV = nil;
    
    [view setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kInfoBarHeight)];
    
    [button setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kInfoBarHeight)];
    
    if (imageV && [imageV superview])
    {
        [imageV mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(buttonH));
            make.width.equalTo(@(buttonH));
            make.right.equalTo(titleLabel.mas_left).offset(-gap);
            make.centerY.equalTo(button.mas_centerY);
        }];
    }
    
    if (titleLabel && [titleLabel superview])
    {
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(0));
            make.bottom.equalTo(@(0));
            CGSize size = [CUtil getTextSize:titleLabel.text textFont:titleLabel.font];
            make.width.equalTo(@(size.width+2));
            make.centerX.equalTo(button.mas_centerX).offset(buttonH/2+gap/2);
        }];
    }
    if (!view)
    {
        view = [UIView new];
        view.backgroundColor = [UIColor redColor];
        [view setFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, kInfoBarHeight)];
    }
    return view;
#else
    
    return [UIView new];
    
#endif
}

// Lin - Ended

- (void)showSearchLeftButton
{
    self.recordBtn.alpha = 0.0;
    if (!_isUpdateSearch)
    {
        self.view.userInteractionEnabled=NO;
        return;
    }
    
    _isUpdateSearch=NO;
    self.view.userInteractionEnabled=NO;
    [self.searchBgView addSubview:self.recordBtn];
    
    [UIView animateKeyframesWithDuration:.2 delay:0.3 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        self.recordBtn.alpha = 0.8;
        //[self.recordBtn setFrame:CGRectMake(14, 18, 22, 22)];
        [self.recordBtn setFrame:CGRectMake(_searchBgView.frame.size.width/2 -22/2, 18, 22, 22)];

    } completion:^(BOOL finished) {
        self.recordBtn.alpha = 1.0;
        
        _isUpdateSearch=YES;
        self.view.userInteractionEnabled=YES;
    }];
    
    
}

#pragma mark - Swipable Cell Function

- (UIView *)viewWithImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    
    return imageView;
}


#pragma mark UISearchDisplayDelegate methods

- (void)updateSearchResultsForString:(NSString *)searchString
{
    self.searchString = searchString;
    
    NSMutableArray *searchResults = self.displayMode == DisplayModePeople ? _peopleSearchResults : _topicSearchResults;
    
    [searchResults removeAllObjects];
    
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    
    if(self.displayMode == DisplayModePeople)
    {

#if kContactUserFetchedController
        NSArray *peopleData = self.fetchedResultsController.fetchedObjects;
#else
        NSArray *peopleData = _peopleData;
#endif
        for (ContactsEntity *contact in peopleData)
        {
            NSString *searchAgainst = contact.name;
            
            if(!searchAgainst || searchAgainst.length == 0)
            {
                continue;
            }
            
            NSRange foundRange = [searchAgainst rangeOfString:searchString
                                                      options:searchOptions
                                                        range:NSMakeRange(0, searchAgainst.length)];
            
            if (foundRange.length > 0)
            {
                [searchResults addObject:contact];
            }
        }
    }
    else if(self.displayMode == DisplayModePads)
    {

#if kUseFetchedController
        
        NSArray *topicArray = self.fetchedResultsController.fetchedObjects;
        for (TopicsEntity *entity in topicArray)
        {
            NSString *searchAgainst = entity.topic;
            
            if(!searchAgainst || searchAgainst.length == 0)
            {
                continue;
            }
            
            NSRange foundRange = [searchAgainst rangeOfString:searchString options:searchOptions range:NSMakeRange(0, searchAgainst.length)];
            
            if (foundRange.length > 0)
            {
                [searchResults addObject:entity];
            }
        }
#else
        

        NSArray *topicArray = (self.currentContact && self.searchController.active) ? [self specificUserPadsDataSource] : _topicArray;
        
        for (TopicInfo *tInfo in topicArray)
        {
            NSString *searchAgainst = tInfo.entity.topic;
            
            if(!searchAgainst || searchAgainst.length == 0)
            {
                continue;
            }
            
            NSRange foundRange = [searchAgainst rangeOfString:searchString options:searchOptions range:NSMakeRange(0, searchAgainst.length)];
            
            if (foundRange.length > 0)
            {
                [searchResults addObject:tInfo];
            }
        }
#endif

    }
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller {
    self.searchBar.showsCancelButton = NO;
    self.searchController.displaysSearchBarInNavigationBar = NO;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller{
    self.navigationItem.titleView = nil;

#if kCombinedNewFeature
    self.searchCancelClicked = YES;
    [self showSearchLeftButton];
#endif
    
    if (self.displayMode == DisplayModePeople)
    {
        [self UpdateNavigationBarIndex:1];
#if !New_DrawerDesign
        [self.bottomMenuBar UpdateButtonStateIndex:1];
#endif
    }
    else if (self.displayMode == DisplayModePads)
    {
        [self UpdateNavigationBarIndex:2];
#if !New_DrawerDesign
        [self.bottomMenuBar UpdateButtonStateIndex:2];
#endif
    }
    else if(self.displayMode == DisplayModeSettings)
    {
        [self UpdateNavigationBarIndex:3];
#if !New_DrawerDesign
        [self.bottomMenuBar UpdateButtonStateIndex:3];
#endif
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self updateSearchResultsForString:searchString];
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    //NSLog(@"------>frame");
    //NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    self.searchMode = YES;

    [tableView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    
    if (CGRectIsEmpty(self.searchTableViewRect)) {
        
        CGRect tableViewFrame = tableView.frame;
        
        tableViewFrame.origin.y = tableViewFrame.origin.y + 66;
        tableViewFrame.size.height =  tableViewFrame.size.height - 66;
        
        self.searchTableViewRect = tableViewFrame;
        
    }
     //[_searchBar setFrame:CGRectMake(40, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 44)];
    [tableView setFrame:self.searchTableViewRect];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    NSLog(@"2-- willHideSearchResultsTableView");
    
    
    NSLog(@"------>frame");
    
    NSLog(@"%@",NSStringFromCGRect(self.view.frame));
    
    //[self setSearchBarVisibleDisplayMode:DisplayModePads Visible:YES];
  // [_searchBar setFrame:CGRectMake(40, 0, CGRectGetWidth([UIScreen mainScreen].bounds)-40, 44)];
    self.searchMode = NO;
}

- (void)searchTableViewTaped:(UIGestureRecognizer *)gestureRecognizer
{
    if(self.editingIndexPath)
    {
        UITableViewCell * cell = [self.searchController.searchResultsTableView cellForRowAtIndexPath:self.editingIndexPath];
        
        [self setEditing:NO
      atPrivateIndexPath:self.editingIndexPath
                    cell:cell];
    }
}


- (NSIndexPath *)cellIndexPathForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    UIView * view = gestureRecognizer.view;
    if(![view isKindOfClass:[UITableView class]]) {
        return nil;
    }
    
    CGPoint point = [gestureRecognizer locationInView:view];
    NSIndexPath * indexPath = [self.searchController.searchResultsTableView indexPathForRowAtPoint:point];
    return indexPath;
}

- (void)setEditing:(BOOL)editing atPrivateIndexPath:indexPath cell:(UITableViewCell *)cell {
    
    if(editing) {
        if(self.editingIndexPath) {
            UITableViewCell * editingCell = [self.searchController.searchResultsTableView cellForRowAtIndexPath:self.editingIndexPath];
            [self setEditing:NO atIndexPath:self.editingIndexPath cell:editingCell];
        }
        [self.searchController.searchResultsTableView addGestureRecognizer:self.tapGestureRecognizer];
    } else {
        [self.searchController.searchResultsTableView removeGestureRecognizer:self.tapGestureRecognizer];
    }
    
    if(editing) {
        self.editingIndexPath = indexPath;
    } else {
        self.editingIndexPath = nil;
    }
    
    if ([self respondsToSelector:@selector(setEditing:atIndexPath:cell:)]) {
        [self setEditing:editing atIndexPath:indexPath cell:cell];
    }
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO; // Recognizers of this class are the first priority
}

- (void)dealloc
{
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)needChangeTopicTitle:(TopicInfo *)tInfo
{
    if (![self.topicArray containsObject:tInfo]){
        [self fetchedTopics:nil];
    }
    
    if (self.displayMode == DisplayModePads){
        [self reloadData];
    }
}

-(void) topicArchivOperate:(TopicInfo *)tInfo
{
    if (self.searchMode)
    {
        [self searchTableViewTaped:nil];
        
        switch (self.displayMode)
        {
            case DisplayModePeople:
                break;
                
            case DisplayModePads:
                
                [self.searchController.searchResultsTableView.dataSource tableView:self.searchController.searchResultsTableView
                                                                commitEditingStyle:UITableViewCellEditingStyleDelete
                                                                 forRowAtIndexPath:tInfo.indexPath];
                break;
                
            default:
                break;
        }
    }
    else
    {
        [self.tableView tapped:nil];
        
        switch (self.displayMode){
        
            case DisplayModePeople:
                break;
                
            case DisplayModePads:
                
                [self removeTopicWithTopicID:tInfo.topic_id];
                
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - CTitleInfoBarDelegate

- (void) titleInfoClickeAtContact:(ContactsEntity *)entity
{
    // Lin - Added to
    
    /*
     Recent View : Show Profile :
     
     Will not show remove button
     
     */
    
    // Lin - Ended
    
    MyProfileController *profile = [[MyProfileController alloc] initWithContact:entity];
    [profile setProfile_remove_buttonType:RemoveFromNone];
    
    __block MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:profile];
    
    CGFloat ctlHeight = self.view.bounds.size.height - 60;
    formSheet.presentedFormSheetSize = CGSizeMake(300, ctlHeight);
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    [formSheet setPortraitTopInset:20];
    [formSheet setLandscapeTopInset:20];
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        // Passing data
    };
    
    [MZFormSheetController sharedBackgroundWindow].formSheetBackgroundWindowDelegate = self;
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
    
}

- (void) enableSwitchView
{
#if !New_DrawerDesign
    self.bottomMenuBar.m_btnPads.userInteractionEnabled=YES;
#endif
}

#pragma mark - Utility Functions


-(BOOL) canHideTopProgressLoading
{
//    if ([self.title isEqual:@"Recent"])
//    {
//        return YES;
//    }
//    else if ([self.title isEqual:@"People"])
//    {
//        if (self.peopleData.count >= [AppDelegate sharedDelegate].user_total_contacts)
//        {
//            NSLog(@"STOP ANIMATING FetchedAllTopics user_total_contacts %i %i", (int)self.peopleData.count, (int)[AppDelegate sharedDelegate].user_total_contacts);
//            
//            return YES;
//        }
//        else
//        {
//            return NO;
//        }
//
//    }
//    else if ([self.title isEqual:@"Pads: Done"])
//    {
//        if (self.topicArray.count >= [AppDelegate sharedDelegate].user_archived_topics)
//        {
//            NSLog(@"STOP ANIMATING FetchedAllTopics user_archived_topics %i %i", (int)self.topicArray.count, (int)[AppDelegate sharedDelegate].user_archived_topics);
//            
//            return YES;
//        }
//        else
//        {
//            return NO;
//        }
//
//    }
//    else if ([self.title isEqual:@"Profile"])
//    {
//        return YES;
//    }
//    else if ([self.title isEqual:PADS_TITLE])
//    {
//        if (self.topicArray.count >= [AppDelegate sharedDelegate].user_active_topics)
//        {
//            NSLog(@"STOP ANIMATING FetchedAllTopics Pads: Active %i %i", (int)self.topicArray.count, (int)[AppDelegate sharedDelegate].user_active_topics);
//            
//            return YES;
//        }
//        else
//        {
//            return NO;
//        }
//    }
//    else
//    {
        return YES;
//    }
}


-(NSString*) getTitleForTopLoadingBar
{
//    if ([self.title isEqual:@"Recent"])
//    {
//        return @"";
//    }
//    else if ([self.title isEqual:@"People"])
//    {
//        return @"updating contacts ..";
//    }
//    else if ([self.title isEqual:@"Pads: Done"])
//    {
//        return @"updating pad list ..";
//    }
//    else if ([self.title isEqual:@"Profile"])
//    {
//        return @"";
//    }
//    else if ([self.title isEqual:PADS_TITLE])
//    {
//        return @"updating pad list ..";
//    }
//    else
//    {
        return @"";
//    }
}

-(void) OpenPeople
{
    // Close profile filter view if it's open
    if(self.peopleFilterBackgroundView.superview){
        self.tablewViewCurrentYPosition = [NSNumber numberWithInt:TABLEVIEW_INITIAL_Y_POSITION];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tablewViewCurrentYPosition);
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.bottom.equalTo(@0);
        }];
        [self configureQuickFilterButton];
        [self.peopleFilterBackgroundView removeFromSuperview];
    }
    
    self.showOwner = NO;
    self.showMutedItems = NO;
    
    self.searchingPeople = NO;
    
    [[Lookback_Weak lookback] enteredView:@"People View"];
    
    if (self.displayMode != DisplayModePeople)
    {
        
#if kContactUserFetchedController
        
        BOOL sortFlag = NO,archiveFlag = NO;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"archived == %@ && isMe == NO", @(archiveFlag)];
        
        NSString *sortFields = sortFlag ? @"name:YES" : @"position:NO,total_topics:YES";
        
        _fetchedResultsController.delegate = nil;
        _fetchedResultsController = [ContactsEntity MR_fetchAllSortedBy:sortFields ascending:YES withPredicate:predicate groupBy:nil delegate:self];
        
#endif
        self.displayMode = DisplayModePeople;
    }
    else
    {
        [self scrollUp];
    }
    
    // Remove quick filter if visible
    self.filterButton.hidden = YES;
    if(self.bubbleDialog.superview){
        [self.bubbleDialog removeFromSuperview];
        [self.opaqueBlackBackgroundView removeFromSuperview];
        self.opaqueBlackBackgroundView = nil;
        self.bubbleDialog = nil;
        self.filteredArray = nil;
    }
}

//-(void) OpenPads
//{
//    // Close profile filter view if it's open
//    if(self.peopleFilterBackgroundView.superview){
//        self.tablewViewCurrentYPosition = [NSNumber numberWithInt:TABLEVIEW_INITIAL_Y_POSITION];
//        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.tablewViewCurrentYPosition);
//            make.left.equalTo(@0);
//            make.right.equalTo(@0);
//            make.bottom.equalTo(@0);
//        }];
//        [self configureQuickFilterButton];
//        [self.peopleFilterBackgroundView removeFromSuperview];
//    }
//    
//    self.filterButton.hidden = NO;
//    self.showOwner = NO;
//    self.showMutedItems = NO;
//    
//    // Lin - Added to init Pad UI
//    
//    if(self.showArchived){
//        self.showArchived = NO;
//        [self.topicArray removeAllObjects];
//        [self.topicArrayDictionary removeAllObjects];
//        [self.recordBtn setImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor grayColor]]
//                        forState:UIControlStateNormal];
//    }
//    
//    self.navigationLeftMenu.archiveSelectedFlag = NO;
//    [self.navigationLeftMenu.m_btnArchive setBackgroundImage:[UIImage imageNamed:@"trash_normal.png"] forState:UIControlStateNormal];
//    
//    self.navigationLeftMenu.m_btnReorder.selected = NO;
//    
//    [[Lookback_Weak lookback] enteredView:@"Pad View"];
//    
//    if (self.displayMode != DisplayModePads)
//    {
//        self.currentContact = nil;
//        
//        //self.padProgressBar.indicatorTextLabel.text = [NSString stringWithFormat:@"0%%"];
//        
//        //[self.padProgressBar setProgress:0 animated:YES];
//
//        NSUInteger local_active_topic_count = 0;
//        
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isArchived == %@)", @(NO)];
//        
//        local_active_topic_count = [TopicsEntity MR_countOfEntitiesWithPredicate:predicate];
//        
//        DLog(@"Server Active Topics : %d", (int)[AppDelegate sharedDelegate].user_active_topics);
//        
////        if (local_active_topic_count >= [AppDelegate sharedDelegate].user_active_topics)
//        {
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
//                                                     (unsigned long)NULL), ^(void){
//                
//                [self fetchedAllPeopleTopics:NO];
//#if !New_DrawerDesign
//                self.bottomMenuBar.m_btnPads.userInteractionEnabled=YES;
//#endif
//                
//                self.isUpdatedTopic=YES;
//            });
//        }
////        else
//        {
////            self.bottomMenuBar.m_btnPads.userInteractionEnabled=YES;
////            
////            self.isUpdatedTopic=YES;
//        }
//
//        self.displayMode = DisplayModePads;
//        
//    }
//    else
//    {
//        self.currentContact = nil;
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
//                                                 (unsigned long)NULL), ^(void){
//            
//            [self fetchedAllPeopleTopics:NO];
//            
//        });
//    }
//#if !kCombinedNewFeature  
//    [self scrollUp];
//#endif
//}

-(void) OpenSettings
{
    self.filterButton.hidden = YES;
    if(self.bubbleDialog.superview){
        [self.bubbleDialog removeFromSuperview];
        [self.opaqueBlackBackgroundView removeFromSuperview];
        self.opaqueBlackBackgroundView = nil;
        self.bubbleDialog = nil;
        self.filteredArray = nil;
    }
    
    self.showOwner = NO;
    self.showMutedItems = NO;
    self.firstLoad=NO;
    if(self.displayMode !=DisplayModeSettings)
    {
        self.displayMode=DisplayModeSettings;
        [[Lookback_Weak lookback] enteredView:@"Profile Detail View"];
        self.profileInfo =[[ProfileDetailVC alloc] initWithAccount:[DataManager sharedInstance].currentAccount];
        self.profileInfo.logOUTInstance=self;
        [self addChildViewController:self.profileInfo];
#if !New_DrawerDesign
        self.auxiliarScrollViewForProfileInfoView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.profileInfo.view.frame.size.width, self.view.frame.size.height - self.bottomMenuBar.frame.size.height)];
#else
         self.auxiliarScrollViewForProfileInfoView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.profileInfo.view.frame.size.width, self.view.frame.size.height )];
#endif
        
        [self.auxiliarScrollViewForProfileInfoView addSubview:self.profileInfo.view];
        
        [self.view addSubview:self.auxiliarScrollViewForProfileInfoView];
#if !New_DrawerDesign
        self.bottomMenuBar.frame = CGRectMake(0, self.view.frame.size.height - self.bottomMenuBar.frame.size.height, self.bottomMenuBar.frame.size.width, self.bottomMenuBar.frame.size.height);
#endif
    }
}

// Lin - Added to Control Menubar Touching
- (void) TouchableMenu
{
#if !New_DrawerDesign
    [self.bottomMenuBar setUserInteractionEnabled:YES];
#endif
}

- (void) NonTouchableMenu
{
#if !New_DrawerDesign
    [self.bottomMenuBar setUserInteractionEnabled:NO];
#endif
}
// Lin - Ended


- (void) actionSort
{
    BOOL    senderFlag = !self.sortAlphabetically;
    [self floatingTraySetAlphabetical:senderFlag];
}

- (void) actionSpeaker
{
    self.animateMuteCell = NO;
}

- (void) actionArchive
{
    BOOL    senderFlag = !self.showArchived;
    
    [self showArchivedPads:senderFlag];
}

- (void) actionReorder
{
    BOOL    senderFlag = !self.reorderFlag;
    
    //    [self floatingTraysetReorder:senderFlag];
    
    [self floatingTraysetOneReorder:senderFlag];
}

- (void)UpdateNavigationBarIndex:(NSInteger)buttonIndex
{
    return;// for remove pad people, setting remove
    
    if (buttonIndex < 3)
    {
        self.navigationItem.leftBarButtonItem = Nil;
        self.navigationItem.leftBarButtonItems = Nil;
        
        self.navigationItem.rightBarButtonItem = Nil;
        self.navigationItem.rightBarButtonItems = Nil;
    }
    
    //Restore navigation Bar
    self.navigationController.navigationBar.translucent = NO;
    
    switch (buttonIndex) {
            
        case PEOPLE_BUTTON_INDEX:
            
            self.title = PEOPLE_TITLE;
            
#if !New_DrawerDesign
            
            if (self.addButton == Nil)
            {
                
                //tmd
                UIImage * leftBarButnImg = [UIImage imageNamed:@"ios7-plus"];
                //UIImage * leftBarButnImg = [UIImage imageWithIcon:@"fa-pencil-square-o" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] fontSize:40];

                UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
                [button setImage:leftBarButnImg forState:UIControlStateNormal];
                [button setFrame:CGRectMake(0, 0, leftBarButnImg.size.width, leftBarButnImg.size.height)];
                [button addTarget:self action:@selector(addPressed) forControlEvents:UIControlEventTouchUpInside];
                self.addButton = [[UIBarButtonItem alloc] initWithCustomView:button];
            }
            
            self.navigationItem.rightBarButtonItem = self.addButton;
#endif
            break;
            
        case PADS_BUTTON_INDEX:
            
            if (self.showArchived)
            {
                self.title = ARCHIVE_TITLE;
                
                [self.recordBtn setImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor blueColor]]
                                forState:UIControlStateNormal];
            }
            else
            {
                self.title = PADS_TITLE;
                
                [self.recordBtn setImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor grayColor]]
                                forState:UIControlStateNormal];
            }
            
            
            
            self.leftCustomMenu = [[UIBarButtonItem alloc] initWithCustomView:self.navigationLeftMenu];
#if !kCombinedNewFeature           
            self.navigationItem.leftBarButtonItem = self.leftCustomMenu;
#endif            
            // Naviation Right Button Setting
#if !New_DrawerDesign
            if (self.editButton == Nil)
            {
                self.editButton = [self customBarButtonItem];
            }
            
            self.navigationItem.rightBarButtonItem = self.editButton;
#endif
            break;
            
        case SETTING_BUTTON_INDEX:
#if New_DrawerDesign
            self.title = @"Settings";
#else
            self.title = @"";
#endif
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = Nil;
            self.navigationItem.rightBarButtonItem.tag = 1;
#if New_DrawerDesign
            self.navigationController.navigationBar.translucent = NO;
#else
            self.navigationController.navigationBar.translucent = YES;
#endif
            break;
    }
    
// remove for left drawerbutton and slider
#if 0// New_DrawerDesign
    UIImage * leftBarButnImg = [[UIImage imageNamed:@"menuicon"] imageTintedWithColor:[UIColor blackColor]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:leftBarButnImg forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, leftBarButnImg.size.width, leftBarButnImg.size.height)];
    [button addTarget:self action:@selector(showDrawer) forControlEvents:UIControlEventTouchUpInside];
    self.leftDrowerMenu = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = self.leftDrowerMenu;
#endif
    
    //tmd
    //UIImage * rightBarButnImg = [[UIImage imageNamed:@"awesome_search"] imageTintedWithColor:[UIColor whiteColor]];
    UIImage * rightBarButnImg = [UIImage imageWithIcon:@"fa-search" backgroundColor:[UIColor clearColor] iconColor:[UIColor blackColor] andSize:CGSizeMake(22, 22)];

    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [button2 setImage:rightBarButnImg forState:UIControlStateNormal];
    [button2 setFrame:CGRectMake(0, 0, rightBarButnImg.size.width, rightBarButnImg.size.height)];
    [button2 addTarget:self action:@selector(showSearch) forControlEvents:UIControlEventTouchUpInside];

    self.rightSrchBtn = [[UIBarButtonItem alloc] initWithCustomView:button2];
    self.navigationItem.rightBarButtonItem = self.rightSrchBtn;

}

- (void)showSearch{
    
#if New_DrawerDesign
    self.navigationItem.leftBarButtonItem = nil;
#endif
    
    self.searchBar.showsCancelButton = YES;
    self.navigationItem.rightBarButtonItem = nil;
    
    @try {
        self.navigationItem.titleView = _searchBar; 
    }
    @catch (NSException *exception) {
    }
    @finally {
        
    }
    
    
    
    self.searchController.displaysSearchBarInNavigationBar = YES;
    [_searchBar becomeFirstResponder];
    
}

- (void)profileDetailEdit
{
    [self.profileInfo onEdit];
}

- (void)setSearchBarVisibleDisplayMode:(NSInteger)displayMode Visible:(BOOL)visible
{
    if (displayMode == DisplayModePeople
        || displayMode == DisplayModePads)
    {
        if (self.tableView.tableHeaderView != _searchBar)
        {
#if kCombinedNewFeature
            
            if (!self.searchBgView)
            {
                self.searchBgView = [UIView new];
            }
            
            [self.searchBgView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:nil];
            
            
            [_searchBgView setFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 60)];
        [_searchBar setFrame:CGRectMake(40, 8, CGRectGetWidth([UIScreen mainScreen].bounds)-40, 44)];
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];

            [_searchBgView addSubview:button];
            
            //[button setFrame:CGRectMake(14, 18, 22, 22)];
            [button setFrame:CGRectMake(_searchBgView.frame.size.width/2 -22/2, 18, 22, 22)];

            if (displayMode == DisplayModePads)
            {
                //self.tableView.translatesAutoresizingMaskIntoConstraints = YES;
                self.readButton.hidden = NO;
                self.unreadButton.hidden = NO;
                [self.readButton setTitle:DONE_BUTTON_TITLE forState:UIControlStateNormal];
                [self.unreadButton setTitle:DOING_BUTTON_TITLE forState:UIControlStateNormal];
                //self.edgesForExtendedLayout=UIRectEdgeNone;
                //self.automaticallyAdjustsScrollViewInsets=NO;
                /*
                [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(@50);
                    make.left.equalTo(@0);
                    make.right.equalTo(@0);
                    make.bottom.equalTo(@0);
                }];
                 */
                
                [self createTableView];
                
                /*
                [button addTarget:self
                           action:@selector(actionArchive)
                 forControlEvents:UIControlEventTouchUpInside];
                
                self.recordBtn = button;
                
                [self updateButtonStatus:displayMode];
                
                self.tableView.tableHeaderView = _searchBgView;
                 */
            }
            else
            {
                [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(self.tablewViewCurrentYPosition);
                    make.left.equalTo(@0);
                    make.right.equalTo(@0);
                    make.bottom.equalTo(@0);
                }];
                
                [self.tableView setContentInset:UIEdgeInsetsMake(-60, 0, 0, 0)];
                
                self.readButton.hidden = YES;
                self.unreadButton.hidden = YES;

                /*[button addTarget:self
                           action:@selector(actionSort)
                 forControlEvents:UIControlEventTouchUpInside];
                
                self.recordBtn = button;
                
                
                
                self.tableView.tableHeaderView = _searchBgView;*/
                 [self updateButtonStatus:displayMode];
            }
            
            if(displayMode == DisplayModePeople){
                self.readButton.hidden = NO;
                self.unreadButton.hidden = NO;
                [self.readButton setTitle:ALL_BUTTON_TITLE forState:UIControlStateNormal];
                [self.unreadButton setTitle:FAVORITES_BUTTON_TITLE forState:UIControlStateNormal];
            }

            
#endif
        }
    }
    
    if (visible)
    {
        //[self.tableView setContentOffset:CGPointMake(0, _searchBgView.frame.size.height) animated:NO];
        [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];

    }
}

- (void) showLoadingViewWhile
{
    
#if 1
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self ShowKnoteLoadingView];
        
    });
    
#endif
    
}

- (void) hideLoadingView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self HideKnoteLoadingView];
        
    });
}

-(void)smoothProgressBarTimerAction
{
    /*
    float progress = self.knoteProgressBar.progress + 0.010;
    
    int progressAsInteger = progress * 100;
    
    if(progressAsInteger >= 100)
    {
        progressAsInteger = 100;
    }
    */
    //self.knoteProgressBar.indicatorTextLabel.text = [NSString stringWithFormat:@"%i%@", progressAsInteger, @"%"];
    
    //[self.knoteProgressBar setProgress:progress];
}

// Will keep old reference and also add progress bar as a replacement.
- (void)ShowKnoteLoadingView
{
    /*
    if(!self.knoteProgressBar)
    {
        self.knoteProgressBar = [[YLProgressBar alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
        
        self.knoteProgressBar.type               = YLProgressBarTypeFlat;
        
        self.knoteProgressBar.progressTintColor  = [DesignManager knoteProgressBarTintColor];
        
        self.knoteProgressBar.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
        
        self.knoteProgressBar.indicatorTextLabel.textColor = [UIColor blackColor];
        self.knoteProgressBar.indicatorTextLabel.font = [UIFont fontWithName:self.knoteProgressBar.indicatorTextLabel.font.fontName size:10];
        
        self.knoteProgressBar.hideTrack = YES;
        self.knoteProgressBar.hideGloss = YES;
        self.knoteProgressBar.hideStripes = YES;
        
        [self.view addSubview:self.knoteProgressBar];
    }
     
    
    if(self.smoothProgressBarTimer)
    {
        [self.smoothProgressBarTimer invalidate];
    }
    
    self.smoothProgressBarTimer = [NSTimer scheduledTimerWithTimeInterval:0.3
                                                                   target:self
                                                                 selector:@selector(smoothProgressBarTimerAction)
                                                                 userInfo:nil
                                                                  repeats:YES];
    
    [self.knoteProgressBar setProgress:0.0 animated:NO];
    
     self.knoteProgressBar.hidden = NO   ;
     
     [self.tableView setUserInteractionEnabled:NO];
     
     */
    
    
    // Checking holding state with timer
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.observeHoldingTimer = [NSTimer scheduledTimerWithTimeInterval:LoadingObserverTime
                                                                target:self
                                                              selector:@selector(holdingObserver)
                                                              userInfo:Nil
                                                               repeats:NO];
    });
    
}

- (void)HideKnoteLoadingView
{
    
#if kPeopleProcess
    
    //self.knoteProgressBar.hidden = YES;
    
    //[self.smoothProgressBarTimer invalidate];
    
#else
    
    //[self.knoteProgressBar removeFromSuperview];
    
#endif
    
    [self.tableView setUserInteractionEnabled:YES];
    
    // Hide Search bar after refreshing
    if (self.displayMode == DisplayModePeople
        || self.displayMode == DisplayModePads)
    {
        if (self.tableView.contentOffset.y<_searchBar.frame.size.height-10)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //[self.tableView setContentOffset:CGPointMake(0, _searchBgView.frame.size.height) animated:YES];
                [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
            });

        }
    }
    
    // Process timer
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.observeHoldingTimer)
        {
            [self.observeHoldingTimer invalidate];
            self.observeHoldingTimer = Nil;
        }
        
    });
    
    
    
}

- (void) holdingObserver
{
    // Removing Observer
    
    [self hideLoadingView];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.observeHoldingTimer)
        {
            [self.observeHoldingTimer invalidate];
            self.observeHoldingTimer = Nil;
        }
        
    });
}

- (void) removedContactFromDataSource:(ContactsEntity*)contact;
{
    // Remove from data source also
    if ([self.peopleData count] > 0)
    {
        for (int i = 0 ;  i < [self.peopleData count] ; i ++ )
        {
            ContactsEntity* tempContact = [self.peopleData objectAtIndex:i];
            
            if ([tempContact.contact_id isEqualToString:contact.contact_id])
            {
                [self.peopleData removeObjectAtIndex:i];
                
                break;
            }
        }
    }
    
    if (self.searchMode)
    {
        // Remove from search result first
        
        if ([self.peopleSearchResults count] > 0)
        {
            for (int i = 0; i  < [self.peopleSearchResults count] ; i ++)
            {
                ContactsEntity* tempContact = [self.peopleSearchResults objectAtIndex:i];
                
                if ([tempContact.contact_id isEqualToString:contact.contact_id])
                {
                    [self.peopleSearchResults removeObjectAtIndex:i];
                    
                    break;
                }
            }
        }
    }
}

-(void) removedContact:(ContactsEntity*)contact
{
    NSLog(@"Removed Conact successfully");
    
    if (self.displayMode != DisplayModePeople)
    {
        return;
    }
    
    if (contact == Nil)
    {
        return;
    }
    
    DLog(@"Total People : %ld - searched people : %ld", (unsigned long)[self.peopleData count], (unsigned long)[self.peopleSearchResults count]);
    
    if (self.searchMode)
    {
        if ([self.peopleSearchResults count] > 0)
        {
            for (int i = 0 ;  i < [self.peopleSearchResults count] ; i ++ )
            {
                ContactsEntity* tempContact = [self.peopleSearchResults objectAtIndex:i];
                
                if ([tempContact.contact_id isEqualToString:contact.contact_id])
                {
                    [self deleteContact:contact.contact_id];
                    
                    NSDictionary *parameters = @{ @"removedContactId": contact.contact_id };
                    
                    [[AnalyticsManager sharedInstance] notifyContactWasDeletedWithParameters:parameters];
                    
                    contact.archived = @YES;
                    
                    [self.tableView tapped:nil];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSIndexPath *changeIndex = Nil;
                        
                        changeIndex = [NSIndexPath indexPathForRow:i inSection:0];
                        
                        [self.searchController.searchResultsTableView beginUpdates];
                        
                        [self.peopleSearchResults removeObjectAtIndex:changeIndex.row];
                        
                        [self removedContactFromDataSource:contact];
                        
                        [self.searchController.searchResultsTableView deleteRowsAtIndexPaths:@[changeIndex] withRowAnimation:UITableViewRowAnimationLeft];
                        
                        [self.searchController.searchResultsTableView endUpdates];
                        
                    });
                    
                    if (self.formSheetController)
                    {
                        [self.formSheetController dismissAnimated:YES
                                                completionHandler:^(UIViewController *presentedFSViewController) {
                            
                            [self reloadData];
                            
                        }];
                    }
                    else if (self.formSheetControl)
                    {
                        [self.formSheetControl dismissAnimated:YES
                                             completionHandler:^(UIViewController *presentedFSViewController) {
                            
                            [self reloadData];
                            
                        }];
                    }
                    
                    break;
                }
                
            }
        }
        
    }
    else
    {
        if ([self.peopleData count] > 0)
        {
            for (int i = 0 ;  i < [self.peopleData count] ; i ++ )
            {
                ContactsEntity* tempContact = [self.peopleData objectAtIndex:i];
                
                if ([tempContact.contact_id isEqualToString:contact.contact_id])
                {
                    [self deleteContact:contact.contact_id];
                    
                    NSDictionary *parameters = @{ @"removedContactId": contact.contact_id };
                    
                    [[AnalyticsManager sharedInstance] notifyContactWasDeletedWithParameters:parameters];
                    
                    contact.archived = @YES;
                    
                    [self.tableView tapped:nil];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSIndexPath *changeIndex = Nil;
                        
                        changeIndex = [NSIndexPath indexPathForRow:i inSection:0];
                        
                        [self.tableView beginUpdates];
                        
                        [self.peopleData removeObjectAtIndex:changeIndex.row];
                        
//                        [self removedContactFromDataSource:contact];
                        
                        [self.tableView deleteRowsAtIndexPaths:@[changeIndex] withRowAnimation:UITableViewRowAnimationLeft];
                        
                        [self.tableView endUpdates];
                        
                    });
                    
                    if (self.formSheetController)
                    {
                        [self.formSheetController dismissAnimated:YES
                                                completionHandler:^(UIViewController *presentedFSViewController) {
                            
//                            [self reloadData];
                            
                        }];
                    }
                    else if (self.formSheetControl)
                    {
                        [self.formSheetControl dismissAnimated:YES
                                             completionHandler:^(UIViewController *presentedFSViewController) {
                            
//                            [self reloadData];
                            
                        }];
                    }
                    
                    break;
                }
                
            }
        }
    }
    
}

#pragma mark - MCSwipeTableViewCellDelegate

// When the user starts swiping the cell this method is called
- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell {
     NSLog(@"Did start swiping the cell!");
}

// When the user ends swiping the cell this method is called
- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell {
     NSLog(@"Did end swiping the cell!");
}

// When the user is dragging, this method is called and return the dragged percentage from the border
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didSwipeWithPercentage:(CGFloat)percentage {
     NSLog(@"Did swipe with percentage : %f", percentage);
}

#if kPeopleProcess

- (void)contactsUpdateProgress:(NSInteger)totalCount
{
    if (_displayMode == DisplayModePeople)
    {
        /*
        [self.knoteProgressBar setProgress:0 animated:YES];
        
        if(self.knoteProgressBar.superview)
        {
            float progress = 0.0f;
            
            if ([ContactsEntity MR_countOfEntities]>0 && totalCount>0)
            {
                progress = [ContactsEntity MR_countOfEntities] / ((float)totalCount);
            }
            
            if (progress>=1)
            {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.knoteProgressBar.hidden = YES;
                    [self.smoothProgressBarTimer invalidate];
                });
            }
            else
            {
                self.knoteProgressBar.hidden = NO;
                
                [self.knoteProgressBar setProgress:progress animated:YES];
            }
        }
         */
    }
}
#endif
@end

// Lin - Added for Menu change sub task

#pragma mark - BMBMenuActionDelegate implemention

@implementation CombinedViewController (KnoteBMBDelegate)
-(void)loggingOutExtras
{
//        self.stack.hidden=YES;
//        [self.stack removeFromSuperview];
//        self.stack=nil;
//        [self.sideBar hideSideBarWithAnimation:NO];
//        [self.sideBar removeFromSuperview];
//        self.sideBar=nil;
}
- (void)BottomMenuActionIndex:(NSInteger)butIndex
{
//#if New_DrawerDesign
//    if (self.sideBar)
//    {
//        [self.sideBar hideSideBarWithAnimation:YES];
//    }
//#endif
//    if (butIndex < 3)
//    {
//        if(self.profileInfo.view.superview)
//        {
//            // Lin - Added to store Profile view's information on Server
//         
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                if ([self.profileInfo respondsToSelector:@selector(SaveProfileInfo)])
//                {
//                    [self.profileInfo SaveProfileInfo];
//                }
//                
//            });
//            
//            // Lin - Ended
//            
//            [self.profileInfo removeFromParentViewController];
//            [self.auxiliarScrollViewForProfileInfoView removeFromSuperview];
//            [self.profileInfo.view removeFromSuperview];
//            
//            self.profileInfo = nil;
//        }
//    }
//    
//    self.expIndexPath = nil;
//    
//    self.justLoaded = NO;
//    
//    [self UpdateNavigationBarIndex:butIndex];
//    
//#if !New_DrawerDesign
//    
//    [self.bottomMenuBar UpdateButtonStateIndex:butIndex];
//    
//#endif
//    
//    // Close all notification view here
//    
//    [self hideLoadingView];
//    
//    // Will resolve reorder flag for recent, people view
//    
//    if (butIndex !=2 )
//    {
//        self.tableView.isReordering=NO;
//        self.tableView.isReorderingAll = NO;
//        self.tableView.editing=NO;
//    }
//    
//    if (!self.firstLoad)
//    {
//#if !New_DrawerDesign
//        self.bottomMenuBar.frame = CGRectMake(0, self.view.frame.size.height - self.bottomMenuBar.frame.size.height, self.bottomMenuBar.frame.size.width, self.bottomMenuBar.frame.size.height);
//#endif
//    }
//    
//    /*
//    if (self.padProgressBar)
//    {
//        [self.padProgressBar setHidden:YES];
//    }
//    */
//    
//    switch (butIndex) {
//            
//        case 1:
//            self.isUpdatedTopic=YES;
//#if !New_DrawerDesign
//            self.bottomMenuBar.m_btnPads.userInteractionEnabled=YES;
//#else
////            self.stack.hidden=NO;
//#endif
//            [self OpenPeople];
//           
//            
//            break;
//            
//        case 2:
//#if !New_DrawerDesign
//            self.bottomMenuBar.m_btnPads.userInteractionEnabled=NO;
//#else
////            self.stack.hidden=NO;
//#endif
//            [self OpenPads];
//            
//            break;
//            
//        case 3:
//            self.isUpdatedTopic=YES;
//#if !New_DrawerDesign
//            self.bottomMenuBar.m_btnPads.userInteractionEnabled=YES;
//#else
////             self.stack.hidden=YES;
//#endif
//
//            [self OpenSettings];
//           
//            break;
//    }
//    
}

@end

#pragma mark - Navigation MenuActionDelegate implemention

@implementation CombinedViewController (KnoteNMDelegate)

- (void)NavigationMenuActionIndex:(NSInteger)butIndex
{
    switch (butIndex) {
        case ARCHIVE_MENU_INDEX:
            
            [self actionArchive];
            
            break;
            
        case REORDER_MENU_INDEX:
            
            [self actionReorder];
            
            break;
    }
    
}

@end

#pragma mark - Navigation MuteAction implemention

@implementation CombinedViewController (KnoteNMTDelegate)

- (void)NavigationMuteManage
{
    if (self.navigationMuteMenu)
    {
        if (self.showMutedItems)
        {
            
            [self.navigationMuteMenu.m_btnMute setBackgroundImage:[UIImage imageNamed:@"speaker_normal"] forState:UIControlStateNormal];
            [self.navigationMuteMenu.m_btnMute animated];
            
        }
        else
        {
            [self.navigationMuteMenu.m_btnMute setBackgroundImage:[UIImage imageNamed:@"speaker_selected"] forState:UIControlStateNormal];
            [self.navigationMuteMenu.m_btnMute animated1];
            
        }
        
        self.showMutedItems = !self.showMutedItems;
        
        self.recent_showMutedItems_Flag = self.showMutedItems;
        
        [self actionSpeaker];
    }
}

@end

#pragma mark - Navigation Sort ActionDelegate implemention

@implementation CombinedViewController (KnoteNSMDelegate)

- (void)NavigationSortAction
{
    [self actionSort];
}

@end

#pragma mark - PadOwnerCellDelegate implemention

@implementation CombinedViewController (PadOwnerCellDelegate)

//- (void)CloseContactOwner
//{
//    NSLog(@"Will update Pad UI here");
//    self.tablewViewCurrentYPosition = [NSNumber numberWithInt:TABLEVIEW_INITIAL_Y_POSITION];
//    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.tablewViewCurrentYPosition);
//        make.left.equalTo(@0);
//        make.right.equalTo(@0);
//        make.bottom.equalTo(@0);
//    }];
//    [self configureQuickFilterButton];
//    
//    [self.peopleFilterBackgroundView removeFromSuperview];
//    
//    self.showOwner = NO;
//    self.currentContact = nil;
//    _searchMode=NO;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,
//                                             (unsigned long)NULL), ^(void){
//        [self fetchedAllPeopleTopics:self.showArchived];
//    });
//    
//    [self updateTopicsData];
//    [self.searchController setActive:NO animated:YES];
//    [self scrollUp];
//}


@end

#pragma mark - ContactCellDelegate implemention

@implementation CombinedViewController (ContactCellDelegate)

- (void)ShowProfile:(ContactsEntity*)contact
{
    // Lin - Added to
    /*
     
     People view : Show profile
     
     Will show remove button : Remove from Contact
     
     */
    // Lin - Ended
    
    MyProfileController *profile = [[MyProfileController alloc] initWithContact:contact];
    
//    [profile setProfile_remove_buttonType:RemoveFromContact];
    [profile setProfile_remove_buttonType:RemoveFromNone];
    
    profile.delegate = self;
    
    __block MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:profile];
    
    self.formSheetControl = formSheet;
    
    CGFloat ctlHeight = self.view.bounds.size.height - 60;
    
    formSheet.presentedFormSheetSize = CGSizeMake(300, ctlHeight);
    
    formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
    formSheet.shadowRadius = 2.0;
    formSheet.shadowOpacity = 0.3;
    formSheet.shouldDismissOnBackgroundViewTap = YES;
    [formSheet setPortraitTopInset:20];
    [formSheet setLandscapeTopInset:20];
    
    formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
        // Passing data
    };
    
    [MZFormSheetController sharedBackgroundWindow].formSheetBackgroundWindowDelegate = self;
    
    [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
    }];
}
#if kCombinedNewFeature
- (void) showSearchLeftButton
{
    self.recordBtn.alpha = 0.0;
    if (!_isUpdateSearch)
    {
        self.view.userInteractionEnabled=NO;
        return;
    }
    
    _isUpdateSearch=NO;
    self.view.userInteractionEnabled=NO;
    [self.searchBgView addSubview:self.recordBtn];
    
    [UIView animateKeyframesWithDuration:.2 delay:0.3 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        self.recordBtn.alpha = 0.8;
        //[self.recordBtn setFrame:CGRectMake(14, 18, 22, 22)];
        [self.recordBtn setFrame:CGRectMake(_searchBgView.frame.size.width/2 -22/2, 18, 22, 22)];

        
    } completion:^(BOOL finished) {
        self.recordBtn.alpha = 1.0;
        
        _isUpdateSearch=YES;
        self.view.userInteractionEnabled=YES;
    }];
    
    
}
- (void) hiddenSearchLeftButton
{
    if (!_isUpdateSearch)
    {
        self.view.userInteractionEnabled=NO;
        return;
    }
    _isUpdateSearch=NO;
    self.view.userInteractionEnabled=NO;
    [UIView animateKeyframesWithDuration:.2 delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
        //[self.recordBtn setFrame:CGRectMake(14, 18, 10, 22)];
        [self.recordBtn setFrame:CGRectMake(_searchBgView.frame.size.width/2 -22/2, 18, 22, 22)];

        self.recordBtn.alpha = 0.0;
    } completion:^(BOOL finished) {
        _isUpdateSearch=YES;
        self.view.userInteractionEnabled=YES;

    }];
}
#endif

#pragma mark - UISearchBar delegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
#if 0
    if (self.recordBtn.alpha < 0.9)
    {
        [UIView animateKeyframesWithDuration:.3 delay:0.3 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
            self.recordBtn.alpha = 0.8;
            [self.recordBtn setFrame:CGRectMake(_searchBgView.frame.size.width/2 -22/2, 18, 22, 22)];

            [[_searchBar superview] addSubview:self.recordBtn];

        } completion:^(BOOL finished) {
            self.recordBtn.alpha = 1.0;
        }];
        [UIView animateKeyframesWithDuration:.3 delay:0 options:UIViewKeyframeAnimationOptionLayoutSubviews animations:^{
            [_searchBar setFrame:CGRectMake(40, 0, CGRectGetWidth([UIScreen mainScreen].bounds)-40, 44)];
        } completion:^(BOOL finished) {
        }];
    }
#endif
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
#if kCombinedNewFeature
    
    self.searchCancelClicked = NO;
    
    [self hiddenSearchLeftButton];
    
#endif
//    CGRect  menuBarFrame = CGRectMake(0, [AppDelegate sharedDelegate].window.frame.size.height-BottomMenuHeight, 320, BottomMenuHeight);
//    [self.bottomMenuBar setFrame:menuBarFrame];
#if !New_DrawerDesign
    self.bottomMenuBar.hidden = YES;
#endif
    
    return YES;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
#if kCombinedNewFeature
    self.searchCancelClicked = YES;
#endif
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"searchBarCancelButtonClicked");
    self.searchBar.showsCancelButton = NO;
    self.searchController.displaysSearchBarInNavigationBar = NO;
    [self.searchDisplayController setActive:NO];
    self.navigationItem.titleView = nil;

    
#if kCombinedNewFeature
    self.searchCancelClicked = YES;
    [self showSearchLeftButton];
#endif
    
    if (self.displayMode == DisplayModePeople)
    {
        [self UpdateNavigationBarIndex:1];
#if !New_DrawerDesign
        [self.bottomMenuBar UpdateButtonStateIndex:1];
#endif
    }
    else if (self.displayMode == DisplayModePads)
    {
        [self UpdateNavigationBarIndex:2];
#if !New_DrawerDesign
        [self.bottomMenuBar UpdateButtonStateIndex:2];
#endif
    }
    else if(self.displayMode == DisplayModeSettings)
    {
        [self UpdateNavigationBarIndex:3];
#if !New_DrawerDesign
        [self.bottomMenuBar UpdateButtonStateIndex:3];
#endif
    }

    
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
#if kCombinedNewFeature
    if (!_searchMode)
    {
        [self showSearchLeftButton];
    }
#endif
//    CGRect  menuBarFrame = CGRectMake(0, self.view.frame.size.height- 64 - BottomMenuHeight, 320, BottomMenuHeight);
//    [self.bottomMenuBar setFrame:menuBarFrame];
#if !New_DrawerDesign
    self.bottomMenuBar.hidden = NO;
#endif

    return YES;
}

#if kContactUserFetchedController

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {

        BOOL sortFlag = YES,archiveFlag = NO;

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"archived == %@ && isMe == NO", @(archiveFlag)];

        NSString *sortFields = sortFlag ? @"name:YES" : @"position:NO,total_topics:YES";
        _fetchedResultsController = [ContactsEntity MR_fetchAllSortedBy:sortFields ascending:YES withPredicate:predicate groupBy:nil delegate:self];
    }
    
    return _fetchedResultsController;
}


/**
 Delegate methods of NSFetchedResultsController to respond to additions, removals and so on.
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    
    if ([self needUpdateTableView:controller]) {
        // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
        self.tableView.userInteractionEnabled = NO;
        
        [self.tableView beginUpdates];
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    if ([self needUpdateTableView:controller]) {
        
        UITableView *tableView = self.tableView;
        
        switch(type) {
            case NSFetchedResultsChangeInsert:
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                if (_displayMode == DisplayModePeople  ){
                    [self tableView:_tableView cellForRowAtIndexPath:indexPath];
                }
                //            [self configureCell:(RecipeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
                break;
                
            case NSFetchedResultsChangeMove:
                [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    if ([self needUpdateTableView:controller]) {
        
        switch(type) {
            case NSFetchedResultsChangeInsert:
                NSLog(@"Knotable: NSFetchedResultsChangeInsert");
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                NSLog(@"Knotable: NSFetchedResultsChangeDelete");
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeUpdate:
                NSLog(@"Knotable: NSFetchedResultsChangeUpdate");
                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
            case NSFetchedResultsChangeMove:
                NSLog(@"Knotable: NSFetchedResultsChangeMove");
//                [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
            default:
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    
    // The fetch controller has sent all current change notifications,
    // so tell the table view to process all updates.
    if ([self needUpdateTableView:controller]) {
        @try {
            [_tableView endUpdates];
        }
        @catch (NSException *exception) {
            [self.tableView removeFromSuperview];
            [self createTableView];
            [self reloadData];
        }
        @finally {
        }
        self.tableView.userInteractionEnabled = YES;
    }
}


#endif


@end
