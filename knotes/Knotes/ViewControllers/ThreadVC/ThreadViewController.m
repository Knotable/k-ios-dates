//
//  ThreadViewController.m
//
//  Created by backup on 13-10-15.
//
//

#import "ThreadViewController.h"
#import "ShareListController.h"
#import "GGFullscreenImageViewController.h"
#import "MyProfileController.h"
#import "CommentViewController.h"

#import "COverlayView.h"
#import "CEditKeynoteItemView.h"
#import "CEditHeaderItemView.h"
#import "CEditDateItemView.h"
#import "CEditVoteItemView.h"
#import "CEditKnoteItemView.h"
#import "CEditLockItemView.h"
#import "CNewCommentItemView.h"
#import "CEditReplysItemView.h"
#import "RichTableView.h"
#import "BWStatusBarOverlay.h"
#import "VoteCell.h"
#import "KnoteCell.h"
#import "PicturesCell.h"
#import "ContactCell.h"
#import "BaseKnoteCell.h"
#import "PictureCell.h"
#import "DeadlineCell.h"
#import "LockCell.h"
#import "KeyKnoteCell.h"
#import "MCSwipeTableViewCell.h"
#import "PostPicturesCell.h"

#import "CVoteItem.h"
#import "CLockItem.h"
#import "CKnoteItem.h"
#import "CKeyNoteItem.h"
#import "CMessageItem.h"
#import "CNewCommentItem.h"
#import "CPictureItem.h"
#import "CReplysItem.h"
#import "CustomBarButtonItem.h"

#import "ContactManager.h"
#import "PostingManager.h"
#import "TopicManager.h"
#import "AnalyticsManager.h"
#import "ThreadItemManager.h"
#import "ReachabilityManager.h"
#import "DesignManager.h"
#import "DataManager.h"

#import "MessageEntity.h"
#import "ContactsEntity.h"
#import "FileEntity.h"

#import "NSString+Knotes.h"
#import "UIImage+Retina4.h"
#import "UIImage+Tint.h"
#import "NSMutableArray+KnotesArray.h"
#import "FTAnimation+UIView.h"
#import "UIImage+FontAwesome.h"

#import "CEditVoteInfo.h"
#import "TopicInfo.h"

#import "MyMacros.h"
#import "Constant.h"
#import "AppDelegate.h"
#import "M13OrderedDictionary.h"
#import "OMPromises/OMPromises.h"
#import "ChatInput.h"
#import "KnotePUV.h"
#import "KnoteEPNV.h"
#import "ImageTransitioningDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>
#if New_DrawerDesign
#if ChangeInDrawer
#import "CustomSideBar.h"
#import "MozTopAlertView.h"
#else
#import "RNFrostedSidebar.h"
#endif
#endif
#define USE_HEADER_TRAY 1

#if USE_HEADER_TRAY

#import "CEditHeaderInfoView.h"

#endif

#include "CustomSideBar.h"
#include "SideMenuViewController.h"
#import "ProfileDetailVC.h"

NSString * const KnotebleTopicChange = @"KnotebleTopicChange";

NSString* defaultTopicName = @"Knotes from iOS";
NSString* lastTopicId = nil;

#if USE_HEADER_TRAY

typedef NS_ENUM(NSInteger, NJKScrollDirection) {
    NJKScrollDirectionNone,
    NJKScrollDirectionUp,
    NJKScrollDirectionDown,
};

NJKScrollDirection detectScrollDirection(currentOffsetY, previousOffsetY)
{
    return currentOffsetY > previousOffsetY ? NJKScrollDirectionUp   :
    currentOffsetY < previousOffsetY ? NJKScrollDirectionDown :
    NJKScrollDirectionNone;
}

#endif

#define kActionUserData @"kActionUserData"

#define kSwipeRightMenuButtonsWidth 50
#define DelayToObservingCrash    10.0f

@interface ThreadViewController (KnoteEPNVDelegate)<KnoteEPNVDelegate>
@end

@interface ThreadViewController ()
<
NSFetchedResultsControllerDelegate,
CEditBaseItemViewDelegate,
COverlayViewDelegate,
RichTableViewDelegate,
RichTableViewDataSource,
EditorViewControllerDelegate,
CEditHeaderItemViewDelegate,
UIGestureRecognizerDelegate,
MenuViewDelegate,
MZFormSheetBackgroundWindowDelegate,
UIActionSheetDelegate,
UITextFieldDelegate,
FloatingTrayDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate,
ReachabilityManagerDelegate,
UITextViewDelegate,
CTitleInfoBarDelegate,
ReorderTableViewDelegate,
MyProfileDelegateProtocol,
ChatInputDelegate,
ShareListDelegateProtocol,
#if USE_HEADER_TRAY
CEditHeaderInfoViewDelegate,
#endif
MCSwipeTableViewCellDelegate
#if New_DrawerDesign
,CItemDelegate
,UPStackMenuDelegate
#if ChangeInDrawer
,CustomSidebarDelegate
#else
,RNFrostedSidebarDelegate
#endif
#endif
,SideMenuDelegate>
{
    
}

@property (nonatomic)           BOOL isRefreshAnimating;
@property (assign, atomic)      BOOL isKeyboardVisible;
@property (assign, atomic)      BOOL finishLoad;
@property (assign, atomic)      BOOL showArchived;
@property (nonatomic, assign)   BOOL rearrangingCells;
@property (nonatomic, assign)   BOOL isNewPad;
@property (nonatomic, assign)   BOOL needScroll;
@property (assign, nonatomic)   BOOL locked;
@property (assign, nonatomic)   BOOL customEditing;
@property (assign, nonatomic)   BOOL firstIn;
@property (assign, nonatomic)   BOOL orderByLike;
@property (assign, nonatomic)   BOOL isCreatingKnote ;
@property (assign, nonatomic)   BOOL newPadCreated ;
@property (assign, nonatomic)   BOOL isPostingComment ;
@property (assign, nonatomic)   BOOL isSubscribed ;


@property (assign, nonatomic)   BOOL isUpdationOver ;
@property                       BOOL willSegueAfterRowTap;


@property (assign, nonatomic)   BOOL isReady_topic;
@property (assign, nonatomic)   BOOL isReady_pinnedKnotes;
@property (assign, nonatomic)   BOOL isReady_archivedKnotes;
@property (assign, nonatomic)   BOOL isReady_toGoBack;
@property (assign, nonatomic)   BOOL isReady_toGetRest;
@property (assign, nonatomic)   BOOL isAddedPullRefresh_toGetRest;

@property (nonatomic) BOOL showFooter;

@property (assign, nonatomic)   NSInteger count_topic;
@property (assign, nonatomic)   NSInteger count_pinnedKnotes;
@property (assign, nonatomic)   NSInteger count_archivedKnotes;
@property (assign, nonatomic)   NSInteger count_restKnotes;

@property (assign, nonatomic)   NSInteger counter_knote_added;

@property (nonatomic, strong)   NSDate*     start_Subscription_date;
@property (nonatomic, strong)   NSString*   log_knotes_loading;
@property (nonatomic, strong)   UIImageView*   loadingGhostScreen;


@property (nonatomic, strong) CItem             *focusedToCommentitem;
@property (strong, nonatomic) CItem             *focusedCommentItem;
@property (strong, nonatomic) CLockItem         *lockItem;
@property (strong, nonatomic) CKeyNoteItem      *keyNoteItem;
@property (nonatomic, strong) CNewCommentItem   *nwCommentItem;
@property (strong, nonatomic) CKnoteItem        *placeHoldNote;

@property (nonatomic)         NSMutableArray*   sortOrderMapArray;//prevent reorder (when user reoder at iPhone)

@property (nonatomic, strong) KnotePUV  *bottomPadUserView;
@property (nonatomic, strong) KnoteEPNV *emptyNotifyView;
@property (strong, nonatomic) ChatInput *commentInput;
@property (nonatomic, strong) CommentViewController *commentController;

@property (nonatomic, strong) UILabel * gettingYourPadLabel;

@property (strong, nonatomic) KnotableProgressView  *spinnerImageView;

@property (strong, nonatomic) RichTableView         *tableView;
@property (strong, nonatomic) RichTableView         *tableViewRight;
@property (strong, nonatomic) COverlayView          *overlayView;
@property (strong, nonatomic) CEditBaseItemView     *cellInEditor;
@property (strong, nonatomic) CEditBaseItemView     *focusedCommentCell;
@property (strong, nonatomic) UIImageView           *firstDot;
@property (strong, nonatomic) UIImageView           *secondDot;
#if !New_DrawerDesign
@property (nonatomic, strong) CEditHeaderItemView   *headerTitle;
#endif

@property (nonatomic, strong)   UserEntity                  *login_user;
@property (nonatomic, strong)   ImageTransitioningDelegate  *transDelegate;

@property (nonatomic, strong)   UIAlertView                     *titleAlert;
@property (nonatomic, strong)   UITextField                     *titleTextField;
#if !New_DrawerDesign
@property (nonatomic, strong)   UIToolbar                       *menuWithSharePad;
#endif
@property (nonatomic ,strong)   CALayer                         *animalLayer;
@property (weak, nonatomic)     UIView                          *activeView;
@property (strong, nonatomic)   UIRefreshControl                *refresh;
@property (strong, nonatomic)   UILabel                         *titleLabel;
#if !New_DrawerDesign
@property (strong, nonatomic)   UIBarButtonItem                 *createKnoteButton;
#else
@property (strong, nonatomic)   UIBarButtonItem                 *sharedPeopleButton;
#endif
@property (strong, nonatomic)   UIDocumentInteractionController *documentInteractionController;
@property (strong, nonatomic)   MNMBottomPullToRefreshManager   *pullToRefreshManager;

@property (strong, atomic)      NSMutableArray  *knotes;
@property (strong, atomic)      NSMutableArray  *rightData;
@property (strong, atomic)      NSMutableArray  *RestData;
@property (strong, nonatomic)   NSIndexPath     *expandIndex;
@property (strong, nonatomic)   NSMutableArray  *itemsOpened;
@property (strong, nonatomic)   NSString        *mainTitle;
@property (assign, atomic)      NSInteger       banPosition;
@property (weak, nonatomic)     NSString        *indexItemBeingCommented;
@property (weak, nonatomic)     NSNumber        *numberOfCommentsitemBeingCommented;
@property (assign, nonatomic)   NSInteger       cameraIdx, photoLibIdx, savedPhotosIdx;


#if USE_HEADER_TRAY

@property (nonatomic, strong) CEditHeaderInfoView *headerInfoView;
@property (nonatomic, strong) NSMutableDictionary *headerInfoDic;
@property (nonatomic) CGFloat previousOffsetY;
@property (nonatomic) CGFloat accumulatedY;
@property (nonatomic) CGFloat upThresholdY; // up distance until fire. default 0 px.
@property (nonatomic) CGFloat downThresholdY; // down distance until fire. default 200 px.
@property (nonatomic) NJKScrollDirection previousScrollDirection;
#if New_DrawerDesign
#if ChangeInDrawer
@property (nonatomic,strong)  CustomSideBar *sideBar;
#else
@property (nonatomic, strong) RNFrostedSidebar *callout;
#endif
@property (nonatomic, strong)UPStackMenu *  stack;
@property (nonatomic)NSIndexPath *archivedIndexPath;
@property (nonatomic,strong)MCSwipeTableViewCell *archivedCell;
@property (nonatomic,strong)UITextField *instanceTxtReply;
#endif
#endif

@property (nonatomic) BOOL isNeedShowStack;// avoid to show when show About, settings ...
@end

@implementation ThreadViewController

- (void)dealloc
{
    DLog(@"thread dealloc");
    
    self.placeHoldNote = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver: self];

    NSMutableArray* knotesArray = [ThreadItemManager sharedInstance].knotesArray;
    [knotesArray removeAllObjects];
}

- (void)AddObserversForSelectedPad
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topicChangedIdNotificationReceived:)
                                                 name:@"TOPIC_CHANGED_ID"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(needRefreshView)
                                                 name:NEW_CONTACT_DOWNLOADED_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(fileDownloaded:)
                                                 name:FILE_DOWNLOADED_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topicChange)
                                                 name:KnotebleTopicChange
                                               object:nil];
    /*
     [[NSNotificationCenter defaultCenter] addObserver:self
     selector:@selector(hideLoadingView)
     name:HIDE_NOTIFYVIEW_NOTIFICATION
     object:nil];
     */
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(operatorThreadItem:)
                                                 name:OperatorThreadItemNotification
                                               object:nil];
    /****Dhruv : Causes crash, Dont see it useful.*********/

    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newKnotePosted)
                                                 name:@"new_knote_posted" object:nil];*/
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(knotesAdded:)
                                                 name:@"topic_added"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(knotesAdded:)
                                                 name:@"topic_changed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(knotesAdded:)
                                                 name:@"allRestKnotesByTopicId_added"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(knotesAdded:)
                                                 name:@"allRestKnotesByTopicId_changed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(knotesRemoved:)
                                                 name:@"allRestKnotesByTopicId_removed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(knotesAdded:)
                                                 name:@"knotes_added"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(knotesAdded:)
                                                 name:@"messages_added"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(knotesAdded:)
                                                 name:@"messages_changed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(knotesRemoved:)
                                                 name:@"knotes_removed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(knotesChanged:)
                                                 name:@"knotes_changed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(addedTopic:)
                                                 name:TOPICS_ADDEDED_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(changedTopic:)
                                                 name:TOPICS_CHANGED_NOTIFICATION
                                               object:nil];
    
    
    // Knote Count part
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotActiveKnotesCount:)
                                                 name:@"NumberOfKnotesOnCurrentPad_added"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotActiveKnotesCount:)
                                                 name:@"NumberOfKnotesOnCurrentPad_changed"
                                               object:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotPinnedKnotesCount:)
                                                 name:@"NumberOfPinnedKnotesOnCurrentPad_added"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotPinnedKnotesCount:)
                                                 name:@"NumberOfPinnedKnotesOnCurrentPad_changed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotArchivedKnotesCount:)
                                                 name:@"NumberOfArchivedKnotesOnCurrentPad_added"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotArchivedKnotesCount:)
                                                 name:@"NumberOfArchivedKnotesOnCurrentPad_changed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotRestKnotesCount:)
                                                 name:@"NumberOfRestKnotesOnCurrentPad_added"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotRestKnotesCount:)
                                                 name:@"NumberOfRestKnotesOnCurrentPad_changed"
                                               object:nil];
    
    // Check ready state
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(Ready_topic)
                                                 name:@"topic_ready"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(Ready_pinnedKnotes)
                                                 name:@"pinnedKnotesForTopic_ready"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(Ready_archivedKnotes)
                                                 name:@"archivedKnotesForTopic_ready"
                                               object:nil];
    
    
}

- (void)RemoveObserverFromSelectedPad
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"FILE_DOWNLOADED" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:OperatorThreadItemNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NEW_CONTACT_DOWNLOADED_NOTIFICATION object:nil];
    
    // Remove knotes Observers
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"knotes_added" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"knotes_changed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"knotes_removed" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"allRestKnotesByTopicId_added" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"allRestKnotesByTopicId_changed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"allRestKnotesByTopicId_removed" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"messages_added" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"messages_changed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"messages_removed" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TOPICS_ADDEDED_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TOPICS_CHANGED_NOTIFICATION object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HIDE_COMMENTINPUTVIEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:HIDE_NOTIFYVIEW_NOTIFICATION object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    /****Dhruv : Causes crash, Dont see it useful.*********/

    /*[[NSNotificationCenter defaultCenter] removeObserver:self name:@"new_knote_posted" object:nil];*/
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NumberOfKnotesOnCurrentPad_added" object:Nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NumberOfPinnedKnotesOnCurrentPad_added" object:Nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"NumberOfArchivedKnotesOnCurrentPad_added" object:Nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"topic_ready" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pinnedKnotesForTopic_ready" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"archivedKnotesForTopic_ready" object:nil];
    
    [self removeSubscriptionsToMeteorCollections];
}

-(void)removeCachedMessages{
    [MessageEntity truncateAll];
}

-(void)initWithTopicMethod:(TopicInfo *)tInfo{
    self.rearrangingCells = NO;
    
    self.finishLoad = NO;
    
    self.tInfo = tInfo;
    self.isPostingComment = NO;
    
    self.isKeyboardVisible = NO;
    self.isCreatingKnote = NO;
    self.newPadCreated = NO;
    
    self.focusedCommentCell = Nil;
    self.focusedCommentItem = Nil;
    
    self.isReady_topic = NO;
    self.isReady_archivedKnotes = NO;
    self.isReady_pinnedKnotes = NO;
    self.isReady_toGoBack = NO;
    
    self.count_topic = 0;
    self.count_pinnedKnotes = 0;
    self.count_archivedKnotes = 0;
    self.count_restKnotes = 0;
    self.counter_knote_added = 0;
    
    if (tInfo)
    {
        _isNewPad = NO;
        
        self.start_Subscription_date = [NSDate date];
        
        self.log_knotes_loading = Nil;
        
        self.log_knotes_loading = [NSDateFormatter localizedStringFromDate:self.start_Subscription_date
                                                                 dateStyle:NSDateFormatterShortStyle
                                                                 timeStyle:NSDateFormatterMediumStyle];
        /*
         #if DEBUG || ADHOC
         
         [[AppDelegate sharedDelegate] AutoHiddenAlert:@"Started - Knotes - Loading"
         messageContent:self.log_knotes_loading];
         
         #endif
         */
        
        // Turn off background task
//ying        [[DataManager sharedInstance] turnOffBackground];
//        [[DataManager sharedInstance]turnOnContactsInBackground];
        
        //                        [[AppDelegate sharedDelegate].meteor addSubscription:METEORCOLLECTION_KNOTE_TOPIC
        //                                                              withParameters:@[self.tInfo.topic_id]];
        //
        //                        [[AppDelegate sharedDelegate].meteor addSubscription:METEORCOLLECTION_KNOTE_PINNED
        //                                                              withParameters:@[self.tInfo.topic_id]];
        //
        //                        [[AppDelegate sharedDelegate].meteor addSubscription:METEORCOLLECTION_KNOTE_ARCHIVED
        //                                                              withParameters:@[self.tInfo.topic_id]];
        
        [self addSubscriptionsToMeteorCollectionsForTopicWithId: tInfo.topic_id];
    }
    else
    {
        _isNewPad = YES;
    }
    
    self.currentData = [[NSMutableArray alloc] init];
    self.rightData = [[NSMutableArray alloc] init];

    self.banPosition = 0;
    
    // Lin - Ended
    
    if (tInfo.entity.locked_id!=nil
        && [tInfo.entity.locked_id length]>0)
    {
        self.locked = YES;
    }
    
    self.nwCommentItem = Nil;
    self.focusedToCommentitem = Nil;
    
    // Lin - Ended
    
    self.itemsOpened = [NSMutableArray new];

    self.shouldReloadKnotes = YES;
}

- (id)initWithTopic:(TopicInfo *)tInfo
{
    self = [super init];
    
    if (self)
    {
        [self initWithTopicMethod:tInfo];
        
    }
    
    return self;
}

- (void) reloadThreads
{
    if (self.tInfo.entity.topic.length > 0)
    {
        self.mainTitle = self.tInfo.entity.topic;
        [self customizeTitleLabel];
    }

    [self ReoadLocalKnotes];
    [self.tableView reloadData];
    [self.tableViewRight reloadData];
}

- (void) updateTitleWith: (NSString*) newTitle
{
    if (newTitle.length == 0)
        return;
    
    if ([newTitle isEqualToString: self.mainTitle] == NO)
    {
        self.mainTitle = newTitle;
        [self customizeTitleLabel];
    }
}

- (void) customizeTitleLabel {
    if (self.titleLabel == nil)
    {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220, 44)];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        
        self.titleLabel.numberOfLines = 2;
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20]/*[UIFont boldSystemFontOfSize: 20.0f]*/;
        self.titleLabel.adjustsFontSizeToFitWidth=YES;
        
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor blackColor];
        
#if !K_SERVER_BETA
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleTaped:)];
        
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        tapGesture.cancelsTouchesInView = NO;
        [self.titleLabel addGestureRecognizer:tapGesture];
#endif

        self.titleLabel.userInteractionEnabled = YES;
    }
    
    self.titleLabel.text = self.mainTitle;
    self.navigationItem.titleView = self.titleLabel;
}

#pragma mark View Lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    /*********Navigation Bar changes as per New Design************/
    NSDictionary *navBarTitleAttr =[NSDictionary dictionaryWithObjectsAndKeys:
                                    [DesignManager knoteTitleFont],NSFontAttributeName,
                                    [UIColor blackColor], NSForegroundColorAttributeName, nil];
    
    [self.navigationController.navigationBar setTitleTextAttributes: navBarTitleAttr];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
    {
        /*for iOS 7 and newer*/
        [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithWhite:0.941 alpha:1.000]];
    }
    else
    {
        /*for older versions than iOS 7*/
        [self.navigationController.navigationBar setTintColor:[UIColor colorWithWhite:0.941 alpha:1.000]];
    }
    [(KnotableNavigationController *)self.navigationController navBorder].hidden=YES;
    /*********************/
    self.view.hidden = NO;
//    [self initWithTopicMethod:self.tInfo];
//    [self.tableView reloadData];

    if (self.isNewTopicAdded)
    {
        self.view.hidden=YES;
        self.navigationController.navigationBarHidden=YES;
        self.isNewTopicAdded = NO;

        ComposeThreadViewController *composeThreadViewController = [[ComposeThreadViewController alloc] initForNewPad];
        composeThreadViewController.shouldPopToMainView          = self.shouldPopToMainView;
        composeThreadViewController.topic_id                     = self.tInfo.entity.topic_id;
        composeThreadViewController.subject                      = self.tInfo.entity.topic;//self.mainTitle;
        composeThreadViewController.delegate                     = self;
        composeThreadViewController.opType                       = ItemAdd;
        composeThreadViewController.itemLifeCycleStage           = ItemNew;
        
        CKeyNoteItem *item = nil;
        for (int i = 0; i < [self.currentData count]; i++) {
            item = [self.currentData objectAtIndex:i];
            if ([item isKindOfClass:[CKeyNoteItem class]]) {
                composeThreadViewController.keyItem = item;
                break;
            }
        }

        [self.navigationController pushViewController:composeThreadViewController animated:NO];
    }
    else
    {
        NSLog(@"Knotable: Seeing topic with id: %@", self.tInfo.topic_id);
//        [self addSubscriptionsToMeteorCollectionsForTopicWithId:self.tInfo.topic_id];
        self.navigationController.navigationBarHidden=NO;
        self.view.hidden=NO;
    }

    [self saveCurrentTopicID];

//    [self.navigationController.navigationBar addSubview:self.titleLabel];
    [ReachabilityManager sharedInstance].delegate = self;
    
//    self.navigationController.navigationBarHidden = NO;
//    self.navigationController.navigationBar.translucent = NO;
//    [self.navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
    
#if !New_DrawerDesign
    if (self.headerTitle) {
        [self.headerTitle.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    }
#endif
    // Lin - Added to implement New Comment post method
    
    if (_isNewPad == NO) {
        
        if (self.currentData.count > 0)
        {
            [self HideEmptyPadOverlay];
            [self removeDeletedMessage];
//          [self stopActivityView]; @malik
        }
    }
    else
    {
//        [self titleTaped:nil];
//        [self ShowEmptyPadOverlay:YES];
    }
    
    //Lin - Ended
    
#if New_DrawerDesign
    [self createFloatingMenu];
    self.stack.hidden=NO;
#endif
#if ChangeInDrawer
    [self addScreenGesturein];
#endif
    
    if(self.shouldReloadKnotes){
        self.shouldReloadKnotes = NO;
        [self.loadingGhostScreen removeFromSuperview];
        self.tableView.tableHeaderView=nil;
        [self ReoadLocalKnotes];
        [self.tableView reloadData];
        [self.tableViewRight reloadData];
    }
//    [self.tableView reloadData];
    
    if (self.currentData.count > 0)
    {
        [self HideEmptyPadOverlay];
    }
    else
    {
        [self ShowEmptyPadOverlay:YES];
    }
}
#if New_DrawerDesign
-(void)showDrawer
{
    SideMenuViewController  *contentView = [[SideMenuViewController alloc] init];
    contentView.Cur_account=[DataManager sharedInstance].currentAccount;
    contentView.targetDelegate = self;
    self.sideBar.isShowingFromRight = NO;
    [self.sideBar ShowSideBarWithAnimationWithController:contentView animated:YES];
}

-(void)loggingOutExtras
{
    self.stack.hidden=YES;
    [self.stack removeFromSuperview];
    self.stack=nil;
    [self.sideBar hideSideBarWithAnimation:NO];
    [self.sideBar removeFromSuperview];
    self.sideBar=nil;
}

- (void)BottomMenuActionIndex:(NSInteger)butIndex
{
    self.isNeedShowStack = NO; // avoid show stack button
    [self.sideBar hideSideBarWithAnimation: NO];

    if (butIndex == 1)
    {
        UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
        UIViewController* aboutController = [mainStoryBoard instantiateViewControllerWithIdentifier: @"aboutIdentity"];
        [self.navigationController pushViewController: aboutController animated: YES];
    }
    else if (butIndex == 2)
    {
        UIStoryboard* mainStoryBoard = [UIStoryboard storyboardWithName: @"Main" bundle: nil];
        ProfileDetailVC* profileVC = [mainStoryBoard instantiateViewControllerWithIdentifier: @"settingController"];
        
        AccountEntity* account = [DataManager sharedInstance].currentAccount;
        profileVC.account = account;
        profileVC.user = account.user;
        
        profileVC.logOUTInstance = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];

        [self.navigationController pushViewController: profileVC animated: YES];
    }
}

#endif

- (void)addSubscriptionsToMeteorCollectionsForTopicWithId:(NSString *)topicId {
    if (!self.isSubscribed && self.tInfo != nil) {
//ying        [[DataManager sharedInstance] turnOffBackground];
        [[AppDelegate sharedDelegate].meteor addSubscription:METEORCOLLECTION_KNOTE_TOPIC withParameters:@[self.tInfo.topic_id]];
        [[AppDelegate sharedDelegate].meteor addSubscription:METEORCOLLECTION_KNOTE_PINNED withParameters:@[self.tInfo.topic_id]];
        [[AppDelegate sharedDelegate].meteor addSubscription:METEORCOLLECTION_KNOTE_ARCHIVED withParameters:@[self.tInfo.topic_id]];
        
        self.isSubscribed=YES;
    }
}

- (void)removeSubscriptionsToMeteorCollections {
    [[AppDelegate sharedDelegate].meteor removeSubscription:METEORCOLLECTION_KNOTES];
    [[AppDelegate sharedDelegate].meteor removeSubscription:METEORCOLLECTION_KNOTE_TOPIC];
    [[AppDelegate sharedDelegate].meteor removeSubscription:METEORCOLLECTION_KNOTE_PINNED];
    [[AppDelegate sharedDelegate].meteor removeSubscription:METEORCOLLECTION_KNOTE_ARCHIVED];
    [[AppDelegate sharedDelegate].meteor removeSubscription:METEORCOLLECTION_KNOTE_REST];
    self.isSubscribed = NO;
}

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.mainTitle = defaultTopicName;
    
    if (self.tInfo.entity.topic.length > 0)
    {
        self.mainTitle = self.tInfo.entity.topic;
    }

    [self customizeTitleLabel];
    
    self.isNeedShowStack = YES;

    if (self.currentData == nil)
        self.currentData = [NSMutableArray new];
    self.mainTitle = [NSString new];
    self.sortOrderMapArray = [NSMutableArray new];
    
    self.showFooter = NO;
    
    self.isUpdationOver=YES;
    
    self.login_user = [DataManager sharedInstance].currentAccount.user;
    
    self.showArchived = NO;
    
    self.firstIn = YES;
    
    // CommentInput
    self.commentInput = [ChatInput new];
    self.commentInput.stopAutoClose = NO;
    self.commentInput.placeholderLabel.text = @"  Write a comment...";
    self.commentInput.delegate = self;
    self.commentInput.backgroundColor = [UIColor colorWithWhite:1 alpha:0.825f];
    [self.commentInput setHidden:YES];
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        self.automaticallyAdjustsScrollViewInsets = YES;
    }
    
#endif
#if !New_DrawerDesign
    UIImage *barButtonBgImage = [UIImage imageNamed:@"Note_Icon.png"];
    UIButton *customBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customBarButton.bounds = CGRectMake( 0, 0, barButtonBgImage.size.width, barButtonBgImage.size.height);
    [customBarButton setImage:barButtonBgImage forState:UIControlStateNormal];
    [customBarButton addTarget:self action:@selector(knoteClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.createKnoteButton = [[UIBarButtonItem alloc] initWithCustomView:customBarButton];
#else
    UIImage *barButtonBgImage = [UIImage imageWithIcon:@"fa-user" backgroundColor:[UIColor clearColor] iconColor:[UIColor blackColor] andSize:CGSizeMake(22, 22)];

    UIButton *customBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    customBarButton.bounds = CGRectMake( 0, 0, 30, 30);
    [customBarButton setImage:barButtonBgImage forState:UIControlStateNormal];
    [customBarButton addTarget:self action:@selector(showSharedDrawer) forControlEvents:UIControlEventTouchUpInside];
    self.sharedPeopleButton = [[UIBarButtonItem alloc] initWithCustomView:customBarButton];
#endif
    [self setupTopRightButtons];
    
    ////  Left Button
    self.navigationItem.hidesBackButton = YES;
    
#if 1// New_DrawerDesign
    UIImage * leftBarButnImg = [[UIImage imageNamed:@"menuicon"] imageTintedWithColor:[UIColor blackColor]];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:leftBarButnImg forState:UIControlStateNormal];
    [button setFrame:CGRectMake(0, 0, leftBarButnImg.size.width, leftBarButnImg.size.height)];
    [button addTarget:self action:@selector(showDrawer) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * leftDrowerMenu = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem = leftDrowerMenu;
#else
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:self.navigationItem.backBarButtonItem.style target:nil action:nil];
    UIImage *backImage = [UIImage imageWithIcon:@"fa-angle-left" backgroundColor:[UIColor clearColor] iconColor:[UIColor blackColor] andSize:CGSizeMake(30, 30)];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [backButton setImage:backImage forState:UIControlStateNormal];
    [backButton setFrame:CGRectMake(0, 0, backImage.size.width, backImage.size.height)];
    
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -15, 0, 0);
    
    [backButton addTarget:self
                   action:@selector(ThreadPopBack)
         forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    self.navigationItem.leftBarButtonItem = backButtonItem;
#endif
    ////
    self.title = @"Knotes";
    
    // Define Navigation Sort Button
    
    if (self.emptyNotifyView == Nil)
    {
        self.emptyNotifyView = [[KnoteEPNV alloc] init];
        
        self.emptyNotifyView.targetDelegate = self;
    }
    
    // Define Loading View
    self.view.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1.0];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (self.tableView == nil)
    {
        CGRect frame = self.view.bounds;
        self.tableView = [[RichTableView alloc] initWithFrame: frame];
        _loadingGhostScreen=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-64)];
        _loadingGhostScreen.image=[UIImage imageNamed:@"GhostScreen"];
        self.tableView.tableHeaderView=_loadingGhostScreen;
        self.tableView.canReorder = NO;
        self.tableView.delegate = self;
        self.tableView.richDelegate = self;
        self.tableView.dataSource = self;
        //self.tableView.backgroundColor = [DesignManager appBackgroundColor];
        self.tableView.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1.0];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.separatorInset = UIEdgeInsetsZero;
        self.tableView.contentOffset=CGPointMake(0, 0);
