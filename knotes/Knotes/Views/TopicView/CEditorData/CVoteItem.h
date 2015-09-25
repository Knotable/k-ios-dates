//
//  CVoteItem.h
//  RevealControllerProject
//
//  Created by backup on 13-10-17.
//
//

#import "CItem.h"
@interface CVoteItem : CItem
@property (nonatomic, strong) NSMutableArray* voteList;
@property (nonatomic, strong) UIFont *titleFont;
+ (CGFloat)getCustomHeight:(MessageEntity *)message;
@end
