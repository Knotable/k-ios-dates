//
//  MFileManager.h
//  Mailer
//
//  Created by Martin Ceperley on 10/23/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <Foundation/Foundation.h>
@class Message, Attachment;
@interface MFileManager : NSObject

+ (UIImage *) snapshotImageForMessage:(Message *)message;
+ (void) clearSnapshotsDir;
+ (void) writeSnapshotImage:(Message *)message;


+ (void) writeAttachmentData:(Attachment *)attachment;
+ (NSData *) dataForAttachment:(Attachment *)attachment;
+ (UIImage *) imageForAttachment:(Attachment *)attachment;
+ (NSString *) directoryForMessage:(Message *)message;

@end
