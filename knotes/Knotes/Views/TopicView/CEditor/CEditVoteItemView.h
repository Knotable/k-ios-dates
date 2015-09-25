//
//  CEditVoteItemView.h
//  RevealControllerProject
//
//  Created by backup on 13-10-16.
//
//

#import "CEditBaseItemView.h"
#define kItemDefaultHeight 38.0f
#if NEW_DESIGN
#import "CreplyUtils.h"
#endif
@interface CEditVoteItemView : CEditBaseItemView
@property (nonatomic, assign) BOOL isMultiSelected;
@property (nonatomic,assign) BOOL isRight;
@property (nonatomic, strong) NSArray *participators;
@property (nonatomic, strong) NSString *my_account_id;
#if NEW_DESIGN
@property(nonatomic,strong)CItem *itmTemp;
#endif
@end
