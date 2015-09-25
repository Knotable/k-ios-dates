//
//  MyProfileController.h
//  Knotable
//
//  Created by Martin Ceperley on 1/2/14.
//
//


#import "ConnectGoogleController.h"
@class AccountEntity, ContactsEntity;
@protocol MyProfileDelegateProtocol <NSObject>

@optional

-(void) updateSharedTopicContact:(ContactsEntity*)usertoAdd Removed:(BOOL)bRemove;
-(void)SelectedProfileMenu:(UIButton*)MenuItem;
@end


@interface MyProfileController : UIViewController <UITextFieldDelegate, ConnectGoogleDelegate,UITableViewDelegate>

- (id)initWithAccount:(AccountEntity *)account;
- (id)initWithContact:(ContactsEntity *)contact;
-(IBAction)RemoveFromPad:(UIButton*)sender;
@property (nonatomic, strong) IBOutlet UIButton *removeFromPad;
@property (nonatomic, weak) id<MyProfileDelegateProtocol> delegate;
@property (nonatomic)BOOL bDisplayMenu;
@end
