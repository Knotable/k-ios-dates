//
//  ThreadItemManager.m
//  Knotable
//
//  Created by backup on 14-2-8.
//
//

#import "ThreadItemManager.h"
#import "DataManager.h"
#import "AnalyticsManager.h"
#import "PostingManager.h"

#import "Utilities.h"

#import "CReplysItem.h"
#import "CKeyNoteItem.h"
#import "CKnoteItem.h"
#import "CMessageItem.h"
#import "CDateItem.h"
#import "CVoteItem.h"
#import "CNewCommentItem.h"
#import "CLockItem.h"
#import "CPictureItem.h"

#import "AccountEntity.h"
#import "UserEntity.h"
#import "ContactsEntity.h"

#import "FileInfo.h"
#import "CEditVoteInfo.h"

#import "CEditInfoBar.h"

#import "NSDate+InternetDateTime.h"
#import "NSString+Knotes.h"
#import "Constant.h"
#import "AppDelegate.h"

@interface ThreadItemManager ()

@property (nonatomic, strong) NSDateFormatter *dateTimeFormat;

@end

@implementation ThreadItemManager

SYNTHESIZE_SINGLETON_FOR_CLASS(ThreadItemManager);

- (id)init
{
    self = [super init];
    
    if (self)
    {
        self.dateTimeFormat = [[NSDateFormatter alloc] init];
        
        [self.dateTimeFormat setDateFormat:kDateFormat];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"archived == %@", @(NO)];
        
        self.peopleData = [ContactsEntity MR_findAllSortedBy:@"contact_id" ascending:NO withPredicate:predicate];

        self.processArray = [NSMutableArray new];
        self.knotesArray = [NSMutableArray new];
    }
    
    return self;
}

- (NSString *)getTitleImageName:(MessageEntity *)message
{
    for (ContactsEntity *contact in _peopleData)
    {
        if (![contact isFault])
        {
            if ([contact.email isEqualToString:message.email])
            {
                if (contact.gravatar_exist)
                {
                    NSString *path  = [CUtil pathForCachedImage:[CUtil hashForEmail:contact.email]];
                    
                    if([[NSFileManager defaultManager] fileExistsAtPath:path])
                    {
                        return contact.email;
                    }
                    else
                    {
                        return contact.bgcolor;
                    }
                }
                else
                {
                    return contact.bgcolor;
                }
                
                break;
            }
        }
        else
        {
            
        }
    }
    
    return @"bgcolor0";
}

- (CItem *)findExistingItemById:(NSString *)itemId
{
    CItem *retItem = nil;
    
    static NSLock *checkLock = nil;
    if (checkLock)
    {
        checkLock = [NSLock new];
    }
    
    [checkLock lock];

    NSArray* itemArray = [self.processArray arrayByAddingObjectsFromArray: self.knotesArray];

    for (CItem *item in itemArray)
    {
        if ([item.itemId isEqualToString:itemId])
        {
            retItem = item;
            break;
        }
    }
    
    [checkLock unlock];
    
    return retItem;
}

- (MessageEntity *)insertOrUpdateMessageObject:(NSDictionary*) dic
                                   withTopicId:(NSString *)topic_id
                                      withFlag:(NSNumber **)flag
{
    MessageEntity *message = nil;
    
    NSString *message_id = dic[@"_id"];
    
    NSString *type = dic[@"type"];
    
    if ([type isEqualToString:@"key_knote"])
    {
        return nil;
    }
    
    [glbAppdel.managedObjectContext lock];
    
    if (message_id)
    {
        message = [MessageEntity MR_findFirstByAttribute:@"message_id"
                                               withValue:message_id
                                               inContext:glbAppdel.managedObjectContext];
    }
    
    if (!message)
    {
        if (flag != nil)
        {
            *flag = @(YES);
        }
        
        message = [MessageEntity MR_createEntity];
        
    }
    else
    {
        if (flag != nil)
        {
            *flag = @(NO);
        }
    }
    
    [glbAppdel.managedObjectContext unlock];
    
    for(NSString * key in dic.allKeys){
        NULL_TO_NIL([dic objectForKey:key]);
    }
    
    [message setValuesForKeysWithDictionary:dic withTopicId:topic_id];
    
    message.contact = [ContactsEntity MR_findFirstByAttribute:@"mainEmail"
                                                    withValue:message.email];
    
    return message;
}

- (CItem *)generateItemForMessage:(MessageEntity *)message withTopic:(TopicsEntity *)topic
{
    NSArray *items = [self generateItemsForMessage:message withTopic:topic];
    
    return items.firstObject;
}

