//
//  AccountInfo.m
//  Mailer
//
//  Created by backup on 14-4-30.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import "AccountInfo.h"
#import "Folder.h"
#import "MAppDelegate.h"
#import "MDataManager.h"
#import "MMailManager.h"
#import "Message.h"
#import "Attachment.h"
#import "NSString+MailExtensions.h"
#import "MMailManager.h"
#import "Address.h"
#import "Debug.h"

@implementation AccountInfo
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.showNewEmail = NO;
        self.cell = nil;
        self.uid = -1;
    }
    return self;
}
- (void) postError:(NSError *)error
{
    [[NSNotificationCenter defaultCenter] postNotificationName:ERROR_NOTIFICATION object:error];
}

- (void) fetchMessageContent:(Message *)message highPriority:(BOOL)highPriority
{
    [self realFetchMessageContent:message highPriority:highPriority];
}
- (void) fetchMessageContent:(Message *)message
{
    ////NSLog(@"///////////////////////////  fetchMessageContent:(Message *)message  //////////////////////");
    [self fetchMessageContent:message highPriority:NO];
    
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

- (void) realFetchMessageContent:(Message *)message highPriority:(BOOL)highPriority
{
    if (message.body != nil) {
        return;
    }
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if ([defaults boolForKey:@"isList"]) {
        
        MCOIMAPFetchContentOperation * op = [self.imapSession
                                             fetchMessageByUIDOperationWithFolder:message.folder.name
                                             uid:message.uid.intValue
                                             urgent:highPriority];
        
        NSManagedObjectID *objID = message.objectID;
        if (objID.isTemporaryID) {
            //////NSLog(@"UH OH in fetchMessageContent objID is a temporary ID!!!");
            [[MDataManager sharedManager] saveContextAndWait];
            objID = message.objectID;
        }
        
        _fetchContentTotalCount += 1;
        
        [op start:^(NSError * error, NSData * messageData) {
            if(error == nil){
                //NSLog(@"fetched message");
                
                [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                    Message *mess = [message inContext:localContext];
                    
                    if  (mess == nil){
                        //////NSLog(@"Message is nil!!");
                        return;
                    }
                    
                    mess.body = messageData;
                    mess.fetched = YES;
                    
                    MCOMessageParser *parser = [MCOMessageParser messageParserWithData:messageData];
                    
                    NSString* plaintextRendering = parser.plainTextBodyRendering;
                    TextCount tc = [plaintextRendering characterAndWordCounts];
                    mess.characterCount = (int32_t)tc.character;
                    mess.wordCount = (int32_t)tc.word;
                    NSString* summary = [parser.plainTextBodyRendering stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    mess.summary = [summary substringToIndex:MIN(400,[summary length])];
                    
                    if(parser.mainPart == nil){
                        return;
                    }
                    
                    NSArray *attachments = [self attachmentsFromPart:parser.mainPart];
                    //                ////NSLog(@"attachments=%@",attachments);
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    
                    NSMutableArray *newAttachments = [[NSMutableArray alloc] init];
                    for (MCOAttachment *mcoAttachment in attachments) {
                        
                        if (message.folder.account !=  self.account) {
                            
                            ////NSLog(@"break11111...........");
                            break;
                            
                        }
                        
                        if (![defaults boolForKey:@"isList"]) {
                            ////NSLog(@"break22222...........");
                            break;
                        }

                        
                        
                        BOOL isText = [mcoAttachment.mimeType isEqualToString:@"text/plain"]  ||
                        [mcoAttachment.mimeType isEqualToString:@"text/html"] ;
                        
                        BOOL isImage =  [[mcoAttachment.mimeType lowercaseString] isEqualToString:@"image/jpg"]  ||
                        [[mcoAttachment.mimeType lowercaseString] isEqualToString:@"image/jpeg"] ||
                        [[mcoAttachment.mimeType lowercaseString] isEqualToString:@"image/png"];

                        
                        if (!isText) {
                            
                            
                            
                            if (isImage) {
                                
                                NSData *data = mcoAttachment.data;
                                UIImage *image = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
                                
                                Attachment *attachment = [Attachment createInContext:localContext];
                                
                                attachment.message = mess;
                                if (mcoAttachment.contentID != nil) {
                                    attachment.contentID = mcoAttachment.contentID;
                                }
                                attachment.uniqueID = mcoAttachment.uniqueID;
                                attachment.mimeType = mcoAttachment.mimeType;
                                attachment.filename = mcoAttachment.filename;
                                attachment.size = (int32_t)data.length;
                                attachment.isImage = YES;
                                attachment.haveFile = YES;
                                
                                attachment.data = data;
                                attachment.image = image;
                                [newAttachments addObject:attachment];
                            }
                            
                            else{
                                
                                NSData *data = mcoAttachment.data;
                                UIImage *image = [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
                                
                                Attachment *attachment = [Attachment createInContext:localContext];
                                
                                attachment.message = mess;
                                if (mcoAttachment.contentID != nil) {
                                    attachment.contentID = mcoAttachment.contentID;
                                }
                                attachment.uniqueID = mcoAttachment.uniqueID;
                                attachment.mimeType = mcoAttachment.mimeType;
                                attachment.filename = mcoAttachment.filename;
                                attachment.size = (int32_t)data.length;
                                attachment.isImage = NO;
                                attachment.haveFile = YES;
                                
                                attachment.data = data;
                                attachment.image = image;
                                [newAttachments addObject:attachment];
                                
                            }
                            
                        }
                        
                        [[MDataManager sharedManager] saveContextAsync];
                        
                    }
                    
                }  completion:^(BOOL success, NSError *error) {
                    
                    if (message.folder.account ==  self.account) {
                        
                        if ([defaults boolForKey:@"isList"]) {
                            ////NSLog(@"break...........");
                            
                            _fetchContentCompletedCount += 1;
                            NSValue *value = [NSValue valueWithRange:
                                              NSMakeRange(_fetchContentCompletedCount, _fetchContentTotalCount)];
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:PROGRESS_FETCHING_NEW_MAIL_NOTIFICATION object:value];
                            
                            if (_fetchContentCompletedCount == _fetchContentTotalCount) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:FETCHED_NEW_MAIL_CONTENT_NOTIFICATION object:@(_fetchContentCompletedCount)];
                                _fetchContentTotalCount = 0;
                                _fetchContentCompletedCount = 0;
                            }
                            
                            if (message.attachments.count > 0) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:FETCHED_NEW_ATTACHMENT_NOTIFICATION object:nil];
                            }
                            
                            if (success) {
                                [[NSNotificationCenter defaultCenter] postNotificationName:MESSAGE_BODY_FETCHED_NOTIFICATION object:message.objectID];
                            }
                            
                        }
                        
                    }
                    
                }];
                
            } else {
                [self postError:error];
            }
        }];
        
    }
}

