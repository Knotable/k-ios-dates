//
//  Message.h
//  Mailer
//
//  Created by Martin Ceperley on 10/1/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <MailCore/MailCore.h>

@class Account, Address, Folder, Attachment,Address;

@interface Message : NSManagedObject <MCOHTMLRendererDelegate>

@property (nonatomic, retain) NSString * fromAddress;
@property (nonatomic, retain) NSString * fromName;
@property (nonatomic, retain) NSString * messageID;
@property (nonatomic, retain) NSDate * receivedDate;
@property (nonatomic, retain) NSString * subject;
@property (nonatomic, retain) NSNumber * uid;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSData * body;
@property (nonatomic, retain) NSString * gmailMessageIDS;
@property (nonatomic) BOOL theadShow;
@property (nonatomic, retain) Account *account;
@property (nonatomic, retain) Folder *folder;
@property (nonatomic, retain) Address *address;

@property (nonatomic, retain) Address *from;
@property (nonatomic, retain) NSOrderedSet *replyTo;
@property (nonatomic, retain) NSOrderedSet *to;
@property (nonatomic, retain) NSOrderedSet *cc;
@property (nonatomic, retain) NSOrderedSet *bcc;


/* Boolean message flags */
@property (nonatomic) BOOL fetched;
@property (nonatomic) BOOL read;
@property (nonatomic) BOOL replied;
@property (nonatomic) BOOL flagged;
@property (nonatomic) BOOL deleted;
@property (nonatomic) BOOL draft;
@property (nonatomic) BOOL forwarded;
@property (nonatomic) BOOL submitPending;
@property (nonatomic) BOOL submitted;
@property (nonatomic) BOOL sent;
@property (nonatomic) BOOL archive;

@property (nonatomic) BOOL passed;
@property (nonatomic) BOOL processed;
@property (nonatomic) uint64_t gmailThreadID;

@property (nonatomic) int32_t characterCount;
@property (nonatomic) int32_t wordCount;

/* Attachments */
@property (nonatomic, retain) NSOrderedSet *attachments;
@property (nonatomic, readonly) NSArray *imageAttachments;


/*
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSNumber * replied;
@property (nonatomic, retain) NSNumber * flagged;
@property (nonatomic, retain) NSNumber * deleted;
@property (nonatomic, retain) NSNumber * draft;
@property (nonatomic, retain) NSNumber * forwarded;
@property (nonatomic, retain) NSNumber * submitPending;
@property (nonatomic, retain) NSNumber * submitted;
@property (nonatomic, retain) NSNumber * sent;
*/

@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong) UIView * snapshotView;
@property (nonatomic, strong) UIImage * image;


+ (Message *) messageWithMCOMessage:(MCOIMAPMessage *)mcoMessage folder:(Folder *)folder inManagedObjectContext:(NSManagedObjectContext *)context;
+ (Message *) messageWithMCOMessage:(MCOIMAPMessage *)mcoMessage folder:(Folder *)folder;
+ (Message *) findMessagesWithGmailThreadID:(NSNumber *)gmailThreadID inContext:(NSManagedObjectContext *)context;
+ (Message *) findMessageWithID:(NSString *)messageID;

+ (Message *) updateMessageWithMCOMessage:(MCOIMAPMessage *)mcoMessage folder:(Folder *)folder;

- (void) markRead;
- (void) toggleMarkRead;

- (void) markPassed;

- (void) deleteMessage;
-(void)archiveAction;
-(void) unarchiveAction;

- (NSString *) htmlBody;


@end

@interface Message (CoreDataGeneratedAccessors)

/* TO */
- (void)insertObject:(Address *)value inToAtIndex:(NSUInteger)idx;
- (void)removeObjectFromToAtIndex:(NSUInteger)idx;
- (void)insertTo:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeToAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInToAtIndex:(NSUInteger)idx withObject:(Address *)value;
- (void)replaceToAtIndexes:(NSIndexSet *)indexes withTo:(NSArray *)values;
- (void)addToObject:(Address *)value;
- (void)removeToObject:(Address *)value;
- (void)addTo:(NSOrderedSet *)values;
- (void)removeTo:(NSOrderedSet *)values;

/* CC */

- (void)insertObject:(Address *)value inCcAtIndex:(NSUInteger)idx;
- (void)removeObjectFromCcAtIndex:(NSUInteger)idx;
- (void)insertCc:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeCcAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInCcAtIndex:(NSUInteger)idx withObject:(Address *)value;
- (void)replaceCcAtIndexes:(NSIndexSet *)indexes withCc:(NSArray *)values;
- (void)addCcObject:(Address *)value;
- (void)removeCcObject:(Address *)value;
- (void)addCc:(NSOrderedSet *)values;
- (void)removeCc:(NSOrderedSet *)values;

/* BCC */

- (void)insertObject:(Address *)value inBccAtIndex:(NSUInteger)idx;
- (void)removeObjectFromBccAtIndex:(NSUInteger)idx;
- (void)insertBcc:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeBccAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInBccAtIndex:(NSUInteger)idx withObject:(Address *)value;
- (void)replaceBccAtIndexes:(NSIndexSet *)indexes withBcc:(NSArray *)values;
- (void)addBccObject:(Address *)value;
- (void)removeBccObject:(Address *)value;
- (void)addBcc:(NSOrderedSet *)values;
- (void)removeBcc:(NSOrderedSet *)values;

/* Reply to */

- (void)insertObject:(Address *)value inReplyToAtIndex:(NSUInteger)idx;
- (void)removeObjectFromReplyToAtIndex:(NSUInteger)idx;
- (void)insertReplyTo:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeReplyToAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInReplyToAtIndex:(NSUInteger)idx withObject:(Address *)value;
- (void)replaceReplyToAtIndexes:(NSIndexSet *)indexes withReplyTo:(NSArray *)values;
- (void)addReplyToObject:(Address *)value;
- (void)removeReplyToObject:(Address *)value;
- (void)addReplyTo:(NSOrderedSet *)values;
- (void)removeReplyTo:(NSOrderedSet *)values;

/* Attachments */

- (void)insertObject:(Attachment *)value inAttachmentsAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAttachmentsAtIndex:(NSUInteger)idx;
- (void)insertAttachments:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAttachmentsAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAttachmentsAtIndex:(NSUInteger)idx withObject:(Attachment *)value;
- (void)replaceAttachmentsAtIndexes:(NSIndexSet *)indexes withAttachments:(NSArray *)values;
- (void)addAttachmentsObject:(Attachment *)value;
- (void)removeAttachmentsObject:(Attachment *)value;
- (void)addAttachments:(NSOrderedSet *)values;
- (void)removeAttachments:(NSOrderedSet *)values;

@end
