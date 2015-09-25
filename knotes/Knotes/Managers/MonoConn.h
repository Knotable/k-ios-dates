//
//  MonoConn.h
//  Knotable
//
//  Created by backup on 14-1-10.
//
//

#import <Foundation/Foundation.h>
#import "MongoConnection.h"
#import <Reachability.h>
@class MonoConn;
typedef void (^timeoutBlock)(MonoConn *conn);

@interface MonoConn : NSObject
@property (nonatomic, assign) NSTimeInterval beginTime;
@property (nonatomic, assign) NSTimeInterval checkTime;
@property (atomic, assign) BOOL isFinished;
@property (atomic, strong) MongoConnection *conn;
@property (nonatomic, copy) timeoutBlock tBlock;
-(void)beginConnCheck;
@end