- (void) fetchMissingMessageContents
{
    [[NSNotificationCenter defaultCenter]postNotificationName:SHOW_STATUS_NOTIFICATION object:[NSString stringWithFormat:@"Downloading email content"]];
    NSArray *missingMessages = [Message findByAttribute:@"fetched"
                                              withValue:@(NO)
                                             andOrderBy:@"receivedDate"
                                              ascending:NO];
    
    //    MAppDelegate *delegate = (MAppDelegate *) [[UIApplication sharedApplication]delegate];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    for (Message *message in missingMessages){
        
        if (message.account !=  self.account) {
            
            break;
            
        }
        
        if (![defaults boolForKey:@"isList"]) {
            break;
        }
        [self fetchMessageContent:message];
        
    }
}
- (void) syncMessageFlagsFolder:(Folder *)folder modSeq:(uint64_t)modseq completion:(void (^)(NSError *))completion
{
    if(modseq == 0){
        return;
    }
    BIDERROR("Synchronizing");
    [[NSNotificationCenter defaultCenter]postNotificationName:SHOW_STATUS_NOTIFICATION object:[NSString stringWithFormat:@"Synchronizing"]];

    MCOIndexSet* range = [folder rangeOfStoredUIDs];
    
    MCOIMAPFetchMessagesOperation * op = [self.imapSession syncMessagesByUIDWithFolder:folder.name
                                                                       requestKind:MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindFlags
                                                                              uids:range
                                                                            modSeq:modseq];
    [op start:^(NSError * error, NSArray * messages, MCOIndexSet * vanishedMessages) {
        //////NSLog(@"SYNC request ended took %f", [start timeIntervalSinceNow]);
        if (error != nil) {
            [self postError:error];
        }
        
        NSMutableArray *newMessages = [[NSMutableArray alloc] init];
        
        if(messages != nil && [messages count] > 0){
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            
            for(MCOIMAPMessage* mcoMessage in messages){
                
                if (folder.account !=  self.account) {
                    
                    break;
                    
                }
                
                if (![defaults boolForKey:@"isList"]) {
                    break;
                }
                Message *updatedOrNewMessage = [Message updateMessageWithMCOMessage:mcoMessage folder:folder];
                if (updatedOrNewMessage.objectID.isTemporaryID) {
                    [newMessages addObject:updatedOrNewMessage];
                }
            }
            
        } else {
            //NSLog(@"SYNC NO added or updated messages");
        }
        
        if(vanishedMessages != nil  && [vanishedMessages count] > 0){
            //NSLog(@"SYNC vanished messages: %@", vanishedMessages);
        } else {
            //NSLog(@"SYNC NO vanished messages");
        }
        
        //Need to get folder info to get current modSeq
        //NSLog(@"saveContext after SYNC");
        
        [[MDataManager sharedManager] saveContextAsyncCompletion:^(BOOL success, NSError *error) {
            if(success){
                for (Message *newMessage in newMessages){
                    
                    //NSLog(@"...........Fetching.............");
                    
                    //////NSLog(@"[MMailManager sharedManager].currentAccount === %@",[MMailManager sharedManager].currentAccount.name);
                    //////NSLog(@"[MMailManager sharedManager].currentFolder.name === %@",[MMailManager sharedManager].currentFolder.account);
                    
                    [[MMailManager sharedManager] fetchMessageContent:newMessage];
                    
                }
            }
        }];
        
        completion(error);
    }];
}
- (void)addToSystemNotification:(NSString *)msg
{
    UILocalNotification *notification=[[UILocalNotification alloc] init];
    if (notification!=nil) {
        NSDate *now=[NSDate date];
        notification.fireDate=[now dateByAddingTimeInterval:2];
        notification.timeZone=[NSTimeZone defaultTimeZone];
        notification.alertBody= msg;
        [[UIApplication sharedApplication]   scheduleLocalNotification:notification];
    }
}
- (void) fetchNewMessagesWithSuccess:(void (^)(NSUInteger))onSuccess
                             failure:(void (^)(NSError *))onFailure
{
    if (!self.account) {
        return;
    }
    MCOIMAPSession *imapSession = self.imapSession;
    Folder *folder = self.account.inbox;
    if (!folder) {
        return;
    }
    int messageCount = 10;
    if (self.isBuzzy) {
        return;
    }
    _isBuzzy = YES;
    
    uint64_t oldmodseq = folder.modSeq;
    MCOIMAPFolderInfoOperation *folderInfo = [imapSession folderInfoOperation:folder.name];

    BIDERROR("fetch New Email: %s uid:%d",[self.account.username cStringUsingEncoding:NSASCIIStringEncoding],self.uid);
    if (self.uid<0) {
        [[NSNotificationCenter defaultCenter]postNotificationName:SHOW_STATUS_NOTIFICATION object:[NSString stringWithFormat:@"Fetching new emails"]];
    } else {
        [[NSNotificationCenter defaultCenter]postNotificationName:SHOW_STATUS_NOTIFICATION object:[NSString stringWithFormat:@"Updating"]];
    }
    [folderInfo start:^(NSError *error, MCOIMAPFolderInfo *info){
        
        _isBuzzy = NO;
        
        if(error != nil){
            [self postError:error];
            onFailure(error);
            return;
        }
        
        
        int numberOfMessages = messageCount - 1;
        int startUID = MAX(0, info.messageCount - numberOfMessages);
        dispatch_async(dispatch_get_global_queue(0, 0), ^{

            NSInteger lastUID = [folder lastUID];
            NSInteger lastUIDNext = lastUID + 1;
            
            BOOL newMessagesPresent = info.uidNext > lastUIDNext;
            
            NSInteger newMessageCount = info.uidNext - lastUIDNext;
            BOOL firstLoad = folder.uidNext == 0;
            BOOL haveSpecificUid = self.uid != -1;
            
            BOOL modseqChanged = info.modSequenceValue != folder.modSeq && info.modSequenceValue != 0;
            
            //NSLog(@"new messages? %d count: %d modseq changed? %d", newMessagesPresent, newMessageCount, modseqChanged);
            
            MCOIMAPFetchMessagesOperation *fetchOperation;
            
            uint32_t fetchflags =  MCOIMAPMessagesRequestKindHeaders | MCOIMAPMessagesRequestKindFlags | MCOIMAPMessagesRequestKindStructure ;
//            if (self.gmailCapability == YES)
            {
                fetchflags |= MCOIMAPMessagesRequestKindGmailLabels | MCOIMAPMessagesRequestKindGmailThreadID | MCOIMAPMessagesRequestKindGmailMessageID;
            }
            NSInteger requestCount = messageCount;
            
            if(haveSpecificUid) {
                
                MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(self.uid, messageCount)];
                
                fetchOperation = [imapSession fetchMessagesByUIDOperationWithFolder:folder.name requestKind:fetchflags uids:uids];
            } else {
                
                if(firstLoad){
                    MCOIndexSet *numbers = [MCOIndexSet indexSetWithRange:MCORangeMake(startUID, numberOfMessages)];
                    fetchOperation = [imapSession fetchMessagesByNumberOperationWithFolder:folder.name
                                                                               requestKind:fetchflags
                                                                                   numbers:numbers];
                } else {
                    MCOIndexSet *uids = [MCOIndexSet indexSetWithRange:MCORangeMake(lastUIDNext, newMessageCount-1)];
                    //NSLog(@"UID Range for new messages: %@", uids);
                    fetchOperation = [imapSession fetchMessagesByUIDOperationWithFolder:folder.name requestKind:fetchflags uids:uids];
                    requestCount = newMessageCount;
                }
            }
            if (![folder isFault]) {
                [folder updateWithInfo:info];
            } else {

                BIDERROR(">>>>>>>check folder");
                return ;
            }
            
            if(!(haveSpecificUid || firstLoad || newMessagesPresent)) {
                if(modseqChanged) {
                    [self syncMessageFlagsFolder:folder modSeq:oldmodseq completion:^(NSError* error){
                        onSuccess(0);
                    }];
                } else {
                    onSuccess(0);
                }
                
                [self fetchMissingMessageContents];
                
                return;
            }
            
            [fetchOperation start:^(NSError *error, NSArray *messages, MCOIndexSet *vanishedMessages) {
                
                
                if(error) {
                    [self postError:error];
                    onFailure(error);
                    
                } else {
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        
                        self.commingMessages = [[NSMutableArray alloc] init];
#if 1
                        __block NSInteger newEmailCount = 0;
                        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
                            for (MCOIMAPMessage * message in messages) {
#if FOLDER_DEBUG
                                if (folder.firstUID > message.uid || folder.firstUID <=0 ) {
                                    folder.firstUID = message.uid;
                                }
                                if (folder.lastUID<message.uid) {
                                    folder.lastUID = message.uid;
                                }
                                
                                NSLog(@"folder.firstUID:%lld folder.lastUID:%lld uid=%d",folder.firstUID,folder.lastUID,message.uid);
#endif
                                Message *messageObject = [Message findMessagesWithGmailThreadID:[NSNumber numberWithLongLong:message.gmailThreadID] inContext:localContext];
                                if (messageObject==nil) {
                                    newEmailCount++;
                                    Message *email = [Message messageWithMCOMessage:message folder:self.account.inbox inManagedObjectContext:localContext];
                                    if (self.uid == -1) {
                                        [self addToSystemNotification:email.subject];
                                    }
                                } else {
                                    if (![messageObject.messageID isEqualToString:message.header.messageID]) {
                                        NSMutableArray *messageIds = nil;
                                        if (messageObject.gmailMessageIDS && [messageObject.gmailMessageIDS length]>0) {
                                            messageIds = [[messageObject.gmailMessageIDS componentsSeparatedByString:@","] mutableCopy];
                                            [messageIds addObject:message.header.messageID];
                                        } else {
                                            messageIds = [NSMutableArray new];
                                            [messageIds addObject:message.header.messageID];
                                            [messageIds addObject:messageObject.messageID];
                                        }
                                        newEmailCount++;
                                        Message *email = [Message messageWithMCOMessage:message folder:self.account.inbox inManagedObjectContext:localContext];
                                        if ([messageObject.receivedDate compare:message.header.receivedDate] == NSOrderedAscending) {
                                            messageObject.theadShow = YES;
                                            email.theadShow = NO;
                                            messageObject.gmailMessageIDS = [messageIds componentsJoinedByString:@","];
                                        } else {
                                            email.theadShow = YES;
                                            messageObject.theadShow = NO;
                                            email.gmailMessageIDS = [messageIds componentsJoinedByString:@","];
                                        }
                                        if (self.uid == -1) {
                                            [self addToSystemNotification:email.subject];
                                        }
                                    }
                                }
                            }
                        }completion:^(BOOL success, NSError *error) {
                            if(success){
                                
                                //                if(modseqChanged){
                                //
                                //                }
                                if (self.uid == -1) {
                                    if (newEmailCount > 1) {
                                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                                    }

                                    [[NSNotificationCenter defaultCenter]postNotificationName:NEED_SHOW_NEWEMAILS_NOTIFICATION object:self];
                                } else {
                                    [self syncMessageFlagsFolder:self.account.inbox modSeq:self.account.inbox.modSeq completion:^(NSError* error){
                                        //NSLog(@"Done syncing after loading messages");
                                        //                    onSuccess(newMessages.count);
                                        [self fetchMissingMessageContents];
                                    }];
                                }
                                
                            } else {
                                [[NSNotificationCenter defaultCenter]postNotificationName:@"RemovingTableLoader" object:nil];
                            }
                        }];
#else
                        for (MCOIMAPMessage * message in messages) {
#if FOLDER_DEBUG
                            if (folder.firstUID > message.uid || folder.firstUID <=0 ) {
                                folder.firstUID = message.uid;
                            }
                            if (folder.lastUID<message.uid) {
                                folder.lastUID = message.uid;
                            }
                            
                            NSLog(@"folder.firstUID:%lld folder.lastUID:%lld uid=%d",folder.firstUID,folder.lastUID,message.uid);
#endif
                            Message* messageObject = [Message findMessageWithID:message.header.messageID];
                            if (messageObject == nil) {
                                [self.commingMessages addObject:message];
                                self.showNewEmail = YES;
                                
                            }
                        }
                        dispatch_async(dispatch_get_main_queue(), ^{

                            if (self.showNewEmail) {
                                if (self.cell && [self.cell respondsToSelector:@selector(setNewEmailHidden:)]) {
                                    [self.cell setNewEmailHidden:NO];
                                }
                                [[NSNotificationCenter defaultCenter] postNotificationName:GOT_NEWEMAILS_NOTIFICATION object:self];
                                [[NSNotificationCenter defaultCenter]postNotificationName:SHOW_STATUS_NOTIFICATION object:[NSString stringWithFormat:@"%@ got %lu new emails",folder.account.address.email,(unsigned long)[self.commingMessages count]]];
                                BIDERROR("%s",[[NSString stringWithFormat:@"%@ got %lu new emails",folder.account.address.email,(unsigned long)[self.commingMessages count]] cStringUsingEncoding:NSASCIIStringEncoding]);

                            } else {
                                [[NSNotificationCenter defaultCenter]postNotificationName:SHOW_STATUS_NOTIFICATION object:[NSString stringWithFormat:@"Up to date"]];
                                BIDERROR("Up to date");
                            }
                            
                            onSuccess(0);
                        });
#endif
                    });
                }
                
            }];
        });
        
        
        MAppDelegate *delegate = (MAppDelegate *)[[UIApplication sharedApplication]delegate];
        
        if (delegate.ispulled) {
            
            delegate.ispulled = NO;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"stopReloading" object:nil];
            
        }
        
    }];
}
- (void) stopFetch
{
    _stopFetching = YES;
    _isBuzzy = NO;
    [self.imapSession cancelAllOperations];
}