- (NSArray *)generateItemsForMessage:(MessageEntity *)message withTopic:(TopicsEntity *)topic
{
    CItem *retItem = [self findExistingItemById:message.message_id];
    
    if (retItem)
    {
        [retItem setCommonValueByMessage:message];
        
        retItem.topic = topic;
        
        NSMutableArray *output = [@[retItem] mutableCopy];
        
#if THREAD_TEST
        
        if ([message.availableFileIDs count]>0
            || [message.loadedEmbeddedImages count]>0)
        {
            CPictureItem *pItem = [[CPictureItem alloc] initWithMessage:message];
            
            pItem.userData = message;
        }
        
#else
        
        for(NSString *fileId in [message availableFileIDs])
        {
            [output addObject:[[CPictureItem alloc] initWithMessage:message fileId:[fileId noPrefix:kKnoteIdPrefix]]];
        }
        
        for(NSString *fileURL in [message loadedEmbeddedImages])
        {
            [output addObject:[[CPictureItem alloc] initWithMessage:message imageURL:fileURL]];
        }
        
#endif
#if !NEW_DESIGN
    
        if (message.replys)
        {
            NSArray *a = [NSKeyedUnarchiver unarchiveObjectWithData:message.replys];
            
            for (NSDictionary *dic in a)
            {
                CReplysItem *item = [[CReplysItem alloc] init];
                
                item.content = dic;
                
                item.parentItem = retItem;
                
                [retItem.subReplys addObject:item];
                
#if NEW_FEATURE
                
                if (message.expanded)
                {
                    retItem.isReplysExpand = YES;
                    [output addObject:item];
                }
                
#endif
                
            }
        }
#endif
        
        return output;
    }

    NSMutableArray *items = [[NSMutableArray alloc] init];

    message.topic_type = C_MESSAGE;
    
    switch (message.type)
    {
        case C_MESSAGE_TO_KNOTE:
        case C_KNOTE:
        {
            retItem = [[CKnoteItem alloc] initWithMessage:message];
            [items addObject:retItem];
            if (message.type == C_MESSAGE_TO_KNOTE)
            {
                retItem.type = C_MESSAGE_TO_KNOTE;
            }
#if THREAD_TEST
            
            if ([message.availableFileIDs count]>0
                || [message.loadedEmbeddedImages count]>0)
            {
                CPictureItem *pItem = [[CPictureItem alloc] initWithMessage:message];
                
                pItem.userData = message;
            }
#else
            
            NSArray *avFiles = [message availableFileIDs];
            
            for(NSString *fileId in avFiles)
            {
                [items addObject:[[CPictureItem alloc] initWithMessage:message fileId:[fileId noPrefix:kKnoteIdPrefix]]];
            }
            
            NSArray *emImageArray = [message loadedEmbeddedImages];
            
            for(NSString *imageURL in emImageArray)
            {
                [items addObject:[[CPictureItem alloc] initWithMessage:message imageURL:imageURL]];
            }
#endif
#if !NEW_DESIGN

            if (message.replys)
            {
                NSArray *a = [NSKeyedUnarchiver unarchiveObjectWithData:message.replys];
                
                for (NSDictionary *dic in a)
                {
                    CReplysItem *item = [[CReplysItem alloc] init];
                    
                    item.content = dic;
                    
                    item.parentItem = retItem;
                    
                    [retItem.subReplys addObject:item];
#if NEW_FEATURE
                    if (message.expanded) {
                        retItem.isReplysExpand = YES;
                        [items addObject:item];
                    }
#endif
                }
            }
#endif
        }
            break;
            
        case C_KEYKNOTE:
        {
            [items addObject:[[CKeyNoteItem alloc] initWithMessage:message]];
        }
            break;
            
        case C_DATE:
        {
            retItem = [[CDateItem alloc] initWithMessage:message];
            
            [(CDateItem *)retItem setDate: [NSDate dateWithTimeIntervalSince1970:message.time]];
            
            NSString *dline = [NSString stringWithFormat:@"%@",[NSKeyedUnarchiver unarchiveObjectWithData:message.content]];
            
            [(CDateItem *)retItem setDeadline:[NSDate dateFromAppleString:dline]];
            
            [items addObject:retItem];
#if !NEW_DESIGN
          
            if (message.replys)
            {
                NSArray *a = [NSKeyedUnarchiver unarchiveObjectWithData:message.replys];
                
                for (NSDictionary *dic in a)
                {
                    CReplysItem *item = [[CReplysItem alloc] init];
                    
                    item.content = dic;
                    
                    item.parentItem = retItem;
                    
                    [retItem.subReplys addObject:item];
#if NEW_FEATURE
                    if (message.expanded) {
                        retItem.isReplysExpand = YES;
                        [items addObject:item];
                    }
#endif
                }
            }
#endif

        }
            break;
            
        case C_VOTE:
        case C_LIST:
        {
            CVoteItem *retItem =  [[CVoteItem alloc] initWithMessage:message];
            
            NSArray *a = [NSKeyedUnarchiver unarchiveObjectWithData:message.content];
            
            NSMutableArray *vote = [[NSMutableArray alloc] initWithCapacity:3];
            
            for (NSDictionary *dic in a)
            {
                CEditVoteInfo * info = [[CEditVoteInfo alloc] initWithDic:dic];
                
                info.type = message.type;
                
                [vote addObject:info];
            }
            
            [retItem setVoteList:vote];
            
            retItem.type = message.type;

            [items addObject:retItem];
#if !NEW_DESIGN

            if (message.replys)
            {
                NSArray *a = [NSKeyedUnarchiver unarchiveObjectWithData:message.replys];
                
                for (NSDictionary *dic in a)
                {
                    CReplysItem *item = [[CReplysItem alloc] init];
                    
                    item.content = dic;
                    
                    item.parentItem = retItem;
                    
                    [retItem.subReplys addObject:item];
#if NEW_FEATURE
                    if (message.expanded) {
                        retItem.isReplysExpand = YES;
                        [items addObject:item];
                    }
#endif
                }
            }
#endif
        }
            
            break;
            
        case C_LOCK:
        {
            CLockItem *item = [[CLockItem alloc] initWithMessage:message];
            
            message.order = -1;
            
            [items addObject:item];
        }
            break;
            
        case C_MESSAGE:
        {
            CMessageItem *item = [[CMessageItem alloc] initWithMessage:message];
            
            [items addObject:item];
            
#if THREAD_TEST
            
            if ([message.availableFileIDs count]>0 || [message.loadedEmbeddedImages count]>0)
            {
                CPictureItem *pItem = [[CPictureItem alloc] initWithMessage:message];
                
                pItem.userData = message;
            }
#else
            for(NSString *fileId in [message availableFileIDs])
            {
                [items addObject:[[CPictureItem alloc] initWithMessage:message fileId:[fileId noPrefix:kKnoteIdPrefix]]];
            }
            
            for(NSString *imageURL in [message loadedEmbeddedImages])
            {
                [items addObject:[[CPictureItem alloc] initWithMessage:message imageURL:imageURL]];
            }
#endif
#if !NEW_DESIGN

            if (message.replys)
            {
                NSArray *a = [NSKeyedUnarchiver unarchiveObjectWithData:message.replys];
                
                for (NSDictionary *dic in a)
                {
                    CReplysItem *item = [[CReplysItem alloc] init];
                    item.content = dic;
                    item.parentItem = retItem;
                    [item.subReplys addObject:item];
#if NEW_FEATURE
                    if (message.expanded) {
                        retItem.isReplysExpand = YES;
                        [items addObject:item];
                    }
#endif
                }
            }
#endif

        }
            break;
            
        default:
            break;
    }

    for(CItem *item in items)
    {
        item.imageName = [self getTitleImageName:message];
        
        item.topic = topic;
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.time];
        
        item.time =  [self.dateTimeFormat stringFromDate:date];
        
        //for info bar
        if ([message.liked_account_ids length]>0)
        {
            item.likesId = [message.liked_account_ids componentsSeparatedByString:@","];
        }
        else
        {
            item.likesId = nil;
        }
        
        item.checkInCloud = YES;
        item.offline = self.offline;
    }

    //NSLog(@"ITEMS GENERATED: %@", items);
    return [items copy];
}

