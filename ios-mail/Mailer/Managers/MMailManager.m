//
//  MMailManager.m
//  Mailer
//
//  Created by Martin Ceperley on 9/30/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MMailManager.h"
#import "MDataManager.h"
#import "MFileManager.h"
#import "Account.h"
#import "Address.h"
#import "Message.h"
#import "Folder.h"
#import "Attachment.h"
#import "MAppDelegate.h"
#import "AccountInfo.h"
#import <AudioToolbox/AudioToolbox.h>
#define kIdleTimeInterval 30
NSString* const FETCHING_NEW_MAIL_NOTIFICATION = @"FETCHING_NEW_MAIL_NOTIFICATION";
NSString* const PROGRESS_FETCHING_NEW_MAIL_NOTIFICATION = @"PROGRESS_FETCHING_NEW_MAIL_NOTIFICATION";
NSString* const FETCHED_NEW_MAIL_CONTENT_NOTIFICATION = @"FETCHED_NEW_MAIL_CONTENT_NOTIFICATION";
NSString* const FETCHED_NEW_MAIL_HEADERS_NOTIFICATION = @"FETCHED_NEW_MAIL_HEADERS_NOTIFICATION";
NSString* const ERROR_FETCHING_NEW_MAIL_NOTIFICATION = @"ERROR_FETCHING_NEW_MAIL_NOTIFICATION";
NSString* const ERROR_NOTIFICATION = @"ERROR_NOTIFICATION";
NSString* const FETCHED_NEW_ATTACHMENT_NOTIFICATION = @"FETCHED_NEW_ATTACHMENT_NOTIFICATION";
NSString* const MESSAGE_BODY_FETCHED_NOTIFICATION = @"MESSAGE_BODY_FETCHED_NOTIFICATION";
NSString* const GOT_NEWEMAILS_NOTIFICATION = @"GOT_NEWEMAILS_NOTIFICATION";
NSString* const NEED_SHOW_NEWEMAILS_NOTIFICATION = @"NEED_SHOW_NEWEMAILS_NOTIFICATION";
NSString* const SHOW_STATUS_NOTIFICATION = @"SHOW_STATUS_NOTIFICATION";

int const FETCH_EVERY_X_MINUTES = 5;
int const FETCH_MESSAGE_COUNT = 10;

BOOL const CHECK_FOR_SERVER_DELETED_MESSAGES = YES;
BOOL const SYNC_FLAGS_FROM_SERVER = YES;
@interface MMailManager()
@property (nonatomic, strong) NSTimer *idleTimer;

@end
@implementation MMailManager

//@synthesize currentAccount = _account;
@synthesize inbox = _inbox;

+ (MMailManager *)sharedManager {
    static MMailManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MMailManager alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    
    _fetchContentCompletedCount = 0;
    _fetchContentTotalCount = 0;
    
    _fetchMessageQueue = [[NSOperationQueue alloc] init];
    _fetchMessageQueue.name = @"FETCH_MESSAGE_QUEUE";
    _fetchMessageQueue.maxConcurrentOperationCount = 1;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(commingNewMessage:) name:GOT_NEWEMAILS_NOTIFICATION object:nil];

    [self resetIdleTimer];
    
    return self;
}
-(Folder *)getCurrentFolder
{
    return [self getCurrentAccount].inbox;
}
-(void)commingNewMessage:(NSNotification *)notification
{
    AccountInfo *actInfo = notification.object;
    
    if (actInfo.commingMessages && [actInfo.commingMessages count]>0) {
     return;
	    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            if (actInfo.commingMessages>0) {
                if (actInfo.uid == -1) {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                }
                
                for (MCOIMAPMessage *message in actInfo.commingMessages) {
                    
                    Message *email = [Message messageWithMCOMessage:message folder:actInfo.account.inbox inManagedObjectContext:localContext];
                    if (actInfo.uid == -1) {
                        
                        UILocalNotification *notification=[[UILocalNotification alloc] init];
                        if (notification!=nil) {
                            NSDate *now=[NSDate date];
                            notification.fireDate=[now dateByAddingTimeInterval:2];
                            notification.timeZone=[NSTimeZone defaultTimeZone];
                            notification.alertBody=email.subject;
                            [[UIApplication sharedApplication]   scheduleLocalNotification:notification];
                        }
                    }
                }
            }
        } completion:^(BOOL success, NSError *error) {
            if(success){
                
                //                if(modseqChanged){
                //
                //                }
                if (actInfo.uid == -1) {
                    [[NSNotificationCenter defaultCenter]postNotificationName:NEED_SHOW_NEWEMAILS_NOTIFICATION object:actInfo];
                } else {
                    [actInfo syncMessageFlagsFolder:actInfo.account.inbox modSeq:actInfo.account.inbox.modSeq completion:^(NSError* error){
                        //NSLog(@"Done syncing after loading messages");
                        //                    onSuccess(newMessages.count);
                        [actInfo fetchMissingMessageContents];
                    }];
                }

            } else {
                [[NSNotificationCenter defaultCenter]postNotificationName:@"RemovingTableLoader" object:nil];
            }
        }];
    }
}
- (void)resetIdleTimer {
    
    //    ////NSLog(@"idleTimer = %@",idleTimer);
    if (!self.idleTimer) {
        
        self.idleTimer = [NSTimer scheduledTimerWithTimeInterval:kIdleTimeInterval
                                                     target:self
                                                   selector:@selector(idleTimerExceeded)
                                                   userInfo:nil
                                                    repeats:NO];
    }
    else {
        if (fabs([self.idleTimer.fireDate timeIntervalSinceNow]) < kIdleTimeInterval-1.0) {
            [self.idleTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:kIdleTimeInterval]];
        }
    }
}
- (void)idleTimerExceeded {
    
    self.idleTimer = nil;
    [self resetIdleTimer];
    if (self.currentFetType == FetchAll) {
        for (AccountInfo *actInfo in self.allAccount) {
            actInfo.uid = -1;
            [actInfo fetchNewMessagesWithSuccess:^(NSUInteger newNum) {
                NSLog(@"##########SUCC NUM: %lu",(unsigned long)newNum);
            } failure:^(NSError *error) {
                NSLog(@"##########Faulie NUM: %@",error);
            }];
        }
    } else if (self.currentFetType == FetchCurrent) {
        AccountInfo *actInfo = [self getCurrentAccountInfo];
        actInfo.uid = -1;
        [actInfo fetchNewMessagesWithSuccess:^(NSUInteger newNum) {
            NSLog(@"##########SUCC NUM: %lu",(unsigned long)newNum);
        } failure:^(NSError *error) {
            NSLog(@"##########Faulie NUM: %@",error);
        }];
    } else {
        NSLog(@"##########Fetch None");
    }
}

