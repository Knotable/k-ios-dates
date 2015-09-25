//
//  MAppDelegate.h
//  Mailer
//
//  Created by Martin Ceperley on 9/20/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@interface MAppDelegate : UIResponder <UIApplicationDelegate,CLLocationManagerDelegate>{
    
    __block id fetchComplete;
    __block id fetchError;
    UIBackgroundTaskIdentifier bgTask;
    NSTimer *timer,*locTimer,*addressTimer;
    
    CLLocationManager *locationManager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic,strong) UIViewController *parentViewCntrllr;
@property (nonatomic , readwrite) BOOL isChangeLogin,ispulled;
@property (nonatomic,strong) NSString *locationStr;
@property (nonatomic, strong)NSMutableArray *addressArray;

@end
