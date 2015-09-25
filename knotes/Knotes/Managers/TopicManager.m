//
//  TopicManager.m
//  Knotable
//
//  Created by backup on 14-2-25.
//
//

#import "TopicManager.h"
#import "DataManager.h"
#import "AnalyticsManager.h"
#import "ThreadItemManager.h"

#import "ObjCMongoDB.h"
#import "TopicInfo.h"
#import "FileInfo.h"
#import "ServerConfig.h"

#import "UIImage+Knotes.h"
#import "NSString+Knotes.h"


@implementation TopicManager

SYNTHESIZE_SINGLETON_FOR_CLASS(TopicManager);

- (id)init
{
    self = [super init];
    if (self) {
        self.processArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    return self;
}

- (void)generateNewTopic:(NSString *)title account:(AccountEntity *)account sharedContacts:(NSArray *)sharedContacts andBeingAutocreated:(BOOL)isAutoCreated withCompleteBlock:(MongoCompletion)block
{
    if (!(account && account.account_id)) {
        return;
    }
    __block TopicInfo *tInfo = nil;
    
    TopicsEntity *entity = [TopicsEntity MR_createEntity];
    
    entity.topic_id = [NSString stringWithFormat:@"%@%@", kKnoteIdPrefix, [[AppDelegate sharedDelegate] mongo_id_generator]];
    
    entity.topic = title;
    
    NSLog(@"generateNewTopic set topic_id: %@ topic: %@", entity.topic_id, entity.topic);
    
    entity.topic_type = 0;
    entity.isArchived = @(NO);
    entity.created_time = [NSDate date];
    entity.updated_time = [NSDate date];
    entity.locked_id = @"";
    entity.account_id = account.account_id;
    entity.viewers = account.account_id;
    
    NSMutableArray *shared_account_ids = [[NSMutableArray alloc] initWithArray:@[account.account_id]];
    
    if (sharedContacts) {
        for (ContactsEntity *contact in sharedContacts) {
            if(contact.account_id && ![shared_account_ids containsObject:contact.account_id]){
                [shared_account_ids addObject:contact.account_id];
            }
        }
    }
    
    NSLog(@"new topic shared_account_ids: %@", shared_account_ids);
    
    entity.shared_account_ids = [shared_account_ids componentsJoinedByString:@","];
    
    NSNumber *new_order =  @(999);
    
    TopicsEntity *highestOrderTopic = [TopicsEntity MR_findFirstOrderedByAttribute:@"order" ascending:NO];
    
    if(highestOrderTopic && highestOrderTopic.order != nil)
    {
        new_order = @(highestOrderTopic.order.integerValue + 1);
    }
    
    entity.order = new_order;
    
    entity.order_to_set = new_order;
    entity.order_user_id = account.user.user_id;
    
    NSMutableArray *participantEmails = [[NSMutableArray alloc] init];
    
    [participantEmails addObject:[account.user getFirstEmail]];
    
    for (ContactsEntity *contact in sharedContacts)
    {
        if (contact.email && ![participantEmails containsObject:[contact getFirstEmail]]) {
            [participantEmails addObject:[contact getFirstEmail]];
        }
    }
    
    entity.participators = [participantEmails componentsJoinedByString:@","];
    
    NSLog(@"New topic with shared_account_ids: %@ participators: %@", entity.shared_account_ids, entity.participators);
    
    tInfo = [[TopicInfo alloc] initWithTopicEntity:entity];
    
    tInfo.entity.needSend = @(YES);
    
    tInfo.my_account_id = account.account_id;
    
    block(NetworkSucc,nil,tInfo);
    
    [AppDelegate saveContext];
}

- (void)generateNewTopic:(NSString *)title content:(NSDictionary *)content files:(NSArray *)files account:(AccountEntity *)account sharedContacts:(NSArray *)sharedContacts andBeingAutocreated:(BOOL)isAutoCreated withCompleteBlock:(MongoCompletion)block 
{
    NSLog(@"generateNewTopic: %@ : %@", title, content);
    __block TopicInfo *tInfo = nil;
    
    TopicsEntity *entity = [TopicsEntity MR_createEntity];
    
    entity.topic_id = [NSString stringWithFormat:@"%@%@", kKnoteIdPrefix, [[AppDelegate sharedDelegate] mongo_id_generator]];
    
    entity.topic = title;
    NSLog(@"generateNewTopic set topic_id: %@ topic: %@", entity.topic_id, entity.topic);

    entity.topic_type = 0;
    entity.isArchived = @(NO);
    entity.created_time = [NSDate date];
    entity.updated_time = [NSDate date];
    entity.locked_id = @"";
    entity.account_id = account.account_id;
    entity.viewers = account.account_id;

    NSMutableArray *shared_account_ids = [[NSMutableArray alloc] initWithArray:@[account.account_id]];

    if (sharedContacts)
    {
        for (ContactsEntity *contact in sharedContacts)
        {
            if(contact.account_id && ![shared_account_ids containsObject:contact.account_id])
            {
                [shared_account_ids addObject:contact.account_id];
            }
        }
    }
    
    NSLog(@"new topic shared_account_ids: %@", shared_account_ids);

    entity.shared_account_ids = [shared_account_ids componentsJoinedByString:@","];

    NSNumber *new_order =  @(999);
    
    TopicsEntity *highestOrderTopic = [TopicsEntity MR_findFirstOrderedByAttribute:@"order" ascending:NO];
    
    if(highestOrderTopic && highestOrderTopic.order != nil)
    {
        new_order = @(highestOrderTopic.order.integerValue + 1);
    }
    
    entity.order = new_order;

    entity.order_to_set = new_order;
    entity.order_user_id = account.user.user_id;


    NSMutableArray *participantEmails = [[NSMutableArray alloc] init];
    
    [participantEmails addObject:[account.user getFirstEmail]];
    
    for (ContactsEntity *contact in sharedContacts)
    {
        if (contact.email && ![participantEmails containsObject:[contact getFirstEmail]])
        {
            [participantEmails addObject:[contact getFirstEmail]];
        }
    }

    entity.participators = [participantEmails componentsJoinedByString:@","];

    NSLog(@"New topic with shared_account_ids: %@ participators: %@", entity.shared_account_ids, entity.participators);

    tInfo = [[TopicInfo alloc] initWithTopicEntity:entity];
    //tInfo.content = [MessageEntity wrapTextInHTML:content];
    tInfo.content = content[@"htmlBody"];
    tInfo.filesArray = files;
    
    // Lin - Added for setting account_id for TopicInfo
    
    tInfo.my_account_id = account.account_id;
    
    // Lin - Ended
    
    MessageEntity *message = [MessageEntity MR_createEntity];
    
    [message setValuesForKeysWithDictionary:content withTopicId:[entity.topic_id noPrefix:kKnoteIdPrefix]];
    
    message.contact = [ContactsEntity MR_findFirstByAttribute:@"mainEmail" withValue:message.email];
    
    tInfo.message_id = message.message_id;
    
    tInfo.topic_id = entity.topic_id;
    
    message.need_send = YES;

    if (files && [files count]>0)
    {
        NSMutableArray *file_ids = [[NSMutableArray alloc] initWithCapacity:3];
        
        for (FileInfo *fInfo in files)
        {
            [file_ids addObject:fInfo.imageId];
        }
        
        tInfo.filesIds = @[];
        
        message.file_ids = [file_ids componentsJoinedByString:@","];
    }
    else
    {
        tInfo.filesIds = @[];
    }
    
    NSArray *items = [[ThreadItemManager sharedInstance] generateItemsForMessage:message withTopic:entity];

    //CItem *item = [[ThreadItemManager sharedInstance] generateItemForMessage:message withTopic:entity];
    tInfo.items = items;
    tInfo.item = items.firstObject;

    AppDelegate *app = [AppDelegate sharedDelegate];
    
    [app saveContextAndWait];

    tInfo.entity.needSend = @(YES);
    NSLog(@"uploading Topic from generateNewTopic completion %@", tInfo.topic_id);
    
    if(!isAutoCreated){
        [tInfo recordSelfToServer];
    }

    block(NetworkSucc,nil,tInfo);
    
}

- (void)recordTopicToServer:(TopicInfo *) tInfo withCompleteBlock:(MongoCompletion2)block
{
    NSLog(@"recordTopicToServer");

    NSLock *checkLock = [[NSLock alloc] init];
    
    [checkLock lock];
    
    if ( !self.processArray )
    {
        self.processArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    BOOL needAdd = ![self.processArray containsObject:tInfo];
    
    if (needAdd)
    {
        [self.processArray addObject:tInfo];
        
        NSLog(@"Adding to processArray: %@ : %@", tInfo.topic_id, self.processArray);
    }
    
    if (![tInfo.entity.isSending boolValue])
    {
        //Sending to Meteor instead of Mongo
        
        MeteorClient *meteor = [AppDelegate sharedDelegate].meteor;
        
        if (!meteor || !meteor.connected || ![[DataManager sharedInstance] lastAccountIsLoggedIn ]) {
            NSLog(@"Knotable: NOT POSTING TOPIC, not connected");
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [self recordTopicToServer:tInfo withCompleteBlock:block];
            });
            
            [checkLock unlock];
            return;
        }

        TopicsEntity *topic = tInfo.entity;
        
        
        NSArray *participator_account_ids = @[];
        
        if (topic.shared_account_ids)
        {
            participator_account_ids = [[[NSOrderedSet orderedSetWithArray:[topic.shared_account_ids componentsSeparatedByString:@","]] array] copy];
        }
        else if (topic.account_id)
        {
            participator_account_ids = @[topic.account_id];
        }
        else if ([DataManager sharedInstance].currentAccount.account_id)
        {
            participator_account_ids = @[[DataManager sharedInstance].currentAccount.account_id];
        }
        
        NSArray *participator_emails = [[NSSet setWithArray:[topic.participators componentsSeparatedByString:@","]] allObjects];

        
        NSDictionary *requiredTopicParams = @{
                @"userId":[DataManager sharedInstance].currentAccount.user.user_id,
                @"participator_account_ids":participator_account_ids,
                @"subject":topic.topic,
                @"permissions":@[@"read", @"write", @"upload"],
        };
        
        NSDictionary *optionalTopicParams = @{
               @"file_ids":tInfo.filesIds ? tInfo.filesIds : @[],
               @"_id":[topic.topic_id noPrefix:kKnoteIdPrefix],
               @"order":@{[DataManager sharedInstance].currentAccount.user.user_id : topic.order_to_set != nil? topic.order_to_set : @(999)},
              @"to":participator_emails,
              };
        
        NSDictionary *additionalOptions = @{/*@"topicId":[topic.topic_id noPrefix:kKnoteIdPrefix]*/};
        
        NSArray *params = @[requiredTopicParams, optionalTopicParams, additionalOptions];
        
        if (meteor && meteor.connected) {
            tInfo.entity.isSending = @(YES);
            NSLog(@"Knotable: Going to create topic in server with id %@ and entity.topic %@", tInfo.topic_id, tInfo.entity.topic);
            [meteor callMethodName:@"create_topic" parameters:params responseCallback:^(NSDictionary *response, NSError *error) {
                if (error) {
                    NSLog(@"Knotable: Error creating topic in server with id %@ and entity.topic %@", tInfo.topic_id, tInfo.entity.topic);
                    NSLog(@"error calling create_topic on meteor: %@", error);
                    block(NetworkFailure, error, nil, nil);
                } else {
                    NSLog(@"Knotable: Succeed to create topic in server with id %@ and entity.topic %@", tInfo.topic_id, tInfo.entity.topic);
                    NSString *topic_id = response[@"result"];
                    
                    BOOL shouldNotifyTopicChangedId = NO;
                    if (![tInfo.topic_id isEqualToString:topic_id]) {
                        shouldNotifyTopicChangedId = YES;
                    }
    
                    tInfo.topic_id = topic_id;
                    tInfo.entity.topic_id = topic_id;
                    if (tInfo.item) {
                        tInfo.item.topic.topic_id = topic_id;
                        if(tInfo.item.userData){
                            tInfo.item.userData.topic_id = topic_id;
                        }
                        
                    }
                    tInfo.entity.needSend         = @(NO);
                    tInfo.item.files              = tInfo.filesArray;
                    tInfo.item.needSend           = NO;
                    if(tInfo.item.userData){
                        tInfo.item.userData.need_send = NO;
                    }
                    
                    
                    if ([tInfo.topic_id rangeOfString:kKnoteIdPrefix].location != NSNotFound) {
                        [self setNewTopicId:tInfo.topic_id toMessagesWithId:tInfo.topic_id];
                    }
                    tInfo.entity.isSending = @(NO);
                    [AppDelegate saveContext];
                    
                    NSLog(@"success calling create_topic on meteor topic_id: %@", topic_id);
                    
                    NSDictionary *parameters = @{ @"topicId": topic_id };
                    
                    [[AnalyticsManager sharedInstance] notifyPadWasCreatedWithParameters:parameters];
                    
                    [self.processArray removeObject:tInfo];
                    
                    if (shouldNotifyTopicChangedId) {
                        NSLog(@"Knotable: Going to send notification @'TOPIC_CHANGED_ID' with topicId param %@", topic_id);
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"TOPIC_CHANGED_ID" object:nil userInfo:@{@"topicId": topic_id}];
                    }
                    
                    block(NetworkSucc, nil, topic_id, nil);
                }
            }];
        }
        else
        {
            NSLog(@"cant call create_topic, meteor not connected");
        }
        
    }
    else
    {
        NSLog(@"Not sending to mongo already isSending: %@", tInfo.topic_id);
    }
    
    [checkLock unlock]; 
}

