//
//  single_mongodb.h
//  RevealControllerProject
//
//  Created by yanbo on 13-11-8.
//
//

#import <Foundation/Foundation.h>
#import "ThreadCommon.h"
#import "ObjCMongoDB.h"
#import "ContactsEntity.h"

#define S3_FILENAME_FORMAT @"uploads/%@"

#define MUTE_KNOTE_FETCH_LIMIT 10000

#define HOT_KNOTE_FETCH_LIMIT 5
#define HOT_KNOTE_DISPLAY_LIMIT 5

@protocol MongoEngineDelegate <NSObject>

@required

- (void)loginNetworkResult:(id)obj withCode:(NSInteger)code;
- (void)gotContactResult:(id)obj withCode:(NSInteger)code;
- (void)gotTopicResult:(id)obj userData:(id)data withCode:(NSInteger)code;

@end

@interface single_mongodb : NSObject

@property (nonatomic,strong,getter = getCurr) NSString *account_id;

-(MongoConnection *)generateConnection;
+(single_mongodb *)sharedInstanceMethod;

+ (void)releaseSharedInstance;
+ (void)disconnect_to_server;

//+ (void)sendRequestLogin:(NSString *)name Password:(NSString *)pass withDelegate:(id)delegate;

//deprecated code NS_DEPRECATED_IOS(2_0, 8_0)
//+(void)sendRequestContactList:(NSString *)user_id withDelegate:(id)delegate;

//+(void)sendRequestMyTopics:(AccountEntity *)account withDelegate:(id)delegate;

//+(void)sendRequestTopicList:(NSString *)email userEmail:(NSString*)user_email userData:(id) data withDelegate:(id)delegate;
//+(void)sendRequestTopicsByID:(NSArray *)ids withDelegate:(id)delegate;
//+(void)sendUpdatedTopicSubject:(NSString *)topic_id withContent:(NSString *)subject  withCompleteBlock:(MongoCompletion)block;
//+(void)sendUpdatedTopicViewed:(NSString *)topic_id accountID:(NSString *)account_id reset:(BOOL)shouldReset;
//+(void)sendUpdatedTopicOrder:(NSString *)topic_id accountID:(NSString *)account_id OrderRank:(NSString*)order reset:(BOOL)shouldReset;
//+(ContactsEntity *)sendRequestContactByContactID:(NSString *)ContactID;

//+(void)sendRequestMessages:(NSArray *)topic_ids withCompleteBlock:(MongoCompletion)block;
//+(void)sendRequestContactByAccountId:(NSString *)account_id withCompleteBlock:(MongoCompletion)block;
//+(void)sendRequestBelongIdsByAccountId:(NSString *)account_id withCompleteBlock:(MongoCompletion)block;
//+(void)sendRequestContactByEmail:(NSString *)email withCompleteBlock:(MongoCompletion)block;
//+(void)sendRequestMeIds:(NSArray *)contacts withCompleteBlock:(MongoCompletion)block;
//+(void)sendRequestEmails:(NSString *)_id withParticipators:(NSArray *)participators withCompleteBlock:(MongoCompletion)block;
//+(void)sendRequestKnotes:(NSArray *)topic_ids withCompleteBlock:(MongoCompletion)block;
//+(void)sendRequestKeyNotes:(NSString *)_id withCompleteBlock:(MongoCompletion)block;
//+(void)getLatestNotification:(NSString*)email withCompleteBlock:(MongoCompletion)block;

//+(NSString*)getAccountID:(NSString *)user_id withMongoConnection:(MongoConnection *)dbconn;
//+(void)sendRequestAccountID:(NSString *)user_id withCompleteBlock:(MongoCompletion)block;

//+(void)sendRequestUser:(NSString *)username email:(NSString *)email withCompleteBlock:(MongoCompletion)block;
//+(void)sendUpdateKnotesFileIds:(NSMutableDictionary *)knote withAccountId:(NSString *)account_id withUseData:(id)userData withCompleteBlock:(MongoCompletion)block;
//+(void)sendInsertKnotes:(NSMutableDictionary *)knote withUserId:(NSString *)userId withUseData:(id)userData withCompleteBlock:(MongoCompletion3)block;

//+(NSString*)mongo_id_generator;

