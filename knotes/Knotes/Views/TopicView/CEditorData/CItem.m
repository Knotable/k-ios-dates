//
//  CItem.m
//  RevealControllerProject
//
//  Created by backup on 13-10-17.
//
//

#import "CItem.h"

#import "FileInfo.h"
#import "AppDelegate.h"
#import "CReplysItem.h"
#import "SVProgressHUD.h"

#import "FileEntity.h"
#import "UserEntity.h"
#import "AccountEntity.h"
#import "ContactsEntity.h"

#import "S3Manager.h"
#import "DataManager.h"
#import "ThreadItemManager.h"

#import "NSString+Knotes.h"

#if NEW_DESIGN
#define kMaximumNumberOfLinesInNotExpandedMode 4
#else
#define kMaximumNumberOfLinesInNotExpandedMode 3
#endif
@implementation CItem

@synthesize checkInCloud = _checkInCloud;

- (id)init {
    self = [super init];
    if (self) {
        self.maximumNumberOfLinesInNotExpandedMode = kMaximumNumberOfLinesInNotExpandedMode;
    }
    return self;
}

- (id)initWithMessage:(MessageEntity *)message
{
    self = [super init];
    if (self) {
        [self setCommonValueByMessage:message];
    }
    return self;
}

- (BOOL) isEqual:(id)object
{
    if ([object isKindOfClass: [self class]])
    {
        CItem* item = object;
        return [self.itemId isEqual: item.itemId];
    }
    return NO;
}

- (NSComparisonResult) compare:(id) item
{
    NSComparisonResult ret = NSOrderedDescending;
    CItem* item2 = item;
    
    // newest is first (timestamp is bigger ==> is asceding)
    if (self.order < item2.order)
    {
        ret = NSOrderedAscending;
    }
    else if (self.order == item2.order)
    {
        ret = NSOrderedSame;
        
        if (self.timeStamp > item2.timeStamp)
            ret = NSOrderedAscending;
        else if (self.timeStamp == item2.timeStamp)
            ret = NSOrderedSame;
        else
            ret = NSOrderedDescending;
    }
    else
        ret = NSOrderedDescending;
    return ret;
}

-(void)setItemId:(NSString *)itemId
{
    _itemId = itemId;
    if (itemId==nil) {
        NSLog(@"check");
    }
}

- (NSInteger) numberOfLikes
{
    return self.likesId.count;
}

-(NSArray *)getFileEntitiesFromSelfMessage
{
    NSMutableArray * arrayToReturn = [[NSMutableArray alloc] init];
    
    if ([self.userData.file_ids length]>0)
    {
        NSArray *files = [self.userData.file_ids componentsSeparatedByString:@","];
        
        for (NSString *name in files)
        {
            NSFetchRequest *request = [FileEntity MR_requestFirstByAttribute:@"file_id" withValue:[name noPrefix:kKnoteIdPrefix]];
            
            FileEntity *file = [FileEntity MR_executeFetchRequestAndReturnFirstObject:request
                                                                            inContext:[[MagicalRecordStack defaultStack] context]];
            
            if (file)
            {
                if ([file isFault])
                {
                    [file MR_refresh];
                }
                
                [arrayToReturn addObject:file];
            }
            
        }
    }
    
    return [arrayToReturn copy];
}


