//
// Created by Martin Ceperley on 4/4/14.
//

#import "CPictureItem.h"
#import "NSString+Knotes.h"

@implementation CPictureItem {

}

- (id)initWithMessage:(MessageEntity *)message
{
    self = [super init];
    if (self) {
        [self setCommonValueByMessage:message];
        NSArray *available = [message availableFileIDs];
        if(available.count > 0){
            self.fileId = [available.firstObject noPrefix:kKnoteIdPrefix];
        }
    }
    return self;
}

- (id)initWithMessage:(MessageEntity *)message fileId:(NSString *)fileId
{
    self = [super init];
    if (self) {
        [self setCommonValueByMessage:message];
        self.fileId = [fileId noPrefix:kKnoteIdPrefix];
    }
    return self;
}


- (id)initWithMessage:(MessageEntity *)message imageURL:(NSString *)imageURL
{
    self = [super init];
    if (self) {
        [self setCommonValueByMessage:message];
        self.imageURL = imageURL;
    }
    return self;
}


@end
