//
//  MultiConnGenerator.m
//  Knotable
//
//  Created by backup on 14-1-10.
//
//

#import "MultiConnGenerator.h"
#import "MonoConn.h"
#import "ObjCMongoDB.h"
@interface MultiConnGenerator ()

@property (atomic, strong)NSMutableArray *connArray;
@property (atomic, strong) NSTimer *checkTimer;
@end

@implementation MultiConnGenerator

static MultiConnGenerator *sharedInstance;

+ (MultiConnGenerator *)sharedInstance
{
    static MultiConnGenerator *_sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[MultiConnGenerator alloc] init];
    });
    return _sharedInstance;
}

- (void)reset
{
    NSLock *checkLock = [[NSLock alloc] init];
    [checkLock lock];
    [self.checkTimer invalidate];
    self.checkTimer = nil;
    
    for ( MonoConn *mconn in self.connArray ) {
        if (mconn.conn) {
            [mconn.conn disconnect];
            mconn.conn = nil;
        }
    }
    
    [self.connArray removeAllObjects];
    
    [checkLock unlock];
}

- (void)dealloc
{
    [self reset];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.connArray = [[NSMutableArray alloc] initWithCapacity:3];
        self.checkInterval = 1.0f;
    }
    return self;
}

- (void)checkTimeout:(NSTimer*)timer
{
    NSTimeInterval tv = [NSDate timeIntervalSinceReferenceDate];
    NSInteger conn_count = 0;
    NSLock *checkLock = [[NSLock alloc] init];
    [checkLock lock];
    for ( int i = 0; i < [self.connArray count]; i++) {
        MonoConn *mconn = (MonoConn *)[self.connArray objectAtIndex:i];
        if (mconn.conn) {
            if (mconn.isFinished == NO) {
                if (tv - mconn.beginTime>mconn.checkTime) {
                    mconn.isFinished = YES;
                    [mconn.conn disconnect];
                    mconn.conn = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        mconn.tBlock(mconn);
                    });
                }
                conn_count++;
            }
        }
    }
    
    if (conn_count == 0) {
        [self.checkTimer invalidate];
        self.checkTimer = nil;
    }
    [checkLock unlock];

}

- (void)requestFreeMonoConn:(gotConnBlock)block withTimeOut:(timeoutBlock)timeoutBlock
{
    NSLock *checkLock = [[NSLock alloc] init];
    [checkLock lock];
    if ( !self.checkTimer) {
        self.checkTimer = [NSTimer scheduledTimerWithTimeInterval:self.checkInterval target:self selector:@selector(checkTimeout:) userInfo:nil repeats:YES];
    }
    [checkLock unlock];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        MonoConn *idealConn = nil;
        for ( int i = 0; i < [self.connArray count]; i++) {
            MonoConn *mconn = (MonoConn *)[self.connArray objectAtIndex:i];
            if (mconn.conn) {
                if (mconn.isFinished == YES) {
                    idealConn = mconn;
                    break;
                }
            }
        }
        
        NSError *error = nil;

        if (!idealConn) {
            idealConn = [[MonoConn alloc] init];
            [self.connArray addObject:idealConn];
        }
        idealConn.isFinished = NO;
        idealConn.beginTime = [NSDate timeIntervalSinceReferenceDate];
        if(idealConn.conn != nil) {
            [idealConn.conn checkConnectionWithError:&error];
        }
        
        if(idealConn.conn == nil) {
            idealConn.conn = [[single_mongodb sharedInstanceMethod] generateConnection];
        } else if ( error != nil ) {
            NSLog(@"connection result %@", error);
            error = nil;
            [idealConn.conn reconnectWithError:&error];
        }
        
        idealConn.tBlock = timeoutBlock;
        [idealConn beginConnCheck];
        block(idealConn);
    });
}
@end