- (void)setCommonValueByMessage:(MessageEntity *)message
{
    if (message) {
        self.type = message.type;
    }
    if (!self.subReplys) {
        self.subReplys = [NSMutableArray new];
    }
    self.isReplysExpand = NO;
#if NEW_DESIGN
#else
    self.isReplysExpand = NO;
#endif
    self.needShowMoreButton = NO;
    self.expandedMode = NO;
    
    self.maxHeight = [[UIScreen mainScreen] bounds].size.height/2;
    self.checkInCloud = NO;
    self.isLocked = NO;
    self.isSending = NO;
    self.uploadRetryCount = 3;
    
    if (!message) {
        return;
    }
    
    self.title = message.title;
    self.body = message.body;
    self.highlights = message.highlights;
    self.name = message.name;
    if (!self.name || [self.name length]<=0) {
        if (message.account_id) {
            ContactsEntity *contact = [ContactsEntity MR_findFirstByAttribute:@"account_id" withValue:message.account_id];
            if (contact&&![contact isFault]) {
                self.name = contact.name;
                message.name = contact.name;
            }
        }
    }
    if(self.name){
        NSRegularExpression *regularExpression = [NSRegularExpression regularExpressionWithPattern:@"<[^>]*>|\n" options:0 error:nil];
        self.name = [regularExpression stringByReplacingMatchesInString:self.name options:NSMatchingReportProgress range:NSMakeRange(0, self.name.length) withTemplate:@""];
    }
    
    self.order = message.order;
    
    self.itemId = message.message_id;
    
    self.timeStamp = message.time;
    
    self.archived = message.archived;
    
    self.userData = message;
    
    self.needSend = message.need_send;
    
    if (!self.uploadCache)
    {
        self.uploadCache = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    [self.uploadCache removeAllObjects];
    
    if ([message.file_ids length]>0)
    {
        NSArray *files = [message.file_ids componentsSeparatedByString:@","];
        NSMutableArray *files_array = [[NSMutableArray alloc] initWithCapacity:3];
        
        for (NSString *name in files)
        {
            if (name != Nil
                && [name length] > 0)
            {
                FileInfo *fInfo = [[S3Manager sharedInstance] findFileInfoById:name];
                
                if (!fInfo)
                {
                    fInfo = [[FileInfo alloc] init];
                    
                    fInfo.imageId = name;
                    
                    NSString *imgId = [fInfo.imageId noPrefix:kKnoteIdPrefix];
                    
                    NSFetchRequest *request = [FileEntity MR_requestFirstByAttribute:@"file_id" withValue:imgId];
                    
                    FileEntity *file = [FileEntity MR_executeFetchRequestAndReturnFirstObject:request
                                                                                    inContext:[[MagicalRecordStack defaultStack] context]];
                    
                    if (file)
                    {
                        if ([file isFault])
                        {
                            [file MR_refresh];
                        }
                        
                        [fInfo setCommonValueByFile:file];
                    }
                    
                    NSLog(@"query result: %@", file);
                }
                
                [files_array addObject:fInfo];
                
                if ([fInfo.imageId hasPrefix:kKnoteIdPrefix])
                {
                    [self.uploadCache addObject:fInfo.imageId];
                }
            }
        }
        
        self.files= [files_array copy];
        
        NSLog(@"self.files = %@", self.files);
    }
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    
    [format setDateFormat:kDateFormat];
    
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:message.time];
    
    self.time =  [format stringFromDate:date];
    
    self.opType = C_OP_NONE;
}
- (NSMutableDictionary *)dictionaryValue
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (self.userData.message_id) {
        dict[@"_id"] = self.userData.message_id;
    }
    if (self.userData.topic_id) {
        dict[@"topic_id"] = self.userData.topic_id;
    }
    dict[@"from"] =[ContactsEntity MR_findFirstByAttribute:@"account_id" withValue:[DataManager sharedInstance].currentAccount.account_id].email.length>0?[ContactsEntity MR_findFirstByAttribute:@"account_id" withValue:[DataManager sharedInstance].currentAccount.account_id].email:[[self.userData.email componentsSeparatedByString:@","]lastObject];
    dict[@"name"] = self.userData.name;
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:kDateFormat1];
    dict[@"date"] = [format stringFromDate:self.userData.created_time];
    
    dict[@"timestamp"] = [NSNumber numberWithDouble:[self.userData.created_time timeIntervalSince1970]*1000.0];
    dict[@"status"] = @"ready";
    dict[@"topic_type"] = @"0";
    dict[@"order"] = @(self.userData.order);
    dict[@"archived"]=@(self.userData.archived);

    if (self.topic) {
        dict[@"message_subject"] = self.topic.topic;
    }
    
    return dict;
}

-(int) getHeight
{
    return 0;
}

-(int) getCellHeight
{
#if !NEW_DESIGN
    if ([[self likesId] count]>0) {
        return self.height+kDefalutInfoBarH;
    }
#endif
    return self.height;
}