//        CGRect frame = self.tableView.frame;
        frame.origin.x= frame.size.width;
        self.tableViewRight = [[RichTableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
        self.tableViewRight.canReorder = NO;
        self.tableViewRight.delegate = self;
        self.tableViewRight.richDelegate = self;
        self.tableViewRight.dataSource = self;
        //self.tableViewRight.backgroundColor = [DesignManager appBackgroundColor];
        self.tableViewRight.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1.0];
        self.tableViewRight.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableViewRight.separatorInset = UIEdgeInsetsZero;
        
        /*frame.origin.x = 0;
         frame.origin.y -=50;
         frame.size.height = 50;
         UIView *view = [[UIView alloc] initWithFrame:frame];*/
        
        
        //create and add functionallity to page indicators
        
        CGRect dotFrame = CGRectMake(self.tableView.frame.size.width/2 - 15, 5, 10,10);
        
        self.firstDot = [[UIImageView alloc] initWithFrame:dotFrame];
        [self.firstDot setImage:[[UIImage imageNamed:@"blue_dot.png"] imageTintedWithColor:[UIColor colorWithRed:0.094 green:0.557 blue:0.996 alpha:1.000]]];
        
        dotFrame.origin.x += 20;
        self.secondDot = [[UIImageView alloc] initWithFrame:dotFrame];
        [self.secondDot setImage:[UIImage imageNamed:@"gray_dot.png"]];
        
        [self.secondDot.layer setZPosition:3];
        [self.firstDot.layer setZPosition:3];
        
        
        UITapGestureRecognizer *firstTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
        [firstTap setNumberOfTapsRequired:1];
        [self.firstDot setUserInteractionEnabled:YES];
        [self.firstDot addGestureRecognizer:firstTap];
        [self.firstDot setHidden:YES];
        
        UITapGestureRecognizer *secondTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
        [secondTap setNumberOfTapsRequired:1];
        [self.secondDot setUserInteractionEnabled:YES];
        [self.secondDot addGestureRecognizer:secondTap];
        [self.secondDot setHidden:YES];
        
        [self.view addSubview:self.firstDot];
        [self.view addSubview:self.secondDot];
        
        /*UIPageControl *pageControl = [[UIPageControl alloc] init];
         pageControl.frame = CGRectMake(0, frame.origin.y, 320, 50);
         pageControl.numberOfPages = 2;
         
         pageControl.backgroundColor = [UIColor blueColor];
         pageControl.currentPage = 0;
         [self.view addSubview:pageControl];*/
        
        //[self.view addSubview:[[UIView alloc] initWithFrame:context ]];
        
        UISwipeGestureRecognizer *recognizerLeft;
        recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeLeft:)];
        //There is a direction property on UISwipeGestureRecognizer. You can set that to both right and left swipes
        recognizerLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        UISwipeGestureRecognizer *recognizerRight;
        recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeRight:)];
        //There is a direction property on UISwipeGestureRecognizer. You can set that to both right and left swipes
        recognizerRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self.tableView addGestureRecognizer:recognizerLeft];
        [self.tableViewRight addGestureRecognizer:recognizerRight];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(longPress:)];
        [self.tableView addGestureRecognizer:longPress];
        
        
        [self.view addSubview:self.tableView];
        [self.view addSubview:self.tableViewRight];
        //[self.view addSubview:view];
        
        NSLog(@"View Frame : %@", NSStringFromCGRect(self.view.frame));
        
        /*
         [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(@0);
         make.left.equalTo(@0);
         make.right.equalTo(@0);
         #if !New_DrawerDesign
         make.bottom.equalTo(@(-BottomMenuHeight));    // This is the height of bottom view
         #else
         make.bottom.equalTo(@0);    // This is the height of bottom view
         #endif
         }];*/
    }
#if !New_DrawerDesign
    if (!self.headerTitle)
    {
        self.headerTitle = [[CEditHeaderItemView alloc] init];
        self.headerTitle.delegate = self;
    }
#endif
    if (!self.bottomPadUserView)
    {
        self.bottomPadUserView = [[KnotePUV alloc] init];
        self.bottomPadUserView.backgroundColor = [UIColor clearColor];
    }
#if !New_DrawerDesign
    if (!self.menuWithSharePad)
    {
        self.menuWithSharePad = [[UIToolbar alloc] init];
        
        CustomBarButtonItem *shareItem = [CustomBarButtonItem barItemWithImage:[UIImage imageNamed:@"icon_people_shared"]
                                                                 selectedImage:[[UIImage imageNamed:@"icon_people_shared"]
                                                                                imageTintedWithColor:[UIColor lightGrayColor]]
                                                                        target:self
                                                                        action:@selector(sharedButtonClicked)];
        
        UIBarButtonItem* spaceButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                      target:nil
                                                      action:nil];
        
        self.menuWithSharePad.items = @[spaceButtonItem, shareItem, spaceButtonItem];
        self.menuWithSharePad.backgroundColor = [DesignManager knoteNavigationBarTintColor];
        
        if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
        {
            [self.menuWithSharePad setBarTintColor:[DesignManager knoteNavigationBarTintColor]];
        }
        else
        {
            [self.menuWithSharePad setTintColor:[DesignManager knoteNavigationBarTintColor]];
        }
    }
    
    self.headerTitle.titleLabel.text = self.mainTitle;
    self.headerTitle.titleLabel.delegate = self;
#endif
//    self.navigationController.navigationBar.topItem.title = @"";
    
    [ThreadItemManager sharedInstance].offline = ([ReachabilityManager sharedInstance].currentNetStatus == NotReachable);
    
    self.isRefreshAnimating = NO;
    
    if (_isNewPad || !self.tInfo)
    {
        [self HideEmptyPadOverlay];
    }
    
#if 0
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, touchAreaWidth, touchAreaHeight)];
    titleView.backgroundColor = [UIColor clearColor];
    [self.navigationItem setTitleView:titleView];
    
    UITapGestureRecognizer *navBarTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(navBarTapped:)];
    [titleView addGestureRecognizer:navBarTapRecognizer];
    
#endif
#if !New_DrawerDesign
    self.headerTitle.itemArray = [self getSharedPeople:YES];
    
    [self.bottomPadUserView addSubview:self.headerTitle];
    
    [self.headerTitle setFrame:CGRectMake(0, 0, 320, BottomMenuHeight)];
    
    [self.headerTitle.collectionView reloadData];
    
    [self.headerTitle.collectionView setScrollsToTop:YES];
    
    if (self.headerTitle)
    {
        [self.headerTitle.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]
                                                atScrollPosition:UICollectionViewScrollPositionCenteredVertically
                                                        animated:YES];
    }
#endif
    
    // Lin - Added to fix - https://trello.com/c/Jl7LlMu2/890-qa-feedback-ui-tweaks
#if !New_DrawerDesign
    [self.bottomPadUserView addSubview:self.menuWithSharePad];
    
    [self.menuWithSharePad setFrame:CGRectMake(0, 0, 320, BottomMenuHeight)];
    
    if ([self.headerTitle.itemArray count] <= 0)
    {
        [self.menuWithSharePad setHidden:NO];
        [self.bottomPadUserView bringSubviewToFront:self.menuWithSharePad];
    }
    else
    {
        [self.menuWithSharePad setHidden:YES];
        [self.bottomPadUserView sendSubviewToBack:self.menuWithSharePad];
    }
#endif
    // Lin - Ended
    
    CGRect frame = self.view.bounds;
    
    CGRect  menuBarFrame = CGRectMake(0, frame.size.height- 64 - BottomMenuHeight , 320, BottomMenuHeight);
#if !New_DrawerDesign
    [self.headerTitle setBackgroundColor:[DesignManager KnoteBMBBackgroundColor]];
#endif
    [self.view addSubview:self.bottomPadUserView];
    
    [self.bottomPadUserView setFrame:menuBarFrame];
    
    // Lin - Ended
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taped:)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    tapGesture.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGesture];
    
    if ([self.currentData count] <= 1 )
    {
        if (!self.placeHoldNote)
        {
            self.placeHoldNote = [[CKnoteItem alloc] init];
            self.placeHoldNote.height = 42;
            
            NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            
            NSString *text = @"     Partial pad. Pull to refresh";
            
            NSDictionary *attributedTextProperties = @{
                                                       NSFontAttributeName:[DesignManager knoteBodyFont],
                                                       NSForegroundColorAttributeName:[DesignManager knoteBodyTextColor],
                                                       NSBackgroundColorAttributeName:[UIColor clearColor],
                                                       NSParagraphStyleAttributeName:[paragraphStyle copy]
                                                       };
            
            NSMutableAttributedString *mutAttStr = [[[NSAttributedString alloc] initWithString:text attributes:attributedTextProperties] mutableCopy];
            
            self.placeHoldNote.attributedString = [mutAttStr copy];
            
            // Lin - Marked : Do we need to add this item?
            
            [self.currentData addObject:self.placeHoldNote];
        }
    }
    /* _pullToRefreshManager = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:60.0f tableView:_tableView withClient:self];*/
    
#if USE_HEADER_TRAY
    _needScroll = YES;
    [self updateHeaderInfo:_needScroll];
#endif
    
    [self AddObserversForSelectedPad];
    
#if ChangeInDrawer
    [self CreateSideBar];
#endif
}

#if ChangeInDrawer
-(void)CreateSideBar
{
    self.sideBar = [[CustomSideBar alloc] initSideBarisShowingFromRight:NO withDelegate:self];
}
-(void)addScreenGesturein
{
    UIScreenEdgePanGestureRecognizer *panRecognizer =
    [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(handleScreenEdge:)];
    panRecognizer.edges = UIRectEdgeRight;
    [[_sideBar getMainViewController].view addGestureRecognizer:panRecognizer];
}
-(void)handleScreenEdge:(UIScreenEdgePanGestureRecognizer *)gesture
{
    __block ShareListController *shareList;
    UIAlertView *alert;
    UINavigationController *nav;
    switch (gesture.state)
    {
        case UIGestureRecognizerStateBegan:
            
            shareList = [[ShareListController alloc] initWithTopic:self.tInfo.entity loginUser:self.login_user sharedContacts:[self getSharedPeople:YES] isForCombinedView:YES];
            
            
            if (!self.tInfo || !self.tInfo.entity)
            {
                if ([self.mainTitle length]<=0)
                {
                    self.mainTitle = @"Untitled";
                }
                
                alert = [[UIAlertView alloc] initWithTitle:@"Enter a title to share the pad"
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Cancel"
                                         otherButtonTitles:@"Ok", nil];
                
                alert.tag = 100;
                [alert show];
                
                return;
            }
            
            shareList.delegate = self;
            nav=[[UINavigationController alloc]initWithRootViewController:shareList];
            nav.view.backgroundColor=[UIColor whiteColor];
            self.sideBar.ContainerInSidebar=nav;
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

- (void)newTopicCreatedFromComposeView:(TopicInfo *)topic {
    self.isNewTopicAdded = NO;
    self.tInfo = topic;
    
    self.tInfo.entity = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:self.tInfo.topic_id];
    self.tInfo.entity.contact_id = [DataManager sharedInstance].currentAccount.user.contact.contact_id;
    self.tInfo.item.userData = [MessageEntity MR_findFirstByAttribute:@"message_id" withValue:self.tInfo.message_id];
    self.tInfo.entity.hasNewActivity = @(YES);
    
    if ([DataManager sharedInstance].currentAccount.user.contact) {
        NSMutableSet *topicContacts = [[NSMutableSet alloc] init];
        [topicContacts addObject:[DataManager sharedInstance].currentAccount.user.contact];
        self.tInfo.entity.contacts = [topicContacts copy];
    }
    
    [self updateTitleWith: topic.entity.topic];
//    self.title = @"Notes";
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(needChangeTopicTitle:)]) {
        [self.delegate needChangeTopicTitle:self.tInfo];
    }
    
    self.isNewPad = NO;
    self.newPadCreated = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"topics_added" object:self];
    //    [self needRefreshView];
}

- (void) changeTopic:(TopicInfo*) newTopic
{
    if (self.tInfo != nil)
    {
        [self removeSubscriptionsToMeteorCollections];
    }

    self.tInfo = newTopic;
    [self saveCurrentTopicID];

    [self addSubscriptionsToMeteorCollectionsForTopicWithId: newTopic.topic_id];
    [self updateTitleWith: newTopic.entity.topic];

    for (CItem* item in self.currentData)
    {
        if ([item.topic isEqual: newTopic.entity] == NO)
        {
            item.topic = newTopic.entity;
            item.topic.needSend = @(YES);
        }
    }
}

- (void) saveCurrentTopicID
{
    if (self.tInfo == nil)
        return;

#if !K_SERVER_BETA
    lastTopicId = self.tInfo.entity.topic_id;
    NSUserDefaults* userInfo = [NSUserDefaults standardUserDefaults];
    [userInfo setObject: lastTopicId forKey: @"lastTopicID"];
    [userInfo synchronize];
#endif
}

#endif
//- (void)viewDidDisappear:(BOOL)animated
//{
//    [self.titleLabel removeFromSuperview];
//    [super viewDidDisappear:YES];
//}

- (void)viewWillDisappear:(BOOL)animated
{
    [self HideKnoteLoadingView];
    
#if ChangeInDrawer
    for (UIGestureRecognizer *recognizer in [_sideBar getMainViewController].view.gestureRecognizers) {
        if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]])
        {
            [[_sideBar getMainViewController].view removeGestureRecognizer:recognizer];
        }
    }
#endif
#if NEW_FEATURE
    
    for (CItem *item in self.currentData)
    {
        if (item.userData && ![item.userData isFault])
        {
            item.userData.expanded = NO;
        }
    }
    
    [AppDelegate saveContext];
    
#endif
    
    if ([self isMovingFromParentViewController])
    {
        [AppDelegate saveContext];
    }
    
    [self HideEmptyPadOverlay];
    
#if New_DrawerDesign
    
    self.stack.hidden=YES;
    
#endif
    [super viewWillDisappear:animated];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Disable iOS 7 back gesture
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)])
    {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        self.navigationController.interactivePopGestureRecognizer.delegate = self;
    }

#if 0
    UIMenuItem *highlightMenuItem = [[UIMenuItem alloc] initWithTitle:@"Highlight" action:@selector(highlight:)];
    UIMenuItem *quoteMenuItem = [[UIMenuItem alloc] initWithTitle:@"Quote" action:@selector(quoteText:)];
    
    [UIMenuController sharedMenuController].menuItems = @[highlightMenuItem, quoteMenuItem];
#else
    //    UIMenuItem *quoteMenuItem = [[UIMenuItem alloc] initWithTitle:@"Quote" action:@selector(quoteText:)];
    //    [UIMenuController sharedMenuController].menuItems = @[ quoteMenuItem];
#endif
    
    AppDelegate* app = [AppDelegate sharedDelegate];
    
    if (app.needUseClipBoard)
    {
        if (self.firstIn)
        {
            /*UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
             
             if ([pasteboard.string length]>0)
             {*/
            ComposeThreadViewController *vc = [[ComposeThreadViewController alloc] init];
            
            vc.topic_id = self.tInfo.entity.topic_id;
            vc.subject = self.mainTitle;
            vc.delegate = self;
            
            [self.navigationController pushViewController:vc animated:YES];
            //}
        }
    }
    
//ying    if (app.meteor && app.meteor.connected)
//    {
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(changedTopic:)
//                                                     name:TOPICS_CHANGED_NOTIFICATION
//                                                   object:nil];
//    }
    
    if (_isNewPad == NO)
    {
        [self HideEmptyPadOverlay];
    }
    else
    {
    }
    
    if (self.firstIn)
    {
        self.firstIn = NO;
    }
    
    if ( self.currentData == nil || self.currentData.count == 0) {
        NSLog(@"Callling LOADRESTKNOTES");
        //  [_pullToRefreshManager tableViewReleased];
    }
    
//    if (self.isAutoCreated)
//    {
//        NSDictionary* last_compose = [[NSUserDefaults standardUserDefaults] objectForKey: lastComposeKey];
//        if (last_compose) {
//            [self addNewItemWithLastContent: last_compose];
//        }
//        else
//        {
//            [self addNewItem: C_KNOTE];
//        }
//        self.isAutoCreated = NO;
//    }
}

- (void) showComposeViewController:(BOOL) usingLastEditInfo animated: (BOOL) animated
{
    NSDictionary* last_compose = [[NSUserDefaults standardUserDefaults] objectForKey: lastComposeKey];
    if (last_compose && usingLastEditInfo) {
        [self addNewItemWithLastContent: last_compose animated: animated];
    }
    else
    {
        [self addNewItem: C_KNOTE animated: animated];
    }
}

- (void)handleSwipeLeft:(UISwipeGestureRecognizer *)recognizer{
    
    if (self.rightData.count > 0) {
        NSLog(@"swipe left direction: %lu",(unsigned long)recognizer.direction);
        
        CGRect oldFrameRight = self.tableView.frame;
        oldFrameRight.origin.x = self.tableView.frame.size.width;
        [self.tableViewRight setFrame:oldFrameRight];
        
        CGRect oldFrameLeft = self.tableView.frame;
        oldFrameLeft.origin.x = 0;
        
        CGRect newFrameRight = self.tableView.frame;
        newFrameRight.origin.x = 0;
        
        CGRect newFrameLeft = self.tableView.frame;
        newFrameLeft.origin.x = - newFrameLeft.size.width;
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        
        [self.tableViewRight setFrame:newFrameRight];
        [self.firstDot setImage:[UIImage imageNamed:@"gray_dot.png"]];
        [self.secondDot setImage:[[UIImage imageNamed:@"blue_dot.png"] imageTintedWithColor:[UIColor colorWithRed:0.094 green:0.557 blue:0.996 alpha:1.000]]];
        [self.tableView setFrame:newFrameLeft];
        
        [UIView commitAnimations];
    }
}

- (void)handleSwipeRight:(UISwipeGestureRecognizer *)recognizer{
    // NSLog(@"swipe right direction: %lu",(unsigned long)recognizer.direction);
    CGRect oldFrameRight = self.tableView.frame;
    oldFrameRight.origin.x = 0;
    [self.tableViewRight setFrame:oldFrameRight];
    
    CGRect oldFrameLeft = self.tableView.frame;
    oldFrameLeft.origin.x = - oldFrameLeft.size.width;
    
    CGRect newFrameRight = self.tableView.frame;
    newFrameRight.origin.x = newFrameRight.size.width;
    
    CGRect newFrameLeft = self.tableView.frame;
    newFrameLeft.origin.x = 0;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    [UIView setAnimationDelay:0.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    
    [self.tableViewRight setFrame:newFrameRight];
    [self.firstDot setImage:[[UIImage imageNamed:@"blue_dot.png"] imageTintedWithColor:[UIColor colorWithRed:0.094 green:0.557 blue:0.996 alpha:1.000]]];
    [self.secondDot setImage:[UIImage imageNamed:@"gray_dot.png"]];
    [self.tableView setFrame:newFrameLeft];
    
    [UIView commitAnimations];
}

#if USE_HEADER_TRAY
- (void)scrollUp
{
    [self.tableView setContentOffset:CGPointMake(0, CGRectGetHeight(self.tableView.tableHeaderView.bounds)) animated:NO];
    [self.tableViewRight setContentOffset:CGPointMake(0, CGRectGetHeight(self.tableViewRight.tableHeaderView.bounds)) animated:NO];
}

-(void)updateHeaderInfo:(BOOL)flag
{
    NSInteger voteIndex = -1,taskIndex = -1,dateIndex = -1;
    
    self.headerInfoDic  = [NSMutableDictionary new];
    
    NSArray *auxArray;
    
    if (self.tableView.frame.origin.x == 0) {
        auxArray = self.currentData;
    }else{
        auxArray = self.rightData;
    }
    
    
    for (int i = 0; i<auxArray.count; i++)
    {
        CItem *item = auxArray[i];
        if (item.type == C_LIST)
        {
            if (taskIndex==-1)
            {
                taskIndex = i;
                self.headerInfoDic[@"C_LIST"] = @(taskIndex);
            }
            else if (self.headerInfoDic[@"C_LIST"])
            {
                [self.headerInfoDic removeObjectForKey:@"C_LIST"];
            }
        }
        if (item.type == C_VOTE)
        {
            if (voteIndex==-1)
            {
                voteIndex = i;
                self.headerInfoDic[@"C_VOTE"] = @(voteIndex);
            }
            else if (self.headerInfoDic[@"C_VOTE"])
            {
                [self.headerInfoDic removeObjectForKey:@"C_VOTE"];
            }
        }
        if (item.type == C_DATE)
        {
            if (dateIndex==-1)
            {
                dateIndex = i;
                self.headerInfoDic[@"C_DATE"] = @(dateIndex);
            }
            else if (self.headerInfoDic[@"C_DATE"])
            {
                [self.headerInfoDic removeObjectForKey:@"C_DATE"];
            }
        }
    }
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSInteger archivedNum = 0;
        if (self.tInfo.entity.topic_id)
        {
            NSMutableString *predicateString = [@"topic_id = %@" mutableCopy];
            NSMutableArray *arguments = [[NSMutableArray alloc] initWithObjects:[self.tInfo.entity.topic_id noPrefix:kKnoteIdPrefix], nil];
            [predicateString appendString :@" AND archived = YES"];
            NSArray *archivedArray = [MessageEntity MR_findAllWithPredicate:[NSPredicate predicateWithFormat:predicateString argumentArray:arguments]];
            archivedNum = archivedArray.count;
        }
        
        if (self.headerInfoDic[@"C_NUM"])
        {
            self.headerInfoDic[@"C_NUM"] = @(archivedNum);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (self.headerInfoDic)
            {
                self.headerInfoView.contentDic = self.headerInfoDic;
            }
        });
    });
    
#if USE_HEADER_TRAY
    
    if (!self.headerInfoView)
    {
        self.headerInfoView = [[CEditHeaderInfoView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 36)];
        self.headerInfoView.delegate = self;
        self.headerInfoView.showArchived = _showArchived;
    }
    
    [self.headerInfoView setFrame:CGRectMake(0, 0, CGRectGetWidth(self.tableView.bounds), 36)];
    
    if (flag)
    {
        [self scrollUp];
    }
#endif
}
#endif

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self resetAnimation];
    //NSLog(@"%f", scrollView.contentOffset.y);
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (_isAddedPullRefresh_toGetRest)
    {
        //// [_pullToRefreshManager tableViewReleased];
    }
}
- (void)resetAnimation
{
    // Reset our flags and background color
    self.isRefreshAnimating = NO;
    self.spinnerImageView.alpha = 0;
}

-(BOOL)isContentoffsetisNear:(CGPoint)offset
{
    if (offset.y<=40)
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

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_isAddedPullRefresh_toGetRest)
    {
        //// [_pullToRefreshManager tableViewReleased];
    }
    
    [self setHiddenAnimated:![self isContentoffsetisNear:scrollView.contentOffset] forView:self.stack];
    if (scrollView.contentOffset.y<=0)
    {
        [(KnotableNavigationController *)self.navigationController navBorder].hidden=YES;
    }
    else
    {
        [(KnotableNavigationController *)self.navigationController navBorder].hidden=NO;
    }
    /* if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.bounds.size.height) && _isAddedPullRefresh_toGetRest)
     {
     // Don't animate
     self.spinnerImageView.alpha =1;
     [self loadRestknotes];
     }*/
    
    /*
     if(scrollView.contentOffset.y < -60)
     self.spinnerImageView.alpha = 1;
     
     #if USE_HEADER_TRAY
     
     
     CGFloat currentOffsetY = scrollView.contentOffset.y;
     
     NJKScrollDirection currentScrollDirection = detectScrollDirection(currentOffsetY, _previousOffsetY);
     
     CGFloat topBoundary = -scrollView.contentInset.top;
     CGFloat bottomBoundary = scrollView.contentSize.height + scrollView.contentInset.bottom;
     
     BOOL isOverTopBoundary = currentOffsetY <= topBoundary;
     BOOL isOverBottomBoundary = currentOffsetY >= bottomBoundary;
     
     BOOL isBouncing = (isOverTopBoundary && currentScrollDirection != NJKScrollDirectionDown) || (isOverBottomBoundary && currentScrollDirection != NJKScrollDirectionUp);
     if (isBouncing || !scrollView.isDragging) {
     return;
     }
     
     CGFloat deltaY = _previousOffsetY - currentOffsetY;
     _accumulatedY += deltaY;
     
     // reset acuumulated y when move opposite direction
     if (!isOverTopBoundary && !isOverBottomBoundary && self.previousScrollDirection != currentScrollDirection) {
     self.accumulatedY = 0;
     }
     
     self.previousScrollDirection = currentScrollDirection;
     self.previousOffsetY = currentOffsetY;
     
     #endif
     */
}

- (void)ShowEmptyPadOverlay:(BOOL)showSlogan
{
    if ([self.emptyNotifyView.superview isEqual:self.view])
    {
        [self.emptyNotifyView removeFromSuperview];
    }
    
    [self.view addSubview:self.emptyNotifyView];
    
    if (showSlogan)
    {
        [self.emptyNotifyView.lbl_Slogan setHidden:NO];
        
    }
    else
    {
        [self.emptyNotifyView.lbl_Slogan setHidden:YES];
    }
    
    [self setupTopRightButtons];
    
    CGFloat notify_xPos = 0.0f;
    CGFloat notify_yPos = 0.0f;
    
    notify_xPos = (320 - self.emptyNotifyView.frame.size.width) / 2;
    notify_yPos = 0;
    
    [self.emptyNotifyView setFrame:CGRectMake(notify_xPos, notify_yPos, self.emptyNotifyView.frame.size.width, self.emptyNotifyView.frame.size.height)];
}

-(void)updateChangedKnote:(CItem *)item{
    
    int indexOfItem = 0;
    for(int i = 0; i < self.currentData.count; i++){
        CItem * it = [self.currentData objectAtIndex:i];
        if([it.itemId isEqualToString:item.itemId])
        {
            indexOfItem = i;
            [self.currentData replaceObjectAtIndex:indexOfItem withObject:item];
            break;
        }
    }
    
    indexOfItem = 0;
    for(int i = 0; i < self.rightData.count; i++){
        CItem * it = [self.rightData objectAtIndex:i];
        if([it.itemId isEqualToString:item.itemId])
        {
            indexOfItem = i;
            [self.rightData replaceObjectAtIndex:indexOfItem withObject:item];
            break;
        }
    }
    
}

- (void)HideEmptyPadOverlay
{
    if ([self.emptyNotifyView.superview isEqual:self.view])
    {
        [self.emptyNotifyView removeFromSuperview];
    }
    
    [self setupTopRightButtons];
    
}

- (void)ShowKnoteLoadingView
{
    if (self.knoteLoadingView == Nil)
    {
        self.knoteLoadingView = [[KnotableProgressView alloc] init];
    }
    
    [self.knoteLoadingView startProgressWithTitle:@"updating pad"];
    [AppDelegate sharedDelegate].barstyleloaderthread =self.knoteLoadingView.statusBarLoaderView;
    [[AppDelegate sharedDelegate].barstyleloaderthread setBackgroundColor:[UIColor colorWithWhite:0.941 alpha:1.000]];
}

- (void)HideKnoteLoadingView
{
    [self.knoteLoadingView stopProgressBar];
    
    if ([self.knoteLoadingView.superview isEqual:self.view])
    {
        [self.knoteLoadingView removeFromSuperview];
    }
    
    //self.tableView.tableFooterView = [UIView new];
    
    if(self.gettingYourPadLabel.superview)
    {
        [self.gettingYourPadLabel removeFromSuperview];
    }
}

- (void) ThreadPopBack
{
    // Turn on background task
    [self RemoveObserverFromSelectedPad];
    
    // If pad is auto-created and it doesn't have any entries, remove it.
    NSInteger count = [self.currentData count];
    if(count == 0){
        
        
        
    }else if (self.isAutoCreated){
        NSLog(@"uploading Topic from generateNewTopic completion %@", self.tInfo.topic_id);
        //        [self.tInfo recordSelfToServer];
        //block(NetworkSucc,nil,self.tInfo);
    }
    [[DataManager sharedInstance]turnOffContactsInBackground];
    [[DataManager sharedInstance] turnOnBackground];
    
    if(!self.willSegueAfterRowTap){
        self.willSegueAfterRowTap = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return NO;
}

- (void)setupTopRightButtons
{
    self.navigationItem.rightBarButtonItem = Nil;
#if New_DrawerDesign
    [self.navigationItem setRightBarButtonItem:self.sharedPeopleButton];
#else
    [self.navigationItem setRightBarButtonItem:self.createKnoteButton];
#endif
}

-(void)needRefreshView
{
#if !New_DrawerDesign
    NSInteger preCountLine = ceil([self.headerTitle.itemArray count] / 9.0);
    
    self.headerTitle.itemArray = [self getSharedPeople:YES];
    
    if (ceil([self.headerTitle.itemArray count] / 9.0) > preCountLine )
    {
        [self.headerTitle.collectionView reloadData];
        
        [self.headerTitle setNeedsUpdateConstraints];
        
        if (self.headerTitle)
        {
            [self.headerTitle.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
        }
    }
    else
    {
        [self.headerTitle.collectionView reloadData];
    }
    
    // Lin - Added to fix - https://trello.com/c/Jl7LlMu2/890-qa-feedback-ui-tweaks
    
    if ([self.headerTitle.itemArray count] <= 0)
    {
        [self.menuWithSharePad setHidden:NO];
        [self.bottomPadUserView bringSubviewToFront:self.menuWithSharePad];
    }
    else
    {
        [self.menuWithSharePad setHidden:YES];
        [self.bottomPadUserView sendSubviewToBack:self.menuWithSharePad];
    }
#endif
    // Lin - Ended
    
    //ying added
    [self updateTitleWith: self.tInfo.entity.topic];
}

-(void)navBarTapped:(UITapGestureRecognizer *)recognizer
{
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:NSNotFound inSection:0]
                          atScrollPosition:UITableViewScrollPositionTop
                                  animated:YES];
}


//-(void)longPress:(UILongPressGestureRecognizer *)recognizer
//{
//    if (recognizer.state == UIGestureRecognizerStateBegan)
//    {
//        if (!self.rearrangingCells)
//        {
//            self.rearrangingCells = YES;
//            
//            NSLog(@"long PRESS! state %d", (int)recognizer.state);
//            
//            [self startSortMode];
//        }
//    }
//}
//

-(void)longPress:(UILongPressGestureRecognizer *)recognizer
{
    
    UIGestureRecognizerState state = recognizer.state;
    
    CGPoint location = [recognizer locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    static UIView       *snapshot = nil;        ///< A snapshot of the row user is moving.
    static NSIndexPath  *destIndexPath = nil; ///< Initial index path, where gesture begins.
    static NSIndexPath *prevIndexPath = nil; // orignal index path, where gesture begins.;
    static NSArray* originArray = nil;
    
    static BOOL isDragging = NO;
    
    switch (state) {
        case UIGestureRecognizerStateBegan: {
            if (indexPath) {
                isDragging = YES;
                destIndexPath = indexPath;
                prevIndexPath = indexPath;
                originArray = [self.currentData copy];
                
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                
                // Take a snapshot of the selected row using helper method.
                snapshot = [self customSnapshotFromView:cell];
                
                // Add the snapshot as subview, centered at cell's center...
                __block CGPoint center = cell.center;
                snapshot.center = center;
                snapshot.alpha = 0.0;
                [self.tableView addSubview:snapshot];
                [UIView animateWithDuration:0.25 animations:^{
                    
                    // Offset for gesture location.
                    center.y = location.y;
                    snapshot.center = center;
                    snapshot.transform = CGAffineTransformMakeScale(1.05, 1.05);
                    snapshot.alpha = 0.98;
                    
                    // Fade out.
                    cell.alpha = 0.0;
                    
                } completion:^(BOOL finished) {
                    
                    cell.hidden = YES;
                    
                }];
            }
            break;
        }
        
        case UIGestureRecognizerStateChanged: {
            CGPoint center = snapshot.center;
            center.y = location.y;
            snapshot.center = center;
            
            // Is destination valid and is it different from source?
            if (isDragging && indexPath && ![indexPath isEqual:destIndexPath]) {
                
                // ... update data source.
                [self.currentData exchangeObjectAtIndex:indexPath.row withObjectAtIndex:destIndexPath.row];
                
                // ... move the rows.
                [self.tableView moveRowAtIndexPath:destIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                destIndexPath = indexPath;
            }
            break;
        }
        
        case UIGestureRecognizerStateEnded:
        {
            // Is destination valid and is it different from source?
            if (isDragging && indexPath && ![indexPath isEqual:destIndexPath]) {
                
                // ... update data source.
                [self.currentData exchangeObjectAtIndex:indexPath.row withObjectAtIndex:destIndexPath.row];
                
                // ... move the rows.
                [self.tableView moveRowAtIndexPath:destIndexPath toIndexPath:indexPath];
                
                // ... and update source so it is in sync with UI changes.
                destIndexPath = indexPath;
            }
           
            if (isDragging && [destIndexPath isEqual: prevIndexPath] == NO)
            {// order changed
                [self positionChangedTo: destIndexPath from: prevIndexPath atArray: originArray];
//                [self updateKnoteOrders];
                [self.tableView scrollToRowAtIndexPath: destIndexPath
                                      atScrollPosition: UITableViewScrollPositionNone
                                              animated: YES];
            }

            // break;    //            goto default;

        }
            
        default: {
            // Clean up.
            isDragging = NO;
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:destIndexPath];
            cell.hidden = NO;
            cell.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                
                snapshot.center = cell.center;
                snapshot.transform = CGAffineTransformIdentity;
                snapshot.alpha = 0.0;
                
                // Undo fade out.
                cell.alpha = 1.0;
                
            } completion:^(BOOL finished) {
                
                destIndexPath = nil;
                [snapshot removeFromSuperview];
                snapshot = nil;
                
                snapshot = nil;
                destIndexPath = nil;
                prevIndexPath = nil;
                originArray = nil;
                
                
            }];
            break;
        }
    }
}

