//
//  Message.m
//  Mailer
//
//  Created by Martin Ceperley on 10/1/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "Message.h"
#import "Account.h"
#import "Address.h"
#import "Folder.h"
#import "MDataManager.h"
#import "MMailManager.h"
#import "MFileManager.h"
#import "MDesignManager.h"

@implementation Message

@dynamic fromAddress;
@dynamic fromName;
@dynamic messageID;
@dynamic gmailThreadID;
@dynamic gmailMessageIDS;
@dynamic theadShow;
@dynamic receivedDate;
@dynamic subject;
@dynamic summary;
@dynamic body;
@dynamic uid;
@dynamic read;
@dynamic replied;
@dynamic flagged;
@dynamic deleted;
@dynamic draft;
@dynamic forwarded;
@dynamic submitPending;
@dynamic submitted;
@dynamic sent;
@dynamic fetched;
@dynamic archive;

@dynamic processed;
@dynamic passed;

@dynamic account;
@dynamic folder;
@dynamic address;

@dynamic from;
@dynamic to;
@dynamic replyTo;
@dynamic cc;
@dynamic bcc;

@dynamic characterCount;
@dynamic wordCount;

@dynamic attachments;
@dynamic imageAttachments;

@synthesize snapshotView;
@synthesize webView;
@synthesize image;

- (void) setFlagsFromMCOMessage:(MCOIMAPMessage *)mcoMessage
{
    MCOMessageFlag flags = mcoMessage.flags;
    
    self.read =          (flags & MCOMessageFlagSeen) == MCOMessageFlagSeen;
    self.replied =       (flags & MCOMessageFlagAnswered) == MCOMessageFlagAnswered;
    self.flagged =       (flags & MCOMessageFlagFlagged) == MCOMessageFlagFlagged;
    self.deleted =       (flags & MCOMessageFlagDeleted) == MCOMessageFlagDeleted;
    self.draft =         (flags & MCOMessageFlagDraft) == MCOMessageFlagDraft;
    self.forwarded =     (flags & MCOMessageFlagForwarded) == MCOMessageFlagForwarded;
    self.submitPending = (flags & MCOMessageFlagSubmitPending) == MCOMessageFlagSubmitPending;
    self.submitted =     (flags & MCOMessageFlagSubmitted) == MCOMessageFlagSubmitted;
    self.sent =          (flags & MCOMessageFlagMDNSent) == MCOMessageFlagMDNSent;
}

+ (Message *) messageWithMCOMessage:(MCOIMAPMessage *)mcoMessage folder:(Folder *)folder inManagedObjectContext:(NSManagedObjectContext *)context
{
    
    NSManagedObjectContext *managedObjectContext = context;
    NSEntityDescription *messageEntity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:managedObjectContext];
    Message *message = [[Message alloc] initWithEntity:messageEntity insertIntoManagedObjectContext:managedObjectContext];
    
    message.uid = @(mcoMessage.uid);
    message.messageID = mcoMessage.header.messageID;
    message.receivedDate = mcoMessage.header.receivedDate;
    message.fromName = mcoMessage.header.from.displayName;
    message.fromAddress = mcoMessage.header.from.mailbox;
    message.gmailThreadID =mcoMessage.gmailThreadID;
    message.from = [Address addressWithEmail:message.fromAddress name:message.fromName context:managedObjectContext];
    
    //    NSLog(@"message.from = %@",message.from);
    
    message.to =        [NSOrderedSet orderedSetWithArray:[Address addressesFromMCOAddresses:mcoMessage.header.to context:managedObjectContext]];
    message.cc =        [NSOrderedSet orderedSetWithArray:[Address addressesFromMCOAddresses:mcoMessage.header.cc context:managedObjectContext]];
    message.bcc =       [NSOrderedSet orderedSetWithArray:[Address addressesFromMCOAddresses:mcoMessage.header.bcc context:managedObjectContext]];
    message.replyTo =   [NSOrderedSet orderedSetWithArray:[Address addressesFromMCOAddresses:mcoMessage.header.replyTo context:managedObjectContext]];
    
    message.subject = mcoMessage.header.subject;
    
    //    NSLog(@"message.to = %@",message.to);
    
    //    NSLog(@"folder =-================= %@",folder);
    
    [message setFlagsFromMCOMessage:mcoMessage];
    
    message.folder = [folder inContext:managedObjectContext];
    message.account = [folder.account inContext:managedObjectContext];
    message.address = [message.from inContext:managedObjectContext];
    
    message.fetched = NO;
    message.archive = NO;
    message.theadShow = YES;

    return message;
}

+ (Message *) messageWithMCOMessage:(MCOIMAPMessage *)mcoMessage folder:(Folder *)folder
{
    
//    NSLog(@"mcoMessage = %@",mcoMessage);
    
//     NSLog(@"mcoMessage = %@",mcoMessage.header);
    
    MDataManager *dataManager = [MDataManager sharedManager];
    NSManagedObjectContext *managedObjectContext = dataManager.managedObjectContext;
    NSEntityDescription *messageEntity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:managedObjectContext];
    Message *message = [[Message alloc] initWithEntity:messageEntity insertIntoManagedObjectContext:managedObjectContext];
    
    message.uid = @(mcoMessage.uid);
    message.messageID = mcoMessage.header.messageID;
    message.receivedDate = mcoMessage.header.receivedDate;
    message.fromName = mcoMessage.header.from.displayName;
    message.fromAddress = mcoMessage.header.from.mailbox;
    
    message.from = [Address addressWithEmail:message.fromAddress name:message.fromName];
    
