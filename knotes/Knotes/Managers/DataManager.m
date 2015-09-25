//
//  DataManager.m
//  Knotable
//
//  Created by Martin Ceperley on 1/29/14.
//
//

#import "AppDelegate.h"
#import "DataManager.h"
#import "ThreadItemManager.h"
#import "MessageManager.h"
#import "ReachabilityManager.h"

#import "MessageEntity.h"
#import "AccountEntity.h"
#import "UserEntity.h"
#import "ContactsEntity.h"
#import "TopicsEntity.h"

#import "CombinedViewController.h" //Managers shouldn't reference viewcontrollers

#import "SDWebImageManager.h"

#import "ObjCMongoDB.h"
#import "CUtil.h"
#include <mach/mach.h>

#define kDefaultFetchContactRetryCount 5
#define kDefaultFetchContactLimitCount 25

#define RemoveMeteorMethod  YES

@implementation DataManager{
@private
    int fetch_retry_count;
    BOOL _topicsReady;
    BOOL _contactsReady;
    
    BOOL _fetchingHotKnotes;
    BOOL _fetchingTopics;
    BOOL _fetchingContacts;
    BOOL _fetchContactsEnd;

    BOOL _fetchHotKnotesAfterContacts;
    BOOL _fetchDataAfterConnecting;
    
    BOOL _haveStartedFetching;
    
    BOOL _pulled_active_Topics;
    
    NSDate *lastSaveDate;

    NSTimer *_fetchRemoteHotTimer;

    NSInteger _fetchContactsLimit;
    NSInteger _fetchContactsOffset;
    NSInteger _fetchContactsRetryCount;

}

@synthesize currentAccount = _currentAccount;

+ (DataManager *)sharedInstance
{
    static DataManager *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[DataManager alloc] init];
    });
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if(self){
        _forceStopFetchTopic = NO;
        _haveStartedFetching = NO;
        fetch_retry_count = 5;
        _fetchedContacts = NO;
        _fetchContactsEnd = NO;
        _topicsReady = NO;
        _contactsReady = NO;
        
        _fetchingContacts = NO;
        _fetchingHotKnotes = NO;
        _fetchingTopics = NO;
        
        _fetchHotKnotesAfterContacts = NO;
        _fetchDataAfterConnecting = NO;
        
        _pulled_active_Topics = NO;
        
        _fetchContactsLimit = kDefaultFetchContactLimitCount;
        _fetchContactsOffset = 0;
        _fetchContactsRetryCount = kDefaultFetchContactRetryCount;
        _assetsLibrary = [[ALAssetsLibrary alloc] init];

        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(meteorLoggedIn:)
                                                     name:@"meteor_logged_in"
                                                   object:nil];
        
        // Topic Observer
        [self turnOnBackground];
        
    }
    
    return self;
}

- (void)turnOffBackground
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"TopicsCount_added" object:nil];    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ArchivedTopicsCount_added" object:nil];

    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"topics_added" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"topics_changed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"topics_removed" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"archivedKnotesForTopic_added" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"archivedKnotesForTopic_changed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"archivedKnotesForTopic_removed" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pinnedKnotesForTopic_added" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pinnedKnotesForTopic_changed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"pinnedKnotesForTopic_removed" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"OtherContactsCount_added" object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"contacts_added" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"contacts_changed" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"contacts_removed" object:nil];
}