// Add this at the end of your .m file. It returns a customized snapshot of a given view.
- (UIView *)customSnapshotFromView:(UIView *)inputView {
    
    // Make an image from the input view.
    UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, NO, 0);
    [inputView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Create an image view.
    UIView *snapshot = [[UIImageView alloc] initWithImage:image];
    snapshot.layer.masksToBounds = NO;
    snapshot.layer.cornerRadius = 0.0;
    snapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0);
    snapshot.layer.shadowRadius = 5.0;
    snapshot.layer.shadowOpacity = 0.4;
    
    return snapshot;
}

- (void) positionChangedTo: (NSIndexPath*) destIndexPath from: (NSIndexPath*) sourceIndexPath atArray: (NSArray*) sourceArray
{
//    NSMutableArray* orderArray = [NSMutableArray array];
    NSMutableArray* orderMapArray = [NSMutableArray array];
    NSArray* currentArray = self.currentData;
    NSDictionary* orderMap;
    
//    for (CItem* item in sourceArray)
//    {
//        [orderArray addObject: @(item.order)];
//    }
//    
//    [orderArray insertObject: @(((NSNumber*)orderArray[0]).intValue - 1) atIndex: 0];
//    
//    if (destIndexPath.row < sourceIndexPath.row) // moved up
//    {
//        // step 1: destination order save
//        int64_t destOrder = ((NSNumber*)orderArray[destIndexPath.row]).intValue;
//        //step 2: shift-up from first to desination;
//        for (NSInteger i = 0; i < destIndexPath.row; i++)
//        {
//            CItem* item = sourceArray[i];
//            int upOrder = ((NSNumber*)orderArray[i]).intValue;
//            item.order = upOrder;
//            item.userData.order = upOrder;
//            
//            orderMap = [NSArray arrayWithObjects: item.userData, @(upOrder), nil];
//            [orderMapArray addObject: orderMap];
//        }
//        // step 3: set source cell's order by destination cell's order.
//        CItem* sourceItem = sourceArray[sourceIndexPath.row];
//        sourceItem.order = destOrder;
//        sourceItem.userData.order = destOrder;
//        orderMap = [NSArray arrayWithObjects: sourceItem.userData, @(destOrder), nil];
//        [orderMapArray addObject: orderMap];
//        
//        // step 5: shift-down above source index
//        for (NSInteger i = sourceIndexPath.row; i >= 0; i--)
//        {
//            CItem* item = currentArray[i];
//            int downOrder = ((NSNumber*)orderArray[i + 1]).intValue;
//            item.order = downOrder;
//            item.userData.order = downOrder;
//            orderMap = [NSArray arrayWithObjects: item.userData, @(downOrder), nil];
//            [orderMapArray addObject: orderMap];
//        }
//    }
//    else // moved down
//    {
//        // step 1: destination order save
//        int64_t destOrder = ((NSNumber*)orderArray[destIndexPath.row + 1]).intValue;
//        //step 2: shift-up from first to desination;
//        for (NSInteger i = 0; i <= destIndexPath.row; i++)
//        {
//            CItem* item = sourceArray[i];
//            int upOrder = ((NSNumber*)orderArray[i]).intValue;
//            item.order = upOrder;
//            item.userData.order = upOrder;
//            
//            orderMap = [NSArray arrayWithObjects: item.userData, @(upOrder), nil];
//            [orderMapArray addObject: orderMap];
//        }
//        // step 3: set source cell's order by destination cell's order.
//        CItem* sourceItem = sourceArray[sourceIndexPath.row];
//        sourceItem.order = destOrder;
//        sourceItem.userData.order = destOrder;
//        orderMap = [NSArray arrayWithObjects: sourceItem.userData, @(destOrder), nil];
//        [orderMapArray addObject: orderMap];
//        
//        // step 5: shift-down above source index
//        for (NSInteger i = sourceIndexPath.row - 1; i >= 0; i--)
//        {
//            CItem* item = currentArray[i];
//            int downOrder = ((NSNumber*)orderArray[i + 1]).intValue;
//            item.order = downOrder;
//            item.userData.order = downOrder;
//            orderMap = [NSArray arrayWithObjects: item.userData, @(downOrder), nil];
//            [orderMapArray addObject: orderMap];
//        }
//    }

    for (int i = 0; i < currentArray.count; i++) {
        int newOrder = i - (int)currentArray.count;
        CItem* item = currentArray[i];
        if (item.order != newOrder)
        {
            item.order = newOrder;
            item.userData.order = newOrder;
            orderMap = @{@"message_id" : item.itemId, @"newOrder" : @(newOrder)};
            [orderMapArray addObject: orderMap];
        }
    }

    [self.sortOrderMapArray addObjectsFromArray: orderMapArray];
    [[AppDelegate sharedDelegate] sendUpdatedKnoteOrderMaps: orderMapArray];
    [AppDelegate saveContext];
    
//    [self updateKnoteOrders];
}

-(void)startSortMode
{
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(endSortMode)];
    [self.navigationItem setRightBarButtonItems:@[doneButton] animated:YES];
    
    [self.tableView setEditing:YES animated:YES];
}

-(void)endSortMode
{
    [self setupTopRightButtons];
    [self.tableView setEditing:NO animated:YES];
    [self updateKnoteOrders];
    self.rearrangingCells = NO;
    
}
#if New_DrawerDesign
-(void)createFloatingMenu
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    UIWindow *wn = appDelegate.window;
    
    for (int i=0; i<wn.subviews.count; i++)
    {
        UIView *e=wn.subviews[i];
        if (e!=_stack && [e isKindOfClass:[UPStackMenu class]])
        {
            [e removeFromSuperview];
            e=nil;
        }
    }
    
    if (_stack==nil)
    {
        _stack=[[UPStackMenu alloc]initWithImage:[UIImage imageNamed:@"ios7-plus"]  inSelection:NO];
        [_stack setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width-40, [UIScreen mainScreen].bounds.size.height-40)];
        [_stack setDelegate:self];
        
        UPStackMenuItem *menu_knote = [[UPStackMenuItem alloc] initWithImage:[[UIImage imageNamed:@"tabadd"]imageTintedWithColor:[UIColor whiteColor]] highlightedImage:nil title:@"New Knote"];
        
        /*
        UPStackMenuItem *menu_vote = [[UPStackMenuItem alloc] initWithImage:[[UIImage imageNamed:@"tablist"] imageTintedWithColor:[UIColor whiteColor]] highlightedImage:nil title:@"New Vote"];
        */
        
        UPStackMenuItem *menu_task = [[UPStackMenuItem alloc] initWithImage:[[UIImage imageNamed:@"tabvote"]imageTintedWithColor:[UIColor whiteColor]] highlightedImage:nil title:@"New Task"];
        /*
        UPStackMenuItem *menu_date = [[UPStackMenuItem alloc] initWithImage:[[UIImage imageNamed:@"tabcalender"]imageTintedWithColor:[UIColor whiteColor]] highlightedImage:nil title:@"New Date"];
        */
        
        NSMutableArray *items = [[NSMutableArray alloc] initWithObjects:menu_knote, /*menu_vote,*/ menu_task, /*menu_date,*/ nil];
        
        [items enumerateObjectsUsingBlock:^(UPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
            [item setTitleColor:[UIColor colorWithWhite:0.298 alpha:1.000]];
        }];
        
        [_stack setAnimationType:UPStackMenuAnimationType_progressive];
        [_stack setStackPosition:UPStackMenuStackPosition_up];
        [_stack setOpenAnimationDuration:.4];
        [_stack setCloseAnimationDuration:.4];
        
        [items enumerateObjectsUsingBlock:^(UPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
            [item setLabelPosition:UPStackMenuItemLabelPosition_right];
            [item setLabelPosition:UPStackMenuItemLabelPosition_left];
        }];
        
        [_stack addItems:items];
        
        [wn addSubview:_stack];
    }
    else
    {
        if ([wn.subviews containsObject:_stack])
        {
            self.stack.hidden = NO;
        }
        else
        {
            [wn addSubview:_stack];
            self.stack.hidden = NO;
        }
    }
}
#pragma mark - RNSIde Bar Delegate
#if ChangeInDrawer
-(void)sidebarwillShowOnScreenAnimated:(BOOL)animatedYesOrNo
{
    if (self.stack)
    {
        self.stack.hidden=YES;
    }
}
-(void)sidebardidDismissFromScreenAnimated:(BOOL)animatedYesOrNo
{
    if (self.stack)
    {
        // for About, setting viewcontroller ...
        if (self.isNeedShowStack)
        {
            self.stack.hidden = NO;
        }
        else
        {
            self.isNeedShowStack = YES;
        }
    }
}
#else
-(void)sidebar:(RNFrostedSidebar *)sidebar willShowOnScreenAnimated:(BOOL)animatedYesOrNo
{
    if (self.stack)
    {
        self.stack.hidden=YES;
    }
}
-(void)sidebar:(RNFrostedSidebar *)sidebar didDismissFromScreenAnimated:(BOOL)animatedYesOrNo
{
    if (self.stack)
    {
        self.stack.hidden=NO;
    }
}
#endif
#pragma mark - UPStackMenuDelegate
- (void)stackMenuWillOpen:(UPStackMenu *)menu
{
    if([[_stack.conView subviews] count] == 0)
        return;
    
    [self setStackIconClosed:NO];
}

- (void)stackMenuWillClose:(UPStackMenu *)menu
{
    if([[_stack.conView subviews] count] == 0)
        return;
    
    [self setStackIconClosed:YES];
}

- (void)stackMenu:(UPStackMenu *)menu didTouchItem:(UPStackMenuItem *)item atIndex:(NSUInteger)index
{
    switch (index)
    {
        case 0:
            [self addNewItem:C_KNOTE animated: YES];
            break;
        case 1:
//            [self addNewItem:C_VOTE];
            
            [self addNewItem:C_LIST animated: YES];
            
            break;
            /*
        case 2:
            [self addNewItem:C_LIST];
            break;
        case 3:
            [self addNewItem:C_DATE];
            break;
             */
        default:
            break;
    }
}
- (void)setStackIconClosed:(BOOL)closed
{
    float angle = closed ? 0 : (M_PI * (135) / 180.0);
    [UIView animateWithDuration:0.3 animations:^{
        [_stack.icon.layer setAffineTransform:CGAffineTransformRotate(CGAffineTransformIdentity, angle)];
    }];
}
#endif
#pragma mark - UITextViewDelegate

- (void)textViewDidEndEditing:(UITextView *)textView
{
#if !New_DrawerDesign
    if ([self.headerTitle.titleLabel isEqual:textView])
    {
        self.mainTitle = self.headerTitle.titleLabel.text;
#endif
        [[AppDelegate sharedDelegate] sendUpdatedTopicSubject:self.tInfo.entity.topic_id
                                                  withContent:self.mainTitle
                                            withCompleteBlock:^(NSDictionary *response, NSError *error) {
                                                
                                                if (error)
                                                {
                                                    [SVProgressHUD showErrorWithStatus:@"Update Failed." duration:2];
                                                    
                                                    return ;
                                                }
                                                
                                                DLog(@"Success : %@", response);
                                                
                                                self.tInfo.entity.topic = self.mainTitle;
#if !New_DrawerDesign
                                                
                                                self.headerTitle.titleLabel.text = self.mainTitle;
#endif
                                                [self.tableView reloadData];
                                                
                                                if (self.delegate
                                                    && [self.delegate respondsToSelector:@selector(needChangeTopicTitle:)])
                                                {
                                                    [self.delegate needChangeTopicTitle:self.tInfo];
                                                }
                                                
                                            }];
#if !New_DrawerDesign
        
    }
#endif
}

- (void)taped:(UITapGestureRecognizer *)tapGesture
{
    if ([self.titleTextField isFirstResponder])
    {
        [self.titleTextField resignFirstResponder];
    }
#if !New_DrawerDesign
    if ([self.headerTitle.titleLabel isFirstResponder])
    {
        [self.headerTitle.titleLabel endEditing:YES];
    }
#endif
}

-(void)topicChange
{
#if !New_DrawerDesign
    self.headerTitle.itemArray = [self getSharedPeople:YES];
    
    [self.headerTitle setFrame:CGRectMake(0, 0, 320, BottomMenuHeight)];
    
    [self.headerTitle.collectionView reloadData];
    
    if (self.headerTitle)
    {
        [self.headerTitle.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    }
    
    // Lin - Added to fix - https://trello.com/c/Jl7LlMu2/890-qa-feedback-ui-tweaks
    
    if ([self.headerTitle.itemArray count] <= 0)
    {
        [self.menuWithSharePad setHidden:NO];
        [self.bottomPadUserView bringSubviewToFront:self.menuWithSharePad];
    }
    else
    {
        //NSLog(@"login took: %f login error: %@ response: %@", timeTook,error, response);
        [self.menuWithSharePad setHidden:YES];
        [self.bottomPadUserView sendSubviewToBack:self.menuWithSharePad];
    }
#endif
    
    // Lin - Ended
}

- (void) addButtonClickedWithContactsAlreadyAdded:(NSMutableArray *)itemsArray
{
    [self floatingTrayShared:itemsArray];
}

- (void) addButtonClicked
{
    [self floatingTrayShared:nil];
}

#pragma mark - Citem Delegate
-(void)itemSuccessfullyArchived:(CItem *)item
{
    __block CItem *againItem = item;
    
    [MozTopAlertView showWithType:MozAlertTypeWarning text:@"Marked Done" doText:@"UNDO" andDelegate:self doBlock:^{
        
        
        NSLog(@"againItem-->%@",againItem);
        
        [self.currentData insertObject:againItem atIndex:_archivedIndexPath.row];
        [self.tableView reloadData];
//        [self.tableView insertRowsAtIndexPaths:@[_archivedIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
        /*againItem.archived=!againItem.archived;
        againItem.userData.archived=againItem.archived;*/
        [againItem checkToDelete];
        [MozTopAlertView hideViewWithParentView:self.view];
        
    } parentView:self.view];
    
}

-(void)failedToArchiveknote:(CItem *)item
{
    /*CEditBaseItemView *c = (CEditBaseItemView *)_archivedCell;
     CItem *itemForcheck = [c getItemData];*/
    
    if(self.currentData.count >= _archivedIndexPath.row){
        [self.currentData insertObject:item atIndex:_archivedIndexPath.row];
        [self.tableView reloadData];
//        [self.tableView insertRowsAtIndexPaths:@[_archivedIndexPath] withRowAnimation:UITableViewRowAnimationLeft];
    }

}

#pragma mark - moz delegate
-(void)mozAlertViewWillDisplay
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect frame = self.stack.frame;
                         frame.origin.y -= 36;
                         self.stack.frame = frame;
                     }
                     completion:^(BOOL finished){
                         // whatever you need to do when animations are complete
                     }];
}
-(void)mozAlertViewWillhide
{
    [UIView animateWithDuration:0.5
                     animations:^{
                         CGRect frame = self.stack.frame;
                         frame.origin.y += 36;
                         self.stack.frame = frame;
                     }
                     completion:^(BOOL finished){
                         // whatever you need to do when animations are complete
                     }];
}
- (void) headerViewClickeAtContact:(ContactsEntity *)entity
{
    // Lin - Added to
    /*
     
     Sharing people list
     
     Show remove button : remove from pad
     
     */
    // Lin - Ended
    
    if(entity){
        
        MyProfileController *profile = [[MyProfileController alloc] initWithContact:entity];
        
        profile.topic = self.tInfo.entity;
        profile.login_user = self.login_user;
        
        __block MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:profile];
        
        NSMutableArray *arr =[[entity.email componentsSeparatedByString:@","] mutableCopy];
        
        if([arr containsObject:self.login_user.email])
        {
            // This is the self profile, do not need to show button
            [profile setProfile_remove_buttonType:RemoveFromNone];
            
            profile.delegate = nil;
        }
        else
        {
            [profile setProfile_remove_buttonType:RemoveFromPad];
            
            profile.delegate = self;
        }
        
        
        CGFloat ctlHeight = self.view.bounds.size.height - 60;
        formSheet.presentedFormSheetSize = CGSizeMake(300, ctlHeight);
        
        formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
        formSheet.shadowRadius = 2.0;
        formSheet.shadowOpacity = 0.3;
        formSheet.shouldDismissOnBackgroundViewTap = YES;
        [formSheet setPortraitTopInset:20];
        [formSheet setLandscapeTopInset:20];
        
        formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
            
        };
        
        [MZFormSheetController sharedBackgroundWindow].formSheetBackgroundWindowDelegate = self;
        
        [self mz_presentFormSheetController:formSheet
                                   animated:YES
                          completionHandler:^(MZFormSheetController *formSheetController) {
                          }];
    }
    
}
#pragma mark - CReplyDelegate
#if NEW_DESIGN
-(void)replyClickedOnItem:(CItem *)ReplyItem
{
    NSLog(@"%@",ReplyItem);
    /*
    if (ReplyItem.userData.isReplyExpanded)
    {
        ReplyItem.userData.isReplyExpanded=NO;
        ReplyItem.userData.isAllExpanded=NO;
    }
    else
    {
        ReplyItem.userData.isReplyExpanded=YES;
    }
    
    if (self.tableView.frame.origin.x == 0) {
        NSUInteger index=[self.currentData indexOfObject:ReplyItem];
        
        if(index < self.currentData.count){
            
            [self.currentData replaceObjectAtIndex:index withObject:ReplyItem];
            
            if (self.isUpdationOver)
            {
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    self.isUpdationOver=YES;
                }];
                
                [self.tableView beginUpdates];
                
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                                      withRowAnimation:UITableViewRowAnimationFade];
                
                [self.tableView endUpdates];
                
                [CATransaction commit];
            }
        }
        
    }else{
        if(self.rightData){
            NSUInteger index=[self.rightData indexOfObject:ReplyItem];
            
            [self.rightData replaceObjectAtIndex:index withObject:ReplyItem];
            
            if (self.isUpdationOver)
            {
                [CATransaction begin];
                [CATransaction setCompletionBlock:^{
                    self.isUpdationOver=YES;
                }];
                
                [self.tableViewRight beginUpdates];
                
                [self.tableViewRight reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                                           withRowAnimation:UITableViewRowAnimationFade];
                
                [self.tableViewRight endUpdates];
                
                [CATransaction commit];
            }
        }
        
    }
    */
    
    //tmd
    self.commentController = [[CommentViewController alloc] initWithTopic:ReplyItem];
    [self.navigationController pushViewController:_commentController animated:YES];
    
}
-(void)ShowAllReplies:(CItem *)ReplyItem
{
    if (!ReplyItem.userData.isAllExpanded)
    {
        ReplyItem.userData.isAllExpanded=YES;
    }
    
    if (self.tableView.frame.origin.x == 0) {
        NSUInteger index=[self.currentData indexOfObject:ReplyItem];
        
        [self.currentData replaceObjectAtIndex:index withObject:ReplyItem];
        
        if (self.isUpdationOver)
        {
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                self.isUpdationOver=YES;
            }];
            
            [self.tableView beginUpdates];
            
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                                  withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView endUpdates];
            
            [CATransaction commit];
        }
    }else{
        NSUInteger index=[self.rightData indexOfObject:ReplyItem];
        
        [self.rightData replaceObjectAtIndex:index withObject:ReplyItem];
        
        if (self.isUpdationOver)
        {
            [CATransaction begin];
            [CATransaction setCompletionBlock:^{
                self.isUpdationOver=YES;
            }];
            
            [self.tableViewRight beginUpdates];
            
            [self.tableViewRight reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]
                                       withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableViewRight endUpdates];
            
            [CATransaction commit];
        }
    }
    
}
-(void)ChangeOffsetAccordingToEdting:(CItem *)itm forTextField:(UITextField *)tefl
{
    _instanceTxtReply=tefl;
    
    if (self.tableView.frame.origin.x == 0) {
        NSIndexPath *index=[NSIndexPath indexPathForRow:[self.currentData indexOfObject:itm] inSection:0];
        CGRect rect = [self.tableView rectForRowAtIndexPath:index];
        [self.tableView setContentOffset:CGPointMake(0, rect.origin.y+rect.size.height-230) animated:YES];
    }else{
        NSIndexPath *index=[NSIndexPath indexPathForRow:[self.rightData indexOfObject:itm] inSection:0];
        CGRect rect = [self.tableViewRight rectForRowAtIndexPath:index];
        [self.tableViewRight setContentOffset:CGPointMake(0, rect.origin.y+rect.size.height-230) animated:YES];
    }
    
    
}
-(void)ChangeOffsetAccordingToEndEdting:(CItem *)itm
{
    if (self.tableView.frame.origin.x == 0) {
        NSIndexPath *index=[NSIndexPath indexPathForRow:[self.currentData indexOfObject:itm] inSection:0];
        CGRect rect = [self.tableView rectForRowAtIndexPath:index];
        [self.tableView setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }else{
        NSIndexPath *index=[NSIndexPath indexPathForRow:[self.rightData indexOfObject:itm] inSection:0];
        CGRect rect = [self.tableViewRight rectForRowAtIndexPath:index];
        [self.tableViewRight setContentOffset:CGPointMake(0, rect.origin.y) animated:YES];
    }
}
#endif

#pragma mark - CTitleInfoBarDelegate

- (void) titleInfoClickeAtContact:(ContactsEntity *)entity
{
    MyProfileController *profile = [[MyProfileController alloc] initWithContact:entity];
    
    NSMutableArray *arr = [[entity.email componentsSeparatedByString:@","] mutableCopy];
    
    if([arr containsObject:self.login_user.email])
    {
        [profile setProfile_remove_buttonType:RemoveFromNone];
        
        profile.delegate=nil;
    }
    else
    {
        [profile setProfile_remove_buttonType:RemoveFromPad];
        
        profile.delegate = self;
    }
    
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
        
    };
    
    [MZFormSheetController sharedBackgroundWindow].formSheetBackgroundWindowDelegate = self;
    
    [self mz_presentFormSheetController:formSheet
                               animated:YES
                      completionHandler:^(MZFormSheetController *formSheetController) {
                      }];
    
}

- (void)fileDownloaded:(NSNotification *)note
{
    
}

- (void)titleTaped:(UITapGestureRecognizer *)tapGesture
{
    if (self.titleTextField == nil)
    {
        self.titleTextField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 230, 40)];
        self.titleTextField.delegate = self;
        self.titleTextField.placeholder = @"Enter a title";
        self.titleTextField.textAlignment = NSTextAlignmentLeft;
        self.titleTextField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:22]/*[UIFont systemFontOfSize:22]*/;
    }
    self.titleTextField.text = self.mainTitle;
    self.navigationItem.titleView = self.titleTextField;
    [self.titleTextField becomeFirstResponder];
}

- (void) titleViewTaped:(CEditBaseItemView *)view
{
    [self addTitle:nil];
}

