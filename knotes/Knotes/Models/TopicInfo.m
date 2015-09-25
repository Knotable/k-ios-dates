//
//  TopicInfo.m
//  Knotable
//
//  Created by backup on 14-2-25.
//
//

#import "TopicInfo.h"
#import "TopicCell.h"
#import "TopicManager.h"
#import "DataManager.h"
#import "SVProgressHUD.h"
#import "ThreadItemManager.h"
#import "FileInfo.h"

@implementation TopicInfo

- (id)initWithTopicEntity:(TopicsEntity *)entity
{
    self = [super init];
    
    if (self)
    {        
        self.entity = entity;
        
        self.topic_id = entity.topic_id;
        
        [entity.managedObjectContext performBlockAndWait:^{
            
            if ([entity.topic_id hasPrefix:kKnoteIdPrefix])
            {
                entity.needSend = [NSNumber numberWithBool:YES];
            }
            else
            {
                entity.needSend = [NSNumber numberWithBool:NO];
            }
            
            entity.isSending = [NSNumber numberWithBool:NO];

            
        }];
        
        self.archived = entity.isArchived.boolValue;
        
        self.uploadRetryCount = 3;
        
        self.hasNewActivity = entity.hasNewActivity != nil && entity.hasNewActivity.boolValue;        
    }
    
    return self;
}

