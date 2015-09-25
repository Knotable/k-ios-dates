//
//  TopicInfo.h
//  Knotable
//
//  Created by backup on 14-2-25.
//
//

#import <Foundation/Foundation.h>

#import "TopicsEntity.h"
#import "ComposeView.h"
#import "ThreadCommon.h"
#import "KnotesCellProtocal.h"

@class CItem;
@class TopicInfo;
@class TopicCell;
@class MessageEntity;

@protocol TopicInfoDelegate <NSObject>

-(void) topicArchivOperate:(TopicInfo *)tInfo;

@end

@interface TopicInfo : NSObject

@property(nonatomic, strong) NSString       *topic_id;
@property(nonatomic, strong) NSString       *message_id;
@property(nonatomic, strong) TopicsEntity   *entity;
@property(nonatomic, strong) NSString       *my_account_id;
@property(nonatomic, strong) CItem          *item;
@property(nonatomic, strong) NSArray        *items;
@property(nonatomic, strong) NSString       *content;
@property(nonatomic, strong) NSArray        *filesArray;
@property(nonatomic, strong) NSArray        *filesIds;
@property(nonatomic, assign) BOOL           archived;
@property(nonatomic, assign) BOOL           hasNewActivity;

@property(nonatomic, weak) id<KnotableCellProtocal>cell;
@property(nonatomic, weak) id <TopicInfoDelegate> delegate;
@property(nonatomic, strong) NSIndexPath    *indexPath;
@property (atomic, assign) NSInteger        uploadRetryCount;

- (id) initWithTopicEntity:(TopicsEntity *)entity;
- (void) processOperator:(btnOperatorTag)oper;
- (void) recordSelfToServer;
- (void) udpateSelfTopicArchive:(btnOperatorTag)oper;

- (void) bookMarkTopicOnline:(BOOL)bookMarkStatus TopicEntity:(TopicsEntity*)entity;


+ (NSString*) defaultName;

@end
