//
//  MMessageListController.m
//  Mailer
//
//  Created by Martin Ceperley on 9/20/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MMessageListController.h"

#import "MDetailViewController.h"
#import "MDataManager.h"
#import "MMailManager.h"
#import "Message.h"
#import "Folder.h"
#import "MMessageCell.h"
#import "MCircleView.h"
#import "MStatusView.h"
#import "MTableFooterView.h"
#import "MCarouselViewController.h"
#import "MSignInViewController.h"
#import "MDesignManager.h"
#import "MControllerManager.h"
#import "MHomeViewController.h"
#import "MAppDelegate.h"
#import "MCyclingViewController.h"
#import "Debug.h"
#import "AccountInfo.h"
#import "MMailHeaderIndicateView.h"
#import "MMailListSessionTableViewController.h"

//Modified by 3E ------START------

//const int MESSAGE_CELLS_PER_LOAD = 20;
const int MESSAGE_CELLS_PER_LOAD = 10;

//Modified by 3E ------END------

const int PULL_TO_LOAD_REQUIREMENT = 50;

@interface MMessageListController ()<JZSwipeCellDelegate,MSwipedButtonManagerDelegate>
{
    BOOL _loadingMore;
    BOOL _exhaustedCoreData;
    UIAlertView *_authAlert;
    NSInteger _retainCount;
}

@property (nonatomic, readonly) BOOL isIdle;
@property (nonatomic, strong) NSMutableArray *fetchineQueue;
@property (nonatomic, strong) MMailHeaderIndicateView *headerView;
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

@implementation MMessageListController

@synthesize statusItem;
@synthesize statusView;
@synthesize refreshButton;
@synthesize lastUpdated;
@synthesize updateStatusTimer;
@synthesize loadingIndicator;
@synthesize refresh,isadding;



- (void)awakeFromNib
{
    [super awakeFromNib];
    
    ////NSLog(@"MasterViewController awakeFromNib");
    //[self fetchedResultsController];
    ////NSLog(@"MasterViewController done awakeFromNib");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commingNewMessage:) name:NEED_SHOW_NEWEMAILS_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showStatusMessage:) name:SHOW_STATUS_NOTIFICATION object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[MSwipedButtonManager sharedManager] setHidden:NO];
    [MSwipedButtonManager sharedManager].delegate = self;

    _visible = YES;
    _isLoaded = NO;
    _isIndicating = NO;
    initialVal = 0;
    
    _deleteIndexArray = [NSMutableArray arrayWithArray:nil];
    _deleteMessageArray = [NSMutableArray arrayWithArray:nil];
    _archiveIndexArray = [NSMutableArray arrayWithArray:nil];
    _archiveIndexPathArray  = [NSMutableArray arrayWithArray:nil];
    
//    [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];

    //self.toolbar.barPosition = UIBarPositionTopAttached;
    [self.navigationController setToolbarHidden:NO animated:NO];
    
     self.fetchedResultsController.delegate = self;
    
    //Modified by 3E ------START------
    
    [self.navigationController.toolbar setBarStyle:UIBarStyleBlack];
    self.navigationController.toolbar.translucent = YES;
    [self.navigationController.toolbar setBackgroundImage:[UIImage imageNamed:@"bottom"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    _markUnread=YES;
    
    //Modified by 3E ------END------
    
    [self updateUnreadCount];
    
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    if (indexPath) {
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell setSelected:NO animated:NO];
        [cell setHighlighted:NO animated:NO];
    }
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:YES forKey:@"isList"];
    [defaults synchronize];
    

    
//    [swipeBut setTitle:@"+" forState:UIControlStateNormal];
//    swipeBut.titleLabel.font = [UIFont boldSystemFontOfSize:50];
//    swipeBut.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
//    swipeBut.tintColor = [UIColor whiteColor];
    
    
//    [swipeBut addTarget:self action:@selector(composeNewMessage) forTouchAndHoldControlEventWithTimeInterval:0.2];

    
//    [swipeBut addTarget:self
//                 action:@selector(composeNewMessage)
//       forControlEvents:UIC];
    
//    swipeBut.backgroundColor = [MDesignManager patternImage];
    
//    swipeBut.frame = CGRectMake(([[UIApplication sharedApplication] keyWindow].frame.size.width/2)-35, [[UIApplication sharedApplication] keyWindow].frame.size.height-100, 70, 70);
    



    
//    self.navigationItem.titleView.frame = CGRectMake(0, 0, 200, 200);
//    self.navigationItem.titleView.backgroundColor = [UIColor redColor];
    
//    CGFloat verticalOffset = -1;
//    [[UINavigationBar appearance] setTitleVerticalPositionAdjustment:verticalOffset forBarMetrics:UIBarMetricsDefault];
    
//    - (CGFloat)titleVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefault;
    
//    [[UINavigationBar appearance] titleVerticalPositionAdjustmentForBarMetrics:UIBarMetricsDefault];

    
     [self updateUnreadCount];
    self.fetchineQueue = [NSMutableArray new];
   

}
-(void) showStatusMessage:(NSNotification *)notification
{
    NSString *str = notification.object;

    dispatch_async(dispatch_get_main_queue(), ^(void) {
        if (!self.notification) {
            self.notification = [CWStatusBarNotification new];
            self.notification.notificationLabelBackgroundColor = [UIColor colorWithWhite:0.96 alpha:1];
            self.notification.notificationLabelTextColor = [UIColor blackColor];
            self.notification.notificationAnimationInStyle = CWNotificationAnimationStyleBottom;
        }

        [self.notification displayNotificationWithMessage:str forDuration:3];    });

}
-(void)realGetMessage:(UIButton *)sender
{
    MMailHeaderIndicateView *headerView = (MMailHeaderIndicateView *)[sender superview];
    AccountInfo *actInfo  = headerView.actInfo;
    [actInfo syncMessageFlagsFolder:actInfo.account.inbox modSeq:actInfo.account.inbox.modSeq completion:^(NSError* error){
        //NSLog(@"Done syncing after loading messages");
        //                    onSuccess(newMessages.count);
        [actInfo fetchMissingMessageContents];
    }];
}
- (void)removeHeaderIndicateView:(AccountInfo *)actInfo
{
    self.tableView.tableHeaderView = nil;
    [self.fetchineQueue addObject:actInfo];
}
-(void)commingNewMessage:(NSNotification *)notification
{
    AccountInfo *actInfo = notification.object;
    self.headerView.actInfo = actInfo;
    if ([actInfo.commingMessages count]>0) {
        NSString *str = [NSString stringWithFormat:@"Get %lu new mails",(unsigned long)[actInfo.commingMessages count]];
        [self.headerView.indicateButton addTarget:self action:@selector(realGetMessage:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView.indicateButton setTitle:str forState:UIControlStateNormal];
        [UIView animateWithDuration:1 animations:^{
            self.tableView.tableHeaderView=self.headerView;
            self.tableView.contentOffset = CGPointMake(0, -70);
            [self.headerView setNeedsUpdateConstraints];
        } completion:^(BOOL finished) {
            [self performSelector:@selector(removeHeaderIndicateView:)withObject:actInfo afterDelay:5];
        }];
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];

    _isIndicating = YES;
    _retainCount = 0;
    
    
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(fetchingMail) name:FETCHING_NEW_MAIL_NOTIFICATION object:nil];
    [notificationCenter addObserver:self selector:@selector(justUpdated) name:FETCHED_NEW_MAIL_CONTENT_NOTIFICATION object:nil];
    [notificationCenter addObserver:self selector:@selector(errorFetchingMail) name:ERROR_FETCHING_NEW_MAIL_NOTIFICATION object:nil];
    [notificationCenter addObserver:self selector:@selector(errorOccurred:) name:ERROR_NOTIFICATION object:nil];
    [notificationCenter addObserver:self selector:@selector(progressFetchingMail:) name:PROGRESS_FETCHING_NEW_MAIL_NOTIFICATION object:nil];
    
    [notificationCenter addObserver:self selector:@selector(justUpdated) name:@"stopReloading" object:nil];
//    [notificationCenter addObserver:self selector:@selector(loadMoreMessages) name:@"LoadingData" object:nil];
    [notificationCenter addObserver:self selector:@selector(removeTableViewFooter) name:@"RemovingTableLoader" object:nil];
    
    self.navigationItem.title = _modeTitle = _shortMode ? @"Short" : (_longMode ? @"Long" : @"Inbox");
    self.refresh.tintColor = [MDesignManager highlightColor];
    self.refreshControl = self.refresh;
    
    //_galleryItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startGallery)];
    
    //Modified by 3E ------START------
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    if (height == 1024) {
        
        self.tableView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"topbar"]];
    }
    else{
        
        self.tableView.backgroundColor = [MDesignManager patternImage];
    }
    
    _galleryItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"scan.png"] style:UIBarButtonItemStylePlain target:self action:@selector(startGallery)];
    
    //Modified by 3E ------END------
    
    _galleryItem.tintColor = [MDesignManager highlightColor];
    
    CGRect statusFrame = CGRectMake(0, 0, self.view.frame.size.width-10, 20);
    self.statusView = [[MStatusView alloc] initWithFrame:statusFrame];
    
//    self.statusView.backgroundColor = [UIColor redColor];
    
    self.statusItem = [[UIBarButtonItem alloc] initWithCustomView:statusView];
    
    self.refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshPressed)];
    
    refreshButton.tintColor = [MDesignManager highlightColor];
    
    self.loadingIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.loadingIndicator.hidesWhenStopped = NO;
    
    
    //statusItem.width = 50.0;
    
    //Location Updtes
    
     MAppDelegate *delegate = (MAppDelegate *)[[UIApplication sharedApplication]delegate ];
    
    if (delegate.locationStr != nil) {
         self.statusView.statusLabel.text = [NSString stringWithFormat:@"%@",delegate.locationStr];
    }
//    if (![delegate.locationStr isEqualToString:[NSString stringWithFormat:@"(null)"]]){
//        
//    }
    
    
   
   
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    //self.toolbarItems = @[refreshButton, statusItem];
    
    ////NSLog(@"toolbar items: %@", self.toolbarItems );
    ////NSLog(@"isToolbarHidden: %d", self.navigationController.toolbarHidden );
    
//    UIBarButtonItem *composeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(composeNewMessage)];
    