- (void)modifyItem:(CItem *)item ByMessage:(MessageEntity *)message
{
    [item setCommonValueByMessage:message];
    item.imageName = [self getTitleImageName:message];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.time];
    
    item.time =  [self.dateTimeFormat stringFromDate:date];
    
    if ([message.liked_account_ids length]>0)
    {
        item.likesId = [message.liked_account_ids componentsSeparatedByString:@","];
    }
    else
    {
        item.likesId = nil;
    }
    
    item.offline = self.offline;
    item.archived = message.archived;
    item.userData.archived=item.archived;
    item.userData.pinned=message.pinned;
}

- (void)sendInsertKey:(CItem *)item withCompleteBlock:(MongoCompletion3)block
{
    NSLock *checkLock = [[NSLock alloc] init];
    
    [checkLock lock];
    
    if ( !self.processArray )
    {
        self.processArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    BOOL needAdd = YES;
    
    for (int i = 0; i<[self.processArray count]; i++)
    {
        CItem *it = [self.processArray objectAtIndex:i];
        
        if ([it isEqual:item])
        {
            needAdd = NO;
            
            break;
        }
    }
    
    if (needAdd)
    {
        [self.processArray addObject:item];
        
        if (!item.isUpdating)
        {
            item.isUpdating = YES;
            
            NSMutableDictionary *postDic = [item dictionaryValue];
            
            [[AppDelegate sharedDelegate] sendRequestUpdateKeyNote:postDic
                                                        withUserId:[DataManager sharedInstance].currentAccount.user.user_id
                                                           topicId:item.userData.topic_id
                                                       withUseData:item withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData, id userData2, id userData3)
            {            
                item.isUpdating = NO;
                
                [self.processArray removeObject:item];
                
                if(item.topic)
                {
                    [item.topic createdNewActivity];
                }
                block(success,error,userData,userData2,userData3);
            }];
        }

    }
    [checkLock unlock];
}

- (void)sendInsertLock:(CItem *)item withCompleteBlock:(MongoCompletion3)block
{
    NSLock *checkLock = [[NSLock alloc] init];
    
    [checkLock lock];
    
    if ( !self.processArray )
    {
        self.processArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    BOOL needAdd = YES;
    
    for (int i = 0; i<[self.processArray count]; i++)
    {
        CItem *it = [self.processArray objectAtIndex:i];
        
        if ([it isEqual:item])
        {
            needAdd = NO;
            
            break;
        }
    }
    
    if (needAdd)
    {
        [self.processArray addObject:item];
        
        if (!item.isUpdating)
        {
            item.isUpdating = YES;
            
            NSMutableDictionary *postDic = [item dictionaryValue];
            
            [[AppDelegate sharedDelegate] sendRequestlockAction:postDic
                                                     withUserId:[DataManager sharedInstance].currentAccount.user.user_id
                                                        topicId:item.userData.topic_id
                                                    withUseData:nil withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData, id userData2, id userData3)
            {
                item.isUpdating = NO;
                
                [self.processArray removeObject:item];
                
                if(item.topic)
                {
                    [item.topic createdNewActivity];
                }

                block(success,error,userData,userData2,userData3);
            }];
        }
    }
    [checkLock unlock];
}

