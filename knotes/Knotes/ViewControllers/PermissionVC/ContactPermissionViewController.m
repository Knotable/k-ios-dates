//
//  ContactPermissionViewController.m
//  Knotes
//
//  Created by Chunji on 9/15/15.
//
//

#import "ContactPermissionViewController.h"
#import <AddressBook/AddressBook.h>

@implementation ContactPermissionViewController
- (IBAction)setContactPermission:(id)sender {
    
    // Request authorization to Address Book
    ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
    ABAuthorizationStatus status = ABAddressBookGetAuthorizationStatus();
    if (status == kABAuthorizationStatusNotDetermined)
    {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                // First time access has been granted, add the contact

            } else {
                // User denied access
                // Display an alert telling user the contact could not be added
            }

            [self showNextPermission];
        });
    }
    else if (status == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
//        [self showAlertWithMessage: @"It has been allowed."];
        [self showNextPermission];
    }
    else {
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
//        [self showAlertWithMessage: @"It is denied acces.\nYou can change privacy setting in settings app."];
        [self showNextPermission];
    }
}

- (void) showAlertWithMessage:(NSString*) message
{
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showNextPermission];
    }];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"Location" message: message preferredStyle: UIAlertControllerStyleAlert];
    [alert addAction: okAction];
    [self presentViewController: alert animated: YES completion:^{
        
    }];
}

- (void) showNextPermission
{
    [self performSegueWithIdentifier: @"showPhotoPermission" sender: nil];
}

@end