//    NSLog(@"message.from = %@",message.from);
    
    message.to =        [NSOrderedSet orderedSetWithArray:[Address addressesFromMCOAddresses:mcoMessage.header.to]];
    message.cc =        [NSOrderedSet orderedSetWithArray:[Address addressesFromMCOAddresses:mcoMessage.header.cc]];
    message.bcc =       [NSOrderedSet orderedSetWithArray:[Address addressesFromMCOAddresses:mcoMessage.header.bcc]];
    message.replyTo =   [NSOrderedSet orderedSetWithArray:[Address addressesFromMCOAddresses:mcoMessage.header.replyTo]];
    
    message.subject = mcoMessage.header.subject;
    
//    NSLog(@"message.to = %@",message.to);
    
//    NSLog(@"folder =-================= %@",folder);
    
    [message setFlagsFromMCOMessage:mcoMessage];
    
    message.folder = folder;
    message.account = folder.account;
    message.address = message.from;
    
    message.fetched = NO;
    message.archive = NO;
    message.theadShow = YES;
    return message;
}
+ (Message *) findMessagesWithGmailThreadID:(NSNumber *)gmailThreadID inContext:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"gmailThreadID = %@ AND theadShow = YES",gmailThreadID];
    NSArray *array = [Message MR_findAllSortedBy:@"receivedDate" ascending:YES withPredicate:predicate inContext:context];
    if (array && [array count]>=1) {
        return [array firstObject];
    }
    return nil;
//    return [Message MR_findByAttribute:@"gmailThreadID" withValue:gmailThreadID andOrderBy:@"receivedDate" ascending:YES];
}
+ (Message *) findMessageWithID:(NSString *)messageID
{
    return [Message findFirstByAttribute:@"messageID" withValue:messageID];
}

+ (Message *) updateMessageWithMCOMessage:(MCOIMAPMessage *)mcoMessage folder:(Folder *)folder
{
    Message* message = [Message findMessageWithID:mcoMessage.header.messageID];
    if(message == nil){
        //create message
        message = [Message messageWithMCOMessage:mcoMessage folder:folder];
        //NSLog(@"Creating message UID %@ Subject: %@", message.uid, [message.subject stringByPaddingToLength:20 withString:@" " startingAtIndex:0]);
    } else {
        [message setFlagsFromMCOMessage:mcoMessage];
        //NSLog(@"Updating message UID %@ Subject: %@", message.uid, [message.subject stringByPaddingToLength:20 withString:@" " startingAtIndex:0]);
    }
    return message;
}

- (void) toggleMarkRead
{
    self.read = !self.read;
    //NSLog(@"saveContext toggleMarkRead");
    [[MDataManager sharedManager] saveContextAsync];
    [[MMailManager sharedManager] syncMessageRead:self];

}

- (void) markRead
{
    if (!self.read) {
        
        self.read = YES;
        //NSLog(@"saveContext markRead");
        [[MDataManager sharedManager] saveContextAsync];
        [[MMailManager sharedManager] syncMessageRead:self];
    }
}

-(void) archiveAction{
    
    if (!self.archive) {
    
    self.archive = YES;
    [[MDataManager sharedManager] saveContextAsync];
    [[MMailManager sharedManager] syncMessageArchive:self];
        
    }

}

-(void) unarchiveAction{
    
    if (self.archive) {
        
        self.archive = NO;
        [[MDataManager sharedManager] saveContextAsync];
        [[MMailManager sharedManager] syncMessageArchive:self];
        
    }
    
}

- (void) markPassed
{
    if (!self.passed) {
        
        self.passed = YES;
        //NSLog(@"saveContext markPassed");
        [[MDataManager sharedManager] saveContextAsync];
        [[MMailManager sharedManager] syncMessageSkip:self];
        
    }
}

- (void) deleteMessage
{
    
//    NSLog(@"self.deleted = %d",self.deleted);
    
    if (self.deleted == NO) {
        self.deleted = YES;
        
//        [[MDataManager sharedManager] saveContextAsync];

        [[MMailManager sharedManager] deleteMessage:self];
        
    }
    
}

- (NSString *) htmlBody
{
    if (self.body == nil) {
        return @"";
    }
    
    MCOMessageParser* parser = [MCOMessageParser messageParserWithData:self.body];
    NSString *msgHTMLBody = [parser htmlRenderingWithDelegate:self];
    return msgHTMLBody;
}

- (NSString *)MCOAbstractMessage:(MCOAbstractMessage *)msg templateForMainHeader:(MCOMessageHeader *)header {
    
    UIColor *linkColor = [MDesignManager tintColor];
    CGFloat red, green, blue, alpha;
    [linkColor getRed:&red green:&green blue:&blue alpha:&alpha];
    //NSString *colorStyles = [NSString stringWithFormat:@"a:link {color:orange;}"];
    NSString *colorCSS = [NSString stringWithFormat:@"{color:rgb(%d,%d,%d);}", (int)red*255, (int)blue*255, (int)green*255];

    NSString *colorStyles = [NSString stringWithFormat:@"a:link, a:visited, a:hover, a:active %@", colorCSS];
    NSString *fontStyles = @"body {font-family:\"Helvetica\", sans-serif;}";
    NSString *tag = [NSString stringWithFormat:@"<style type=\"text/css\">%@\n%@</style>", fontStyles, colorStyles];
    return tag;
}

- (UIImage *) image
{
    if (image == nil) {
        image = [MFileManager snapshotImageForMessage:self];
    }
    return image;
}

- (void) setImage:(UIImage *)newImage
{
    image = newImage;
    [MFileManager writeSnapshotImage:self];
}

@end