- (AccountInfo *)connectGmailWithUsername:(NSString *)username password:(NSString *)password
{
    AccountInfo *retInfo = nil;
    if (!self.pendingAccount) {
        self.pendingAccount = [NSMutableArray new];
    }
    if ([self.pendingAccount count]<=0 ) {
        retInfo = [[AccountInfo alloc] init];
        retInfo.imapSession = [self connectWithUsername:username password:password host:@"imap.gmail.com" port:993];
        [self.pendingAccount addObject:retInfo];
    } else {
        BOOL inFlag = NO;
        for (AccountInfo *info in self.pendingAccount) {
            if ([info.imapSession.username isEqualToString:username]) {
                inFlag = YES;
                retInfo = info;
                break;
            }
        }
        if (!inFlag) {
            retInfo = [[AccountInfo alloc] init];
            retInfo.imapSession = [self connectWithUsername:username password:password host:@"imap.gmail.com" port:993];
            [self.pendingAccount addObject:retInfo];
        } else {
            retInfo.imapSession = [self connectWithUsername:username password:password host:@"imap.gmail.com" port:993];
        }
    }
    return retInfo;
}

- (MCOIMAPSession *)connectWithUsername:(NSString *)username password:(NSString *)password host:(NSString *)host port:(uint)port
{
    
    MCOIMAPSession *imapSession = [[MCOIMAPSession alloc] init];

    imapSession.hostname = host;
    imapSession.port = port;
    imapSession.username = username;
    imapSession.password = password;
    imapSession.connectionType = MCOConnectionTypeTLS;
    imapSession.allowsFolderConcurrentAccessEnabled = YES;
//    _connected = YES;
    
    return imapSession;
}

-(void)reloadAllAccount
{
    MDataManager *dataManager = [MDataManager sharedManager];
    self.currentAccoutIndex = 0;
    NSManagedObjectContext *managedObjectContext = dataManager.managedObjectContext;
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"status = YES"];
    
    NSArray *actAry = [Account findAllSortedBy:@"lastLoggedIn" ascending:YES withPredicate:predicate inContext:managedObjectContext];
    NSMutableArray *array = [NSMutableArray new];
    for (Account *act in actAry) {
        AccountInfo *info = [[AccountInfo alloc] init];
        MCOIMAPSession *imapSession = [[MCOIMAPSession alloc] init];
        
        imapSession.hostname = @"imap.gmail.com";
        imapSession.port = 993;
        imapSession.username = act.username;
        imapSession.password = act.password;
        imapSession.connectionType = MCOConnectionTypeTLS;
        imapSession.allowsFolderConcurrentAccessEnabled = YES;
        
        if (act.inbox == nil) {
            Folder *inbox = [Folder createEntity];
            inbox.name = @"INBOX";//@"[Gmail]/Drafts";//@"INBOX"
            inbox.account = act;
            act.inbox = inbox;
            //////NSLog(@"saveContext new inbox");
            [[MDataManager sharedManager] saveContextAsync];
        }
        info.imapSession = imapSession;
        info.account = act;
        [array addObject:info];
    }
    self.allAccount = array;
    
}
-(void) postError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ERROR_NOTIFICATION object:error];
}

- (void) logThread:(NSString *)message
{
    //////NSLog(@"THREAD %@: %@", message, [NSThread currentThread] == [NSThread mainThread] ? @"main thread" : @"secondary thread");
}


