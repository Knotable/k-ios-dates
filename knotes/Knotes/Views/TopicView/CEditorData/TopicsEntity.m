//
//  TopicsEntity.m
//  RevealControllerProject
//
//  Created by backup on 13-11-15.
//
//

#import "TopicsEntity.h"
#import "ContactsEntity.h"
#import "AccountEntity.h"
#import "UserEntity.h"
#import "ObjCMongoDB.h"
#import "DataManager.h"
#import "NSString+Knotes.h"

@implementation TopicsEntity

@dynamic participators;
@dynamic topic;
@dynamic topic_id;
@dynamic contact_id;
@dynamic topic_type;
@dynamic locked_id;
@dynamic key_id;
@dynamic created_time;
@dynamic updated_time;
@dynamic archived;
@dynamic isArchived;
@dynamic order;
@dynamic contacts;
@dynamic account_id;
@dynamic shared_account_ids;
@dynamic viewers;
@dynamic position;
@dynamic order_to_set;
@dynamic order_user_id;
@dynamic hasNewActivity;
@dynamic needSend;
@dynamic isSending;
@dynamic isMute;
@dynamic isPlaceHold;
@dynamic currently_contact_edit;
@dynamic isBookMarked;

@dynamic uniqueNumber;
@dynamic needToSync;

-(void)didSave {
    [super didSave];
}

-(void)willSave {
    [super willSave];
}

- (NSDate *)dateFromInput:(id)dateInput
{
    if (dateInput == nil || [dateInput isKindOfClass:[NSDate class]]) {
        return dateInput;
    } else if ([dateInput isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)dateInput;
        long long lnumber = number.longLongValue / 1000;
        if (isnan(lnumber) || lnumber == 0) {
            return nil;
        }
        return [NSDate dateWithTimeIntervalSince1970:lnumber];
    }
    return nil;
}