-(BOOL) shouldShowHeader
{
    return YES;
}

- (void) reCalHeight
{
    
}

- (void) checkToUpdataSelf
{
    return;
}

- (void) checkToUpdataFiles
{
    NSLog(@"CItem checkToUpdataFiles");
    
    [self.cell showProcess];
    
    [[ThreadItemManager sharedInstance] updateKeynotesFileIds:self withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData) {
        switch (success) {
            case NetworkSucc:
            {
                self.uploadRetryCount = 3;
                [self.cell stopProcess];
            }
                break;
            case NetworkErr:
            case NetworkTimeOut:
            case NetworkFailure:
            {
                if (self.uploadRetryCount>0) {
                    self.uploadRetryCount--;
                    [self checkToUpdataFiles];
                } else {
                    [self.cell showInfo:InfoWarrning];
                }
            }
                break;
            default:
                break;
        }
        [self.cell stopProcess];
        
    }];
}

- (void) checkToLike
{
    NSLog(@"CItem checkToLike");
    
    if (self.type == C_DATE)
    {
        return;
    }
    
    if ( self.isSending == NO)
    {
        self.needUp = YES;
        self.isSending = YES;
        
        MessageEntity *message = self.userData ;
        
        if (message)
        {
            NSMutableArray *accountIds = nil;
            
            if ([message.liked_account_ids length]>0)
            {
                accountIds = [[message.liked_account_ids componentsSeparatedByString:@","] mutableCopy];
            }
            
            NSString * myAcountId= [[DataManager sharedInstance].currentAccount.user.contact contact_id];
            
            if ( myAcountId== nil || [myAcountId length]<=0)
            {
                NSLog(@"aborting, dont have myAcountId");
                
                return;
            }
            
            if (!accountIds)
            {
                accountIds = [[NSMutableArray alloc] initWithCapacity:3];
                [accountIds addObject:myAcountId];
            }
            else if ([accountIds count]>0)
            {
                if ([accountIds containsObject:myAcountId])
                {
                    //Unlike knote since its already liked, remove like
                    self.needUp = NO;
                    [accountIds removeObject:myAcountId];
                }
                else {
                    //Liking knote, add like
                    [accountIds addObject:myAcountId];
                }
            }
            
            NSString *knote_id = self.itemId;
            if (!knote_id) {
                NSLog(@"aborting, dont have knote_id");
                return;
            }
            self.likeIdsCaches = accountIds;
            NSLog(@"setting likeIdsCaches: %@", self.likeIdsCaches);
            
            [self.cell showProcess];
            
            [[AppDelegate sharedDelegate] sendRequestAddLike:self.likeIdsCaches
                                      itemType:self.type
                                       knoteId:self.itemId
                             withCompleteBlock:^(WM_NetworkStatus success,NSError *error, id userData){
                                 
                self.isSending = NO;
                                 
                [self.cell stopProcess];
                
                if (success == NetworkSucc)
                {
                    MessageEntity *message = self.userData;
                    
                    if (message)
                    {
                        message.liked_account_ids = [self.likeIdsCaches componentsJoinedByString:@","];
                        
                        self.likesId = [self.likeIdsCaches copy];
#if !NEW_DESIGN
                        [self reCalHeight];
#endif
                    }
                    
                    self.opType = C_OP_LIKE;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:OperatorThreadItemNotification object:self];
                    
                }
                else
                {
                    NSLog(@"mongo like operation not successful");
                }
            }];
        }
    }
}
- (void) checkToPin:(BOOL)pinned withNewOrder:(int64_t) oroder;
{
    NSLog(@"CItem checkToLike");
    
    if (self.type == C_DATE)
    {
        return;
    }
    
    if ( self.isSending == NO)
    {
        self.needUp = YES;
        
        self.isSending = YES;
        
        MessageEntity *message = self.userData ;
        
        if (message)
        {
            NSString *knote_id = self.itemId;
            
            if (!knote_id)
            {
                NSLog(@"aborting, dont have knote_id");
                
                return;
            }
            
            [self.cell showProcess];
            
            [[AppDelegate sharedDelegate] sendRequestAddPin:pinned
                                                   itemType:self.type
                                                    knoteId:self.itemId
                                                      order:oroder
                                          withCompleteBlock:^(WM_NetworkStatus success,NSError *error, id userData)
            {
                self.isSending = NO;
                
                [self.cell stopProcess];
                
                if (success == NetworkSucc)
                {
                    MessageEntity *message = self.userData;
                    
                    if (message)
                    {
                        self.isPinned=pinned;
                    }
                    
                    self.opType = C_OP_PINNED;

                    [[NSNotificationCenter defaultCenter] postNotificationName:OperatorThreadItemNotification object:self];
                    
                }
                else
                {
                    NSLog(@"mongo like operation not successful");
                }
            }];
        }
    }
}

