//
//  UserEntity.h
//  RevealControllerProject
//
//  Created by backup on 13-11-16.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContactsEntity;

@interface UserEntity : NSManagedObject{
@private;
    NSString *_password;
}

@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * user_id;
@property (nonatomic, strong) ContactsEntity * contact;
@property (nonatomic, strong) NSNumber * logout;
//Not stored in Core Data but in Keychain
@property (nonatomic, retain) NSString *password;

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues;

- (NSString *)getFirstEmail;

@end