- (void)turnOnBackground
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotTopicCount:)
                                                 name:@"TopicsCount_added"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(gotArchivedTopicCount:)
                                                 name:@"ArchivedTopicsCount_added"
                                               object:nil];

    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topicsUpdated:)
                                                 name:@"topics_added"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topicsUpdated:)
                                                 name:@"topics_changed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topicsRemoved:)
                                                 name:@"topics_removed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topicsUpdated:)
                                                 name:@"archivedKnotesForTopic_added"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topicsUpdated:)
                                                 name:@"archivedKnotesForTopic_changed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topicsRemoved:)
                                                 name:@"archivedKnotesForTopic_removed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topicsUpdated:)
                                                 name:@"pinnedKnotesForTopic_added"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topicsUpdated:)
                                                 name:@"pinnedKnotesForTopic_changed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(topicsRemoved:)
                                                 name:@"pinnedKnotesForTopic_removed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactsCountAdded:)
                                                 name:@"OtherContactsCount_added"
                                               object:nil];
    
   
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactsAdded:)
                                                 name:@"contacts_added"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactsChanged:)
                                                 name:@"contacts_changed"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactsRemoved:)
                                                 name:@"contacts_removed"
                                               object:nil];
}
-(void)turnOnContactsInBackground
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(contactsAdded:)
                                                 name:@"contacts_added"
                                               object:nil];
}
-(void)turnOffContactsInBackground
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"contacts_added" object:nil];

}
- (void)dealloc
{
    [_fetchRemoteHotTimer invalidate];
    _fetchRemoteHotTimer = nil;
}

//-(void)setCurrentAccount:(AccountEntity *)currentAccount
//{
//    _currentAccount = currentAccount;
//
//    if(!_currentAccount.hashedToken)
//    {
//        [_currentAccount setTokenInfo:self.accountTokenBackup];
//        
//        self.accountTokenBackup = nil;
//    }
//}

-(AccountEntity *)currentAccount
{
    if(!_currentAccount)
    {
        AccountEntity* lastAccount = [AccountEntity MR_findFirstOrderedByAttribute:@"lastLoggedIn"
                                                                         ascending:NO];
        
        return lastAccount;
        
    }
    else
    {
        return _currentAccount;
    }
}

- (void)meteorLoggedIn:(NSNotification *)note
{
    if (_haveStartedFetching)
    {
        return;
    }
    
    NSLog(@".");

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isPlaceHold == %d",kInvalidatePosition];
    
    TopicsEntity * topic = [TopicsEntity MR_findFirstWithPredicate:predicate
                                                         inContext:glbAppdel.managedObjectContext];
    
    if (!topic)
    {
        topic = [TopicsEntity MR_createEntityInContext:glbAppdel.managedObjectContext];
        
        topic.isPlaceHold = kInvalidatePosition;
        
        topic.isArchived = @(NO);
    }
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    if (app.meteor && app.meteor.connected)
    {
        _haveStartedFetching = YES;
        
        _topicsReady = NO;
        _contactsReady = NO;
        
        if (self.userLogin)
        {
            self.userLogin = NO;
            
            [app entryMainView:YES];
        }
        
        NSLog(@">>>>>>>>>>>PULLING TOPICS <<<<<<<<<<<<");
      
            [[AppDelegate sharedDelegate].meteor addSubscription:METEORCOLLECTION_TOPICS];
            [[AppDelegate sharedDelegate].meteor addSubscription:METEORCOLLECTION_ARCHIVEDTOPICS];
        
        
        return;
    }
}

-(void)gotTopicCount:(NSNotification *)note
{
    NSDictionary* serverData = Nil;
    
    if (note.userInfo)
    {
        serverData = note.userInfo;
    }
    
    if (serverData[@"count"])
    {
        //[self removeSubscriptionFromMeteor];
        DLog(@"***Active Topic Count : %ld***", (long)[serverData[@"count"] integerValue]);
        
#if DEBUG || ADHOC
        
        [AppDelegate sharedDelegate].user_active_topics = [serverData[@"count"] integerValue] - 4;  // for angus account
        
#else   // APPSTORE and ENTERPRISE
        
        [AppDelegate sharedDelegate].user_active_topics = [serverData[@"count"] integerValue];
        
#endif
        
        // Store new topic count every time
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setInteger:[AppDelegate sharedDelegate].user_active_topics forKey:kUserTopicCount];
        [userDefault synchronize];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName: @"topic_count_update" object: nil userInfo:note.userInfo];
}

