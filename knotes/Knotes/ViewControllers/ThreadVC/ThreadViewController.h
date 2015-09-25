//
//  ThreadViewController.h
//
//  Created by backup on 13-10-15.
//
//

#import "TopicsEntity.h"
#import "UserEntity.h"
#import "MZFormSheetController.h"
#import "PeopleSelectViewController.h"
#import "UIActionSheet+Blocks.h"
#import "ComposeThreadViewController.h"
#import "S3Manager.h"
#import "MenuView.h"
#import "ShareListController.h"
#import "SWTableViewCell.h"
#import "MCSwipeTableViewCell.h"
#import "MyProfileController.h"
#import "MNMBottomPullToRefreshManager.h"
#import "CDateItem.h"
#import "KnotesProgressView.h"

@class TopicInfo;

@protocol ThreadViewControllerDelegate <NSObject>

- (void)needChangeTopicTitle:(TopicInfo *)tInfo;

@end
#if NEW_DESIGN
@interface ThreadViewController : UIViewController <UIDocumentInteractionControllerDelegate, CReplyViewDelegate,CTitleInfoBarDelegate,CReplyFieldDelegate,MNMBottomPullToRefreshManagerClient, ShareListDelegateProtocol,SWTableViewCellDelegate>
#else

@interface ThreadViewController : UIViewController <ShareListDelegateProtocol,SWTableViewCellDelegate, UIDocumentInteractionControllerDelegate>

#endif
@property (nonatomic)      NSMutableArray  *currentData;
@property (nonatomic, weak) id <ThreadViewControllerDelegate>delegate;
@property (nonatomic, assign) BOOL isNewTopicAdded;
@property (nonatomic) BOOL isAutoCreated;
@property (nonatomic) BOOL shouldPopToMainView;
@property (nonatomic) BOOL shouldReloadKnotes;
@property (nonatomic, strong) TopicInfo *tInfo;
@property (nonatomic, strong) KnotableProgressView  *knoteLoadingView;

- (id) initWithTopic:(TopicInfo *)tInfo;
- (void) reloadThreads;

- (void)ShowEmptyPadOverlay:(BOOL)showSlogan;
- (void)HideEmptyPadOverlay;

- (void)ProcessKnoteAndMessagewithDict:(NSDictionary*)serverResponse;

- (void)ProcessOnlyKnoteWithDict:(NSDictionary*)serverResponse;
- (void)ProcessOnlyMessageWithDict:(NSDictionary*)serverResponse;

- (void)AddObserversForSelectedPad;
- (void)RemoveObserverFromSelectedPad;
-(void)ShowAfterDismiss;
-(void)updateChangedKnote:(CItem *)item;
- (void)removedContactFromPad:(ContactsEntity*)contact;
- (void)ThreadPopBack;

- (void) changedTopic:(NSNotification *)notification;

- (void)ShowKnoteLoadingView;
- (void)HideKnoteLoadingView;

- (void)Ready_topic;
- (void)Ready_pinnedKnotes;
- (void)Ready_archivedKnotes;

- (BOOL)check_ReadyToUse_Knote;
- (void)check_KnotesCount;

- (void)newTopicCreatedFromComposeView:(TopicInfo *)topic;

- (void) changeTopic:(TopicInfo*) newTopic;
- (void) showComposeViewController:(BOOL) usingLastEditInfo animated: (BOOL) animated;
@end

@interface ThreadViewController (MyProfileDelegateProtocol)<MyProfileDelegateProtocol>

@end

extern NSString* defaultTopicName;
extern NSString* lastTopicId;