- (void) sendMessageTo:(Address *)to subject:(NSString *)subject text:(NSString *)text
{
    if (!self.smtpSession) {
        self.smtpSession = [[MCOSMTPSession alloc] init];
    }
    self.smtpSession.hostname = @"smtp.gmail.com";
    self.smtpSession.port = 465;
    self.smtpSession.username = self.account.username;
    self.smtpSession.password = self.account.password;
    self.smtpSession.connectionType = MCOConnectionTypeTLS;
    
    Account* account = self.account;
    
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    builder.header.to = @[to.mcoAddress];
    builder.header.from = account.address.mcoAddress;
    builder.header.subject = subject;
    builder.textBody = text;
    
    NSData *rfc822Data = builder.data;
    
    MCOSMTPOperation * op = [self.smtpSession checkAccountOperationWithFrom:[MCOAddress addressWithMailbox:self.smtpSession.username]];
    
    [op start:^(NSError *error) {
        if (error) {
            //////NSLog(@"SMTP Error connecting: %@", error);
        } else {
            //////NSLog(@"SMTP Successfully connected");
            MCOSMTPSendOperation *sendOperation = [self.smtpSession sendOperationWithData:rfc822Data];
            [sendOperation start:^(NSError *error) {
                if (error) {
                    //////NSLog(@"SMTP Error sending: %@", error);
                } else {
                    //////NSLog(@"SMTP Succesfully sent email!");
                }
                
            }];
        }
    }];
}


