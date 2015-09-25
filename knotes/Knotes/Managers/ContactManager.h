//
//  ContactManager.h
//  Knotable
//
//  Created by Martin Ceperley on 5/6/14.
//
//

#import "MLPAutoCompleteTextField.h"
#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>
#import "ObjCMongoDB.h"
#import "Utilities.h"
#import "ShareListController.h"
#import "AJNotificationView.h"

typedef void (^DownloadContactCompletion)(WM_NetworkStatus success, NSError *error, id userData);

@class OMPromise;

@interface ContactManager : NSObject <UIActionSheetDelegate, ABPeoplePickerNavigationControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIAlertViewDelegate, MLPAutoCompleteTextFieldDataSource>

+ (ContactManager *)sharedInstance;

+ (OMPromise *)doesUserExist:(NSString *)emailOrUsername;
+ (OMPromise *)addNewContact:(NSString *)email username:(NSString *)username;

- (OMPromise *)startAddPerson:(UIViewController *)vc;

- (void)performRemoteEmailAdd:(NSString *)email;
- (void)performRemoteUsernameAdd:(NSString *)username;
+ (void)findContactFromServerByAccountId:(NSString *)account_id withNofication:(NSString *)notiStr withCompleteBlock:(DownloadContactCompletion)block;
+ (void)findContactFromServerByEmail:(NSString *)email;

@end