//    self.toolbarItems = @[spacer, statusItem, spacer, composeButton];
    
    self.toolbarItems = @[spacer, statusItem, spacer];

    //self.navigationItem.rightBarButtonItem = composeButton;
    self.navigationItem.rightBarButtonItem = _galleryItem;
    
    _tableFooterView = [[MTableFooterView alloc] initWithFrame:CGRectMake(0,0,self.view.frame.size.width,50)];
    self.tableView.delegate = self;
    
    if (_fetchingProgressView == nil) {
        _fetchingProgressView = (UIProgressView *)[self.navigationController.toolbar viewWithTag:42];
    }
    
    if(_fetchingProgressView == nil){
        
        _fetchingProgressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
        _fetchingProgressView.tag = 42;
        _fetchingProgressView.progressTintColor = [MDesignManager highlightColor];
        
        //Modified by 3E ------START------
        _fetchingProgressView.trackTintColor = [MDesignManager tintColorUpdated];
        //Modified by 3E ------END------
        
        _fetchingProgressView.progress = 0.0;
        _fetchingProgressView.hidden = YES;
        
        CGRect frame = _fetchingProgressView.frame;
        frame.size.width = self.navigationController.toolbar.bounds.size.width;
        _fetchingProgressView.frame = frame;
        [self.navigationController.toolbar addSubview:_fetchingProgressView];
        
        //[NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(fakeProgress:) userInfo:nil repeats:YES];
    }
    
    // ////NSLog(@"[MMailManager sharedManager].isFetching = %d",[MMailManager sharedManager].isFetching);
    
    if([MMailManager sharedManager].isFetching){
        
        _fetchingProgressView.progress = 0.0;
        _fetchingProgressView.hidden = NO;
        
        statusView.statusLabel.hidden = NO;
        statusView.statusLabel.text = @"Checking for messages";
        
//        MAppDelegate *delegate = (MAppDelegate *)[[UIApplication sharedApplication]delegate ];
//        if ([delegate.locationStr length]) {
//            
//            statusView.statusLabel.text = [NSString stringWithFormat:@"Checking for messages - %@",delegate.locationStr];
//        }
        
    }
    
    // &&&&&&&&&&&&&&&     Need Testing   &&&&&&&&&&&&&&&&
    //    else{
    //        _fetchingProgressView.progress = 0.0;
    //        _fetchingProgressView.hidden = YES;
    //    }
    //    [self.navigationItem setHidesBackButton:NO animated:YES];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"paper_clip.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
    
    self.navigationItem.leftBarButtonItem = backButton;
   
    
    //    [self.tableView reloadData];
    self.fetchedResultsController.delegate = self;
    self.headerView = [[MMailHeaderIndicateView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40)];

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

//    [self performSelector:@selector(newMail) withObject:nil afterDelay:2.0];
    
    _isFromDidApear = YES;
    [[MSwipedButtonManager sharedManager] setHidden:NO];
}

//-(void)newMail{
//    [[MMailManager sharedManager] beginFetchingMail];
//}




-(IBAction)buttonClick:(id)sender{
    
//    ////NSLog(@"************  buttonClick  **************");
    
    [self composeNewMessage];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];

    if (idleTimer) {
        
        [idleTimer invalidate];
        idleTimer = nil;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[MSwipedButtonManager sharedManager] setHidden:YES];
    [MSwipedButtonManager sharedManager].delegate = nil;

    _visible = NO;
    _markUnread=NO;
    _isLoaded = NO;
    

//    if([spinner isDescendantOfView:[self view]]) {
    
    if (self.tableView.tableFooterView) {
            
        //        ////NSLog(@"Present");
        
        [_tableFooterView.loader stopAnimating];
        self.tableView.tableFooterView = nil;
        _loadingMore = NO;

    }
    
    if ([undoBut isDescendantOfView:[[UIApplication sharedApplication] keyWindow]]){
        
        defaults = [NSUserDefaults standardUserDefaults];
        [defaults setBool:NO forKey:@"isList"];
        [defaults synchronize];
        
        [undoBut removeFromSuperview];
        
        [self performSelectorOnMainThread:@selector(deleteMessages:) withObject:_deleteIndexArray waitUntilDone:YES];
        
//        [self performSelectorOnMainThread:@selector(deleteMessages:) withObject:_deleteMessageArray waitUntilDone:YES];
        
        
//        [self deleteMessages:_deleteIndexArray];
        
//        [self performSelectorOnMainThread:@selector(archiveMessages:) withObject:_archiveIndexArray waitUntilDone:YES];
        
        [_deleteIndexArray removeAllObjects];
        [_archiveIndexArray removeAllObjects];
        [_archiveIndexPathArray removeAllObjects];
        [_deleteMessageArray removeAllObjects];
    }
    

    //[self.navigationController setToolbarHidden:YES animated:animated];
    
    /*
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];

    [notificationCenter removeObserver:self name:FETCHING_NEW_MAIL_NOTIFICATION object:nil];
    [notificationCenter removeObserver:self name:FETCHED_NEW_MAIL_NOTIFICATION object:nil];
    [notificationCenter removeObserver:self name:ERROR_FETCHING_NEW_MAIL_NOTIFICATION object:nil];
    [notificationCenter removeObserver:self name:ERROR_NOTIFICATION object:nil];
    [notificationCenter removeObserver:self name:PROGRESS_FETCHING_NEW_MAIL_NOTIFICATION object:nil];

    if (_fetchingProgressView != nil) {
        _fetchingProgressView.hidden = YES;
    }
     */
    NSNotificationCenter* notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter removeObserver:self name:NEED_SHOW_NEWEMAILS_NOTIFICATION object:nil];
    [notificationCenter removeObserver:self name:SHOW_STATUS_NOTIFICATION object:nil];
}

#pragma mark - Idle Timer

 //Modified by 3E -------START-------

- (void)resetIdleTimer {
    
//    ////NSLog(@"idleTimer = %@",idleTimer);
    
    if (!idleTimer) {
        
        isadding = NO;
        idleTimer = [NSTimer scheduledTimerWithTimeInterval:10
                                                      target:self
                                                    selector:@selector(idleTimerExceeded)
                                                    userInfo:nil
                                                     repeats:NO];
    }
    else {
        if (fabs([idleTimer.fireDate timeIntervalSinceNow]) < 10-1.0) {
            [idleTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        }
    }
}

- (void)idleTimerExceeded {
    
    idleTimer = nil;
    
//    ////NSLog(@"_loadingMore = %d",_loadingMore);
//    ////NSLog(@"isadding = %d",isadding);
    
    if (!_loadingMore ) {
        
        if (!isadding) {
            
            if (!_isIndicating) {
                
                if (initialVal >0) {
               
//                 ////NSLog(@"##################  spinner  ##################");
            
//               [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
                
                _isIndicating = YES;
                
                }
                
                initialVal = 1;
            
//                [self loadMoreMessages];
                _isIdle = YES;
                [self performSelector:@selector(loadMoreMessages) withObject:nil afterDelay:0.1];

            }

//            [self loadMoreMessages];
            
        }
        
        [self resetIdleTimer];

    }
}

- (UIResponder *)nextResponder {
    
   
         [self resetIdleTimer];
   
    return [super nextResponder];
}

 //Modified by 3E -------END-------

#pragma mark - Idle Timer END

- (void) updateUnreadCount
{
    Account *account = [[MMailManager sharedManager] getCurrentAccount];
    
    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
    request.resultType = NSCountResultType;
//    request.predicate = [NSPredicate predicateWithFormat:@" account = %@ AND read = NO",account];
    
    request.predicate = [NSPredicate predicateWithFormat:@" account = %@ AND read = NO AND NOT (passed=YES OR processed=YES OR archive = YES)",account];
    
    
    NSError *error;
    //NSArray *array = [[MDataManager sharedManager].managedObjectContext executeFetchRequest:request error:&error];
    //NSNumber *count = [array firstObject];
    
    NSUInteger count = [[MDataManager sharedManager].managedObjectContext countForFetchRequest:request error:&error];
    if(count == NSNotFound) {
        //Handle error
    }

    ////NSLog(@"updateUnreadCount result: %lu", (unsigned long)count);
    //NSString* folderName = [[MMailManager sharedManager].currentFolder.name capitalizedString];
    
    if (count > 0) {
        
        self.navigationItem.title = [NSString stringWithFormat:@"%@ (%lu)", _modeTitle, (unsigned long)count];
    }
    else {
        self.navigationItem.title = _modeTitle;
    }
    
}

- (void) updateLastUpdatedLabel
{
    if (self.lastUpdated == nil) {
        self.statusView.statusLabel.text = @"";
        return;
    }
    
    NSTimeInterval seconds = round([self.lastUpdated timeIntervalSinceNow] * -1.0);
    ////NSLog(@"time interval is %f", seconds);

    NSString* relativeTime = @"just now";
    if(seconds >= 60.0){
        int minutes = (int)round(seconds/60.0);
        if (minutes >= 60) {
            int hours = (int)round( (double)minutes/60.0);
            if (hours >= 24) {
                
                int days = (int)round( (double)hours/24.0);
                relativeTime = [NSString stringWithFormat:@"%d day%@ ago", days, days == 1 ? @"" : @"s"];
            } else {
                relativeTime = [NSString stringWithFormat:@"%d hour%@ ago", hours, hours == 1 ? @"" : @"s"];
        }
        } else {
            relativeTime = [NSString stringWithFormat:@"%d minute%@ ago", minutes, minutes == 1 ? @"" : @"s"];
        }
        
    }
    
    self.statusView.statusLabel.text = [NSString stringWithFormat:@"Last updated %@", relativeTime];
    
    MAppDelegate *delegate = (MAppDelegate *)[[UIApplication sharedApplication]delegate ];
    if ([delegate.locationStr length]) {
        
        self.statusView.statusLabel.text = [NSString stringWithFormat:@"Last updated %@  -  %@",relativeTime,delegate.locationStr];
    }
    
}

- (void) setupRefreshControlActive:(BOOL)isActive
{
    if(isActive){
        
        [self.refresh beginRefreshing];
    }
    else {
        
        [self.refresh endRefreshing];
    }
}

- (void) justUpdated {
    
//    _loadingMore = NO;
    
    _fetchingNewMail = NO;
    self.lastUpdated = [NSDate date];
    [self updateLastUpdatedLabel];
    
    _fetchingProgressView.hidden = YES;
    [_fetchingProgressView setProgress:0.0 animated:NO];
    
    MAppDelegate *delegate = (MAppDelegate *)[[UIApplication sharedApplication]delegate];
    delegate.ispulled = NO;
    
    [self setupRefreshControlActive:NO];

    if(self.updateStatusTimer == nil){
        self.updateStatusTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(updateLastUpdatedLabel) userInfo:nil repeats:YES];
    } else{
        [self.updateStatusTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:-60.0]];
    }
    
    isadding = NO;
    
}

- (void) fetchingMail {
    
    _fetchingNewMail = YES;
    
    _fetchingProgressView.progress = 0.0;
    _fetchingProgressView.hidden = NO;
    
    self.statusView.statusLabel.hidden = NO;
    self.statusView.statusLabel.text = @"Checking for messages";
    
    
//    MAppDelegate *delegate = (MAppDelegate *)[[UIApplication sharedApplication]delegate ];
//    if ([delegate.locationStr length]) {
//        
//        self.statusView.statusLabel.text = [NSString stringWithFormat:@"Checking for messages  -  %@",delegate.locationStr];
//    }


}

