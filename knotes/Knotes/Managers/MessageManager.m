//
//  MessageManager.m
//  Knotable
//
//  Created by wuli on 8/28/14.
//
//

#import "MessageManager.h"
#import "DataManager.h"
#import "TopicsEntity.h"


@implementation MessageManager

- (void)dealloc
{
    NSLog(@"MessageManager dealloc");
}

- (void)setMeteorMuted:(BOOL)mute WithRetryCount:(NSInteger)count;
{
    self.retryCount = count;
    if (mute)
    {
        [self performSelector:@selector(setMeteorMuted) withObject:nil afterDelay:0.5];
    }
    else
    {
        [self performSelector:@selector(setMeteorUnMuted) withObject:nil afterDelay:0.5];
    }
}

- (void)setMeteorMuted
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    if ([DataManager sharedInstance].current_user_id
        && self.message.topic_id)
    {
        NSArray *parm = @[self.message.topic_id,
                          @[@"ALL",@"IOS"],
                          [DataManager sharedInstance].current_user_id];
        
        [app.meteor callMethodName:@"mutePadByUser"
                        parameters:parm
                  responseCallback:^(NSDictionary *response, NSError *error)
        {
            if (!error && ![self.message isFault] && self.message.topic_id)
            {
                TopicsEntity *entity = [TopicsEntity MR_findFirstByAttribute:@"topic_id"
                                                                   withValue:self.message.topic_id];
                
                entity.isMute = @(YES);
                
                self.message.muted = YES;
                
                [AppDelegate saveContext];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KNOTES_HAS_MUTED_NOTIFICATION
                                                                    object:nil];
            }
            else
            {
                self.retryCount--;
                
                if (self.retryCount>0)
                {
                    [self performSelector:@selector(setMeteorMuted)
                               withObject:nil
                               afterDelay:0.5];
                }
                else
                {
                    TopicsEntity *entity = [TopicsEntity MR_findFirstByAttribute:@"topic_id"
                                                                       withValue:self.message.topic_id];
                    
                    entity.isMute = @(NO);
                    
                    self.message.muted = NO;
                    
                    [glbAppdel.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error)
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:HOT_KNOTES_DOWNLOADED_NOTIFICATION
                                                                            object:nil
                                                                          userInfo:@{kHotOrMute:@(2)}];
                    }];
                }
            }
        }];
    }
}

- (void)setMeteorUnMuted
{
    // We would archive Recent Item here.
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    if ([DataManager sharedInstance].current_user_id
        && self.message.topic_id)
    {
        NSArray *parm = @[self.message.topic_id,
                          @[@"ALL",@"IOS"],
                          [DataManager sharedInstance].current_user_id];
        
        [app.meteor callMethodName:@"unmutePadByUser"
                        parameters:parm
                  responseCallback:^(NSDictionary *response, NSError *error)
        {
            if (!error && ![self.message isFault] && self.message.topic_id)
            {
                TopicsEntity *entity = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:self.message.topic_id];
                
                entity.isMute = @(NO);
                
                self.message.muted = NO;
                
                [glbAppdel.managedObjectContext MR_saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error)
                {
                    [[NSNotificationCenter defaultCenter] postNotificationName:HOT_KNOTES_DOWNLOADED_NOTIFICATION
                                                                        object:nil
                                                                      userInfo:@{kHotOrMute:@(2)}];
                }];
            }
            else
            {
                self.retryCount--;
                
                if (self.retryCount>0)
                {
                    [self performSelector:@selector(setMeteorUnMuted)
                               withObject:nil
                               afterDelay:0.5];
                }
                else
                {
                    TopicsEntity *entity = [TopicsEntity MR_findFirstByAttribute:@"topic_id"
                                                                       withValue:self.message.topic_id];
                    
                    entity.isMute = @(YES);
                    
                    self.message.muted = YES;
                    
                    [AppDelegate saveContext];
                }
            }
        }];
    }
}

@end