//
//  ONNetworkManager.m
//  OptimizedNetworking
//
//  Created by Brennan Stehling on 7/10/12.
//  Copyright (c) 2012 SmallSharpTools LLC. All rights reserved.
//

#import "ONNetworkManager.h"


// NOTES
// A download queue will regulate downloads. Download operations will be added to the queue
// and counted as they are in progress and new items will be added based on priority.
// A list of downloads will be downloaded at times and should be downloaded in the background
// with the ability for priority items to skip ahead of the line. Images will be handled
// differently than XML and other downloads because they take longer to download and will be
// stored using EGOCache.

// Look into AFNetworking - https://github.com/AFNetworking/AFNetworking

#pragma mark - Class Extension
#pragma mark -

@interface ONNetworkManager ()

@property (strong, readwrite, nonatomic) NSRecursiveLock *lock;
@property (strong, nonatomic) NSMutableArray *operations;
@property (assign, nonatomic) NSUInteger queuedCount;

@end

#pragma mark -

@implementation ONNetworkManager {
    NSUInteger networkingCount;
}

#pragma mark - Singleton
#pragma mark -

SYNTHESIZE_SINGLETON_FOR_CLASS(ONNetworkManager);

#pragma mark - Initialization
#pragma mark -

- (id)init {
    self = [super init];
    if (self != nil) {
        self.lock = [[NSRecursiveLock alloc] init];
        self.operations = [NSMutableArray array];
        self.queuedCount = 0;
    }
    return self;
}

#pragma mark - Implementation
#pragma mark -


- (void)addOperations:(NSArray *)operations {
    [self.lock lock];
    NSArray *sorted = [ONNetworkManager sortOperations:operations];
    for (ONNetworkOperation *operation in sorted) {
        [self addOperation:operation];
    }
    [self.lock unlock];
}

- (BOOL)checkCategoryInQueue:(NSString *)category
{
    if ([self.operations count]==0) {
        return NO;
    }
    for (int i = 0; i<[self.operations count]; i++) {
        ONNetworkOperation *operator = [self.operations objectAtIndex:i];
        if ([operator.category isEqualToString:category]) {
            return YES;
        }
    }
    return NO;
}
- (void)addOperation:(ONNetworkOperation *)operation {
    [self.lock lock];
    
    // ensure the NSRunLoop thread is running
    if (operation.forceInQueue || ![self checkCategoryInQueue:operation.category]) {
        [self.operations addObject:operation];
        __weak ONNetworkOperation *weakOperation = operation;
        [operation setCompletionBlock:^{
            [self.lock lock];
            self.queuedCount--;
            [self.operations removeObject:weakOperation];
            [self.lock unlock];
            [self processOperationQueue];
        }];
        [operation changeStatus:ONNetworkOperation_Status_Ready];
        self.queuedCount++;
    }
    [self.lock unlock];
}
- (void)processOperationQueue
{
    NSLog(@"[self.operations count]>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>:%d",(int)[self.operations count]);
    if ([self.operations count]>0) {
        ONNetworkOperation *operator = [self.operations objectAtIndex:0];
        if (operator.status == ONNetworkOperation_Status_Ready) {
            [operator startNetworkOperation];
        }
    }
}
- (void)cancelOperation:(ONNetworkOperation *)operation {
    [self.lock lock];
    [self.operations removeObjectIdenticalTo:operation];
    [self.lock unlock];
}

- (void)cancelOperationsWithCategory:(NSString *)category {
    [self.lock lock];
    NSMutableArray *operationsToCancel = [NSMutableArray array];
    for (ONNetworkOperation *operation in self.operations) {
        if ([operation.category isEqualToString:category]) {
            [operationsToCancel addObject:operation];
        }
    }
    
    for (ONNetworkOperation *operation in operationsToCancel) {
        [self cancelOperation:operation];
    }
    [self.lock unlock];
}

- (void)cancelAll {
    [self.lock lock];
    [self.operations removeAllObjects];
    [self.lock unlock];
}

- (void)logOperations {
    [self.lock lock];
    DLog(@"There are %i active operations", (unsigned)[self operationsCount]);
    for (ONNetworkOperation *operation in self.operations) {
        DLog(@"%@", operation);
    }
    [self.lock unlock];
}

+ (NSArray *)sortOperations:(NSArray *)operations {
    // sort by status (waiting, queued, finished), priority, category
    NSArray *sorted = [operations sortedArrayUsingComparator: ^(id obj1, id obj2) {
        if ([obj1 isKindOfClass:[ONNetworkOperation class]] && [obj2 isKindOfClass:[ONNetworkOperation class]]) {
            ONNetworkOperation *op1 = (ONNetworkOperation *)obj1;
            ONNetworkOperation *op2 = (ONNetworkOperation *)obj2;
            
            NSComparisonResult result = (NSComparisonResult)NSOrderedSame;
            
            result = [[NSNumber numberWithInt:(int)op1.status] compare:[NSNumber numberWithInt:(int)op2.status]];
            
            if (result != NSOrderedSame) {
//todo
            }
            
            if (result != NSOrderedSame) {
                result = [op1.category compare:op2.category];
            }
            
            return result;
        }
        
        // fall through in case object types do not match
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    return sorted;
}

- (void)didStartNetworking {
    networkingCount += 1;
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)didStopNetworking {
    if (networkingCount > 0) {
        networkingCount -= 1;
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible: (networkingCount > 0)];
}

- (NSUInteger)operationsCount {
    return self.queuedCount;
}

@end