- (void) errorFetchingMail {
    
    _fetchingNewMail = NO;
    //self.toolbarItems = @[refreshButton, statusItem];
    //[self.loadingIndicator stopAnimating];
    self.statusView.statusLabel.text = @"There was a problem checking for messages";
    //[self.refresh endRefreshing];
    [self setupRefreshControlActive:NO];
    
    MAppDelegate *delegate = (MAppDelegate *)[[UIApplication sharedApplication]delegate];
    delegate.ispulled = NO;

}

- (void) refreshPressed {
    
    [_tableFooterView.loader stopAnimating];
    self.tableView.tableFooterView = nil;
    
    ////NSLog(@"refreshPressed");
//    [[MMailManager sharedManager] fetchNewMail];
    
    if (_fetchingProgressView.hidden) {

    [[MMailManager sharedManager] stopFetchingMail];
    
    MAppDelegate *delegate = (MAppDelegate *)[[UIApplication sharedApplication]delegate];
    delegate.ispulled = YES;
    
    [self clearDataBase];
        
    }
    else{
         [[MMailManager sharedManager] fetchNewMail];
    }
}

- (IBAction) refreshPulled:(id)sender
{
    //Working...
    
    if (_fetchingProgressView.hidden) {
        
        if ([_tableFooterView.loader isAnimating]) {
            [_tableFooterView.loader stopAnimating];
            self.tableView.tableFooterView = nil;

        }
        
        
        [[MMailManager sharedManager] stopFetchingMail];
        
        MAppDelegate *delegate = (MAppDelegate *)[[UIApplication sharedApplication]delegate];
        delegate.ispulled = YES;
        [self setupRefreshControlActive:YES];
        
            [[MMailManager sharedManager] fetchNewMail];
        
//        [self clearDataBase];
    }
    else{
        
        [[MMailManager sharedManager] fetchNewMail];
    }
}

-(void)ballRefreshAction{
    
    if ([_tableFooterView.loader isAnimating]) {
        
        [_tableFooterView.loader stopAnimating];
        self.tableView.tableFooterView = nil;
       
    }
    
    
    dispatch_async(dispatch_queue_create("myqueue3", 0), ^{
        
        [[MMailManager sharedManager] stopFetchingMail];
        
        [[MMailManager sharedManager] fetchNewMail];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
             [self performSelector:@selector(removeLoaderFromMore) withObject:nil afterDelay:0.2
              ];
        });
        
    });

    
    
    
   
    
   
    
}

-(void)clearDataBase{
    
    MDataManager *dataManager = [MDataManager sharedManager];
    
    NSManagedObjectContext* context = dataManager.managedObjectContext;
    NSFetchRequest * allMessages = [[NSFetchRequest alloc] init];
    [allMessages setEntity:[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context]];
    [allMessages setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(account = %@  AND account.status = YES)",[[MMailManager sharedManager] getCurrentAccount]];
    [allMessages setPredicate:predicate];
    
    NSError * error = nil;
    NSArray * messages = [context executeFetchRequest:allMessages error:&error];
    for (NSManagedObject* message in messages) {
        
//        ////NSLog(@"...............Deleting Messages..............");
        [context deleteObject:message];
        
    }
    
    ////NSLog(@"saveContext after FOLDERINFO");
//    [dataManager saveContextAsync];
    
    _loadingMore = NO;
    

    
    [self performSelector:@selector(loadMoreMessages) withObject:nil afterDelay:0.2];
    [self resetIdleTimer];
    
    [self performSelector:@selector(setupRefreshControlActive:) withObject:NO afterDelay:0.5];
    
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    _authAlert = nil;
    NSMutableArray* controllers = [self.navigationController.viewControllers mutableCopy];
    BOOL signInPresent = NO;
    MSignInViewController* signIn = nil;
    
    for (UIViewController* controller in controllers) {
        if([controller class] == [MSignInViewController class]){
            signInPresent = YES;
            signIn = (MSignInViewController *)controller;
            break;
        }
    }
    
    if (signIn == nil) {
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        signIn = [storyboard instantiateViewControllerWithIdentifier:@"MSignInViewController"];
        [controllers insertObject:signIn atIndex:1];
        [self.navigationController setViewControllers:[controllers copy] animated:NO];
    } else {
        [signIn resetStateFromError];
    }

    ////NSLog(@"Controllers: %@", self.navigationController.viewControllers);
    [self.navigationController popToViewController:signIn animated:YES];
}

-(void)authenticationError
{
    if (_authAlert == nil) {
        _authAlert = [[UIAlertView alloc] initWithTitle:@"Authentication Problem"
                                                        message:@"There was a problem signing in, please re-enter your credentials."
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [_authAlert show];
    }
}

- (void)errorOccurred:(NSNotification *)notification
{
    if(self.navigationController.visibleViewController != self){
        ////NSLog(@"Not visible, not responding to error");
        return;
    }
    
    NSError *error = notification.object;
    
    if ([error.domain isEqualToString:MCOErrorDomain]){
        switch (error.code) {
            case MCOErrorAuthentication:
                [self authenticationError];
                break;
            default:
                ////NSLog(@"MCO Other Error %@", error);
                break;
        }
        
    } else {
        
        ////NSLog(@"Non-MCO Error: %@", error);
    }

}



- (void) swipedButtonPanChanged:(UIPanGestureRecognizer *)recognizer
{
    if (_isIndicating) {
        _isIndicating = NO;
        DLog(@"swipedButtonPanChanged ERROR %d",(int)[defaults integerForKey:@"selectedIndex"]);
    }
    if (!_isIndicating) {
        
        if ([defaults integerForKey:@"selectedIndex"] > 0) {
            

//    ////NSLog(@"recognizer.x ==== %f",[recognizer locationInView:swipeBut.superview].x);
//    ////NSLog(@"recognizer.y ==== %f",[recognizer locationInView:swipeBut.superview].y);

//    NSLog(@"recognizer.view.center.y ==== %f",recognizer.view.center.y);
//    NSLog(@"recognizer.view.center.x ==== %f",recognizer.view.center.x);

    NSInteger height = self.view.frame.size.height + 0.5f;
    
//    ////NSLog(@"self.view.frame.size.width ==== %f",self.view.frame.size.width);
        
//        ////NSLog(@"height = %d",height);

    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
//        self.view.center = [recognizer locationInView:swipeBut.superview];
        
        switch (height)
        {
        case 568:
            //iPhone 5
           {
//               if ((recognizer.view.center.y > 470)&&(recognizer.view.center.y < 500)) {
               
                   if ((recognizer.view.center.y > 200)&&(recognizer.view.center.y < 560)) {
               
                   [UIView beginAnimations:@"presentWithSuperview" context:nil];
                   [UIView setAnimationDuration:0.3];
                       
//                   self.view.frame=CGRectMake(recognizer.view.center.x - self.view.frame.size.width/2, recognizer.view.center.y-500, self.view.frame.size.width, self.view.frame.size.height);
                       
//                    self.navigationController.view.frame=CGRectMake(recognizer.view.center.x - self.view.frame.size.width/2, 0, self.view.frame.size.width, self.view.frame.size.height);
                   
                   self.view.frame=CGRectMake(recognizer.view.center.x - self.view.frame.size.width/2, 0, self.view.frame.size.width, self.view.frame.size.height);

                   [UIView commitAnimations];
                   
               }
           }
         
            break;
         
         case 480:
            //iPhone
             {
//                 if ((recognizer.view.center.y > 380)&&(recognizer.view.center.y < 450)) {
                 
                     if ((recognizer.view.center.y > 150)&&(recognizer.view.center.y < 460)) {

                 
                     [UIView beginAnimations:@"presentWithSuperview" context:nil];
                     [UIView setAnimationDuration:0.3];
//                     self.view.frame=CGRectMake(recognizer.view.center.x - self.view.frame.size.width/2, recognizer.view.center.y-416, self.view.frame.size.width, self.view.frame.size.height);
                     self.view.frame=CGRectMake(recognizer.view.center.x - self.view.frame.size.width/2,0, self.view.frame.size.width, self.view.frame.size.height);
                     
                     [UIView commitAnimations];
                     
                     
                 }
             }

                break;
         
          default:
            //iPad
         
             {
                 if ((recognizer.view.center.y > 200)&&(recognizer.view.center.y < 1000)) {
                     
//                     if ((recognizer.view.center.y > 930)&&(recognizer.view.center.y < 970)) {
                 
                     [UIView beginAnimations:@"presentWithSuperview" context:nil];
                     [UIView setAnimationDuration:0.2];
//                     self.view.frame=CGRectMake(recognizer.view.center.x - self.view.frame.size.width/2, recognizer.view.center.y-955, self.view.frame.size.width, self.view.frame.size.height);
                     self.view.frame=CGRectMake(recognizer.view.center.x - self.view.frame.size.width/2, 0, self.view.frame.size.width, self.view.frame.size.height);

                     [UIView commitAnimations];
                     
                 }
             }

                break;
        }

    }
    
    else if(recognizer.state == UIGestureRecognizerStateEnded)
    {
        
//        swipeLoader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        swipeLoader.center = CGPointMake([[UIApplication sharedApplication] keyWindow].frame.size.width / 2, ([[UIApplication sharedApplication] keyWindow].frame.size.height / 2) - 44);
//        
//        [[[UIApplication sharedApplication] keyWindow] addSubview:swipeLoader];
//        
//        [swipeLoader startAnimating];
        
        
        switch (height)
        {
            case 568:
                //iPhone 5
            {
                
//                if ((recognizer.view.center.x > 170)&&(recognizer.view.center.y > 470)&&(recognizer.view.center.y < 500)){
                
                if ((recognizer.view.center.x > 190)&&(recognizer.view.center.y > 150)&&(recognizer.view.center.y < 560)){

                    [MCyclingViewController panLeftFrom:self recognizer:recognizer];
                    _fetchedResultsController = nil;
                    
                    
                }
//                else if ((recognizer.view.center.x < 170)&&(recognizer.view.center.y > 470)&&(recognizer.view.center.y < 500)){
                
                else if ((recognizer.view.center.x < 150)&&(recognizer.view.center.y > 150)&&(recognizer.view.center.y < 560)){

                    [MCyclingViewController panRightFrom:self recognizer:recognizer];
                    _fetchedResultsController = nil;
                    
                }
                else{
                    
                    if ((recognizer.view.center.x > 151) &&(recognizer.view.center.x < 189)&&(recognizer.view.center.y > 495)) {
                        
                        _isIndicating = YES;
                        
                        [self performSelector:@selector(ballRefreshAction) withObject:nil afterDelay:0.1];
                        
                        
                    }
                    
                    else if ((recognizer.view.center.x > 151) &&(recognizer.view.center.x < 189)&&(recognizer.view.center.y < 490)){
                        
//                        [self.navigationController popViewControllerAnimated:NO];
                        
                        [self backAction:0];
                        
                    }
                    
                    
                    
                    [UIView animateWithDuration:.3 animations:^{
                        
                        [UIView beginAnimations:@"presentWithSuperview" context:nil];
                        self.view.frame = CGRectMake(0 , 0 , self.view.frame.size.width, self.view.frame.size.height);
                        
                        [UIView commitAnimations];
                        
                        
                    } completion:^(BOOL isFinished){
                        if (isFinished == true)
                        {
                            
                            [UIView beginAnimations:@"presentWithSuperview" context:nil];
                            [UIView setAnimationDuration:0.3];
                            
                            
                            [UIView commitAnimations];
                            
                        }
                    }];
                    
                }
                
            }
                
                break;
                
            case 480:
                //iPhone
            {
                
//                if ((recognizer.view.center.x > 170)&&(recognizer.view.center.y > 380)&&(recognizer.view.center.y < 450)){
                
                if ((recognizer.view.center.x > 190)&&(recognizer.view.center.y > 150)&&(recognizer.view.center.y < 460)){

                    
                    [MCyclingViewController panLeftFrom:self recognizer:recognizer];
                    _fetchedResultsController = nil;
                    
//                    [[MControllerManager sharedManager] goPanLeftFrom:[self.navigationController.viewControllers lastObject] recognizer:recognizer];
//                    _shortMode = YES;
                    
//                    [self.navigationController pushViewController:[self.navigationController.viewControllers lastObject] animated:YES];
                    
                    
                }
                else if ((recognizer.view.center.x < 150)&&(recognizer.view.center.y > 150)&&(recognizer.view.center.y < 460)){
                    
//                    else if ((recognizer.view.center.x < 170)&&(recognizer.view.center.y > 380)&&(recognizer.view.center.y < 450)){

                    
                    
                    [MCyclingViewController panRightFrom:self recognizer:recognizer];
                    _fetchedResultsController = nil;
                    
//                    [[MControllerManager sharedManager] goPanRightFrom:[self.navigationController.viewControllers lastObject] recognizer:recognizer];

                }
                else{
                    
                    if ((recognizer.view.center.x > 151) &&(recognizer.view.center.x < 189)&&(recognizer.view.center.y > 435)) {

                        _isIndicating = YES;
                        
                        [self performSelector:@selector(ballRefreshAction) withObject:nil afterDelay:0.1];
                        
//                        [self ballRefreshAction];
                        
                    }
                    else if ((recognizer.view.center.x > 151) &&(recognizer.view.center.x < 189)&&(recognizer.view.center.y < 390)){
                        
//                        [self.navigationController popViewControllerAnimated:NO];
                        
                         [self backAction:0];
                        
                    }
                    
                    
                    [UIView animateWithDuration:.3 animations:^{
                        
                        [UIView beginAnimations:@"presentWithSuperview" context:nil];
                        self.view.frame = CGRectMake(0 , 0 , self.view.frame.size.width, self.view.frame.size.height);
                        
                        [UIView commitAnimations];
                        
                    } completion:^(BOOL isFinished){
                        if (isFinished == true)
                        {
                            
                            [UIView beginAnimations:@"presentWithSuperview" context:nil];
                            [UIView setAnimationDuration:0.3];
                            
                            
                            [UIView commitAnimations];
                            
                        }
                    }];
                    
                }
                
            }
                
                break;
                
            default:
                //iPad
                
            {
                if ((recognizer.view.center.x > 405)&&(recognizer.view.center.y > 200)&&(recognizer.view.center.y < 1000)){
//                    if ((recognizer.view.center.x > 395)&&(recognizer.view.center.y > 930)&&(recognizer.view.center.y < 970)){

                    [MCyclingViewController panLeftFrom:self recognizer:recognizer];
                    _fetchedResultsController = nil;
                    
                }
                else if ((recognizer.view.center.x < 365)&&(recognizer.view.center.y > 200)&&(recognizer.view.center.y < 1000)){
//                    else if ((recognizer.view.center.x < 395)&&(recognizer.view.center.y > 930)&&(recognizer.view.center.y < 970)){

                    
                    [MCyclingViewController panRightFrom:self recognizer:recognizer];
                    _fetchedResultsController = nil;
                }
                else{
                    
                    if ((recognizer.view.center.x > 366)&&(recognizer.view.center.x < 404)&&(recognizer.view.center.y > 965)){

                        _isIndicating = YES;
                        
                        [self performSelector:@selector(ballRefreshAction) withObject:nil afterDelay:0.1];

                    }
                    
                    else if ((recognizer.view.center.x > 366)&&(recognizer.view.center.x < 404)&&(recognizer.view.center.y < 960)){
                        
                        //                        [self.navigationController popViewControllerAnimated:NO];
                        
                        [self backAction:0];
                        
                    }
                    
                    [UIView animateWithDuration:.3 animations:^{
                        
                        [UIView beginAnimations:@"presentWithSuperview" context:nil];
                        self.view.frame = CGRectMake(0 , 0 , self.view.frame.size.width, self.view.frame.size.height);
                        
                        [UIView commitAnimations];
                        
                    } completion:^(BOOL isFinished){
                        if (isFinished == true)
                        {
                            
                            [UIView beginAnimations:@"presentWithSuperview" context:nil];
                            [UIView setAnimationDuration:0.3];
                            
                            
                            [UIView commitAnimations];
                            
                        }
                    }];
                    
                }
                
            }
                
                break;
        }
      
    }
        
    }
    }
    else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please select an inbox from home page" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
        [alert show];
    }

}

