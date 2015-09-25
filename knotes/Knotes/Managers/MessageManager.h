//
//  MessageManager.h
//  Knotable
//
//  Created by wuli on 8/28/14.
//
//

#import <Foundation/Foundation.h>
#import "MessageEntity.h"
@interface MessageManager : NSObject
@property (nonatomic, strong) MessageEntity* message;
@property (nonatomic, assign)  NSInteger retryCount;
- (void)setMeteorMuted:(BOOL)mute WithRetryCount:(NSInteger)count;
@end
