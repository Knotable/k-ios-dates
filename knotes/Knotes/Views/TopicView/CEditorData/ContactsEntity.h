//
//  ContactsEntity.h
//  RevealControllerProject
//
//  Created by backup on 13-11-15.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
typedef void (^AsyncGetImage)(id img,BOOL flag);

@class UserEntity;

@interface ContactsEntity : NSManagedObject

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * email;
@property (nonatomic, strong) NSString * mainEmail;
@property (nonatomic, strong) NSString * contact_id;
@property (nonatomic, strong) NSString * me_id;//for parcipator
@property (nonatomic, strong) NSString * bgcolor;
@property (nonatomic) int32_t cid;
@property (nonatomic) int32_t order;
@property (nonatomic) Boolean gravatar_exist;
@property (nonatomic, strong) NSData *avatar;
@property (nonatomic, strong) UserEntity * user;
@property (nonatomic, strong) NSString * phone;
@property (nonatomic, strong) NSString * website;
@property (nonatomic, strong) NSString * twitter_link;
@property (nonatomic, strong) NSString * facebook_link;
@property (nonatomic, strong) NSString * account_id;
@property (nonatomic, strong) NSNumber * archived;
@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSNumber * total_topics;
@property (nonatomic, strong) NSNumber * position;
@property (nonatomic, strong) NSString * fullURL;
@property (nonatomic, strong) NSString * miniURL;
@property (nonatomic, strong) NSSet * messages;
@property (nonatomic, strong) NSSet * topics;

@property (nonatomic, assign) NSNumber * isMe;

+ (ContactsEntity *)contactWithDict:(NSDictionary *)dict inContext:(NSManagedObjectContext *)context;
+ (ContactsEntity *)contactWithDict:(NSDictionary *)dict;

- (void)setValuesForKeysWithDictionary:(NSDictionary *)keyedValues;
-(void)addNewMail:(NSString *)mail;

- (NSString *)userImageName;

- (NSString *)getFirstEmail;

// functions to download real profile images
- (void)getAsyncImageWithBlock:(AsyncGetImage)block;
+ (void)getAsyncImage:(ContactsEntity *)entity WithBlock:(AsyncGetImage)block;

// functioins to generate the avatar image with contact name
- (void)getPlaceholderImageWithBlock:(AsyncGetImage)block;
+ (void)getPlaceholderImage:(ContactsEntity *)entity WithBlock:(AsyncGetImage)block;


- (void)oldAsyncImageWithBlock:(AsyncGetImage)block;
- (void)newAsyncImageWithBlock:(AsyncGetImage)block;
- (void)newAsyncFullImageWithBlock:(AsyncGetImage)block;
- (void)newAsyncMiniImageWithBlock:(AsyncGetImage)block;
- (void)newAsyncAvatarImageWithBlock:(AsyncGetImage)block;

+ (void)oldAsyncImage:(ContactsEntity *)entity WithBlock:(AsyncGetImage)block;
+ (void)newAsyncImage:(ContactsEntity *)entity WithBlock:(AsyncGetImage)block;

+ (void)newAsyncFullImage:(ContactsEntity *)entity WithBlock:(AsyncGetImage)block;
+ (void)newAsyncMiniImage:(ContactsEntity *)entity WithBlock:(AsyncGetImage)block;
+ (void)newAsyncAvatarImage:(ContactsEntity *)entity WithBlock:(AsyncGetImage)block;

- (UIImage *)getImageByUserName;

- (BOOL) isValidURL:(NSString *)checkURL;

@end