- (void)processOperator:(btnOperatorTag)oper
{
    if (oper == btnOperDelete)
    {
        if (self.my_account_id == nil || self.my_account_id.length==0)
        {
            self.my_account_id = [DataManager sharedInstance].currentAccount.account_id;
        }
        
        DLog(@"Self.topicID : %@", self.topic_id);
        
       /* if (self.entity.needSend.boolValue)
        {
            [self.delegate topicArchivOperate:self];
            [self.entity MR_deleteEntity];
            self.entity = nil;
            
            return;
        }*/
        
        [self.cell showProcess];
    
        if ([self.entity.isArchived isEqual:@(1)])
        {
            if ([ReachabilityManager sharedInstance].currentNetStatus!=NotReachable &&[AppDelegate sharedDelegate]
                .meteor.connected)
            {
                [self unarchiveTopicOnline];
            }
            else
            {
                NSLog(@"self.entity.needToSync %@ self.entity.isArchived %@",self.entity.needToSync,self.entity.isArchived);
                self.entity.needToSync=@(YES);
                /*if (self.entity && ![self.entity isFault])
                 {*/
                self.entity.isArchived = @(NO);
                //}
                //self.entity.archived=@"";
                NSMutableArray *archivedArray = [[NSMutableArray alloc] init];
                
                if (self.entity.archived)
                {
                    archivedArray = [[self.entity.archived componentsSeparatedByString:@","] mutableCopy];
                    if (self.my_account_id == Nil)
                    {
                        self.my_account_id = [DataManager sharedInstance].currentAccount.account_id;
                    }
                    if ([archivedArray containsObject:self.my_account_id])
                    {
                        [archivedArray removeObject:self.my_account_id];
                    }
                }
                self.entity.archived=[archivedArray componentsJoinedByString:@","];
                [AppDelegate saveContext];
                if (self.delegate && [self.delegate respondsToSelector:@selector(topicArchivOperate:)])
                {
                    [self.delegate topicArchivOperate:self];
                }
            }
            
        }
        else
        {
            if ([ReachabilityManager sharedInstance].currentNetStatus!=NotReachable&&[AppDelegate sharedDelegate]
                .meteor.connected)
            {
                [self archiveTopicOnline];
            }
            else
            {
                
                self.entity.needToSync=@(YES);
                
                NSMutableArray *archivedArray = [[NSMutableArray alloc] init];
                
                if (self.entity.archived)
                {
                    archivedArray = [[self.entity.archived componentsSeparatedByString:@","] mutableCopy];
                    
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
                
                if (!self.archived)
                {
                    DLog(@"tInfo.my_account_id : %@", self.my_account_id);
                    
                    if (self.my_account_id == Nil)
                    {
                        self.my_account_id = [DataManager sharedInstance].currentAccount.account_id;
                    }
                    
                    [archivedArray addObject:self.my_account_id];
                }
                else
                {
                    for (int i = 0 ; i <[archivedArray count]; i++)
                    {
                        NSString *my_account = [archivedArray objectAtIndex:i];
                        
                        if ([my_account isEqualToString:self.my_account_id])
                        {
                            [archivedArray removeObjectAtIndex:i];
                            
                            break;
                        }
                    }
                }
                
                self.entity.archived=[archivedArray componentsJoinedByString:@","];
                self.entity.isArchived = @(YES);
                
                [AppDelegate saveContext];
                
                if (self.delegate && [self.delegate respondsToSelector:@selector(topicArchivOperate:)])
                {
                    [self.delegate topicArchivOperate:self];
                }
            }
            
        }
    }
}
-(void)unarchiveTopicOnline
{
    NSLog(@"unarchiveTopicOnline");
    AppDelegate *app = [AppDelegate sharedDelegate];
    [app.meteor callMethodName:@"topic.restore"
                    parameters:@[self.entity.topic_id]
              responseCallback:^(NSDictionary *response, NSError *error)
     {
         if (!error)
         {
             if (self.entity && ![self.entity isFault])
             {
                 self.entity.isArchived = @(NO);
             }
             NSMutableArray *archivedArray = [[NSMutableArray alloc] init];
             
             if (self.entity.archived)
             {
                 archivedArray = [[self.entity.archived componentsSeparatedByString:@","] mutableCopy];
                 if (self.my_account_id == Nil)
                 {
                     self.my_account_id = [DataManager sharedInstance].currentAccount.account_id;
                 }
                 if ([archivedArray containsObject:self.my_account_id])
                 {
                     [archivedArray removeObject:self.my_account_id];
                 }
             }
             self.entity.archived=[archivedArray componentsJoinedByString:@","];

             [AppDelegate saveContext];
             
             if (self.delegate && [self.delegate respondsToSelector:@selector(topicArchivOperate:)])
             {
                 [self.delegate topicArchivOperate:self];
             }
         }
     }];
}
-(void)archiveTopicOnline
{
    NSLog(@"archiveTopicOnline");
    [[TopicManager sharedInstance] archivedTopic:self
                               withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
     {
         [self.cell stopProcess];
         
         switch (success) {
                 
             case NetworkSucc:
             {
                 if (userData)
                 {
                     NSArray *array = [userData copy];
                     
                     self.entity.archived = [array componentsJoinedByString:@","];
                     
                     self.entity.isArchived = @(YES);
                     
                     [AppDelegate saveContext];
                     
                     if (self.delegate && [self.delegate respondsToSelector:@selector(topicArchivOperate:)])
                     {
                         [self.delegate topicArchivOperate:self];
                     }
                 }
             }
                 break;
             case NetworkErr:
             case NetworkFailure:
             case NetworkTimeOut:
             {
                 DLog(@"Failed in archiving");
             }
                 break;
             default:
                 break;
         }
     }];
}

- (void)recordSelfToServer
{
    if (!self.item)
    {
        MessageEntity *firstMessage = [MessageEntity MR_findFirstByAttribute:@"topic_id" withValue:self.topic_id orderedBy:@"created_time" ascending:NO];
       
        if(firstMessage)
        {
            CItem *item = [[ThreadItemManager sharedInstance] generateItemForMessage:firstMessage withTopic:self.entity];
            //self.items = [[ThreadItemManager sharedInstance] generateItemsForMessage:firstMessage withTopic:self.entity];
            self.item = item;
        }
        else
        {
            NSLog(@"self.item is nil");
        }
    }
    
    if (self.item)
    {
        if(!self.item.userData)
        {
            self.item.userData = [MessageEntity MR_findFirstByAttribute:@"message_id" withValue:self.message_id];
        }
        
        self.item.topic = self.entity;
    }
    
    [self.cell showProcess];
    
    [[TopicManager sharedInstance] recordTopicToServer:self withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData, id userData2) {
        if (error.code == 403) {
            self.entity.needSend = @(NO);
            [AppDelegate saveContext];
        }
        switch (success) {
            case NetworkSucc:
            {
                self.uploadRetryCount = 3;
                NSString *newTopicId = userData;
                
                if (![self.topic_id isEqualToString:newTopicId]) {
                    [self changeNotesWithTopicId:self.topic_id toTopicId:newTopicId];
                }
                
                self.topic_id = newTopicId;
                NSLog(@"Setting entity topic_id from TopicInfo after recordTopicToServer: %@", self.topic_id);
                self.entity.topic_id = self.topic_id;
                if(self.item){
                    self.item.topic.topic_id = self.topic_id;
                    self.item.userData.topic_id = self.topic_id;
                }
                self.entity.needSend = @(NO);

                if(!self.item){
                    [self.cell stopProcess];
                    return;
                }
                NSLog(@"about to insertKnote with filesArray: %@", self.filesArray);
                [self.cell stopProcess];
                
                self.item.files = self.filesArray;

                self.item.needSend = NO;
                self.item.userData.need_send = NO;
                
                [AppDelegate saveContext];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"new_knote_ready_to_post" object:self.item userInfo:nil];
            }
                break;
            case NetworkTimeOut:
            case NetworkErr:
            case NetworkFailure:
            {
                self.uploadRetryCount--;
                
                if (self.uploadRetryCount>=0)
                {
                    NSLog(@"TopicInfo recordSelfToServer retrying count: %d", (int)self.uploadRetryCount);
                    
                    [self recordSelfToServer];
                }
                else
                {
                    
                }                
            }
                break;
            default:
                break;
        }
        
        [self.cell stopProcess];
    }];
}