-(void)gotArchivedTopicCount:(NSNotification *)note
{
    NSDictionary* serverData = Nil;
    
    if (note.userInfo)
    {
        serverData = note.userInfo;
    }
    
    if (serverData[@"count"])
    {
        DLog(@"***Archived Topic Count : %ld***", (long)[serverData[@"count"] integerValue]);
        
        [AppDelegate sharedDelegate].user_archived_topics = [serverData[@"count"] integerValue];
        
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        
        [userDefault setInteger:[AppDelegate sharedDelegate].user_archived_topics forKey:kUserArchivedTopicCount];
        
        [userDefault synchronize];
    }
    
}

// Lin - Added
/*
 This function will manage the topic's add and changed event.
 */
// Lin - Ended

- (void)topicsUpdated:(NSNotification *)note
{
    NSDictionary *topic_dict = note.userInfo;
    
    NSString *topic_id = topic_dict[@"_id"];
    
    TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:topic_id];

    if(topic)
    {
        [topic setValuesForKeysWithDictionary:topic_dict withAccount:_currentAccount];
        NSUInteger local_archived_topic_count = 0;
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isArchived == %@)",
                                  @(YES)];
        
        local_archived_topic_count = [TopicsEntity MR_countOfEntitiesWithPredicate:predicate];
        [[NSNotificationCenter defaultCenter] postNotificationName:TOPICS_CHANGED_NOTIFICATION object:@(YES) userInfo:topic_dict];
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
        
            TopicsEntity* topic = [self insertOrUpdateNewTopicObject:topic_dict];
            
            DLog(@"New : %@", topic.isArchived);
            
            [AppDelegate saveContext];
            
            if ([topic.isArchived boolValue])
            {
                // This topic is the archived topic
                
                if (_pulled_active_Topics == NO)
                {
                    NSUInteger local_active_topic_count = 0;
                    
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(isArchived == %@)",
                                              @(NO)];
                    
                    local_active_topic_count = [TopicsEntity MR_countOfEntitiesWithPredicate:predicate];
                    
                    DLog(@"****** Active Topics ****** %ld : %lu", (long)[AppDelegate sharedDelegate].user_active_topics, (unsigned long)local_active_topic_count);
                    
                    _pulled_active_Topics = YES;
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:FORCE_RELOAD_PAD_FOR_ACTIVE_TOPICS
                                                                        object:Nil
                                                                      userInfo:Nil];
                    
                }
            }
            else
            {
                // This topic is the non archived topic
                
                _pulled_active_Topics = NO;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:TOPICS_ADDEDED_NOTIFICATION
                                                                    object:@(YES)
                                                                  userInfo:topic_dict];
                
            }
        });
        
        
    }
}

- (void) deleteTopicWithTopicID:(NSString *)topicID{

    NSArray *messages = [MessageEntity MR_findByAttribute:@"topic_id" withValue:topicID];
    
    for (MessageEntity *message in messages)
    {
        [message MR_deleteEntity];
    }
    
    TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:topicID];
    [topic MR_deleteEntity];
    
    [AppDelegate saveContext];
    
}

- (void)topicsRemoved:(NSNotification *)note
{
    if (_currentAccount.account_id)
    {
        NSDictionary *topic_dict = note.userInfo;
        
        NSString *topic_id = topic_dict[@"_id"];
        
        NSArray *messages = [MessageEntity MR_findByAttribute:@"topic_id" withValue:topic_id];
        
        for (MessageEntity *message in messages)
        {
            [message MR_deleteEntity];
        }
        
        TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:topic_id];
        
        if (topic)
        {
            topic.isArchived = @(YES);
            
            NSString *account_id = _currentAccount.account_id;
            
            NSRange range = [topic.archived rangeOfString:account_id];
            
            if (range.location == NSNotFound)
            {
                topic.archived = [NSString stringWithFormat:@"%@,%@",topic.archived,account_id];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:TOPICS_REMOVED_NOTIFICATION
                                                                object:@(YES)
                                                              userInfo:topic_dict];
        }
    }
}

#pragma mark Contacts

