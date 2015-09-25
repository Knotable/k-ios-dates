//
//  AccountEntity.h
//  RevealControllerProject
//
//  Created by Martin Ceperley on 11/22/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class UserEntity;

@interface AccountEntity : NSManagedObject

@property (nonatomic, retain) NSDate * lastLoggedIn;
@property (nonatomic, retain) UserEntity *user;
@property (nonatomic, retain) NSNumber *loggedIn;
@property (nonatomic, retain) NSString *account_id;
@property (nonatomic, retain) NSNumber *google_linked;
@property (nonatomic, retain) NSString *google_id;
@property (nonatomic, retain) NSString *google_user_id;
@property (nonatomic,retain) NSNumber* notificationStatus;
@property (nonatomic, retain) NSString *lastNotification;
@property (nonatomic, retain) NSString *hashedToken;
@property (nonatomic, retain) NSDate *expireDate;
@property (nonatomic, retain) NSString *belongs_account_ids;
- (void)setTokenInfo:(NSDictionary *)dic;

- (void)checkIfUserHasGoogle;

- (void)saveUserPassword:(NSString *)password;
@end
