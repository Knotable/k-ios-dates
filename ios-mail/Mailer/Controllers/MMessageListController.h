//
//  MMessageListController.h
//  Mailer
//
//  Created by Martin Ceperley on 9/20/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "MCyclingTableViewController.h"
#import "MSwipedButtonManager.h"
#import "CWStatusBarNotification.h"
@class MStatusView, MTableFooterView, Message;

@interface MMessageListController : MCyclingTableViewController <NSFetchedResultsControllerDelegate, UITableViewDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate> {
    
    BOOL _fetchingNewMail;
    NSString *_modeTitle;
    BOOL _visible;
    
    //Modified by 3E ------START------
    BOOL _markUnread,isSpinning;
    NSTimer *idleTimer;
    NSUserDefaults *defaults;
    
    UIActivityIndicatorView *spinner;
//    UIImageView *imgVw;
    UIButton *undoBut;
    UIActivityIndicatorView *swipeLoader;
    int initialVal;
    
    NSInteger deletedIndex;
    
    NSTimer *undoTimer;
    
    //Modified by 3E ------END------
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) IBOutlet UIToolbar* toolbar;
@property (strong, nonatomic) UIBarButtonItem* refreshButton;
@property (strong, nonatomic) UIActivityIndicatorView* loadingIndicator;

@property (strong, nonatomic) UIBarButtonItem* statusItem;
@property (strong, nonatomic) UIBarButtonItem* galleryItem;

@property (strong, nonatomic) MStatusView* statusView;
@property (strong, nonatomic) MTableFooterView* tableFooterView;

@property (strong, nonatomic) NSDate* lastUpdated;
@property (strong, nonatomic) NSTimer* updateStatusTimer;

@property (strong, nonatomic) IBOutlet UIRefreshControl* refresh;

@property (nonatomic) BOOL shortMode,isLoaded,isAllInbox,isDeleteMode,isArchiveMode;
@property (nonatomic) BOOL longMode,isadding,isIndicating,isFromDidApear;

@property (strong, nonatomic) UIProgressView* fetchingProgressView;
@property (nonatomic, strong) NSMutableArray *deleteIndexArray,*deleteMessageArray,*archiveIndexArray,*archiveIndexPathArray;
@property (atomic, assign) BOOL loadingFinished;

- (IBAction) refreshPulled:(id)sender;

- (void) showMessage:(Message *)message animated:(BOOL)animated;
@property (strong, nonatomic) CWStatusBarNotification *notification;

@end