- (void)startRemoteFetch {

    if(!self.meteor.connected)
    {
        NSLog(@"waiting for meteor to connect");
        
        _fetchDataAfterConnecting = YES;
        
        return;
    }
    
    _fetchContactsEnd = YES;
    
    [self fetchRemoteContactsThenHotKnotes];

}

- (void)fetchRemoteContactsThenHotKnotes
{
    if (_fetchContactsEnd == YES)
    {
        _fetchContactsEnd = NO;
        _fetchHotKnotesAfterContacts = YES;
        _fetchContactsOffset = 0;
        _fetchContactsRetryCount = kDefaultFetchContactRetryCount;
    
        [self fetchRemoteContacts];
    }
}

- (void)forceFetchRemoteContacts
{
    _fetchContactsOffset = 0;
    
    _fetchContactsRetryCount = kDefaultFetchContactRetryCount;
    
    [self fetchRemoteContacts];
}

- (void)fetchRemoteContacts
{
    if ( _fetchingContacts
        || _currentAccount.user.logout.boolValue
        || !([ReachabilityManager sharedInstance].currentNetStatus != NotReachable) )
    {
        return;
    }
    
    _fetchingContacts = YES;
    
    AppDelegate* app = [AppDelegate sharedDelegate];
    
    [app.meteor addSubscription:METEORCOLLECTION_PEOPLE];
}

- (void)afterFetchingContacts
{
    NSLog(@"afterFetchingContacts");

    _lastFetchedContacts = [NSDate date];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:CONTACTS_DOWNLOADED_NOTIFICATION
                                                        object:nil userInfo:nil];

    if (_fetchContactsEnd)
    {
        [self performSelector:@selector(updateRelationships) withObject:nil afterDelay:1];
    }
    
    if (_fetchHotKnotesAfterContacts)
    {
        _fetchHotKnotesAfterContacts = NO;
        
    }


}

- (void) updateRelationships
{
    NSLog(@"updateRelationships");
    //1) set contacts on topics
    //2) set contacts on messages

    NSArray *allTopics = [TopicsEntity MR_findAll];
    for(TopicsEntity *topic in allTopics){
        [topic updateContactsUser:_currentAccount.user.contact];
    }

    NSArray *allMessages = [MessageEntity MR_findAll];
    for(MessageEntity *message in allMessages){
        if(!message.contact){
            message.contact = [ContactsEntity MR_findFirstByAttribute:@"mainEmail" withValue:message.email];
        }
    }


    [[NSNotificationCenter defaultCenter] postNotificationName:RELATIONSHIPS_UPDATED_NOTIFICATION
                                                        object:nil userInfo:nil];
}

#pragma mark Topics
-(void)setCurrentOrder:(NSInteger)currentOrder
{
    _currentOrder = currentOrder;
    if (currentOrder==0) {
        self.finishFetchTopic = NO;
    }
}

- (void)forceFetchRemoteTopics
{
    _currentOrder = 0;
    self.finishFetchTopic = NO;
    _fetchingTopics=NO;
}

- (void)afterFetchingTopics:(NSMutableArray* )topic_ids
{
    //NSLog(@".");
    _fetchedTopics = YES;
    _fetchingTopics = NO;
    _lastFetchedTopics = [NSDate date];
    
    NSMutableDictionary* topic_dicts = [[NSMutableDictionary alloc] init];
    
    [topic_dicts setObject:topic_ids forKey:@"topic_ids"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:TOPICS_DOWNLOADED_NOTIFICATION
                                                        object:@(YES)
                                                      userInfo:topic_dicts];
    
    
}

- (void)afterFetchingHotKnotes
{
    _fetchedHotKnotes = YES;
    _fetchingHotKnotes = NO;
    _lastFetchedHotKnotes = [NSDate date];
}