- (void)addTitle:(id)sender
{
    self.titleAlert = [[UIAlertView alloc] initWithTitle:@"Modify Title"
                                                 message:nil
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                       otherButtonTitles:@"Save", nil];
    self.titleAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    self.titleTextField = [self.titleAlert textFieldAtIndex:0];
    self.titleTextField.delegate = self;
    if (self.mainTitle && self.mainTitle.length > 0) {
        self.titleTextField.text = self.mainTitle;
    }
    [self.titleAlert show];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
//    if ([textField])
    if (textField == self.titleTextField)
    {
        [textField resignFirstResponder];
        [self delayCheckToPost:textField];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [self.titleAlert dismissWithClickedButtonIndex:1 animated:YES];
    
    if (textField == self.titleTextField) {
        [self.titleTextField resignFirstResponder];
//        [self delayCheckToPost:textField];
        return NO;
    }
    
    return YES;
}

- (void)delayCheckToPost:(UITextField *)textField
{
    if ([ReachabilityManager sharedInstance].delegate != nil)//check will dismiss viewcontroller can't change title
    {

        NSString* newTitle = [textField.text stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (newTitle.length > 0 && [self.mainTitle isEqualToString: newTitle] == NO)
        {
            self.mainTitle = newTitle;
            if (self.tInfo && ![self.tInfo.entity.topic_id containsString:@"tempId"])
            {
                [[AppDelegate sharedDelegate] sendUpdatedTopicSubject:self.tInfo.entity.topic_id
                                                          withContent:self.mainTitle
                                                    withCompleteBlock:^(NSDictionary *response, NSError *error) {
                                                        
                                                        if (error)
                                                        {
                                                            [SVProgressHUD showErrorWithStatus:@"Update Failed." duration:2];
                                                            
                                                            return ;
                                                        }
                                                        
                                                        DLog(@"Success : %@", response);
                                                        
                                                        self.tInfo.entity.topic = self.mainTitle;
#if !New_DrawerDesign
                                                        self.headerTitle.titleLabel.text = self.mainTitle;
#endif
                                                        self.isCreatingKnote = YES;
                                                        
                                                        [self.tableView reloadData];
                                                        [self.tableViewRight reloadData];
                                                        
                                                        self.isCreatingKnote = NO;
                                                        
                                                        if (self.delegate && [self.delegate respondsToSelector:@selector(needChangeTopicTitle:)])
                                                        {
                                                            [self.delegate needChangeTopicTitle:self.tInfo];
                                                        }
                                                    }];
                
            }
            else
            {
                if ([self.mainTitle length]<=0) {
                    self.mainTitle = @"Untitled";
                }
                
                NSLog(@"Knotable: generateNewTopic in threadviewcontroller");
                [[TopicManager sharedInstance] generateNewTopic:self.mainTitle
                                                        account:[DataManager sharedInstance].currentAccount
                                                 sharedContacts:@[]andBeingAutocreated:NO withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
                 {
                     self.tInfo = userData;
                     self.tInfo.entity = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:self.tInfo.topic_id];
                     self.tInfo.entity.contact_id = [DataManager sharedInstance].currentAccount.user.contact.contact_id;
                     self.tInfo.item.userData = [MessageEntity MR_findFirstByAttribute:@"message_id" withValue:self.tInfo.message_id];
                     self.tInfo.entity.hasNewActivity = @(YES);
                     
                     if ([DataManager sharedInstance].currentAccount.user.contact)
                     {
                         NSMutableSet *topicContacts = [[NSMutableSet alloc] init];
                         
                         [topicContacts addObject:[DataManager sharedInstance].currentAccount.user.contact];
                         
                         self.tInfo.entity.contacts = [topicContacts copy];
                     }
                     
                     if (self.delegate
                         && [self.delegate respondsToSelector:@selector(needChangeTopicTitle:)])
                     {
                         [self.delegate needChangeTopicTitle:self.tInfo];
                     }
                     
                     self.newPadCreated = YES;
                 }];
            }
        }
        
        [self customizeTitleLabel];
//        
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 220, 44)];
//        label.backgroundColor = [UIColor clearColor];
//        
//        label.numberOfLines = 2;
//        label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20]/*[UIFont boldSystemFontOfSize: 20.0f]*/;
//        label.adjustsFontSizeToFitWidth=YES;
//        
//        label.textAlignment = NSTextAlignmentLeft;
//        label.textColor = [UIColor whiteColor];
//        label.text = self.mainTitle;
//        
//        self.navigationItem.titleView = Nil;
//        
//        UIView *labelView = [[UIView alloc] initWithFrame:CGRectMake(0,0,230,44)];
//        [labelView addSubview:label];
//        
//        self.navigationItem.titleView = labelView;
//        
//        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(titleTaped:)];
//        tapGesture.numberOfTapsRequired = 1;
//        tapGesture.numberOfTouchesRequired = 1;
//        tapGesture.cancelsTouchesInView = NO;
//        [label addGestureRecognizer:tapGesture];
//        label.userInteractionEnabled = YES;
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 100)
    {
        if (buttonIndex == 1)
        {
            [self.titleTextField becomeFirstResponder];
        }
    }
    else
    {
        DLog(@"alert willDismissWithButtonIndex %d", (int)buttonIndex);
        
        if (buttonIndex != 0)
        {
            self.mainTitle = self.titleTextField.text;
        }
        
        if (buttonIndex == 1)
        {
            [[AppDelegate sharedDelegate] sendUpdatedTopicSubject:self.tInfo.entity.topic_id
                                                      withContent:self.mainTitle
                                                withCompleteBlock:^(NSDictionary *response, NSError *error) {
                                                    
                                                    if (error)
                                                    {
                                                        [SVProgressHUD showErrorWithStatus:@"Update Failed." duration:2];
                                                    }
                                                    
                                                    DLog(@"Success : %@", response);
                                                    
                                                    self.tInfo.entity.topic = self.mainTitle;
#if !New_DrawerDesign
                                                    self.headerTitle.titleLabel.text = self.mainTitle;
#endif
                                                    [self.tableView reloadData];
                                                    [self.tableViewRight reloadData];
                                                    
                                                    if (self.delegate
                                                        && [self.delegate respondsToSelector:@selector(needChangeTopicTitle:)])
                                                    {
                                                        [self.delegate needChangeTopicTitle:self.tInfo];
                                                    }
                                                    
                                                }];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"clickedButtonAtIndex %d", (int)buttonIndex);
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (alertView.tag == 100)
    {
        return YES;
    }
    return self.titleTextField.text.length > 0 && ![self.titleTextField.text isEqualToString:self.mainTitle];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (CItem *)findItemInArry:(NSArray *)array byItemId:(NSString *)itemId
{
    CItem *item = nil;
    
    if (itemId != nil && array != nil)
    {
        for (int i = 0 ; i< [array count]; i++)
        {
            CItem * tmp = [array objectAtIndex:i];
            
            if ([tmp.itemId isEqualToString:itemId])
//            if ([tmp.userData.message_id isEqualToString: itemId])
            {
                item = tmp;
                
                break;
            }
        }
    }
    else
    {
        DLog(@"###############ERROR: in findItemInArry");
    }
    
    return item;
}

// Lin - Added to process server response as well.

- (void)ProcessKnoteAndMessagewithDict:(NSDictionary*)serverResponse
{
    ThreadItemManager* threadManager = [ThreadItemManager sharedInstance];
    MessageEntity *message  =  [threadManager insertOrUpdateMessageObject:serverResponse
                                                              withTopicId:self.tInfo.entity.topic_id
                                                                 withFlag:nil];
    
    CItem *item = [self findItemInArry:self.currentData byItemId:message.message_id];
    
    if (item)
    {
        // If there is existing itme in data source, then update that with
        // new data.
        
        [threadManager modifyItem:item ByMessage:message];
        
        if (message.archived)
        {
            item.archived = YES;
            [self.currentData removeObject:item];
        }
        
        item.checkInCloud = YES;
        
        // Data source update
        
        for (CItem* cycle_Item in self.currentData)
        {
            if ([cycle_Item.itemId isEqualToString:message.message_id])
            {
                [threadManager modifyItem:cycle_Item ByMessage:message];
                
                break;
            }
        }
    }
    else
    {
        NSArray* addedItems = [NSArray array];
        if (message.archived && _showArchived)
        {
            addedItems = [threadManager generateItemsForMessage:message withTopic:self.tInfo.entity];
            
            if([message.containerName isEqualToString:CONTAINER_NAME_MAIN]){
                [self.currentData ReorganizedArrayWithNewDatasource: addedItems];
            }else{
                [self.rightData ReorganizedArrayWithNewDatasource: addedItems];
            }
        }
        else if (!message.archived)
        {
            addedItems = [threadManager generateItemsForMessage:message withTopic:self.tInfo.entity];
            
            if([message.containerName isEqualToString:CONTAINER_NAME_MAIN]){
                [self.currentData ReorganizedArrayWithNewDatasource: addedItems];
            }else{
                [self.rightData ReorganizedArrayWithNewDatasource: addedItems];
            }
        }
        [threadManager.knotesArray addObjectsFromArray: addedItems];
    }
}

- (void)ProcessOnlyKnoteWithDict:(NSDictionary*)serverResponse
{
    NSLog(@"ProcessOnlyKnoteWithDict");
    //NSLog(@"ProcessOnlyKnoteWithDict %@",serverResponse);
    ThreadItemManager* threadManager = [ThreadItemManager sharedInstance];
    MessageEntity *message  =  [threadManager insertOrUpdateMessageObject:serverResponse
                                                              withTopicId:self.tInfo.entity.topic_id
                                                                 withFlag:nil];
    
    NSArray *addedItems = [NSArray array];
    if (![[serverResponse objectForKey:@"type"] isEqualToString:@"knote"] || [serverResponse objectForKey:@"pinned"])
    {
        CItem *item = [self findItemInArry:self.rightData
                                  byItemId:message.message_id];
        
        if (item)
        {
            NSLog(@"modifyItem");
            [threadManager modifyItem:item
                            ByMessage:message];
            
            if (message.archived)
            {
                [self.rightData removeObject:item];
                item.archived = message.archived;
                item.userData.archived = item.archived;
                
            }
            
            item.checkInCloud = YES;
            [_commentController setItemInfo:item];
        }
        else
        {
            NSLog(@"inside else");
            
            if (message.archived && _showArchived)
            {
                addedItems = [threadManager generateItemsForMessage:message
                                                          withTopic:self.tInfo.entity];
                
                [self.rightData ReorganizedArrayWithNewDatasource:addedItems];
                
            }
            else if (!message.archived)
            {
                addedItems = [threadManager generateItemsForMessage:message
                                                          withTopic:self.tInfo.entity];
                [self.rightData ReorganizedArrayWithNewDatasource: addedItems];
            }
            if (self.rightData.count >0) {
                [self.firstDot setHidden:NO];
                [self.secondDot setHidden:NO];
            }else{
                [self.firstDot setHidden:YES];
                [self.secondDot setHidden:YES];
            }
            [self.tableViewRight reloadData];
        }
        
    }else{
        CItem *item = [self findItemInArry:self.currentData
                                  byItemId:message.message_id];
        
        if (item)
        {
            NSLog(@"modifyItem");
            [threadManager modifyItem:item
                            ByMessage:message];
            
            if (message.archived)
            {
                [self.currentData removeObject:item];
                item.archived = message.archived;
                item.userData.archived = item.archived;
            }
            
            item.checkInCloud = YES;
            [_commentController setItemInfo:item];
            
            BOOL isSortNeed = YES;
            /////// Check, if already is sorted by drag in current iPhone, not web
            for (int i = 0; i < self.sortOrderMapArray.count; i++)
            {
                NSDictionary* orderInfo = self.sortOrderMapArray[i];
                NSNumber* order = orderInfo[@"newOrder"];
                NSString *knoteID = orderInfo[@"message_id"];

                if ([knoteID isEqual: message.message_id] && order.longLongValue == message.order)
                {
                    isSortNeed = NO;
                    [self.sortOrderMapArray removeObjectAtIndex: i];
                    break;
                }
            }
            //////////////////////////////////////////////////////
            
            if (isSortNeed)
                [self sortknotesByOrder];
        }
        else
        {
            if (message.archived && _showArchived)
            {
                addedItems = [threadManager generateItemsForMessage:message
                                                          withTopic:self.tInfo.entity];
                
                if([message.containerName isEqualToString:CONTAINER_NAME_MAIN]){
                    [self.currentData ReorganizedArrayWithNewDatasource:addedItems];
                }else{
                    [self.rightData ReorganizedArrayWithNewDatasource:addedItems];
                }
                
            }
            else if (!message.archived)
            {
                addedItems = [threadManager generateItemsForMessage:message
                                                          withTopic:self.tInfo.entity];

                if([message.containerName isEqualToString:CONTAINER_NAME_MAIN]){
                    [self.currentData ReorganizedArrayWithNewDatasource:addedItems];
                }else{
                    [self.rightData ReorganizedArrayWithNewDatasource:addedItems];
                }
            }
        }
    }

    [threadManager.knotesArray addObjectsFromArray: addedItems];
}

- (void)NewProcessOnlyKnoteWithDict:(NSDictionary*)serverResponse
{
    ThreadItemManager* threadManager = [ThreadItemManager sharedInstance];
    MessageEntity *message = [threadManager insertOrUpdateMessageObject:serverResponse
                                                            withTopicId:self.tInfo.entity.topic_id
                                                               withFlag:nil];
    
    CItem *item = [self findItemInArry:self.currentData
                              byItemId:message.message_id];
    NSArray* addedItems = [NSArray array];
    if (item)
    {
        [[ThreadItemManager sharedInstance] modifyItem:item
                                             ByMessage:message];
        
        if (message.archived)
        {
            item.archived = YES;
            [self.currentData removeObject:item];
        }
        
        item.checkInCloud = YES;
    }
    else
    {
        if (_showArchived)
        {
            //            if (message.archived)
            {
                addedItems = [threadManager generateItemsForMessage:message
                                                          withTopic:self.tInfo.entity];
                
                if([message.containerName isEqualToString:CONTAINER_NAME_MAIN]){
                    [self.currentData ReorganizedArrayWithNewDatasource:addedItems];
                }else{
                    [self.rightData ReorganizedArrayWithNewDatasource: addedItems];
                }
            }
        }
        else
        {
            if (message.archived)   // This is the pinned = 1 && archived = 1
            {
                //                NSArray *items = [[ThreadItemManager sharedInstance] generateItemsForMessage:message
                //                                                                                   withTopic:self.tInfo.entity];
                //
                //                [self.currentData ReorganizedArrayWithNewDatasource:items];
            }
            else
            {
                addedItems = [threadManager generateItemsForMessage:message
                                                          withTopic:self.tInfo.entity];
                
                
                if([message.containerName isEqualToString:CONTAINER_NAME_MAIN]){
                    [self.currentData ReorganizedArrayWithNewDatasource:addedItems];
                }else{
                    [self.rightData ReorganizedArrayWithNewDatasource:addedItems];
                }
            }
        }
    }
    
    [threadManager.knotesArray addObjectsFromArray: addedItems];
}

- (void)ProcessOnlyMessageWithDict:(NSDictionary*)serverResponse
{
    ThreadItemManager* threadManager = [ThreadItemManager sharedInstance];
    MessageEntity *message = [threadManager insertOrUpdateMessageObject:serverResponse
                                                            withTopicId:self.tInfo.entity.topic_id
                                                               withFlag:nil];
    
    CItem *item = [self findItemInArry:self.currentData byItemId:message.message_id];
    NSArray* addedItems = [NSArray array];
    if (item)
    {
        [threadManager modifyItem:item ByMessage:message];
        
        if (message.archived)
        {
            NSLog(@"Message is ARCHIVED, remove from currentData");
            item.archived = YES;
            [self.currentData removeObject:item];
        }
        
        item.checkInCloud = YES;
    }
    else
    {
        if (message.archived == _showArchived)
        {
            addedItems = [threadManager generateItemsForMessage:message
                                                      withTopic:self.tInfo.entity];
            
            if([message.containerName isEqualToString:CONTAINER_NAME_MAIN]){
                [self.currentData ReorganizedArrayWithNewDatasource: addedItems];
            }else{
                [self.rightData ReorganizedArrayWithNewDatasource: addedItems];
            }
        }
    }
    [threadManager.knotesArray addObjectsFromArray: addedItems];
}

- (void)removeDeletedMessage
{
    if (self.placeHoldNote)
    {
        if ([self.currentData containsObject:self.placeHoldNote])
        {
            [self.currentData removeObject:self.placeHoldNote];
            
            self.placeHoldNote  =nil;
        }
    }
    
    BOOL needRefresh = NO;
    
    NSMutableSet *messageIDs = [[NSMutableSet alloc] init];
    ThreadItemManager* threadManager = [ThreadItemManager sharedInstance];
    
    for (int i =0 ; i< [self.currentData count]; i++)
    {
        CItem *item = [self.currentData objectAtIndex:i];
        
        MessageEntity *message = item.userData;
        
        if(message && message.message_id)
        {
            MessageEntity *messageToDelete = nil;
            
            NSString *messageID = message.message_id;
            
            //check if picture item, then add file ID
            
            if([item isKindOfClass:[CPictureItem class]])
            {
                CPictureItem *pictureItem = (CPictureItem *)item;
                
                messageID = [NSString stringWithFormat:@"%@-%@-%@", message.message_id, pictureItem.fileId, pictureItem.imageURL];
            }
            
            if([messageIDs containsObject:messageID])
            {
                messageToDelete = message;
            }
            else
            {
                [messageIDs addObject:messageID];
            }
            
            if([messageID hasPrefix:kKnoteIdPrefix])
            {
                NSString *noprefix = [message.message_id noPrefix:kKnoteIdPrefix];
                
                MessageEntity *realMessage = [MessageEntity MR_findFirstByAttribute:@"message_id" withValue:noprefix];
                
                if(realMessage)
                {
                    messageToDelete = message;
                }
            }
            
            if(messageToDelete)
            {
                //delete this one since it's already been uploaded and has a real message ID
                
                NSLog(@"DELETING DUPLICATE MESSAGE: %@", messageToDelete.message_id);
                [threadManager.knotesArray removeObjectIdenticalTo: item];
                [messageToDelete MR_deleteEntity];
                
                [self.currentData removeObjectAtIndex:i];
                
                needRefresh = YES;
                
                i--;
            }
        }
    }
    
#if USE_HEADER_TRAY
    
    [self updateHeaderInfo:_needScroll];
    
#endif
    
    //    if (needRefresh )
    {
        if ([self.currentData count] > 0)
        {
            [self.tableView reloadData];
        }
    }
}
-(void)addContactPressedFromSharelist
{
    if (_sideBar)
    {
        [_sideBar hideSideBarWithAnimation:NO];
    }
    
}
-(void)changeDrawerLayoutPickerDismiss
{
    [_sideBar ShowSideBarWithAnimationWithController:nil animated:NO];
}
#pragma mark - Add item method

- (void)addNewItem:(int)type animated: (BOOL) animated
{
    if ( ! self.newPadCreated && self.titleTextField){
        
        [self delayCheckToPost: self.titleTextField];
    }
    
    //need syns to web op
    
    ComposeThreadViewController *vc = [[ComposeThreadViewController alloc] initWithItemType:type];
    if (self.tInfo)
    {
        vc.topic_id = self.tInfo.entity.topic_id;
        vc.subject = self.tInfo.entity.topic;
    }
    vc.delegate = self;
    vc.opType = ItemAdd;
    vc.itemLifeCycleStage = ItemExisting;
    CKeyNoteItem *item = nil;
    for (int i = 0 ; i<[self.currentData count]; i++) {
        item = [self.currentData objectAtIndex:i];
        if ([item isKindOfClass:[CKeyNoteItem class]]) {
            vc.keyItem =item;
            break;
        }
    }
    
    [self.navigationController pushViewController:vc animated: animated];
}

- (void) addNewItemWithLastContent: (NSDictionary*) content animated: (BOOL) animated
{
    if ( ! self.newPadCreated && self.titleTextField){
        
        [self delayCheckToPost: self.titleTextField];
    }
    
    //need syns to web op
    
    ComposeThreadViewController *vc = [[ComposeThreadViewController alloc] initWithData: content];
    vc.topic_id = self.tInfo.entity.topic_id;
    vc.subject = self.tInfo.entity.topic;
    vc.delegate = self;
    vc.opType = ItemAdd;
    vc.itemLifeCycleStage = ItemExisting;
    CKeyNoteItem *item = nil;
    for (int i = 0 ; i<[self.currentData count]; i++) {
        item = [self.currentData objectAtIndex:i];
        if ([item isKindOfClass:[CKeyNoteItem class]]) {
            vc.keyItem =item;
            break;
        }
    }
    
    [self.navigationController pushViewController:vc animated: animated];
}

- (void)addNewItemFromString:(NSString *)subject
{
    DLog( @"subject: %@" , subject );
    
    ComposeThreadViewController *vc = [[ComposeThreadViewController alloc] initWithString:subject];
    vc.topic_id = self.tInfo.entity.topic_id;
    vc.subject = subject;
    vc.delegate = self;
    vc.opType = ItemAdd;
    CKeyNoteItem *keyItem = nil;
    for (int i = 0 ; i<[self.currentData count]; i++) {
        keyItem = [self.currentData objectAtIndex:i];
        if ([keyItem isKindOfClass:[CKeyNoteItem class]]) {
            vc.keyItem = keyItem;
            break;
        }
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)addNewItemWithPhoto:(id)object
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
    return;
    DLog(@"addNewItemWithPhoto");
    /*
     * Not yet working
     */
    
    
    UIActionSheet *cameraActionSheet = [[UIActionSheet alloc] init];
    cameraActionSheet.delegate = self;
    
    _cameraIdx = _photoLibIdx = _savedPhotosIdx = -1;
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        _cameraIdx = [cameraActionSheet addButtonWithTitle:@"Take Photo"];
    }
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        _photoLibIdx = [cameraActionSheet addButtonWithTitle:@"Photo Library"];
    }
    
    NSUInteger idx = [cameraActionSheet addButtonWithTitle:@"Cancel"];
    [cameraActionSheet setCancelButtonIndex:idx];
    
    [cameraActionSheet showInView:self.view];
}

#pragma mark - Action sheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    DLog(@"actionSheet clickedButtonAtIndex: %d", (int)buttonIndex);
    UIImagePickerControllerSourceType sourceType;
    if(buttonIndex == _cameraIdx){
        sourceType = UIImagePickerControllerSourceTypeCamera;
    } else if(buttonIndex == _photoLibIdx){
        sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    } else if(buttonIndex == _savedPhotosIdx){
        sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    } else {
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = sourceType;
    picker.delegate = self;
    picker.mediaTypes = @[(NSString *)kUTTypeImage];
    
    [self presentViewController:picker animated:YES completion:^{
        DLog(@"done presenting image picker");
    }];
}

#pragma mark - Image picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // NSLog(@"didFinishPickingMedia info: %@", info);
    __block FileInfo *fInfo = [[FileInfo alloc] init];
    fInfo.image = info[UIImagePickerControllerOriginalImage];
    
    NSURL *assetURL = info[UIImagePickerControllerReferenceURL];
    
    NSDictionary *mediaMetadata = info[UIImagePickerControllerMediaMetadata];
    if (mediaMetadata) {
        //image is from the camera
        
        NSString *filename = [NSString stringWithFormat:@"%lld.jpg", (long long)[[NSDate date] timeIntervalSince1970]];
        NSLog(@"filename %@", filename);
        
        fInfo.imageName = [filename lowercaseString];
        fInfo.isPNG = NO;
    }
    else if (assetURL) {
        //image is from the library
        
        ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
        [assetLibrary assetForURL:assetURL resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            NSLog(@"filename: %@", rep.filename);
            if (rep.filename){
                fInfo.imageName = [rep.filename lowercaseString];
                
                fInfo.isPNG = [[[fInfo.imageName pathExtension] lowercaseString] isEqualToString:@"png"];
                
                NSLog(@"image is PNG? %d", fInfo.isPNG);
            }
            //NSLog(@"metadata: %@", rep.metadata);
            //Byte *buffer = (Byte*)malloc(rep.size);
            //NSUInteger buffered = [rep getBytes:buffer fromOffset:0.0 length:rep.size error:nil];
            //NSData *data = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];//this is NSData may be what you want
            //[data writeToFile:photoFile atomically:YES];//you can save image later
        } failureBlock:^(NSError *err) {
            NSLog(@"Error: %@",[err localizedDescription]);
        }];
    }
    // [self.cNewNote addImageInfo:fInfo];
    
    //    [self.cNewNote.imageArray addObject:_imgAttach];
    [picker dismissViewControllerAnimated:YES completion: ^(void) {
        CItem *item = [[CItem alloc] init];
        item.type = C_KNOTE;
        item.body = fInfo.imageName;
        
        ComposeThreadViewController *vc = [[ComposeThreadViewController alloc] initWithItem: item];
        vc.topic_id = self.tInfo.entity.topic_id;
        vc.subject = self.mainTitle;
        vc.delegate = self;
        vc.opType = ItemAdd;
        CKeyNoteItem *keyItem = nil;
        for (int i = 0 ; i<[self.currentData count]; i++) {
            keyItem = [self.currentData objectAtIndex:i];
            if ([keyItem isKindOfClass:[CKeyNoteItem class]]) {
                vc.keyItem = keyItem;
                break;
            }
        }
        
        vc.cNewNote = [[ComposeNewNote alloc] init];
        vc.cNewNote.delegate = vc;
        vc.currentView = (ComposeView *)vc.cNewNote;
        
        [vc.cNewNote addImageInfo: fInfo];
        [vc postData];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Utility Functions

- (void)stopActivityView
{
    [self HideKnoteLoadingView];
    
    if ([self.currentData count] == 0)
    {
        [self ShowEmptyPadOverlay:NO];
    }
    else
    {
        [self HideEmptyPadOverlay];
    }
}

- (void)addItemsWithMessages:(NSArray *)array
{
    NSArray* addedItems = [NSArray array];
    ThreadItemManager* threadManager = [ThreadItemManager sharedInstance];
    for (MessageEntity *message in array)
    {
        //NSLog(@"Message order: %lld archived: %d title: %@", message.order, message.archived, message.title);
        
        CItem *item = nil;
        
        if (message.type == C_KEYKNOTE)
        {
            CItem *item = [[ThreadItemManager sharedInstance] findExistingItemById:message.message_id];
            
            if (item)
            {
                self.keyNoteItem = (CKeyNoteItem *)item;
            }
            else
            {
                if (!self.keyNoteItem)
                {
                    self.keyNoteItem = [[CKeyNoteItem alloc] initWithMessage:message];
                }
                else
                {
                    [self.keyNoteItem setCommonValueByMessage:message];
                }
            }
        }
        else if (message.type == C_LOCK)
        {
            CItem *item = [[ThreadItemManager sharedInstance] findExistingItemById:message.message_id];
            
            if (item)
            {
                self.lockItem = (CLockItem *)item;
            }
            else
            {
                if (!self.lockItem)
                {
                    self.lockItem = [[CLockItem alloc] initWithMessage:message];
                }
                else
                {
                    [self.lockItem setCommonValueByMessage:message];
                }
            }
        }
        else
        {
            addedItems = [threadManager generateItemsForMessage:message
                                                      withTopic:self.tInfo.entity];
            
            if ([message type] != 0 || [message pinned] || (![message.containerName isEqualToString:CONTAINER_NAME_MAIN])) {
                [self.rightData addObjectsFromArray: addedItems];
            }else{
                [self.currentData addObjectsFromArray: addedItems];
            }
        }
        
        item.checkInCloud = NO;
    }
    
    [threadManager.knotesArray addObjectsFromArray: addedItems];
    
    if ( self.tInfo.entity.locked_id && [self.tInfo.entity.locked_id length]>0)
    {
        self.keyNoteItem.isLocked = YES;
        
        if (self.keyNoteItem.userData)
        {
            if ([self.keyNoteItem type] != 0 || self.keyNoteItem.isPinned) {
                if (![self.rightData containsObject:self.keyNoteItem])
                {
                    [self.rightData insertObject:self.keyNoteItem atIndex:0];
                }
            }else{
                if (![self.currentData containsObject:self.keyNoteItem])
                {
                    [self.currentData insertObject:self.keyNoteItem atIndex:0];
                }
            }
        }
        
        if (self.lockItem)
        {
            if ([self.lockItem type] != 0 || self.lockItem.isPinned) {
                if (![self.rightData containsObject:self.lockItem])
                {
                    [self.rightData insertObject:self.lockItem atIndex:0];
                }
            }else{
                if (![self.currentData containsObject:self.lockItem])
                {
                    [self.currentData insertObject:self.lockItem atIndex:0];
                }
            }
            
        }
        
    }
    else
    {
        if (self.keyNoteItem)
        {
            if ([self.keyNoteItem type] != 0 || self.keyNoteItem.isPinned) {
                if (![self.rightData containsObject:self.keyNoteItem])
                {
                    [self.rightData insertObject:self.keyNoteItem atIndex:0];
                }
            }else {
                if (![self.currentData containsObject:self.keyNoteItem])
                {
                    [self.currentData insertObject:self.keyNoteItem atIndex:0];
                }
            }
            
        }
    }
    
    self.banPosition = 0;
    
    if (self.keyNoteItem)
    {
        self.banPosition++;
    }
    
    if (self.lockItem)
    {
        self.banPosition++;
    }
}

- (void)ReoadLocalKnotes
{
    NSLog(@"ReoadLocalKnotes");
    
    [self.currentData removeAllObjects];
    
    NSArray *messages = nil;
    
    NSMutableString *predicateString = [@"topic_id = %@" mutableCopy];
    
    if (!self.tInfo.entity.topic_id)
    {
        return;
    }
    
    NSMutableArray *arguments = [[NSMutableArray alloc] initWithObjects:self.tInfo.entity.topic_id, nil];
    
    NSString *sortString = nil;
    
    if (!_showArchived)
    {
        [predicateString appendString :@" AND archived = NO"];
    }
    
    if (_orderByLike)
    {
        sortString = @"likes_count:NO,time:NO";
    }
    else
    {
        sortString = @"pinned:YES,order:YES,time:NO";
    }
    
    
    messages = [MessageEntity MR_findAllSortedBy:sortString
                                       ascending:YES
                                   withPredicate:[NSPredicate predicateWithFormat:predicateString argumentArray:arguments]];
    
    [self addItemsWithMessages:messages];
//    [self.tableView reloadData];
//    [self.tableViewRight reloadData];
}

-(void)updateSharedTopicContacts
{
    [self topicChange];
}

-(void) updateSharedTopicContact:(ContactsEntity*)usertoAdd Removed:(BOOL)bRemove
{
    NSString *topicID = [self.tInfo.entity.topic_id copy];
    
    OMPromise *addPromise = nil, *removePromise = nil;
    
    if(!bRemove)
    {
        NSMutableArray *emailsToAdd =[NSMutableArray arrayWithObject:usertoAdd.email];
        NSArray *addParams = @[self.tInfo.entity.topic_id, emailsToAdd];
        
        addPromise = [[PostingManager sharedInstance] enqueueMeteorMethod:@"addContactsToTopic"
                                                               parameters:addParams];
        
        [addPromise fulfilled:^(id result)
         {
             NSDictionary *parameters = @{ @"topicId":       self.tInfo.entity.topic_id,
                                           @"contactEmail":  usertoAdd.email };
             
             [[AnalyticsManager sharedInstance] notifyContactWasAddedToPadWithParameters:parameters];
             
             NSLog(@"addContactsToTopic success response: %@", result);
             
         }];
        
        [addPromise failed:^(NSError *error) {
            NSLog(@"addContactsToTopic error: %@", error);
            //[[NSNotificationCenter defaultCenter] postNotificationName:KnotebleShowPopUpMessage object:@"Network is failed, please try again." userInfo:nil];
        }];
    }
    else
    {
        NSLog(@"email to remove: %@", usertoAdd.email);
        
        NSArray *removeParams = @[topicID, usertoAdd.email];
        
        removePromise = [[PostingManager sharedInstance] enqueueMeteorMethod:@"removeContactFromThread"
                                                                  parameters:removeParams];
        
        [removePromise fulfilled:^(id result) {
            
            NSLog(@"removeContactFromThread success main thread? %d response: %@", [[NSThread currentThread] isMainThread],result);
            
            NSDictionary *parameters = @{ @"topicId": self.tInfo.entity.topic_id,
                                          @"contactEmail": usertoAdd.email };
            
            [[AnalyticsManager sharedInstance] notifyContactWasRemovedFromPadWithParameters:parameters];
            
            NSNumber *didRemoveNum = result;
            BOOL didRemove = didRemoveNum.boolValue;
            
            if (self.formSheetController)
            {
                [self.formSheetController dismissAnimated:YES completionHandler:Nil];
            }
            
            if(didRemove)
            {
                //Remove locally from core data
                NSLog(@"did remove contact: %@", usertoAdd.email);
            }
            else
            {
                NSLog(@"did not remove contact: %@", usertoAdd.email);
            }
            
        }];
        [removePromise failed:^(NSError *error) {
            NSLog(@"removeContactFromThread error: %@", error);
            
        }];
    }
    
    OMPromise *allDonePromise;
    
    if (addPromise && removePromise)
    {
        allDonePromise = [OMPromise all:@[addPromise, removePromise]];
    }
    else
    {
        allDonePromise = addPromise ? addPromise : removePromise;
    }
    
    [allDonePromise fulfilled:^(id result)
     {
         
     }];
    
    NSLog(@"updating local contacts");
    
    if (self.tInfo)
    {
        NSMutableArray *shared_account_ids = [[self.tInfo.entity.shared_account_ids componentsSeparatedByString:@","] mutableCopy];
        
        if(!bRemove)
        {
            if (![shared_account_ids containsObject:usertoAdd.account_id]) {
                NSLog(@"adding contact with account_id: %@", usertoAdd.account_id);
                [shared_account_ids addObject:usertoAdd.account_id];
            }
            
        }
        else
        {
            if ([shared_account_ids containsObject:usertoAdd.account_id])
            {
                NSLog(@"removing contact with account_id: %@", usertoAdd.account_id);
                [shared_account_ids removeObject:usertoAdd.account_id];
            }
            
        }
        
        NSString *new_account_ids = [shared_account_ids componentsJoinedByString:@","];
        NSLog(@"new account ids: %@", new_account_ids);
        
        self.tInfo.entity.shared_account_ids = new_account_ids;
        
        [AppDelegate saveContext];
        
        [self updateSharedTopicContacts];
    }
}

-(NSMutableArray *)getSharedPeople:(BOOL)flag
{
    // If we have participators, flag means we will get contacts that are already
    // participators and not archived. flag=NO means we will get everyone else
    // If we don't have participators, flag means we get all contacts not archived,
    // flag=NO means we get all archived contacts very confusing!!
    
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:3];
    
    NSMutableArray *peopleItem = [[self.tInfo.entity.shared_account_ids componentsSeparatedByString:@","] mutableCopy];
    NSMutableArray *missingAccontIds  =[[NSMutableArray alloc] initWithCapacity:3];
    
    for (int i = 0; i < [peopleItem count]; i++ )
    {
        NSString *account_id = peopleItem[i];
        
        ContactsEntity *contact = [ContactsEntity MR_findFirstByAttribute:@"account_id" withValue:account_id];
        
        if (contact)
        {
            if (flag)
            {
                [mArray addObject:contact];
            }
            else
            {
                if (!contact.archived)
                {
                    [mArray addObject:contact];
                }
            }
        }
        else
        {
            if ([DataManager sharedInstance].currentAccount.account_id && account_id) {
                if (account_id) {
                    [missingAccontIds addObject:account_id];
                }
            }
            
            [ContactManager findContactFromServerByAccountId:account_id
                                              withNofication:NEW_CONTACT_DOWNLOADED_NOTIFICATION
                                           withCompleteBlock:nil];
        }
        
        
    }
    if (missingAccontIds.count>0 && [DataManager sharedInstance].currentAccount.account_id) {
        [[PostingManager sharedInstance] enqueueLocalMethod:@"addContactsFromTopicParticipators"
                                                 parameters:@[missingAccontIds,[DataManager sharedInstance].currentAccount.account_id]];
    }
    return mArray;
}

-(NSMutableArray *)getPartyPeople:(BOOL)flag
{
    //If we have participators, flag means we will get contacts that are already participators and not archived. flag=NO means we will get everyone else
    //If we don't have participators, flag means we get all contacts not archived, flag=NO means we get all archived contacts
    //Very confusing!!
    
    NSMutableArray *mArray = [[NSMutableArray alloc] initWithCapacity:3];
    
    NSMutableArray *peopleItem = [[self.tInfo.entity.shared_account_ids componentsSeparatedByString:@","] mutableCopy];
    
    NSPredicate *predicate = nil;
    NSMutableArray *missingAccontIds  =[[NSMutableArray alloc] initWithCapacity:3];
    for (int i = 0; i<[peopleItem count]; i++)
    {
        NSString *account_id = peopleItem[i];
        
        ContactsEntity *contact = [ContactsEntity MR_findFirstByAttribute:@"account_id" withValue:account_id];
        
        if (!contact)
        {
            if (account_id) {
                [missingAccontIds addObject:account_id];
            }
            
            [ContactManager findContactFromServerByAccountId:account_id
                                              withNofication:NEW_CONTACT_DOWNLOADED_NOTIFICATION
                                           withCompleteBlock:nil];
            
        }
        else
        {
            NSLog(@"%@", contact);
        }
    }
    
    if (missingAccontIds.count>0 && [DataManager sharedInstance].currentAccount.account_id) {
        [[PostingManager sharedInstance] enqueueLocalMethod:@"addContactsFromTopicParticipators"
                                                 parameters:@[missingAccontIds,[DataManager sharedInstance].currentAccount.account_id]];
    }
    
    NSLog(@"getPartyPeople peopleItem: %@", peopleItem);
    
    if (peopleItem && [peopleItem count]>0)
    {
        if (flag)
        {
            id obj_to_remove = nil;
            
            for (NSString *str in peopleItem)
            {
                if ([str isEqualToString:self.login_user.getFirstEmail])
                {
                    obj_to_remove = str;
                    
                    break;
                }
            }
            
            if(obj_to_remove)
            {
                [peopleItem removeObject:obj_to_remove];
            }
            
            NSLog(@"getPartyPeople querying for contacts IN peopleItem");
            
            predicate = [NSPredicate predicateWithFormat:@"(account_id IN %@) and archived == %@", peopleItem,@(NO)];
        }
        else
        {
            NSLog(@"getPartyPeople querying for contacts NOT in peopleItem");
            
            predicate = [NSPredicate predicateWithFormat:@"NOT (mainEmail IN %@) and archived == %@", peopleItem,@(NO)];
        }
    }
    else
    {
        if (flag)
        {
            predicate = [NSPredicate predicateWithFormat:@"archived == %@", @(NO)];
        }
        else
        {
            predicate = [NSPredicate predicateWithFormat:@"NOT archived == %@", @(NO)];
        }
    }
    
    NSArray *users = [ContactsEntity MR_findAllSortedBy:@"cid" ascending:NO withPredicate:predicate];
    //    NSLog(@"getPartyPeople found contacts: %@", users);
    
    for (ContactsEntity *contact in users) {
        if ([contact.account_id isEqualToString:self.login_user.contact.account_id] && ![contact.isMe boolValue]) {
            continue;
        }
        NSString * text = contact.name;
        
        if (contact.gravatar_exist) {
            DLog(@"Downloading avatar for %@", contact);
            NSString *md5str = [CUtil hashForEmail:contact.mainEmail];
            
            if ( ![CUtil imageInfileCache:contact.mainEmail]) {
                
                [contact getAsyncImageWithBlock:^(id img, BOOL flag) {
                    if (flag == YES) {
                        [self.tableView reloadData];
                    }
                }];
                
                if ([text length]>0) {
                    text = [text substringWithRange:NSMakeRange(0, 1)].uppercaseString;
                    UIImage *img = [CUtil imageText:text withBackground:contact.bgcolor size:CGSizeMake(40, 40) rate:0.6];
                    SHMenuItem *item = [SHMenuItem initWithName:contact.name Email:contact.mainEmail andImage:img];
                    [mArray addObject:item];
                }
            } else {
                NSString *path  = [kImageCachePath stringByAppendingPathComponent:md5str];
                UIImage *img = [UIImage imageWithContentsOfFile:path];
                SHMenuItem *item = [SHMenuItem initWithName:contact.name Email:contact.mainEmail andImage:img];
                [mArray addObject:item];
            }
        } else {
            if ([text length]>0) {
                text = [text substringWithRange:NSMakeRange(0, 1)].uppercaseString;
                UIImage *img = [CUtil imageText:text withBackground:contact.bgcolor size:CGSizeMake(40, 40) rate:0.6];
                SHMenuItem *item = [SHMenuItem initWithName:contact.name Email:contact.mainEmail andImage:img];
                [mArray addObject:item];
            }
        }
    }
    
    return mArray;
}

-(void) removedContactFromPad:(ContactsEntity*)contact
{
    NSString *topicID = [self.tInfo.entity.topic_id copy];
    
    if ([AppDelegate sharedDelegate].meteor
        && [AppDelegate sharedDelegate].meteor.connected)
    {
        NSArray * mailsArray = [contact.email componentsSeparatedByString:@","];
        
        if ([mailsArray count] > 0)
        {
            NSArray *params = @[topicID,
                                [mailsArray firstObject]];
            
            [[AppDelegate sharedDelegate].meteor callMethodName:@"removeContactFromThread"
                                                     parameters:params
                                               responseCallback:^(NSDictionary *response, NSError *error)
             {
                 if (error == Nil)
                 {
                     if (response)
                     {
                         NSInteger result = [response[@"result"] integerValue];
                         
                         if (result == 1)
                         {
                             NSLog(@"Success");
                             
                             if (self.formSheetController)
                             {
                                 [self.formSheetController dismissAnimated:YES completionHandler:Nil];
                             }
                             
                             NSMutableArray *shared_account_ids = [[self.tInfo.entity.shared_account_ids componentsSeparatedByString:@","] mutableCopy];
                             
                             if ([shared_account_ids containsObject:contact.account_id])
                             {
                                 NSLog(@"removing contact with account_id: %@", contact.account_id);
                                 [shared_account_ids removeObject:contact.account_id];
                             }
                             
                             NSString *new_account_ids = [shared_account_ids componentsJoinedByString:@","];
                             NSLog(@"new account ids: %@", new_account_ids);
                             
                             self.tInfo.entity.shared_account_ids = new_account_ids;
                             
                             [AppDelegate saveContext];
                             
                             [self updateSharedTopicContacts];
                             
                         }
                         else
                         {
                             NSLog(@"Failed");
                         }
                     }
                 }
                 
             }];
        }
        
    }
}

#pragma mark - Observer functions for Knotes and Messages

- (void)Ready_topic
{
    [self HideKnoteLoadingView];
    
    self.isReady_topic = YES;
    
    [self check_ReadyToUse_Knote];
}

- (void)Ready_pinnedKnotes
{
    self.isReady_pinnedKnotes = YES;
    
    [self check_ReadyToUse_Knote];
}

- (void)Ready_archivedKnotes
{
    self.isReady_archivedKnotes = YES;
    
    [self check_ReadyToUse_Knote];
    
    [self check_KnotesCount];
}

- (BOOL)check_ReadyToUse_Knote
{
    /*
     // Let's not wait for arhived which may take long and not even been displayed
     if (self.isReady_topic
     && self.isReady_pinnedKnotes
     && self.isReady_archivedKnotes)
     */
    if (self.isReady_topic
        && self.isReady_pinnedKnotes)
    {
        //DLog(@"We are ready to hide animation");
        
        NSString* end_log = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                           dateStyle:NSDateFormatterShortStyle
                                                           timeStyle:NSDateFormatterLongStyle];
        
        NSString* final_log = [NSString stringWithFormat:@"Started : %@\nEnded : %@", self.log_knotes_loading, end_log];
        
        DLog(@"%@", final_log);
        
        if (!_isReady_toGetRest)
        {
            self.isReady_toGetRest = YES;
            
            if (self.tInfo) {
                [[AppDelegate sharedDelegate].meteor addSubscription:METEORCOLLECTION_KNOTE_REST withParameters:@[self.tInfo.topic_id]];
            }
        }
        
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)check_KnotesCount
{
    NSInteger total_knotes = 0;
    
    DLog(@"%d", _showArchived);
    [_loadingGhostScreen removeFromSuperview];
    self.tableView.tableHeaderView=nil;
    if (self.count_topic > 10)
    {
        total_knotes = 10 + self.count_pinnedKnotes + self.count_archivedKnotes;
    }
    else
    {
        total_knotes = self.count_topic + self.count_pinnedKnotes + self.count_archivedKnotes;
    }
    
    if ((total_knotes == self.counter_knote_added)
        && [self check_ReadyToUse_Knote])
    {
        NSString* end_log = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                                           dateStyle:NSDateFormatterShortStyle
                                                           timeStyle:NSDateFormatterMediumStyle];
        
        NSTimeInterval dutation_val = [[NSDate date] timeIntervalSinceDate:self.start_Subscription_date];
        
        NSString* duration = [NSString stringWithFormat:@"Due : %f s", dutation_val];
        
        NSString* final_log = [NSString stringWithFormat:@"\n%@\n-------------\nStarted : %@\nEnded : %@\n\n%@",
                               self.tInfo.entity.topic, self.log_knotes_loading, end_log, duration];
        
        DLog(@"%@", final_log);
        
        self.isReady_toGoBack = YES;
        
        if (!_isReady_toGetRest)
        {
            
            self.isReady_toGetRest=YES;
            
            [[AppDelegate sharedDelegate].meteor addSubscription:METEORCOLLECTION_KNOTE_REST
                                                  withParameters:@[self.tInfo.topic_id]];
        }
        
        [self sortknotesByOrder];
        if (_isAddedPullRefresh_toGetRest)
        {
            [_pullToRefreshManager tableViewReloadFinished];
        }
        [self.tableView reloadData];
    }
    else
    {
        [self sortknotesByOrder];
        if (_isAddedPullRefresh_toGetRest)
        {
            [_pullToRefreshManager tableViewReloadFinished];
        }
        [self.tableView reloadData];
        [self.tableViewRight reloadData];
    }
    
}

