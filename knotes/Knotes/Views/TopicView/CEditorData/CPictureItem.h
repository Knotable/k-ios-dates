//
// Created by Martin Ceperley on 4/4/14.
//

#import <Foundation/Foundation.h>
#import "CItem.h"


@interface CPictureItem : CItem

@property (nonatomic, copy) NSString *fileId;
@property (nonatomic, copy) NSString *imageURL;

- (id)initWithMessage:(MessageEntity *)message fileId:(NSString *)fileId;
- (id)initWithMessage:(MessageEntity *)message imageURL:(NSString *)imageURL;

@end