- (void) fetchMessagesFromFolder:(Folder *)folder startingUID:(int)uid count:(int)messageCount success:(void (^)(NSUInteger))onSuccess failure:(void (^)(NSError *))onFailure {
    
    
////NSLog(@"message.account.name  = %@",message.account.name );
    
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    
//    //////NSLog(@"[defaults boolForKey:@isList] = %d",[defaults boolForKey:@"isList"]);
//    
//    if ([defaults boolForKey:@"isList"]) {
    
    //NSLog(@"folder.account.username = %@",folder.account.username);
    
    //NSLog(@"uid = %d",uid);
    if (self.isBuzzy) {
        return;
    }
    _isBuzzy = YES;
    
    uint64_t oldmodseq = folder.modSeq;
    AccountInfo *actinfo = [self getCurrentAccountInfo];
    MCOIMAPFolderInfoOperation *folderInfo = [actinfo.imapSession folderInfoOperation:folder.name];

    MDataManager *dataManager = [MDataManager sharedManager];
    
    [folderInfo start:^(NSError *error, MCOIMAPFolderInfo *info){
        
        _isBuzzy = NO;
        //NSLog(@"FOLDERINFO request ended took %f", [start timeIntervalSinceNow]);
    
         if(error != nil){
             [self postError:error];
             //NSLog(@"FOLDERINFO error: %@", error);
             onFailure(error);
             return;
         }
        
        
        //NSLog(@"folder  = %@",folder.account);
        //NSLog(@"folder.uidValidity  = %d",folder.uidValidity);
        //NSLog(@"info.uidValidity  = %d",info.uidValidity);
        
        
        //first check uid validity to see if we have to throw out our local messages
//        if (info.uidValidity != folder.uidValidity) {
//            
//            //***********************DELETE*************************
//            
//             //Commented start
//            
////            ////NSLog(@"Different uidValidity, deleting all messages from local DB");
////            [[folder managedObjectContext] deleteObject:folder];
//            
//             //Commented end
//            
//            NSManagedObjectContext* context = dataManager.managedObjectContext;
//            NSFetchRequest * allMessages = [[NSFetchRequest alloc] init];
//            [allMessages setEntity:[NSEntityDescription entityForName:@"Message" inManagedObjectContext:context]];
//            [allMessages setIncludesPropertyValues:NO]; //only fetch the managedObjectID
//            
//            //Commented start
//            
//            NSError * error = nil;
//            NSArray * messages = [context executeFetchRequest:allMessages error:&error];
//            for (NSManagedObject* message in messages) {
//                
//                ////NSLog(@"...............Deleting Messages..............");
//                [context deleteObject:message];
//            }
//            //Commented end
//            
//            
//            //////NSLog(@"saveContext after FOLDERINFO");
//            [dataManager saveContextAsync];
//            
//            
//            
//        }
        
        
        //NSLog(@"FOLDERINFO: uidNext %d uidValidity %d modSequenceValue %llu messageCount %d",
//              info.uidNext,
//              info.uidValidity,
//              info.modSequenceValue,
//              info.messageCount);
        
        int numberOfMessages = messageCount - 1;
        int startUID = MAX(0, info.messageCount - numberOfMessages);
        
        //NSLog(@"FOLDERINFO: Message Count: %d Starting UID: %d Number of messages: %d",  info.messageCount, startUID, numberOfMessages);

        //NSLog(@"folder object: uidNext: %d modSeq: %lld", folder.uidNext, folder.modSeq);
        
        //check uidnext to see if we need to request new messages
        
        //getting it from the actual last message we have to avoid faulty data in folder object
        NSInteger lastUID = [folder lastUID];
        NSInteger lastUIDNext = lastUID + 1;
        //NSLog(@"lastUID: %d lastUIDNext: %d", lastUID, lastUIDNext);
        
        //NSLog(@"info.uidNext = %d",info.uidNext);
        //NSLog(@"lastUIDNext = %d",lastUIDNext);
        
        
        BOOL newMessagesPresent = info.uidNext > lastUIDNext;
        
        NSInteger newMessageCount = info.uidNext - lastUIDNext;
        BOOL firstLoad = folder.uidNext == 0;
        BOOL haveSpecificUid = uid != -1;
        BOOL modseqChanged = info.modSequenceValue != folder.modSeq && info.modSequenceValue != 0;
        
        //NSLog(@"new messages? %d count: %d modseq changed? %d", newMessagesPresent, newMessageCount, modseqChanged);

        MCOIMAPFetchMessagesOperation *fetchOperation;
        
        uint32_t fetchflags =  MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindFlags | MCOIMAPMessagesRequestKindStructure;
        
        NSInteger requestCount = messageCount;
        
        if(haveSpecificUid){
            
            //load from this UID
            MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(uid, messageCount)];
            //NSLog(@"UID Range: %@", uids);
            
            //NSLog(@"_imapSession.username: %@", _imapSession.username);
            AccountInfo *actinfo = [self getCurrentAccountInfo];

            fetchOperation = [actinfo.imapSession fetchMessagesByUIDOperationWithFolder:folder.name requestKind:fetchflags uids:uids];
        }
        
        else{
            //load most recent messages
            //if it's the first load, load using number operations, else UID
            
            if(firstLoad){
                //int initalBatchSize = 300;
                //numberOfMessages = initalBatchSize-1;
                //startUID = MAX(0,info.messageCount - numberOfMessages);
                MCOIndexSet *numbers = [MCOIndexSet indexSetWithRange:MCORangeMake(startUID, numberOfMessages)];
                //NSLog(@"Number Range: %@", numbers);
                fetchOperation = [_imapSession fetchMessagesByNumberOperationWithFolder:folder.name
                                                                   requestKind:fetchflags
                                                                       numbers:numbers];
            } else {
                //load new messages based on UID
                
                MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(lastUIDNext, newMessageCount-1)];
                //NSLog(@"UID Range for new messages: %@", uids);
                AccountInfo *actinfo = [self getCurrentAccountInfo];

                fetchOperation = [actinfo.imapSession fetchMessagesByUIDOperationWithFolder:folder.name requestKind:fetchflags uids:uids];
                requestCount = newMessageCount;
            }
        }

        [folder updateWithInfo:info];
        
        //NSLog(@"haveSpecificUid = %d",haveSpecificUid);
        //NSLog(@"firstLoad = %d",firstLoad);
        //NSLog(@"newMessagesPresent = %d",newMessagesPresent);
        
        if(!(haveSpecificUid || firstLoad || newMessagesPresent)){
            //don't need to do anything further, no new messages
            //NSLog(@"no new messages, not fetching anything");
            
            if(modseqChanged){
                
                [actinfo syncMessageFlagsFolder:folder modSeq:oldmodseq completion:^(NSError* error){
                    //NSLog(@"Done syncing after not loading messages");

                    onSuccess(0);
                }];
            } else{
                
                //NSLog(@"onSuccess(0) 222 ");
                onSuccess(0);
            }
            
            [actinfo fetchMissingMessageContents];
            
            //Commented
//            [self clearDeletedMessagesFolder:folder];
            return;
        }

//        NSDate* start = [NSDate date];
        /*
        [fetchOperation setProgress:^(unsigned int current){
            NSValue *value = [NSValue valueWithRange:NSMakeRange(current, requestCount)];
            [[NSNotificationCenter defaultCenter] postNotificationName:PROGRESS_FETCHING_NEW_MAIL_NOTIFICATION object:value];
        }];
         */
        
        NSMutableArray *checkArray = [[NSMutableArray alloc] init];
        
        [fetchOperation start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
            
        //NSLog(@"messages.count = %d",messages.count);
            
            if(error){
                [self postError:error];
                
                //NSLog(@"error from fetching headers: %@", error);
                //NSLog(@"error domain: %@", [error domain]);
                //NSLog(@"error user info: %@", [error userInfo]);
                //NSLog(@"localized code: %ld", (long)[error code]);
                //NSLog(@"localized description: %@", [error localizedDescription]);
                
                onFailure(error);

            }
            else {
                
//                //NSLog(@"FETCHMESSAGES request ended took %f", [start timeIntervalSinceNow]);
                //NSLog(@"FETCHMESSAGES Received message count: %lu Vanished Messages: %@", (unsigned long)messages.count, vanishedMessages);
                
                [checkArray addObjectsFromArray:messages];
                
                //NSLog(@"checkArray = %@",checkArray);
                
                NSMutableArray *newMessages = [[NSMutableArray alloc] init];
                
                for (MCOIMAPMessage * message in messages) {
                    Message* messageObject = [Message findMessageWithID:message.header.messageID];
                    if (messageObject == nil) {
                        messageObject = [Message messageWithMCOMessage:message folder:_folder];
                        [newMessages addObject:messageObject];
                    }
                }
                
                //NSLog(@"newMessages = %@",newMessages);

                //NSLog(@"saveContext after FETCHMESSAGES");
                
//                if ([newMessages count]) {
                
                [dataManager saveContextAsyncCompletion:^(BOOL success, NSError *error) {
                    
                    if(success){
                        //NSLog(@"Success");
                        
                        if(modseqChanged){
                            [actinfo syncMessageFlagsFolder:folder modSeq:oldmodseq completion:^(NSError* error){
                                //NSLog(@"Done syncing after loading messages");
                                onSuccess(newMessages.count);
                            }];
                        }else{
                            onSuccess(newMessages.count);
                        }
                        
//                        [self clearDeletedMessagesFolder:folder];

                        /*
                        for (Message *newMessage in [newMessages reverseObjectEnumerator]){
                            [[MMailManager sharedManager] fetchMessageContent:newMessage];
                        }
                         */
                        
                        [actinfo fetchMissingMessageContents];

                        /*
                        dispatch_queue_t queue;
                        queue = dispatch_queue_create("com.mailable.FetchMessageSummaryQueue", NULL);
                        NSManagedObjectContext *defaultContext = [NSManagedObjectContext defaultContext];
                        NSManagedObjectContext *backgroundMOC = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];

                        for (Message *newMessage in [newMessages reverseObjectEnumerator]){
                            NSManagedObjectID *moid = [newMessage objectID];
                            dispatch_async(queue, ^{
                                
                                [[MMailManager sharedManager] fetchMessageContent:newMessage];
                            });
                        }
                         */
                    }
                    else{
                        //NSLog(@"error.description == %@",error.description);
                        //NSLog(@"Failure");
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"RemovingTableLoader" object:nil];
                    }
                }];
                
//            }
            }
            
        }];
        
        MAppDelegate *delegate = (MAppDelegate *)[[UIApplication sharedApplication]delegate];
        
        if (![checkArray count] && delegate.ispulled) {
            
            //NSLog(@"No count");
            
            delegate.ispulled = NO;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopReloading" object:nil];

            
        }

    }];
    
