//
//  FileEntity.m
//  Knotable
//
//  Created by Martin Ceperley on 12/10/13.
//
//

#import "FileEntity.h"
#import "TopicsEntity.h"
#import "MessageEntity.h"
#import "FileManager.h"
#import "ObjCMongoDB.h"

@implementation FileEntity

@dynamic file_id;
@dynamic name;
@dynamic isImage;
@dynamic isPNG;
@dynamic isPDF;
@dynamic isDownloaded;
@dynamic sendFlag;
@dynamic ext;
@dynamic size;
@dynamic knote;
@dynamic full_url;
@dynamic thumbnail_url;
@dynamic belongId;
@dynamic downloading;

- (NSString *) filePath
{
    return [FileManager threadFilePath:self];
}

- (UIImage *) loadImage
{
    NSLog(@"FileEntity loadImage from path: %@", [self filePath]);

    return [UIImage imageWithContentsOfFile:[self filePath]];
}

- (UIImage *)loadThreadImage
{
    return [UIImage imageWithContentsOfFile:[self filePath]];
}
- (BOOL)saveTreadImage:(NSData *)data
{
    return [FileManager saveThreadFile:data withFile:self];
}

- (BOOL) fileExists
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[self filePath]];
}


+ (void)ensureFileID:(NSString *)fileId message:(MessageEntity *)message
{
    NSLog(@"ensureFileID message %@ file %@", message.message_id, fileId);

    FileEntity *file = [FileEntity MR_findFirstByAttribute:@"file_id" withValue:fileId];
    
    if(!file || !file.isDownloaded.boolValue || !file.full_url)
    {
        [[AppDelegate sharedDelegate] sendRequestFile:fileId withMessage:message
                                    withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
        {
#if 0
            FileEntity *file = [FileEntity MR_findFirstByAttribute:@"file_id" withValue:fileId];
            
            if(file)
            {
                if (message.message_id!=nil)
                {
                    
                    file.knote = [message inContext:[[MagicalRecordStack defaultStack] context]];
                    [AppDelegate saveContext];
                }
            }
#else
            FileEntity *file = userData;
#endif

            if(file && file.full_url)
            {
                if(![file fileExists])
                {
                    NSLog(@"ensureFileID %@ downloading from S3", fileId);

                    [file downloadData];
                }


            }

        }];
    }
}

- (void)downloadData
{
    if (self.full_url && self.full_url.length>0)
    {
        NSString *escapedURL = Nil;
        
        if ([self isValidURL:self.full_url] == NO)
        {
            NSString*   tempURL = Nil;
            
            if ([self.full_url hasPrefix:@"http://"] || [self.full_url hasPrefix:@"https://"])
            {
                tempURL = self.full_url;
                // do something
            }
            else
            {
                if ([self.full_url hasPrefix:@"//"])
                {
                    tempURL = [NSString stringWithFormat:@"http:%@", self.full_url];
                }
                else if ([self.full_url hasPrefix:@"://"])
                {
                    tempURL = [NSString stringWithFormat:@"http%@", self.full_url];
                }
            }
            
            escapedURL = [tempURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
//            escapedURL = [self.full_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            escapedURL = self.full_url;
        }
        
        NSURLRequest *dataRequest = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:escapedURL]];
        
        [NSURLConnection sendAsynchronousRequest:dataRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   
                                   if (![self isFault])
                                   {
                                       NSLog(@"Got image data for file_id %@ length %d", self.file_id, (int)data.length);
                                       
                                       if (data)
                                       {
                                           [self saveTreadImage:data];
                                           
                                           [[NSNotificationCenter defaultCenter] postNotificationName:FILE_DOWNLOADED_NOTIFICATION
                                                                                               object:self.file_id
                                                                                             userInfo:nil];
                                       }
                                   }
                                   
                                   
                               }];
    }
}

- (void)asynDownloadImage:(FileDataCompletion) handle
{
    if (self.full_url && self.full_url.length>0)
    {
        NSString *escapedURL = Nil;
        
        if ([self isValidURL:self.full_url] == NO)
        {
            NSString*   tempURL = Nil;
            
            if ([self.full_url hasPrefix:@"http://"] || [self.full_url hasPrefix:@"https://"])
            {
                tempURL = self.full_url;
                // do something
            }
            else
            {
                if ([self.full_url hasPrefix:@"//"])
                {
                    tempURL = [NSString stringWithFormat:@"http:%@", self.full_url];
                }
                else if ([self.full_url hasPrefix:@"://"])
                {
                    tempURL = [NSString stringWithFormat:@"http%@", self.full_url];
                }
            }
            
            escapedURL = [tempURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        else
        {
            escapedURL = [self.full_url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        
        NSURLRequest *dataRequest = [NSURLRequest requestWithURL:[[NSURL alloc] initWithString:escapedURL]];
        [NSURLConnection sendAsynchronousRequest:dataRequest
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                                   if (data)
                                   {
                                       if (![self isFault]) {
                                           [self saveTreadImage:data];
                                       }
                                       handle(data);
                                   }
                               }];
    }


}

// Lin - Added to check URL Validation

- (BOOL) isValidURL:(NSString *)checkURL
{
    NSUInteger length = [checkURL length];
    
    // Empty strings should return NO
    
    if (length > 0)
    {
        NSError *error = nil;
        
        NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        
        if (dataDetector && !error)
        {
            NSRange range = NSMakeRange(0, length);
            NSRange notFoundRange = (NSRange){NSNotFound, 0};
            NSRange linkRange = [dataDetector rangeOfFirstMatchInString:checkURL options:0 range:range];
            
            if (!NSEqualRanges(notFoundRange, linkRange) && NSEqualRanges(range, linkRange))
            {
                return YES;
            }
        }
        else
        {
            NSLog(@"Could not create link data detector: %@ %@", [error localizedDescription], [error userInfo]);
        }
    }
    
    return NO;
}

// Lin - Ended

@end
