//
//  S3Manager.h
//  Knotable
//
//  Created by backup on 14-2-10.
//
//

#import <Foundation/Foundation.h>
#import "FileInfo.h"
#import "MessageEntity.h"
#import "ObjCMongoDB.h"
#import "Singleton.h"

@interface S3Manager : NSObject
@property (atomic,strong) NSMutableArray *uploadingArray;
@property (atomic,strong) NSMutableArray *downloadingArray;

+(S3Manager *)sharedInstance;
- (FileInfo *)findFileInfoById:(NSString *)image_id;
- (void)sendFile:(FileInfo *)info withCompleteBlock:(MongoCompletion)cblock;
- (void)downLoadFile:(FileInfo *)info withMessage:(MessageEntity *)message withCompleteBlock:(MongoCompletion)cblock;
- (void)removeFile:(FileInfo *)info withCompleteBlock:(MongoCompletion)cblock;
@end