- (void)insertKnote:(CItem *)item fileInfos:(NSArray *)fileInfos
{
    NSLog(@"insertKnote fileInfos: %@", fileInfos);
    
    NSLock *checkLock = [[NSLock alloc] init];
    
    [checkLock lock];
    
    if ( !self.processArray )
    {
        self.processArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    BOOL needAdd = YES;
    
    for (int i = 0; i<[self.processArray count]; i++)
    {
        CItem *it = [self.processArray objectAtIndex:i];
        
        if ([it isEqual:item])
        {
            needAdd = NO;
            
            break;
        }
    }
    
    if (needAdd && item)
    {
        [self.processArray addObject:item];
        
        NSMutableDictionary *postDic = [item dictionaryValue];
        
        if (!item.isUpdating)
        {
            item.isUpdating = YES;
            
            NSLog(@"sending knote to meteor: order: %lld\n %@", item.userData.order, postDic);
            
            if (item.type == C_MESSAGE_TO_KNOTE)
            {
                [self directlyAddKnoteToMeteor:postDic userId:[DataManager sharedInstance].currentAccount.user.user_id item:item files:fileInfos withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
                {
                    if (item.type == C_MESSAGE_TO_KNOTE && !error)
                    {
                        [[PostingManager sharedInstance] enqueueLocalMethod:DELETE_MESSAGE_BY_ID
                                                                 parameters:@[@{@"_id"    : item.itemId}]];
                    }
                }];
            }
            else if ([item isKindOfClass:[CKnoteItem class]] && [postDic[@"_id"] hasPrefix:kKnoteIdPrefix])
            {
                [self directlyAddKnoteToMeteor:postDic
                                        userId:[DataManager sharedInstance].currentAccount.user.user_id
                                          item:item
                                         files:fileInfos
                             withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
                {
                    if (error == Nil)
                    {
                        [[PostingManager sharedInstance] enqueueLocalMethod:DELETE_MESSAGE_BY_ID
                                                                 parameters:@[@{@"_id"    : item.itemId}]];
                    }
                }];
            }
            
            // Lin - Added to
            // datetime post
            else if ([item isKindOfClass:[CDateItem class]]
                     && [postDic[@"_id"] hasPrefix:kKnoteIdPrefix])
            {
                [self directlyAddDeadlineKnoteToMeteor:postDic
                                                userId:[DataManager sharedInstance].currentAccount.user.user_id
                                                  item:item
                                                 files:fileInfos
                                     withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
                {
                    if (error == Nil)
                    {
                        [[PostingManager sharedInstance] enqueueLocalMethod:DELETE_MESSAGE_BY_ID
                                                                 parameters:@[@{@"_id"    : item.itemId}]];
                    }
                }];
            }
            // check list post
            else if ([item isKindOfClass:[CVoteItem class]] && [postDic[@"_id"] hasPrefix:kKnoteIdPrefix])
            {
                [self directlyAddVoteOrListKnoteToMeteor:postDic
                                                  userId:[DataManager sharedInstance].currentAccount.user.user_id
                                                    item:item
                                                   files:fileInfos
                                     withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
                 {
                     if (error == Nil)
                     {
                         [[PostingManager sharedInstance] enqueueLocalMethod:DELETE_MESSAGE_BY_ID
                                                                  parameters:@[@{@"_id"    : item.itemId}]];
                     }
                 }];
            }
            else if ([item isKindOfClass:[CMessageItem class]])
            {
                [self directlyAddKnoteToMeteor:postDic
                                        userId:[DataManager sharedInstance].currentAccount.user.user_id
                                          item:item
                                         files:fileInfos
                             withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData) {
                    if (!error)
                    {
                        [[PostingManager sharedInstance] enqueueLocalMethod:DELETE_MESSAGE_BY_ID
                                                                 parameters:@[@{@"_id"    : item.itemId}]];
                    }
                }];

            }
            else
            {
                [[AppDelegate sharedDelegate] sendInsertKnotes:postDic
                                      withUserId:[DataManager sharedInstance].currentAccount.user.user_id
                                     withUseData:nil
                               withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData, id userData2, id userData3)
                {
                    
                    item.itemId = userData;
                    item.isUpdating = NO;
                    item.isSending = NO;
                    item.needSend = NO;
                    item.uploadRetryCount = 3;
                    
                    if (item.type == C_DATE)
                    {
                        // Lin - Added to Check SIGABRT issue
                        
                        
                        
                        // Lin - Ended
                        
                    }
                    else if (item.type == C_VOTE)
                    {
                        // Lin - Added to Check SIGABRT issue
                        
                        NSDictionary *parameters = Nil;
                        
                        if (item.topic && item.topic.topic_id && item.itemId)
                        {
                            parameters = @{@"topicId": item.topic.topic_id,
                                           @"knoteId": item.itemId};
                        }
                        else if (item.itemId)
                        {
                            parameters = @{@"topicId": @"NULL",
                                           @"knoteId": item.itemId};
                        } else {
                            parameters = @{@"topicId": @"NULL",
                                           @"knoteId":  @"NULL"};
                        }
                        
                        [[AnalyticsManager sharedInstance] notifyVoteNoteWasAddedWithParameters:parameters];
                        
                        // Lin - Ended
                        
                    }
                    else if (item.type == C_LIST)
                    {
                        // Lin - Added to Check SIGABRT issue
                        
                        NSDictionary *parameters = Nil;
                        
                        if (item.topic && item.topic.topic_id && item.itemId)
                        {
                            parameters = @{@"topicId": item.topic.topic_id,
                                           @"knoteId": item.itemId};
                        }
                        else if (item.itemId)
                        {
                            parameters = @{@"topicId": @"NULL",
                                           @"knoteId": item.itemId};
                        } else {
                            parameters = @{@"topicId": @"NULL",
                                           @"knoteId":  @"NULL"};
                        }
                        
                        [[AnalyticsManager sharedInstance] notifyListNoteWasAddedWithParameters:parameters];
                        
                        // Lin - Ended
                    }
                    
                    item.userData.message_id = userData;
                    item.userData.need_send = NO;
                    [item.cell stopProcess];

                    [self.processArray removeObject:item];
                    
                    if(item.topic)
                    {
                        [item.topic createdNewActivity];
                    }
                    
                    // Lin - Added to avoid SIGABRT
                    
                    if (postDic[@"topic_id"])
                    {
                        [self triggerEmailNotifications:postDic[@"topic_id"]];
                    }
                    
                    // Lin - Ended
                    /****Dhruv : Causes crash, Dont see it useful.*********/

                    /*[[NSNotificationCenter defaultCenter] postNotificationName:@"new_knote_posted" object:item userInfo:nil];*/

                    //block(success,error,userData,userData2,userData3);
                }];
            }
            
            
        }
    } else {
        NSLog(@"item was already processing, didnt add it");
    }
    [checkLock unlock];
}

// Lin - Added to make working hot knote scenario

- (void)directlyAddDeadlineKnoteToMeteor:(NSDictionary *)postDic
                                  userId:(NSString *)userId
                                    item:(CItem *)item
                                   files:(NSArray *)files
                       withCompleteBlock:(MongoCompletion)block
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    MeteorClient *meteor = app.meteor;
    
    if (!userId)
    {
        userId = [DataManager sharedInstance].currentAccount.user.user_id;
    }
    
    if (meteor && meteor.connected && userId)
    {
        NSString *from = postDic[@"from"];
        if(!from) from = @"";
        
        NSString *subject = postDic[@"message_subject"];
        if(!subject) subject = @"";
        
        NSString *date = postDic[@"date"];
        if(!date) date = @"";
        
        NSString *name = postDic[@"name"];
        if(!name) name = @"";
        
        NSDate* deadline = postDic[@"deadline"];
        if (!deadline) deadline = [NSDate date];    // This is the test case.
        
        NSString* local_deadline = postDic[@"local_deadline"];
        if (!local_deadline) local_deadline = @"";
        
        NSString *message_id = [postDic[@"_id"] noPrefix:kKnoteIdPrefix];
        if(!message_id) message_id = @"";
        
        NSString *topic_id = postDic[@"topic_id"];
        if(!topic_id) topic_id = @"";
        
        
        NSString *deadline_subject = postDic[@"deadline_subject"];
        if(!deadline_subject) deadline_subject = @"";
        
        NSString *deadlineId = postDic[@"deadlineId"];
        if(!deadlineId) deadlineId = @"";
        
        NSString *section_id = postDic[@"section_id"];
        if(!section_id) section_id = @"";
        
        NSMutableArray* paramArray = [[NSMutableArray alloc] initWithCapacity:15];
        
        /*
         userId, from, to, message_subject, date, name, deadline, 
         strLocalDeadline, isMailgun, headers,topic_type,topic_id,
         deadline_subject, deadlineId, section_id = null
         */
        
        [paramArray addObject:userId];
        [paramArray addObject:from];
        [paramArray addObject:@""];
        [paramArray addObject:subject];
        [paramArray addObject:date];
        [paramArray addObject:name];
        [paramArray addObject:deadline];
        [paramArray addObject:local_deadline];
        [paramArray addObject:@NO];
        [paramArray addObject:@[]];
        [paramArray addObject:@(0)];
        [paramArray addObject:[topic_id noPrefix:kKnoteIdPrefix]];
        [paramArray addObject:deadline_subject];
        [paramArray addObject:deadlineId];
        [paramArray addObject:section_id];
        
        NSLog(@"calling add_deadline with params: %@", paramArray);
        
        [meteor callMethodName:@"add_deadline"
                    parameters:paramArray
              responseCallback:^(NSDictionary *response, NSError *error)
        {
            if (error)
            {
                NSLog(@"add_deadline error: %@", error);
                
                block(NetworkFailure, error, response);
            }
            else
            {
                NSLog(@"add_deadline response type: %@ : %@", [response class], response);
                
                NSString *knote_id = response[@"result"];
                
                if (knote_id)
                {
                    item.itemId = knote_id;
                    item.isUpdating = NO;
                    item.isSending = NO;
                    item.needSend = NO;
                    item.uploadRetryCount = 3;
                    
                    item.userData.message_id = knote_id;
                    item.userData.need_send = NO;
                    
                    [item.cell stopProcess];
                    
                    NSDictionary *parameters = Nil;
                    
                    if (item.topic && item.topic.topic_id && item.itemId)
                    {
                        parameters = @{@"topicId": item.topic.topic_id,
                                       @"knoteId": item.itemId};
                    }
                    else if (item.itemId)
                    {
                        parameters = @{@"topicId": @"NULL",
                                       @"knoteId": item.itemId};
                    } else {
                        parameters = @{@"topicId": @"NULL",
                                       @"knoteId":  @"NULL"};
                    }
                    
                    [[AnalyticsManager sharedInstance] notifyDateNoteWasAddedWithParameters:parameters];
                    
                    [self.processArray removeObject:item];
                    
                    if(item.topic)
                    {
                        [item.topic createdNewActivity];
                    }
                    
                    if (postDic[@"topic_id"])
                    {
                        [self triggerEmailNotifications:postDic[@"topic_id"]];
                    }
                    /****Dhruv : Causes crash, Dont see it useful.*********/

                    /*[[NSNotificationCenter defaultCenter] postNotificationName:@"new_knote_posted"
                                                                        object:item
                                                                      userInfo:nil];*/
                    
                    block(NetworkSucc, error, response);
                }
                else
                {
                    NSLog(@"add_deadline problem no knote id returned");
                    
                    block(NetworkFailure, error, response);
                }
            }
        }];
    }
    else
    {
        [self.processArray removeObject:item];
    }
}

