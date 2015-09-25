//
//  S3Manager.m
//  Knotable
//
//  Created by backup on 14-2-10.
//
//

#import "S3Manager.h"
#import "DataManager.h"

#import "Constant.h"
#import "AppDelegate.h"
#import "ServerConfig.h"

#import "MCAWSS3Client.h"
#import "UIImage+Knotes.h"
#import "ImageCollectionViewCell.h"

#import "AccountEntity.h"

#import "ASIS3ObjectRequest.h"
#import "ASIS3BucketRequest.h"
#import <OMPromises/OMPromises.h>

@implementation S3Manager

SYNTHESIZE_SINGLETON_FOR_CLASS(S3Manager);

- (FileInfo *)findFileInfoById:(NSString *)image_id
{
    if (!self.uploadingArray || [self.uploadingArray count]==0)
    {
        return nil;
    }
    
    for (FileInfo *info in self.uploadingArray)
    {
        if ([info.imageId isEqualToString:image_id])
        {
            return info;
        }
    }
    
    return nil;
}

- (void)recordToMongo:(FileInfo *)info withCompleteBlock:(MongoCompletion)cblock
{
    if ( [DataManager sharedInstance].currentAccount.account_id)
    {
         [[AppDelegate sharedDelegate] sendRequestAddFile:info
                             withAccountId:[DataManager sharedInstance].currentAccount.account_id
                               withUseData:nil
                         withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
        {
            if (cblock)
            {
                cblock(success,error,userData);
            }
        }];
        
    }
    else
    {
        NSLog(@"####ERROR! in sendRequestAddFile please check longin user id");
    }

}

- (void)removeFile:(FileInfo *)info withCompleteBlock:(MongoCompletion)cblock
{
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    MCAWSS3Client* client = [[MCAWSS3Client alloc] init];
    
    client.accessKey = app.server.s3_access_key;
    client.secretKey = app.server.s3_secret_key;
    client.bucket = app.server.s3_bucket;
    
    NSString *key = [NSString stringWithFormat:S3_FILENAME_FORMAT, [NSString stringWithFormat:@"%@_%@",info.imageId,info.imageName]];

    ASIS3ObjectRequest *request = [ASIS3ObjectRequest DELETERequestWithBucket:app.server.s3_bucket
                                                                          key:key];
    [request setSecretAccessKey:app.server.s3_secret_key];
    [request setAccessKey:app.server.s3_access_key];
    [request startSynchronous];
    
    if ([request error])
    {
        NSLog(@"%@",[[request error] localizedDescription]);
    }
    else
    {
        if (cblock)cblock(NetworkSucc,nil,nil);
    }
}

- (void)uploadFile:(FileInfo *)info withCompleteBlock:(MongoCompletion)cblock
{
    NSLog(@"uploadFile: %@", info);
    
    AppDelegate *app = [AppDelegate sharedDelegate];
    
    MCAWSS3Client* client = [[MCAWSS3Client alloc] init];
    client.accessKey = app.server.s3_access_key;
    client.secretKey = app.server.s3_secret_key;
    client.bucket = app.server.s3_bucket;

    NSString *mime = info.isPNG ? @"image/png" : @"image/jpg";
    
    NSString *awsFilename = [NSString stringWithFormat:S3_FILENAME_FORMAT, [NSString stringWithFormat:@"%@_%@",info.imageId,info.imageName]];

    //NSData *imageData = [info getFullResolutionData];
    
    [[info getFullResolutionData] fulfilled:^(id result) {
        NSData *imageData = result;
        
        NSLog(@"UPLOADING to S3 image data length: %lu filename: %@", (unsigned long)imageData.length, awsFilename);
        
        [client putObjectWithData:imageData
                              key:awsFilename
                         mimeType:mime
                       permission:MCAWSS3ObjectPermissionPublicRead
     //match with embedly.m
#if !AFNetworking_2_And_Above_Installed
         progress:^ (NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite){
#else
        progress:^(NSUInteger bytesWritten, NSInteger totalBytesWritten, NSInteger totalBytesExpectedToWrite) {
#endif
         
                             float progress = ((float)totalBytesWritten)/((float)totalBytesExpectedToWrite);
//                             progress = 0.2 + progress*0.7;
                             info.curUploadProgress = progress;
                             
                             if (info.cell)
                             {
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [info.cell updateProgress:progress];
                                 });
                             }
                         } success:^(AFHTTPRequestOperation *operation, id responseObject) {
                             NSLog(@"S3 Upload Success response: %@ class: %@ URL: %@", responseObject, [responseObject class], info.file.full_url);
                             
                             if (info.file.file_id && info.file.name && info.file.full_url)
                             {
                                 NSArray *param = @[info.file.file_id,info.file.name,info.file.full_url];
                                 
                                 AppDelegate *app = [AppDelegate sharedDelegate];
                                 
                                 [app.meteor callMethodName:@"processThumbnail"
                                                 parameters:param
                                           responseCallback:^(NSDictionary *response, NSError *error)
                                 {
                                 
                                     if (error)
                                     {
                                         NSLog(@"upload thumbnail file error: %@ response: %@", error, response);
                                     }
                                     else
                                     {
                                         if (info.cell)
                                         {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 [info.cell updateProgress:1.0];
                                             });
                                         }
                                         
                                         info.file.thumbnail_url = @"";
                                         if(response[@"result"] != [NSNull null]){
                                             info.file.thumbnail_url = response[@"result"];
                                         }
                                         
                                         [[MagicalRecordStack defaultStack] saveWithBlock:^(NSManagedObjectContext *localContext) {
                                             info.file.sendFlag = @(SendS3);
                                         } completion:^(BOOL success, NSError *error) {
                                             //info.file = [FileEntity MR_findFirstByAttribute:@"file_id" withValue:info.imageId];
                                             if (cblock)cblock(NetworkSucc,error,nil);
                                         }];
                                     }
                                 }];
                             }
                             else
                             {
                                 if (cblock)cblock(NetworkErr,nil,nil);
                             }
                         }
                          failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             
                              DLog(@"Upload Failed... %@,%@", error,info);
                              info.curUploadProgress = 0.2;

                             if (cblock)
                             {
                                 cblock(NetworkFailure,error,nil);
                             }
                              
                         }];

        
        
    }];
}


