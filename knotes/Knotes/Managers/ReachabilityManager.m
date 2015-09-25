//
//  ReachabilityManager.m
//  Knotable
//
//  Created by liwu on 14-2-12.
//
//

#import "ReachabilityManager.h"
#import "Singleton.h"

@interface ReachabilityManager ()
@property (nonatomic, strong) Reachability *hostReach;
@property (nonatomic, strong) Reachability *internetReach;
@property (nonatomic, strong) Reachability *wifiReach;
@end
@implementation ReachabilityManager

SYNTHESIZE_SINGLETON_FOR_CLASS(ReachabilityManager);

- (void)dealloc
{
    self.hostReach = nil;
    self.internetReach = nil;
    self.wifiReach = nil;
}

- (void)registerNotifier
{
    [[NSNotificationCenter defaultCenter]addObserver:self
                                            selector:@selector(reachabilityChanged:)
                                                name:kReachabilityChangedNotification
                                              object:nil];
    [self checkNetworkAvailable];
}

-(void)removeNotifier
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability *curReach = [note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    [self updateInterfaceWithReachability:curReach];
}

- (void)updateInterfaceWithReachability:(Reachability *)curReach
{
    NetworkStatus netStatus = [curReach currentReachabilityStatus];
    BOOL connectionRequired = [curReach connectionRequired];
    if (curReach == self.hostReach)
    {
        DLog(@"hostReach");
    }
    if (curReach == self.internetReach)
    {
        DLog(@"internetReach");
    }
    if (curReach == self.wifiReach)
    {
        DLog(@"wifiReach");
    }
    self.currentNetStatus  = netStatus;
    if (self.delegate && [self.delegate respondsToSelector:@selector(netWorkDidChangeStatus:)]) {
        [self.delegate netWorkDidChangeStatus:self.currentNetStatus];
    }
    DLog(@"netStatus:%d|%d",(int)netStatus, (int)connectionRequired);
}

- (void)checkNetworkAvailable
{
    if (!self.hostReach) {
        self.hostReach = [Reachability reachabilityWithHostname:@"www.apple.com"];
        [self.hostReach startNotifier];
    }
    
    if (!self.internetReach) {
        self.internetReach = [Reachability reachabilityForInternetConnection];
        [self.internetReach startNotifier];
        [self updateInterfaceWithReachability:self.internetReach];
    }
    
    if (!self.wifiReach) {
        self.wifiReach = [Reachability reachabilityForLocalWiFi] ;
        [self.wifiReach startNotifier];
        [self updateInterfaceWithReachability:self.wifiReach];
    }
}
@end
