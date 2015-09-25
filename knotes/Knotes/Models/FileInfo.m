//
//  FileInfo.m
//  Knotable
//
//  Created by backup on 14-1-7.
//
//

#import "FileInfo.h"

#import "S3Manager.h"
#import "ObjCMongoDB.h"
#import "ProgressHUD.h"
#import "CItem.h"
#import "OMPromises.h"
#import "UIImage+Knotes.h"
#import "CEditBaseItemView.h"
#import "ImageCollectionViewCell.h"

@interface FileInfo()
@end
@implementation FileInfo
- (id)initWithFile:(FileEntity *)file
{
    self = [super init];
    if (self) {
        NSLog(@"FileInfo initWithFile: %@", file);
        [self setCommonValueByFile:file];
    }
    return self;
}
- (void)setCommonValueByFile:(FileEntity *)file
{
    DLog(@"FileInfo setCommonValueByFile: %@", file);

    self.imageName = file.name;
    self.imageId = file.file_id;
    self.file = file;
    self.image = [file loadThreadImage];
    
    [AppDelegate sharedDelegate].SharedFile = file;
    
    DLog(@"%@",file.sendFlag);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RefreshingEndsForProfile" object:nil];

}

- (id)init
{
    self = [super init];
    if (self) {
        self.downLoading = NO;
        self.upLoading = NO;
        self.upLoadRetryCount = 3;
        self.downLoadRetryCount = 3;
    }
    return self;
}

+ (FileInfo *)fileInfoForAsset:(ALAsset *)asset
{
    FileInfo *fInfo = [[FileInfo alloc] init];
    ALAssetRepresentation *representation = [asset defaultRepresentation];
    fInfo.assetURL = [asset valueForProperty:ALAssetPropertyAssetURL];
    fInfo.imageSize = representation.size;
    fInfo.image = [UIImage imageWithCGImage:[representation fullScreenImage] scale:representation.scale orientation:(UIImageOrientation)0];
    fInfo.imageName = [[representation filename] lowercaseString];
    fInfo.isPNG = [[[fInfo.imageName pathExtension] lowercaseString] isEqualToString:@"png"];
    fInfo.imageOrientation = (UIImageOrientation)representation.orientation;
    return fInfo;
};

- (NSMutableDictionary *)dictionaryValue
{
    return nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"imageName: %@ imageId: %@ has file: %d has data: %d data size: %d has image: %d isPNG: %d downLoading: %d upLoading: %d",
        _imageName, _imageId, _file != nil, _imageData != nil, (int)(_imageData ? _imageData.length : 0), _image != nil, _isPNG, _downLoading, _upLoading];
}

- (void)recordSelfToServer
{
    DLog(@"%@", self.file.sendFlag);
    
    [self.parentCell showProcess];
    
    if (self.cell){
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSLog(@"Progress : %f", self.curUploadProgress);
            
            if (self.curUploadProgress > 0)
            {
                [self.cell updateProgress:self.curUploadProgress];
            }
            else
            {
                [self.cell updateProgress:0];
            }
        });
    }

    [[S3Manager sharedInstance] sendFile:self withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData) {
        switch (success) {
            case NetworkSucc:
            {
                self.curUploadProgress = -1.0f;

                if (self.cell){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.cell updateProgress:-1];
                    });
                }
                self.upLoading = NO;
                self.file.sendFlag = @(SendSuc);
                [self setCommonValueByFile:self.file];
                [self.parentItem checkToUpdataFiles];
            }
                break;
            case NetworkErr:
            case NetworkTimeOut:
            case NetworkFailure:
            {
                if (self.upLoadRetryCount>0)
                {
                    self.upLoadRetryCount--;
                    
                    [self recordSelfToServer];
                }
                else
                {
                    self.upLoadRetryCount = 3;
                    [self.cell updateProgress:-1];
                    [self.cell setShowImage:HUD_IMAGE_ERROR withContentMode:UIViewContentModeCenter];
                }
            }
                break;
            default:
                break;
        }
        [self.parentCell stopProcess];
    }];
}

- (void)fetchSelfFromServer:(MessageEntity *)message
{
    DLog(@"fetchSelfFromServer collectionView cellForItemAtIndexPath requesting file:%@",self);
    AppDelegate *app = [AppDelegate sharedDelegate];
    if (!app.meteor.connected) {
        return;
    }
    [[S3Manager sharedInstance] downLoadFile:self withMessage:message withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData) {
        switch (success) {
            case NetworkSucc:
            {
#if 0
                FileEntity *file = (FileEntity *)[FileEntity MR_findFirstByAttribute:@"file_id" withValue:userData];
#else
                FileEntity* file = userData;
#endif
                if ([file isFault]) {
                    [file MR_refresh];
                }
                self.downLoading = NO;
                self.file = file;
                [self.cell setShowEntity:file];
                [self.cell removeWaitingView];
                //[self.parentCell stopProcess];
            }
                break;
            case NetworkTimeOut:
            case NetworkErr:
            case NetworkFailure:
            {
                if (self.downLoadRetryCount>0) {
                    self.downLoadRetryCount--;
                    [self fetchSelfFromServer:message];
                } else {
                    self.cell.downloadSucces = NO;
                    self.downLoadRetryCount = 3;
                    [self.cell setShowImage:HUD_IMAGE_ERROR withContentMode:UIViewContentModeCenter];
                }
                //[self.parentCell stopProcess];
            }
            default:
                break;
        }
        [self.cell removeWaitingView];
    }];

}

- (void)removeSelfFromServer
{
    [[S3Manager sharedInstance] removeFile:self withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData) {
        
    }];
}

- (OMPromise *)getFullResolutionImage
{
    if (self.assetURL) {
        OMDeferred *deferred = [OMDeferred deferred];
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library assetForURL:self.assetURL resultBlock:^(ALAsset *asset) {
            ALAssetRepresentation *rep = [asset defaultRepresentation];
            CGImageRef cgimage = [rep CGImageWithOptions:nil];
            UIImage *image = [UIImage imageWithCGImage:cgimage scale:rep.scale orientation:(UIImageOrientation)rep.orientation];
            if (rep.orientation != ALAssetOrientationUp) {
                NSLog(@"fixing orientation from %d", rep.orientation);
                image = [image fixOrientation];
            }
            NSLog(@"have asset image %@ size %@", image, NSStringFromCGSize(image.size));
            [deferred fulfil:image];
        } failureBlock:^(NSError *error) {
            [deferred fail:error];
        }];
        return deferred.promise;
    } else {
        if (self.image.imageOrientation == UIImageOrientationUp) {
            return [OMPromise promiseWithResult:self.image];
        } else {
            OMDeferred *deferred = [OMDeferred deferred];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *image = [self.image fixOrientation];
                [deferred fulfil:image];
            });
            return deferred.promise;
        }
        
    }
    
}

- (OMPromise *)getFullResolutionData
{
    OMPromise *chain = [[self getFullResolutionImage] then:^id(id result) {
        UIImage *image = result;
        NSData *imageData;
        
        if (self.isPNG)
        {
            imageData = UIImagePNGRepresentation(image);
        }
        else
        {
            imageData = UIImageJPEGRepresentation(image, 0.9);
        }
        
        self.imageSize = imageData.length;
        self.file.size = @(self.imageSize);
        
        return imageData;
        
    }];
    return chain;
}


@end
