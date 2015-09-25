//
//  SyncManager.m
//  Knotable
//
//  Created by Dhruv on 5/8/15.
//
//

#import "SyncManager.h"
#import "ReachabilityManager.h"

@implementation SyncManager
+ (instancetype)sharedInstance
{
    static SyncManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SyncManager alloc] init];
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}
- (void)startMonitoring
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(reachabilityChanged:)
                                                name:kReachabilityChangedNotification
                                              object:nil];
    CGFloat checkInterVal=15.0;
    
    self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:checkInterVal target:self selector:@selector(periodicCheck) userInfo:nil repeats:YES];
    
}
- (void)reachabilityChanged:(NSNotification *)note
{
    [self periodicCheck];
}
- (void)periodicCheck
{
    if (![self canPostNow]) {
        return;
    }
    
    [self checkForActionsToPerform];
}
- (BOOL)canPostNow
{
    BOOL offline = [ReachabilityManager sharedInstance].currentNetStatus == NotReachable;
    
    if(offline)
    {
        NSLog(@"offline");
        return NO;
    }
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    if (!app.meteor.connected)
    {
        NSLog(@"meteor not connected");
        return NO;
    }
    
    return YES;
}
- (void)checkForActionsToPerform
{
    if (![self canPostNow]) {
        return;
    }
    //Dhruv : The methods we will Sync here from from gettin isSync bool value
    
    [AppDelegate saveContext];
    
}
@end
