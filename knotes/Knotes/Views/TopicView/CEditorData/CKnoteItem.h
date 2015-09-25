//
//  CKeyNoteItem.h
//  RevealControllerProject
//
//  Created by backup on 13-10-17.
//
//

#import <UIKit/UIKit.h>
#import "CItem.h"
#if NEW_DESIGN
#import "CLatestReplyView.h"
#endif
@interface CKnoteItem : CItem

@property (nonatomic, readwrite) NSAttributedString *attributedString;
@property (nonatomic, strong) NSMutableAttributedString *lessAttString;
- (id)initWithMessage:(MessageEntity *)message;
- (NSMutableDictionary *)dictionaryValue;

@end
