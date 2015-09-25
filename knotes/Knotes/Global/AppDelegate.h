/*

 Copyright (c) 2013 Joan Lluch <joan.lluch@sweetwilliamsl.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is furnished
 to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE ANDConstant.h NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

*/

#import <UIKit/UIKit.h>
#import <ObjectiveDDP/MeteorClient.h>
#import "FileEntity.h"
#import "constant.h"
#import "ContactsEntity.h"
#import "ThreadCommon.h"
#import "CalendarEventManager.h"


#define DIRECT_AWS_DOWNLOAD        YES

//before you change this macro,you need delete Documents/current_server.plist and servers.plist

/*
 
Production version :com.knotable.knotable

-----------------
 
Knote Beta1     :  com.knotable.knotealpha2     :   knotealpha2
Knote Beta2     :  com.knotable.knotealpha3     :   knotealpha3
 
-----------------

PreBeta version :   com.knotable.knoteprebeta   :   knoteprebeta

-----------------

KnoteStage      :   com.knotable.knotestaging   :   knotestaging

-----------------

KnoteDev        :   com.knotable.knotedev       :   knotedev
 
*/

#define K_SERVER_BETA       1
#define K_SERVER_STAGING    0
#define K_SERVER_DEV        0

@class LoginViewController, MeteorClient, AccountEntity, ServerConfig, BWStatusBarOverlay;

@class MyProfileController;

@class KnotableNavigationController;

@interface AppDelegate : UIResponder <UIApplicationDelegate,
                                    DDPAuthDelegate,
                                    UIActionSheetDelegate>

+ (AppDelegate*)sharedDelegate;

@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) KnotableNavigationController *navController;

@property (strong, nonatomic) LoginViewController *loginController;

@property (strong, nonatomic) MyProfileController   *g_ProfileVC;

@property (strong, nonatomic) UINavigationController *recentNVC;
@property (strong, nonatomic) UINavigationController *peopleNVC;
@property (strong, nonatomic) UINavigationController *padNVC;
@property (strong, nonatomic) UINavigationController *profileNVC;
@property (strong, nonatomic) FileEntity *SharedFile;
@property (strong, atomic) MeteorClient *meteor;
@property (strong, atomic) MeteorClient *meteorOld;
@property (nonatomic, strong) BWStatusBarOverlay  *barstyleloaderthread;
@property (nonatomic, strong) BWStatusBarOverlay  *barstyleloaderCombine;
@property (assign, nonatomic) BOOL firstIn;
@property (assign, nonatomic) BOOL needUseClipBoard;
@property (nonatomic, strong) ServerConfig *server;
@property (nonatomic, readonly) NSString *serverID;
@property (nonatomic, readonly) NSArray *allServerConfigs;
@property (nonatomic, copy) NSDate *sessionStart;
@property (atomic, assign) BOOL hasLogin;
@property (nonatomic, strong) CalendarEventManager *calendarEventManager;

// Lin - Added to

@property (atomic, assign) NSInteger    user_active_topics;
@property (atomic, assign) NSInteger    user_archived_topics;
@property (atomic, assign) NSInteger    user_total_topics;

// Lin - Ended

// Malik Added

@property (atomic, assign) NSInteger    user_total_contacts;

// Ended

@property (nonatomic, assign) BOOL loadFromGoogleConnect;

+ (void)setNotFirstUser;
- (void)login:(BOOL)animated;
- (void)logout;
- (void)restoreAppData;
+ (void)saveContext;
- (void)saveContextAndWait;

- (void) AddSubscriptionMeteorCollection:(NSString*)collection;

- (void)meteorLoginWithUsername:(NSString *)inputUsername password:(NSString *)inputPassword;
- (void)meteorLoginWithSessionToken:(NSString *)token;

- (void) ShowAlert:(NSString*)title messageContent:(NSString *)content;
- (void) AutoHiddenAlert:(NSString*)title messageContent:(NSString *)content;
- (void) HideAlert:(NSString*)title messageContent:(NSString *)content withDelay:(double)delay;

- (CGFloat) heightOfTextForString:(NSString *)aString andFont:(UIFont *)aFont maxSize:(CGSize)aSize;

- (void) entryMainView:(BOOL)animated;
- (NSString *)generateConfigAWSPath;

- (void)showCombinedVC:(BOOL)animated;

// New methods from DB Calling to Meteor.Collection Calls
// Added by Lin

@property (strong, nonatomic) NSString* appUserAccountID;

// Working
- (NSString*) mongo_id_generator;

// Working
- (void) sendUpdatedTopicSubject:(NSString *)topic_id
                    withContent:(NSString *)subject
              withCompleteBlock:(MeteorClientMethodCallback)block;

// Working
- (void) sendUpdatedTopicViewed:(NSString *)topic_id
                      accountID:(NSString *)account_id
                          reset:(BOOL)shouldReset;

// Working
- (void) sendUpdatedTopicOrder:(NSString *)topic_id
                     accountID:(NSString *)account_id
                     OrderRank:(NSString*)order
                         reset:(BOOL)shouldReset;

// Working
- (void) sendRequestMessages:(NSString *)topic_id
           withCompleteBlock:(MongoCompletion)block;

// Working
- (void) sendRequestContactByAccountId:(NSString *)account_id
                     withCompleteBlock:(MongoCompletion)block;

// Wroking
- (void) sendRequestContactByEmail:(NSString *)email
                 withCompleteBlock:(MongoCompletion)block;

// Working
- (void) sendRequestKnotes:(NSString *)topic_id
         withCompleteBlock:(MongoCompletion)block;

// Working
- (NSString *) getAccountID:(NSString *)user_id;

