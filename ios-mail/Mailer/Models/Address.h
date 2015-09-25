//
//  Address.h
//  Mailer
//
//  Created by Martin Ceperley on 10/17/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, Message, MCOAddress;

@interface Address : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * email;
@property (nonatomic) int32_t abRecordID;
@property (nonatomic, retain) Account *account;
@property (nonatomic , retain) Message *message;
@property (nonatomic, retain) NSSet *messagesFrom;
@property (nonatomic, retain) NSSet *messagesTo;
@property (nonatomic, retain) NSSet *messagesCC;
@property (nonatomic, retain) NSSet *messagesBCC;
@property (nonatomic, retain) NSSet *messagesReplyTo;


+ (Address *)addressWithEmail:(NSString *)email name:(NSString *)name context:(NSManagedObjectContext *)context;
+ (Address *)addressWithEmail:(NSString *)email name:(NSString *)name;
+ (NSArray *)addressesFromMCOAddresses:(NSArray *)mcoAddresses context:(NSManagedObjectContext *)context;
+ (NSArray *)addressesFromMCOAddresses:(NSArray *)mcoAddresses;

- (MCOAddress *) mcoAddress;

- (NSString *) pathString;

@end

@interface Address (CoreDataGeneratedAccessors)

- (void)addMessagesFromObject:(Message *)value;
- (void)removeMessagesFromObject:(Message *)value;
- (void)addMessagesFrom:(NSSet *)values;
- (void)removeMessagesFrom:(NSSet *)values;

- (void)addMessagesToObject:(Message *)value;
- (void)removeMessagesToObject:(Message *)value;
- (void)addMessagesTo:(NSSet *)values;
- (void)removeMessagesTo:(NSSet *)values;

- (void)addMessagesCCObject:(Message *)value;
- (void)removeMessagesCCObject:(Message *)value;
- (void)addMessagesCC:(NSSet *)values;
- (void)removeMessagesCC:(NSSet *)values;

- (void)addMessagesBCCObject:(Message *)value;
- (void)removeMessagesBCCObject:(Message *)value;
- (void)addMessagesBCC:(NSSet *)values;
- (void)removeMessagesBCC:(NSSet *)values;

- (void)addMessagesReplyToObject:(Message *)value;
- (void)removeMessagesReplyToObject:(Message *)value;
- (void)addMessagesReplyTo:(NSSet *)values;
- (void)removeMessagesReplyTo:(NSSet *)values;

@end
