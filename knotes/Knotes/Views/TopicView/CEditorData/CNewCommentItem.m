//
//  CNewCommentItem.m
//  Knotable
//
//  Created by Agustin Guerra on 8/12/14.
//
//

#import "CNewCommentItem.h"
#import "ThreadItemManager.h"
#import "OMPromise.h"

@implementation CNewCommentItem

- (id)initWithNoteId:(NSString *)itemId andPadId:(NSString *)padId {
    self = [super init];
    if (self) {
        self.type   = C_NEW_COMMENT;
        self.itemId = itemId;
        self.padId = padId;
    }
    return self;
}

- (int)getCellHeight {
    return 100;
}

- (void)setContent:(NSDictionary *)content {
    
}

- (void)postComment {
    NSString *noteId      = self.itemId;
    NSString *commentBody = self.body;
    NSString *topicId     = self.padId;
    
    BOOL emptyNoteId = [noteId isEqualToString:@""] || noteId == NULL;

    if (!emptyNoteId)
    {
        [[ThreadItemManager sharedInstance] addComment:commentBody
                                          toNoteWithId:noteId
                                         inTopicWithId:topicId];
    }
}

@end