- (void)setNewTopicId:(NSString *)topicId toMessagesWithId:(NSString *)tempTopicId {
//    - (void)changeNotesWithTopicId:(NSString *)topicId toTopicId:(NSString *)newTopicId {
    [[ThreadItemManager sharedInstance] changeNotesWithTopicId:tempTopicId toTopicId:topicId];
}

- (void)archivedTopic:(TopicInfo *)tInfo withCompleteBlock:(MongoCompletion)block
{
    NSLock *checkLock = [[NSLock alloc] init];
    
    [checkLock lock];
    
    if ( !self.processArray )
    {
        self.processArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    BOOL needAdd = ![self.processArray containsObject:tInfo];
    
    if (needAdd)
    {
        [self.processArray addObject:tInfo];
    }
    else
    {
        DLog(@"%@", self.processArray);
        
        DLog(@"Do not need to add this Pad");
    }
    
    if(tInfo.entity.managedObjectContext != nil){
        if (![tInfo.entity.isSending boolValue])
        {
            tInfo.entity.isSending = @(YES);
            
            NSMutableArray *archivedArray = [[NSMutableArray alloc] init];
            
            if (tInfo.entity.archived)
            {
                archivedArray = [[tInfo.entity.archived componentsSeparatedByString:@","] mutableCopy];
                
                for (int i = 0 ; i <[archivedArray count]; i++)
                {
                    NSString *my_account = [archivedArray objectAtIndex:i];
                    
                    if ([my_account isEqualToString:@""])
                    {
                        [archivedArray removeObjectAtIndex:i];
                        
                        break;
                    }
                }
            }
            
            if (!tInfo.archived)
            {
                DLog(@"tInfo.my_account_id : %@", tInfo.my_account_id);
                
                if (tInfo.my_account_id == Nil)
                {
                    tInfo.my_account_id = [DataManager sharedInstance].currentAccount.account_id;
                }
                
                [archivedArray addObject:tInfo.my_account_id];
            }
            else
            {
                for (int i = 0 ; i <[archivedArray count]; i++)
                {
                    NSString *my_account = [archivedArray objectAtIndex:i];
                    
                    if ([my_account isEqualToString:tInfo.my_account_id])
                    {
                        [archivedArray removeObjectAtIndex:i];
                        
                        break;
                    }
                }
            }
            
            if ( archivedArray && [archivedArray count] > 0 )
            {
                [[AppDelegate sharedDelegate] sendRequestDeleteTopic:tInfo.entity.topic_id
                                                        withArchived:archivedArray
                                                   withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
                 {
                     tInfo.entity.isSending = @(NO);
                     
                     [self.processArray removeObject:tInfo];
                     
                     block(success, error, userData);
                 }];
            }
        }
        else
        {
            DLog(@"Server is processing this with server");
        }
        
    }
    
    
    [checkLock unlock];
}

- (void)archivedLocalTopic:(TopicInfo *)tInfo withCompleteBlock:(MongoCompletion)block
{
    // Checking isSending Value here
    
    DLog(@"Topic's entity information : %@", tInfo.entity);
    
    if (![tInfo.entity.isSending boolValue])
    {
        
        NSLock *checkLock = [[NSLock alloc] init];
        
        [checkLock lock];
        
        tInfo.entity.isSending = @(YES);
        
        NSMutableArray *archivedArray = [[NSMutableArray alloc] init];
        
        if (tInfo.entity.archived)
        {
            archivedArray = [[tInfo.entity.archived componentsSeparatedByString:@","] mutableCopy];
            
            for (int i = 0 ; i <[archivedArray count]; i++)
            {
                NSString *my_account = [archivedArray objectAtIndex:i];
                
                if ([my_account isEqualToString:@""])
                {
                    [archivedArray removeObjectAtIndex:i];
                    
                    break;
                }
            }
        }
        
        if (!tInfo.archived)
        {
            DLog(@"tInfo.my_account_id : %@", tInfo.my_account_id);
            
            if (tInfo.my_account_id == Nil)
            {
                tInfo.my_account_id = [DataManager sharedInstance].currentAccount.account_id;
            }
            
            [archivedArray addObject:tInfo.my_account_id];
        }
        else
        {
            for (int i = 0 ; i <[archivedArray count]; i++)
            {
                NSString *my_account = [archivedArray objectAtIndex:i];
                
                if ([my_account isEqualToString:tInfo.my_account_id])
                {
                    [archivedArray removeObjectAtIndex:i];
                    
                    break;
                }
            }
        }
        
        if ( archivedArray && [archivedArray count] > 0 )
        {
            tInfo.entity.isSending = @(NO);
        }
    
        [checkLock unlock];
        
        block(NetworkSucc, Nil, archivedArray);
    }
    else
    {
        DLog(@"Server is processing this with server");
    }
    
    
}

- (NSString *)generateNewTopicTitle {
    NSDate * date = [NSDate date];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
    NSDateComponents *componentsDate = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    
    NSString *secs = [NSString stringWithFormat:@"%ld", (long)[components second]];
    if(secs.length < 2){
        secs = [@"0" stringByAppendingString:secs];
    }
    
    NSString * minuteS = [NSString stringWithFormat:@"%ld", (long)[components minute]];
    if(minuteS.length <= 1){
        minuteS = [@"0" stringByAppendingString:minuteS];
    }
    
    NSString * amORpm = @"am";
    NSInteger hour = [components hour];
    if([components hour] >= 13){
        amORpm = @"pm";
        if (hour > 12) {
            hour -= 12;
        }
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM"];
    NSString *monthStringFromDate = [formatter stringFromDate:date];
    formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE"];
    
    NSInteger dayNumber = [componentsDate day];
    NSString *dayNumberString = [NSString stringWithFormat:@"%ld", (long)dayNumber];
    
    NSString *padTitle = [NSString stringWithFormat:@"%@ %@, %@ %@", monthStringFromDate, dayNumberString, [NSString stringWithFormat:@"%ld:%@:%@",(long)hour,minuteS, secs], amORpm];
    
    BOOL haveAccessToCalendar = [[AppDelegate sharedDelegate].calendarEventManager eventsAccessGranted];
    if (haveAccessToCalendar) {
        BOOL validEventFound = [[AppDelegate sharedDelegate].calendarEventManager getNextEventTitle];
        if (validEventFound) {
            padTitle = [[AppDelegate sharedDelegate].calendarEventManager getNextEventTitle];
        }
    }
    
    return padTitle;
}

- (TopicsEntity *)generateNewTopicEntityWithTitle:(NSString *)title account:(AccountEntity *)account sharedContacts:(NSArray *)sharedContacts {
    
    if (!(account && account.account_id)) {
        return nil;
    }
    
    TopicsEntity *entity = [TopicsEntity MR_createEntity];
    entity.topic_id = [NSString stringWithFormat:@"%@%@", kKnoteIdPrefix, [[AppDelegate sharedDelegate] mongo_id_generator]];
    entity.topic = title;
    entity.needSend = @(NO);
    entity.needToSync = @(NO);
    entity.topic_type = 0;
    entity.isArchived = @(NO);
    entity.created_time = [NSDate date];
    entity.updated_time = [NSDate date];
    entity.hasNewActivity = @(YES);
    entity.locked_id = @"";
    entity.account_id = account.account_id;
    entity.viewers = account.account_id;
    
    NSMutableArray *shared_account_ids = [[NSMutableArray alloc] initWithArray:@[account.account_id]];
    if (sharedContacts) {
        for (ContactsEntity *contact in sharedContacts) {
            if(contact.account_id && ![shared_account_ids containsObject:contact.account_id]){
                [shared_account_ids addObject:contact.account_id];
            }
        }
    }
    entity.shared_account_ids = [shared_account_ids componentsJoinedByString:@","];
    
    NSNumber *new_order =  @(999);
    TopicsEntity *highestOrderTopic = [TopicsEntity MR_findFirstOrderedByAttribute:@"order" ascending:NO];
    if(highestOrderTopic && highestOrderTopic.order != nil) {
        new_order = @(highestOrderTopic.order.integerValue + 1);
    }
    
    entity.order = new_order;
    entity.order_to_set = new_order;
    entity.order_user_id = account.user.user_id;
    
    NSMutableArray *participantEmails = [[NSMutableArray alloc] init];
    
    [participantEmails addObject:[account.user getFirstEmail]];
    
    for (ContactsEntity *contact in sharedContacts) {
        if (contact.email && ![participantEmails containsObject:[contact getFirstEmail]]) {
            [participantEmails addObject:[contact getFirstEmail]];
        }
    }
    entity.participators = [participantEmails componentsJoinedByString:@","];
    
    NSError *error = nil;
    if ([entity.managedObjectContext save:&error]) {
        return entity;
    } else {
        DLog(@"Knotable: Error creating temporary topic");
        return nil;
    }
}

@end