- (void)directlyAddVoteOrListKnoteToMeteor:(NSDictionary *)postDic
                                    userId:(NSString *)userId
                                      item:(CItem *)item
                                     files:(NSArray *)files
                         withCompleteBlock:(MongoCompletion)block
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    MeteorClient *meteor = app.meteor;
    
    if (!userId)
    {
        userId = [DataManager sharedInstance].currentAccount.user.user_id;
    }
    
    if (meteor && meteor.connected && userId)
    {
        NSString *from = postDic[@"from"];
        if(!from) from = @"";
        
        NSString *subject = postDic[@"message_subject"];
        if(!subject) subject = @"";
        
        NSString *date = postDic[@"date"];
        if(!date) date = @"";
        
        NSString *name = postDic[@"name"];
        if(!name) name = @"";
        
        NSDate* deadline = postDic[@"deadline"];
        if (!deadline) deadline = [NSDate date];    // This is the test case.
        
        NSString* local_deadline = postDic[@"local_deadline"];
        if (!local_deadline) local_deadline = @"";
        
        NSString *message_id = [postDic[@"_id"] noPrefix:kKnoteIdPrefix];
        if(!message_id) message_id = @"";
        
        NSString *topic_id = postDic[@"topic_id"];
        if(!topic_id) topic_id = @"";
        
        
        NSString *deadline_subject = postDic[@"deadline_subject"];
        if(!deadline_subject) deadline_subject = @"";
        
        NSString *deadlineId = postDic[@"deadlineId"];
        if(!deadlineId) deadlineId = @"";
        
        NSString *section_id = postDic[@"section_id"];
        if(!section_id) section_id = @"";
        
        NSArray* optionArray = postDic[@"options"];
        if (!optionArray) optionArray = @[];
        
        NSString* title = postDic[@"title"];
        if (!title) title = @"";
        
        NSString* checklisetId = postDic[@"checklistId"];
        if (!checklisetId) checklisetId = @"";
        
        NSNumber* order = postDic[@"order"];
        if (!order) order = @1;
        
        NSString* tasktype = postDic[@"type"];
        if (!tasktype) tasktype = @"";
        
        NSMutableArray* paramArray = [[NSMutableArray alloc] initWithCapacity:15];
        
        switch (item.type) {
            case C_LIST:
            {
                /*
                 id, message_subject, name, from, to, date, options, title,
                 isMailgun, headers,topic_type,topic_id, checklistId, order,
                 task_type, section_id = null
                 */
                
                [paramArray addObject:userId];
                [paramArray addObject:subject];
                [paramArray addObject:name];
                [paramArray addObject:from];
                [paramArray addObject:@""];
                [paramArray addObject:date];
                [paramArray addObject:optionArray];
                [paramArray addObject:title];
                
                [paramArray addObject:@NO];
                [paramArray addObject:@[]];
                [paramArray addObject:@(0)];
                [paramArray addObject:[topic_id noPrefix:kKnoteIdPrefix]];
                [paramArray addObject:@""];
//                [paramArray addObject: message_id];
                [paramArray addObject:order];
                
                [paramArray addObject:tasktype];
                [paramArray addObject:section_id];
                
                [meteor callMethodName:@"add_checklist"
                            parameters:paramArray
                      responseCallback:^(NSDictionary *response, NSError *error)
                 {
                     item.isSending = NO;
                     [self.processArray removeObjectIdenticalTo: item];
                     if (error)
                     {
                         NSLog(@"add_checklist error: %@", error);
                         
                         block(NetworkFailure, error, response);
                     }
                     else
                     {
                         block(NetworkSucc, error, response);
                         NSLog(@"add_checklist response type: %@ : %@", [response class], response);
                         
                         NSString *knote_id = response[@"result"];
                         
                         if (knote_id)
                         {
                             item.itemId = knote_id;
                             item.isUpdating = NO;
                             item.isSending = NO;
                             item.needSend = NO;
                             item.uploadRetryCount = 3;
                             
                             item.userData.message_id = knote_id;
                             item.userData.need_send = NO;
                             [AppDelegate saveContext];
                             
                             [item.cell stopProcess];
                             
                             NSDictionary *parameters = Nil;
                             
                             if (item.topic && item.topic.topic_id && item.itemId)
                             {
                                 parameters = @{@"topicId": item.topic.topic_id,
                                                @"knoteId": item.itemId};
                             }
                             else if (item.itemId)
                             {
                                 parameters = @{@"topicId": @"NULL",
                                                @"knoteId": item.itemId};
                             } else {
                                 parameters = @{@"topicId": @"NULL",
                                                @"knoteId":  @"NULL"};
                             }
                             
                             [[AnalyticsManager sharedInstance] notifyListNoteWasAddedWithParameters:parameters];
                             
                             if(item.topic)
                             {
                                 [item.topic createdNewActivity];
                             }
                             
                             if (postDic[@"topic_id"])
                             {
                                 [self triggerEmailNotifications:postDic[@"topic_id"]];
                             }
                             /****Dhruv : Causes crash, Dont see it useful.*********/

                             /*[[NSNotificationCenter defaultCenter] postNotificationName:@"new_knote_posted"
                                                                                 object:item
                                                                               userInfo:nil];*/
                         }
                         else
                         {
                             NSLog(@"add_checklist problem no knote id returned");
                             
                             block(NetworkFailure, error, response);
                         }
                     }
                 }];
            }
                break;
                
            case C_VOTE:
            {
                /*
                 id, message_subject, name, from, to, date, pollOptions, title,
                 isMailgun, headers,topic_type,topic_id, pollId, 
                 order, section_id = null
                 */
                
                [paramArray addObject:userId];
                [paramArray addObject:subject];
                [paramArray addObject:name];
                [paramArray addObject:from];
                [paramArray addObject:@""];
                [paramArray addObject:date];
                [paramArray addObject:optionArray];
                [paramArray addObject:title];
                
                [paramArray addObject:@NO];
                [paramArray addObject:@[]];
                [paramArray addObject:@(0)];
                [paramArray addObject:[topic_id noPrefix:kKnoteIdPrefix]];
                [paramArray addObject:@""];
                [paramArray addObject:order];
                
                //[paramArray addObject:tasktype];
                [paramArray addObject:section_id];
                
                [meteor callMethodName:@"add_poll"
                            parameters:paramArray
                      responseCallback:^(NSDictionary *response, NSError *error)
                 {
                     if (error)
                     {
                         NSLog(@"add_poll error: %@", error);
                         
                         block(NetworkFailure, error, response);
                     }
                     else
                     {
                         NSLog(@"add_poll response type: %@ : %@", [response class], response);
                         
                         NSString *knote_id = response[@"result"];
                         
                         if (knote_id)
                         {
                             item.itemId = knote_id;
                             item.isUpdating = NO;
                             item.isSending = NO;
                             item.needSend = NO;
                             item.uploadRetryCount = 3;
                             
                             item.userData.message_id = knote_id;
                             item.userData.need_send = NO;
                             
                             [item.cell stopProcess];
                             
                             NSDictionary *parameters = Nil;
                             
                             if (item.topic && item.topic.topic_id && item.itemId)
                             {
                                 parameters = @{@"topicId": item.topic.topic_id,
                                                @"knoteId": item.itemId};
                             }
                             else if (item.itemId)
                             {
                                 parameters = @{@"topicId": @"NULL",
                                                @"knoteId": item.itemId};
                             } else {
                                 parameters = @{@"topicId": @"NULL",
                                                @"knoteId":  @"NULL"};
                             }
                             
                             [[AnalyticsManager sharedInstance] notifyVoteNoteWasAddedWithParameters:parameters];
                             
                             [self.processArray removeObject:item];
                             
                             if(item.topic)
                             {
                                 [item.topic createdNewActivity];
                             }
                             
                             if (postDic[@"topic_id"])
                             {
                                 [self triggerEmailNotifications:postDic[@"topic_id"]];
                             }
                             /****Dhruv : Causes crash, Dont see it useful.*********/

                            /* [[NSNotificationCenter defaultCenter] postNotificationName:@"new_knote_posted"
                                                                                 object:item
                                                                               userInfo:nil];*/
                             
                             block(NetworkSucc, error, response);
                         }
                         else
                         {
                             NSLog(@"add_poll problem no knote id returned");
                             
                             block(NetworkFailure, error, response);
                         }
                     }
                 }];

            }
                break;
                
            default:
                break;
        }
        
        NSLog(@"calling add_deadline with params: %@", paramArray);
        
        
        
        
    }
    else
    {
        [self.processArray removeObject:item];
    }
}

