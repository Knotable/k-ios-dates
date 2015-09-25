//
//  Attachment.h
//  Mailer
//
//  Created by Martin Ceperley on 10/23/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message;

@interface Attachment : NSManagedObject

@property (nonatomic, retain) NSString * mimeType;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSString * contentID;
@property (nonatomic, retain) NSString * filename;
@property (nonatomic) BOOL isImage;
@property (nonatomic) int32_t size;
@property (nonatomic, retain) NSString * path;
@property (nonatomic) BOOL haveFile;
@property (nonatomic, retain) Message *message;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) NSData *data;
@property (nonatomic, retain) NSDate *dateSaved;

@property (nonatomic, retain) NSArray *features;

@end