#pragma mark - UILongPressGestureRecognizer


- (void)swipedButtonLongChanged:(UILongPressGestureRecognizer *)recognizer{
    
    if (!_isIndicating) {
        
    //as you hold the button this would fire
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
         [self composeNewMessage];
        
        
//            ////NSLog(@"recognizer.x ==== %f",[recognizer locationInView:swipeBut.superview].x);
//            ////NSLog(@"recognizer.y ==== %f",[recognizer locationInView:swipeBut.superview].y);
        
    }
    
    //as you release the button this would fire
    
//    if (recognizer.state == UIGestureRecognizerStateEnded) {
    
//            ////NSLog(@"recognizer.x  END==== %f",[recognizer locationInView:swipeBut.superview].x);
//            ////NSLog(@"recognizer.y END ==== %f",[recognizer locationInView:swipeBut.superview].y);
        
       
        
//    }
        
    }
    
}



-(IBAction)backAction:(id)sender{
    
    [[MMailManager sharedManager] stopFetchingMail];
    [[MDataManager sharedManager] saveContextAsync];
    
    MAppDelegate *delegate = (MAppDelegate *) [[UIApplication sharedApplication]delegate];
    delegate.isChangeLogin = YES;
    
    _fetchedResultsController.delegate = nil;
    
    defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:NO forKey:@"isList"];
    [defaults synchronize];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
    
    [self performSegueWithIdentifier:@"UnwindBack" sender:self];
    _fetchedResultsController = nil;

//    MAppDelegate *delegate = (MAppDelegate *)[[UIApplication sharedApplication]delegate];
//    [self.navigationController popToViewController:delegate.homeView animated:YES];
//    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

- (void)fakeProgress:(NSTimer *)timer
{
    float newProgress = _fetchingProgressView.progress + 0.01;
    
    ////NSLog(@"newProgress=%f",newProgress);
    
    if (newProgress > 1.0) {
        newProgress = 1.0;
        [timer invalidate];
    }
    
    ////NSLog(@"setting fakeProgress to %f", newProgress);
    [_fetchingProgressView setProgress:newProgress animated:YES];
}

- (void)composeNewMessage{
    
    [self performSegueWithIdentifier:@"composeNewMessage" sender:self];
}

- (void)startGallery
{
    if (!_shortMode) {
        
        [self performSegueWithIdentifier:@"StartCarousel" sender:self];
    } else {
        [self performSegueWithIdentifier:@"showDetailShort" sender:self];
    }
    
    /*
    MCarouselViewController* carouselController = [[MCarouselViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
    [self presentViewController:carouselController animated:YES completion:^{
        ////NSLog(@"GALLERY completed");
    }];
     */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    /*
    NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
    NSEntityDescription *entity = [[self.fetchedResultsController fetchRequest] entity];
    NSManagedObject *newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    // If appropriate, configure the new managed object.
    // Normally you should use accessor methods, but using KVC here avoids the need to add a custom class to the template.
    [newManagedObject setValue:[NSDate date] forKey:@"timeStamp"];
    
    // Save the context.
    NSError *error = nil;
    if (![context save:&error]) {
         // Replace this implementation with code to handle the error appropriately.
         // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
        ////NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
     */
}

#pragma mark - Load More Action


//-(void)loadMoreMessages{
//    
//    ////NSLog(@"******************loadMoreMessages*********************");
//    ////NSLog(@"_isFirst = %d",_isFirst);
//    
//    if (!_isFirst) {
//        
//         ////NSLog(@"_loadingMore = %d",_loadingMore);
//        
//        if (_loadingMore) {
//            
//            ////NSLog(@"_exhaustedCoreData: %d _loadingMore: %d", _exhaustedCoreData, _loadingMore);
//            return;
//        }
//        
//        _loadingMore = YES;
//        
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        
////            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 2), ^{
//
//            NSUInteger currentFetchLimit = _fetchedResultsController.fetchRequest.fetchLimit;
//            NSUInteger newFetchLimit = MESSAGE_CELLS_PER_LOAD + currentFetchLimit;
//            [_fetchedResultsController.fetchRequest setFetchLimit:newFetchLimit];
//            
//            ////NSLog(@"object count before: %d",[self.fetchedResultsController.fetchedObjects count]);
//            
//            ////NSLog(@"Dispatch call");
//
//            NSError* error;
//            if (![_fetchedResultsController performFetch:&error]) {
//                
//                ////NSLog(@"Error");
//                
//                abort();
//            }
//            else{
//                ////NSLog(@"No error");
//            }
//            
//            ////NSLog(@"object count after: %d",[self.fetchedResultsController.fetchedObjects count]);
//            
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                ////NSLog(@"Dispatch main thread");
//                
//                NSUInteger newItemCount = [self.fetchedResultsController.fetchedObjects count];
//                
////                if (newItemCount > newFetchLimit) {
//                
//                    [self.tableView reloadData];
////                }
//                
//                
//                
//                
//                
//                
//                //testing
//                
//                if(newItemCount < newFetchLimit){
//                    
//                    //        ////NSLog(@"No more in core data! Stop!");
//                    //_exhaustedCoreData = YES;
//                    _fetchedResultsController.fetchRequest.fetchLimit = currentFetchLimit;
//                    
//                    _loadingMore = NO;
//                    
//                    isadding = NO;
//                    
//                    _tableFooterView.label.text = @"Loading More";
//                    //        [_tableFooterView.loader startAnimating];
//                    
//                    self.tableView.tableFooterView = _tableFooterView;
//                    
//                    //got to fetch more from mail manager here
//                    
//                    
//                    
//                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                        
//                        int lastUID = ((Message *)[self.fetchedResultsController.fetchedObjects lastObject]).uid.intValue;
//                        int fetchCount = FETCH_MESSAGE_COUNT;
//                        
//                        
//                        [[MMailManager sharedManager] fetchMessagesFromFolder:[MMailManager sharedManager].inbox startingUID:lastUID-fetchCount-1 count:fetchCount success:^(NSUInteger newCount){
//                            
//                            //                       ////NSLog(@"done loading more messages");
//                            
//                        } failure:^(NSError* error){
//                            
//                            //                        ////NSLog(@"failure loading more messages: %@", error);
//                            
//                            
//                            
//                        }];
//                        
//
//                        
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            
//                            [_tableFooterView.loader stopAnimating];
//                            self.tableView.tableFooterView = nil;
//                            _loadingMore = NO;
//                            
//                        });
//                    });
//                    
//
//                    
//                    
//                } else {
//                    
//                    //done with loading fetch more from core data
//                    
//                    _loadingMore = NO;
//                    //        self.tableView.tableFooterView = nil;
//                    
//                    _tableFooterView.label.text = @"Loading More";
//                    [_tableFooterView.loader stopAnimating];
//                    
//                    //        self.tableView.tableFooterView = _tableFooterView;
//                    
//                    self.tableView.tableFooterView = nil;
//                    
//                }
//                
//                
//                
//
//                
//                
//                
//                
//                
//                
//                
//                
//                    _loadingMore = NO;
//                
//            });
//        });
//        
//        
////        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0),
////                       ^{
////                            ////NSLog(@"Dispatch call");
////                           [self performSelector:@selector(methodThatloadYourData)];
////                           dispatch_async(dispatch_get_main_queue(),
////                                          ^{
////                                              
////                                              ////NSLog(@"Dispatch main thread");
////                                              [self.tableView reloadData];
////                                              _loadingMore = NO;
////                                          });
////                       });
////
//        
//        
//        
//        
//    }
//    _isFirst = NO;
//    
//}