//    }
    
}
- (void) beginFetchingAllMail
{
    for (AccountInfo *actInfo in self.allAccount) {
        [actInfo fetchNewMessagesWithSuccess:^(NSUInteger newNum) {
            
        } failure:^(NSError *error) {
            
        }];
    }
 
    
    //    [self fetchNewMail];
}
- (void) beginFetchingMail
{
    if (self.currentAccoutIndex < [self.allAccount count]) {
        AccountInfo *actInfo = [self.allAccount objectAtIndex:self.currentAccoutIndex];
        [actInfo fetchNewMessagesWithSuccess:^(NSUInteger newNum) {
            
        } failure:^(NSError *error) {
            
        }];
    }
//    [self fetchNewMail];
}

- (void) stopFetchingMail
{
    for (int i = 0 ; i<[self.allAccount count]; i++) {
        AccountInfo *actInfo = [self.allAccount objectAtIndex:i];
        [actInfo stopFetch];
    }
    [self stopTimer];
    
}

- (void) fetchNewMail
{
    
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if ([defaults boolForKey:@"isList"]) {
    
        //////NSLog(@"............fetchNewMail............");
    if ([self.allAccount count]>0 && self.currentAccoutIndex>0 && [self.allAccount count]<self.currentAccoutIndex) {
        AccountInfo *actInfo = [self.allAccount objectAtIndex:self.currentAccoutIndex];
        [actInfo fetchNewMessagesWithSuccess:^(NSUInteger newNum) {
            
        } failure:^(NSError *error) {
            
        }];
    }
   
//        [self fetchNewMailFromIDLE:NO];
//        [self restartTimer];
//    }
    
}

- (void) restartTimer
{
    [self stopTimer];
    
    //NSLog(@"FETCH_EVERY_X_MINUTES*60.0 = %f",FETCH_EVERY_X_MINUTES*60.0);
    
    self.fetchMailTimer = [NSTimer scheduledTimerWithTimeInterval:FETCH_EVERY_X_MINUTES*60.0
                                                           target:self
                                                         selector:@selector(fetchNewMail)
                                                         userInfo:nil
                                                          repeats:YES];
}

- (void) stopTimer
{
    
    //NSLog(@"self.fetchMailTimer.isValid = %d",self.fetchMailTimer.isValid);
    
    if(self.fetchMailTimer != nil && self.fetchMailTimer.isValid){
        
        //NSLog(@"*******************TIMER STOPS********************");
        
        [self.fetchMailTimer invalidate];
        self.fetchMailTimer = nil;
        
    }
    else{
         //NSLog(@"stopTimer Never stops");
    }
    
}

-(void) stopIDLE
{
    if(_idleOperation != nil){
        //NSLog(@"IDLE being killed");
        [_idleOperation interruptIdle];
        _idleOperation = nil;
    }
}

-(void) startIDLE
{
    [self stopIDLE];
    NSInteger lastUID = [self getCurrentFolder].lastUID;
    //NSLog(@"IDLE starting with last UID: %ld", (long)lastUID);
    MCOIMAPIdleOperation* op  = [_imapSession idleOperationWithFolder:[self getCurrentFolder].name lastKnownUID:(uint32_t)lastUID];
    _idleOperation = op;
    
    [op start:^(NSError *error) {
       //NSLog(@"IDLE ended");
        [self fetchNewMailFromIDLE:YES];
    }];
}

-(void) fetchNewMailFromIDLE:(BOOL)fromIDLE
{
    //NSLog(@"***************  fetchNewMailFromIDLE  *****************");
    
    _isFetching = YES;
    [self stopIDLE];
    [[NSNotificationCenter defaultCenter] postNotificationName:FETCHING_NEW_MAIL_NOTIFICATION object:nil];
    
//NSLog(@"[MMailManager sharedManager].currentAccount  = %@",[MMailManager sharedManager].currentAccount );
//NSLog(@"[MMailManager sharedManager].currentFolder  = %@",[MMailManager sharedManager].currentFolder );
//    
    //NSLog(@"_account = %@",_account);
    
    [self fetchMessagesFromFolder:[self getCurrentAccount].inbox startingUID:-1 count:FETCH_MESSAGE_COUNT success:^(NSUInteger newCount) {
        
        //NSLog(@"Success fetching messages");
        //NSLog(@"FETCH_MESSAGE_COUNT=%d",FETCH_MESSAGE_COUNT);
        //NSLog(@"newCount=%d",newCount);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:FETCHED_NEW_MAIL_HEADERS_NOTIFICATION object:@(newCount)];
        _isFetching = NO;
        ////NSLog(@"newCount  = %d",newCount);
        
        if (newCount == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FETCHED_NEW_MAIL_CONTENT_NOTIFICATION object:@(newCount)];
        }
        if(fromIDLE){
            [self startIDLE];
        }
        
    } failure:^(NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:ERROR_FETCHING_NEW_MAIL_NOTIFICATION object:nil];
        //NSLog(@"failed fetching messages: %@", error);
        _isFetching = NO;
        if(fromIDLE){
            [self startIDLE];
        }
    }];
}