- (void)updateContactsUser:(ContactsEntity *)userContact
{
    if(!self.shared_account_ids){
        return;
    }
    
    //NSLog(@"updateContactsUser mainthread? %d", [[NSThread currentThread] isMainThread]);
    
    NSArray *participators = [self.shared_account_ids componentsSeparatedByString:@","];
    NSSet *participatorSet = [NSSet setWithArray:participators];
    participators = [participatorSet allObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"account_id IN %@", participators];
    
    //NSLog(@"Querying for emails in list of participators: %@ main thread? %d", participators, [[NSThread currentThread] isMainThread]);
    
    [glbAppdel.managedObjectContext lock];
    NSManagedObjectContext *backgroundMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [backgroundMOC setPersistentStoreCoordinator:[glbAppdel.managedObjectContext persistentStoreCoordinator]];
    
    NSArray *participatingContactsNonMutable = [ContactsEntity MR_findAllWithPredicate:predicate inContext:backgroundMOC];
    [glbAppdel.managedObjectContext unlock];
    NSMutableArray *participatingContacts = [participatingContactsNonMutable mutableCopy];
    
    
    //NSLog(@"Done querying for emails contact count: %d", participatingContacts.count);
    
    /*
     for(NSString *email in participators){
     NSLog(@"Individually querying for email: %@", email);
     ContactsEntity* contactMatch = [ContactsEntity MR_findFirstByAttribute:@"email" withValue:email];
     NSLog(@"Found match? %d", contactMatch != nil);
     
     }
     */
    if(self.contacts){
        [participatingContacts addObjectsFromArray:[self.contacts allObjects]];
    }
    if(userContact){
        [participatingContacts addObject:userContact];
    }
    NSMutableArray *m = [NSMutableArray new];
    for (ContactsEntity *contact in participatingContacts) {
        ContactsEntity *entity = (ContactsEntity *)[glbAppdel.managedObjectContext existingObjectWithID:[contact objectID] error:nil];
        [m addObject:entity];
    }
    self.contacts = [NSSet setWithArray:m];
    
    //    self.contacts = [NSSet setWithArray:participatingContacts];
    
}

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues
                           withAccount:(AccountEntity *)account
{
    
    if(account.user && account.user.contact)
    {
        self.contact_id = account.user.contact.contact_id;
    }
    
    NSString *author_account_id = keyedValues[@"account_id"];
    
    if(author_account_id && author_account_id != (id)[NSNull null])
    {
        self.account_id = author_account_id;
    }
    
    NSNumber* temp_BookMark_Val = (NSNumber*)keyedValues[@"flagged"];
    
    if( temp_BookMark_Val == (id)[NSNull null])
    {
        self.isBookMarked = [NSNumber numberWithBool:false];
    }
    else
    {
        self.isBookMarked = temp_BookMark_Val;
    }
    
    NSArray *shared_account_ids = keyedValues[@"participator_account_ids"];
    
    if(shared_account_ids)
    {
        if ([shared_account_ids isKindOfClass:[NSArray class]])
        {
            self.shared_account_ids = [shared_account_ids componentsJoinedByString:@","];
        }
        else if ([shared_account_ids isKindOfClass:[NSString class]])
        {
            self.shared_account_ids = (NSString *)shared_account_ids;
        }
    }
    
    NSArray *participators = keyedValues[@"participators"];
    
    if (participators && participators.count > 0)
    {
        self.participators = [participators componentsJoinedByString:@","];
    }
    [self updateContactsUser:account.user.contact];
    
    NSString *topic = keyedValues[@"subject"];
    
    if (topic && [topic isKindOfClass:[NSString class]] && topic.length>0)
    {
        topic = [topic stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters];
        
        if (topic && topic.length > 0)
        {
            self.topic = topic;
        }
        else
        {
            self.topic = @"Untitled";
        }
    }
    else
    {
        
        NSString *changedTopic = keyedValues[@"changed_subject"];
        
        if ([changedTopic isKindOfClass:[NSString class]]) {
            
            if (changedTopic && changedTopic.length > 0)
            {
                self.topic = [changedTopic stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters];
            }
            else if (topic && [topic isKindOfClass:[NSString class]] && topic.length > 0)
            {
                self.topic = [topic stringByTrimmingLeadingAndTrailingWhitespaceAndNewlineCharacters];
            }
            else
            {
                self.topic = @"Untitled";
            }
        }
        else
        {
            if (topic && [topic isKindOfClass:[NSString class]] && topic.length > 0)
            {
                self.topic = topic;
            }
            else
            {
                self.topic = @"Untitled";
            }
        }
    }
    
    NSString *topic_id = keyedValues[@"_id"];
    
    if (topic_id)
    {
        self.topic_id = topic_id;
    }
    
    NSNumber *topic_type = keyedValues[@"topic_type"];
    
    if (topic_type)
    {
        self.topic_type = [topic_type intValue];
    }
    
    NSString *locked_id = keyedValues[@"locked_id"];
    
    if (locked_id)
    {
        self.locked_id = locked_id;
    }
    
    NSString *key_id = keyedValues[@"key_id"];
    
    if (key_id)
    {
        self.key_id = key_id;
    }
    NSString *uniquenumber=[NSString stringWithFormat:@"%@",keyedValues[@"uniqueNumber"]];
    if (uniquenumber)
    {
        self.uniqueNumber=uniquenumber;
    }
    id createdTime = keyedValues[@"created_time"];
    
    if (createdTime)
    {
        self.created_time = [self dateFromInput:createdTime];
    }
    
    id updatedTime = keyedValues[@"updated_time"];
    
    if (updatedTime)
    {
        self.updated_time = [self dateFromInput:updatedTime];
    }
    
#if 0
    NSArray *archivedAccountIDs = keyedValues[@"archived"];
    if (account.account_id && archivedAccountIDs && [archivedAccountIDs isKindOfClass:[NSArray class]] && archivedAccountIDs.count > 0) {
        if (account.belongs_account_ids && account.belongs_account_ids.length>0) {
            BOOL flag = NO;
            for (NSString *str in archivedAccountIDs) {
                NSRange range = [account.belongs_account_ids rangeOfString:str];
                if (range.location!=NSNotFound) {
                    flag = YES;
                    break;
                }
            }
            self.isArchived = @(flag);
        }
        //        if (self.isArchived.boolValue != YES) {
        //            self.isArchived = @([archivedAccountIDs containsObject:account.account_id]);
        //        }
        self.archived = [archivedAccountIDs componentsJoinedByString:@","];
    } else {
        self.isArchived = @(NO);
        self.archived = @"";
    }
#else
    
    NSArray *archivedAccountIDs = keyedValues[@"archived"];
    
    if (account.account_id
        && archivedAccountIDs
        && [archivedAccountIDs isKindOfClass:[NSArray class]]
        && archivedAccountIDs.count > 0)
    {
        self.isArchived = @([archivedAccountIDs containsObject:account.account_id]);
        self.archived = [archivedAccountIDs componentsJoinedByString:@","];
    }
    else
    {
        self.isArchived = @(NO);
        self.archived = @"";
    }
    
#endif
    //NSLog(@"Archived? %d List: %@ For topic: %@", self.isArchived.boolValue, self.archived, self.topic);
    
    NSDictionary *orderDict = keyedValues[@"order"];
    
    if(orderDict && [orderDict isKindOfClass:[NSDictionary class]])
    {
        id val = orderDict[account.user.user_id];
        
        if([val isKindOfClass:[NSString class]])
        {
            NSString *stringVal = (NSString *)val;
            val = @([stringVal integerValue]);
        }
        else if (val && [val isKindOfClass:[NSDictionary class]])
        {
            if ([val valueForKey:@"$InfNaN"])
            {
                val=@([[NSString stringWithFormat:@"%@",[val valueForKey:@"$InfNaN"]] integerValue]);
            }
            else
            {
                val=@(1);
            }
        }
        @try {
            self.order = val;
        }
        @catch (NSException *exception) {
            NSLog(@"See order exception");
            NSLog(@"See order exception%@",exception.name);
            
        }
        @finally {
            self.order=@([[NSString stringWithFormat:@"%@",val] integerValue]);
        }
        
    }
    else if([orderDict isKindOfClass:[NSNumber class]])
    {
        
        self.order = (NSNumber *)orderDict;
    }
    else
    {
        self.order = nil;
    }
    
    NSArray *viewers = keyedValues[@"viewers"];
    
    if (viewers && [viewers isKindOfClass:[NSArray class]])
    {
        self.viewers = [viewers componentsJoinedByString:@","];
    }
    else if (viewers && [viewers isKindOfClass:[NSString class]])
    {
        self.viewers = (NSString *)viewers;
    }
    else
    {
        self.viewers = @"";
    }
    
    if(account.account_id)
    {
        self.hasNewActivity = @([self.viewers rangeOfString:account.account_id].location == NSNotFound);
    }
    else
    {
        self.hasNewActivity = @(NO);
    }
    
    self.isMute = @(NO);
    
    NSArray *muteForPhone = keyedValues[@"muteForPhone"];
    
    if ( muteForPhone && [muteForPhone count]>0 )
    {
        NSString *mutes = [muteForPhone componentsJoinedByString:@","];
        
        if (account.account_id)
        {
            if ([muteForPhone count]==1)
            {
                self.isMute = @([mutes isEqualToString:account.account_id]);
            }
            else
            {
                self.isMute = @([mutes rangeOfString:account.account_id].location == NSNotFound);
            }
        }
    }
}