- (TopicsEntity *)insertOrUpdateNewTopicObject:(NSDictionary*) dic
{
    NSString *topic_id = dic[@"_id"];
    
    [glbAppdel.managedObjectContext lock];
    
    NSManagedObjectContext *backgroundMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [backgroundMOC setPersistentStoreCoordinator:[glbAppdel.managedObjectContext persistentStoreCoordinator]];
    
    TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:topic_id inContext:backgroundMOC];
    
    if(topic == nil)
    {
        topic = [TopicsEntity MR_createEntity];
    }
    else
    {
        topic = (TopicsEntity *)[glbAppdel.managedObjectContext existingObjectWithID:[topic objectID] error:nil];
    }
    
    [topic setValuesForKeysWithDictionary:dic withAccount:_currentAccount];
    
    [glbAppdel.managedObjectContext unlock];
    
    return topic;
}

- (MessageEntity *)insertOrUpdateMessage:(NSDictionary*) dict
{
    MessageEntity *message = [MessageEntity MR_findFirstByAttribute:@"message_id" withValue:dict[@"_id"]];
    if(message == nil){
        message = [MessageEntity MR_createEntity];
    }
    [message setValuesForKeysWithDictionary:dict withTopicId:dict[@"topic_id"]];
    message.contact = [ContactsEntity MR_findFirstByAttribute:@"mainEmail" withValue:message.email];
    return message;
}

- (void)reset
{
    NSLog(@"removing meteor subscriptions");
    
    self.currentOrder = 0;
    
    _forceStopFetchTopic = YES;
    _fetchContactsEnd = NO;
    _fetchContactsOffset = 0;
    
    self.userLogin = NO;
    self.current_user_id = @"";

    [[AppDelegate sharedDelegate].meteor removeSubscription:METEORCOLLECTION_TOPICS];
    [[AppDelegate sharedDelegate].meteor removeSubscription:METEORCOLLECTION_ARCHIVEDTOPICS];

    if (self.currentAccount)
    {
        self.currentAccount.loggedIn = @(NO);
        self.currentAccount.hashedToken = nil;
        self.currentAccount.expireDate = nil;
        self.currentAccount = nil;
    }
    
    self.currentAccount = nil;
    
    _haveStartedFetching = NO;
    _fetchedContacts = _fetchedTopics = _fetchedHotKnotes = NO;
    
    _topicsReady = _contactsReady = NO;
    
    _fetchingHotKnotes = _fetchingTopics = _fetchingContacts = NO;


}

-(void)removeSubscriptionFromMeteor
{
    [[AppDelegate sharedDelegate].meteor removeSubscription:METEORCOLLECTION_TOPICS];
    [[AppDelegate sharedDelegate].meteor removeSubscription:METEORCOLLECTION_ARCHIVEDTOPICS];
}

#pragma mark Core Data Notifications

- (void)contextWillSave:(NSNotification *)note
{
    NSDictionary *info = note.userInfo;
    NSLog(@"contextWillSave info: %@ object: %@", info, note.object);
}

- (void)objectsDidChange:(NSNotification *)note
{
    NSDictionary *info = note.userInfo;
    NSArray *inserted = info[NSInsertedObjectsKey];
    NSArray *updated =  info[NSUpdatedObjectsKey];
    NSArray *deleted =  info[NSDeletedObjectsKey];
    NSLog(@"inserted:%d, updated:%d, deleted:%d",(int)[inserted count],(int)[updated count],(int)[deleted count]);
    if(deleted && deleted.count > 0){
        NSLog(@"DELETED ITEMS: %d", (int)deleted.count);
        NSArray *entityNames = [deleted valueForKeyPath:@"entity.name"];
        NSLog(@"%@", entityNames);
        for(NSManagedObject *obj in deleted){
            if([obj isKindOfClass:[MessageEntity class]]){
                MessageEntity *message = (MessageEntity *)obj;
                NSLog(@"Message ID: %@", message.message_id);
            }
        }
    }

}

- (void)saveIfNeeded
{
    long saveInterval = 10.0;

    if (!lastSaveDate || (-1.0 * [lastSaveDate timeIntervalSinceNow]) >= saveInterval) {
        lastSaveDate = [NSDate date];
        [AppDelegate saveContext];
        NSLog(@".");
    }
}

