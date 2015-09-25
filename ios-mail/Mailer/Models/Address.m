//
//  Address.m
//  Mailer
//
//  Created by Martin Ceperley on 10/17/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "Address.h"
#import "Account.h"
#import "Message.h"
#import <AddressBook/AddressBook.h>
//#import "MMailManager.h"

@implementation Address

@dynamic name;
@dynamic email;
@dynamic abRecordID;
@dynamic account;
@dynamic messagesFrom;
@dynamic messagesTo;
@dynamic messagesCC;
@dynamic messagesBCC;
@dynamic messagesReplyTo;
@dynamic message;
+ (Address *)addressWithEmail:(NSString *)email name:(NSString *)name context:(NSManagedObjectContext *)context
{
    Address *address = [Address findFirstByAttribute:@"email" withValue:email inContext:context];
    if (address == nil) {
        
        address = [Address MR_createInContext:context];
        address.name = name;
        address.email = email;
        //        address.account = [MMailManager sharedManager].currentAccount;
    }
    return address;
}

+ (Address *)addressWithEmail:(NSString *)email name:(NSString *)name
{
    Address *address = [Address findFirstByAttribute:@"email" withValue:email];
    if (address == nil) {
        
        address = [Address createEntity];
        address.name = name;
        address.email = email;
//        address.account = [MMailManager sharedManager].currentAccount;
    }
    return address;
}
+ (NSArray *)addressesFromMCOAddresses:(NSArray *)mcoAddresses context:(NSManagedObjectContext *)context
{
    NSMutableArray* addresses = [[NSMutableArray alloc] initWithCapacity:mcoAddresses.count];
    for (MCOAddress *mcoAddress in mcoAddresses) {
        [addresses addObject:[Address addressWithEmail:mcoAddress.mailbox name:mcoAddress.displayName context:context]];
    }
    return [addresses copy];
}
+ (NSArray *)addressesFromMCOAddresses:(NSArray *)mcoAddresses
{
    NSMutableArray* addresses = [[NSMutableArray alloc] initWithCapacity:mcoAddresses.count];
    for (MCOAddress *mcoAddress in mcoAddresses) {
        [addresses addObject:[Address addressWithEmail:mcoAddress.mailbox name:mcoAddress.displayName]];
    }
    return [addresses copy];
}

- (void) findAddressBookContactByEmail
{
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, NULL);
    NSArray *allPeople = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeople(addressBook));
    NSMutableDictionary *emailsDict = [[NSMutableDictionary alloc] init];
    
    //NSLog(@"ADDRESS BOOK people count %lu", (unsigned long)allPeople.count);
    for (id record in allPeople) {
        ABRecordRef abRecord = (__bridge ABRecordRef)record;
        ABRecordID recordID = ABRecordGetRecordID(abRecord);
        ABMultiValueRef emails = ABRecordCopyValue(abRecord, kABPersonEmailProperty);
        for (CFIndex i = 0; i < ABMultiValueGetCount(emails); i++) {
            NSString* email = (__bridge_transfer NSString*) ABMultiValueCopyValueAtIndex(emails, i);
            NSString* emailLower = [email lowercaseString];
            [emailsDict setObject:@(recordID) forKey:emailLower];
        }
        CFRelease(emails);
    }
    
    //NSLog(@"ADDRESS BOOK emails count %lu", (unsigned long)emailsDict.count);
    
    NSNumber* usersID = [emailsDict objectForKey:self.email.lowercaseString];
    if (usersID != nil) {
        ABRecordRef record = ABAddressBookGetPersonWithRecordID(addressBook, usersID.intValue);
        if (record != nil) {
            
//            NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonFirstNameProperty));
//            NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(record, kABPersonLastNameProperty));
            //NSLog(@"ADDRESS BOOK found match %@ %@ %@", firstName, lastName, usersID);
            
            self.abRecordID = (int32_t)usersID.integerValue;
            
        } else {
            //NSLog(@"ADDRESS BOOK didnt find match record was nil");
        }
    } else {
        //NSLog(@"ADDRESS BOOK didnt find match for email address");

    }
}

- (MCOAddress *) mcoAddress
{
    return [MCOAddress addressWithDisplayName:self.name mailbox:self.email];
}

- (NSString *) pathString
{
    if (self.email == nil || self.email.length < 3){
        return @"";
    }
    if (self.name && self.name.length > 0) {
        return [NSString stringWithFormat:@"%@ <%@>", self.name, self.email];
    }
    return [NSString stringWithFormat:@"<%@>", self.email];
}


@end
