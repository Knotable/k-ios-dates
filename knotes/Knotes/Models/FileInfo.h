//
//  FileInfo.h
//  Knotable
//
//  Created by backup on 14-1-7.
//
//

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "FileEntity.h"
#import "KnotesCellProtocal.h"

#define kUploadFileToS3Server @"kUploadFileToS3Server"
@class CEditBaseItemView;
@class ImageCollectionViewCell;
@class CItem;
@class OMPromise;

@interface FileInfo : NSObject
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) NSData *imageData;
@property (nonatomic, assign) long long imageSize;
@property (nonatomic, assign) UIImageOrientation imageOrientation;
@property (nonatomic, copy) NSString *imageName;
@property (nonatomic, copy) NSString *imageId;
@property (nonatomic, strong) FileEntity *file;
@property (nonatomic, assign) BOOL isPNG;
@property (nonatomic, assign) BOOL isPDF;

@property (nonatomic, assign) BOOL downLoading;
@property (nonatomic, assign) BOOL upLoading;
@property (nonatomic, assign) BOOL upLoaded;
@property (nonatomic, assign) NSInteger upLoadRetryCount;
@property (nonatomic, assign) NSInteger downLoadRetryCount;

@property (nonatomic, strong) NSURL *assetURL;
@property (nonatomic, assign)  CGFloat curUploadProgress;

@property (nonatomic, weak) ImageCollectionViewCell *cell;
@property (nonatomic, weak) id<KnotableCellProtocal>parentCell;
@property (nonatomic, weak) CItem *parentItem;


+ (FileInfo *)fileInfoForAsset:(ALAsset *)asset;

- (id)initWithFile:(FileEntity *)file;

- (void)setCommonValueByFile:(FileEntity *)file;

- (NSMutableDictionary *)dictionaryValue;

- (void)recordSelfToServer;

- (void)fetchSelfFromServer:(MessageEntity *)message;

- (void)removeSelfFromServer;

- (OMPromise *)getFullResolutionImage;

- (OMPromise *)getFullResolutionData;

@end
