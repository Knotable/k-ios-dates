//
//  CReplysItem.h
//  Knotable
//
//  Created by backup on 14-7-18.
//
//

#import "CItem.h"

@interface CReplysItem : CItem
@property (nonatomic, readonly) NSAttributedString *attributedString;
@property (nonatomic, strong) NSDictionary *content;
@property (nonatomic, weak) CItem *parentItem;
@end