//- (void)methodThatloadYourData {
//    
//            NSError* error;
//            if (![_fetchedResultsController performFetch:&error]) {
//
//                ////NSLog(@"Error");
//
//                abort();
//            }
//            else{
//                ////NSLog(@"No error");
//            }
//
//            ////NSLog(@"object count after: %d",[self.fetchedResultsController.fetchedObjects count]);
//
//    
//    
////    NSError *_error;
////     if (![_fetchedResultsController performFetch:&_error]) {
////        ////NSLog(@"Unresolved error %@, %@", _error, [_error userInfo]);
////    }
//}


- (void)sr_executeFetchRequest:(NSFetchRequest *)request completion:(void (^)(NSArray *objects, NSError *error))completion {
    
    NSPersistentStoreCoordinator *coordinator = [NSPersistentStoreCoordinator MR_defaultStoreCoordinator];
//    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    
//    ////NSLog(@"request = %@",request);
    
//    NSUInteger prevItemCount = [self.fetchedResultsController.fetchedObjects count];
    
//    ////NSLog(@"self.fetchedResultsController = %@",self.fetchedResultsController);
    
//    ////NSLog(@"prevItemCount = %lu",(unsigned long)prevItemCount);
    
    NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [backgroundContext performBlock:^{
        backgroundContext.persistentStoreCoordinator = coordinator;
        
        // Fetch into shared persistent store in background thread
        NSError *error = nil;
//        NSArray *fetchedObjects = [backgroundContext executeFetchRequest:request error:&error];
        BIDT1();
        if (![_fetchedResultsController performFetch:&error]){
            
        }
        BIDT2();
        [self.tableView reloadData];
        
//        [backgroundContext performBlock:^{
//            if (fetchedObjects) {
//                
//                // Collect object IDs
//                NSMutableArray *mutObjectIds = [[NSMutableArray alloc] initWithCapacity:[fetchedObjects count]];
//                ////NSLog(@"fetchedObjects = %@",fetchedObjects);
//                
//                
//                for (int i=0; i< [fetchedObjects count]; i++) {
//                    
//                    Message *message = [fetchedObjects objectAtIndex:i];
//                    
//                    
//                    
//                }
//                
////                for (NSManagedObject *obj in fetchedObjects) {
////                    [mutObjectIds addObject:obj.objectID];
////                    
//////                    Message *message = obj;
//////                    ////NSLog(@"message = %@",message);
//////                    
////                    
////                }
//                
//                // Fault in objects into current context by object ID as they are available in the shared persistent store
//                NSMutableArray *mutObjects = [[NSMutableArray alloc] initWithCapacity:[mutObjectIds count]];
//                for (NSManagedObjectID *objectID in mutObjectIds) {
//                    
////                     [[self.fetchedResultsController objectWithID:objectID] willAccessValueForKey:nil];
//                    
////                    ////NSLog(@"objectID = %@",objectID);
//                    
////                    Message *message = objectID;
////                    ////NSLog(@"message = %@",message);
//                    
////                    NSManagedObject *obj = [self objectWithID:objectID];
////                    [mutObjects addObject:obj];
//                }
                
//                if (completion) {
//                    
//                    NSUInteger newItemCount = [self.fetchedResultsController.fetchedObjects count];
        
//                    ////NSLog(@"newItemCount = %lu",(unsigned long)newItemCount);
//
//                    NSArray *objects = [mutObjects copy];
//                    completion(objects, nil);
//                    
//                    _loadingMore = NO;
//                    
//                    [self.tableView reloadData];
//                }
//                
//            } else {
//                if (completion) {
//                    completion(nil, error);
//                }
//            }
//        }];
    }];
}


//- (void)contextDidSaveNotification:(NSNotification*)saveNotification {
//    
//    NSManagedObjectContext *backgroundContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
//    
//    [backgroundContext performBlock:^{
//        [backgroundContext mergeChangesFromContextDidSaveNotification:saveNotification];
//    }];
//}
-(NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName {
    return sectionName;
}

- (void)loadMoreMessages
{
    _isIndicating = YES;
    
    
    [[MSwipedButtonManager sharedManager] setEnable:NO];
    
    NSLog(@"******************loadMoreMessages*********************");
    
    if (_loadingMore) {
        return;
    }
    
    _loadingMore = YES;
    isadding = YES;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSUInteger currentFetchLimit = _fetchedResultsController.fetchRequest.fetchLimit;
        NSUInteger newFetchLimit = MESSAGE_CELLS_PER_LOAD + currentFetchLimit;
        [_fetchedResultsController.fetchRequest setFetchLimit:newFetchLimit];
        
        NSUInteger beforeItemCount = [self.fetchedResultsController.fetchedObjects count];
        NSLog(@">>>>>>>>beforeItemCount:%lu",(unsigned long)beforeItemCount);
        BIDT1();
        
        NSError* error = nil;
        if (![_fetchedResultsController performFetch:&error]) {
            
            abort();
        }
        __block NSUInteger newItemCount = [self.fetchedResultsController.fetchedObjects count];
        if (newItemCount != beforeItemCount) {
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
        }

        BIDT2();
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
            if(newItemCount < newFetchLimit || _isIdle){
                
                //NSLog(@"  -------------------   No more in core data! Stop!  ----------------");
                
                _fetchedResultsController.fetchRequest.fetchLimit = currentFetchLimit;
                
                _loadingMore = NO;
                
                isadding = NO;
                
                _tableFooterView.label.text = @"Loading More";
                
                self.tableView.tableFooterView = _tableFooterView;
                
                //got to fetch more from mail manager here
                
                int lastUID = ((Message *)[self.fetchedResultsController.fetchedObjects lastObject]).uid.intValue;
                
                //NSLog(@"lastUID = %d",lastUID);
                
                int fetchCount = FETCH_MESSAGE_COUNT;
                
                int sUID =lastUID-fetchCount-1;
                if (_isIdle || sUID<-1) {
                    sUID = -1;
                }
                AccountInfo *actInfo = [[MMailManager sharedManager] getCurrentAccountInfo];
                actInfo.uid = sUID;
                [actInfo fetchNewMessagesWithSuccess:^(NSUInteger newCount) {
                    actInfo.showNewEmail = NO;
                    [_tableFooterView.loader stopAnimating];
                    self.tableView.tableFooterView = nil;
                    _loadingMore = NO;
                } failure:^(NSError *error) {
                    //NSLog(@"failure loading more messages: %@", error);
                    [_tableFooterView.loader stopAnimating];
                    self.tableView.tableFooterView = nil;
                    _loadingMore = NO;
                }];
            } else {
                _loadingMore = NO;
                
                _tableFooterView.label.text = @"Loading More";
                
                if ([_tableFooterView.loader isAnimating]) {
                    [_tableFooterView.loader stopAnimating];
                }
                
                self.tableView.tableFooterView = _tableFooterView;
            }
            [[MSwipedButtonManager sharedManager] setEnable:YES];
            [self performSelector:@selector(removeLoaderFromMore) withObject:nil afterDelay:0.1];
        });
    });
}

-(void)removeLoaderFromMore{
    
    _isIndicating = NO;
    [[MSwipedButtonManager sharedManager] setEnable:YES];
}

-(void)removeTableViewFooter{
    
    if (self.tableView.tableFooterView) {
        
        [_tableFooterView.loader stopAnimating];
        self.tableView.tableFooterView = nil;
        _loadingMore = NO;
        
    }
    if (self.refresh.isRefreshing) {
        [self performSelector:@selector(setupRefreshControlActive:) withObject:NO afterDelay:0.5];
    }
}

#pragma mark - Scroll View
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.loadingFinished = NO;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _isIdle = NO;

    //check if we're at the bottom of the table by scrolling and not loading more already
   
    if (_loadingMore || !(scrollView.dragging || scrollView.decelerating)) return;
    CGFloat targetOffset = scrollView.contentSize.height - scrollView.frame.size.height + scrollView.contentInset.bottom;
    
    BOOL hitBottom = scrollView.contentOffset.y >= targetOffset;
    
    if(hitBottom){
        
        CGFloat delta = scrollView.contentOffset.y - targetOffset;
        CGFloat triggerDelta = PULL_TO_LOAD_REQUIREMENT;
        if (delta >= triggerDelta) {
            
            if (_fetchedResultsController.fetchedObjects.count) {
                
                _tableFooterView.label.text = @"Loading More";
                [_tableFooterView.loader startAnimating];
                
                self.tableView.tableFooterView = _tableFooterView;
                
            }
            if (!self.loadingFinished) {
                self.loadingFinished = YES;
                [self performSelector:@selector(loadMoreMessages) withObject:nil afterDelay:.1];
            }
        }
    }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return [[_fetchedResultsController sections] count];
    
