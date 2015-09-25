//
//  MonoConn.m
//  Knotable
//
//  Created by backup on 14-1-10.
//
//

#import "MonoConn.h"
@interface MonoConn ()
@end
@implementation MonoConn
- (void)dealloc
{
    [self.conn disconnect];
    self.conn = nil;
    NSLog(@"#############Mongo Connection dealloc !!!!!!");
}

- (id)init
{
    self = [super init];
    if (self) {
        self.checkTime = 15.0f;
    }
    return self;
}

-(void)beginConnCheck
{
}
@end
