//
//  LocationPermissionViewController.m
//  Knotes
//
//  Created by Chunji on 9/15/15.
//
//

#import "LocationPermissionViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface LocationPermissionViewController () <CLLocationManagerDelegate>
@property (nonatomic) CLLocationManager* locationManager;
@end

@implementation LocationPermissionViewController
- (IBAction)setLocationPermission:(id)sender {
    
    CLAuthorizationStatus stutus = [CLLocationManager authorizationStatus];
    
    if (stutus == kCLAuthorizationStatusNotDetermined)
    {
        self.locationManager = [CLLocationManager new];
        self.locationManager.delegate = self;
        [self.locationManager requestWhenInUseAuthorization];
    }
    else
    {
        [self showNextPermssion];
    }
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self showNextPermssion];
}

- (void) showNextPermssion
{
    [self performSegueWithIdentifier: @"showContactPermission" sender: nil];
}

@end
