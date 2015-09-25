//
//  FileManager.h
//  Knotable
//
//  Created by Martin Ceperley on 12/10/13.
//
//

#import <Foundation/Foundation.h>

@class MessageEntity, FileEntity, FileInfo;

@interface FileManager : NSObject

+ (NSString *) filePath:(FileEntity *)file;
+ (BOOL) saveData:(NSData *)data fileID:(NSString *)fileID extension:(NSString *)extension;
///new for thread image
+ (NSString *) threadFilePath:(FileEntity *)file;
+ (BOOL) saveThreadFile:(NSData *)data withFile:(FileEntity *)file;
+ (void)beginUploadingFile:(FileInfo *)fInfo;


@end