//+(void)sendRequestLockInfo:(NSString *)_id withCompleteBlock:(MongoCompletion)block;
//+(void)sendRequestlockAction:(NSMutableDictionary *)knote withUserId:(NSString *)userId topicId:(NSString *)topic_id withUseData:(id)data  withCompleteBlock:(MongoCompletion3)block;
//+(void)sendRequestUnlockAction:(NSMutableDictionary *)knote withUserId:(NSString *)userId topicId:(NSString *)topic_id withCompleteBlock:(MongoCompletion)block;

// Converted
//-(int)sendRequestUpdateTopicLockedIdKeyId:(NSString *)topic_id field:(NSString *)_id keyValue:(NSString*)value withMongoConnection:(MongoConnection *)dbconn;
//+(void)sendRequestTopic:(NSString *)topic_id withUserId:(NSString *)userId withCompleteBlock:(MongoCompletion)block;
//+(void)sendRequestArchiveKnote:(NSString *)_id Archived:(BOOL)arhived isMessage:(BOOL)isMessage withCompleteBlock:(MongoCompletion)block;

//+(void)sendRequestUpdateKeyNote:(NSMutableDictionary *)knote withUserId:(NSString *)userId topicId:(NSString *)topic_id withUseData:(id)data withCompleteBlock:(MongoCompletion3)block;
//+(void)sendRequestDeleteKeyNote:(NSString *)_id topicId:topic_id withCompleteBlock:(MongoCompletion)block;
//+(void)sendUpdatedKnoteCurrentlyEditing:(NSArray *)messages ContactID:(NSString *)ContactID;
//+(void)sendUpdatedKnoteUnsetCurrentlyEditing:(NSArray *)messages;
//+(void)sendUpdatedContactWithImage:(NSManagedObject *)contactEntity URL:(NSDictionary *)Urls;
//+(void)sendRequestAddTopic:(NSMutableDictionary *)topic withUserId:(NSString *)userId withUseData:(id)data  withCompleteBlock:(MongoCompletion2)block;
//+(void)sendRequestAddPin:(BOOL )pinned itemType:(CItemType)type knoteId:(NSString *)knote_id order:(int64_t)neworder withCompleteBlock:(MongoCompletion)block;
//+(void)sendRequestAddLike:(NSMutableArray *)liked_array itemType:(CItemType)type knoteId:(NSString *)knote_id withCompleteBlock:(MongoCompletion)block;
//+(void)sendRequestFile:(NSString *)file_id withCompleteBlock:(MongoCompletion)block;
//+(void)sendRequestAddFile:(id)fileInfo withAccountId:(NSString *)account_id withUseData:(id)userData withCompleteBlock:(MongoCompletion)block;
//+(void)sendRequestUpdteParticipators:(NSMutableArray *)new_participators withTopicId:(NSString *)topicId withUseData:(id)userData withCompleteBlock:(MongoCompletion)block;

//+(void)sendRequestDeleteTopic:(NSString *)_id withArchived:(NSArray*)archived withCompleteBlock:(MongoCompletion)block;
//+ (void)sendRequestArchivePeople:(NSString *)_id Archived:(BOOL)arhived withCompleteBlock:(MongoCompletion)block;
//+(void)sendUpdatedTopicOrders:(NSArray *)messages;
//+(void)sendUpdatedKnoteOrders:(NSArray *)messages;
//+(void)sendUpdatedContact:(NSManagedObject *)contact;

//+ (void)sendRequestUpdateList:(NSString *)_id withOptionArray:(NSArray *)array withCompleteBlock:(MongoCompletion)block;

//+ (void)sendRequestHotKnotes:(NSString *)account_id withCompleteBlock:(MongoCompletion)block;

//+(void)checkIfUserHasGoogle:(NSString *)account_id withCompleteBlock:(MongoCompletion)block;
//+(void)sendRequestSaveGoogle:(NSDictionary *)serviceData accountID:(NSString *)account_id withCompleteBlock:(MongoCompletion)block;

//+(void)sendRecordLoginData:(NSString *)username seconds:(NSTimeInterval)timeTaken error:(NSError *)error reason:(NSString *)reason;
//+(void)sendRequestSaveNotificationStatus:(BOOL)notificationStatus accountID:(NSString *)account_id withCompleteBlock:(MongoCompletion)block;
//+(void)recordHotknoteHasViewedOnActivites:(NSString*)account_id withKnoteId:(NSString *)knote_id andTopicID:(NSString *)topic_id withCompleteBlock:(MongoCompletion)block;


//+(void)checkHotknoteHasViewedOnActivites:(NSString*)account_id withKnoteId:(NSString *)knote_id withCompleteBlock:(MongoCompletion)block;

@end
