//
//  AppDelegate.h
//  Example
//
//  Created by wuli on 2/3/15.
//  Copyright (c) 2015 smart4c. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#define BIDT1()     NSDate* date = [NSDate date];
#define BIDT2()     do{NSLog(@"%s>>>>>>>>>>>>> cost: %f", __PRETTY_FUNCTION__, [date timeIntervalSinceNow]*-1000);}while(0)
@class ViewController, MeteorClient;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) LoginViewController *loginController;
@property (strong, nonatomic) UINavigationController *navController;
@property (strong, nonatomic) MeteorClient *meteorClient;

@end

