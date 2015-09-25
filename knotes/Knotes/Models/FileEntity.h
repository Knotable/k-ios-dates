//
//  FileEntity.h
//  Knotable
//
//  Created by Martin Ceperley on 12/10/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
typedef void (^FileDataCompletion)(NSData* fileData);

@class MessageEntity;
typedef enum {
    SendBegin,
    SendMongoDB,
    SendS3,
    SendSuc,
} SendStatus;
@interface FileEntity : NSManagedObject

@property (nonatomic, retain) NSString * file_id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * isImage;
@property (nonatomic, retain) NSNumber * isPNG;
@property (nonatomic, retain) NSNumber * isPDF;
@property (nonatomic, retain) NSNumber * isDownloaded;
@property (nonatomic, retain) NSNumber * sendFlag;
@property (nonatomic, retain) NSString * ext;
@property (nonatomic, retain) NSNumber * size;
@property (nonatomic, retain) NSString * full_url;
@property (nonatomic, retain) NSString * thumbnail_url;
@property (nonatomic, retain) NSString *belongId;
@property (nonatomic, retain) MessageEntity *knote;
@property (nonatomic, assign) BOOL downloading;

- (NSString *)filePath;

- (UIImage *) loadImage;
- (UIImage *) loadThreadImage;

- (BOOL) saveTreadImage:(NSData *)data;
+ (void) ensureFileID:(NSString *)fileId message:(MessageEntity *)message;
- (void) asynDownloadImage:(FileDataCompletion) handle;

// Lin - Added to check URL Validation

- (BOOL) isValidURL:(NSString *)checkURL;

// Lin - Ended

@end
