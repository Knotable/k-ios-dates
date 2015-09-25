//
//  ONNetworkOperation.h
//  OptimizedNetworking
//
//  Created by Brennan Stehling on 7/10/12.
//  Copyright (c) 2012 SmallSharpTools LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjCMongoDB.h"
enum {
    ONNetworkOperation_Status_Waiting = 10,
    ONNetworkOperation_Status_Ready = 20,
    ONNetworkOperation_Status_Executing = 40,
    ONNetworkOperation_Status_Cancelled = 50,
    ONNetworkOperation_Status_Finished = 60
};
typedef NSUInteger ONNetworkOperation_Status;

typedef void (^ONNetworkOperationCompletionHandler)(NSData *data, NSError *error);
typedef void (^ONNetworkOperationProgressHandler)(long long currentContentLength, long long expectedContentLength);

@interface ONNetworkOperation : NSObject

@property (nonatomic, copy) void (^completionBlock)(void);
@property (copy, nonatomic) ONNetworkOperationCompletionHandler completionHandler;
@property (copy, nonatomic) ONNetworkOperationProgressHandler progressHandler;
@property (copy, nonatomic) NSString *category;
@property (assign, nonatomic) ONNetworkOperation_Status status;
//@property (weak, nonatomic) id<MongoEngineDelegate> delegate_local;
@property (strong, nonatomic) id userData;
@property (assign, nonatomic) BOOL forceInQueue;
- (void)changeStatus:(ONNetworkOperation_Status)status;
- (NSTimeInterval)operationDuration;

- (void)startNetworkOperation;
- (void)cancelNetworkOperation;
- (void)failNetworkOperation;
- (void)finishNetworkOperation;

@end