- (NSArray *) attachmentsFromPart:(MCOAbstractPart *)superpart;
{
    if ([superpart isKindOfClass:[MCOAttachment class]]){
        return @[superpart];
    }
    
    if ([superpart isKindOfClass:[MCOAbstractMultipart class]]) {
        NSMutableArray *attachments = [[NSMutableArray alloc] init];
        MCOAbstractMultipart *multipart = (MCOAbstractMultipart *)superpart;
        for(MCOAbstractPart *part in multipart.parts){
            [attachments addObjectsFromArray:[self attachmentsFromPart:part]];
        }
        return [attachments copy];
    }
    
    return @[];
}


+ (MCOAttachment *) partFromPart:(MCOAbstractPart *)superpart mimeType:(NSString *)mimeType
{
    if ([superpart isKindOfClass:[MCOAttachment class]]){
        if ([superpart.mimeType.lowercaseString isEqualToString:mimeType]) {
            return (MCOAttachment *)superpart;
        }
        return nil;
    }
    
    MCOAttachment *lastAttachmentOfType = nil;
    
    if ([superpart isKindOfClass:[MCOAbstractMultipart class]]){
        MCOAbstractMultipart *multipart = (MCOAbstractMultipart *)superpart;
        
        for (MCOAbstractPart *part in multipart.parts) {
            MCOAttachment *attachment = [self partFromPart:part mimeType:mimeType];
            if (attachment != nil) {
                lastAttachmentOfType = attachment;
            }
        }
    }
    return lastAttachmentOfType;
    
}

+ (MCOAttachment *) htmlFromPart:(MCOAbstractPart *)superpart
{
    return [self partFromPart:superpart mimeType:@"text/html"];
}

+ (MCOAttachment *) plainTextFromPart:(MCOAbstractPart *)superpart
{
    return [self partFromPart:superpart mimeType:@"text/plain"];
}

//+ (MCOAttachment *) attachmentPart:(MCOAbstractPart *)superpart
//{
//    return [self partFromPart:superpart mimeType:@"text/plain"];
//}