- (void)sendFile:(FileInfo *)info withCompleteBlock:(MongoCompletion)cblock
{
    if ( !self.uploadingArray )
    {
        self.uploadingArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    for (int i = 0; i<[self.uploadingArray count]; i++)
    {
        FileInfo *fInfo = [self.uploadingArray objectAtIndex:i];
        
        if ([fInfo.imageId isEqualToString:info.imageId])
        {
            if (fInfo.upLoading)
            {
                return;
            }
        }
    }
    
    [self.uploadingArray addObject:info];
    info.upLoading = YES;
    

    switch ([info.file.sendFlag charValue])
    {
        case SendBegin:
        {
            if (info.cell)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [info.cell updateProgress:0];
                });
            }
            
            [self recordToMongo:info withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
            {
                if (success == NetworkSucc)
                {
                    info.curUploadProgress = 0.2f;
                    if ([info.file isFault])
                    {
                        [info.file MR_refresh];
                    }
                    
                    if (![info.file isFault]){
                        info.file.sendFlag = @(SendMongoDB);
                        //[info setCommonValueByFile:info.file];
                        [self uploadFile:info withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
                         {
                             info.upLoading = NO;
                             
                             if (success == NetworkSucc)
                             {
                                 
                                 if (self.uploadingArray && [self.uploadingArray count]>0)
                                 {
                                     if ([self.uploadingArray containsObject:info])
                                     {
                                         [self.uploadingArray removeObject:info];
                                     }
                                 }
                                 
                                 if (cblock)
                                 {
                                     cblock(success,error,userData);
                                 }
                             }
                             else
                             {
                                 if (cblock)
                                 {
                                     cblock(success,error,userData);
                                 }
                             }
                         }];
                    }
                }
                else
                {
                    if (cblock)cblock(success,error,userData);
                }
            }];
        }
            break;
        case SendMongoDB:
        {
            if (info.cell)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [info.cell updateProgress:0];
                });
            }
            
            [self uploadFile:info withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
            {
                info.upLoading = NO;
                if (success == NetworkSucc)
                {                   
                    if (self.uploadingArray && [self.uploadingArray count]>0)
                    {
                        if ([self.uploadingArray containsObject:info])
                        {
                            [self.uploadingArray removeObject:info];
                        }
                    }
                    
                    if (cblock)
                    {
                        cblock(success,error,userData);
                    }
                }
                else
                {
                    if (cblock)
                    {
                        cblock(success,error,userData);
                    }
                }
            }];
        }
            break;
        case SendS3:
        {
            if (info.cell)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [info.cell updateProgress:0];
                });
            }
            
            if (cblock)
            {
                cblock(NetworkSucc,nil,nil);
            }

        }
            break;
        case SendSuc:
        {
            
        }
            break;
        default:
            break;
    }
}

- (void)downLoadFile:(FileInfo *)info withMessage:(MessageEntity *)message withCompleteBlock:(MongoCompletion)cblock
{
    if (!self.downloadingArray)
    {
        self.downloadingArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    for (FileInfo *fInfo in self.downloadingArray)
    {
        if ([fInfo.imageId isEqualToString:info.imageId] && fInfo.downLoading)
        {
            return;
        }
    }

    if(info.cell)
    {
        [info.cell showWaitingView];
    }

    info.downLoading = YES;
    
    [self.downloadingArray addObject:info];
    
    [[AppDelegate sharedDelegate] sendRequestFile:info.imageId withMessage:message
                                withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
    {
        [self.downloadingArray removeObject:info];
        
        if (cblock) {
            cblock(success,nil,userData);
        }
    }];
}
     
@end
