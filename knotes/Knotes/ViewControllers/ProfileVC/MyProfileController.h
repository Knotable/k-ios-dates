//
//  MyProfileController.h
//  Knotable
//
//  Created by Martin Ceperley on 1/2/14.
//
//

//NSLog(@"login took: %f login error: %@ response: %@", timeTook,error, response);

#import "PostingManager.h"
#import "MZFormSheetController.h"

@class AccountEntity, ContactsEntity,TopicsEntity,UserEntity;

typedef enum {
    RemoveFromPad,
    RemoveFromContact,
    RemoveFromNone,
} RemoveButtonType;

@protocol MyProfileDelegateProtocol <NSObject>

@optional

-(void) updateSharedTopicContact:(ContactsEntity*)usertoAdd Removed:(BOOL)bRemove;
-(void) updateSharedTopicContacts;
-(void) removedContact:(ContactsEntity*)contact;
-(void) removedContactFromPad:(ContactsEntity*)contact;

@end

@interface MyProfileController : UIViewController <UITableViewDelegate, UITableViewDataSource>

- (id)initWithAccount:(AccountEntity *)account;
- (id)initWithContact:(ContactsEntity *)contact;

@property (nonatomic,strong)    UserEntity *login_user;
@property (nonatomic,strong)    TopicsEntity *topic;

@property (nonatomic, weak)     id<MyProfileDelegateProtocol> delegate;

@property (nonatomic,assign)    RemoveButtonType profile_remove_buttonType;

@property (nonatomic, strong)   NSArray *sharedContacts;
@property (weak, nonatomic)     IBOutlet UIImageView *blurredProfileImageView;
@property (nonatomic, strong)   IBOutlet UIButton *btn_remove_contact;

@property (nonatomic)BOOL   bDisplayMenu;

-(IBAction)removeContact:(UIButton*)sender;

- (void) loadProfileImage : (UIImage* )profileImage;
- (void) updateProfileImage;
- (UIImage* ) generatePlaceHolderImage;

@end
