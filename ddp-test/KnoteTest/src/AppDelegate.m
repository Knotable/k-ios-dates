//
//  AppDelegate.m
//  Example
//
//  Created by wuli on 2/3/15.
//  Copyright (c) 2015 smart4c. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "MeteorClient.h"
#import "ObjectiveDDP.h"
#import <ObjectiveDDP/MeteorClient.h>
//#define kServer @"wss://ddptester.meteor.com/websocket"


@interface AppDelegate()

@end
@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    LoginViewController *loginController = [[LoginViewController alloc] initWithNibName:@"LoginViewController"
                                                                                 bundle:nil];
    loginController.meteor = self.meteorClient;
    self.loginController = loginController;

    self.navController = [[UINavigationController alloc] initWithRootViewController:loginController];
    self.navController.navigationBarHidden = YES;
    
    self.window.rootViewController = self.navController;
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportConnection) name:MeteorClientDidConnectNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reportDisconnection) name:MeteorClientDidDisconnectNotification object:nil];

    return YES;
}

- (void)reportConnection {
    NSLog(@"================> connected to server!");
}

- (void)reportDisconnection {
    NSLog(@"================> disconnected from server!");    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [self.meteorClient.ddp connectWebSocket];
}

@end