// Lin - Ended

- (void)directlyAddKnoteToMeteor:(NSDictionary *)postDic userId:(NSString *)userId item:(CItem *)item files:(NSArray *)files withCompleteBlock:(MongoCompletion)block
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    MeteorClient *meteor = app.meteor;
    
    if (!userId) {
        userId = [DataManager sharedInstance].currentAccount.user.user_id;
    }
    
    if (meteor && meteor.connected && userId) {
        
        NSString *message_id = [postDic[@"_id"] noPrefix:kKnoteIdPrefix];
        if((!message_id) || ([message_id isEqual:NULL]) ) message_id = @"";

        NSString *topic_id = postDic[@"topic_id"];
        if((!topic_id) || ([topic_id isEqual:NULL]) ) topic_id = @"";

        NSString *subject = postDic[@"message_subject"];
        if((!subject) || ([subject isEqual:NULL]) ) subject = @"";
        
        NSString *body = postDic[@"htmlBody"];
        if((!body) || ([body isEqual:NULL]) ) body = @"";

        NSString *name = postDic[@"name"];
        if((!name) || ([name isEqual:NULL]) ) name = @"";

        NSString *from = postDic[@"from"];
        if((!from) || ([from isEqual:NULL]) ) from = @"";

        NSArray  *file_ids = postDic[@"file_ids"];
        if((!file_ids) || ([file_ids isEqual:NULL]) ) file_ids = @[];

        NSString *date = postDic[@"date"];
        if((!date) || ([date isEqual:NULL]) ) date = @"";
        
        NSString *title = postDic[@"title"];
        if((!title) || ([title isEqual:NULL]) ) title = @"";

        NSNumber *order = postDic[@"order"];
        if((!order) || ([order isEqual:NULL]) ) order = @(1);

        NSArray *usertags = postDic[@"usertags"];
        if((!usertags) || ([usertags isEqual:NULL]) ) usertags = @[];
        
        NSDictionary *requiredParams = @{
             @"subject":subject,
             @"body":body,
             @"topic_id":[topic_id noPrefix:kKnoteIdPrefix],
             @"userId":userId,
             @"name":name,
             @"from":from,
             @"isMailgun":@NO
        };
        
        NSDictionary *optionalParams = @{
             @"file_ids":file_ids,
             @"_id":message_id,
             @"date":date,
             @"title":title,
             @"order":order
             };
        
        NSArray *params = @[requiredParams, optionalParams];

        NSLog(@"calling add_knote with params: %@", params);
        
        [meteor callMethodName:@"add_knote" parameters:params responseCallback:^(NSDictionary *response, NSError *error) {
                  
                  item.isSending = NO;
                  [self.processArray removeObject:item];
                  block(NetworkSucc,error,response);
                  if (error) {
                      NSLog(@"Knotable: add_knote to topic with id %@ error: %@", topic_id, error);
                      
//                      Dhruv added this, not sure if I should comment it but I think it conflicts with my work on syncing. Let's try -- Agus.
//                      if ([error.description containsString:@"Topic not exist with"])
//                      {
//                          
//                         TopicsEntity *new = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:topic_id];
//                          new.isSending=@(NO);
//                          TopicInfo *info = [[TopicInfo alloc] initWithTopicEntity:new];
//                          [info recordSelfToServer];
//                      }

                  } else {
                      NSLog(@"add_knote response type: %@ : %@", [response class], response);
                      
                      NSString *knote_id = @"";
                      
                      if (response[@"result"])
                      {
                          knote_id = response[@"result"];
                      }
                      
                      if (knote_id)
                      {
                          item.itemId = knote_id;
                          item.isUpdating = NO;
                          item.isSending = NO;
                          item.needSend = NO;
                          item.uploadRetryCount = 3;
                          
                          item.userData.message_id = knote_id;
                          item.userData.need_send = NO;
                          
                          [AppDelegate saveContext];
                          
                          [item.cell stopProcess];
                          /****Dhruv : Causes crash, Dont see it useful.*********/

                         /* [[NSNotificationCenter defaultCenter] postNotificationName:@"new_knote_posted"
                                                                              object:item
                                                                            userInfo:nil];*/
                          
                          NSDictionary *parameters = @{@"topicId": topic_id, @"knoteId": knote_id};
                          
                          [[AnalyticsManager sharedInstance] notifyKNoteWasAddedWithParameters:parameters];
                          
                          NSLog(@"files: %@", files);

                          
                      }
                      else
                      {
                          NSLog(@"add_knote problem no knote id returned");
                      }
                      
                      if (files && files.count > 0)
                      {
                          item.files = files;
                          
                          for (FileInfo *fInfo in files)
                          {
                              //item.cell = self.cell;
                              if (!fInfo.file)
                              {
                                  fInfo.file = [FileEntity MR_findFirstByAttribute:@"file_id" withValue:fInfo.imageId];
                              }
                              
                              fInfo.parentItem = item;
                              //fInfo.parentCell = self.cell;
                              NSLog(@"calling recordSelfToServer after add_knote");
                              
//                              [fInfo recordSelfToServer];
                              
                              if ([fInfo.file.sendFlag  isEqual: @(SendSuc)])
                              {
                                  // No action
                              }
                              else
                              {
                                  [fInfo recordSelfToServer];
                              }
                          }
                      }
                  }
              }];


    } else {
        [self.processArray removeObject:item];
    }
}

