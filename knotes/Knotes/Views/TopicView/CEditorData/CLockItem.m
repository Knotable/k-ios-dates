//
//  CLockItem.m
//  RevealControllerProject
//
//  Created by backup on 13-10-17.
//
//

#import "CLockItem.h"
#import "ThreadItemManager.h"

@implementation CLockItem

- (id)initWithMessage:(MessageEntity *)message;
{
    self = [super initWithMessage:message];
    if (self) {
        self.type = C_LOCK;
        self.height = 120;

    }
    return self;
}

-(id)init {
    self = [super init];
    if (self) {
        self.type = C_LOCK;
        self.height = 120;
    }
    return self;
}

-(int) getHeight
{
    return 0;
}

-(int) getCellHeight
{
    CGFloat h = [super getCellHeight];
    return h<kItemMinH?kItemMinH:h;
}

- (NSMutableDictionary *)dictionaryValue
{
    NSMutableDictionary *dict = [super dictionaryValue];
    
    dict[@"body"] = self.userData.body;
    dict[@"cname"] = @"knotes";
    dict[@"htmlBody"] =  self.userData.body;
    dict[@"type"] = @"lock";

    return dict;
}

-(void)checkToUpdataSelf
{
    [self.cell showProcess];
    [[ThreadItemManager sharedInstance] sendInsertLock:self withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData, id userData2, id userData3) {
        
        switch (success) {
            case NetworkSucc:
            {
                [self.cell stopProcess];
                self.itemId = (NSString *)userData;
                self.userData.message_id = self.itemId;
                self.needSend = NO;
                self.userData.need_send = NO;
                self.topic.locked_id = self.itemId;
                
                self.needSend = NO;
                self.userData.need_send = NO;
                self.uploadRetryCount = 3;
            }
                break;
            case NetworkTimeOut:
            case NetworkErr:
            case NetworkFailure:
            {
                if (self.uploadRetryCount>0) {
                    self.uploadRetryCount--;
                    [self checkToUpdataSelf];
                } else {
                    [self.cell showInfo:InfoWarrning];
                }
            }
                break;
            default:
                break;
        }
        [self.cell stopProcess];
    }];
}
@end
