//
//  MFileManager.m
//  Mailer
//
//  Created by Martin Ceperley on 10/23/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MFileManager.h"
#import "Message.h"
#import "Folder.h"
#import "Attachment.h"

@implementation MFileManager

+ (NSString *) documentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *) snapshotsDirectory
{
    return [self.documentsDirectory stringByAppendingPathComponent:@"messageSnapshots"];
}

+ (NSString *) snapshotPath:(Message *)message
{
    NSString *filename = [NSString stringWithFormat:@"%@.png", [message.messageID md5]];
    return [self.snapshotsDirectory stringByAppendingPathComponent:filename];
}

+ (void) clearSnapshotsDir
{
    NSString* dir = self.snapshotsDirectory;
    NSError* error = nil;
    BOOL isDir = YES;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dir isDirectory:&isDir]) {
        //NSLog(@"snapshots dir doesnt exist");
        return;
    }
    BOOL ok = [[NSFileManager defaultManager] removeItemAtPath:dir error:&error];
    if (!ok || error != nil) {
        //NSLog(@"Error deleting snapshot dir: %@", error);
    } else {
        //NSLog(@"Sucess deleting snapshot dir");
    }
}


+ (BOOL) snapshotExists:(Message *)message
{
    NSString *snapshotsDirectory = self.snapshotsDirectory;
    BOOL isDirectory;
    BOOL snapshotsDirExists = [[NSFileManager defaultManager] fileExistsAtPath:snapshotsDirectory isDirectory:&isDirectory];
    if (!snapshotsDirExists) {
        //NSLog(@"creating snapshots dir: %@", snapshotsDirectory);
        BOOL madeDir = [[NSFileManager defaultManager] createDirectoryAtPath:snapshotsDirectory withIntermediateDirectories:NO attributes:nil error:NULL];
        if (!madeDir) {
            //NSLog(@"failed creating snapshots dir");
        }
    }
    return [[NSFileManager defaultManager] fileExistsAtPath:[self snapshotPath:message]];
}

+ (UIImage *) snapshotImageForMessage:(Message *)message
{
    if (![self snapshotExists:message]) {
        return nil;
    }
    NSData* data = [NSData dataWithContentsOfFile:[self snapshotPath:message]];
    return [UIImage imageWithData:data scale:[UIScreen mainScreen].scale];
}

+ (void) writeToFile:(NSString *)path data:(NSData *)data
{
    NSString* dirPath = [path stringByDeletingLastPathComponent];
    NSError * error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
        //NSLog(@"error creating directory: %@", error);
    }

    error = nil;
    if (![data writeToFile:path options:NSDataWritingAtomic error:&error]) {
        //NSLog(@"Create of %@ FAILED: %@", path, error);
    } else {
        [[NSURL fileURLWithPath:path] setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:NULL];
    }
}

+ (void) writeSnapshotImage:(Message *)message
{
    NSString *filePath = [self snapshotPath:message];
    NSData *imageData = UIImagePNGRepresentation(message.image);
    [self writeToFile:filePath data:imageData];
    //NSLog(@"SAVED ATTACHMENT to path: %@", filePath);
}

+ (NSString *) attachmentsDirectory
{
    
    return [self.documentsDirectory stringByAppendingPathComponent:@"attachments"];
}

+ (NSString *) directoryForMessage:(Message *)message
{
    
    return [self.attachmentsDirectory stringByAppendingPathComponent:[message.messageID md5]];
}

+ (NSString *) directoryForAttachment:(Attachment *)attachment
{
    NSString *contentID = attachment.contentID;
    if (contentID == nil || contentID.length == 0) {
        contentID = attachment.uniqueID;
    }
    return [[self directoryForMessage:attachment.message] stringByAppendingPathComponent:[contentID md5]];
}

+ (NSString *) pathForAttachment:(Attachment *)attachment
{
    
//    NSLog(@"[self directoryForAttachment:attachment] == %@",[self directoryForAttachment:attachment]);


    return [[self directoryForAttachment:attachment] stringByAppendingPathComponent:attachment.filename];
}

+ (void) writeAttachmentData:(Attachment *)attachment
{
    if (attachment == nil || attachment.data == nil) {
        return;
    }
    
    NSString *path = [self pathForAttachment:attachment];
//   NSLog(@"writeAttachmentData path %@", path);

    [self writeToFile:path data:attachment.data];
    attachment.path = path;
    attachment.haveFile = YES;
    attachment.dateSaved = [NSDate date];
}

+ (NSData *) dataForAttachment:(Attachment *)attachment
{
//     NSLog(@"pathForAttachment == %@",[self pathForAttachment:attachment]);
    
//    NSLog(@"attachment.path = %@",attachment.path);
    
//    NSLog(@"dataForAttachment = %@",[NSData dataWithContentsOfFile:@"/Users/mac7/Library/Application Support/iPhone Simulator/7.0-64/Applications/31283A56-F833-45DC-9C46-AF639C9C7819/Documents/attachments/4d578cda48e99a2363f73bbc7e8a2c72/cfcd208495d565ef66e7dff9f98764da/Video.png"]);
    
    
    return [NSData dataWithContentsOfFile:attachment.path];
}

+ (UIImage *) imageForAttachment:(Attachment *)attachment
{
//    NSLog(@"imageForAttachment = %@",[UIImage imageWithData:[self dataForAttachment:attachment] scale:[UIScreen mainScreen].scale]);
    
    
    return [UIImage imageWithData:[self dataForAttachment:attachment] scale:[UIScreen mainScreen].scale];
}


@end
