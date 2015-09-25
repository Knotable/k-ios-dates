//
//  PostingManager.m
//  Knotable
//
//  Created by Martin Ceperley on 6/19/14.
//
//

#import "PostingManager.h"
#import "ThreadItemManager.h"
#import "ContactManager.h"
#import "ReachabilityManager.h"
#import "DataManager.h"

#import "MessageEntity.h"
#import "TopicsEntity.h"
#import "ActionEntity.h"
#import "AccountEntity.h"

#import "Singleton.h"
#import "CItem.h"
#import "TopicInfo.h"

#import "AJNotificationView.h"
#import <OMPromises/OMPromises.h>
#import "AppDelegate.h"

static int RETRY_COUNT = 5;

static float CHECK_INTERVAL = 15.0;

static float INTERNET_NOT_AVAILABLE_POPUP_INTERVAL = 180.0; // 3 Mins time.

@interface PostingManager()

@property (nonatomic, strong) NSTimer *checkTimer;
@property (nonatomic, strong) NSTimer *offlineObservingTimer;
@property (nonatomic, strong) NSArray *localMethods;

@end
@implementation PostingManager

SYNTHESIZE_SINGLETON_FOR_CLASS(PostingManager);

- (id)init
{
    if (self = [super init]) {
        
        _localMethods = @[
                          ADD_CONTACT_FROM_EMAIL,
                          ADD_CONTACT_FROM_USERNAME];
        
    }
    return self;
}

- (void)startMonitoring
{
    NSLog(@".");
    
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(reachabilityChanged:)
                                                name:kReachabilityChangedNotification
                                              object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loggedIn:)
                                                 name:@"meteor_logged_in"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(checkForActionsToPerform)
                                                 name:@"new_knote_posted"
                                               object:nil];
    /****Dhruv : Causes crash, Dont see it useful.*********/
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newKnoteToPost:)
                                                 name:@"new_knote_ready_to_post"
                                               object:nil];*/

    self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:CHECK_INTERVAL target:self selector:@selector(periodicCheck) userInfo:nil repeats:YES];
    
    self.offlineObservingTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(offlineObserver) userInfo:nil repeats:NO];
    
    
}

- (void)reachabilityChanged:(NSNotification *)note
{
    [self periodicCheck];
}

- (BOOL)canPostNow
{
    BOOL offline = [ReachabilityManager sharedInstance].currentNetStatus == NotReachable;
    
    if(offline)
    {
        NSLog(@"offline");
        return NO;
    }
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    if (!app.meteor.connected)
    {
        NSLog(@"meteor not connected");
        return NO;
    }
    
    return YES;
}

- (void)loggedIn:(NSNotification *)note
{
    NSLog(@".");
    
    if ([AJNotificationView queueCount] > 0)
    {
        [AJNotificationView hideCurrentNotificationViewAndClearQueue];
    }
    
    [self checkForActionsToPerform];
}


- (void)periodicCheck
{
    if (![self canPostNow]) {
        return;
    }
    
    [self checkForActionsToPerform];
}

- (void)offlineObserver
{
    BOOL offline = [ReachabilityManager sharedInstance].currentNetStatus == NotReachable;
    self.offlineObservingTimer = [NSTimer scheduledTimerWithTimeInterval:INTERNET_NOT_AVAILABLE_POPUP_INTERVAL target:self selector:@selector(offlineObserver) userInfo:nil repeats:NO];
    
    if (offline)
    {
        /*UIAlertView* confirm = [[UIAlertView alloc] initWithTitle:@"Cannot connect to server"
                                                          message:nil
                                                         delegate:nil
                                                cancelButtonTitle:Nil
                                                otherButtonTitles:@"Ok", nil];
        [confirm show];*/
    }
    else
    {
      }
    
    return;
}

