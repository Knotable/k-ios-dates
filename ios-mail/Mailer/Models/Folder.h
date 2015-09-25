//
//  Folder.h
//  Mailer
//
//  Created by Martin Ceperley on 10/1/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#define FOLDER_DEBUG 0

@class Account, Message, MCOIMAPFolderInfo, MCOIMAPFolderStatus, MCOIndexSet;

@interface Folder : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * path;
@property (nonatomic, retain) NSString * delimiter;
@property (nonatomic) int32_t unreadCount;
@property (nonatomic) int32_t messageCount;
@property (nonatomic) int64_t modSeq;
@property (nonatomic) int32_t uidValidity;
@property (nonatomic) int32_t uidNext;
@property (nonatomic) int32_t firstUnseenUid;
#if FOLDER_DEBUG
@property (nonatomic) int64_t firstUID;
@property (nonatomic) int64_t lastUID;
#endif
@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) NSSet *messages;

- (void)updateWithInfo:(MCOIMAPFolderInfo *)info;
- (void)updateWithStatus:(MCOIMAPFolderStatus *)info;

- (MCOIndexSet *)rangeOfStoredUIDs;
#if FOLDER_DEBUG
#else
- (NSInteger)firstUID;
- (NSInteger)lastUID;
#endif


@end

@interface Folder (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