- (void)changeNotesWithTopicId:(NSString *)topicId toTopicId:(NSString *)newTopicId {
    [[ThreadItemManager sharedInstance] changeNotesWithTopicId:topicId toTopicId:newTopicId];
}

- (void) udpateSelfTopicArchive:(btnOperatorTag)oper
{
    if (oper == btnOperDelete)
    {
        if (self.my_account_id == nil || self.my_account_id.length==0)
        {
            self.my_account_id = [DataManager sharedInstance].currentAccount.account_id;
        }
        
        DLog(@"Self.topicID : %@", self.topic_id);
        
        /*if (self.entity.needSend.boolValue)
        {
           // [self.delegate topicArchivOperate:self];
            [self.entity MR_deleteEntity];
            self.entity = nil;
            
            return;
        }*/
        
        if (self.archived)
        {
            if (self.entity && ![self.entity isFault])
            {
                self.entity.isArchived = @(NO);
            }
            
            self.archived = NO;
            
            [AppDelegate saveContext];
        }
        else
        {            
            [[TopicManager sharedInstance] archivedLocalTopic:self
                                            withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
            {
                switch (success) {
                        
                    case NetworkSucc:
                    {
                        if (userData)
                        {
                            NSArray *array = [userData copy];
                            
                            self.entity.archived = [array componentsJoinedByString:@","];
                            
                            self.entity.isArchived = @(YES);
                            
                            [AppDelegate saveContext];
                        }
                    }
                        break;
                    case NetworkErr:
                    case NetworkFailure:
                    case NetworkTimeOut:
                    {
                        DLog(@"Failed in archiving");
                    }
                        break;
                    default:
                        break;
                }
            }];
        }
    }
}

- (void) bookMarkTopicOnline:(BOOL)bookMarkStatus TopicEntity:(TopicsEntity*)entity
{
    MeteorClient *meteor = [AppDelegate sharedDelegate].meteor;
    
    if (!meteor || !meteor.connected )
    {
        NSLog(@"Knotable: NOT POSTING BookMark Status, not connected");
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self bookMarkTopicOnline:bookMarkStatus TopicEntity:entity];
        });
        
        return;
    }
    
    [[AppDelegate sharedDelegate] sendTopicBookMarkStatusToServer:entity.topic_id
                                                      withContent:bookMarkStatus
                                                withCompleteBlock:^(NSDictionary *response, NSError *error)
     {
         if (error)
         {
             NSLog(@"Knotable: BookMark Server Error ");
             NSLog(@"%@",error.userInfo);
             return;
         }
         
         DLog(@"Success : %@", response);
         
         entity.isBookMarked = [NSNumber numberWithBool:bookMarkStatus];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:Pad_BookMarked_Notification object:nil];
         
     }];
}

+ (NSString*) defaultName
{
    NSString* userName = [DataManager sharedInstance].currentAccount.user.name;
    return [userName stringByAppendingString: @"'s Knotes from Chrome"];
}


@end