- (void)checkForActionsToPerform
{
    if (![self canPostNow]) {
        return;
    }

    MessageEntity *message = [MessageEntity MR_findFirstByAttribute:@"need_send"
                                                          withValue:@(YES)
                                                          orderedBy:@"created_time"
                                                          ascending:YES];
    
    if ([message.account_id isEqualToString:[DataManager sharedInstance].currentAccount.account_id])
    {
        [self postKnote:message];
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"needToSync = '%@'", @(YES)]];
    NSArray *arrOFRemainingTopics=[TopicsEntity MR_findAllWithPredicate:predicate];
    if (arrOFRemainingTopics.count>0)
    {
        for (int i=0; i<arrOFRemainingTopics.count; i++)
        {
            TopicsEntity *entity=arrOFRemainingTopics[i];
            TopicInfo *info=[[TopicInfo alloc]initWithTopicEntity:entity];
            if ([info.entity.isArchived isEqual:@(1)])
            {
                [self archiveTopicWithTopicID:info];
            }
            else
            {
                [self unarchiveTopicWithTopicID:info];
            }
        }
    }
    //look at queue for unsent actions
    
    NSArray *unsentActions = [ActionEntity MR_findByAttribute:@"sent"
                                                    withValue:@(NO)
                                                   andOrderBy:@"dateCreated"
                                                    ascending:YES];
    if (unsentActions.count == 0)
    {
        return;
    }
    
    NSLog(@"%lu unsent actions", (unsigned long)unsentActions.count);

    BOOL dirty = NO;
    
    for (ActionEntity *action in unsentActions)
    {
        if (![action.account_id isEqualToString:[DataManager sharedInstance].currentAccount.account_id])
        {
            //different account, do not process
            continue;
        }
        
        OMPromise *promise = [self performAction:action];
        
        [promise fulfilled:^(id result) {
            [self delayedActionFulfilled:action result:result];
        }];
        
    }
    
    //look at queue for failed actions
    
    if (dirty) {
        [AppDelegate saveContext];
    }
}
-(void)unarchiveTopicWithTopicID:(TopicInfo *)topicinfo
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    [app.meteor callMethodName:@"topic.restore"
                    parameters:@[topicinfo.entity.topic_id]
              responseCallback:^(NSDictionary *response, NSError *error)
     {
         if (!error)
         {
             
             NSLog(@"unarchived through posting %@",topicinfo.entity.topic);
             topicinfo.entity.needToSync=@(NO);
             [AppDelegate saveContext];
         }
     }];
}
-(void)archiveTopicWithTopicID:(TopicInfo *)topicinfo
{
    [[TopicManager sharedInstance] archivedTopic:topicinfo
                               withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
     {
         
         
         switch (success) {
                 
             case NetworkSucc:
             {
                 NSLog(@"archived through posting %@",topicinfo.entity.topic);
                 if (userData)
                 {
                     NSArray *array = [userData copy];
                     
                     topicinfo.entity.archived = [array componentsJoinedByString:@","];
                     //topicinfo.entity.isArchived=@(YES);
                     topicinfo.entity.needToSync = @(NO);
                     
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
- (void)delayedActionFulfilled:(ActionEntity *)action result:(id)result
{
    NSLog(@"%@ result: %@", action.methodName, result);
    if ([action.methodName isEqualToString:METEOR_METHOD_ADD_NEW_CONTACT]) {
        NSString *email = result;
        [[NSNotificationCenter defaultCenter] postNotificationName:NEW_CONTACT_ADDED_NOTIFICATION object:email userInfo:nil];
    }
}

- (OMPromise *)performAction:(ActionEntity *)action
{
    if (![self canPostNow]) {
        return [OMPromise promiseWithError:nil];
    }

    NSLog(@"%@", action.methodName);
    
    NSArray *params = [NSKeyedUnarchiver unarchiveObjectWithData:action.parameters];
    
    //check if it's a locally dispatched method
    if ([_localMethods containsObject:action.methodName]) {
        return [self performLocalAction:action];
    }
    
    OMPromise *promise = [PostingManager callMeteorMethod:action.methodName parameters:params];
    
    [promise fulfilled:^(id result) {
        action.result = [NSKeyedArchiver archivedDataWithRootObject:result];
        action.dateConfirmed = [NSDate date];
        action.completed = YES;
        [AppDelegate saveContext];
    }];
    
    [promise failed:^(NSError *error) {
        action.error_code = (int32_t)error.code;
        action.error = [error description];
        
        NSLog(@"Meteor error received: %@", error);
        action.dateConfirmed = [NSDate date];
        action.completed = YES;
        [AppDelegate saveContext];
    }];
    
    
    action.sent = YES;
    action.dateSent = [NSDate date];
    

    [AppDelegate saveContext];
    
    return promise;
}

- (OMPromise *)performLocalAction:(ActionEntity *)action
{
    NSString *methodName = action.methodName;
    id parameter = [NSKeyedUnarchiver unarchiveObjectWithData:action.parameters];
    NSLog(@"%@ param: %@", methodName, parameter);
    

    if ([methodName isEqualToString:ADD_CONTACT_FROM_EMAIL]) {
        
        NSString *email = parameter;
        [[ContactManager sharedInstance] performRemoteEmailAdd:email];
        
    } else if ([methodName isEqualToString:ADD_CONTACT_FROM_USERNAME]){
        
        NSString *username = parameter;
        [[ContactManager sharedInstance] performRemoteUsernameAdd:username];

    } else {
        return [OMPromise promiseWithError:nil];
    }
    
    action.dateConfirmed = [NSDate date];
    action.completed = YES;
    action.sent = YES;
    action.dateSent = [NSDate date];
    
    
    [AppDelegate saveContext];

    
    return [OMPromise promiseWithResult:nil];
}

- (void)newKnoteToPost:(NSNotification *)note {
    CItem *item = note.object;
    if (item.needSend && item.userData.need_send) {
        [self postItem:item];
    }
}

- (void) postKnote:(MessageEntity *)message
{
    NSLog(@"postKnote message ID: %@", message.message_id);
    TopicsEntity *topic = nil;
    if (message.topic_id) {
        topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:message.topic_id];
        if (!topic) {
            topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:[message.topic_id noPrefix:kKnoteIdPrefix]];
            if (topic) {
                message.topic_id = [message.topic_id noPrefix:kKnoteIdPrefix];
            }
        }
    }
    else
    {
        [message MR_deleteEntity];
        [AppDelegate saveContext];
        return;
    }
    if (topic && topic.needSend.boolValue == YES) {
        TopicInfo *info = [[TopicInfo alloc] initWithTopicEntity:topic];
        [info recordSelfToServer];
    }
    
    if (topic) {
        CItem *item = [[ThreadItemManager sharedInstance] generateItemForMessage:message withTopic:topic];
        [self postItem:item];
    }
}

- (void) postItem:(CItem *)item
{
    if (![self canPostNow])
    {
        return;
    }
    [[ThreadItemManager sharedInstance] insertKnote:item
                                          fileInfos:item.files ? item.files : @[]];
}

- (OMPromise *)enqueueLocalMethod:(NSString *)methodName parameters:(id)params
{
    NSLog(@"name: %@ params: \n%@", methodName, params);
    ActionEntity *action = [ActionEntity MR_createEntity];
    action.methodName = methodName;
    if(!params) params = @[];
    NSData *paramData = [NSKeyedArchiver archivedDataWithRootObject:params];
    action.parameters = paramData;
    action.dateCreated = [NSDate date];
    action.sent = NO;
    action.completed = NO;
    action.retriesLeft = RETRY_COUNT;
    
    action.account_id = [DataManager sharedInstance].currentAccount.account_id;
    
    [AppDelegate saveContext];
    
    OMPromise *promise = [self performAction:action];
    return promise;
}

- (OMPromise *)enqueueMeteorMethod:(NSString *)methodName parameters:(NSArray *)params
{
    NSLog(@"name: %@ params: \n%@", methodName, params);
    ActionEntity *action = [ActionEntity MR_createEntity];
    action.methodName = methodName;
    if(!params) params = @[];
    NSData *paramData = [NSKeyedArchiver archivedDataWithRootObject:params];
    action.parameters = paramData;
    action.dateCreated = [NSDate date];
    action.sent = NO;
    action.completed = NO;
    action.retriesLeft = RETRY_COUNT;
    
    action.account_id = [DataManager sharedInstance].currentAccount.account_id;
    
    [AppDelegate saveContext];
    
    OMPromise *promise = [self performAction:action];
    
    return promise;
    
}

+ (OMPromise *)callMeteorMethod:(NSString *)methodName parameters:(NSArray *)params
{
    NSLog(@"method: %@ params: %@", methodName, params);
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    MeteorClient *meteor = app.meteor;
    
    if (meteor && meteor.connected)
    {
        OMDeferred *deferred = [OMDeferred deferred];
        
        [meteor callMethodName:methodName
                    parameters:params
              responseCallback:^(NSDictionary *response, NSError *error)
        {
            if (error)
            {
                NSLog(@"Meteor error received: %@", error);
                
                [deferred fail:error];
            }
            else
            {
                id result = response[@"result"];
                
                [deferred fulfil:result];
            }
        }];
        return deferred;
    } else {
        return [OMPromise promiseWithError:[NSError errorWithDomain:@"knotable" code:101 userInfo:@{@"code":@"not_connected",@"message":@"Not connected to Knotable"}]];
    }
}


@end
