//
//  MultiConnGenerator.h
//  Knotable
//
//  Created by backup on 14-1-10.
//
//

#import <Foundation/Foundation.h>
#import "MonoConn.h"
#import <Reachability.h>

typedef void (^CompletionBlock)(BOOL success,id userData, NSError *error);
typedef void (^gotConnBlock)(MonoConn *conn);

@interface MultiConnGenerator : NSObject
@property (atomic, assign) NSTimeInterval checkInterval;//default is 1.0f s
+ (MultiConnGenerator *)sharedInstance;
- (void)requestFreeMonoConn:(gotConnBlock)block withTimeOut:(timeoutBlock)timeoutBlock;
- (void)reset;


@end
