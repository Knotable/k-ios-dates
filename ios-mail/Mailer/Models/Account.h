//
//  Account.h
//  Mailer
//
//  Created by Martin Ceperley on 10/1/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Address, Message, Folder;

@interface Account : NSManagedObject{
    @private;
    NSString *_password;
}

@property (nonatomic, retain) NSString * hostname;
@property (nonatomic, retain) NSDate * lastLoggedIn;
@property (nonatomic, retain) NSNumber * port;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet  * messages;
@property (nonatomic, retain) NSSet  * folders;
@property (nonatomic, retain) Address *address;
@property (nonatomic, retain) Folder *inbox;
@property (nonatomic) BOOL status;


//Fetched from keychain
@property (nonatomic, retain) NSString *password;

+ (Account *)gmailAccountWithUsername:(NSString *)username password:(NSString *)password;
+ (Account *)setAccount:(Account*)account WithUsername:(NSString *)username password:(NSString *)password;
- (NSString *)accountID;

+ (Account *)lastAccount;

+ (Account *)selectedUser : (NSString *)username;

//+(Account *)changeStatus : (NSString *)username;


@end
@interface Account (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

- (void)addFoldersObject:(Folder *)value;
- (void)removeFoldersObject:(Folder *)value;
- (void)addFolders:(NSSet *)values;
- (void)removeFolders:(NSSet *)values;

@end
