//
//  DataManager.h
//  Knotable
//
//  Created by Martin Ceperley on 1/29/14.
//
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <ObjectiveDDP/MeteorClient.h>


#define kUserAddSubscribe 0
#define kInvalidatePosition 999
#define kTimeStamp @"kTimeStamp"
#define kMuteTimeStamp @"kMuteTimeStamp"
#define kHotOrMute @"kHotOrMute" //0:hote 1:mute 2:all
#define kContactUserFetchedController 1
#define kPeopleProcess 1

@class CombinedViewController;
@class MessageEntity;
@class MeteorClient;

typedef void (^DataManagerCompletion)(BOOL success, NSError *error);

static NSString *CONTACTS_DOWNLOADED_NOTIFICATION = @"CONTACTS_DOWNLOADED_NOTIFICATION";

static NSString *CONTACT_IMAGE_DOWNLOADED_NOTIFICATION = @"CONTACT_IMAGE_DOWNLOADED_NOTIFICATION";

static NSString *TOPICS_DOWNLOADED_NOTIFICATION = @"TOPICS_DOWNLOADED_NOTIFICATION";

static NSString *TOPICS_ADDEDED_NOTIFICATION = @"TOPICS_ADDEDED_NOTIFICATION";

static NSString *TOPICS_CHANGED_NOTIFICATION = @"TOPICS_CHANGED_NOTIFICATION";

static NSString *TOPICS_REMOVED_NOTIFICATION = @"TOPICS_REMOVED_NOTIFICATION";

static NSString *TOPICS_AUTO_DELETED_NOTIFICATION = @"TOPICS_AUTO_DELETED_NOTIFICATION";

static NSString *HOT_KNOTES_DOWNLOADED_NOTIFICATION = @"HOT_KNOTES_DOWNLOADED_NOTIFICATION";

static NSString *MUTE_KNOTES_DOWNLOADED_NOTIFICATION = @"MUTE_KNOTES_DOWNLOADED_NOTIFICATION";

static NSString *KNOTES_HAS_MUTED_NOTIFICATION = @"KNOTES_HAS_MUTED_NOTIFICATION";

static NSString *NEW_CONTACT_DOWNLOADED_NOTIFICATION = @"NEW_CONTACT_DOWNLOADED_NOTIFICATION";

static NSString *RELATIONSHIPS_UPDATED_NOTIFICATION = @"RELATIONSHIPS_UPDATED_NOTIFICATION";

static NSString* FORCE_RELOAD_PAD_FOR_ACTIVE_TOPICS = @"FORCE_RELOAD_PAD_FOR_ACTIVE_TOPICS";

@class AccountEntity, TopicsEntity, UserEntity;

@interface DataManager : NSObject

+ (DataManager *)sharedInstance;

- (void)startRemoteFetch;

- (void)forceFetchRemoteContacts;

- (void)fetchRemoteContacts;

- (void)fetchRemoteContactsThenHotKnotes;

- (void)forceFetchRemoteTopics;

- (TopicsEntity *)insertOrUpdateNewTopicObject:(NSDictionary*) dic;
-(void)removeSubscriptionFromMeteor;
- (void)reset;

@property (nonatomic, strong) AccountEntity *currentAccount;
@property (nonatomic, strong) NSDictionary  *accountTokenBackup;

@property (nonatomic, assign) BOOL fetchedContacts;
@property (nonatomic, readonly) BOOL fetchedTopics;
@property (nonatomic, readonly) BOOL fetchedHotKnotes;
@property (nonatomic, assign) BOOL finishFetchTopic;

@property (atomic, assign)  BOOL    finished_active_topic_pulling;

@property (nonatomic, readonly) NSDate *lastFetchedContacts;
@property (nonatomic, readonly) NSDate *lastFetchedTopics;
@property (nonatomic, readonly) NSDate *lastFetchedHotKnotes;

@property (nonatomic, readonly) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, assign) NSInteger currentOrder;

@property (nonatomic, assign) BOOL forceStopFetchTopic;
@property (nonatomic, strong) NSMutableArray *muteOperatorArray;
@property (nonatomic, assign) BOOL userLogin;

@property (nonatomic, strong) NSString *current_user_id;

@property (nonatomic, weak) CombinedViewController *combinedVC;

#if kPeopleProcess
@property (nonatomic, assign) NSInteger contactsCount;
#endif
@property (strong, nonatomic) MeteorClient *meteor;

- (UserEntity *)saveUserObject:(NSDictionary*) dic;

- (void)setMessage:(MessageEntity *)message withMute:(BOOL)mute;

- (BOOL)lastAccountIsLoggedIn;

- (void)saveIfNeeded;
- (void) deleteTopicWithTopicID:(NSString *)topicID;
- (void)turnOffBackground;
- (void)turnOnBackground;
-(void)turnOnContactsInBackground;
-(void)turnOffContactsInBackground;

@end
