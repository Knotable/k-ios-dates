//
//  MMailManager.h
//  Mailer
//
//  Created by Martin Ceperley on 9/30/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MailCore/MailCore.h>

#include <mach/mach.h>
#include <malloc/malloc.h>
typedef enum {
    FetchCurrent,
    FetchAll,
    FetchNone,
} FetchEmailType;

@class Account, Message, Folder, Address,AccountInfo;

extern  NSString * const FETCHING_NEW_MAIL_NOTIFICATION;
extern  NSString * const PROGRESS_FETCHING_NEW_MAIL_NOTIFICATION;
extern  NSString * const FETCHED_NEW_MAIL_HEADERS_NOTIFICATION;
extern  NSString * const FETCHED_NEW_MAIL_CONTENT_NOTIFICATION;
extern  NSString * const ERROR_FETCHING_NEW_MAIL_NOTIFICATION;
extern  NSString * const ERROR_NOTIFICATION;
extern  NSString * const FETCHED_NEW_ATTACHMENT_NOTIFICATION;
extern  NSString * const MESSAGE_BODY_FETCHED_NOTIFICATION;
extern  NSString * const GOT_NEWEMAILS_NOTIFICATION ;
extern  NSString* const NEED_SHOW_NEWEMAILS_NOTIFICATION;
extern  NSString* const SHOW_STATUS_NOTIFICATION;
extern int const FETCH_EVERY_X_MINUTES;
extern int const FETCH_MESSAGE_COUNT;

@interface MMailManager : NSObject {
@private
    MCOIMAPSession *_imapSession;
    BOOL _connected;
    Folder *_folder;
    Folder *_inbox;
    MCOIMAPIdleOperation *_idleOperation;
    NSUInteger _fetchContentTotalCount;
    NSUInteger _fetchContentCompletedCount;
    
    NSOperationQueue *_fetchMessageQueue;

}

+ (MMailManager *)sharedManager;

+ (MCOAbstractPart *) preferredPart:(MCOAbstractMultipart *)multipart wantPlain:(BOOL)wantPlain;
+ (MCOAttachment *) htmlFromPart:(MCOAbstractPart *)superpart;
+ (MCOAttachment *) plainTextFromPart:(MCOAbstractPart *)superpart;

//@property (nonatomic, strong) Account *currentAccount;
@property (nonatomic, strong) NSMutableArray *allAccount;
@property (nonatomic, strong) NSMutableArray *pendingAccount;

@property (nonatomic, assign) NSInteger currentAccoutIndex;
@property (nonatomic, readonly) Folder *inbox;

@property (strong, nonatomic) NSTimer* fetchMailTimer;

@property (nonatomic, readonly) BOOL isFetching;

@property (atomic, readonly) BOOL isBuzzy;
@property (nonatomic, assign) FetchEmailType currentFetType;

-(void)reloadAllAccount;
- (AccountInfo *)connectGmailWithUsername:(NSString *)username password:(NSString *)password;
- (MCOIMAPSession *)connectWithUsername:(NSString *)username password:(NSString *)password host:(NSString *)host port:(uint)port;

//- (void) fetchMessageFromFolder:(Folder *)folder uid:(uint32_t)uid completion:(void (^)(MCOMessageParser *parser))completionBlock;
- (void) fetchMessageContent:(Message *)message;
- (void) fetchMessageContent:(Message *)message highPriority:(BOOL)highPriority;

- (void) fetchMessagesFromFolder:(Folder *)folder startingUID:(int)uid count:(int)messageCount success:(void (^)(NSUInteger))onSuccess failure:(void (^)(NSError *))onFailure;

-(void) checkAccount:(AccountInfo *)checkAcount Success:(void (^)(void))onSuccess failure:(void (^)(NSError *))onFailure;
- (void) syncMessageRead:(Message *)message;

- (void) deleteMessage:(Message *)message;
-(void) syncMessageArchive:(Message *)message;
-(void) syncMessageSkip:(Message *)message;
- (void) beginFetchingAllMail;
- (void) beginFetchingMail;
- (void) stopFetchingMail;

- (void) fetchNewMail;
- (void) fetchNewMailFromIDLE:(BOOL)fromIDLE;

- (void) checkCapabilities;

- (void) startIDLE;
- (void) stopIDLE;

-(void)sendMessageTo:(Address *)to subject:(NSString *)subject text:(NSString *)text;

- (void) sendMessageTo:(NSArray *)to/* MCOAddress */
                    Cc:(NSArray *)cc/* MCOAddress */
                   Bcc:(NSArray *)bcc/* MCOAddress */
              dataDict:(NSDictionary *)dictionary;
-(AccountInfo *)getCurrentAccountInfo;
-(Account *)getCurrentAccount;
-(Folder *)getCurrentFolder;
- (void) logout:(AccountInfo *)actInfo completion:(void (^)(BOOL success,NSString *msg, NSError *error))completion;
+(NSString *)getCpuInfo;
+(NSString *)getMemInfo;
@end
