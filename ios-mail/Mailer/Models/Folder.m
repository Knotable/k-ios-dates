//
//  Folder.m
//  Mailer
//
//  Created by Martin Ceperley on 10/1/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "Folder.h"
#import "Account.h"
#import "Message.h"
#import "MDataManager.h"
#import "MMailManager.h"
#import "Debug.h"


@implementation Folder

@dynamic name;
@dynamic path;
@dynamic delimiter;
@dynamic unreadCount;
@dynamic messageCount;
@dynamic modSeq;
@dynamic uidValidity;
@dynamic uidNext;
@dynamic account;
@dynamic messages;
@dynamic firstUnseenUid;
#if FOLDER_DEBUG
@dynamic firstUID;
@dynamic lastUID;
#else
#endif


- (NSInteger)getUIDlimitsMax:(BOOL)isMax
{
    //isMax should be true for max UID, false for min UID
    
    Account *account = [[MMailManager sharedManager] getCurrentAccount];
    Folder *folder = [[MMailManager sharedManager] getCurrentFolder];
    
//    NSLog(@"account = %@",account.username);
//    NSLog(@"folder = %@",folder.name);

    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account = %@ AND account.status = YES AND folder = %@", account,folder];
    
//    NSFetchRequest* request = [[NSFetchRequest alloc] initWithEntityName:@"Message"];
//    [request setPredicate:predicate];
//    
//    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"uid" ascending:!isMax]];
//    
//    request.fetchLimit = 1;
//    NSArray *array = [[self managedObjectContext] executeFetchRequest:request error:NULL];
//    if ([array count] < 1) {
//        return 0;
//    }
//    
//    Message* message = [array firstObject];
    Message* message = [Message MR_findFirstWithPredicate:predicate sortedBy:@"uid" ascending:!isMax];
//    NSLog(@"message %@",message);
    
//    NSLog(@"Message (%d) subject: %@", message.uid.integerValue, message.subject);
    return message.uid.unsignedIntegerValue;
}
#if FOLDER_DEBUG

#else
- (NSInteger)firstUID
{
    NSInteger firstUID = [self getUIDlimitsMax:NO];
    NSLog(@"firstUID:%ld",(long)firstUID);
    return firstUID;
}
- (NSInteger)lastUID
{
    NSInteger lastUID = [self getUIDlimitsMax:YES];
    NSLog(@"lastUID:%ld",(long)lastUID);
    return lastUID;
}
#endif
- (MCOIndexSet *)rangeOfStoredUIDs
{
    //NSLog(@"starting rangeOfStoredUIDs");
    NSInteger minUID = [self firstUID];
    NSInteger maxUID = [self lastUID];
    //NSLog(@"ending rangeOfStoredUIDs %ld - %ld", (long)minUID, (long)maxUID);
    
    return [MCOIndexSet indexSetWithRange:MCORangeMake(minUID, maxUID-minUID)];
}

- (void)updateWithInfo:(MCOIMAPFolderInfo *)info{
    
    self.uidNext = info.uidNext;
    self.uidValidity = info.uidValidity;
    self.modSeq = info.modSequenceValue;
    self.messageCount = info.messageCount;
    self.firstUnseenUid = info.firstUnseenUid;
//    NSLog(@"saveContext Folder updateWithInfo");
//    [[MDataManager sharedManager] saveContextAsync];
}

- (void)updateWithStatus:(MCOIMAPFolderStatus *)info{
    self.uidNext = info.uidNext;
    self.uidValidity = info.uidValidity;
    self.messageCount = info.messageCount;
//    NSLog(@"saveContext Folder updateWithStatus");
    [[MDataManager sharedManager] saveContextAsync];
}


@end