-(void)gotActiveKnotesCount:(NSNotification *)note
{
    NSDictionary* serverData = Nil;
    
    if (note.userInfo)
    {
        serverData = note.userInfo;
    }
    
    if (serverData[@"count"])
    {
        NSLog(@"********** Active Knote Count : %ld**********", (long)[serverData[@"count"] integerValue]);
        
        self.count_topic = [serverData[@"count"] integerValue];
        if(self.count_topic <= self.currentData.count){
            [self HideKnoteLoadingView];
        }else{
            [self ShowKnoteLoadingView];
        }
    }
}

-(void)gotPinnedKnotesCount:(NSNotification *)note
{
    NSDictionary* serverData = Nil;
    
    if (note.userInfo)
    {
        serverData = note.userInfo;
    }
    
    if (serverData[@"count"])
    {
        NSLog(@"**********Pinned Knote Count : %ld**********", (long)[serverData[@"count"] integerValue]);
        
        self.count_pinnedKnotes = [serverData[@"count"] integerValue];
        if ( self.currentData == nil || self.currentData.count == 0) {
            NSLog(@"Callling LOADRESTKNOTES");
            ////  [_pullToRefreshManager tableViewReleased];
            //[self.tableView reloadData];
        }
    }
}

-(void)gotArchivedKnotesCount:(NSNotification *)note
{
    NSDictionary* serverData = Nil;
    
    if (note.userInfo)
    {
        serverData = note.userInfo;
    }
    
    if (serverData[@"count"])
    {
        NSLog(@"**********Archived Knote Count : %ld**********", (long)[serverData[@"count"] integerValue]);
        
        self.count_archivedKnotes = [serverData[@"count"] integerValue];
    }
    
    //    if (self.count_archivedKnotes == 0)
    //    {
    //        [self check_KnotesCount];
    //    }
    
}

- (void)gotRestKnotesCount:(NSNotification *)note
{
    NSDictionary* serverData = Nil;
    if (note.userInfo)
    {
        serverData = note.userInfo;
    }
    
    if (serverData[@"count"])
    {
        NSLog(@"**********Rest Knote Count : %ld**********", (long)[serverData[@"count"] integerValue]);
        
        self.count_restKnotes = [serverData[@"count"] integerValue];
        
        /*NSUserDefaults *extensionUserDefaults = [[NSUserDefaults alloc]initWithSuiteName:@"group.knotable.knotedev.share"];
         [extensionUserDefaults setObject:serverData forKey:@"Knotes"];
         [extensionUserDefaults synchronize];*/
        /*[_pullToRefreshManager tableViewReloadFinished];
         [_pullToRefreshManager setPullToRefreshViewVisible:NO];*/
    }
}

-(void)restKnotesAdded:(NSNotification *)note {
    NSLog(@"new knote: %@", note.userInfo);
}

-(void)knotesAdded:(NSNotification *)note
{
    NSDictionary* serverData = Nil;
    if (_isReady_toGetRest)
    {
        if (note.userInfo)
        {
            self.showFooter = NO;
            
            serverData = note.userInfo;
            
            if (![[serverData objectForKey:@"type"] isEqualToString:@"knote"] || [serverData objectForKey:@"pinned"]) {
//                [self ProcessOnlyKnoteWithDict:serverData];
            }else{
                [self.RestData addObject:serverData];
                if (!_isAddedPullRefresh_toGetRest)
                {
                    _isAddedPullRefresh_toGetRest=YES;
                    _pullToRefreshManager = [[MNMBottomPullToRefreshManager alloc] initWithPullToRefreshViewHeight:0.0f tableView:_tableView withClient:self];
                    //// [_pullToRefreshManager tableViewReleased];
                    //// [_pullToRefreshManager tableViewReloadFinished];
                }
            }
            
        }
    }
    else
    {
        self.counter_knote_added = self.counter_knote_added + 1;
        if (note.userInfo)
        {
            serverData = note.userInfo;
            
            [self ProcessOnlyKnoteWithDict:serverData];
        }
        
        [self check_KnotesCount];
    }
}

-(void)knotesRemoved:(NSNotification *)note
{
    NSLog(@"KNOTES REMOVED");
    
    NSDictionary* serverData = Nil;
    
    if (note.userInfo)
    {
        serverData = note.userInfo;
        
        NSString* deleteID = serverData[@"_id"];
        CItem* item = [self findItemInArry: self.currentData byItemId: deleteID];
        
        if (item != nil)
        {
            NSMutableArray* knotesArray = [ThreadItemManager sharedInstance].knotesArray;
            [knotesArray removeObjectIdenticalTo: item];
            
            NSUInteger index = [self.currentData indexOfObject: item];
            [self.currentData removeObjectAtIndex: index];
            
            [self.tableView deleteRowsAtIndexPaths: @[[NSIndexPath indexPathForRow: index inSection: 0] ] withRowAnimation:UITableViewRowAnimationFade];
        }
        
    }
}

-(void)knotesChanged:(NSNotification *)note
{
    NSLog(@"KNOTES CHANGED");
    
    NSDictionary* serverData = Nil;
    
    if (note.userInfo)
    {
        serverData = note.userInfo;
        
        [self ProcessOnlyKnoteWithDict:serverData];
    }
    if (self.tableView.frame.origin.x == 0) {
        if ([self.currentData count] > 0)
        {
            [self.tableView reloadData];
        }
    }else{
        if ([self.rightData count] > 0)
        {
            [self.firstDot setHidden:NO];
            [self.secondDot setHidden:NO];
            [self.tableViewRight reloadData];
        }
    }
}

- (void) addedTopic:(NSNotification *)notification
{
    NSLog(@"Added Topic");
    NSDictionary* topic_info = notification.userInfo;
    NSString *topic_id = topic_info[@"_id"];
    
    AccountEntity* account = [DataManager sharedInstance].currentAccount;
    NSString* account_id = account.account_id;
    NSArray *archivedAccountIDs = topic_info[@"archived"];
    
    if ([archivedAccountIDs containsObject: account_id])
    {// not active topic
        return;
    }
    
    // if current topic is temp(offline), or not created(nil), it is replaced by added topic
    //    if current topic_id == new_topic_id, upload contains
    if (self.tInfo == nil || [self.tInfo.topic_id hasPrefix: kKnoteIdPrefix] ||
        [self.tInfo.topic_id isEqualToString: topic_id])
    {
        TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:topic_id];
        if ([self.tInfo.entity isEqual: topic] == NO)
        {
            TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:topic];
            [self changeTopic: tInfo];
        }
        
        NSString* newTitle = topic_info[@"subject"];
        [self updateTitleWith: newTitle];
    }
}

- (void) changedTopic:(NSNotification *)notification
{
    NSLog(@"Inside Changed Topic");
    NSDictionary* topic_info = notification.userInfo;
    NSString *topic_id = topic_info[@"_id"];
    
    AccountEntity* account = [DataManager sharedInstance].currentAccount;
    NSString* account_id = account.account_id;
    NSArray *archivedAccountIDs = topic_info[@"archived"];
    
    if ([archivedAccountIDs containsObject: account_id])
    {// not active topic
        return;
    }
    
// if current topic is temp(offline), or not created(nil), it is replaced by added topic
//    if current topic_id == new_topic_id, upload contains
    if (self.tInfo == nil || [self.tInfo.topic_id hasPrefix: kKnoteIdPrefix] ||
        [self.tInfo.topic_id isEqualToString: topic_id])
    {
        TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:topic_id];
        if ([self.tInfo.entity isEqual: topic] == NO)
        {
            TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:topic];
            [self changeTopic: tInfo];
        }

        NSString* newTitle = topic_info[@"subject"];
        [self updateTitleWith: newTitle];
    }

//    NSRange range = [self.tInfo.topic_id rangeOfString: topic_id];
//    
////    if ([self.tInfo.topic_id isEqualToString:topic_id])
//    if (range.location != NSNotFound)
//    {
//        TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:topic_id];
//        NSString* newTitle = topic.topic;
//
//        if (self.tInfo.entity != topic)
//        {
//            TopicInfo *tInfo = [[TopicInfo alloc] initWithTopicEntity:topic];
//            self.tInfo = tInfo;
//        }
//       
//        if ([newTitle isEqual: self.mainTitle] == NO)
//        {
//            [self needRefreshView];
//        }
//    }
}

- (void)topicChangedIdNotificationReceived:(NSNotification *)notification {
    NSString *topicId = notification.userInfo[@"topicId"];
    [self topicChangedId:topicId];
}

- (void)topicChangedId:(NSString *)topicId {
    if ([self.tInfo.topic_id isEqualToString:topicId] || [[self.tInfo.topic_id noPrefix:kKnoteIdPrefix] isEqualToString:topicId]) {
        [self removeSubscriptionsToMeteorCollections];
        [self addSubscriptionsToMeteorCollectionsForTopicWithId:self.tInfo.topic_id];
        NSLog(@"Knotable: ThreadViewController observing topic with id: %@", self.tInfo.topic_id);
//        [self.delegate needChangeTopicTitle:self.tInfo];
        NSString* newTitle = self.tInfo.entity.topic;
        if ([self.mainTitle isEqualToString: newTitle] == NO)
        {
            self.mainTitle = newTitle;
            [self customizeTitleLabel];
        }
    }
}


-(void)operatorThreadItem:(NSNotification *)notification
{
    NSLog(@".");
    
    if (notification.object)
    {
        CItem *item = (CItem *)notification.object;
        
        switch (item.opType)
        {
            case C_OP_PINNED:
            {
                if (self.tableView.frame.origin.x == 0) {
                    [self.tableView reloadData];
                }else{
                    [self.tableViewRight reloadData];
                }
                
            }
            case C_OP_LIKE:
            {
                if (self.tableView.frame.origin.x == 0) {
                    [self.tableView reloadData];
                }else{
                    [self.tableViewRight reloadData];
                }
                
            }
                break;
            case C_OP_DELETE:
            {
                MessageEntity *message = (MessageEntity *)item.userData;
                
                NSLog(@"%s [Line %d] DELETING MESSAGE: %@" , __FUNCTION__ , __LINE__ , message.message_id );
                
                switch (item.type)
                {
                    case C_KEYKNOTE:
                    {
                        [message MR_deleteEntity];
                        
                        self.tInfo.entity.key_id = nil;
                    }
                        break;
                        
                    case C_LOCK:
                    {
                        [message MR_deleteEntity];
                        
                        self.tInfo.entity.locked_id = nil;
                        
                        self.keyNoteItem.isLocked = NO;
                        
                        if (self.tableView.frame.origin.x) {
                            [self.currentData removeObject:item];
                            
                            if (![self.currentData containsObject:self.keyNoteItem])
                            {
                                [self.currentData insertObject:self.keyNoteItem atIndex:0];
                            }
                            [self.tableView reloadData];
                        }else{
                            [self.rightData removeObject:item];
                            
                            if (![self.rightData containsObject:self.keyNoteItem])
                            {
                                [self.rightData insertObject:self.keyNoteItem atIndex:0];
                            }
                            [self.tableViewRight reloadData];
                        }
                        
                        
                    }
                        break;
                    default:
                    {
                        message.archived = YES;
                        
                        if (!self.showArchived)
                        {
                            //Remove all items and related items (pictures)
                            if (self.tableView.frame.origin.x == 0) {
                                for (int i=0;i<self.currentData.count; i++) {
                                    CItem *it = self.currentData[i];
                                    if ([item.itemId isEqualToString:it.itemId]) {
                                        [self.currentData removeObjectAtIndex:i--];
                                    }
                                }
                            }else{
                                for (int i=0;i<self.rightData.count; i++) {
                                    CItem *it = self.rightData[i];
                                    if ([item.itemId isEqualToString:it.itemId]) {
                                        [self.rightData removeObjectAtIndex:i--];
                                    }
                                }
                            }
                            
                        }
                        
                        break;
                    }
                }
            }
                
            default:
                
                break;
        }
        
        item.opType = C_OP_NONE;
        [AppDelegate saveContext];
        
    }
}

#pragma mark keyboard notifications

-(CItem *) itemWithId :(NSString *) itemId{
    
    CItem * item;
    
    for (CItem* iter in self.currentData){
        
        if ([iter.itemId isEqualToString:itemId]){
            item = iter;
            break;
        }
    }
    
    return item;
}

- (void)keyboardWasShown:(NSNotification*)notification
{
    if (self.indexItemBeingCommented ){
        
        CItem * item = [self itemWithId:self.indexItemBeingCommented];
        NSUInteger pos = [self.currentData indexOfObject:item];
        if (item && self.commentInput && !self.commentInput.isHidden){
            
            NSUInteger numberOfComments = item.subReplys.count;
            
            NSIndexPath *pathToLastRow = [NSIndexPath indexPathForRow:pos+ numberOfComments inSection:0];
            
            NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
            CGRect keyboardBounds;
            [keyboardBoundsValue getValue:&keyboardBounds];
            
            CGPoint offset = self.tableView.contentOffset;
            CGRect rectInTableView = [self.tableView rectForRowAtIndexPath:pathToLastRow];
            CGRect rectInSuperview = [self.tableView convertRect:rectInTableView toView:[self.tableView superview]];
            
            int sizeOverlaped =   (rectInSuperview.origin.y + rectInSuperview.size.height) - keyboardBounds.origin.y ;
            if ( sizeOverlaped > 0){
                UIEdgeInsets contentInsets = self.tableView.contentInset;
                contentInsets.bottom = keyboardBounds.size.height+40;
                self.tableView.contentInset = contentInsets;
                self.tableView.scrollIndicatorInsets = contentInsets;
            }
            
            [self.tableView setContentOffset:offset];
            
            [self.tableView scrollToRowAtIndexPath:pathToLastRow atScrollPosition:UITableViewScrollPositionBottom animated:YES];
            
        }
    }
    self.isKeyboardVisible = YES;
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    //    NSLog(@"");
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
#endif
        if (! self.commentInput.isHidden && self.isKeyboardVisible){
            
            NSValue *keyboardBoundsValue = [[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
            CGRect keyboardBounds;
            [keyboardBoundsValue getValue:&keyboardBounds];
            
            UIEdgeInsets contentInsets = self.tableView.contentInset;
            //contentInsets.bottom -= 40;
            contentInsets.bottom = 0;
            self.tableView.contentInset = contentInsets;
            self.tableView.scrollIndicatorInsets = contentInsets;
            
        }
        
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_3_2
    }
#endif
    
    if (self.cellInEditor){
        [self.cellInEditor.commentButton setSelected:NO];
    }
    
    self.isKeyboardVisible = NO;
}

- (void) startedEditingWith:(CEditBaseItemView *)view
{
    NSLog(@".");
    ComposeThreadViewController *vc = [[ComposeThreadViewController alloc] initWithItem:[view getItemData]];
    vc.subject = self.mainTitle;
    vc.topic_id = self.tInfo.entity.topic_id;
    vc.topic_type = self.tInfo.entity.topic_type;
    vc.opType = ItemModify;
    vc.itemLifeCycleStage = ItemSwapEditing;
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
}

- (void)navBtnClickAtIndex:(NSInteger)index withObject:(id)obj
{
    //    if (index == GmackTag)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(BOOL)threadHasArchivedKnotes{
    
    NSArray *messages = [NSArray array];
    
    NSMutableString *predicateString = [@"topic_id = %@" mutableCopy];
    
    if (self.tInfo.entity.topic_id){
        NSMutableArray *arguments = [[NSMutableArray alloc] initWithObjects:[self.tInfo.entity.topic_id noPrefix:kKnoteIdPrefix], nil];
        
        NSString *sortString = nil;
        [predicateString appendString :@" AND archived = YES"];
        
        if (_orderByLike){
            sortString = @"likes_count:NO,time:NO";
        }
        else{
            sortString = @"pinned:YES,order:YES,time:NO";
        }
        
        messages = [MessageEntity MR_findAllSortedBy:sortString
                                           ascending:YES
                                       withPredicate:[NSPredicate predicateWithFormat:predicateString argumentArray:arguments]];
    }
    
    return ((messages.count > 0) ? YES : NO);
}

#pragma mark -
#pragma mark UITableViewDateSource && delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger  count = 0;
    if (tableView == self.tableView) {
        if ([self.currentData count] >= 1)
        {
            [self HideEmptyPadOverlay];
        }
        
        count = [self.currentData count];
        
        if (! self.finishLoad && [self.currentData count] >0 && !self.isCreatingKnote)
        {
            // It's not working correctly: pads are left with a blank space at the bottom after they have fully loaded.
            // It's visible if you paint the footer of sections of a specific color and compare an empty pad vs a full pad.
            //count ++;
        }
        
    }else if (tableView == self.tableViewRight){
        count = self.rightData.count;
        
        if (count > 0) {
            [self.firstDot setHidden:NO];
            [self.secondDot setHidden:NO];
        }else{
            [self.firstDot setHidden:YES];
            [self.secondDot setHidden:YES];
        }
    }
    
    if(count > 0){
        [self.loadingGhostScreen removeFromSuperview];
    }
    
    return count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if([self threadHasArchivedKnotes]){
        if (self.showFooter)
        {
            return self.headerInfoView.frame.size.height;
        }else{
            return 0;
        }
        
    }else{
        return 0;
    }
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if((self.headerInfoView) && ([self threadHasArchivedKnotes]) ){
        if (self.showFooter)
        {
            return self.headerInfoView;
        }else{
            UIView * footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 12)];
            footer.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1.0];
            return footer;
        }
    }else{
        
        UIView * footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 12)];
        footer.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1.0];
        return footer;
    }
}

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGFloat)tableView:(RichTableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 0;
    if ([tableView isEqual:self.tableView]) {
        if (indexPath.row == [self.currentData count]
            && [self.currentData count] > 0
            && !self.finishLoad
            && !self.isCreatingKnote)
        {
            height = SPINER_IMAGE_SIZE;
        }
        else
        {
            indexPath = [tableView adaptedIndexPathForRowAtIndexPath:indexPath];
            CItem *item = nil;
            
            if(self.currentData.count > indexPath.row){
                item = [self.currentData objectAtIndex:indexPath.row];
                
                if([item isKindOfClass:[CPictureItem class]]){
                    return [self baseKnoteCellHeightForItem:item indexPath:indexPath];
                }
                
                // If item has images in it, we would increase height properly.
                
                CGFloat     offset = 0.0f;
                
                NSInteger   postImageCount = [[item files] count];
                NSInteger   embedImageCount = [[item.userData loadedEmbeddedImages] count];
                
                NSInteger   totalImageCount = postImageCount + embedImageCount;
                if (totalImageCount==0)
                {
                    if (item.userData.isImageDataAvailable)
                    {
                        totalImageCount=1;
                    }
                }
                if (totalImageCount)
                {
                    CGFloat h = ENTERPRIZEPOSTIMAGEHEIGHT;
                    if (totalImageCount>4)
                    {
                        if (item.userData.expanded)
                        {
                            h = ceil(totalImageCount/2.0)*(ENTERPRIZEPOSTIMAGEHEIGHT/2.0);
                        }
                    }
                    offset = h + ENTERPRIZEPOSTOFFSET - 25.0f;      // 160 : Image region height, 10.0f : space
                }
                
                height =[item getCellHeight] + offset;
            }
        }
        
    }else if ([tableView isEqual:self.tableViewRight]){
        if (indexPath.row == [self.rightData count]
            && [self.rightData count] > 0
            && !self.finishLoad
            && !self.isCreatingKnote)
        {
            height = SPINER_IMAGE_SIZE;
        }
        else
        {
            indexPath = [tableView adaptedIndexPathForRowAtIndexPath:indexPath];
            
            CItem *item = (CItem *)[self.rightData objectAtIndex:indexPath.row];
            
            if([item isKindOfClass:[CPictureItem class]]){
                return [self baseKnoteCellHeightForItem:item indexPath:indexPath];
            }
            
            // If item has images in it, we would increase height properly.
            
            CGFloat     offset = 0.0f;
            
            NSInteger   postImageCount = [[item files] count];
            NSInteger   embedImageCount = [[item.userData loadedEmbeddedImages] count];
            
            NSInteger   totalImageCount = postImageCount + embedImageCount;
            if (totalImageCount==0)
            {
                if (item.userData.isImageDataAvailable)
                {
                    totalImageCount=1;
                }
            }
            if (totalImageCount)
            {
                CGFloat h = ENTERPRIZEPOSTIMAGEHEIGHT;
                if (totalImageCount>4)
                {
                    if (item.userData.expanded)
                    {
                        h = ceil(totalImageCount/2.0)*(ENTERPRIZEPOSTIMAGEHEIGHT/2.0);
                    }
                }
                offset = h + ENTERPRIZEPOSTOFFSET - 25.0f;      // 160 : Image region height, 10.0f : space
            }
            
            height =[item getCellHeight] + offset;
        }
    }
    
    
    return height;
}

- (UIButton*)sw_addUtilityButtonWithColor:(UIColor *)color icon:(UIImage *)icon
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = color;
    [button setImage:icon forState:UIControlStateNormal];
    [button setContentMode:UIViewContentModeScaleAspectFit];
    return button;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    UIColor *darkGrayColor = [UIColor colorWithRed:0.26 green:0.26 blue:0.26 alpha:1.0];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:darkGrayColor icon:[UIImage imageNamed:@"delete_icon"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:darkGrayColor icon:[UIImage imageNamed:@"pencil_icon"]];
    [rightUtilityButtons sw_addUtilityButtonWithColor:darkGrayColor icon:[UIImage imageNamed:@"like_icon"]];
    
    return rightUtilityButtons;
}

- (Class)baseCellClassForMessage:(MessageEntity *)message
{
    Class cellClass;
    
    switch (message.type) {
        case C_DATE:
            cellClass = [DeadlineCell class];
            break;
        case C_LOCK:
            cellClass = [LockCell class];
            break;
        case C_KEYKNOTE:
            cellClass = [KeyKnoteCell class];
            break;
        case C_VOTE:
            cellClass = [VoteCell class];
            break;
        default:
            if([message hasPhotoAvailable] || [[message loadedEmbeddedImages] count]>0){
                cellClass = [PicturesCell class];
            } else {
                cellClass = [KnoteCell class];
            }
            break;
    }
    
    return cellClass;
}

- (CGFloat)baseKnoteCellHeightForItem:(CItem *)item indexPath:(NSIndexPath *)indexPath
{
    MessageEntity *message = item.userData;
    Class cellClass;
    CPictureItem *pictureItem = nil;
    
    if ([item isKindOfClass:[CPictureItem class]])
    {
        cellClass = [PicturesCell class];
        
        pictureItem = (CPictureItem *)item;
        
    }
    else
    {
        cellClass = [self baseCellClassForMessage:message];
    }
    
    BaseKnoteCell *prototypeCell = nil;
    
    if (prototypeCell == nil)
    {
        prototypeCell = [cellClass new];
    }
    
    if (pictureItem)
    {
        if (self.expandIndex && [indexPath compare:self.expandIndex] == NSOrderedSame)
        {
            [(PicturesCell *)prototypeCell setIsExpand:YES];
        }
        else
        {
            [(PicturesCell *)prototypeCell setIsExpand:NO];
        }
        
        [(PicturesCell *)prototypeCell setItemData:item];
        [(PicturesCell *)prototypeCell setIndexPath:indexPath];
    }
    else
    {
        [prototypeCell setMessage:message];
    }
    
    
    [prototypeCell setNeedsUpdateConstraints];
    [prototypeCell updateConstraintsIfNeeded];
    
    [prototypeCell.contentView setNeedsLayout];
    [prototypeCell.contentView layoutIfNeeded];
    
    [prototypeCell setMaxWidth];
    
    CGFloat height = [prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    return height;
}

- (NSIndexPath *)moveTableView:(RichTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath
{
    //	Uncomment these lines to enable moving a row just within it's current section
    //	if ([sourceIndexPath section] != [proposedDestinationIndexPath section]) {
    //		proposedDestinationIndexPath = sourceIndexPath;
    //	}
    
    return proposedDestinationIndexPath;
}

- (void) animateSpinnerOnTableCell : (UIView* ) spinner
{
    [UIView animateWithDuration:0.2
                          delay:0
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         // Rotate the spinner by M_PI_2 = PI/2 = 90 degrees
                         [spinner setTransform:CGAffineTransformRotate(spinner.transform, M_PI_2)];
                     }
                     completion:^(BOOL finished) {
                         if (!self.finishLoad){
                             [self animateSpinnerOnTableCell:spinner];
                         }
                     }];
}

- (UITableViewCell *)tableView:(RichTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    CEditBaseItemView *c;
    if ([tableView isEqual:self.tableView]) {
        if (indexPath.row == [self.currentData count])
        {
            cell = [[UITableViewCell alloc] init];
            [cell setUserInteractionEnabled:NO];
            
            UIImageView *spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle.png"]];
            spinner.frame = CGRectMake((320 - SPINER_IMAGE_SIZE) / 2, 10, SPINER_IMAGE_SIZE, SPINER_IMAGE_SIZE);
            spinner.alpha = 1;
            spinner.backgroundColor = [UIColor clearColor];
            return cell;
            
        }
        
        CItem *item = (CItem *)[self.currentData objectAtIndex:indexPath.row];
        item.archiveDelegate=self;
        
        static NSString *knoteCellIdentifier    = @"CEditKnoteItemView";
        static NSString *keynoteCellIdentifier  = @"CEditKeynoteItemView";
        static NSString *dateCellIdentifier     = @"CEditDateItemView";
        static NSString *voteCellIdentifier     = @"CEditVoteItemView";
        static NSString *lockCellIdentifier     = @"CEditLockItemView";
#if !NEW_DESIGN
        static NSString *newCommentCellIdentifier = @"CNewCommentItemView";
#endif
        if([item isKindOfClass:[CPictureItem class]])
        {
            PicturesCell *cell = [PicturesCell new];
            
            if (self.expandIndex && [indexPath compare:self.expandIndex] == NSOrderedSame)
            {
                cell.isExpand = YES;
            }
            else
            {
                cell.isExpand = NO;
            }
            //cell.backgroundColor=[UIColor grayColor];
            cell.itemData = item;
            cell.indexPath = indexPath;
            
            [cell setNeedsUpdateConstraints];
            [cell updateConstraintsIfNeeded];
            
            [cell.contentView setNeedsLayout];
            [cell.contentView layoutIfNeeded];
            
            [cell setMaxWidth];
            
            item.cell = cell;
            
            cell.baseItemDelegate = self;
            
            return cell;
            
        }
        
        switch (item.type) {
            case C_KEYKNOTE:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:keynoteCellIdentifier];
                
                if (!cell || ![cell isKindOfClass:[CEditKeynoteItemView class]])
                {
                    cell = [[CEditKeynoteItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:keynoteCellIdentifier];
                }
            }
                break;
            case C_DATE:
            {
                
                cell = [tableView dequeueReusableCellWithIdentifier:dateCellIdentifier];
                if (!cell || ![cell isKindOfClass:[CEditDateItemView class]])
                {
                    cell = [[CEditDateItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dateCellIdentifier];
                }
            }
                break;
            case C_VOTE:
            case C_LIST:
            {
                
                cell = [tableView dequeueReusableCellWithIdentifier:voteCellIdentifier];
                if (!cell || ![cell isKindOfClass:[CEditVoteItemView class]])
                {
                    cell = [[CEditVoteItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:voteCellIdentifier];
                }
                [(CEditVoteItemView *)cell setParticipators:[self.tInfo.entity.shared_account_ids componentsSeparatedByString:@","]];
                [(CEditVoteItemView *)cell setMy_account_id:[DataManager sharedInstance].currentAccount.account_id];
                
            }
                break;
            case C_LOCK:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:lockCellIdentifier];
                if (!cell || ![cell isKindOfClass:[CEditLockItemView class]])
                {
                    cell = [[CEditLockItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:lockCellIdentifier];
                }
            }
                break;
#if !NEW_DESIGN
            case C_REPlYS:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:knoteCellIdentifier];
                if (!cell || ![cell isKindOfClass:[CEditReplysItemView class]])
                {
                    cell = [[CEditReplysItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:knoteCellIdentifier];
                }
            }
                break;
            case C_NEW_COMMENT:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:newCommentCellIdentifier];
                if (!cell || ![cell isKindOfClass:[CNewCommentItemView class]])
                {
                    cell = [[CNewCommentItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newCommentCellIdentifier];
                    [cell performSelector:@selector(setParentTableView:) withObject:self.tableView];
                } else {
                    [cell performSelector:@selector(reset)];
                }
            }
                break;
#endif
            default:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:knoteCellIdentifier];
                
                if (!cell || ![cell isKindOfClass:[CEditKnoteItemView class]])
                {
                    cell = [[CEditKnoteItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:knoteCellIdentifier];
                }
                
                ((CEditKnoteItemView*)cell).baseItemDelegate = self;
            }
                break;
        }
        
        c = (CEditBaseItemView *)cell;
        
        
        if (item.expandedMode)
        {
            [c.showMoreButton setTitle:@"Less" forState:UIControlStateNormal];
        }
        else
        {
            [c.showMoreButton setTitle:@"More" forState:UIControlStateNormal];
        }
        
        //c.showsReorderControl = YES;
        
        if ([tableView indexPathIsMovingIndexPath:indexPath])
        {
            [c prepareForMove];
        }
        else
        {
            if (tableView.movingIndexPath != nil)
            {
                indexPath = [tableView adaptedIndexPathForRowAtIndexPath:indexPath];
            }
            
            c.baseItemDelegate = self;
            
            [c setItemData:item];
            
            c.index = indexPath.row;
            c.titleInfoBar.delegate = self;
            c.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        c.indexpath =indexPath;
        
        [c bringSubviewToFront:c.pinButton ];
        [c bringSubviewToFront:c.commentButton];
        
        if (item.isReplysExpand)
        {
            [c.commentButton setSelected:YES];
        }
        else
        {
            [c.commentButton setSelected:NO];
        }
        
        [c setCommentButtonImage];
        
        
        /********************************************************
         
         Function : Only delete own comments
         
         ********************************************************/
        
#if !NEW_DESIGN
        if (item.type == C_REPlYS)
        {
            if ([((CReplysItem*)item).content objectForKey:@"from"])
            {
                NSString*   replyerEmail = [((CReplysItem*)item).content objectForKey:@"from"];
                
                DLog(@"Replyer : %@", replyerEmail);
                
                DLog(@"Current User : %@", [DataManager sharedInstance].currentAccount.user);
                
                if ([replyerEmail isEqualToString:[DataManager sharedInstance].currentAccount.user.email])
                {
                    [c.doneButton setTag:indexPath.row +1];
                    UITapGestureRecognizer *doneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteKnote:)];
                    [doneTap setNumberOfTapsRequired:1];
                    [c.doneButton setUserInteractionEnabled:YES];
                    [c.doneButton addGestureRecognizer:doneTap];
                    
                    //[self configureKnoteCell:c forRowAtIndexPath:indexPath editable:NO deletable:YES];
                }
            }
        }
        else
