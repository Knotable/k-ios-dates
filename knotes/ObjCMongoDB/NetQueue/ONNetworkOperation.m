//
//  ONNetworkOperation.m
//  OptimizedNetworking
//
// Various bits borrowed from the AdvancedURLConnections sample project from Apple.
//
//  Created by Brennan Stehling on 7/10/12.
//  Copyright (c) 2012 SmallSharpTools LLC. All rights reserved.
//

#import "ONNetworkOperation.h"

#import "ONNetworkManager.h"

#define kDefaultHttpMethod              @"GET"

@interface ONNetworkOperation () <NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSDate *operationStartDate;
@property (strong, nonatomic) NSDate *operationEndDate;

@property (assign, nonatomic) long long expectedContentLength;
@property (assign, nonatomic) long long currentContentLength;


- (BOOL)isCompleted;

- (NSString *)statusAsString;

@end

@implementation ONNetworkOperation

#pragma mark - Initialization
#pragma mark -

- (id)init {
    self = [super init];
    if (self != nil) {
        self.category = @"Default";
        self.forceInQueue = NO;
        self.status = ONNetworkOperation_Status_Waiting;
    }
    
    return self;
}

#pragma mark - Public Methods
#pragma mark -

- (void)changeStatus:(ONNetworkOperation_Status)status {
    if (self.status != ONNetworkOperation_Status_Ready && status == ONNetworkOperation_Status_Ready) {
        [self willChangeValueForKey:@"isReady"];
        self.status = ONNetworkOperation_Status_Ready;
        [self didChangeValueForKey:@"isReady"];
    }
    else if (self.status != ONNetworkOperation_Status_Executing && status == ONNetworkOperation_Status_Executing) {
        [self willChangeValueForKey:@"isExecuting"];
        self.status = ONNetworkOperation_Status_Executing;
        [self didChangeValueForKey:@"isExecuting"];
    }
    else if (self.status != ONNetworkOperation_Status_Cancelled && status == ONNetworkOperation_Status_Cancelled) {
        [self willChangeValueForKey:@"isCancelled"];
        self.status = ONNetworkOperation_Status_Cancelled;
        [self didChangeValueForKey:@"isCancelled"];
    }
    else if (self.status != ONNetworkOperation_Status_Finished && status == ONNetworkOperation_Status_Finished) {
        [self willChangeValueForKey:@"isFinished"];
        self.status = ONNetworkOperation_Status_Finished;
        [self didChangeValueForKey:@"isFinished"];
    }
    else {
        self.status = status;
    }
}

- (NSTimeInterval)operationDuration {
    if (self.operationStartDate == nil || self.operationEndDate == nil) {
        return 0.0;
    }
    
    CGFloat duration = [self.operationEndDate timeIntervalSinceDate:self.operationStartDate];
    return duration;
}




#pragma mark - Private Methods
#pragma mark -

- (NSString *)statusAsString {
    if (self.status == ONNetworkOperation_Status_Waiting) {
        return @"Waiting";
    }
    else if (self.status == ONNetworkOperation_Status_Ready) {
        return @"Ready";
    }
    else if (self.status == ONNetworkOperation_Status_Executing) {
        return @"Executing";
    }
    else if (self.status == ONNetworkOperation_Status_Cancelled) {
        return @"Cancelled";
    }
    else if (self.status == ONNetworkOperation_Status_Finished) {
        return @"Finished";
    }
    else {
        return @"Unknown";
    }
}

- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix {
    NSString *  result;
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    
    NSAssert(prefix != nil, @"Invalid State");
    
    uuid = CFUUIDCreate(NULL);
    NSAssert(uuid != NULL, @"Invalid State");
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    NSAssert(uuidStr != NULL, @"Invalid State");
    
    result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
    NSAssert(result != nil, @"Invalid State");
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

#pragma mark - NSObject Overrides
#pragma mark -

- (NSString *)description {
    return [NSString stringWithFormat:@"(%@, %@)", self.category, [self statusAsString]];
}

#pragma mark - Base Class Overrides
#pragma mark -

- (void)startNetworkOperation {
//    [[ONNetworkManager sharedInstance] didStartNetworking];
}
- (void)processNetworkOperation {
    @synchronized (self) {
        // report progress (expected could be NSURLResponseUnknownLength)
        if (self.progressHandler != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progressHandler(self.currentContentLength, self.expectedContentLength);
            });
        }
    }
}

- (void)cancelNetworkOperation {
    @synchronized (self) {
        self.operationEndDate = [NSDate date];
        [[ONNetworkManager sharedInstance] didStopNetworking];
        [self changeStatus:ONNetworkOperation_Status_Cancelled];
    }
}

- (void)failNetworkOperation {
    @synchronized (self) {
        self.operationEndDate = [NSDate date];
        [[ONNetworkManager sharedInstance] didStopNetworking];
        [self changeStatus:ONNetworkOperation_Status_Finished];
        if (self.completionHandler != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.completionHandler(nil, nil);
            });
        }
    }
}

- (void)finishNetworkOperation {
    @synchronized (self) {
        // return the data as NSData (possibly dangerous for large files)
        NSError *error = nil;

        if (error != nil) {
            [self failNetworkOperation];
        }
        else {
            
            self.operationEndDate = [NSDate date];
            [[ONNetworkManager sharedInstance] didStopNetworking];
            [self changeStatus:ONNetworkOperation_Status_Finished];
            
            if (self.completionHandler != nil) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.completionHandler(nil, nil);
                });
            }
        }
    }
}

- (BOOL)isCompleted {
    return [self isCancelled] || [self isFinished];
}

#pragma mark - NSOperation Overrides
#pragma mark -

- (void)start {
    
    NSAssert(![self isCompleted], @"Invalid State");

    self.operationStartDate = [NSDate date];
    [self changeStatus:ONNetworkOperation_Status_Executing];
}

- (void)cancel {    
    @synchronized (self) {
        // Call our super class so that isCancelled starts returning true immediately.
        [self cancelNetworkOperation];
        [self changeStatus:ONNetworkOperation_Status_Cancelled];
    }
}

- (BOOL)isReady {
    // any thread
    return self.status == ONNetworkOperation_Status_Ready;
}

- (BOOL)isConcurrent {
    // any thread
    return YES;
}

- (BOOL)isExecuting {
    // any thread
    return self.status == ONNetworkOperation_Status_Executing;
}

- (BOOL)isCancelled {
    // any thread
    return self.status == ONNetworkOperation_Status_Cancelled;
}

- (BOOL)isFinished {
    // any thread
    return self.status == ONNetworkOperation_Status_Finished;
}

@end
