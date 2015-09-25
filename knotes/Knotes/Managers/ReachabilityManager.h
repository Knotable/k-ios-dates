//
//  ReachabilityManager.h
//  Knotable
//
//  Created by liwu on 14-2-12.
//
//

#import <Foundation/Foundation.h>
#import "Reachability.h"
@protocol ReachabilityManagerDelegate <NSObject>
@optional
- (void)netWorkDidChangeStatus:(NetworkStatus)status;
@end
@interface ReachabilityManager : NSObject

@property (nonatomic, assign) NetworkStatus currentNetStatus;
@property (nonatomic, weak) id <ReachabilityManagerDelegate> delegate;

+(ReachabilityManager *)sharedInstance;
-(void)registerNotifier;
-(void)removeNotifier;
@end
