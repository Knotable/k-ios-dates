//
//  CombinedViewController.h
//  Knote
//
//  Created by JYN on 9/19/13.
//  Copyright (c) 2013 jackiejin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "BubbleView.h"
#import "ContactCell.h"
#import "SwipeTableView.h"
#import "TopicCell.h"
#import "BaseViewController.h"
#import "M13OrderedDictionary.h"
#import "MyProfileController.h"
#import "MozTopAlertView.h"
#import "Constant.h"

#if New_DrawerDesign
#import "UPStackMenu.h"
#endif

@class AccountEntity;

@interface CombinedViewController : UIViewController
<
SwipeTableViewDelegate
,EditorViewControllerDelegate
,FilterPadsDelegate
,UITableViewDataSource
,UITableViewDelegate
,UIGestureRecognizerDelegate
,UIActionSheetDelegate
,UISearchBarDelegate
,UISearchDisplayDelegate
,MKMapViewDelegate
,CLLocationManagerDelegate
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
,UIBarPositioningDelegate
#endif
>

@property (nonatomic, strong) NSMutableArray* peopleData;

@property (nonatomic, strong) NSMutableArray* topicArray;
@property (nonatomic, strong) NSMutableDictionary* topicArrayDictionary;

@property (nonatomic, strong) AccountEntity *currentAccount;

@property (nonatomic, assign) BOOL jumpsToMySpaces;             // we can ignore this variable
@property(nonatomic,strong)TopicInfo *tempEntity;
@property (strong, nonatomic) UIRefreshControl *refresh;
@property (nonatomic, strong) UIView * refreshLoadingView;
@property (nonatomic, strong) UIView * refreshColorView;
@property (nonatomic) BOOL isUpdatedTopic;
@property (nonatomic, assign) DisplayMode displayMode;
@property (nonatomic, assign) BOOL isRemovedNow;             // we can ignore this variable
@property (nonatomic, assign) BOOL shouldPopToMainView;



@property (nonatomic, strong) NSTimer*  observeHoldingTimer;

- (void)addPressed;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil account:(AccountEntity *)account;

- (void)reloadData;

// Lin - Added for Menu Change

//- (void) fetchedAllPeopleTopics:(BOOL)f_showArchivedPad;
- (void) OpenPeople;
//- (void) OpenPads;
- (void) OpenSettings;

- (void) TouchableMenu;
- (void) NonTouchableMenu;

- (void) actionSort;
- (void) actionArchive;
- (void) actionReorder;
- (void) actionSpeaker;
- (void) startAddTopic:(BOOL)isAutoCreated;

- (void) UpdateNavigationBarIndex:(NSInteger)buttonIndex;
- (void) setSearchBarVisibleDisplayMode:(NSInteger)displayMode Visible:(BOOL)visible;

// Utility Functon

- (void) updateData;
- (void) logCounts;
- (void) hideLoadingView;
-(void)loggingOutExtras;
- (NSMutableArray *)fetchAllContactsExcludingSelfForSortFlag:(BOOL)sortFlag archiveFlag:(BOOL)archiveFlag;
- (void) holdingObserver;

#if kPeopleProcess

- (void)contactsUpdateProgress:(NSInteger)totalCount;

#endif

- (float)   fetchedTopicsStep;
- (void)    removeTopicWithTopicID:(NSString*)topic_id;
- (void)    addedTopic:(NSNotification *) notification;
- (void)    changedTopic:(NSNotification *) notification;
- (void)    removedTopic:(NSNotification *) notification;
-(void) makeupstakenil;
- (void) manageNotificatioObservers:(BOOL) addflag;

+ (TopicInfo*) lastSessionTopic;

- (void) managePeopleNotificationObservers:(BOOL) addflag;
- (void) managePadsNotificationObservers:(BOOL) addflag;
- (void) removedContact:(ContactsEntity*)contact;
- (void) removedContactFromDataSource:(ContactsEntity*)contact;

- (void) removeLoginSplashFromNavArray;

- (void) enableSwitchView;

- (void) navigateToThreadWithTopicInfo:(NSString *)ti animated:(BOOL)animated;

- (void) showArchivedPads:(BOOL)archived;

@end

@interface CombinedViewController (MyProfileDelegateProtocol)<MyProfileDelegateProtocol>

@end