#endif
        {
            [c.doneButton setTag:indexPath.item+1];
            //tmd * Remove gesture route, and use Action
//            UITapGestureRecognizer *doneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteKnote:)];
//            [doneTap setNumberOfTapsRequired:1];
//            [c.doneButton setUserInteractionEnabled:YES];
//            [c.doneButton addGestureRecognizer:doneTap];
            [c.doneButton addTarget:self action:@selector(deleteKnoteButtonTapped:withEvent:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [c.editButton setTag:indexPath.item+1];
            UITapGestureRecognizer *editTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editKnote:)];
            [editTap setNumberOfTapsRequired:1];
            [c.editButton setUserInteractionEnabled:YES];
            [c.editButton addGestureRecognizer:editTap];
            
            [c.bookMarkButon setTag:indexPath.item+1];
            UITapGestureRecognizer *bookMarkTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bookMarkKnote:)];
            [bookMarkTap setNumberOfTapsRequired:1];
            [c.bookMarkButon setUserInteractionEnabled:YES];
            [c.bookMarkButon addGestureRecognizer:bookMarkTap];
        }
        
    }else if ([tableView isEqual:self.tableViewRight]){
        if (indexPath.row == [self.rightData count])
        {
            cell = [[UITableViewCell alloc] init];
            [cell setUserInteractionEnabled:NO];
            
            UIImageView *spinner = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle.png"]];
            spinner.frame = CGRectMake((320 - SPINER_IMAGE_SIZE) / 2, 10, SPINER_IMAGE_SIZE, SPINER_IMAGE_SIZE);
            spinner.alpha = 1;
            spinner.backgroundColor = [UIColor clearColor];
            return cell;
            
        }
        
        CItem *item = (CItem *)[self.rightData objectAtIndex:indexPath.row];
        item.archiveDelegate=self;
        
        static NSString *knoteCellIdentifier    = @"CEditKnoteItemView";
        static NSString *keynoteCellIdentifier  = @"CEditKeynoteItemView";
        static NSString *dateCellIdentifier     = @"CEditDateItemView";
        static NSString *voteCellIdentifier     = @"CEditVoteItemView";
        static NSString *lockCellIdentifier     = @"CEditLockItemView";
#if !NEW_DESIGN
        static NSString *newCommentCellIdentifier = @"CNewCommentItemView";
#endif
        if([item isKindOfClass:[CPictureItem class]])
        {
            PicturesCell *cell = [PicturesCell new];
            
            if (self.expandIndex && [indexPath compare:self.expandIndex] == NSOrderedSame)
            {
                cell.isExpand = YES;
            }
            else
            {
                cell.isExpand = NO;
            }
            //cell.backgroundColor=[UIColor grayColor];
            cell.itemData = item;
            cell.indexPath = indexPath;
            
            [cell setNeedsUpdateConstraints];
            [cell updateConstraintsIfNeeded];
            
            [cell.contentView setNeedsLayout];
            [cell.contentView layoutIfNeeded];
            
            [cell setMaxWidth];
            
            item.cell = cell;
            
            cell.baseItemDelegate = self;
            
            return cell;
            
        }
        
        switch (item.type) {
            case C_KEYKNOTE:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:keynoteCellIdentifier];
                
                if (!cell || ![cell isKindOfClass:[CEditKeynoteItemView class]])
                {
                    cell = [[CEditKeynoteItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:keynoteCellIdentifier];
                }
            }
                break;
            case C_DATE:
            {
                
                cell = [tableView dequeueReusableCellWithIdentifier:dateCellIdentifier];
                if (!cell || ![cell isKindOfClass:[CEditDateItemView class]])
                {
                    cell = [[CEditDateItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dateCellIdentifier];
                }
            }
                break;
            case C_VOTE:
            case C_LIST:
            {
                
                cell = [tableView dequeueReusableCellWithIdentifier:voteCellIdentifier];
                if (!cell || ![cell isKindOfClass:[CEditVoteItemView class]])
                {
                    cell = [[CEditVoteItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:voteCellIdentifier];
                }
                [(CEditVoteItemView *)cell setParticipators:[self.tInfo.entity.shared_account_ids componentsSeparatedByString:@","]];
                
                ((CEditVoteItemView *)cell).isRight=YES;
                [(CEditVoteItemView *)cell setMy_account_id:[DataManager sharedInstance].currentAccount.account_id];
                
            }
                break;
            case C_LOCK:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:lockCellIdentifier];
                if (!cell || ![cell isKindOfClass:[CEditLockItemView class]])
                {
                    cell = [[CEditLockItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:lockCellIdentifier];
                }
            }
                break;
#if !NEW_DESIGN
            case C_REPlYS:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:knoteCellIdentifier];
                if (!cell || ![cell isKindOfClass:[CEditReplysItemView class]])
                {
                    cell = [[CEditReplysItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:knoteCellIdentifier];
                }
            }
                break;
            case C_NEW_COMMENT:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:newCommentCellIdentifier];
                if (!cell || ![cell isKindOfClass:[CNewCommentItemView class]])
                {
                    cell = [[CNewCommentItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:newCommentCellIdentifier];
                    [cell performSelector:@selector(setParentTableView:) withObject:self.tableView];
                } else {
                    [cell performSelector:@selector(reset)];
                }
            }
                break;
#endif
            default:
            {
                cell = [tableView dequeueReusableCellWithIdentifier:knoteCellIdentifier];
                
                if (!cell || ![cell isKindOfClass:[CEditKnoteItemView class]])
                {
                    cell = [[CEditKnoteItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:knoteCellIdentifier];
                }
                
                ((CEditKnoteItemView*)cell).baseItemDelegate = self;
            }
                break;
        }
        
        c = (CEditBaseItemView *)cell;
        
        if (item.expandedMode)
        {
            [c.showMoreButton setTitle:@"Less" forState:UIControlStateNormal];
        }
        else
        {
            [c.showMoreButton setTitle:@"More" forState:UIControlStateNormal];
        }
        
        //c.showsReorderControl = YES;
        
        if ([tableView indexPathIsMovingIndexPath:indexPath])
        {
            [c prepareForMove];
        }
        else
        {
            if (tableView.movingIndexPath != nil)
            {
                indexPath = [tableView adaptedIndexPathForRowAtIndexPath:indexPath];
            }
            
            c.baseItemDelegate = self;
            
            [c setItemData:item];
            
            c.index = indexPath.row;
            c.titleInfoBar.delegate = self;
            c.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        c.indexpath =indexPath;
        
        [c bringSubviewToFront:c.pinButton ];
        [c bringSubviewToFront:c.commentButton];
        
        if (item.isReplysExpand)
        {
            [c.commentButton setSelected:YES];
        }
        else
        {
            [c.commentButton setSelected:NO];
        }
        
        [c setCommentButtonImage];
        
        
        /********************************************************
         
         Function : Only delete own comments
         
         ********************************************************/
        
#if !NEW_DESIGN
        if (item.type == C_REPlYS)
        {
            if ([((CReplysItem*)item).content objectForKey:@"from"])
            {
                NSString*   replyerEmail = [((CReplysItem*)item).content objectForKey:@"from"];
                
                DLog(@"Replyer : %@", replyerEmail);
                
                DLog(@"Current User : %@", [DataManager sharedInstance].currentAccount.user);
                
                if ([replyerEmail isEqualToString:[DataManager sharedInstance].currentAccount.user.email])
                {
                    [c.doneButton setTag:indexPath.row+1];
                    UITapGestureRecognizer *doneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteKnote:)];
                    [doneTap setNumberOfTapsRequired:1];
                    [c.doneButton setUserInteractionEnabled:YES];
                    [c.doneButton addGestureRecognizer:doneTap];
                    // [self configureKnoteCell:c forRowAtIndexPath:indexPath editable:NO deletable:YES];
                }
            }
        }
        else
#endif
        {
            
            [c.doneButton setTag:indexPath.item+1];
            UITapGestureRecognizer *doneTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteKnote:)];
            [doneTap setNumberOfTapsRequired:1];
            [c.doneButton setUserInteractionEnabled:YES];
            [c.doneButton addGestureRecognizer:doneTap];
            
            [c.editButton setTag:indexPath.item+1];
            UITapGestureRecognizer *editTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editKnote:)];
            [editTap setNumberOfTapsRequired:1];
            [c.editButton setUserInteractionEnabled:YES];
            [c.editButton addGestureRecognizer:editTap];
            
            [c.bookMarkButon setTag:indexPath.item+1];
            UITapGestureRecognizer *bookMarkTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bookMarkKnote:)];
            [bookMarkTap setNumberOfTapsRequired:1];
            [c.bookMarkButon setUserInteractionEnabled:YES];
            [c.bookMarkButon addGestureRecognizer:bookMarkTap];
        }
    }
    
    c.backgroundColor = [UIColor whiteColor];
    
    if (![c.settingsView isHidden]) {
        [c showHideSettingsView];
    }
    
    return c;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"didSelectRowAtIndexPath %@", indexPath);
    
    if ([tableView isEqual:self.tableView]) {
        CItem* item = self.currentData[indexPath.row];
        
        UIView* cell = (UIView *)item.cell;
        
        if (cell && [cell isKindOfClass:[PictureCell class]])
        {
            PictureCell *picturecell = (PictureCell *)cell;
            [self wantFullLayout:picturecell.knoteImageView];
        }
        else if (cell && [cell isKindOfClass:[PostPicturesCell class]])
        {
            NSLog(@"----------PostPicturesCell");
        }
        else if (cell && [cell isKindOfClass:[CEditKnoteItemView class]])
        {
            NSLog(@"----------CEditKnoteItemView");
        }
#if !NEW_DESIGN
        else if (cell && [cell isKindOfClass:[CEditReplysItemView class]])
        {
            NSLog(@"----------CEditReplysItemView");
        }
#endif
        else
        {
            NSArray * itemFiles = [item getFileEntitiesFromSelfMessage];
            if([itemFiles count] > 0){
                NSString * fullPath = [(FileEntity *)[itemFiles objectAtIndex:0] filePath];
                NSURL *resourceToOpen = [NSURL fileURLWithPath:fullPath];
                
                self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:resourceToOpen];
                self.documentInteractionController.delegate = self;
                [self.documentInteractionController presentOpenInMenuFromRect:self.navigationController.navigationBar.frame inView:self.view animated:YES];
                
            }
        }
        
        [self tapedCell:(CEditBaseItemView*)cell];
        [self.tableView endEditing:YES];
    }else{
        CItem* item = self.rightData[indexPath.row];
        
        UIView* cell = (UIView *)item.cell;
        
        if (cell && [cell isKindOfClass:[PictureCell class]])
        {
            PictureCell *picturecell = (PictureCell *)cell;
            [self wantFullLayout:picturecell.knoteImageView];
        }
        else if (cell && [cell isKindOfClass:[PostPicturesCell class]])
        {
            NSLog(@"----------PostPicturesCell");
        }
        else if (cell && [cell isKindOfClass:[CEditKnoteItemView class]])
        {
            NSLog(@"----------CEditKnoteItemView");
        }
#if !NEW_DESIGN
        else if (cell && [cell isKindOfClass:[CEditReplysItemView class]])
        {
            NSLog(@"----------CEditReplysItemView");
        }
#endif
        else
        {
            NSArray * itemFiles = [item getFileEntitiesFromSelfMessage];
            if([itemFiles count] > 0){
                NSString * fullPath = [(FileEntity *)[itemFiles objectAtIndex:0] filePath];
                NSURL *resourceToOpen = [NSURL fileURLWithPath:fullPath];
                
                self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:resourceToOpen];
                self.documentInteractionController.delegate = self;
                [self.documentInteractionController presentOpenInMenuFromRect:self.navigationController.navigationBar.frame inView:self.view animated:YES];
                
            }
        }
        
        [self tapedCell:(CEditBaseItemView*)cell];
        [self.tableViewRight endEditing:YES];
    }
    
    
}

-(void)tapedCell:(CEditBaseItemView *)cell
{
    if ([_instanceTxtReply becomeFirstResponder])
    {
        [_instanceTxtReply resignFirstResponder];
    }
#if NEW_FEATURE
    
    if (!self.isUpdationOver)
    {
        return;
    }
    
    
    NSIndexPath *indexPath = Nil;
    
    if (self.tableView.frame.origin.x == 0) {
        if (cell == Nil)
        {
            if (self.expandIndex)
            {
                indexPath = self.expandIndex;
            }
        }
        else
        {
            indexPath = [self.tableView indexPathForCell:cell];
        }
        
        if (indexPath)
        {
            CItem* item = self.currentData[indexPath.row];
            // Lin - Added to manage comment cell and items
            
            self.focusedCommentCell = Nil;
            self.focusedCommentItem = Nil;
            
            self.focusedCommentCell = cell;
            self.focusedCommentItem = item;
            
            // Lin - Ended
            
            item.userData.expanded = !item.userData.expanded;
            
#if !NEW_DESIGN
            if (self && [self respondsToSelector:@selector(toggleCommentsListInCell:withContent:)]) {
                [self toggleCommentsListInCell:cell withContent:item];
            }
#endif
            
            if (indexPath.row<self.currentData.count)
            {
                self.expandIndex = indexPath;
//                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                return;
            }
            //[self.tableView reloadData];
            
            CGPoint point = self.tableView.contentOffset;
            CGSize size = self.tableView.bounds.size;
            size = CGSizeMake(size.width, size.height-40);
            
            CGRect rect = [self.tableView rectForRowAtIndexPath:self.expandIndex];
            
            if (rect.origin.y<point.y || rect.size.height>size.height)
            {
                [self performSelector:@selector(adjustExpandPicCell:) withObject:@(UITableViewScrollPositionTop) afterDelay:0.1];
            }
            else if ((rect.origin.y+rect.size.height)>(point.y+size.height))
            {
                [self performSelector:@selector(adjustExpandPicCell:) withObject:@(UITableViewScrollPositionBottom) afterDelay:0.1];
            }
        }
        
    }else{
        if (cell == Nil)
        {
            if (self.expandIndex)
            {
                indexPath = self.expandIndex;
            }
        }
        else
        {
            indexPath = [self.tableViewRight indexPathForCell:cell];
        }
        
        if (indexPath)
        {
            CItem* item = self.rightData[indexPath.row];
            // Lin - Added to manage comment cell and items
            
            self.focusedCommentCell = Nil;
            self.focusedCommentItem = Nil;
            
            self.focusedCommentCell = cell;
            self.focusedCommentItem = item;
            
            // Lin - Ended
            
            item.userData.expanded = !item.userData.expanded;
            
#if !NEW_DESIGN
            if (self && [self respondsToSelector:@selector(toggleCommentsListInCell:withContent:)]) {
                [self toggleCommentsListInCell:cell withContent:item];
            }
#endif
            
            if (indexPath.row<self.rightData.count)
            {
                self.expandIndex = indexPath;
                [self.tableViewRight reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            else
            {
                return;
            }
            //[self.tableView reloadData];
            
            CGPoint point = self.tableViewRight.contentOffset;
            CGSize size = self.tableViewRight.bounds.size;
            size = CGSizeMake(size.width, size.height-40);
            
            CGRect rect = [self.tableViewRight rectForRowAtIndexPath:self.expandIndex];
            
            if (rect.origin.y<point.y || rect.size.height>size.height)
            {
                [self performSelector:@selector(adjustExpandPicCell:) withObject:@(UITableViewScrollPositionTop) afterDelay:0.1];
            }
            else if ((rect.origin.y+rect.size.height)>(point.y+size.height))
            {
                [self performSelector:@selector(adjustExpandPicCell:) withObject:@(UITableViewScrollPositionBottom) afterDelay:0.1];
            }
        }
    }
    
#endif
    
}

- (void) recoveyKnote:(CEditBaseItemView *)cell
{
    [self updateArchivedNum];
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSLog(@"from: %@ to: %@", fromIndexPath, toIndexPath);
    //NSLog(@"data before: %@", self.currentData);
    CItem *moving = [self.currentData objectAtIndex:fromIndexPath.row];
    int offset = toIndexPath.row > fromIndexPath.row ? -1 : 0;
    [self.currentData removeObjectAtIndex:fromIndexPath.row];
    [self.currentData insertObject:moving atIndex:toIndexPath.row + offset];
    //NSLog(@"data after: %@", self.currentData);
    
}

- (void)moveTableView:(RichTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSArray *movie = [self.currentData objectAtIndex:fromIndexPath.row];
    [self.currentData removeObjectAtIndex:fromIndexPath.row];
    [self.currentData insertObject:movie atIndex:toIndexPath.row];
}

- (void)swipeNeedShowMenu:(BOOL)show atIndexPath:indexPath cell:(UITableViewCell *)cell;
{
    //    [self setEditing:show atIndexPath:indexPath cell:cell animate:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (void)GMTableViewCell:(UITableViewCell *)cell changedEdit:(BOOL)edit
{
    DLog(@"GMTableViewCell changedEdit: %d", edit);
    
    
    CEditBaseItemView *c = (CEditBaseItemView *)cell;
    
    if (edit) {
        
        ComposeThreadViewController *vc = [[ComposeThreadViewController alloc] initWithItem:[c getItemData]];
        vc.subject = self.mainTitle;
        vc.topic_id = self.tInfo.entity.topic_id;
        vc.topic_type = self.tInfo.entity.topic_type;
        vc.opType = ItemModify;
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    }
}
- (void)CEditItemViewCell:(UITableViewCell *)cell changedLike:(BOOL)edit
{
    NSIndexPath *indexpath = [self.tableView indexPathForCell:cell];
    [self doubleTapAtIndexPath:indexpath cell:cell];
}

- (void)doubleTapAtIndexPath:indexPath cell:(UITableViewCell *)cell
{
    if ([ThreadItemManager sharedInstance].offline) {
        return;
    }
    
    if ([cell isKindOfClass:[CEditBaseItemView class]]) {
        CEditBaseItemView *c = (CEditBaseItemView *)cell;
        CItem *item = [c getItemData];
        
        [item checkToLike];
        
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CItem* item = self.currentData[indexPath.row];
    if ([item isKindOfClass:[CKeyNoteItem class]] ||
        [item isKindOfClass:[CLockItem class]] ||
        [item isKindOfClass:[CPictureItem class]]){
        return NO;
    }
    return YES;
    
}
- (BOOL)moveTableView:(RichTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@".");
    return YES;
}
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([MenuView sharedInstance].isShowing == YES) {
        [self contextMenuDidHideInCell:nil];
    }
}

#pragma mark - Swipable Cell Function

- (UIView *)viewWithImageName:(NSString *)imageName
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.contentMode = UIViewContentModeCenter;
    
    return imageView;
}

- (void)reload:(id)sender
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    });
}

- (void)archiveKnote:(MCSwipeTableViewCell *)cell
{
    NSParameterAssert(cell);
    
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    [cell swipeToOriginWithCompletion:^{
        NSLog(@"Swiped back");
    }];
    
    cell = nil;
    
    [self.currentData removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [self ReoadLocalKnotes];
        
    });
}

-(void)updateArchivedNum
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSInteger archivedNum = 0;
        
        if (self.tInfo.entity.topic_id)
        {
            NSMutableString *predicateString = [@"topic_id = %@" mutableCopy];
            
            NSMutableArray *arguments = [[NSMutableArray alloc] initWithObjects:[self.tInfo.entity.topic_id noPrefix:kKnoteIdPrefix], nil];
            
            [predicateString appendString :@" AND archived = YES"];
            
            NSArray *archivedArray = [MessageEntity MR_findAllWithPredicate:[NSPredicate predicateWithFormat:predicateString
                                                                                               argumentArray:arguments]];
            
            archivedNum = archivedArray.count;
        }
        
        self.headerInfoView.num = archivedNum;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.headerInfoView flashButton];
            
        });
    });
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    [self.animalLayer removeFromSuperlayer];
    [self updateArchivedNum];
    //    [self.tableView setContentOffset:CGPointZero animated:YES];
    
}

- (void)configureKnoteCell:(MCSwipeTableViewCell *)cell
         forRowAtIndexPath:(NSIndexPath *)indexPath
                  editable:(BOOL)canEdit
                 deletable:(BOOL)canDelete

{
    /********************************************************
     
     Function : Configure Knote Cell
     
     ********************************************************/
    
    UIView *knote_EditImgView = [self viewWithImageName:@"knote_edit"];
    UIView *knote_DoneImgView = [self viewWithImageName:@"knote_done"];
    
    UIColor *knote_EditColor = [UIColor colorWithRed:214.0 / 255.0 green:214.0 / 255.0 blue:214.0 / 255.0 alpha:1.0];
    UIColor *knote_DoneColor = [UIColor colorWithRed:56.0 / 255.0 green:209.0 / 255.0 blue:66.0 / 255.0 alpha:1.0];
    
    
    CEditBaseItemView *c = (CEditBaseItemView *)cell;
    CItem *itemForcheck = [c getItemData];
    _archivedCell=cell;
    NSLog(@"--->indexpath %ld",(long)_archivedIndexPath.row);
    [cell setDefaultColor:[DesignManager KnoteReleaseBackgroudColor]];
    
    // Set the first and second action trigger
    
    [cell setFirstTrigger:0.15f];
    //    [cell setSecondTrigger:0.85f];
    
    if (itemForcheck.userData.currently_contact_edit.length>0)
    {
        [cell setDelegate:self];
        [cell setSwipeGestureWithView:knote_EditImgView
                                color:knote_EditColor
                                 mode:MCSwipeTableViewCellModeNone
                                state:MCSwipeTableViewCellStateNone completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
         {
             NSLog(@"Did swipe \"Checkmark\" cell");
         }];
    }
    else
    {
        [self performSelector:@selector(contextMenuDidHideInCell:) withObject:cell afterDelay:0.5];
        
        /*if ([ThreadItemManager sharedInstance].offline)
         {
         return;
         }*/
        
        [cell setDelegate:self];
        
        // Right -> Left : Delete Knote
        
        if (canDelete)
        {
            // State 1 for delete action
            
            [cell setSwipeGestureWithView:knote_DoneImgView
                                    color:knote_DoneColor
                                     mode:MCSwipeTableViewCellModeSwitch
                                    state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
             {
                 NSLog(@"Did swipe \"Checkmark\" cell");
             }];
            
            // State 2 for delete action
            
            [cell setSwipeGestureWithView:knote_DoneImgView
                                    color:knote_DoneColor
                                     mode:MCSwipeTableViewCellModeExit
                                    state:MCSwipeTableViewCellState4
                          completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
             {
                 NSLog(@"Did swipe \"Cross\" cell");
                 
                 // Will Archive current knote if ShowArchive is On then it will update Cell otherwise it will remove.
                 
                 CItem *item = [c getItemData];
                 
                 [item checkToDelete];
                 
                 NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
                 _archivedIndexPath=indexPath;
                 
                 if (!indexPath || indexPath.row >= self.currentData .count)
                 {
                     return;
                 }
                 if (_showArchived && !item.archived)
                 {
                     [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                     [self updateArchivedNum];
                 }
                 else
                 {
                     UIImageView *imageView=[[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor blueColor]]];
                     imageView.contentMode=UIViewContentModeScaleToFill;
                     imageView.frame=CGRectMake(0, 0, 20, 20);
                     imageView.hidden=YES;
                     CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
                     CGPoint point= CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);
                     imageView.center=point;
                     CALayer *layer=[[CALayer alloc]init];
                     layer.contents=imageView.layer.contents;
                     layer.frame=imageView.frame;
                     layer.opacity=1;
                     [[UIApplication sharedApplication].keyWindow.layer addSublayer:layer];
                     self.animalLayer = layer;
                     
                     CGPoint point1=self.headerInfoView.deleteButton.center;
                     point1.x-=15;
                     CGPoint endpoint=[[UIApplication sharedApplication].keyWindow convertPoint:point1 fromView:self.headerInfoView.deleteButton];
                     UIBezierPath *path=[UIBezierPath bezierPath];
                     
                     CGPoint startPoint=[[UIApplication sharedApplication].keyWindow convertPoint:point fromView:self.tableView];
                     [path moveToPoint:startPoint];
                     
                     float sx=startPoint.x;
                     float sy=startPoint.y;
                     float ex=endpoint.x;
                     float ey=endpoint.y;
                     float x=sx+(ex-sx)/3;
                     float y=sy+(ey-sy)*0.5-200;
                     CGPoint centerPoint=CGPointMake(x,y);
                     [path addQuadCurveToPoint:endpoint controlPoint:centerPoint];
                     
                     CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
                     animation.path = path.CGPath;
                     animation.removedOnCompletion = NO;
                     animation.fillMode = kCAFillModeForwards;
                     animation.duration=0.8;
                     animation.delegate=self;
                     animation.autoreverses= NO;
                     animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                     [layer addAnimation:animation forKey:@"buy"];
                     
                     // UI Update
                     
                     /********************************************************
                      
                      There are two methods to archive reload function here.
                      
                      1. After UI delete here, reload tableview with current data
                      2. After UI delete, try to update server and reload tableview
                      with server data.
                      
                      To archive user experience, we need to choose first method.
                      
                      So we will not fire OperatorThreadItemNotification notification
                      after delete knote/comment from knote list.
                      
                      ********************************************************/
                     
                     DLog(@"----------------- Check point !!!! -----------------");
                     
                     DLog(@"Delete Cell Info : %d ", (int)indexPath.row);
                     
                     if ([self.currentData count] > 0)
                     {
                         if (_showArchived)
                         {
                             @try {
                                 [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                             }
                             @catch (NSException *exception) {
                                 [self.tableView reloadData];
                             }
                             @finally {
                                 [self updateArchivedNum];
                             }
                         }
                         else
                         {
                             @try {
                                 [self.currentData removeObjectAtIndex:indexPath.row];
                                 [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                             }
                             @catch (NSException *exception) {
                                 [self.tableView reloadData];
                             }
                             @finally {
                             }
                         }
                     }
                     else
                     {
                         [[NSNotificationCenter defaultCenter] postNotificationName:OperatorThreadItemNotification
                                                                             object:self];
                     }
                 }
             }];
        }
        
        // Left -> Right : Edit Knote
        
        if (canEdit)
        {
            // State 1 for edit action
            
            [cell setSwipeGestureWithView:knote_EditImgView
                                    color:knote_EditColor
                                     mode:MCSwipeTableViewCellModeSwitch
                                    state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
             {
                 NSLog(@"Did swipe \"Checkmark\" cell");
             }];
            
            // State 2 for edit action
            
            [cell setSwipeGestureWithView:knote_EditImgView
                                    color:knote_EditColor
                                     mode:MCSwipeTableViewCellModeExit
                                    state:MCSwipeTableViewCellState2
                          completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
             {
                 NSLog(@"Did swipe \"Cross\" cell");
                 
                 // Will edit current knote
                 
                 [self reload:Nil];
                 
                 CItem *item = [c getItemData];
                 
                 [self UpdateCurrentEdting:item];
                 
                 [self startedEditingWith:(CEditBaseItemView *)cell];
                 
             }];
        }
    }
}

//tmd *Older GestureRecognizer route of deleting
- (void)deleteKnote:(UITapGestureRecognizer *)sender{
    
    UIButton *button = (UIButton *)sender.view;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag -1 inSection:0];
    
    if (self.tableView.frame.origin.x == 0) {
        CEditBaseItemView *cell = (CEditBaseItemView *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        _archivedCell=cell;
        
        CItem *item = [cell getItemData];
        //NSLog(@"tmd: (x!=0) Title: %@", cell.titleName.text);

        [item checkToDelete];
        
        
        _archivedIndexPath=indexPath;
        
        if (!indexPath || indexPath.row >= self.currentData .count)
        {
            return;
        }
        if (_showArchived && !item.archived)
        {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self updateArchivedNum];
        }
        else
        {
            UIImageView *imageView=[[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor blueColor]]];
            imageView.contentMode=UIViewContentModeScaleToFill;
            imageView.frame=CGRectMake(0, 0, 20, 20);
            imageView.hidden=YES;
            CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
            CGPoint point= CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);
            imageView.center=point;
            CALayer *layer=[[CALayer alloc]init];
            layer.contents=imageView.layer.contents;
            layer.frame=imageView.frame;
            layer.opacity=1;
            [[UIApplication sharedApplication].keyWindow.layer addSublayer:layer];
            self.animalLayer = layer;
            
            CGPoint point1=self.headerInfoView.deleteButton.center;
            point1.x-=15;
            CGPoint endpoint=[[UIApplication sharedApplication].keyWindow convertPoint:point1 fromView:self.headerInfoView.deleteButton];
            UIBezierPath *path=[UIBezierPath bezierPath];
            
            CGPoint startPoint=[[UIApplication sharedApplication].keyWindow convertPoint:point fromView:self.tableView];
            [path moveToPoint:startPoint];
            
            float sx=startPoint.x;
            float sy=startPoint.y;
            float ex=endpoint.x;
            float ey=endpoint.y;
            float x=sx+(ex-sx)/3;
            float y=sy+(ey-sy)*0.5-200;
            CGPoint centerPoint=CGPointMake(x,y);
            [path addQuadCurveToPoint:endpoint controlPoint:centerPoint];
            
            CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
            animation.path = path.CGPath;
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeForwards;
            animation.duration=0.8;
            animation.delegate=self;
            animation.autoreverses= NO;
            animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            [layer addAnimation:animation forKey:@"buy"];
            
            // UI Update
            
            /********************************************************
             
             There are two methods to archive reload function here.
             
             1. After UI delete here, reload tableview with current data
             2. After UI delete, try to update server and reload tableview
             with server data.
             
             To archive user experience, we need to choose first method.
             
             So we will not fire OperatorThreadItemNotification notification
             after delete knote/comment from knote list.
             
             ********************************************************/
            
            DLog(@"----------------- Check point !!!! -----------------");
            
            DLog(@"Delete Cell Info : %d ", (int)indexPath.row);
            
            if ([self.currentData count] > 0)
            {
                if (_showArchived)
                {
                    @try {
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    @catch (NSException *exception) {
                        [self.tableView reloadData];
                    }
                    @finally {
                        [self updateArchivedNum];
                    }
                }
                else
                {
                    @try {
                        [self.currentData removeObjectAtIndex:indexPath.row];
                        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    }
                    @catch (NSException *exception) {
                        [self.tableView reloadData];
                    }
                    @finally {
                    }
                }
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:OperatorThreadItemNotification
                                                                    object:self];
            }
        }
        
    }
    
    else{
        CEditBaseItemView *cell = (CEditBaseItemView *)[self.tableViewRight cellForRowAtIndexPath:indexPath];
        
        _archivedCell=cell;
        
        CItem *item = [cell getItemData];
        
        
        [item checkToDelete];
        
        
        _archivedIndexPath=indexPath;
        
        if (!indexPath || indexPath.row >= self.rightData .count)
        {
            return;
        }
        if (_showArchived && !item.archived)
        {
            [self.tableViewRight reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self updateArchivedNum];
        }
        else
        {
            UIImageView *imageView=[[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor blueColor]]];
            imageView.contentMode=UIViewContentModeScaleToFill;
            imageView.frame=CGRectMake(0, 0, 20, 20);
            imageView.hidden=YES;
            CGRect rect = [self.tableViewRight rectForRowAtIndexPath:indexPath];
            CGPoint point= CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);
            imageView.center=point;
            CALayer *layer=[[CALayer alloc]init];
            layer.contents=imageView.layer.contents;
            layer.frame=imageView.frame;
            layer.opacity=1;
            [[UIApplication sharedApplication].keyWindow.layer addSublayer:layer];
            self.animalLayer = layer;
            
            CGPoint point1=self.headerInfoView.deleteButton.center;
            point1.x-=15;
            CGPoint endpoint=[[UIApplication sharedApplication].keyWindow convertPoint:point1 fromView:self.headerInfoView.deleteButton];
            UIBezierPath *path=[UIBezierPath bezierPath];
            
            CGPoint startPoint=[[UIApplication sharedApplication].keyWindow convertPoint:point fromView:self.tableViewRight];
            [path moveToPoint:startPoint];
            
            float sx=startPoint.x;
            float sy=startPoint.y;
            float ex=endpoint.x;
            float ey=endpoint.y;
            float x=sx+(ex-sx)/3;
            float y=sy+(ey-sy)*0.5-200;
            CGPoint centerPoint=CGPointMake(x,y);
            [path addQuadCurveToPoint:endpoint controlPoint:centerPoint];
            
            CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
            animation.path = path.CGPath;
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeForwards;
            animation.duration=0.8;
            animation.delegate=self;
            animation.autoreverses= NO;
            animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            [layer addAnimation:animation forKey:@"buy"];
            
            // UI Update
            
            /********************************************************
             
             There are two methods to archive reload function here.
             
             1. After UI delete here, reload tableview with current data
             2. After UI delete, try to update server and reload tableview
             with server data.
             
             To archive user experience, we need to choose first method.
             
             So we will not fire OperatorThreadItemNotification notification
             after delete knote/comment from knote list.
             
             ********************************************************/
            
            DLog(@"----------------- Check point !!!! -----------------");
            
            DLog(@"Delete Cell Info : %d ", (int)indexPath.row);
            
            if ([self.rightData count] > 0)
            {
                [self.firstDot setHidden:NO];
                [self.secondDot setHidden:NO];
                if (_showArchived)
                {
                    @try {
                        [self.rightData removeObjectAtIndex:indexPath.row];
                        [self.tableViewRight reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    @catch (NSException *exception) {
                        [self.tableViewRight reloadData];
                    }
                    @finally {
                        [self updateArchivedNum];
                        if (self.rightData.count == 0) {
                            [self performSelector:@selector(handleSwipeRight:) withObject:nil];
                        }
                    }
                }
                else
                {
                    @try {
                        [self.rightData removeObjectAtIndex:indexPath.row];
                        [self.tableViewRight deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    }
                    @catch (NSException *exception) {
                        [self.tableViewRight reloadData];
                    }
                    @finally {
                        if (self.rightData.count == 0) {
                            [self performSelector:@selector(handleSwipeRight:) withObject:nil];
                        }
                    }
                }
            }
            else
            {
                [self.firstDot setHidden:YES];
                [self.secondDot setHidden:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:OperatorThreadItemNotification
                                                                    object:self];
                [self performSelector:@selector(handleSwipeRight:) withObject:nil];
            }
        }
        
    }
}