- (NSMutableDictionary *)dictionaryValue
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (self.topic_id) {
        dict[@"_id"] = self.topic_id;
    }
    
    if (self.account_id) {
        dict[@"account_id"] = self.account_id;
    }
    
    if (self.shared_account_ids) {
        dict[@"participator_account_ids"] = [[[NSOrderedSet orderedSetWithArray:[self.shared_account_ids componentsSeparatedByString:@","]] array] copy];
    } else if (self.account_id) {
        dict[@"participator_account_ids"] = @[self.account_id];
    }
    
    NSLog(@"participator_account_ids: %@", dict[@"participator_account_ids"]);
    
    NSLog(@"dictionary_value topic subject: %@ isFault: %d", self.topic, [self isFault]);
    if(self.isFault){
        [self MR_refresh];
        NSLog(@"dictionary_value after refresh topic subject: %@ isFault: %d", self.topic, [self isFault]);
    }
    
    dict[@"status"] = @"POSTED";
    
    dict[@"subject"] = self.topic;
    dict[@"topic_type"] = @(self.topic_type);
    
    if (self.locked_id) {
        dict[@"locked_id"] = self.locked_id;
    }
    if (self.key_id) {
        dict[@"key_id"] = self.key_id;
    }
    
    dict[@"cname"] = @"topics";
    dict[@"created_time"] = self.created_time;
    dict[@"updated_time"] = @(1000.0 * [self.updated_time timeIntervalSince1970]);
    
    
    dict[@"liked_account_ids"] = @[];
    dict[@"likes_count"] = @(0);
    dict[@"archived"] = [[NSSet setWithArray:[self.archived componentsSeparatedByString:@","]] allObjects];
    //dict[@"participators"] = [[NSSet setWithArray:[self.participators componentsSeparatedByString:@","]] allObjects];
    dict[@"viewers"] = self.viewers ? [self.viewers componentsSeparatedByString:@","] : @[];
    
    NSLog(@"new topic order_to_set: %@ order_user_id: %@ account_id: %@", self.order_to_set, self.order_user_id, self.account_id);
    
    if(self.order_to_set != nil && self.order_user_id && self.account_id)
    {
        dict[@"order"] = @{self.order_user_id : self.order_to_set};
    }
    
    NSLog(@"new topic order: %@", dict[@"order"]);
    
    //Additional fields added
    //dict[@"uneditable"] = @(NO);
    
    
    
    return dict;
}