//    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    if(section!=0) return 0;
    
    //id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    ////NSLog(@"number of rows in section %d: %d", section, [sectionInfo numberOfObjects]);
    //return [sectionInfo numberOfObjects];
   id <NSFetchedResultsSectionInfo >info = [_fetchedResultsController.sections objectAtIndex:section];
    NSInteger count =[info numberOfObjects];
    ////NSLog(@"number of fetchedObjects: %d", count);
    return count;
    
//    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell" forIndexPath:indexPath];

    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (![undoBut isDescendantOfView:[[UIApplication sharedApplication] keyWindow]]){

        
        Message *message = [_fetchedResultsController objectAtIndexPath:indexPath];

        NSInteger count = [[message.gmailMessageIDS componentsSeparatedByString:@","] count];

        if (count>1) {
            [self performSegueWithIdentifier:@"listSessionView" sender:self];
        } else {
            [self performSegueWithIdentifier:@"showDetail" sender:self];
        }
    }
}

-(void)removeTableIndex : (NSIndexPath *)swipedIndexPath{
    
   
//    [_deleteIndexArray removeAllObjects];
    
    [_deleteIndexArray addObject:[NSString stringWithFormat:@"%ld",(long)swipedIndexPath.row]];
    
//    [_deleteIndexArray addObject:swipedIndexPath];
    
//    ////NSLog(@"_deleteIndexArray = %@",_deleteIndexArray);
    
//    deletedIndex = swipedIndexPath.row;
    
//    ////NSLog(@"swipedIndexPath = %@",swipedIndexPath);
    
//    Message *message = [self.fetchedResultsController objectAtIndexPath:swipedIndexPath];
//    
//    [_deleteMessageArray addObject:message];
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:swipedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
//    [self.tableView reloadData];
    
    [self createUndoButton];
    
    
   
  
//    [message deleteMessage];
    
    
//    [self.tableView reloadData];
    
//    [self.tableView beginUpdates];
//    [self.tableView deleteRowsAtIndexPaths:@[swipedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
//    [self.tableView endUpdates];
    
    
//    UITableViewCell* swipedCell = [self.tableView cellForRowAtIndexPath:swipedIndexPath];
//    
//    UIView *anmtnVw = (UIView *)[swipedCell viewWithTag:100000];
//    
//    if (anmtnVw) {
//        
//        [self performSelector:@selector(removeCellView:) withObject:anmtnVw afterDelay:.2];
//        
//    }
    
}

//void LR_offsetView(UIView *view, CGFloat offsetX, CGFloat offsetY)
//{
//    view.frame = CGRectOffset(view.frame, offsetX, offsetY);
//}


