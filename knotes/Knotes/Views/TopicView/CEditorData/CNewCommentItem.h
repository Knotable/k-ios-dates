//
//  CNewCommentItem.h
//  Knotable
//
//  Created by Agustin Guerra on 8/12/14.
//
//

#import "CItem.h"

@interface CNewCommentItem : CItem

//@property (nonatomic, strong) NSString *body; // exist in super class
@property (nonatomic, strong) NSString *padId;

- (id)initWithNoteId:(NSString *)itemId andPadId:(NSString *)padId;
- (void)postComment;

@end
