//
//  ThreadItemManager.h
//  Knotable
//
//  Created by backup on 14-2-8.
//
//

#import <Foundation/Foundation.h>
#import "ThreadConst.h"
#import "CItem.h"
#import "MessageEntity.h"
#import "CUtil.h"
#import "Singleton.h"
#import "ObjCMongoDB.h"
#import "NSString+Knotes.h"
#import "TopicInfo.h"


@interface ThreadItemManager : NSObject

@property (nonatomic, assign) BOOL offline;
@property (nonatomic, strong) NSArray *peopleData;
@property (atomic,strong) NSMutableArray *processArray;
@property (nonatomic, strong) NSMutableArray* knotesArray; // CItem array at ThreadViewController

+ (ThreadItemManager *)sharedInstance;
- (CItem *)findExistingItemById:(NSString *)itemId;

- (CItem *)generateItemForMessage:(MessageEntity *)message withTopic:(TopicsEntity *)topic;

- (NSArray *)generateItemsForMessage:(MessageEntity *)message withTopic:(TopicsEntity *)topic;

- (void)modifyItem:(CItem *)item ByMessage:(MessageEntity *)message;

- (void)sendInsertKey:(CItem *)item withCompleteBlock:(MongoCompletion3)block;

- (void)sendInsertLock:(CItem *)item withCompleteBlock:(MongoCompletion3)block;

- (void)insertKnote:(CItem *)item fileInfos:(NSArray *)fileInfos;

- (void)updateKeynotesFileIds:(CItem *)item withCompleteBlock:(MongoCompletion)block;

- (MessageEntity *)insertOrUpdateMessageObject:(NSDictionary*) dic withTopicId:(NSString *)topic_id withFlag:(NSNumber **)flag;

- (NSString *)getDateTimeIndicate:(NSTimeInterval)realInterval;

- (void)addComment:(NSString *)commentBody toNoteWithId:(NSString *)noteId inTopicWithId:(NSString *)topicId;

- (void)changeNotesWithTopicId:(NSString *)topicId toTopicId:(NSString *)newTopicId;

@end