- (void)triggerEmailNotifications:(NSString *)topic_id
{
    NSLog(@". topic: %@", topic_id);
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    MeteorClient *meteor = app.meteor;
    
    if (meteor && meteor.connected)
    {
        [meteor callMethodName:@"process_topic_for_email_notification"
                    parameters:@[topic_id]
              responseCallback:^(NSDictionary *response, NSError *error)
        {
            
            NSLog(@"triggerActivityTemplate error: %@ response: \n%@", error, response);
                        
        }];
    }
}

- (void)updateKeynotesFileIds:(CItem *)item  withCompleteBlock:(MongoCompletion)block
{
    NSLog(@"Item: %@", item);
    
    NSLock *checkLock = [[NSLock alloc] init];
    
    [checkLock lock];
    
    if ( !self.processArray )
    {
        self.processArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    BOOL needAdd = YES;
    
    for (int i = 0; i<[self.processArray count]; i++)
    {
        CItem *it = [self.processArray objectAtIndex:i];
        
        if ([it isEqual:item])
        {
            needAdd = NO;
            break;
        }
    }
    
    if (!needAdd)
    {
        [self.processArray addObject:item];
    }
    
    for (FileInfo *fInfo in item.files)
    {
        if (!fInfo.upLoaded)
        {
            if (![item.uploadCache containsObject:fInfo.imageId])
            {
                [item.uploadCache addObject:fInfo.imageId];
            }
        }
    }
    
    NSLog(@"uploadCache: %@", item.uploadCache);

    if (item.uploadCache && [item.uploadCache count]>0 && item.itemId && [item.itemId length]>0)
    {
        if (item.isUpdating != YES)
        {
            NSMutableDictionary *postDic = [[NSMutableDictionary alloc] init];
            
            postDic[@"_id"] = item.itemId;
            postDic[@"file_ids"] = [item.uploadCache copy];
            item.isUpdating = YES;
            
            NSMutableString *htmlBody = [item.userData.documentHTML mutableCopy];
            
            BOOL isChangeContent = NO;
            
            for (FileInfo *fInfo in item.files)
            {
                if (fInfo.file.thumbnail_url && [fInfo.file.thumbnail_url length]>0)
                {
                    NSRange range = [htmlBody rangeOfString:fInfo.file.full_url];
                    
                    if (range.length>0)
                    {
                        isChangeContent = YES;
                        
                        [htmlBody stringByReplacingOccurrencesOfString:fInfo.file.full_url withString:fInfo.file.thumbnail_url];
                    }
                }
            }
            
            if (isChangeContent && htmlBody)
            {
                postDic[@"htmlBody"] = htmlBody;
            }
            
            if ([DataManager sharedInstance].currentAccount.account_id)
            {
                [[AppDelegate sharedDelegate] sendUpdateKnotesFileIds:postDic
                                                        withAccountId:[DataManager sharedInstance].currentAccount.account_id
                                                          withUseData:nil
                                                    withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
                {
                    if (success == NetworkSucc)
                    {
                        MessageEntity *message = item.userData;
                        
                        if(item.topic)
                        {
                            [item.topic createdNewActivity];
                        }
                        
                        NSArray *files = [message.file_ids componentsSeparatedByString:@","];
                        
                        if ([files count] == [item.uploadCache count])
                        {
                            message.file_ids = [item.uploadCache componentsJoinedByString:@","];
                            [AppDelegate saveContext];
                         
                            [self.processArray removeObject:item];
                        }
                        else
                        {
                            NSMutableArray *checkArray = postDic[@"file_ids"];
                            NSMutableArray *tempArray = [[NSMutableArray alloc] initWithCapacity:3];
                            
                            for (NSString *file_id in files)
                            {
                                NSString *addStr = file_id;
                                
                                for (NSString *str in checkArray)
                                {
                                    if ([[file_id noPrefix:kKnoteIdPrefix] isEqualToString:str])
                                    {
                                        addStr = str;
                                    }
                                }
                                
                                [tempArray addObject:addStr];
                            }
                            
                            if ([tempArray count] > 0)
                            {
                                message.file_ids = [tempArray componentsJoinedByString:@","];
                            }
                            else
                            {
                                message.file_ids = @"";
                            }
                        }
                    }
                    
                    if (block)
                    {
                        item.isUpdating = NO;
                        block(success,error,userData);
                    }
                }];
            }
            else
            {
                if (block)
                {
                    item.isUpdating = NO;
                    block(NetworkFailure,nil,nil);
                }
            }
            
        }
    }
    

    [checkLock unlock];
}

- (NSString *)getDateTimeIndicate:(NSTimeInterval)realInterval
{

    NSDate *datecurrent = [NSDate date];
    if (realInterval > kKnoteTimeIntervalMaxValue)
    {
        realInterval = (NSTimeInterval)(realInterval/1000.0);
    }
    NSTimeInterval timeInterval = [datecurrent timeIntervalSince1970]-realInterval;
    NSString *passedMessage = nil;
    NSTimeInterval year = timeInterval/(60*60*24*365);
    NSTimeInterval month = timeInterval/(60*60*24*30);
    NSTimeInterval day = timeInterval/(60*60*24);
    NSTimeInterval hour = timeInterval/(60*60);
    NSTimeInterval minute = timeInterval/60;
    NSTimeInterval second = timeInterval/1;
    if(timeInterval > 0) {
        if(year>=1) {
            if(year>=2) {
                passedMessage = [NSString stringWithFormat:@"%ld|years passed",(long)year];
            } else {
                passedMessage = [NSString stringWithFormat:@"%ld|year passed",(long)year];
            }
        }else if(month>=1 && month<12) {
            if(month>=2) {
                passedMessage = [NSString stringWithFormat:@"%ld months ago",(long)month];
            } else {
                passedMessage = [NSString stringWithFormat:@"%ld month ago",(long)month];
            }
        }else if(day>=1 && day<31) {
            if(day>=2) {
                passedMessage = [NSString stringWithFormat:@"%ld days ago",(long)day];
            } else {
                passedMessage = [NSString stringWithFormat:@"%ld day ago",(long)day];
            }
        }else if(hour>=1 && hour<24) {
            if(hour>=2) {
                passedMessage = [NSString stringWithFormat:@"%ld hours ago",(long)hour];
            } else {
                passedMessage = [NSString stringWithFormat:@"%ld hour ago",(long)hour];
            }
        }else if(minute>=1 && minute<60) {
            if(minute>=2) {
                passedMessage = [NSString stringWithFormat:@"%ld minutes ago",(long)minute];
            } else {
                passedMessage = [NSString stringWithFormat:@"%ld minute ago",(long)minute];
            }
        } else {
            passedMessage = [NSString stringWithFormat:@"Just now"];
        }
    } else {
        timeInterval = -timeInterval;
        year = -year;
        month = -month;
        day = -day;
        hour = -hour;
        minute = -minute;
        second = -second;
        if(year>=1) {
            if(year>=2) {
                passedMessage = [NSString stringWithFormat:@"%ld|years remaining",(long)year];
            } else {
                passedMessage = [NSString stringWithFormat:@"%ld|year remaining",(long)year];
            }
        }else if(month>=1 && month<12) {
            if(month>=2) {
                passedMessage = [NSString stringWithFormat:@"%ld|months remaining",(long)month];
            } else {
                passedMessage = [NSString stringWithFormat:@"%ld|month remaining",(long)month];
            }
        }else if(day>=1 && day<31) {
            if(day>=2) {
                passedMessage = [NSString stringWithFormat:@"%ld|days remaining",(long)day];
            } else {
                passedMessage = [NSString stringWithFormat:@"%ld|day remaining",(long)day];
            }
        }else if(hour>=1 && hour<24) {
            if(hour>=2) {
                passedMessage = [NSString stringWithFormat:@"%ld|hours remaining",(long)hour];
            } else {
                passedMessage = [NSString stringWithFormat:@"%ld|hour remaining",(long)hour];
            }
        }else if(minute>=1 && minute<60) {
            if(minute>=2) {
                passedMessage = [NSString stringWithFormat:@"%ld|minutes remaining",(long)minute];
            } else {
                passedMessage = [NSString stringWithFormat:@"%ld|minute remaining",(long)minute];
            }
        } else {
            passedMessage = [NSString stringWithFormat:@"Just now"];
        }
    }
    
    return passedMessage;
}

- (void)addComment:(NSString *)commentBody toNoteWithId:(NSString *)noteId inTopicWithId:(NSString *)topicId {
    
    AppDelegate *app     = [AppDelegate sharedDelegate];
    
    MeteorClient *meteor = app.meteor;
    
    NSString *userId     = [DataManager sharedInstance].currentAccount.user.user_id;
    
    if (meteor && meteor.connected && userId)
    {
        NSArray *requestParameters = @[noteId, commentBody];
        
        [meteor callMethodName:@"add_reply_message"
                    parameters:requestParameters
              responseCallback:^(NSDictionary *response, NSError *error)
        {
            if (error)
            {
                NSLog(@"Error while adding comment %@", error.userInfo.description );
            }
            else
            {
                NSDictionary *parameters = @{ @"topicId":   topicId,
                                              @"noteId":    noteId };
                
                [[AnalyticsManager sharedInstance] notifyCommentAddedOnKnoteWithParameters:parameters];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"knotes_changed"
                                                                    object:self
                                                                  userInfo:nil];
            }
        }];
    }
}

- (void)changeNotesWithTopicId:(NSString *)topicId toTopicId:(NSString *)newTopicId {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(topic_id LIKE %@)", topicId];
    NSArray *notesWithOldTopicId = [MessageEntity MR_findAllWithPredicate:predicate];
    for (MessageEntity *noteEntity in notesWithOldTopicId) {
        NSLog(@"Knotable: notesWithOldTopicId %@ and new topic id %@ has title %@ and body %@", topicId, newTopicId, noteEntity.title, noteEntity.body);
        noteEntity.topic_id = newTopicId;
        noteEntity.need_send = YES;
    }
    [AppDelegate saveContext];
    
}

@end