- (void) fetchMessageContent:(Message *)message highPriority:(BOOL)highPriority
{
    ////NSLog(@".....................fetchMessageContent highPriority ...................");
    AccountInfo *actInfo = [self getAccountInfoByName:message.account.username];
    [actInfo realFetchMessageContent:message highPriority:YES];
    
    /*
    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
        [self logThread:@"RUNNING OPERATION BLOCK"];
        //////NSLog(@"Priority high? %d", (int) highPriority);
        [self realFetchMessageContent:message];
    }];
    
    [operation setCompletionBlock:^{
        //////NSLog(@"COMPLETED OPERATION count is %d", _fetchMessageQueue.operationCount);
    }];
    
    operation.queuePriority = highPriority ? NSOperationQueuePriorityHigh : NSOperationQueuePriorityNormal;
    
    
    [_fetchMessageQueue addOperation:operation];
    
    //////NSLog(@"Added operation count is: %d", _fetchMessageQueue.operationCount);
     */
    
}

- (void) fetchMessageContent:(Message *)message
{
    ////NSLog(@"///////////////////////////  fetchMessageContent:(Message *)message  //////////////////////");
    [self fetchMessageContent:message highPriority:NO];
    
}

-(void) checkAccount:(AccountInfo *)checkAcount Success:(void (^)(void))onSuccess failure:(void (^)(NSError *))onFailure
{
    if (checkAcount) {
        MCOIMAPOperation * op = [checkAcount.imapSession checkAccountOperation];
        [op start:^(NSError * error) {
            if(error){
                [self postError:error];
                onFailure(error);
                [self.allAccount removeObject:checkAcount];
            }
            else{
                [self.allAccount addObject:checkAcount];
                [self.pendingAccount removeObject:checkAcount];
                onSuccess();
            }
        }];
    } else {
        [self postError:nil];
        onFailure(nil);
        [self.allAccount removeObject:checkAcount];
    }

}

-(void) syncMessageRead:(Message *)message
{
    MCOIMAPStoreFlagsRequestKind requestKind;
    if (message.read) {
        requestKind = MCOIMAPStoreFlagsRequestKindAdd;
    } else {
        requestKind = MCOIMAPStoreFlagsRequestKindRemove;
    }
    
    //////NSLog(@"message.account.name 22222 = %@",message.account.name );
    //////NSLog(@"message.folder.name 22222 = %@",message.folder.account);
    
    
    MCOIMAPOperation * op = [_imapSession storeFlagsOperationWithFolder:message.folder.name
                                                                   uids:[MCOIndexSet indexSetWithIndex:message.uid.integerValue]
                                                                   kind:requestKind
                                                                  flags:MCOMessageFlagSeen];
    [op start:^(NSError * error) {
        if (error) {
            [self postError:error];
            //////NSLog(@"Error marking Read UID %@ : %@", message.uid, error);
        }
    }];
}

-(void) syncMessageArchive:(Message *)message
{
    MCOIMAPStoreFlagsRequestKind requestKind;
    if (message.archive) {
        requestKind = MCOIMAPStoreFlagsRequestKindAdd;
    } else {
        requestKind = MCOIMAPStoreFlagsRequestKindRemove;
    }
    
    //////NSLog(@"message.account.name 22222 = %@",message.account.name );
    //////NSLog(@"message.folder.name 22222 = %@",message.folder.account);
    
    
    MCOIMAPOperation * op = [_imapSession storeFlagsOperationWithFolder:message.folder.name
                                                                   uids:[MCOIndexSet indexSetWithIndex:message.uid.integerValue]
                                                                   kind:requestKind
                                                                  flags:MCOMessageFlagSeen];
    [op start:^(NSError * error) {
        if (error) {
            [self postError:error];
            //////NSLog(@"Error marking Read UID %@ : %@", message.uid, error);
        }
    }];
}

-(void) syncMessageSkip:(Message *)message
{
    MCOIMAPStoreFlagsRequestKind requestKind;
    if (message.passed) {
        requestKind = MCOIMAPStoreFlagsRequestKindAdd;
    } else {
        requestKind = MCOIMAPStoreFlagsRequestKindRemove;
    }
    
    //////NSLog(@"message.account.name 22222 = %@",message.account.name );
    //////NSLog(@"message.folder.name 22222 = %@",message.folder.account);
    
    
    MCOIMAPOperation * op = [_imapSession storeFlagsOperationWithFolder:message.folder.name
                                                                   uids:[MCOIndexSet indexSetWithIndex:message.uid.integerValue]
                                                                   kind:requestKind
                                                                  flags:MCOMessageFlagSeen];
    [op start:^(NSError * error) {
        if (error) {
            [self postError:error];
            //////NSLog(@"Error marking Read UID %@ : %@", message.uid, error);
        }
    }];
}


-(void) checkCapabilities
{
    MCOIMAPCapabilityOperation* op = [_imapSession capabilityOperation];
    //////NSLog(@"starting cap is %d", MCOIMAPCapabilityACL);
    
    [op start:^(NSError *error, MCOIndexSet *capabilities) {
    //MCOIMAPCapabilityQResync
        //////NSLog(@"server capabilities: %@", capabilities);
        
        NSArray* allCapabilities = [NSArray arrayWithObjects:
                                    @"BINARY", @"CATENATE", @"CHILDREN", @"COMPRESS", @"CONDSTORE", @"ENABLE", @"IDLE", @"ID", @"LITERAL+", @"MULTIAPPEND", @"NAMESPACE", @"QRESYNC", @"QUOTE", @"SORT", @"STARTTLS", @"THREAD=ORDEREDSUBJECT", @"THREAD=REFERENCES", @"UIDPLUS", @"UNSELECT", @"XLIST", @"AUTH=ANONYMOUS", @"AUTH=CRAM-MD5", @"AUTH=DIGEST-MD5", @"AUTH=EXTERNAL", @"AUTH=GSSAPI", @"AUTH=KERBEROSV4", @"AUTH=LOGIN", @"AUTH=NTML", @"AUTH=OTP", @"AUTH=PLAIN", @"AUTH=SKEY", @"AUTH=SRP", @"AUTH=XOAUTH2", nil];
        
        [capabilities enumerateIndexes:^(uint64_t idx) {
            if (idx < [allCapabilities count]) {
                //////NSLog(@"server capability: %@", [allCapabilities objectAtIndex:(NSUInteger)idx]);
            }
        }];
        
        MCOIMAPFetchFoldersOperation * subscribedOp = [_imapSession fetchSubscribedFoldersOperation];
        [subscribedOp start:^(NSError * error, NSArray * folders) {
            
            NSMutableArray* folderNames = [NSMutableArray array];
            for (MCOIMAPFolder* folder in folders){[folderNames addObject:folder.path];}
            //////NSLog(@"Subscribed folders: %@", folderNames);
        }];
        
    }];
}