-(void)removeDeleteView : (UIView *)cellView{
    
    [cellView removeFromSuperview];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ////NSLog(@"prepareForSegue: %@", segue.identifier);
    if (self.fetchedResultsController.fetchedObjects.count < 1){
        ////NSLog(@"showDetailShort no messages, returning");
        return;
    }
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        MDetailViewController *detailController = [segue destinationViewController];
        Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
        detailController.shortMode = _shortMode;
        detailController.fetchedResultsController = self.fetchedResultsController;
        detailController.message = message;
        detailController.peopleMode = NO;
        
    } else if ([[segue identifier] isEqualToString:@"showDetailShort"]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];

        MDetailViewController *detailController = [segue destinationViewController];
        detailController.shortMode = YES;
        detailController.fetchedResultsController = self.fetchedResultsController;
        detailController.message = message;
        detailController.peopleMode = NO;

    } else if ([[segue identifier] isEqualToString:@"listSessionView"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];

        Message *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
        MMailListSessionTableViewController * listSessionView =  [segue destinationViewController];
        listSessionView.message = message;
//        listSessionView.fetchedResultsController = self.fetchedResultsController;
    }

    _markUnread=NO;
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    
//   ////NSLog(@" ****** fetchedResultsController *******");
    
    if (!_isLoaded) {
        
        ////NSLog(@"_isLoaded");
        
        if (_fetchedResultsController != nil) {
            
            //        //NSLog(@"_fetchedResultsController alredy exists");
            
            //        ////NSLog(@"tchedResultsController.fetchedObjects.count BEFORE= %d",_fetchedResultsController.fetchedObjects.count);
            
            return _fetchedResultsController;
        }
        
        //    ////NSLog(@"start first fetchedResultsController %@", self);
        ////NSLog(@"%@",[NSThread callStackSymbols]);
        
        [Message setDefaultBatchSize:MESSAGE_CELLS_PER_LOAD];
        Folder *folder = [[MMailManager sharedManager] getCurrentFolder];
        Account *account = [[MMailManager sharedManager] getCurrentAccount];
        
        //    //NSLog(@"folder = %@",folder);
        ////NSLog(@"account = %@",account);
        
        if (_shortMode) {
            //Modified by 3E ------START------
            
            ////NSLog(@"short mode");
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account.status = YES  AND read = NO AND deleted = NO AND archive = NO AND NOT (passed=YES OR processed=YES)"];
            
            //        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account.status = YES  AND read = NO AND deleted = NO "];
            
            _fetchedResultsController = [Message fetchAllSortedBy:@"characterCount"
                                                        ascending:YES
                                                    withPredicate:predicate
                                                          groupBy:nil
                                                         delegate:self];
            
            
            //        _fetchedResultsController.fetchRequest.fetchLimit = 20;
            _fetchedResultsController.fetchRequest.fetchLimit = 10;
            
        } else if (_longMode){
            
            ////NSLog(@"long mode");
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account.status = YES  AND read = NO AND deleted = NO AND archive = NO AND NOT (passed=YES OR processed=YES)"];
            
            _fetchedResultsController = [Message fetchAllSortedBy:@"characterCount"
                                                        ascending:NO
                                                    withPredicate:predicate
                                                          groupBy:nil
                                                         delegate:self];
            
            //        _fetchedResultsController.fetchRequest.fetchLimit = 20;
            _fetchedResultsController.fetchRequest.fetchLimit = 10;
            
        }
        else if (_isAllInbox){
            
            //         //NSLog(@"isAllInbox mode");
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account.status = YES AND deleted = NO AND archive = NO AND NOT (passed=YES OR processed=YES)"];
            
            _fetchedResultsController = [Message fetchAllSortedBy:@"receivedDate"
                                                        ascending:NO
                                                    withPredicate:predicate
                                                          groupBy:nil
                                                         delegate:self];
            
            _fetchedResultsController.fetchRequest.fetchLimit = 10;
        }
        else {
            
            //         //NSLog(@"inbox mode");
            
            //        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account = %@  AND account.status = YES AND folder = %@ AND deleted = NO ", account, folder];
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account = %@  AND account.status = YES AND folder = %@ AND deleted = NO AND archive = NO AND NOT (passed=YES OR processed=YES)", account, folder];
            
            _fetchedResultsController = [Message fetchAllSortedBy:@"uid"
                                                        ascending:NO
                                                    withPredicate:predicate
                                                          groupBy:nil
                                                         delegate:self];
            _fetchedResultsController.fetchRequest.fetchLimit = 10;
            
        }
        
        //Modified by 3E ------END------
        
        _fetchedResultsController.fetchRequest.fetchOffset = 0;
        
//        [Message performFetch:_fetchedResultsController];
        
        //    //NSLog(@"performFetch %lu results", (unsigned long)_fetchedResultsController.fetchedObjects.count);
        
        if (_fetchedResultsController.fetchedObjects.count == 0) {
            
            if (!isSpinning) {
                
                spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                spinner.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2) - 44);
                [self.view addSubview:spinner];
                isSpinning = YES;
                
                [spinner startAnimating];
            }
        } else {
        }
    } else if(!_fetchedResultsController) {
        ////NSLog(@"_isLoaded");
        
        if (_fetchedResultsController != nil) {
            
            //        //NSLog(@"_fetchedResultsController alredy exists");
            
            //        ////NSLog(@"tchedResultsController.fetchedObjects.count BEFORE= %d",_fetchedResultsController.fetchedObjects.count);
            
            return _fetchedResultsController;
        }
        
        //    ////NSLog(@"start first fetchedResultsController %@", self);
        ////NSLog(@"%@",[NSThread callStackSymbols]);
        
        [Message setDefaultBatchSize:MESSAGE_CELLS_PER_LOAD];
        Folder *folder = [[MMailManager sharedManager] getCurrentFolder];
        Account *account = [[MMailManager sharedManager] getCurrentAccount];
        
        //    //NSLog(@"folder = %@",folder);
        ////NSLog(@"account = %@",account);
        
        if (_shortMode) {
            //Modified by 3E ------START------
            
            ////NSLog(@"short mode");
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account.status = YES  AND read = NO AND deleted = NO AND archive = NO AND NOT (passed=YES OR processed=YES)"];
            
            //        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account.status = YES  AND read = NO AND deleted = NO "];
            
            _fetchedResultsController = [Message fetchAllSortedBy:@"characterCount"
                                                        ascending:YES
                                                    withPredicate:predicate
                                                          groupBy:nil
                                                         delegate:self];
            
            
            //        _fetchedResultsController.fetchRequest.fetchLimit = 20;
            _fetchedResultsController.fetchRequest.fetchLimit = 10;
            
        } else if (_longMode){
            
            ////NSLog(@"long mode");
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account.status = YES  AND read = NO AND deleted = NO AND archive = NO AND NOT (passed=YES OR processed=YES)"];
            
            _fetchedResultsController = [Message fetchAllSortedBy:@"characterCount"
                                                        ascending:NO
                                                    withPredicate:predicate
                                                          groupBy:nil
                                                         delegate:self];
            
            //        _fetchedResultsController.fetchRequest.fetchLimit = 20;
            _fetchedResultsController.fetchRequest.fetchLimit = 10;
            
        }
        else if (_isAllInbox){
            
            //         //NSLog(@"isAllInbox mode");
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account.status = YES AND deleted = NO AND archive = NO AND NOT (passed=YES OR processed=YES)"];
            
            _fetchedResultsController = [Message fetchAllSortedBy:@"receivedDate"
                                                        ascending:NO
                                                    withPredicate:predicate
                                                          groupBy:nil
                                                         delegate:self];
            
            _fetchedResultsController.fetchRequest.fetchLimit = 10;
        }
        else {
            
            //         //NSLog(@"inbox mode");
            
            //        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account = %@  AND account.status = YES AND folder = %@ AND deleted = NO ", account, folder];
            
            NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account = %@  AND account.status = YES AND folder = %@ AND deleted = NO AND archive = NO AND NOT (passed=YES OR processed=YES)", account, folder];
            
            _fetchedResultsController = [Message fetchAllSortedBy:@"uid"
                                                        ascending:NO
                                                    withPredicate:predicate
                                                          groupBy:nil
                                                         delegate:self];
            _fetchedResultsController.fetchRequest.fetchLimit = 10;
            
        }
        
        //Modified by 3E ------END------
        
        _fetchedResultsController.fetchRequest.fetchOffset = 0;
        
        //        [Message performFetch:_fetchedResultsController];
        
        //    //NSLog(@"performFetch %lu results", (unsigned long)_fetchedResultsController.fetchedObjects.count);
        
        if (_fetchedResultsController.fetchedObjects.count == 0) {
            
            if (!isSpinning) {
                
                spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
                spinner.center = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2) - 44);
                [self.view addSubview:spinner];
                isSpinning = YES;
                
                [spinner startAnimating];
            }
        } else {
        }
    }
    
    _isLoaded = YES;
    

    if (_isFromDidApear) {
        
        _isFromDidApear = NO;
        [self.tableView reloadData];
        
        [self performSelector:@selector(removeLoaderFromMore) withObject:nil afterDelay:0.1];
        
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"isList"]) {
        [self.tableView beginUpdates];
        _retainCount++;
    }
}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"isList"]) {
        if (_retainCount>0) {
            [self.tableView endUpdates];
            _retainCount--;
        }
    }
}
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"isList"]) {
    
        switch(type) {
                
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
    
//    [imgVw sendSubviewToBack:self.tableView];
    
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"isList"]) {
        
        UITableView *tableView = self.tableView;
        
        
        switch(type) {
                
            case NSFetchedResultsChangeInsert:
//                NSLog(@"controllerDidChangeObject Insert %d,%d", newIndexPath.row,newIndexPath.section);
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:{
                
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                
                if (_isDeleteMode) {
                    if ([_deleteIndexArray count]) {
                        
                        [_deleteIndexArray removeObjectAtIndex:0];
                        [_deleteMessageArray removeObjectAtIndex:0];
                        if (![_deleteIndexArray count]) {
                            _isDeleteMode = NO;
                        }
                        
                    }
                    else{
                        _isDeleteMode = NO;
                        
                        if (_isArchiveMode) {
                            
                            if ([_archiveIndexArray count]) {
                                [_archiveIndexArray removeObjectAtIndex:0];
                                [_archiveIndexPathArray removeObjectAtIndex:0];
                                if (![_archiveIndexArray count]) {
                                    _isArchiveMode = NO;
                                }
                                
                            }
                            else{
                                _isArchiveMode = NO;
                            }
                            
                        }
                    }
                } else {
                    if (_isArchiveMode) {
                        if ([_archiveIndexArray count]) {
                            [_archiveIndexArray removeObjectAtIndex:0];
                            [_archiveIndexPathArray removeObjectAtIndex:0];
                            if (![_archiveIndexArray count]) {
                                _isArchiveMode = NO;
                            }
                        }
                    }
                }
            }
                break;
                
            case NSFetchedResultsChangeUpdate:
                if (!_isArchiveMode ) {
                    [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
                }
                break;
            case NSFetchedResultsChangeMove:
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

#pragma mark - Undo Section

-(void)createUndoButton{
    
    if (![undoBut isDescendantOfView:[[UIApplication sharedApplication] keyWindow]]) {
        
        ////NSLog(@"undoBut not present");
        
        undoBut = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [undoBut setTitle:@"Undo" forState:UIControlStateNormal];
        undoBut.titleLabel.font = [UIFont boldSystemFontOfSize:16];
//        undoBut.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 10, 0);
        undoBut.tintColor = [UIColor whiteColor];
        undoBut.backgroundColor = [UIColor redColor];
        
        [undoBut addTarget:self
                    action:@selector(udoAction:)
          forControlEvents:UIControlEventTouchUpInside];
        
        undoBut.frame = CGRectMake(([[UIApplication sharedApplication] keyWindow].frame.size.width/2)-35, 70, 50, 50);
        [[[UIApplication sharedApplication] keyWindow] addSubview:undoBut];
        
    }
    if (undoTimer) {
        
         ////NSLog(@"undoTimer present");
        
        [undoTimer invalidate];
        undoTimer = nil;
    }
    
    undoTimer = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                 target:self
                                               selector:@selector(undoTimerMethod:)
                                               userInfo:nil
                                                repeats:NO];

}

-(void)undoTimerMethod : (NSTimer *)timer{
    
    ////NSLog(@"timer");
    
    [timer invalidate];
    timer = nil;
    
    
    [self deleteMessages:_deleteIndexArray];
    
//     [self deleteMessages:_deleteMessageArray];
    
    
    
    [undoBut removeFromSuperview];
    
}

-(IBAction)udoAction:(id)sender{
    
//    deletedIndex = 0;
    
    [_deleteIndexArray removeAllObjects];
    [_deleteMessageArray removeAllObjects];
    
//    [self unarchiving:_archiveIndexArray];
    
    
    
//    [_archiveIndexArray removeAllObjects];
//    [_archiveIndexPathArray removeAllObjects];

    
    [undoTimer invalidate];
    undoTimer = nil;
    
    [undoBut removeFromSuperview];
    
//     NSIndexPath *swipedIndexPath = [_deleteIndexArray objectAtIndex:0];
//    
//     [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:swipedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    [self.tableView reloadData];
    
    
    [self performSelector:@selector(unarchiving:) withObject:_archiveIndexArray afterDelay:0.3];
    
   

    
}

-(void)unarchiving :(NSArray *)indexPathArray{
    
     for (int i=0; i<[indexPathArray count]; i++) {
         
         Message *message = [indexPathArray objectAtIndex:i];
         [message unarchiveAction];
     }
    
    [_archiveIndexArray removeAllObjects];
    [_archiveIndexPathArray removeAllObjects];
    
}

-(void)deleteMessages : (NSArray *)indexPathArray{
    
//    //NSLog(@"");
//    
//     NSInteger index = [[indexPathArray objectAtIndex:0] intValue];
//     Message *message = [_fetchedResultsController.fetchedObjects objectAtIndex:index];
//    [message deleteMessage];
    
    
    
    
//        for (int j=0; j<[indexPathArray count]; j++) {
//
//            _isDeleteMode = YES;
//
//            Message *message = [indexPathArray objectAtIndex:j];
////            //NSLog(@"message second= %@",message);
//
//            [message deleteMessage];
//            
//        }
//    
    
    
    ////NSLog(@"indexPathArray = %@",indexPathArray);
    
    NSMutableArray *messageArray = [NSMutableArray arrayWithArray:nil];
    
    for (int i=0; i<[indexPathArray count]; i++) {
        
        NSInteger index = [[indexPathArray objectAtIndex:i] intValue];
        ////NSLog(@"index=%u",index);
        
        Message *message = [self.fetchedResultsController.fetchedObjects objectAtIndex:index];
//        //NSLog(@"message first= %@",message);
        
        [messageArray addObject:message];
        
//            [message deleteMessage];
    }
    
//    dispatch_async(dispatch_queue_create("mydeletequeue", 0), ^{
    
        for (int j=0; j<[messageArray count]; j++) {
            
            _isDeleteMode = YES;
            
            Message *message = [messageArray objectAtIndex:j];
//            //NSLog(@"message second= %@",message);
            
            [message deleteMessage];
            
        }
    
    //needed
    
    [self archiveMessages:_archiveIndexArray];
    
//    [self performSelector:@selector(archiveMessages:) withObject:_archiveIndexArray afterDelay:.2];
    
    //not needed
    
    
    
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//        });
//    });
    
    //    Message *message = [self.fetchedResultsController objectAtIndexPath:swipedIndexPath];
    //    [message deleteMessage];
    
}

-(void)archiveMessages :(NSArray *)messageArray {
    
    for (int j=0; j<[messageArray count]; j++) {
        
        _isArchiveMode = YES;
        
        Message *message = [messageArray objectAtIndex:j];
        
        [message archiveAction];
        
    }
    
}



/*
// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}
*/

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    
//    ////NSLog(@"//////////////////configureCell//////////////////////");
    
    //NSLog(@"self.fetchedResultsController.count = %lu",(unsigned long)_fetchedResultsController.fetchedObjects.count);
//    NSLog(@"<<<<<<<<%ld,%ld",(long)indexPath.row,(long)indexPath.section);

    Message *message = [_fetchedResultsController objectAtIndexPath:indexPath];

    if (CGRectGetHeight(cell.bounds) <=0 ) {
        cell.hidden = YES;
    }
    
//    //NSLog(@"_deleteIndexArray = %@",_deleteIndexArray);
//    //NSLog(@"_archiveIndexPathArray = %@",_archiveIndexPathArray );
    
//    if (![_deleteIndexArray containsObject:[NSString stringWithFormat:@"%d",indexPath.row]])  {
    
         if (![_deleteIndexArray containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]])  {
        
//        if (![_archiveIndexArray containsObject:[NSString stringWithFormat:@"%@",message]]) {
        
//        //NSLog(@"--------  Condition -------------");
        
        ////NSLog(@"_deleteIndexArray configureCell=%@",_deleteIndexArray);
        
        if (isSpinning) {
        isSpinning = NO;
        [spinner stopAnimating];
        [spinner removeFromSuperview];
    }
    
//    if (_isIndicating) {
//        
//        _isIndicating = NO;
//         [MBProgressHUD hideHUDForView:[[UIApplication sharedApplication] keyWindow] animated:YES];
//    }
    
    MMessageCell *messageCell = (MMessageCell *)cell;
    messageCell.message = message;
    //id <NSFetchedResultsSectionInfo >info = [_fetchedResultsController.sections objectAtIndex:indexPath.section];
             messageCell.threadCount.hidden = YES;
             if (message.theadShow) {
                 NSInteger count = [[message.gmailMessageIDS componentsSeparatedByString:@","] count];
                 if (count>1) {
                     messageCell.threadCount.hidden = NO;
                     messageCell.threadCount.font = [UIFont systemFontOfSize:12];
                     messageCell.threadCount.text = [NSString stringWithFormat:@"%lu",(unsigned long)count];
                 }
             }
//    //NSLog(@"message = %@",message);
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* rec = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:message.receivedDate];
    NSDateComponents* today = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    
    if (rec.day == today.day && rec.month == today.month && rec.year == today.year) {
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
    }
    else
    {
        [dateFormatter setDateFormat:@"MMM dd"];
                                      
        //dateFormatter.dateStyle = NSDateFormatterShortStyle;
        //dateFormatter.timeStyle = NSDateFormatterNoStyle;
    }
    
    [dateFormatter setLocale:[NSLocale currentLocale]];
    
    
    NSString *formattedDate = [dateFormatter stringFromDate:message.receivedDate];
    
//    ////NSLog(@"message.receivedDate = %@",message.receivedDate);
    
    ////NSLog(@"Date for locale %@: %@",
    //      [[dateFormatter locale] localeIdentifier], formattedDate);

    messageCell.subjectLabel.text = message.subject;
    
    if (message.fromName == nil || [message.fromName isEqualToString:@""]) {
        messageCell.fromLabel.text = message.fromAddress;
        
    } else {
        messageCell.fromLabel.text = message.fromName;
    }
             messageCell.delegate = self;
#ifdef DEBUG
    messageCell.dateLabel.text = [NSString stringWithFormat:@"%@,%ld",formattedDate,(long)indexPath.row];
             messageCell.dateLabel.frame = CGRectMake(200, 8, 120, 16);
#else
    messageCell.dateLabel.text = formattedDate;
#endif
    
    if(message.summary != nil){
        messageCell.textLabel.text = message.summary;
    } else {
        messageCell.textLabel.text = @"";
    }
    messageCell.unreadCircle.hidden = YES;

    if (message.read) {
        messageCell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        messageCell.fromLabel.font =   [UIFont systemFontOfSize:13];
        messageCell.subjectLabel.font =   [UIFont systemFontOfSize:12];
        messageCell.textLabel.font =  [UIFont systemFontOfSize:11];
    }
    else {
        messageCell.backgroundColor = [UIColor whiteColor];
        messageCell.fromLabel.font =   [UIFont boldSystemFontOfSize:13];
        messageCell.subjectLabel.font =   [UIFont boldSystemFontOfSize:12];
        messageCell.textLabel.font =  [UIFont boldSystemFontOfSize:11];
    }
    
    messageCell.characterCountLabel.text = [NSString stringWithFormat:@"%d", message.characterCount];
    messageCell.characterCountLabel.hidden = !(_shortMode || _longMode);
    
    
    //Commented
    
    
//    ////NSLog(@"message.characterCount = %d",message.characterCount);
    
//    float progressMin = 0;
//    float progressMax = 5000;
//    float progress = (message.characterCount - progressMin) / (progressMax - progressMin);
//    messageCell.progressView.progress = progress;;
//    messageCell.progressView.hidden = !(_shortMode || _longMode);
    
//    ////NSLog(@"_shortMode = %d",_shortMode);
//    ////NSLog(@"_longMode = %d",_longMode);
//    ////NSLog(@"!(_shortMode || _longMode) = %d",!(_shortMode || _longMode));
    
//    if (_longMode) {
//        messageCell.progressView.hidden = YES;
//        messageCell.characterCountLabel.hidden = YES;
//    }
    
    
    messageCell.progressView.hidden = YES;
    messageCell.characterCountLabel.hidden = YES;
    
    
    /*
    
    if (!messageCell.longPressRecognizer) {
        UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        [messageCell addGestureRecognizer:longPressRecognizer];
        longPressRecognizer.minimumPressDuration = 0.3;
        longPressRecognizer.delegate = self;
        messageCell.longPressRecognizer = longPressRecognizer;
    }
     
     */
    
    /*

    if (!messageCell.doubleTapRecognizer) {
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        [messageCell addGestureRecognizer:doubleTapRecognizer];
        doubleTapRecognizer.delegate = self;
        messageCell.doubleTapRecognizer = doubleTapRecognizer;
    
    */
    
//    if (!messageCell.leftSwipeRecognizer) {
//    
//        UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(leftSwipe:)];
//        leftSwipe.direction = UISwipeGestureRecognizerDirectionRight;
//        [messageCell addGestureRecognizer:leftSwipe];
//        messageCell.leftSwipeRecognizer = leftSwipe;
//    }
//    
//    if (!messageCell.rightSwipeRecognizer) {
//        
//        UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
//        gesture.direction = UISwipeGestureRecognizerDirectionLeft;
//        [messageCell addGestureRecognizer:gesture];
//        messageCell.rightSwipeRecognizer = gesture;
//    }
        
//    }
    }
   