#if kPeopleProcess

-(void)contactsCountAdded:(NSNotification *)note
{
    NSDictionary* serverData = Nil;
    
    if (note.userInfo)
    {
        serverData = note.userInfo;
    }
    
    if (serverData[@"count"])
    {
        self.contactsCount = [serverData[@"count"] integerValue];
        
        
        if ((![serverData[@"count"] isEqual:[NSNull null]]) && serverData[@"count"] != nil)
        {
            
            [AppDelegate sharedDelegate].user_total_contacts = [serverData[@"count"] integerValue];
        }
        
        NSLog(@"Total Contacts of User %li",(long)_contactsCount);
    }
    
    if (self.combinedVC && [self.combinedVC respondsToSelector:@selector(contactsUpdateProgress:)])
    {
        
#if !New_DrawerDesign
        
        [self.combinedVC contactsUpdateProgress:self.contactsCount];
        
#endif
        
    }
}

#endif

- (void)contactsAdded:(NSNotification *)note
{
    
#if kContactUserFetchedController
    
    [ContactsEntity contactWithDict:note.userInfo];
    
    [glbAppdel.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error)
    {
        if (error != nil)
        {
            NSLog(@"Error saving core data: %@", error);
        }
        
    }];
    
#if kPeopleProcess
    
    if (self.combinedVC
        && [self.combinedVC respondsToSelector:@selector(contactsUpdateProgress:)])
    {
#if !New_DrawerDesign
        [self.combinedVC contactsUpdateProgress:self.contactsCount];
#endif
    }
    
#endif
#else
    if (!_contactsReady)
    {
        return;
    }
    
    NSLog(@".");
    
    ContactsEntity *contact = [ContactsEntity contactWithDict:note.userInfo];
    
    [self saveIfNeeded];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NEW_CONTACT_DOWNLOADED_NOTIFICATION
                                                        object:nil];
    
#endif
}


- (void)contactsChanged:(NSNotification *)note
{
    if (!_contactsReady) {
        return;
    }
    NSLog(@".");
    ContactsEntity *contact = nil;
    NSManagedObjectContext *backgroundMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [backgroundMOC setPersistentStoreCoordinator:[glbAppdel.managedObjectContext persistentStoreCoordinator]];
    NSDictionary *dict = note.userInfo;
    NSString *contact_id = dict[@"_id"];
    if (contact_id && contact_id.length > 0) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ContactsEntity"];
        [request setPredicate:[NSPredicate predicateWithFormat:@"%K = %@", @"contact_id", contact_id]];
        [request setFetchLimit:1];
        NSUInteger count = [backgroundMOC countForFetchRequest:request error:nil];
        if (count>0) {
            contact = [[backgroundMOC executeFetchRequest:request error:nil] firstObject];
            contact = (ContactsEntity *)[glbAppdel.managedObjectContext existingObjectWithID:[contact objectID] error:nil];
        }
    }
    if (contact)
    {
        NSNumber *flag = @(NO);
        if (contact.archived.boolValue)
        {
            flag = @(YES);
        }
        [contact setValuesForKeysWithDictionary:note.userInfo];
        if (flag.boolValue)
        {
            contact.archived = @(NO);
        }
    }
    else
    {
        contact = [ContactsEntity MR_createEntityInContext:glbAppdel.managedObjectContext];
        [contact setValuesForKeysWithDictionary:note.userInfo];
    }
//    [contact setValuesForKeysWithDictionary:dict];
//    ContactsEntity *contact = [ContactsEntity contactWithDict:note.userInfo];
    [self saveIfNeeded];
    [[NSNotificationCenter defaultCenter] postNotificationName:NEW_CONTACT_DOWNLOADED_NOTIFICATION object:nil];

}

- (void)contactsRemoved:(NSNotification *)note
{
    NSLog(@"contactsRemoved");
    
}

