//
//  PhotoPermissionViewController.m
//  Knotes
//
//  Created by Chunji on 9/15/15.
//
//

#import "PhotoPermissionViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#import "CombinedViewController.h"
#import "DataManager.h"

@interface PhotoPermissionViewController()
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@property (weak, nonatomic) IBOutlet UIButton *skipButton;

@end

@implementation PhotoPermissionViewController
- (IBAction)setPhotoPermission:(id)sender {
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    
    if (status == PHAuthorizationStatusNotDetermined)
    {
        self.okButton.enabled = NO;
        self.skipButton.enabled = NO;
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            [self showNextScreen: nil];
        }];
    }
    else
    {
        [self showNextScreen: nil];
    }
}

- (IBAction)showNextScreen:(id)sender {
    CombinedViewController *combinedVC = [[CombinedViewController alloc] initWithNibName:@"PeopleViewController" bundle:nil account:[DataManager sharedInstance].currentAccount];
    combinedVC.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:combinedVC animated:NO];
    
    NSUserDefaults* userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject: @(YES) forKey: kPermissionSetState];
}

@end
