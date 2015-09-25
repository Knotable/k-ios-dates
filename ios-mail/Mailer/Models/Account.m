//
//  Account.m
//  Mailer
//
//  Created by Martin Ceperley on 10/1/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "Account.h"
#import "Address.h"
#import "Message.h"
#import "Folder.h"
#import "MDataManager.h"
#import "FXKeychain.h"

@implementation Account

@dynamic hostname;
@dynamic lastLoggedIn;
@dynamic port;
@dynamic username;
@dynamic name;
@dynamic messages;
@dynamic address;
@dynamic folders;
@dynamic inbox;
@dynamic status;

+ (Account *)gmailAccountWithUsername:(NSString *)username password:(NSString *)password
{
    //NSLog(@"gmailAccountWithUsername");
    
    Account *account = [Account createEntity];
    
    account.hostname = @"imap.gmail.com";
    account.port = [NSNumber numberWithInteger:993];
    account.username = username;
    account.lastLoggedIn = [NSDate date];
    account.address = [Address addressWithEmail:username name:nil];
    account.status = YES;
    
    [account setPassword:password];

    Folder *inbox = [Folder createEntity];
    inbox.name =@"INBOX";// @"[Gmail]/Drafts";
    inbox.account = account;
    account.inbox = inbox;

    
    //NSLog(@"saving new account");
    [[MDataManager sharedManager] saveContextAsyncCompletion:^(BOOL success, NSError *error) {
        //[account setPassword:password];
        //NSLog(@"saved new account");
    }];

    return account;
}
+ (Account *)setAccount:(Account*)account WithUsername:(NSString *)username password:(NSString *)password
{
    //NSLog(@"gmailAccountWithUsername");
    
    
    account.hostname = @"imap.gmail.com";
    account.port = [NSNumber numberWithInteger:993];
    account.username = username;
    account.lastLoggedIn = [NSDate date];
    account.address = [Address addressWithEmail:username name:nil];
    account.status = YES;
    
    [account setPassword:password];
    
    Folder *inbox = [Folder createEntity];
    inbox.name =@"INBOX";// @"[Gmail]/Drafts";
    inbox.account = account;
    account.inbox = inbox;
    
    
    //NSLog(@"saving new account");
    [[MDataManager sharedManager] saveContextAsyncCompletion:^(BOOL success, NSError *error) {
        //[account setPassword:password];
        //NSLog(@"saved new account");
    }];
    
    return account;
}
+ (Account *)lastAccount
{
    Account *account = [Account findFirstOrderedByAttribute:@"lastLoggedIn" ascending:NO];
    return account;
}

//+ (Account *)selectedUser : (NSString *)username {
//    
//
////     NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(username = %@ and status = YES)",username];
//    
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(username = %@)",username];
//    
//    MDataManager *dataManager = [MDataManager sharedManager];
//    NSManagedObjectContext *managedObjectContext = dataManager.managedObjectContext;
//
//    
//        NSFetchRequest *request = [[NSFetchRequest alloc] init];
//        NSEntityDescription *sysCounters = [NSEntityDescription entityForName:@"Account" inManagedObjectContext:managedObjectContext];
//        [request setEntity:sysCounters];
//
//        [request setPredicate:predicate];
//
//        NSError *error = nil;
//        NSArray *results = [managedObjectContext executeFetchRequest:request error:&error];
//    
//        for (NSManagedObject *studentRecord in results) {
//
//            [studentRecord setValue:YES forKey:@"status"];
//            
//            [delegate.managedObjectContext save:&error];
//        }
//
//    
//    
//
//    
//    Account *account = [Account findFirstWithPredicate:predicate ];
//    return account;
//
//}

+(Account *)selectedUser : (NSString *)username{
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(username = %@)",username];
    
    Account *account = [Account findFirstWithPredicate:predicate ];
    return account;
}

- (NSString *)accountID
{
    NSString *acct = [NSString stringWithFormat:@"%@@%@:%@", self.username, self.hostname, self.port];
    //NSLog(@"accountID: %@", acct);
    return acct;
    /*
    if([self.objectID isTemporaryID]){
        //NSLog(@"ERROR: accountID isTemporaryID");
        return nil;
    }
    return self.objectID.URIRepresentation.absoluteString;
     */
}

- (NSString *)password
{
    if (_password != nil) {
        return _password;
    }
    _password = [[[FXKeychain defaultKeychain] objectForKey:[self accountID]] copy];
    return _password;
}


- (void)setPassword:(NSString *)password
{
    _password = [password copy];
    [[FXKeychain defaultKeychain] setObject:password forKey:[self accountID]];
}



@end