- (UserEntity *)saveUserObject:(NSDictionary*) dic {
    
    NSString *userID = dic[@"_id"];
    NSString *format = [NSString stringWithFormat:@"user_id = '%@'", userID];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:format];
    
    [UserEntity MR_deleteAllMatchingPredicate:predicate];
    
    UserEntity *user = [UserEntity MR_createEntity];
    
    [user setValuesForKeysWithDictionary:dic];
    
    if (!self.currentAccount)
    {
        self.currentAccount = [AccountEntity MR_createEntity];
    }
    
    self.currentAccount.user = user;
    self.currentAccount.lastLoggedIn = [NSDate date];
    self.currentAccount.loggedIn = @(YES);
    self.currentAccount.account_id = nil;
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    if(!self.currentAccount.account_id)
    {
        NSLog(@"getting account_id for userID: %@", userID);
        
        [[AppDelegate sharedDelegate] sendRequestAccountID:userID
                                         withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData) {
            
            if (success == NetworkSucc && userData)
            {
                self.currentAccount.account_id = (NSString *)userData;
                
                NSLog(@"Setting account_id: %@", userData);
                
                [app saveContextAndWait];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"meteor_logged_in"
                                                                    object:nil];
                
                [self startRemoteFetch];
            }
            else
            {
                NSLog(@"Error getting account_id for userID: %@ error: %@", userID, error);
            }
                                             
            dispatch_async(dispatch_get_main_queue(), ^{

                [app login:YES];
                
            });
        }];
    }
    else
    {
        NSLog(@"Have saved account_id: %@", self.currentAccount.account_id);
        
        AppDelegate *app = [AppDelegate sharedDelegate];
        
        [AppDelegate saveContext];
        
        [app login:YES];
    }
    
    
    return user;
}

- (void)setMessage:(MessageEntity *)message withMute:(BOOL)mute
{
    TopicsEntity *entity = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:message.topic_id];
    entity.isMute = @(mute);
    message.muted = mute;

    MessageManager *msgMgr = [[MessageManager alloc] init];
    msgMgr.message = message;
    [msgMgr setMeteorMuted:mute WithRetryCount:5];

}

- (BOOL)lastAccountIsLoggedIn
{
    if (self.currentAccount && self.currentAccount.loggedIn.boolValue && self.currentAccount.account_id)
    {
        return YES;
    }
    return NO;
}

#pragma mark - Sys Assistant Method

-(float)getCpuInfo
{
    float	tot_cpu = 0;
    kern_return_t			kr = { 0 };
    task_info_data_t		tinfo = { 0 };
    mach_msg_type_number_t	task_info_count = TASK_INFO_MAX;
    
    kr = task_info( mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count );
    if ( KERN_SUCCESS == kr ) {
        task_basic_info_t		basic_info = { 0 };
        thread_array_t			thread_list = { 0 };
        mach_msg_type_number_t	thread_count = { 0 };
        
        thread_info_data_t		thinfo = { 0 };
        thread_basic_info_t		basic_info_th = { 0 };
        
        basic_info = (task_basic_info_t)tinfo;
        
        // get threads in the task
        kr = task_threads( mach_task_self(), &thread_list, &thread_count );
        if ( KERN_SUCCESS == kr ) {
            long	tot_sec = 0;
            long	tot_usec = 0;
            
            for ( int i = 0; i < thread_count; i++ ) {
                mach_msg_type_number_t thread_info_count = THREAD_INFO_MAX;
                
                kr = thread_info( thread_list[i], THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count );
                if ( KERN_SUCCESS == kr ) {
                    basic_info_th = (thread_basic_info_t)thinfo;
                    
                    if ( 0 == (basic_info_th->flags & TH_FLAGS_IDLE) ) {
                        tot_sec		= tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
                        tot_usec	= tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
                        tot_cpu		= tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE;
                    }
                }
            }
            kr = vm_deallocate( mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t) );
            if ( KERN_SUCCESS != kr ) {
                tot_cpu = -1;
            }
        }
    }
    return tot_cpu;
}
@end
