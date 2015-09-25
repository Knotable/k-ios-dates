//
//  TopicManager.h
//  Knotable
//
//  Created by backup on 14-2-25.
//
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "AccountEntity.h"
#import "UserEntity.h"
#import "ContactsEntity.h"
#import "ObjCMongoDB.h"
#import "TopicsEntity.h"

@class TopicInfo;

@interface TopicManager : NSObject

@property (atomic,strong) NSMutableArray *processArray;

+ (TopicManager *)sharedInstance;
- (void)generateNewTopic:(NSString *)title account:(AccountEntity *)account sharedContacts:(NSArray *)sharedContacts andBeingAutocreated:(BOOL)isAutoCreated withCompleteBlock:(MongoCompletion)block;

- (void)generateNewTopic:(NSString *)title content:(NSDictionary *)content files:(NSArray *)files account:(AccountEntity *)account sharedContacts:(NSArray *)sharedContacts andBeingAutocreated:(BOOL)isAutoCreated withCompleteBlock:(MongoCompletion)block;

- (void)archivedTopic:(TopicInfo *)tInfo withCompleteBlock:(MongoCompletion)block;

- (void)archivedLocalTopic:(TopicInfo *)tInfo withCompleteBlock:(MongoCompletion)block;

- (void)recordTopicToServer:(TopicInfo *) tInfo withCompleteBlock:(MongoCompletion2)block;

- (NSString *)generateNewTopicTitle;
- (TopicsEntity *)generateNewTopicEntityWithTitle:(NSString *)title account:(AccountEntity *)account sharedContacts:(NSArray *)sharedContacts;

@end
