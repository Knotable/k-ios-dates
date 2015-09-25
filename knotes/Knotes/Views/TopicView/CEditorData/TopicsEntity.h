//
//  TopicsEntity.h
//  RevealControllerProject
//
//  Created by backup on 13-11-15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ContactsEntity;
@class AccountEntity;

@interface TopicsEntity : NSManagedObject

@property (nonatomic, strong) NSString* participators;
@property (nonatomic, strong) NSString* topic;
@property (nonatomic, strong) NSString* topic_id;
@property (nonatomic, strong) NSString* contact_id;
@property (nonatomic, strong) NSString* locked_id;
@property (nonatomic, strong) NSString* key_id;
@property (nonatomic, assign) int16_t   topic_type;
@property (nonatomic, strong) NSDate*   created_time;
@property (nonatomic, strong) NSDate*   updated_time;
@property (nonatomic, strong) NSString* archived;
@property (nonatomic, strong) NSNumber* isArchived;
@property (nonatomic, strong) NSNumber* order;
@property (nonatomic, strong) NSString* viewers;
@property (nonatomic, strong) NSSet*    contacts;
@property (nonatomic, strong) NSString* account_id;
@property (nonatomic, strong) NSString* shared_account_ids;
@property (nonatomic, strong) NSString* currently_contact_edit;
@property (nonatomic,strong) NSString *uniqueNumber;

@property (nonatomic, strong) NSNumber* needSend;
@property (nonatomic, strong) NSNumber* needToSync;
@property (nonatomic, strong) NSNumber * isSending;


@property (nonatomic, assign) int position;
@property (nonatomic, strong) NSNumber *order_to_set;
@property (nonatomic, strong) NSString *order_user_id;

@property (nonatomic, strong) NSNumber *hasNewActivity;

@property (nonatomic, strong) NSNumber *isMute;

@property (nonatomic, assign) int16_t isPlaceHold;

@property (nonatomic, retain) NSNumber * isBookMarked;

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues
                           withAccount:(AccountEntity *)account;

- (NSMutableDictionary *)dictionaryValue;
- (void)updateContactsUser:(ContactsEntity *)userContact;
- (void)UpdateOrder:(NSString*)order;
- (void)markViewed;
- (void)createdNewActivity;

@end