-(void) deleteMessage:(Message *)message
{
    MCOIMAPOperation * op = [_imapSession storeFlagsOperationWithFolder:message.folder.name
                                                                   uids:[MCOIndexSet indexSetWithIndex:message.uid.integerValue]
                                                                   kind:MCOIMAPStoreFlagsRequestKindAdd
                                                                  flags:MCOMessageFlagDeleted];
    
    [op start:^(NSError * error) {
        if (error) {
            [self postError:error];
            //////NSLog(@"Error marking deleted UID %@ : %@", message.uid, error);
        } else {
            //////NSLog(@"Marked deleted UID %@ : %@", message.uid, error);
            
            MCOIMAPOperation * op = [_imapSession expungeOperation:message.folder.name];
            [op start:^(NSError *error) {
                if (error) {
                    //////NSLog(@"Error expunging: %@", error);
                } else {
                    //////NSLog(@"Expunged succefully");
                }
                
                [message deleteEntity];
                //////NSLog(@"saveContext message delete");
                [[MDataManager sharedManager] saveContextAsync];
            }];
        }
    }];
    
//    [self clearDeletedMessagesFolder:message.folder];
    
}

-(void) clearDeletedMessagesFolder:(Folder *)folder
{
    if (!CHECK_FOR_SERVER_DELETED_MESSAGES) {
        return;
    }
    
    MCOIMAPFetchMessagesOperation* op = [_imapSession fetchMessagesByUIDOperationWithFolder:folder.name
                                                                                requestKind:MCOIMAPMessagesRequestKindUid
                                                                                       uids:[folder rangeOfStoredUIDs]];
//    NSDate* start = [NSDate date];
    [op start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
        //////NSLog(@"FETCH UIDS for deletion request ended took %f", [start timeIntervalSinceNow]);
        if(error != nil){
            [self postError:error];
            //////NSLog(@"FETCH UIDS error aborting: %@", error);
            return;
        }
        NSMutableSet* serverUIDs = [NSMutableSet set];
        for (MCOIMAPMessage *serverMessage in messages){
            [serverUIDs addObject:@(serverMessage.uid)];
        }
        NSPredicate *notOnServer = [NSPredicate predicateWithBlock:^BOOL(Message *message, NSDictionary *bindings) {
            return ![serverUIDs containsObject:message.uid];
        }];
        NSArray *localMessages = [Message findAllSortedBy:@"uid" ascending:YES];
        NSArray *toDeleteLocally = [localMessages filteredArrayUsingPredicate:notOnServer];
        //////NSLog(@"Message to delete count: %lu", (unsigned long)[toDeleteLocally count]);
        if ([toDeleteLocally count] > 0) {
            [toDeleteLocally makeObjectsPerformSelector:@selector(deleteEntity)];
            //////NSLog(@"saveContext after DELETE VANISHED MESSAGES");
            [[MDataManager sharedManager] saveContextAsync];
        }
    }];
    
}

+(MCOAbstractPart *) preferredPart:(MCOAbstractMultipart *)multipart wantPlain:(BOOL)wantPlain
{
    for(MCOIMAPPart *subpart in multipart.parts) {
        BOOL isHTML = [subpart.mimeType.lowercaseString isEqualToString:@"text/html"];
        BOOL isPlaintext = [subpart.mimeType.lowercaseString isEqualToString:@"text/plain"];

        if ((isHTML && (!wantPlain)) || (isPlaintext && wantPlain)) {
            return (MCOAbstractPart *)subpart;
        }
    }
    return nil;
}

-(void)sendMessageTo:(Address *)to subject:(NSString *)subject text:(NSString *)text
{
    AccountInfo *actInfo = [[MMailManager sharedManager] getCurrentAccountInfo];
    [actInfo sendMessageTo:to subject:subject text:text];

}
- (void) sendMessageTo:(NSArray *)to/* MCOAddress */
                    Cc:(NSArray *)cc/* MCOAddress */
                   Bcc:(NSArray *)bcc/* MCOAddress */
              dataDict:(NSDictionary *)dictionary
{
    AccountInfo *actInfo = [[MMailManager sharedManager] getCurrentAccountInfo];
    [actInfo sendMessageTo:to Cc:cc Bcc:bcc dataDict:dictionary];
}
-(AccountInfo *)getCurrentAccountInfo
{
    if (self.currentAccoutIndex<[self.allAccount count]) {
        return [self.allAccount objectAtIndex:self.currentAccoutIndex] ;
    } else {
        self.currentAccoutIndex = [self.allAccount count]-1;
        return [self.allAccount lastObject];
    }
}
-(AccountInfo *)getAccountInfoByName:(NSString *)username
{
    for (AccountInfo *info in self.allAccount) {
        if ([info.account.username isEqual:username]) {
            return  info;
        }
    }
    return nil;
}
-(Account *)getCurrentAccount
{
    return [[self getCurrentAccountInfo] account];
}

