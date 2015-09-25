//
//  CalendarPermissionViewController.m
//  Knotes
//
//  Created by Chunji on 9/15/15.
//
//

#import "CalendarPermissionViewController.h"
#import <EventKit/EventKit.h>

@implementation CalendarPermissionViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    self.navigationController.navigationBarHidden = YES;
}

- (IBAction)setCalendarPermission:(id)sender {
    EKEventStore* eventStore = [EKEventStore new];
    
    EKAuthorizationStatus authorizationStatus = [EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent];
   
    if (authorizationStatus == EKAuthorizationStatusNotDetermined) {
        [eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (granted) {

            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self showNextPermission];
            });
        }];
    } else if (authorizationStatus == EKAuthorizationStatusAuthorized) {
        // You can use the event store now
//        [self showAlertWithMessage: @"It has been allowed."];
        [self showNextPermission];
    } else {
        // Access denied
//        [self showAlertWithMessage: @"It is denied acces.\nYou can change privacy setting in settings app."];
        [self showNextPermission];
    }
}

- (void) showAlertWithMessage:(NSString*) message
{
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style: UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self showNextPermission];
    }];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle: @"Calendar" message: message preferredStyle: UIAlertControllerStyleAlert];
    [alert addAction: okAction];
    [self presentViewController: alert animated: YES completion:^{
        
    }];
}

- (void) showNextPermission
{
    [self performSegueWithIdentifier: @"showLocationPermission" sender: nil];
}

@end
