//
//  VoteCell.h
//  Knotable
//
//  Created by Martin Ceperley on 12/23/13.
//
//

#import "BaseKnoteCell.h"

@interface VoteCell : BaseKnoteCell
@property (nonatomic, copy) NSString *my_account_id;
@property (nonatomic, strong) NSArray *participators;

@end