- (void)UpdateOrder:(NSString*)order
{
    NSString *account_id = [DataManager sharedInstance].currentAccount.account_id;
    
    [[AppDelegate sharedDelegate] sendUpdatedTopicOrder:self.topic_id
                                              accountID:account_id
                                              OrderRank:order
                                                  reset:NO];
    
}
- (void)markViewed
{
    NSString *account_id = [DataManager sharedInstance].currentAccount.account_id;
    
    if (!account_id)
    {
        return;
    }
    
    NSArray *currentViewers = self.viewers ? [self.viewers componentsSeparatedByString:@","] : @[];
    
    NSMutableSet *currentViewersSet = [[NSSet setWithArray:currentViewers] mutableCopy];
    
    [currentViewersSet addObject:account_id];
    
    NSArray *viewers = [currentViewersSet allObjects];
    
    self.viewers = [viewers componentsJoinedByString:@","];
    
    self.hasNewActivity = @(NO);
    
    [AppDelegate saveContext];
    
    double delayInSeconds = 0.0;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [[AppDelegate sharedDelegate] sendUpdatedTopicViewed:self.topic_id
                                                   accountID:account_id
                                                       reset:NO];
        
    });
}

- (void)createdNewActivity
{
    NSString *account_id = [DataManager sharedInstance].currentAccount.account_id;
    
    self.viewers = account_id;
    self.hasNewActivity = @(NO);
    
    [AppDelegate saveContext];
    
    double delayInSeconds = 0.0;
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [[AppDelegate sharedDelegate] sendUpdatedTopicViewed:self.topic_id
                                                   accountID:account_id
                                                       reset:YES];
        
    });
    
}


@end
