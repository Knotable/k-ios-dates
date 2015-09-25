//
//  AccountInfo.h
//  Mailer
//
//  Created by backup on 14-4-30.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MAccountViewCell.h"
#import "Account.h"
#include <MailCore/MailCore.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AccountInfo : NSObject
{
    NSUInteger _fetchContentTotalCount;
    NSUInteger _fetchContentCompletedCount;
    BOOL _stopFetching;

}
@property (nonatomic, strong) Account *account;
@property (nonatomic, strong) MCOIMAPSession *imapSession;
@property (nonatomic, strong) MCOSMTPSession *smtpSession;
@property (nonatomic, assign) BOOL showNewEmail;
@property (nonatomic, assign) BOOL isBuzzy;
@property (nonatomic, weak) MAccountViewCell *cell;
@property (nonatomic, strong) NSMutableArray *commingMessages;
@property (nonatomic, assign) int uid;

- (void) fetchNewMessagesWithSuccess:(void (^)(NSUInteger))onSuccess
                             failure:(void (^)(NSError *))onFailure;
- (void) fetchMissingMessageContents;
- (void) syncMessageFlagsFolder:(Folder *)folder modSeq:(uint64_t)modseq completion:(void (^)(NSError *))completion;
- (void) stopFetch;
- (void) realFetchMessageContent:(Message *)message highPriority:(BOOL)highPriority;
- (void) sendMessageTo:(Address *)to subject:(NSString *)subject text:(NSString *)text;
- (void) sendMessageTo:(NSArray *)to/* MCOAddress */
                    Cc:(NSArray *)cc/* MCOAddress */
                   Bcc:(NSArray *)bcc/* MCOAddress */
              dataDict:(NSDictionary *)dictionary;
@end