//tmd *New Action method of deleting, more accurately finds nsindexpath of cell being deleted
-(void)deleteKnoteButtonTapped:(UIButton*)button withEvent:(UIEvent*)event {
    UITouch *touch = [[event touchesForView:button] anyObject];
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint: [touch locationInView: self.tableView]];
    
    if (self.tableView.frame.origin.x == 0) {
        CEditBaseItemView *cell = (CEditBaseItemView *)[self.tableView cellForRowAtIndexPath:indexPath];
        
        _archivedCell=cell;
        
        CItem *item = [cell getItemData];

        [item checkToDelete];
        
        
        _archivedIndexPath=indexPath;
        
        if (!indexPath || indexPath.row >= self.currentData .count)
        {
            return;
        }
        if (_showArchived && !item.archived)
        {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self updateArchivedNum];
        }
        else
        {
            UIImageView *imageView=[[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor blueColor]]];
            imageView.contentMode=UIViewContentModeScaleToFill;
            imageView.frame=CGRectMake(0, 0, 20, 20);
            imageView.hidden=YES;
            CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
            CGPoint point= CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);
            imageView.center=point;
            CALayer *layer=[[CALayer alloc]init];
            layer.contents=imageView.layer.contents;
            layer.frame=imageView.frame;
            layer.opacity=1;
            [[UIApplication sharedApplication].keyWindow.layer addSublayer:layer];
            self.animalLayer = layer;
            
            CGPoint point1=self.headerInfoView.deleteButton.center;
            point1.x-=15;
            CGPoint endpoint=[[UIApplication sharedApplication].keyWindow convertPoint:point1 fromView:self.headerInfoView.deleteButton];
            UIBezierPath *path=[UIBezierPath bezierPath];
            
            CGPoint startPoint=[[UIApplication sharedApplication].keyWindow convertPoint:point fromView:self.tableView];
            [path moveToPoint:startPoint];
            
            float sx=startPoint.x;
            float sy=startPoint.y;
            float ex=endpoint.x;
            float ey=endpoint.y;
            float x=sx+(ex-sx)/3;
            float y=sy+(ey-sy)*0.5-200;
            CGPoint centerPoint=CGPointMake(x,y);
            [path addQuadCurveToPoint:endpoint controlPoint:centerPoint];
            
            CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
            animation.path = path.CGPath;
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeForwards;
            animation.duration=0.8;
            animation.delegate=self;
            animation.autoreverses= NO;
            animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            [layer addAnimation:animation forKey:@"buy"];
            
            // UI Update
            
            /********************************************************
             
             There are two methods to archive reload function here.
             
             1. After UI delete here, reload tableview with current data
             2. After UI delete, try to update server and reload tableview
             with server data.
             
             To archive user experience, we need to choose first method.
             
             So we will not fire OperatorThreadItemNotification notification
             after delete knote/comment from knote list.
             
             ********************************************************/
            
            DLog(@"----------------- Check point !!!! -----------------");
            
            DLog(@"Delete Cell Info : %d ", (int)indexPath.row);
            
            if ([self.currentData count] > 0)
            {
                if (_showArchived)
                {
                    @try {
                        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    @catch (NSException *exception) {
                        [self.tableView reloadData];
                    }
                    @finally {
                        [self updateArchivedNum];
                    }
                }
                else
                {
                    @try {
                        [self.currentData removeObjectAtIndex:indexPath.row];
                        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    }
                    @catch (NSException *exception) {
                        [self.tableView reloadData];
                    }
                    @finally {
                    }
                }
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:OperatorThreadItemNotification
                                                                    object:self];
            }
        }
        
    }
    
    else{
        CEditBaseItemView *cell = (CEditBaseItemView *)[self.tableViewRight cellForRowAtIndexPath:indexPath];
        
        _archivedCell=cell;
        
        CItem *item = [cell getItemData];
        
        
        [item checkToDelete];
        
        
        _archivedIndexPath=indexPath;
        
        if (!indexPath || indexPath.row >= self.rightData .count)
        {
            return;
        }
        if (_showArchived && !item.archived)
        {
            [self.tableViewRight reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            [self updateArchivedNum];
        }
        else
        {
            UIImageView *imageView=[[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor blueColor]]];
            imageView.contentMode=UIViewContentModeScaleToFill;
            imageView.frame=CGRectMake(0, 0, 20, 20);
            imageView.hidden=YES;
            CGRect rect = [self.tableViewRight rectForRowAtIndexPath:indexPath];
            CGPoint point= CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);
            imageView.center=point;
            CALayer *layer=[[CALayer alloc]init];
            layer.contents=imageView.layer.contents;
            layer.frame=imageView.frame;
            layer.opacity=1;
            [[UIApplication sharedApplication].keyWindow.layer addSublayer:layer];
            self.animalLayer = layer;
            
            CGPoint point1=self.headerInfoView.deleteButton.center;
            point1.x-=15;
            CGPoint endpoint=[[UIApplication sharedApplication].keyWindow convertPoint:point1 fromView:self.headerInfoView.deleteButton];
            UIBezierPath *path=[UIBezierPath bezierPath];
            
            CGPoint startPoint=[[UIApplication sharedApplication].keyWindow convertPoint:point fromView:self.tableViewRight];
            [path moveToPoint:startPoint];
            
            float sx=startPoint.x;
            float sy=startPoint.y;
            float ex=endpoint.x;
            float ey=endpoint.y;
            float x=sx+(ex-sx)/3;
            float y=sy+(ey-sy)*0.5-200;
            CGPoint centerPoint=CGPointMake(x,y);
            [path addQuadCurveToPoint:endpoint controlPoint:centerPoint];
            
            CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
            animation.path = path.CGPath;
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeForwards;
            animation.duration=0.8;
            animation.delegate=self;
            animation.autoreverses= NO;
            animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
            [layer addAnimation:animation forKey:@"buy"];
            
            // UI Update
            
            /********************************************************
             
             There are two methods to archive reload function here.
             
             1. After UI delete here, reload tableview with current data
             2. After UI delete, try to update server and reload tableview
             with server data.
             
             To archive user experience, we need to choose first method.
             
             So we will not fire OperatorThreadItemNotification notification
             after delete knote/comment from knote list.
             
             ********************************************************/
            
            DLog(@"----------------- Check point !!!! -----------------");
            
            DLog(@"Delete Cell Info : %d ", (int)indexPath.row);
            
            if ([self.rightData count] > 0)
            {
                [self.firstDot setHidden:NO];
                [self.secondDot setHidden:NO];
                if (_showArchived)
                {
                    @try {
                        [self.rightData removeObjectAtIndex:indexPath.row];
                        [self.tableViewRight reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                    }
                    @catch (NSException *exception) {
                        [self.tableViewRight reloadData];
                    }
                    @finally {
                        [self updateArchivedNum];
                        if (self.rightData.count == 0) {
                            [self performSelector:@selector(handleSwipeRight:) withObject:nil];
                        }
                    }
                }
                else
                {
                    @try {
                        [self.rightData removeObjectAtIndex:indexPath.row];
                        [self.tableViewRight deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
                    }
                    @catch (NSException *exception) {
                        [self.tableViewRight reloadData];
                    }
                    @finally {
                        if (self.rightData.count == 0) {
                            [self performSelector:@selector(handleSwipeRight:) withObject:nil];
                        }
                    }
                }
            }
            else
            {
                [self.firstDot setHidden:YES];
                [self.secondDot setHidden:YES];
                [[NSNotificationCenter defaultCenter] postNotificationName:OperatorThreadItemNotification
                                                                    object:self];
                [self performSelector:@selector(handleSwipeRight:) withObject:nil];
            }
        }
        
    }
}



- (void)bookMarkKnote:(UITapGestureRecognizer *)sender
{
    NSLog(@"bookMarkKnote PRESSED Man.");
    
    UIButton* bookMarkButton = (UIButton*)sender.view;
}


- (void)editKnote:(UITapGestureRecognizer *)sender{
    
    UIButton *button = (UIButton *)sender.view;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag -1 inSection:0];
    
    CEditBaseItemView *cell;
    
    if (self.tableView.frame.origin.x == 0) {
        cell = (CEditBaseItemView *)[self.tableView cellForRowAtIndexPath:indexPath];
    }else{
        cell = (CEditBaseItemView *)[self.tableViewRight cellForRowAtIndexPath:indexPath];
    }
    
    //tmd
    [cell showHideSettingsView];
    
    [self reload:Nil];
    
    CItem *item = [cell getItemData];
    
    [self UpdateCurrentEdting:item];
    
    [self startedEditingWith:cell];
}

/*
 - (void)configureKnoteCell:(MCSwipeTableViewCell *)cell
 forRowAtIndexPath:(NSIndexPath *)indexPath
 editable:(BOOL)canEdit
 deletable:(BOOL)canDelete
 
 {
 ********************************************************
 
 Function : Configure Knote Cell
 
 ********************************************************
 
 UIView *knote_EditImgView = [self viewWithImageName:@"knote_edit"];
 UIView *knote_DoneImgView = [self viewWithImageName:@"knote_done"];
 
 UIColor *knote_EditColor = [UIColor colorWithRed:214.0 / 255.0 green:214.0 / 255.0 blue:214.0 / 255.0 alpha:1.0];
 UIColor *knote_DoneColor = [UIColor colorWithRed:56.0 / 255.0 green:209.0 / 255.0 blue:66.0 / 255.0 alpha:1.0];
 
 
 CEditBaseItemView *c = (CEditBaseItemView *)cell;
 CItem *itemForcheck = [c getItemData];
 _archivedCell=cell;
 NSLog(@"--->indexpath %ld",(long)_archivedIndexPath.row);
 [cell setDefaultColor:[DesignManager KnoteReleaseBackgroudColor]];
 
 // Set the first and second action trigger
 
 [cell setFirstTrigger:0.15f];
 //    [cell setSecondTrigger:0.85f];
 
 if (itemForcheck.userData.currently_contact_edit.length>0)
 {
 [cell setDelegate:self];
 [cell setSwipeGestureWithView:knote_EditImgView
 color:knote_EditColor
 mode:MCSwipeTableViewCellModeNone
 state:MCSwipeTableViewCellStateNone completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
 {
 NSLog(@"Did swipe \"Checkmark\" cell");
 }];
 }
 else
 {
 [self performSelector:@selector(contextMenuDidHideInCell:) withObject:cell afterDelay:0.5];
 
 /*if ([ThreadItemManager sharedInstance].offline)
 {
 return;
 }*
 
 [cell setDelegate:self];
 
 // Right -> Left : Delete Knote
 
 if (canDelete)
 {
 // State 1 for delete action
 
 [cell setSwipeGestureWithView:knote_DoneImgView
 color:knote_DoneColor
 mode:MCSwipeTableViewCellModeSwitch
 state:MCSwipeTableViewCellState3 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
 {
 NSLog(@"Did swipe \"Checkmark\" cell");
 }];
 
 // State 2 for delete action
 
 [cell setSwipeGestureWithView:knote_DoneImgView
 color:knote_DoneColor
 mode:MCSwipeTableViewCellModeExit
 state:MCSwipeTableViewCellState4
 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
 {
 NSLog(@"Did swipe \"Cross\" cell");
 
 // Will Archive current knote if ShowArchive is On then it will update Cell otherwise it will remove.
 
 CItem *item = [c getItemData];
 
 [item checkToDelete];
 
 NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
 _archivedIndexPath=indexPath;
 
 if (!indexPath || indexPath.row >= self.currentData .count)
 {
 return;
 }
 if (_showArchived && !item.archived)
 {
 [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
 [self updateArchivedNum];
 }
 else
 {
 UIImageView *imageView=[[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor blueColor]]];
 imageView.contentMode=UIViewContentModeScaleToFill;
 imageView.frame=CGRectMake(0, 0, 20, 20);
 imageView.hidden=YES;
 CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
 CGPoint point= CGPointMake(rect.origin.x+rect.size.width/2, rect.origin.y+rect.size.height/2);
 imageView.center=point;
 CALayer *layer=[[CALayer alloc]init];
 layer.contents=imageView.layer.contents;
 layer.frame=imageView.frame;
 layer.opacity=1;
 [[UIApplication sharedApplication].keyWindow.layer addSublayer:layer];
 self.animalLayer = layer;
 
 CGPoint point1=self.headerInfoView.deleteButton.center;
 point1.x-=15;
 CGPoint endpoint=[[UIApplication sharedApplication].keyWindow convertPoint:point1 fromView:self.headerInfoView.deleteButton];
 UIBezierPath *path=[UIBezierPath bezierPath];
 
 CGPoint startPoint=[[UIApplication sharedApplication].keyWindow convertPoint:point fromView:self.tableView];
 [path moveToPoint:startPoint];
 
 float sx=startPoint.x;
 float sy=startPoint.y;
 float ex=endpoint.x;
 float ey=endpoint.y;
 float x=sx+(ex-sx)/3;
 float y=sy+(ey-sy)*0.5-200;
 CGPoint centerPoint=CGPointMake(x,y);
 [path addQuadCurveToPoint:endpoint controlPoint:centerPoint];
 
 CAKeyframeAnimation *animation=[CAKeyframeAnimation animationWithKeyPath:@"position"];
 animation.path = path.CGPath;
 animation.removedOnCompletion = NO;
 animation.fillMode = kCAFillModeForwards;
 animation.duration=0.8;
 animation.delegate=self;
 animation.autoreverses= NO;
 animation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
 [layer addAnimation:animation forKey:@"buy"];
 
 // UI Update
 
 /********************************************************
 
 There are two methods to archive reload function here.
 
 1. After UI delete here, reload tableview with current data
 2. After UI delete, try to update server and reload tableview
 with server data.
 
 To archive user experience, we need to choose first method.
 
 So we will not fire OperatorThreadItemNotification notification
 after delete knote/comment from knote list.
 
 ********************************************************
 
 DLog(@"----------------- Check point !!!! -----------------");
 
 DLog(@"Delete Cell Info : %d ", (int)indexPath.row);
 
 if ([self.currentData count] > 0)
 {
 if (_showArchived)
 {
 @try {
 [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
 }
 @catch (NSException *exception) {
 [self.tableView reloadData];
 }
 @finally {
 [self updateArchivedNum];
 }
 }
 else
 {
 @try {
 [self.currentData removeObjectAtIndex:indexPath.row];
 [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
 }
 @catch (NSException *exception) {
 [self.tableView reloadData];
 }
 @finally {
 }
 }
 }
 else
 {
 [[NSNotificationCenter defaultCenter] postNotificationName:OperatorThreadItemNotification
 object:self];
 }
 }
 }];
 }
 
 // Left -> Right : Edit Knote
 
 if (canEdit)
 {
 // State 1 for edit action
 
 [cell setSwipeGestureWithView:knote_EditImgView
 color:knote_EditColor
 mode:MCSwipeTableViewCellModeSwitch
 state:MCSwipeTableViewCellState1 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
 {
 NSLog(@"Did swipe \"Checkmark\" cell");
 }];
 
 // State 2 for edit action
 
 [cell setSwipeGestureWithView:knote_EditImgView
 color:knote_EditColor
 mode:MCSwipeTableViewCellModeExit
 state:MCSwipeTableViewCellState2
 completionBlock:^(MCSwipeTableViewCell *cell, MCSwipeTableViewCellState state, MCSwipeTableViewCellMode mode)
 {
 NSLog(@"Did swipe \"Cross\" cell");
 
 // Will edit current knote
 
 [self reload:Nil];
 
 CItem *item = [c getItemData];
 
 [self UpdateCurrentEdting:item];
 
 [self startedEditingWith:(CEditBaseItemView *)cell];
 
 }];
 }
 }
 }*/



#pragma mark - MCSwipeTableViewCellDelegate

// When the user starts swiping the cell this method is called
- (void)swipeTableViewCellDidStartSwiping:(MCSwipeTableViewCell *)cell {
    // NSLog(@"Did start swiping the cell!");
}

// When the user ends swiping the cell this method is called
- (void)swipeTableViewCellDidEndSwiping:(MCSwipeTableViewCell *)cell {
    // NSLog(@"Did end swiping the cell!");
}

// When the user is dragging, this method is called and return the dragged percentage from the border
- (void)swipeTableViewCell:(MCSwipeTableViewCell *)cell didSwipeWithPercentage:(CGFloat)percentage {
    // NSLog(@"Did swipe with percentage : %f", percentage);
}

#pragma mark - Private

-(void)sortknotesByOrder
{
//    NSComparator compareDates = ^(CItem * item1, CItem * item2)
//    {
//        if (item1.userData.order > item2.userData.order)
//        {
//            return  NSOrderedDescending;
//        }
//        else
//        {
//            return  NSOrderedAscending;
//        }
//    };
//    
//    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:nil ascending:YES comparator:compareDates];
//    
//    [self.currentData sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
//    [self.rightData sortUsingDescriptors:[NSArray arrayWithObject:descriptor]];
    
    [self.currentData sortUsingSelector:@selector(compare:)];
    [self.rightData sortUsingSelector:@selector(compare:)];
    
    NSLog(@"on init with nib name bundle account");
}

- (void)hideMenuOptionsAnimated:(BOOL)animated
{
    //[self.cellDisplayingMenuOptions showMenuView:NO withAnimated:YES];
}
- (void)setCustomEditing:(BOOL)customEditing
{
    NSLog(@"setCustomEditing: %d", customEditing);
    
    if (_customEditing != customEditing) {
        _customEditing = customEditing;
        self.tableView.scrollEnabled = !customEditing;
        if (customEditing) {
            if (!self.overlayView) {
                self.overlayView = [[COverlayView alloc] initWithFrame:self.view.bounds];
                self.overlayView.backgroundColor = [UIColor clearColor];
                self.overlayView.delegate = self;
            }
            self.overlayView.frame = self.view.bounds;
            [self.view addSubview:self.overlayView];
        }
        else{
            [self.overlayView removeFromSuperview];
        }
    }
    
}
- (void)contextMenuDidHideInCell:(UITableViewCell *)cell
{
    [[MenuView sharedInstance] fadeOut:0. delegate:nil];
    [MenuView sharedInstance].isShowing = YES;
    
}

- (void)contextMenuDidShowInCell:(UITableViewCell *)cell
{
    NSLog(@".");
    CGFloat mHeight = 44;
    CGRect rect = cell.frame;
    
    rect.origin.y += (rect.size.height - mHeight) / 2.0;
    rect.size.height = mHeight;
    
    UIView *view = [MenuView sharedInstance];
    view.hidden = NO;
    [MenuView sharedInstance].cell = cell;
    [MenuView sharedInstance].delegate = self;
    [MenuView sharedInstance].isShowing = YES;
    [view setFrame:rect];
    
    view.alpha = 0.0;
    
    [view setNeedsLayout];
    [self.tableView addSubview:view];
    [self.tableView bringSubviewToFront:view];
    
    [UIView animateWithDuration:0.3 animations:^{
        view.alpha = 1.0;
    }];
    
    
}

- (NSInteger)numberOfLikesWithViewCell:(MCSwipeTableViewCell *)cell
{
    CEditBaseItemView *c = (CEditBaseItemView *)cell;
    CItem *item = [c getItemData];
    return [item numberOfLikes];
}
//This feature is disabled.
/*- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index {
 [cell hideUtilityButtonsAnimated:YES];
 
 [self performSelector:@selector(contextMenuDidHideInCell:) withObject:cell afterDelay:0.5];
 CEditBaseItemView *c = (CEditBaseItemView *)cell;
 if ([ThreadItemManager sharedInstance].offline) {
 return;
 }
 
 switch (index) {
 case 0:
 {
 CItem *item = [c getItemData];
 [item checkToDelete];
 }
 break;
 case 2:
 {
 CItem *item = [c getItemData];
 [item checkToLike];
 }
 break;
 case 1:
 {
 CItem *item = [c getItemData];
 [self UpdateCurrentEdting:item];
 [self startedEditingWith:(CEditBaseItemView *)cell];
 }
 break;
 default:
 break;
 }
 
 }*/

- (void) MarkedPin:(BOOL)pinned withContet:(CItem *)item forIndexpath:(NSIndexPath*)indexpath
{
    [self setOtherKnoteToLess];
    
    item.userData.pinned=pinned;
    
    if(pinned)
    {
        [self.currentData removeObject:item];
        [self.currentData insertObject:item atIndex:0];
        
        NSIndexPath *newPath = [NSIndexPath indexPathForRow:0 inSection:0];
        
        [self.tableView beginUpdates];
        [self.tableView moveRowAtIndexPath:indexpath toIndexPath:newPath];
        [self.tableView endUpdates];
        [self.tableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    }
    else
    {
        [self ReoadLocalKnotes];
    }
    
    [[ThreadItemManager sharedInstance] modifyItem:item ByMessage:item.userData];
    
    [item checkToPin:pinned withNewOrder:item.order];
    
    MessageEntity *msg =item.userData;
    
    msg.pinned=pinned;
    
    [AppDelegate saveContext];
    
}

-(void)UpdateCurrentEdting:(CItem *)itemUpdate
{
    NSMutableArray *changedKnotes = [[NSMutableArray alloc] init];
    
    if (itemUpdate.userData)
    {
        MessageEntity *message = itemUpdate.userData;
        
        [changedKnotes addObject:message];
        
        if ([DataManager sharedInstance].currentAccount.account_id)
        {
            [[AppDelegate sharedDelegate] sendUpdatedKnoteCurrentlyEditing:[changedKnotes copy]
                                                                 ContactID:[DataManager sharedInstance].currentAccount.account_id];
        }
        
        [AppDelegate saveContext];
    }
}

- (void) addNewComment:(CEditBaseItemView *)cell withContet:(CItem *)item
{
    // Lin - Added to implement Show Comment View
    [self setOtherKnoteToLess];
    self.nwCommentItem = Nil;
    self.focusedToCommentitem = Nil;
    
    if (item)
    {
        self.focusedToCommentitem = item;
    }
    
    self.nwCommentItem = [[CNewCommentItem alloc] initWithNoteId:item.itemId andPadId:cell.getItemData.userData.topic_id];
    
    [self.commentInput.textView becomeFirstResponder];
    
    // Lin - Ended
}

- (void)toggleCommentsListInCell:(CEditBaseItemView *)cell withContent:(CItem *)item {
    
    [self setOtherKnoteToLess];
    BOOL commentsListShowing = !(item.userData.expanded);
    self.cellInEditor =cell;
    
    if (commentsListShowing) {
        [self hideCommentsListInCell:cell withContent:item];
    } else {
        [self showCommentsListInCell:cell withContent:item];
        [self.commentInput.textView endEditing:YES];
    }
}

- (void)setOtherKnoteToLess
{
    if (self.expandIndex)
    {
        CEditBaseItemView *cellInExpand = (CEditBaseItemView *)[self.tableView cellForRowAtIndexPath:self.expandIndex];
        CKnoteItem *expandItem = (CKnoteItem *)[cellInExpand getItemData];
        expandItem.expandedMode = NO;
        @try {
            [self.tableView reloadRowsAtIndexPaths:@[self.expandIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            
        }
        @catch (NSException *exception) {
            [self.tableView reloadData];
        }
        @finally {
        }
        //        [cellInExpand setItemData:expandItem];
        self.expandIndex = nil;
    }
}

- (void)showCommentsListInCell:(CEditBaseItemView *)cell withContent:(CItem *)item {
    [self setOtherKnoteToLess];
    self.nwCommentItem = [[CNewCommentItem alloc] initWithNoteId:item.itemId andPadId:cell.getItemData.userData.topic_id];
    
    BOOL itemHasComments = item.subReplys.count > 0;
    id comment;
    NSIndexPath *commentIndexPath;
#if !NEW_DESIGN
    item.isReplysExpand = YES;
#endif
    
    if ( self.commentInput.isHidden){
        UIEdgeInsets contentInsets = self.tableView.contentInset;
        contentInsets.bottom = 40;
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    }
    
    self.indexItemBeingCommented =item.itemId;
    if (itemHasComments) {
        
        self.numberOfCommentsitemBeingCommented =[NSNumber numberWithInt:1];
        NSMutableArray *indexPaths = [NSMutableArray new];
        
        NSUInteger position = [self.currentData indexOfObject:item];
        for ( comment in item.subReplys) {
            NSUInteger commentRowNumber =position+ [self.numberOfCommentsitemBeingCommented  intValue];
            [self.currentData insertObject:comment atIndex:commentRowNumber];
            commentIndexPath = [NSIndexPath indexPathForRow:commentRowNumber inSection:0];
            [indexPaths addObject:commentIndexPath];
            self.numberOfCommentsitemBeingCommented =[NSNumber numberWithInt:([self.numberOfCommentsitemBeingCommented intValue]+ 1)];
            
        }
        
        [self.tableView reloadData];
//        [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:NO];
//        [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:position inSection:0]] withRowAnimation:NO];
        
        NSInteger index = position + [self.numberOfCommentsitemBeingCommented intValue]- 1 ;
        NSInteger numberOfRows =[self.tableView numberOfRowsInSection:0];
        if (index <=numberOfRows){
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow: index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
        else{
            NSLog(@"Error: index to scroll > number of rows in table view");
        }
        
    }
    
    if (self.indexItemBeingCommented && ![self.itemsOpened containsObject:self.indexItemBeingCommented]){
        [self.itemsOpened addObject:self.indexItemBeingCommented];
    }
    
    [self.commentInput setHidden:NO];
    [cell updateViewMode:item.isReplysExpand];
    [self showNewCommentTextArea];
}

- (void)hideCommentsListInCell:(CEditBaseItemView *)cell withContent:(CItem *)item
{
    BOOL itemHasComments = item.subReplys.count > 0;
    
    //    BOOL commentsListShowing = (item.isReplysExpand);
    [cell.commentButton setSelected:NO];
    
    if ( item.isReplysExpand)
    {
        item.isReplysExpand = NO;
        
        [self hideNewCommentTextArea];
        
        if (itemHasComments )
        {
            NSInteger itemIndex = [self.currentData indexOfObject:item];
            int numberOfComments = (int)item.subReplys.count;
            NSRange commentsRange = NSMakeRange(itemIndex + 1, numberOfComments);
            
            [self.currentData removeObjectsInRange:commentsRange];
            
            NSMutableArray *indexPaths = [NSMutableArray new];
            
            for (int commentNumber = 1; commentNumber <= numberOfComments; commentNumber++) {
                int commentRowNumber = (int)(itemIndex + commentNumber);
                
                NSIndexPath *commentIndexPath = [NSIndexPath indexPathForRow:commentRowNumber inSection:0];
                [indexPaths addObject:commentIndexPath];
            }
            
            
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:NO];
            [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:itemIndex inSection:0]] withRowAnimation:NO];
            
            item.isReplysExpand = NO;
            [cell updateViewMode:item.isReplysExpand];
            //[self hideNewCommentTextArea];
            
        }
    }
    
    [self.itemsOpened removeObject:item.itemId];
    self.commentInput.hidden = YES;
}

- (void)showNewCommentTextArea {
    
    if (!self.commentInput.superview) {
        self.commentInput.hidden = YES;
        [self.view addSubview:self.commentInput];
        [self.view bringSubviewToFront:self.commentInput];
    }
    
    [UIView transitionWithView:self.commentInput duration:0.3 options:UIViewAnimationOptionTransitionFlipFromBottom animations:NULL completion:NULL];
    self.commentInput.hidden = NO;
    
    float toolbarHeight      = self.navigationController.toolbar.frame.size.height;
    
    float commentInputWidth  = 320;
    float commentInputHeight = 40;
    float originX            = 0;
    float originY            = self.view.frame.size.height - commentInputHeight - toolbarHeight;
    
    [self.commentInput setFrame:CGRectMake(originX, originY, commentInputWidth, commentInputHeight)];
}

- (void)hideNewCommentTextArea {
    [UIView transitionWithView:self.commentInput duration:0.3 options:UIViewAnimationOptionTransitionFlipFromTop animations:NULL completion:NULL];
    if (self.commentInput.isHidden == NO){
        UIEdgeInsets contentInsets = self.tableView.contentInset;
        contentInsets.bottom -= 40;
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    }
    
    self.commentInput.hidden = YES;
}

- (void) expandReplyInCell:(CEditBaseItemView *)cell withContet:(CItem *)item
{
    // Lin - Added to implement Show Comment View
    
    self.nwCommentItem = Nil;
    self.focusedToCommentitem = Nil;
    
    if (item)
    {
        self.focusedToCommentitem = item;
    }
    
    if (!item.isReplysExpand)
    {
        self.nwCommentItem = [[CNewCommentItem alloc] initWithNoteId:item.itemId andPadId:cell.getItemData.userData.topic_id];
    }
    
    // Lin - Ended
    
    NSInteger index = [self.currentData indexOfObject:item];
    
    if (!item.isReplysExpand)
    {
        NSMutableArray *indexPaths = [NSMutableArray new];
        
        int i;
        
        for (i = 0; i<[item.subReplys count]; i++)
        {
            [self.currentData insertObject:item.subReplys[i] atIndex:index+i+1];
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index+i+1 inSection:0];
            [indexPaths addObject:indexPath];
        }
        
        if (i > 0)
        {
//            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:NO];
            [self.tableView reloadData];
        }
        
    }
    else
    {
        NSRange range = NSMakeRange(index+1, [item.subReplys count]);
        
        //        NSRange range = NSMakeRange(index, [item.subReplys count]);
        
        [self.currentData removeObjectsInRange:range];
        
        NSMutableArray *indexPaths = [NSMutableArray new];
        
        int i;
        
        for (i = 0; i<[item.subReplys count]; i++)
        {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index+i+1 inSection:0];
            
            [indexPaths addObject:indexPath];
        }
        
        if (i > 0)
        {
            [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:NO];
        }
    }
    
    item.isReplysExpand = !item.isReplysExpand;
    
    [cell updateViewMode:item.isReplysExpand];
    
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:NO];
    
    if (item.isReplysExpand)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
