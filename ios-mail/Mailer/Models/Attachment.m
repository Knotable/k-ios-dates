//
//  Attachment.m
//  Mailer
//
//  Created by Martin Ceperley on 10/23/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "Attachment.h"
#import "Message.h"
#import "MFileManager.h"

@implementation Attachment

@dynamic mimeType;
@dynamic uniqueID;
@dynamic contentID;
@dynamic filename;
@dynamic isImage;
@dynamic size;
@dynamic path;
@dynamic haveFile;
@dynamic message;
@dynamic dateSaved;

@synthesize data;
@synthesize image;
@synthesize features;

-(void) setData:(NSData *)dataToSet
{
    //NSLog(@"setData");
    data = dataToSet;
    [MFileManager writeAttachmentData:self];
}

-(UIImage *) image
{
//    if (image == nil) {
        image = [MFileManager imageForAttachment:self];
//    }
    return image;
}

@end