//    [self.tableView bringSubviewToFront:imgVw ];
    
}

- (void) showMessage:(Message *)message animated:(BOOL)animated
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:message];
    [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self performSegueWithIdentifier:@"showDetail" sender:self];

}

- (void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"accessoryButtonTappedForRowWithIndexPath");
    
    if (_isIndicating) {
        _isIndicating = NO;
        [[MSwipedButtonManager sharedManager] setEnable:YES];
    }
    
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self performSegueWithIdentifier:@"showDetail" sender:self];
}

- (void) doubleTap:(UIGestureRecognizer*)gestureRecognizer
{
    MMessageCell *cell = (MMessageCell *)gestureRecognizer.view;
    Message *message = cell.message;
    [message toggleMarkRead];
}

- (void) singleTap:(UIGestureRecognizer*)gestureRecognizer
{
    UIGestureRecognizerState state = gestureRecognizer.state;
    MMessageCell *cell = (MMessageCell *)gestureRecognizer.view;
    
//    ////NSLog(@"singleTap state:%d", (int)state);

    switch (state) {
        case UIGestureRecognizerStateBegan:
            cell.highlighted = YES;
            break;
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateEnded:
            cell.highlighted = NO;
            /*
            [self.tableView selectRowAtIndexPath:[self.tableView indexPathForCell:cell] animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self performSegueWithIdentifier:@"showDetail" sender:self];
             */
            break;
        default:
//            ////NSLog(@"LONG TAP OTHER STATE: %d", state);
            break;
    }
}
- (void)swipeCell:(JZSwipeCell*)cell triggeredSwipeWithType:(JZSwipeType)swipeType
{
    if (swipeType == JZSwipeTypeLongLeft) {
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForCell:cell];
        
        Message *message = [self.fetchedResultsController objectAtIndexPath:swipedIndexPath];
        [_deleteMessageArray addObject:message];
        [self performSelector:@selector(removeTableIndex:) withObject:swipedIndexPath afterDelay:0.5];
    } else if (swipeType == JZSwipeTypeShortLeft) {
        NSIndexPath *swipedIndexPath = [self.tableView indexPathForCell:cell];
        
        MMessageCell *acell = (MMessageCell *)cell;
        Message *message = acell.message;
        [_archiveIndexArray addObject:message];
        
        [_archiveIndexPathArray addObject:[NSString stringWithFormat:@"%ld",(long)swipedIndexPath.row]];
        
        [self performSelector:@selector(removeTableIndexForArchive:) withObject:swipedIndexPath afterDelay:0.5];
    }
}

- (void) leftSwipe:(UIGestureRecognizer*)gestureRecognizer
{
    ////NSLog(@"Read/Unread");
    
    CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
    NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
    
    
    UITableViewCell* swipedCell = [self.tableView cellForRowAtIndexPath:swipedIndexPath];
    
    UIView *cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, swipedCell.frame.size.width, swipedCell.frame.size.height)];
    cellView.backgroundColor = [UIColor greenColor];
    cellView.tag = 200000;
    
    //
    CATransition *animation1 = [CATransition animation];
    [animation1 setDuration:0.5];
    [animation1 setType:kCATransitionPush];
    [animation1 setSubtype:kCATransitionFromLeft];
    [animation1 setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [[swipedCell.contentView layer] addAnimation:animation1 forKey:@"SwitchToView2"];
    
    CGFloat offsetX;
    offsetX = -swipedCell.contentView.frame.size.width;
    swipedCell.contentView.frame = CGRectOffset(swipedCell.contentView.frame, offsetX, 0);
    
    
    // set up an animation for the transition between the views
    CATransition *animation = [CATransition animation];
    [animation setDuration:0.5];
    [animation setType:kCATransitionPush];
    [animation setSubtype:kCATransitionFromLeft];
    [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    
    [[cellView layer] addAnimation:animation forKey:@"SwitchToView1"];
    
    [swipedCell addSubview:cellView];
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        //        CGPoint swipeLocation = [gestureRecognizer locationInView:self.tableView];
        //        NSIndexPath *swipedIndexPath = [self.tableView indexPathForRowAtPoint:swipeLocation];
        //         self.tableView.editing = YES;
        
    [self performSelector:@selector(removeTableIndexForArchive:) withObject:swipedIndexPath afterDelay:0.5];
        
        //        Message *message = [self.fetchedResultsController objectAtIndexPath:swipedIndexPath];
        //
        ////        ////NSLog(@"message = %@",message);
        //        [message deleteMessage];
        
        //         [self.tableView reloadData];
        
    }
    
    MMessageCell *cell = (MMessageCell *)gestureRecognizer.view;
    Message *message = cell.message;
    
//    [_archiveIndexArray removeAllObjects];
//    [_archiveIndexPathArray removeAllObjects];
    
    
    [_archiveIndexArray addObject:message];
    
    [_archiveIndexPathArray addObject:[NSString stringWithFormat:@"%ld",(long)swipedIndexPath.row]];
//
//    
//    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:swipedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//    
//    
//    [message archiveAction];
//
//    
//    [self createUndoButton];
    
    
    
    
    
    
    
    
//    [message archiveAction];
    
//    [message toggleMarkRead];

    
    /* disabling feature for now - need to implement like
     http://www.teehanlax.com/blog/reproducing-the-ios-7-mail-apps-interface/
     
    ////NSLog(@"LEFT SIDE SWIPE");
    
    MMessageCell *cell = (MMessageCell *)gestureRecognizer.view;
    
    CGRect cellFrame = cell.frame;
    
    cellFrame.origin.x = 100.0;
    
    cell.frame = cellFrame;
     */

}

-(void)removeTableIndexForArchive : (NSIndexPath *)swipedIndexPath{
    
    [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:swipedIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    
//    Message *message = [_fetchedResultsController objectAtIndexPath:swipedIndexPath];
//    [message archiveAction];
    
    
    [self createUndoButton];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSLog(@">>>>>>>%ld,%ld",(long)indexPath.row,(long)indexPath.section);
    Message *message = [_fetchedResultsController objectAtIndexPath:indexPath];

//    Message *message = (Message *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    CGFloat height = 122.0;

    if ([_deleteIndexArray containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
        height = 0;
    }
     if ([_archiveIndexPathArray containsObject:[NSString stringWithFormat:@"%ld",(long)indexPath.row]]) {
        height = 0;
    }
    
    if (message.summary == nil || message.summary.length == 0)
    {
        height = 60.0;
    }
    if (!message.theadShow) {
        height = 0;
    }

    return height;
}

- (void) progressFetchingMail:(NSNotification *) notification
{
    isadding = YES;
  
//    [idleTimer invalidate];
    
    NSValue *value = [notification object];
    NSRange range = [value rangeValue];
    NSUInteger fetched = range.location;
    NSUInteger total = range.length;
    
    CGFloat progress = (float)fetched/(float)total;
    
   ////NSLog(@"setting progress to: %f", progress);
    
    statusView.statusLabel.text = [NSString stringWithFormat:@"Received %lu/%lu messages", (unsigned long)fetched, (unsigned long)total];
    
    ////NSLog(@"_visible = %d",_visible);
    
    if(_visible){
        
        [_fetchingProgressView setProgress:progress animated:YES];
        if (_fetchingProgressView.hidden) {
            
            ////NSLog(@"_fetchingProgressView.hidden = NO");
            _fetchingProgressView.hidden = NO;
        }
    }
    
    if (fetched == total) {
       
        isadding = NO;
    }
}

@end