- (void) checkToDelete
{
    NSLog(@"checkToDelete");
    
    if ( self.isSending == NO)
    {
        self.isSending = YES;
        
        /*if ([ThreadItemManager sharedInstance].offline)
         {
         return;
         }*/
        
        if (self.type == C_KEYKNOTE)
        {
            [[AppDelegate sharedDelegate] sendRequestDeleteKeyNote:self.itemId
                                                           topicId:self.userData.topic_id
                                                 withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
             {
                 self.isSending = NO;
                 
                 [self.cell stopProcess];
                 
                 if (success == NetworkSucc)
                 {
                     [[ThreadItemManager sharedInstance] modifyItem:self ByMessage:nil];
                     
                     self.checkInCloud = YES;
                     self.opType = C_OP_DELETE;
                     
                     [[NSNotificationCenter defaultCenter] postNotificationName:OperatorThreadItemNotification object:self];
                 }
                 else
                 {
                     [SVProgressHUD showErrorWithStatus:@"Delete failed, please try again later." duration:3];
                 }
             }];
        }
        else if (self.type == C_LOCK)
        {
            NSString *cname = @"knotes";
            NSString *typeStr = @"unlock";
            NSTimeInterval timeStamp = [[NSDate date] timeIntervalSince1970]*1000;
            
            NSMutableDictionary *postDic = [[NSMutableDictionary alloc] initWithCapacity:3];
            [postDic setObject:[NSArray array] forKey:@"liked_account_ids"];
            [postDic setObject:[NSNumber numberWithInt:0] forKey:@"likes_count"];
            //is mail gun
            [postDic setObject:@"" forKey:@"htmlBody"];
            NSDateFormatter *format = [[NSDateFormatter alloc] init];
            [format setDateFormat:kDateFormat1];
            [postDic setObject:[format stringFromDate:[NSDate date]] forKey:@"date"];
            [postDic setObject:@"ready" forKey:@"status"];
            [postDic setObject:cname forKey:@"cname"];
            [postDic setObject:[[DataManager sharedInstance].currentAccount.user email] forKey:@"from"];
            [postDic setObject:[[DataManager sharedInstance].currentAccount.user name] forKey:@"name"];
            
            [postDic setObject:[NSNumber numberWithLongLong:timeStamp]forKey:@"timestamp"];
            [postDic setObject:self.userData.topic_id forKey:@"topic_id"];
            [postDic setObject:[NSNumber numberWithInt:self.topic.topic_type] forKey:@"topic_type"];
            [postDic setObject:typeStr forKey:@"type"];
            
            [[AppDelegate sharedDelegate] sendRequestUnlockAction:postDic
                                                       withUserId:[[DataManager sharedInstance].currentAccount.user user_id]
                                                          topicId:self.topic.topic_id
                                                withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
             {
                 [self.cell stopProcess];
                 
                 self.isSending = NO;
                 
                 if (success == NetworkSucc)
                 {
                     self.opType = C_OP_DELETE;
                     
                     [[NSNotificationCenter defaultCenter] postNotificationName:OperatorThreadItemNotification object:self];
                 }
                 else
                 {
                     [SVProgressHUD showErrorWithStatus:@"Unlock failed, please try again later." duration:3];
                 }
             }];
        }
        /**********Deleting comment feature is removed.**************/
        /*        else if (self.type == C_REPlYS)
         {
         DLog(@"%@", self);
         
         NSString*   knoteID = Nil;
         NSString*   commentID = Nil;
         
         if (((CReplysItem*)self).parentItem)
         {
         if (((CReplysItem*)self).parentItem.itemId)
         {
         knoteID = ((CReplysItem*)self).parentItem.itemId;
         }
         }
         
         if ([((CReplysItem*)self).content objectForKey:@"replyId"])
         {
         commentID = [((CReplysItem*)self).content objectForKey:@"replyId"];
         
         DLog(@"Replyer : %@", commentID);
         }
         
         [[AppDelegate sharedDelegate] sendRequestDeleteCommentFrom:knoteID
         withCommentID:commentID
         withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData) {
         
         DLog(@"%@", @"Check respons");
         
         [self.cell stopProcess];
         
         self.isSending = NO;
         
         if (success == NetworkSucc)
         {
         self.archived = YES;
         
         self.opType = C_OP_DELETE;
         
         CItem* notificationBody = Nil;
         
         notificationBody.archived = YES;
         notificationBody.opType = C_OP_DELETE;
         
         }
         else
         {
         [SVProgressHUD showErrorWithStatus:@"Delete failed, please try again later." duration:3];
         }
         
         }];
         }*/
        else
        {
            self.userData.need_send=YES;
            self.needSend=YES;
            
            if ([ReachabilityManager sharedInstance].currentNetStatus == NotReachable)
            {
                self.archived=!self.archived;
                self.userData.archived=self.archived;
                [AppDelegate saveContext];
            }
            else
            {
                if (self.archived==NO)
                {
                    [self archiveItem];
                }
                else
                {
                    [self UnarchiveItem];
                }
            }
        }
    }
}
-(void)archiveItem
{
    
    [[AppDelegate sharedDelegate] sendRequestArchiveKnote:self.itemId Archived:self.archived isMessage:self.type==C_MESSAGE withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData) {
        
        [self.cell stopProcess];
        
        self.isSending = NO;
        
        if (success == NetworkSucc)
        {
            self.opType = C_OP_DELETE;
            self.userData.need_send=NO;
            self.needSend=NO;
            self.archived=!self.archived;
            self.userData.archived=self.archived;
            [AppDelegate saveContext];
            if (self.archived==YES)
            {
                if ([self.archiveDelegate respondsToSelector:@selector(itemSuccessfullyArchived:)])
                {
                    [self.archiveDelegate itemSuccessfullyArchived:self];
                }
            }
        }
        else
        {
            
            /*if ([self.archiveDelegate respondsToSelector:@selector(failedToArchiveknote:)])
             {
             [self.archiveDelegate failedToArchiveknote:self];
             }
             [SVProgressHUD showErrorWithStatus:@"Delete failed, please try again later." duration:3];*/
            self.archived=!self.archived;
            self.userData.archived=self.archived;
            [AppDelegate saveContext];
        }
    }];
    
}
-(void)UnarchiveItem
{
    [[AppDelegate sharedDelegate] sendUpdatedKnoteUnArchiveWithID:self.itemId withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData) {
        [self.cell stopProcess];
        
        self.isSending = NO;
        
        if (success == NetworkSucc)
        {
            self.userData.need_send=NO;
            self.needSend=NO;
            self.opType = C_OP_DELETE;
           /* self.archived=!self.archived;
            self.userData.archived=self.archived;*/
            [AppDelegate saveContext];
        }
        else
        {
            
            /*if ([self.archiveDelegate respondsToSelector:@selector(failedToArchiveknote:)])
             {
             [self.archiveDelegate failedToArchiveknote:self];
             }
             [SVProgressHUD showErrorWithStatus:@"Delete failed, please try again later." duration:3];*/
            self.archived=!self.archived;
            self.userData.archived=self.archived;
            [AppDelegate saveContext];
        }
    }];
    
}

- (int)getExpandedCellHeight {
    return 0;
}

- (int)getExpandedCellTextViewHeight {
    return 0;
}

- (int)getNotExpandedCellTextViewHeight {
    return 0;
}

@end