//This feature is disabled.
/*- (void)menuButtonClicked:(id)cell withTag:(NSInteger)tag
 {
 NSLog(@"tag: %d", (int)tag);
 [self performSelector:@selector(contextMenuDidHideInCell:) withObject:cell afterDelay:0.5];
 CEditBaseItemView *c = (CEditBaseItemView *)cell;
 [c setOverLay:NO animate:YES];
 if ([ThreadItemManager sharedInstance].offline) {
 return;
 }
 
 switch (tag) {
 case GmDeleteTag:
 {
 CItem *item = [c getItemData];
 [item checkToDelete];
 }
 break;
 case GmLikeTag:
 {
 CItem *item = [c getItemData];
 [item checkToLike];
 }
 break;
 case GmEditTag:
 {
 [self startedEditingWith:cell];
 }
 break;
 default:
 break;
 }
 }*/

#pragma mark * COverlayView delegate

- (UIView *)overlayView:(COverlayView *)view didHitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    //    CGPoint lo = [self.tableView convertPoint:point fromView:view];
    //    CGRect rt = [self.tableView convertRect:[MenuView sharedInstance].frame fromView:self.tableView];
    //
    //    if (CGRectContainsPoint(rt, lo)) {
    //        CGPoint p = [[MenuView sharedInstance] convertPoint:point fromView:view];
    //        return [[MenuView sharedInstance] hitTest:p withEvent:event];
    //    }
    //
    //    BOOL shouldIterceptTouches = YES;
    //    CGPoint location = [self.tableView convertPoint:point fromView:view];
    //    CGRect rect = [self.tableView convertRect:self.cellDisplayingMenuOptions.frame toView:_gmTableView];
    //    shouldIterceptTouches = CGRectContainsPoint(rect, location);
    //    if (!shouldIterceptTouches) {
    //        [self hideMenuOptionsAnimated:YES];
    //    }
    //    CGPoint p = [self.cellDisplayingMenuOptions convertPoint:point fromView:view];
    //    return (shouldIterceptTouches) ? [self.cellDisplayingMenuOptions hitTest:p withEvent:event] : view;
    return nil;
}

#pragma mark * CEditBaseItemViewDelegate

- (void)adjustExpandPicCell:(NSNumber *)type
{
    if (self.expandIndex.row<self.currentData.count)
    {
        [self.tableView scrollToRowAtIndexPath:self.expandIndex atScrollPosition:[type integerValue] animated:YES];
        
    }
    if (self.expandIndex.row<self.rightData.count)
    {
        [self.tableViewRight scrollToRowAtIndexPath:self.expandIndex atScrollPosition:[type integerValue] animated:YES];
    }
}

- (void) wantExpandPicCell:(NSIndexPath *)indexPath
{
    self.expandIndex = indexPath;
    [self.tableView reloadData];
    CGPoint point = self.tableView.contentOffset;
    CGSize size = self.tableView.bounds.size;
    CGRect rect = [self.tableView rectForRowAtIndexPath:self.expandIndex];
    
    if (rect.origin.y<point.y) {
        [self performSelector:@selector(adjustExpandPicCell:) withObject:@(UITableViewScrollPositionTop) afterDelay:0.1];
    } else if ((rect.origin.y+rect.size.height)>(point.y+size.height)) {
        [self performSelector:@selector(adjustExpandPicCell:) withObject:@(UITableViewScrollPositionBottom) afterDelay:0.1];
    }
}

- (void) wantDocumentControllerPresented:(UIDocumentInteractionController *)documentController{
    
    [documentController setDelegate:self];
    self.documentInteractionController = documentController;
    //[self.documentInteractionController presentPreviewAnimated:YES];
    
    [self.documentInteractionController presentOpenInMenuFromRect:self.navigationController.navigationBar.frame inView:self.view animated:YES];
}

- (void) wantFullLayout:(UIImageView *)view
{
    GGFullscreenImageViewController *vc = [[GGFullscreenImageViewController alloc] init];
    
    vc.liftedImageView = view;
    
    _stack.hidden=YES;
    
    vc.eventToUnHideStack=^(BOOL value){
        _stack.hidden=value;
    };
    
    vc.modalPresentationStyle = UIModalPresentationCustom;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8)
    {
        //ios8 no need add this transition
        
        if (!self.transDelegate)
        {
            self.transDelegate = [[ImageTransitioningDelegate alloc] init];
        }
        
        [vc setTransitioningDelegate:self.transDelegate];
    }
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void) wantControllerPresented:(UIViewController *)controller
{
    NSLog(@"wantControllerPresented");
    
    [self presentViewController:controller animated:YES completion:^{
        
    }];
}

- (void) dismissPDFViewer
{
    NSLog(@"dismissPDFViewer");
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)showMoreButtonClicked:(CEditBaseItemView *)view atIndex:(NSUInteger)index
{
    
    CKnoteItem *noteItem = (CKnoteItem *)[view getItemData];
    
    noteItem.expandedMode = !noteItem.expandedMode;
    
    if (noteItem.expandedMode)
    {
        [view.showMoreButton setTitle:@"Less" forState:UIControlStateNormal];
    }
    else
    {
        [view.showMoreButton setTitle:@"More" forState:UIControlStateNormal];
    }
    
    if (noteItem.expandedMode)
    {
        if (self.expandIndex)
        {
            [self setOtherKnoteToLess];
        }
        
        self.expandIndex = [self.tableView indexPathForCell:view];
    }
    else
    {
        self.expandIndex = nil;
    }
    
    NSIndexPath *indexpath = [self.tableView indexPathForCell:(UITableViewCell *)view];
    
    @try
    {
        [self.tableView reloadRowsAtIndexPaths:@[indexpath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    @catch (NSException *exception)
    {
        [self.tableView reloadData];
    }
    @finally
    {
        
    }
}

- (void) listItemModify:(CEditBaseItemView *)view withOptionArray:(NSArray *)array atIndex:(NSUInteger)index withModificationType: (VoteModificationType  ) modificationType isRight:(BOOL)isRight
{
    
    if (isRight)
    {
        if(self.rightData.count > 0){
            __weak CEditBaseItemView *itemView = (CEditBaseItemView *)view;
            
            if(self.rightData.count > index){
                CItem *item = [self.rightData objectAtIndex:index];
                if ([item isKindOfClass:[CKnoteItem class]]||[item isKindOfClass:[CDateItem class]])
                {
                    return;
                }
                // For Analytics
                NSDictionary *parameters = @{ @"topicId": item.topic.topic_id, @"noteId": item.itemId };
                
                switch (modificationType) {
                    case newVote:
                        [[AnalyticsManager sharedInstance] notifyKnoteReceivedVoteWithParameters:parameters];
                        break;
                    case changeVote:
                        [[AnalyticsManager sharedInstance] notifyKnoteReceivedReVoteWithParameters:parameters];
                        break;
                    case check:
                        [[AnalyticsManager sharedInstance] notifyKnoteReceivedCheckWithParameters:parameters];
                        break;
                }
                
                [itemView showProcess];
                
                [[AppDelegate sharedDelegate] sendRequestUpdateList:item.itemId
                                                    withOptionArray:array
                                                  withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
                 {
                     if (success == NetworkSucc)
                     {
                         CVoteItem *voteItem = (CVoteItem *)item;
                         
                         NSMutableArray *vote = [[NSMutableArray alloc] initWithCapacity:3];
                         
                         for (NSDictionary *dic in array)
                         {
                             CEditVoteInfo * info = [[CEditVoteInfo alloc] initWithDic:dic];
                             info.type = item.type;
                             [vote addObject:info];
                         }
                         
                         voteItem.voteList = vote;
                         //[item saveContext];
                         [view setItemData:voteItem];
                     }
                     else
                     {
                         
                     }
                     
                     [itemView stopProcess];
                     
                 }];
                
                
            }
            
        }

    }
    else
    {
        
    if(self.currentData.count > 0){
        __weak CEditBaseItemView *itemView = (CEditBaseItemView *)view;
        
        if(self.currentData.count > index){
            CItem *item = [self.currentData objectAtIndex:index];
            if ([item isKindOfClass:[CKnoteItem class]]||[item isKindOfClass:[CDateItem class]])
            {
                return;
            }
            // For Analytics
            NSDictionary *parameters = @{ @"topicId": item.topic.topic_id, @"noteId": item.itemId };
            
            switch (modificationType) {
                case newVote:
                    [[AnalyticsManager sharedInstance] notifyKnoteReceivedVoteWithParameters:parameters];
                    break;
                case changeVote:
                    [[AnalyticsManager sharedInstance] notifyKnoteReceivedReVoteWithParameters:parameters];
                    break;
                case check:
                    [[AnalyticsManager sharedInstance] notifyKnoteReceivedCheckWithParameters:parameters];
                    break;
            }
            
            [itemView showProcess];
            
            [[AppDelegate sharedDelegate] sendRequestUpdateList:item.itemId
                                                withOptionArray:array
                                              withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
             {
                 if (success == NetworkSucc)
                 {
                     CVoteItem *voteItem = (CVoteItem *)item;
                     
                     NSMutableArray *vote = [[NSMutableArray alloc] initWithCapacity:3];
                     
                     for (NSDictionary *dic in array)
                     {
                         CEditVoteInfo * info = [[CEditVoteInfo alloc] initWithDic:dic];
                         info.type = item.type;
                         [vote addObject:info];
                     }
                     
                     voteItem.voteList = vote;
                     [view setItemData:voteItem];
                 }
                 else
                 {
                     
                 }
                 
                 [itemView stopProcess];
                 
             }];

            
        }
        
    }
    }
    
}

- (void)updateKnoteOrders
{
    NSLog(@"I M IN updateKnoteOrders man ...");
    
    NSMutableArray *changedKnotes = [[NSMutableArray alloc] initWithCapacity:self.currentData.count];
    
    int currentOrder = 1;
    
    for (CItem *item in self.currentData)
    {
        MessageEntity *message = item.userData;
        
        if([item isKindOfClass:[CPictureItem class]])
        {
            continue;
        }
        else if([item isKindOfClass:[CMessageItem class]])
        {
            CMessageItem *messageItem = (CMessageItem *)item;
            
            if(messageItem.isHeader)
            {
                continue;
            }
        }
        else if([item isKindOfClass:[CKeyNoteItem class]])
        {
            continue;
        }
        
        if (message)
        {
            if (message.order != currentOrder)
            {
                message.order = currentOrder;
                
                [changedKnotes addObject:message];
                
                NSLog(@"Setting order %lld", message.order);
            }
            
            currentOrder++;
        }
    }
    
    NSLog(@"Updating orders on %d knotes", (int)changedKnotes.count);
    
    [[AppDelegate sharedDelegate] sendUpdatedKnoteOrders:[changedKnotes copy]];
    
    [AppDelegate saveContext];
    
}

#pragma mark EditorViewControllerDelegate

- (void)insertItem:(CItem *)item withInfo:(id)info withOpType:(ItemOpType)type
{
    NSLog(@"Knotable: Insert item with body %@ and id %@ in topic with id %@", info[@"body"], info[@"_id"], self.tInfo.entity.topic_id);
    
    ThreadItemManager* threadManager = [ThreadItemManager sharedInstance];
    
    MessageEntity *message = [threadManager insertOrUpdateMessageObject:info withTopicId:self.tInfo.entity.topic_id withFlag:nil];
    message.need_send = NO;
    [message setValuesForKeysWithDictionary:info withTopicId:self.tInfo.entity.topic_id];
    message.need_send = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (type == ItemAdd)
        {
            [self HideEmptyPadOverlay];
            
            long long newOrder = 1;
            
            if (self.currentData.count > 0)
            {
                for (CItem* it in self.currentData)
                {
                    if ([it isKindOfClass:[CKeyNoteItem class]]
                        || [it isKindOfClass:[CLockItem class]])
                    {
                        continue;
                    }
                    
                    if (it.userData)
                    {
                        newOrder = it.userData.order - 1;
                    }
                    else
                    {
                        newOrder = it.order - 1;
                    }
                    
                    break;
                }
            }
            
            //            message.order = newOrder;
            //
            //            item.order = newOrder;
            
            item.order = message.order;
            
            NSArray *newItems = [threadManager generateItemsForMessage:message withTopic:self.tInfo.entity];
            [threadManager.knotesArray addObjectsFromArray: newItems];
            
            NSMutableArray *addingIndexPaths = [[NSMutableArray alloc] init];
            NSMutableArray *addingRightIndexPaths= [[NSMutableArray alloc] init];
            
            NSInteger priorInsertIndex = -1;
            NSInteger priorRightInsertIndex = -1;
            
            for(CItem *newItem in newItems)
            {
                NSInteger insertIndex = 0;
                NSInteger rightInsertIndex = 0;
                
                newItem.isSending = NO;
                newItem.checkInCloud = NO;
                newItem.needFlash = YES;
                
                if (newItem.type == C_KEYKNOTE)
                {
                    self.keyNoteItem = (CKeyNoteItem *)newItem;
                    
                    if (self.lockItem)
                    {
                        insertIndex++;
                    }
                    
                    [self.currentData replaceObjectAtIndex:insertIndex withObject:self.keyNoteItem];
                    
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:insertIndex inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
                    
                }
                else if (newItem.type == C_LOCK)
                {
                    self.lockItem = (CLockItem *)newItem;
                    
                    if (![self.currentData containsObject:self.lockItem])
                    {
                        [self.currentData insertObject:self.lockItem atIndex:insertIndex];
                        
                        [addingIndexPaths addObject:[NSIndexPath indexPathForRow:insertIndex inSection:0]];
                    }
                }
                else if (newItem.type == C_VOTE || newItem.type == C_LIST || newItem.type == C_DATE)
                {
                    if (priorRightInsertIndex == -1)
                    {
                        if (self.keyNoteItem)
                        {
                            rightInsertIndex++;
                        }
                        if (self.lockItem)
                        {
                            rightInsertIndex++;
                        }
                    }
                    else
                    {
                        rightInsertIndex = priorRightInsertIndex + 1;
                    }
                    
                    [addingRightIndexPaths addObject:[NSIndexPath indexPathForRow:rightInsertIndex inSection:0]];
                    
                    [self.rightData insertObject:newItem atIndex:rightInsertIndex];
                    
                    priorRightInsertIndex = rightInsertIndex;
                }
                else
                {
                    if (priorInsertIndex == -1)
                    {
                        if (self.keyNoteItem)
                        {
                            insertIndex++;
                        }
                        if (self.lockItem)
                        {
                            insertIndex++;
                        }
                    }
                    else
                    {
                        insertIndex = priorInsertIndex + 1;
                    }
                    
                    [addingIndexPaths addObject:[NSIndexPath indexPathForRow:insertIndex inSection:0]];
                    
                    [self.currentData insertObject:newItem atIndex:insertIndex];
                    
                    priorInsertIndex = insertIndex;
                }
            }
            
            if (addingIndexPaths.count > 0)
            {
                self.isCreatingKnote = YES;
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    
                    if ([self.currentData count] == 1)
                    {
                        double delayInSeconds = 0.1;
                        
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            
                            self.finishLoad = YES;
                            
                            [self.tableView reloadData];
                            
                        });
                    }
                    else
                    {
                        @try {
                            
//                            [self.tableView insertRowsAtIndexPaths:addingIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                            [self.tableView reloadData];
                            
                            [self.tableView scrollToRowAtIndexPath:addingIndexPaths.firstObject atScrollPosition:UITableViewScrollPositionTop animated:NO];
                            
                        }
                        @catch ( NSException *e )
                        {
                            NSLog(@"bummer: %@",e);
                            
                            NSLog(@"%d,[%d,%d]",(int)[addingIndexPaths count],(int)[(NSIndexPath *)addingIndexPaths.firstObject row],(int)[(NSIndexPath *)addingIndexPaths.firstObject section]);
                            
                            [self.tableView reloadData];
                            
                        }
                    }
                });
                
                
                self.isCreatingKnote = NO;
            }
            
            if (addingRightIndexPaths.count > 0)
            {
                self.isCreatingKnote = YES;
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                    [self.firstDot setHidden:NO];
                    [self.secondDot setHidden:NO];
                    if ([self.rightData count] == 1)
                    {
                        double delayInSeconds = 0.1;
                        
                        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                            
                            self.finishLoad = YES;
                            
                            [self.tableViewRight reloadData];
                            
                        });
                    }
                    else
                    {
                        @try {
  
                            [self.tableViewRight reloadData];
//                            [self.tableViewRight insertRowsAtIndexPaths:addingRightIndexPaths withRowAnimation:UITableViewRowAnimationFade];
                            
                            [self.tableViewRight scrollToRowAtIndexPath:addingRightIndexPaths.firstObject atScrollPosition:UITableViewScrollPositionTop animated:NO];
                            
                        }
                        @catch ( NSException *e )
                        {
                            NSLog(@"bummer: %@",e);
                            
                            NSLog(@"%d,[%d,%d]",(int)[addingRightIndexPaths count],(int)[(NSIndexPath *)addingRightIndexPaths.firstObject row],(int)[(NSIndexPath *)addingRightIndexPaths.firstObject section]);
                            
                            [self.tableViewRight reloadData];
                            
                        }
                    }
                });
                
                
                self.isCreatingKnote = NO;
            }
            
            [self performSelector:@selector(updateHeaderInfo:) withObject:@(YES) afterDelay:0.5];
            
            if (newItems && newItems.count > 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"new_knote_ready_to_post" object:newItems[0] userInfo:nil];
            }
            
        }
        else if (type == ItemModify)
        {
            [threadManager modifyItem:item ByMessage:message];
            
            item.isSending = NO;
            item.checkInCloud = NO;
            item.needFlash = YES;
            
//            [[PostingManager sharedInstance] performSelector:@selector(periodicCheck) withObject:nil afterDelay:0.5];
            
            [[PostingManager sharedInstance] periodicCheck];

        }
    });
}

#pragma mark -
#pragma mark - DPSiderMenuActionDelegate

- (void)siderMenuItemSelected:(NSString *)menuName
{
    NSLog(@"siderMenuItemSelected: %@", menuName);
    
    if (!menuName)
    {
        NSMutableArray *peopleArray = [self getPartyPeople:NO];
        
        NSLog(@"peopleArray: %@", peopleArray);
        
        if (!peopleArray
            ||[peopleArray count]<1)
        {
            [SVProgressHUD showErrorWithStatus:@"All people are in this topic." duration:3];
            return;
        }
        
        PeopleSelectViewController *vc = [[PeopleSelectViewController alloc] initWithNibName:@"PeopleSelectViewController" bundle:nil];
        
        vc.itemArray = [peopleArray copy];
        
        __block MZFormSheetController *formSheet = [[MZFormSheetController alloc] initWithViewController:vc];
        
        vc.doneBlock = ^(NSArray *selects)
        {
            [formSheet dismissAnimated:YES completionHandler:nil];
            
            if (!selects ||[selects count]>0)
            {
                __block NSMutableArray *pArray = [[NSMutableArray alloc] initWithArray:selects];
                
                [pArray addObjectsFromArray:[self.tInfo.entity.shared_account_ids componentsSeparatedByString:@","]];
                
                [[AppDelegate sharedDelegate] sendRequestUpdteParticipators:pArray
                                                                withTopicId:self.tInfo.entity.topic_id
                                                                withUseData:nil withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
                 {
                     if (success == NetworkSucc)
                     {
                         self.tInfo.entity.shared_account_ids = [pArray componentsJoinedByString:@","];
                         
                         [SVProgressHUD dismiss];
                         
                         [self.tableView reloadData];
                     }
                     else
                     {
                     }
                 }];
            }
            else
            {
            }
            
        };
        
        CGFloat height = ceilf([peopleArray count]/4.0)*50+100;
        
        if (height>350)
        {
            height = 350;
        }
        
        formSheet.presentedFormSheetSize = CGSizeMake(300, height);
        
        formSheet.transitionStyle = MZFormSheetTransitionStyleFade;
        formSheet.shadowRadius = 2.0;
        formSheet.shadowOpacity = 0.3;
        formSheet.shouldDismissOnBackgroundViewTap = YES;
        
        formSheet.willPresentCompletionHandler = ^(UIViewController *presentedFSViewController) {
            
        };
        
        [MZFormSheetController sharedBackgroundWindow].formSheetBackgroundWindowDelegate = self;
        
        [self mz_presentFormSheetController:formSheet animated:YES completionHandler:^(MZFormSheetController *formSheetController) {
        }];
    }
    else
    {
        __block NSString *actionParm = menuName;
        
        UIActionSheet *actionSheet = [UIActionSheet presentOnView:self.view
                                                        withTitle:nil
                                                     cancelButton:@"Cancel"
                                                destructiveButton:@"Remove people"
                                                     otherButtons:nil
                                                         onCancel:^(UIActionSheet *actionSheet)
                                      {
                                          DLog(@"Touched cancel button");
                                      }
                                                    onDestructive:^(UIActionSheet *actionSheet)
                                      {
                                          DLog(@"%@", actionParm);
                                          
                                          __block NSMutableArray *pArray = [[self.tInfo.entity.shared_account_ids componentsSeparatedByString:@","] mutableCopy];
                                          
                                          for (NSString *str in pArray)
                                          {
                                              if ([str isEqualToString:actionParm])
                                              {
                                                  [pArray removeObject:str];
                                                  
                                                  break;
                                              }
                                          }
                                          
                                          [[AppDelegate sharedDelegate] sendRequestUpdteParticipators:pArray
                                                                                          withTopicId:self.tInfo.entity.topic_id
                                                                                          withUseData:nil withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
                                           {
                                               if (success == NetworkSucc)
                                               {
                                                   self.tInfo.entity.shared_account_ids = [pArray componentsJoinedByString:@","];
                                                   
                                                   [SVProgressHUD dismiss];
                                                   
                                                   [self.tableView reloadData];
                                               }
                                               else
                                               {
                                                   
                                               }
                                           }];
                                          
                                      }
                                                  onClickedButton:^(UIActionSheet *actionSheet, NSUInteger index)
                                      {
                                      }];
        
        [actionSheet showInView:self.view];
    }
}

- (void)floatingTraySetAlphabetical:(BOOL)alphabetical
{
    _orderByLike = !_orderByLike;
    [self ReoadLocalKnotes];
}

- (void)floatingTraySetArchived:(BOOL)archived
{
    _showArchived = !_showArchived;
    
    [self ReoadLocalKnotes];
}

- (void)floatingTrayLock
{
    [self addNewItem:C_LOCK];
}

- (void)floatingTrayShared:(NSMutableArray *)contactsArray
{
    //[self viewSiderMenu:nil];
    __block ShareListController *shareList = [[ShareListController alloc] initWithTopic:self.tInfo.entity loginUser:self.login_user sharedContacts:contactsArray];
    
    if (!self.tInfo || !self.tInfo.entity)
    {
        if ([self.mainTitle length]<=0)
        {
            self.mainTitle = @"Untitled";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter a title to share the pad"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Ok", nil];
        
        alert.tag = 100;
        [alert show];
        
        return;
    }
    
    shareList.delegate = self;
    
    [self.navigationController pushViewController:shareList animated:YES];
}

- (void)knoteClicked:(id)sender
{
    [self addNewItem:C_KNOTE animated: YES];
}
#if New_DrawerDesign
-(void)showSharedDrawer
{
    
    __block ShareListController *shareList = [[ShareListController alloc] initWithTopic:self.tInfo.entity loginUser:self.login_user sharedContacts:[self getSharedPeople:YES] isForCombinedView:YES];
    
    
    if (!self.tInfo || !self.tInfo.entity)
    {
        if ([self.mainTitle length]<=0)
        {
            self.mainTitle = @"Untitled";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter a title to share the pad"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Ok", nil];
        
        alert.tag = 100;
        [alert show];
        
        return;
    }
    
    shareList.delegate = self;
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:shareList];
    nav.view.backgroundColor=[UIColor whiteColor];
#if ChangeInDrawer
    self.sideBar.isShowingFromRight = YES;
    [_sideBar ShowSideBarWithAnimationWithController:nav animated:YES];
#else
    _callout = [[RNFrostedSidebar alloc] initWithsideViewController:nav];
    _callout.showFromRight=YES;
    _callout.delegate = self;
    [_callout show];
#endif
}
-(void)showSharedDrawerWithoutAnimation
{
#if ChangeInDrawer
    
    if (_sideBar)
    {
        [_sideBar hideSideBarWithAnimation:NO];
    }
    
#endif
    
    __block ShareListController *shareList = [[ShareListController alloc] initWithTopic:self.tInfo.entity loginUser:self.login_user sharedContacts:[self getSharedPeople:YES] isForCombinedView:YES];
    
    if (!self.tInfo || !self.tInfo.entity)
    {
        if ([self.mainTitle length]<=0)
        {
            self.mainTitle = @"Untitled";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enter a title to share the pad"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Ok", nil];
        
        alert.tag = 100;
        [alert show];
        
        return;
    }
    
    shareList.delegate = self;
    UINavigationController *nav=[[UINavigationController alloc]initWithRootViewController:shareList];
    nav.view.backgroundColor=[UIColor whiteColor];
    nav.navigationItem.hidesBackButton=YES;
#if ChangeInDrawer
    [_sideBar ShowSideBarWithAnimationWithController:nav animated:YES];
#else
    _callout = [[RNFrostedSidebar alloc] initWithsideViewController:nav];
    _callout.showFromRight=YES;
    _callout.delegate = self;
    [_callout showAnimated:NO];
#endif
}

#endif
- (void)netWorkDidChangeStatus:(NetworkStatus)status
{
    NSLog(@"netWorkDidChangeStatus %d", (int)status);
    
    BOOL flag = (status == NotReachable);
    
    if ([ThreadItemManager sharedInstance].offline!=flag)
    {
        [ThreadItemManager sharedInstance].offline = flag;
        
        for (int i = 0; i< [self.currentData count]; i++)
        {
            CItem *item = [self.currentData objectAtIndex:i];
            
            if (item.offline != flag)
            {
                item.offline = flag;
                
                CEditBaseItemView * cellView = nil;
                
                cellView.baseItemDelegate = self;
                
                cellView.index = i;
                
                [cellView setItemData:item];
            }
        }
    }
}

#pragma mark BVReorderTableViewDelegate

// This method is called when starting the re-ording process. You insert a blank row object into your
// data source and return the object you want to save for later. This method is only called once.

- (id)saveObjectAndInsertBlankRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"index: %ld", (long)indexPath.row);
    
    CItem *item = self.currentData[indexPath.row];
    
    CKnoteItem *blankItem = [[CKnoteItem alloc] initWithMessage:nil];
    
    float maxDraggingHeight = 100.0;
    
    blankItem.height = MIN(item.height, maxDraggingHeight);
    
    self.currentData[indexPath.row] = blankItem;
    return item;
}

// This method is called when the selected row is dragged to a new position. You simply update your
// data source to reflect that the rows have switched places. This can be called multiple times
// during the reordering process

- (void)moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSLog(@"from: %ld to: %ld", (long)fromIndexPath.row, (long)toIndexPath.row);
    //NSLog(@"data before: %@", self.currentData);
    CItem *moving = [self.currentData objectAtIndex:fromIndexPath.row];
    //int offset = toIndexPath.row > fromIndexPath.row ? -1 : 0;
    int offset = 0;
    [self.currentData removeObjectAtIndex:fromIndexPath.row];
    [self.currentData insertObject:moving atIndex:toIndexPath.row + offset];
}

// This method is called when the selected row is released to its new position. The object is the same
// object you returned in saveObjectAndInsertBlankRowAtIndexPath:. Simply update the data source so the
// object is in its new position. You should do any saving/cleanup here.

- (void)finishReorderingWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"index: %ld isMainThread? %d", (long)indexPath.row, [NSThread currentThread].isMainThread);
    //[self.currentData insertObject:object atIndex:indexPath.row];
    [self.currentData replaceObjectAtIndex:indexPath.row withObject:object];
    
    [self updateKnoteOrders];
    
}

#pragma mark -
#pragma mark - Utility Functions
-(void)makeViewFullScreen
{
    [self.sideBar hideSideBarWithAnimation:YES];
    
    [[[ContactManager sharedInstance] startAddPerson:self] fulfilled:^(id result) {
        
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%@%@", result, @" added."] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }];
        
        UIViewController * vc = [self.sideBar getMainViewController];
        if([vc isKindOfClass:[UINavigationController class]]){
            NSArray * vcArray = [(UINavigationController *)[self.sideBar getMainViewController]viewControllers];
            vc = [vcArray lastObject];
            if([vc isKindOfClass:[ThreadViewController class]]){
                [self ShowAfterDismiss];
                [(ShareListController *)[[(UINavigationController *)self.sideBar.ContainerInSidebar viewControllers]lastObject] getAtON:result];
            }
        }
        
        [CATransaction commit];
        
    }];
}
-(void)ShowAfterDismiss
{
    [self showSharedDrawer];
}

- (void)sharedButtonClicked
{
    [self floatingTrayShared:nil];
}

#pragma mark CHAT INPUT DELEGATE

- (void) chatInputNewMessageSent:(NSString *)messageString
{
    if (self.nwCommentItem)
    {
        self.isPostingComment =YES;
        self.nwCommentItem.body = messageString;
        
        NSLog(@"New Comment Item : %@", self.nwCommentItem);
        
        [self.nwCommentItem postComment];
        
    }
}

#if USE_HEADER_TRAY
#pragma mark CEditHeaderInfoViewDelegate

-(void)headerButtonClickedAt:(NSInteger)index
{
    if (index<self.currentData.count)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
}

-(void)deleteButtonClicked
{
    _showArchived = !_showArchived;
    self.headerInfoView.showArchived = _showArchived;
    [self ReoadLocalKnotes];
    
#if USE_HEADER_TRAY
    [self updateHeaderInfo:NO];
#endif
    
    [_pullToRefreshManager tableViewReloadFinished];
    //[_pullToRefreshManager setPullToRefreshViewVisible:NO];
    
}
#endif

-(void)loadRestknotes
{
    for (int i=0; i<self.RestData.count; i++)
    {
        if (self.RestData[i]!=nil)
        {
            [self ProcessOnlyKnoteWithDict:self.RestData[i]];
        }
    }
    [self.RestData removeAllObjects];
    [self check_KnotesCount];
    if (_isAddedPullRefresh_toGetRest)
    {
        _isAddedPullRefresh_toGetRest=NO;
    }
}

@end

#pragma mark -
#pragma mark - Overlay View implemention

@implementation ThreadViewController (KnoteEPNVDelegate)

- (void)actionMakeNewKnote
{
    _isNewPad = NO;
    
    // Lin : will process for new knote action
    
    [self addNewItem:C_KNOTE animated: YES];
}

- (void) actionAddSomeone
{
    _isNewPad = NO;
    
    [self floatingTrayShared:nil];
}

@end

#pragma mark - Action From MyProfileController

@implementation ThreadViewController (My)

- (void)actionMakeNewKnote
{
    _isNewPad = NO;
    
    // Lin : will process for new knote action
    
    [self addNewItem:C_KNOTE animated: YES];
}

-(NSMutableArray *)RestData{
    if(!_RestData){
        _RestData = [NSMutableArray array];
    }
    
    return _RestData;
}

- (void) actionAddSomeone
{
    _isNewPad = NO;
    
    [self floatingTrayShared:nil];
}
#pragma mark - MNMBottomPullToRefreshManager Delegate
- (void)bottomPullToRefreshTriggered:(MNMBottomPullToRefreshManager *)manager {
    
    [self performSelector:@selector(loadRestknotes) withObject:nil afterDelay:1.0f];
    self.showFooter = YES;
}
-(void)loadRestknotes
{
    for (int i=0; i<self.RestData.count; i++)
    {
        if (self.RestData[i]!=nil)
        {
            [self ProcessOnlyKnoteWithDict:self.RestData[i]];
        }
    }
    [self.RestData removeAllObjects];
    
    [self check_KnotesCount];
    
    if (_isAddedPullRefresh_toGetRest)
    {
        _isAddedPullRefresh_toGetRest=NO;
    }
}
@end
