//
//  ProfileDetailVC.h
//  Knotable
//
//  Created by darshana on 09/08/14.
//
//

#import <UIKit/UIKit.h>
#import "ConnectGoogleController.h"
#import "FileInfo.h"
#import "CombinedViewController.h"
#import <MessageUI/MessageUI.h>

@class AccountEntity, ContactsEntity;

@interface ProfileDetailVC : UIViewController <UITableViewDataSource,
                                                UITableViewDelegate,
                                                UITextFieldDelegate,
                                                UIImagePickerControllerDelegate,
                                                UINavigationControllerDelegate,
                                                UIActionSheetDelegate,
                                                ConnectGoogleDelegate,MFMailComposeViewControllerDelegate>
{
    UIActivityIndicatorView *Spinnerview;
    
    BOOL    isPhotoUpdated;
}

@property (nonatomic, strong) AccountEntity     *account;
@property (nonatomic, strong) UserEntity        *user;

@property (nonatomic, strong) UIImageView * spinnerImageView;
@property (nonatomic, strong) CombinedViewController * logOUTInstance;
// Utilify Functions

- (id) initWithAccount:(AccountEntity *)account;
- (id) initWithContact:(ContactsEntity *)contact;

- (IBAction) onEdit;
- (IBAction) connectGoogle;
- (IBAction)tapOnHelp:(id)sender;

- (void) uploadProfilePhoto;
- (void) SaveProfileInfo;
- (void) unlinkGoogle;
- (void) setupImageRefreshControl;
- (void) loadProfileImage : (UIImage* )profileImage;
- (void) updateProfileImage;

- (NSMutableDictionary *) passwordDictionary;
- (UIImage* ) generatePlaceHolderImage;

@end
