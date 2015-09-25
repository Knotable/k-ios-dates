//
//  FileManager.m
//  Knotable
//
//  Created by Martin Ceperley on 12/10/13.
//
//

#import "FileManager.h"

#import "MessageEntity.h"
#import "FileEntity.h"

#import "ObjCMongoDB.h"
#import "CUtil.h"
#import "FileInfo.h"
#import "ServerConfig.h"

#import "NSString+Knotes.h"
#import <OMPromises/OMPromises.h>

@implementation FileManager

+ (NSString *) documentsDirectory
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+ (NSString *) filesDirectory
{
    return [self.documentsDirectory stringByAppendingPathComponent:@"files"];
}

+ (NSString *) filePath:(FileEntity *)file
{
    return [self filePath:file.file_id extension:file.ext];
}

+ (NSString *) filePath:(NSString *)fileID extension:(NSString *)extension
{
    NSString *filename = [NSString stringWithFormat:@"%@.%@", [fileID md5], [extension lowercaseString]];
    return [self.filesDirectory stringByAppendingPathComponent:filename];
}

+ (BOOL) saveData:(NSData *)data fileID:(NSString *)fileID extension:(NSString *)extension
{
    NSString *filepath = [self filePath:fileID extension:extension];
    NSString* dirPath = [filepath stringByDeletingLastPathComponent];
    
    NSError * error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error != nil) {
        NSLog(@"error creating directory: %@", error);
        return NO;
    }
    error = nil;
    if (![data writeToFile:filepath options:NSDataWritingAtomic error:&error]) {
        NSLog(@"Create of %@ FAILED: %@", filepath, error);
        return NO;
    } else {
        [[NSURL fileURLWithPath:filepath] setResourceValue:@(YES) forKey:NSURLIsExcludedFromBackupKey error:NULL];
    }
    
    return YES;
}

+ (NSString *) threadFilePath:(FileEntity *)file
{
    NSString *name = [NSString stringWithFormat:@"%@_%@",file.file_id,file.name];
    NSString *path  = [kImageCachePath stringByAppendingPathComponent:name];
    return path;
}

+ (BOOL) saveThreadFile:(NSData *)data withFile:(FileEntity *)file
{
    NSString * filepath = [self threadFilePath:file];
    
    NSString* dirPath = [filepath stringByDeletingLastPathComponent];

    NSLog(@"saveThreadFile filepath: %@", filepath);
    
    if ( [filepath.lowercaseString rangeOfString:@".avi"].location != NSNotFound
        || [filepath.lowercaseString rangeOfString:@".css"].location != NSNotFound
        || [filepath.lowercaseString rangeOfString:@".xml"].location != NSNotFound )
    {
        NSLog(@"Let me check the video file");
    }
    
    NSError * error = nil;
    
    [[NSFileManager defaultManager] createDirectoryAtPath:dirPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:&error];
    
    if (error != nil)
    {
        NSLog(@"error creating directory: %@", error);
        
        return NO;
    }
    
    error = nil;
    
    if (![data writeToFile:filepath
                   options:NSDataWritingAtomic
                     error:&error])
    {
        NSLog(@"Create of %@ FAILED: %@", filepath, error);
        
        return NO;
    }
    else
    {
        [[NSURL fileURLWithPath:filepath] setResourceValue:@(YES)
                                                    forKey:NSURLIsExcludedFromBackupKey
                                                     error:NULL];
    }
    
    return YES;
}

+ (void)beginUploadingFile:(FileInfo *)fInfo
{
    AppDelegate* app = [AppDelegate sharedDelegate];
    
    NSString *client_bucket = [app.server s3_bucket];

    if (!fInfo.imageId)
    {
        fInfo.imageId = [[AppDelegate sharedDelegate] mongo_id_generator];
    }
    
    NSString *extension = [fInfo.imageName pathExtension];
    
    if (extension == nil || extension.length == 0)
    {
        extension = @"jpg";
    }
    extension = [extension lowercaseString];
    
    BOOL isImage = NO;
    BOOL isPNG = NO;
    
    if ([@[@"jpg",@"jpeg"] containsObject:extension]) {
        isImage = YES;
    } else if([extension isEqualToString:@"png"]){
        isImage = YES;
        isPNG = YES;
    }

    if (!fInfo.file) {
        NSLog(@"Create file entity for image name %@", fInfo.imageName);
        FileEntity *file = [FileEntity MR_createEntity];
        fInfo.file = file;
        file.file_id = fInfo.imageId;
        file.name = fInfo.imageName;
        
        NSString *awsFilename = [NSString stringWithFormat:S3_FILENAME_FORMAT, [NSString stringWithFormat:@"%@_%@",file.file_id,file.name]];
        
        file.full_url = [NSString stringWithFormat:@"https://s3.amazonaws.com/%@/%@",client_bucket, awsFilename];
        file.full_url = [file.full_url stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
        file.isDownloaded = @(YES);
        file.ext = extension;
        file.isImage = @(isImage);
        file.isPNG = @(isPNG);
        file.sendFlag = @(SendBegin);
        file.belongId = @"";
        file.downloading = NO;
        
        [[fInfo getFullResolutionData] fulfilled:^(id result) {
            NSData *imageData = result;
            NSLog(@"Saving to disk image size: %@ name %@", file.size, fInfo.imageName);
            
            [file saveTreadImage:imageData];
            
            NSLog(@"Done saving to disk image name %@", fInfo.imageName);
            
            [AppDelegate saveContext];
            
            NSLog(@"Uploading image name %@", fInfo.imageName);
            
            [fInfo recordSelfToServer];
        }];
    }
    
    /* need to
    0) write to core data
    1) write to disk
    2) write to S3
    3) write to Mongo
     */
}
@end