//- (void) sendMessageTo:(Address *)to
//              dataDict:(NSDictionary *)dictionary

- (void) sendMessageTo:(NSArray *)to/* MCOAddress */
                    Cc:(NSArray *)cc/* MCOAddress */
                   Bcc:(NSArray *)bcc/* MCOAddress */
              dataDict:(NSDictionary *)dictionary

{
    Account* account = self.account;
    
    if (!account) {
        account = [[MMailManager sharedManager].allAccount firstObject];
    }
    NSString *subject = [dictionary valueForKey:@"subject"];
    NSString *text = [dictionary valueForKey:@"text"];
    NSArray *attachmentArray = [NSArray arrayWithArray:[dictionary valueForKey:@"attachements"]];
    //    //NSLog(@"attachmentArray =%@",attachmentArray);
    
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = @"smtp.gmail.com";
    smtpSession.port = 465;
    smtpSession.username = account.username;
    smtpSession.password = account.password;
    smtpSession.connectionType = MCOConnectionTypeTLS;
    
    
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    builder.header.to = to;
    builder.header.cc = cc;
    builder.header.bcc = bcc;
    builder.header.from = account.address.mcoAddress;
    builder.header.subject = subject;
    builder.textBody = text;
    
    if ([attachmentArray count]) {
        
        for (int i =0; i < [attachmentArray count]; i++) {
            
            NSData *imgData = [attachmentArray objectAtIndex:i];
            MCOAttachment *mcoAttachmnt =  [MCOAttachment attachmentWithData:imgData filename:[NSString stringWithFormat:@"image%d",i+1]];
            mcoAttachmnt.mimeType = @"image/png";
            [builder addAttachment:mcoAttachmnt];
            
        }
    }
    
    //    builder.attachments = attachmentArray;
    
    NSData *rfc822Data = builder.data;
    
    MCOSMTPOperation * op = [smtpSession checkAccountOperationWithFrom:[MCOAddress addressWithMailbox:smtpSession.username]];
    
    [op start:^(NSError *error) {
        if (error) {
            //////NSLog(@"SMTP Error connecting: %@", error);
        } else {
            //////NSLog(@"SMTP Successfully connected");
            MCOSMTPSendOperation *sendOperation = [smtpSession sendOperationWithData:rfc822Data];
            [sendOperation start:^(NSError *error) {
                if (error) {
                    //////NSLog(@"SMTP Error sending: %@", error);
                } else {
                    //////NSLog(@"SMTP Succesfully sent email!");
                }
                
            }];
        }
    }];
}
@end