// Working
- (void) sendRequestAccountID:(NSString *)user_id
            withCompleteBlock:(MongoCompletion)block;

// Working
- (void) sendRequestUser:(NSString *)username
                   email:(NSString *)email
       withCompleteBlock:(MongoCompletion)block;

// Working
- (void) sendUpdateKnotesFileIds:(NSMutableDictionary *)knote
                   withAccountId:(NSString *)account_id
                     withUseData:(id)userData
               withCompleteBlock:(MongoCompletion)block;

// Working
- (void) sendInsertKnotes:(NSMutableDictionary *)knote
               withUserId:(NSString *)userId
              withUseData:(id)userData
        withCompleteBlock:(MongoCompletion3)block;

// Working
- (void) sendUpdatedTopicOrders:(NSArray *)messages;

// Working
- (void) sendUpdatedKnoteOrders:(NSArray *)messages;
- (void) sendUpdatedKnoteOrderMaps:(NSArray *)messages;

// Working
- (void) sendUpdatedContact:(NSManagedObject *)contactEntity;

// Working
- (void) sendUpdatedContactWithImage:(NSManagedObject *)contactEntity
                                 URL:(NSDictionary *)Urls;

// Working : Need to check
- (WM_NetworkStatus) postedKnotesTopicID:(NSString *)topicID
                                  userID:(NSString *)userID
                                 knoteID:(NSString *)knoteID;

// Not using
- (void) sendRequestLockInfo:(NSString *)_id
           withCompleteBlock:(MongoCompletion)block;

// Working
- (int) sendRequestUpdateTopicLockedIdKeyId:(NSString *)topic_id
                                      field:(NSString *)_id
                                   keyValue:(NSString*)value;
// Working
- (void) sendRequestTopic:(NSString *)topic_id
               withUserId:(NSString *)userId
        withCompleteBlock:(MongoCompletion)block;

// Working
- (void) sendRequestlockAction:(NSMutableDictionary *)knote
                    withUserId:(NSString *)userId
                       topicId:(NSString *)topic_id
                   withUseData:(id)data
             withCompleteBlock:(MongoCompletion3)block;

// Working
- (void) sendRequestUnlockAction:(NSMutableDictionary *)knote
                      withUserId:(NSString *)userId
                         topicId:(NSString *)topic_id
               withCompleteBlock:(MongoCompletion)block;

- (void) sendRequestArchiveKnote:(NSString *)_id
                        Archived:(BOOL)arhived
                       isMessage:(BOOL)isMessage
               withCompleteBlock:(MongoCompletion)block;
// Working
- (void) sendRequestUpdateKeyNote:(NSMutableDictionary *)knote
                       withUserId:(NSString *)userId
                          topicId:(NSString *)topic_id
                      withUseData:(id)data
                withCompleteBlock:(MongoCompletion3)block;

// Working
- (void) sendRequestDeleteKeyNote:(NSString *)_id
                          topicId:topic_id
                withCompleteBlock:(MongoCompletion)block;

// Working
- (void) sendUpdatedKnoteCurrentlyEditing:(NSArray *)messages
                                ContactID:(NSString *)ContactID;

// Working
- (void) sendUpdatedKnoteUnsetCurrentlyEditing:(NSArray *)messages;

// Working
- (void) sendRequestFile:(NSString *)file_id
             withMessage:(MessageEntity *)message
       withCompleteBlock:(MongoCompletion)block;

// Working
- (void) sendRequestAddFile:(id)fileInfo
              withAccountId:(NSString *)account_id
                withUseData:(id)userData
          withCompleteBlock:(MongoCompletion)block;

// Working
- (void) sendRequestAddPin:(BOOL )pinned
                  itemType:(CItemType)type
                   knoteId:(NSString *)knote_id
                     order:(int64_t)neworder
         withCompleteBlock:(MongoCompletion)block;

// Working
- (void) sendRequestAddLike:(NSMutableArray *)liked_array
                   itemType:(CItemType)type
                    knoteId:(NSString *)knote_id
          withCompleteBlock:(MongoCompletion)block;

// Not using
- (void) sendRequestUpdteParticipators:(NSMutableArray *)new_participators
                           withTopicId:(NSString *)topicId
                           withUseData:(id)userData
                     withCompleteBlock:(MongoCompletion)block;

// Working
- (void) sendRequestDeleteTopic:(NSString *)_id
                   withArchived:(NSArray*)archived
              withCompleteBlock:(MongoCompletion)block;

// Working
- (void) sendRequestDeleteCommentFrom:(NSString *)knoteId
                        withCommentID:(NSString*)commentId
                withCompleteBlock:(MongoCompletion)block;

// Working
- (void) sendRequestUpdateList:(NSString *)_id
               withOptionArray:(NSArray *)array
             withCompleteBlock:(MongoCompletion)block;

// Working
- (void) checkIfUserHasGoogle:(NSString *)account_id
            withCompleteBlock:(MongoCompletion)block;

// Working
- (void) sendRequestSaveGoogle:(NSDictionary *)serviceData
                     accountID:(NSString *)account_id
             withCompleteBlock:(MongoCompletion)block;

// Working
- (void)sendTopicBookMarkStatusToServer:(NSString *)topic_id
                            withContent:(BOOL)bookMarkFlag
                      withCompleteBlock:(MeteorClientMethodCallback)block;

// Working
- (ContactsEntity*)sendRequestContactByContactID:(NSString *)ContactID;
//Testing
- (void) sendUpdatedKnoteUnArchiveWithID:(NSString *)knoteID withCompleteBlock:(MongoCompletion)block;

// Ended by Lin


@end