- (void) logout:(AccountInfo *)actInfo completion:(void (^)(BOOL success,NSString *msg, NSError *error))completion
{

    [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
        actInfo.account.status = NO;
        [actInfo stopFetch];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"account = %@",actInfo.account];
        
        NSFetchRequest *request = [Message MR_requestAllWithPredicate:pred inContext:localContext];
        [request setReturnsObjectsAsFaults:YES];
        [request setIncludesPropertyValues:NO];
        
        NSArray *objectsToTruncate = [Message MR_executeFetchRequest:request inContext:localContext];
        
        for (id objectToTruncate in objectsToTruncate)
        {
            NSPredicate * pre = [NSPredicate predicateWithFormat:@"message = %@",objectToTruncate];
            NSFetchRequest *req = [Attachment MR_requestAllWithPredicate:pre inContext:localContext];
            [req setReturnsObjectsAsFaults:YES];
            [req setIncludesPropertyValues:NO];
            
            NSArray *attArray = [Attachment MR_executeFetchRequest:req inContext:localContext];
            for (Attachment *attach in attArray) {
                [attach MR_deleteEntity];
            }
            if (attArray && [attArray count]>0) {
                NSError *error = nil;
                NSString *path = [MFileManager directoryForMessage:objectToTruncate];
                BOOL ret = [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                if (!ret) {
                    NSLog(@"Remove Attachment>>>>>>ret:%d,%@",ret,error);
                }
            }
            [objectToTruncate MR_deleteInContext:localContext];
        }
        
        [Folder MR_deleteAllMatchingPredicate:pred inContext:localContext];
        
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"status = YES"];
        NSArray *_allAccounts = [Account findAllWithPredicate:predicate inContext:localContext];
        if (![_allAccounts count]) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setBool:NO forKey:@"IsLogin"];
            [defaults setInteger:0 forKey:@"selectedIndex"];
            [defaults synchronize];
        } else {
            [MMailManager sharedManager].currentAccoutIndex = 0;
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setInteger:0 forKey:@"selectedIndex"];
            [defaults synchronize];
        }
        
    } completion:^(BOOL success, NSError *error) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReloadHomeList" object:nil];
        [[MMailManager sharedManager] reloadAllAccount];
        completion(YES, nil, error);
    }];

}
#pragma mark - Sys Assistant Method

+(NSString *)getCpuInfo
{
    float	tot_cpu = 0;
    kern_return_t			kr = { 0 };
    task_info_data_t		tinfo = { 0 };
    mach_msg_type_number_t	task_info_count = TASK_INFO_MAX;
    
    kr = task_info( mach_task_self(), TASK_BASIC_INFO, (task_info_t)tinfo, &task_info_count );
    if ( KERN_SUCCESS == kr ) {
        task_basic_info_t		basic_info = { 0 };
        thread_array_t			thread_list = { 0 };
        mach_msg_type_number_t	thread_count = { 0 };
        
        thread_info_data_t		thinfo = { 0 };
        thread_basic_info_t		basic_info_th = { 0 };
        
        basic_info = (task_basic_info_t)tinfo;
        
        // get threads in the task
        kr = task_threads( mach_task_self(), &thread_list, &thread_count );
        if ( KERN_SUCCESS == kr ) {
            long	tot_sec = 0;
            long	tot_usec = 0;
            
            for ( int i = 0; i < thread_count; i++ ) {
                mach_msg_type_number_t thread_info_count = THREAD_INFO_MAX;
                
                kr = thread_info( thread_list[i], THREAD_BASIC_INFO, (thread_info_t)thinfo, &thread_info_count );
                if ( KERN_SUCCESS == kr ) {
                    basic_info_th = (thread_basic_info_t)thinfo;
                    
                    if ( 0 == (basic_info_th->flags & TH_FLAGS_IDLE) ) {
                        tot_sec		= tot_sec + basic_info_th->user_time.seconds + basic_info_th->system_time.seconds;
                        tot_usec	= tot_usec + basic_info_th->system_time.microseconds + basic_info_th->system_time.microseconds;
                        tot_cpu		= tot_cpu + basic_info_th->cpu_usage / (float)TH_USAGE_SCALE;
                    }
                }
            }
            kr = vm_deallocate( mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t) );
            if ( KERN_SUCCESS != kr ) {
                tot_cpu = -1;
            }
        }
    }
    return [NSString stringWithFormat:@"cpu:%0.1f%%",tot_cpu*100];
}
+(NSString *)getMemInfo
{
    int64_t				_usedBytes;
	int64_t				_totalBytes;
    
    struct mstats		stat = mstats();
	
	NSProcessInfo *		progress = [NSProcessInfo processInfo];
	unsigned long long	total = [progress physicalMemory];
	
	_usedBytes = stat.bytes_used;
	_totalBytes = total; // NSRealMemoryAvailable();
	
	if ( 0 == _usedBytes )
	{
		mach_port_t host_port;
		mach_msg_type_number_t host_size;
		vm_size_t pagesize;
        
		host_port = mach_host_self();
		host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
		host_page_size( host_port, &pagesize );
        
		vm_statistics_data_t vm_stat;
		kern_return_t ret = host_statistics( host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size );
		if ( KERN_SUCCESS != ret )
		{
			_usedBytes = 0;
			_totalBytes = 0;
		}
		else
		{
			natural_t mem_used = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * (natural_t)pagesize;
			natural_t mem_free = vm_stat.free_count * (natural_t)pagesize;
			natural_t mem_total = mem_used + mem_free;
            
			_usedBytes = mem_used;
			_totalBytes = mem_total;
		}
	}
    return [NSString stringWithFormat:@"mem:%lldMB/%lldMB",_usedBytes/(1024*1024),_totalBytes/(1024*1024)];
}
@end
