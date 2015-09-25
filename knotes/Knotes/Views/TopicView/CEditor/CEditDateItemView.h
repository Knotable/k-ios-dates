//
//  CEditDateItemView.h
//  RevealControllerProject
//
//  Created by backup on 13-10-16.
//
//

#import "CEditBaseItemView.h"
#import "DialController.h"
#if NEW_DESIGN
#import "CreplyUtils.h"
#endif
@class DateTimeView;
@interface CEditDateItemView : CEditBaseItemView
@property (nonatomic, strong) DateTimeView *datetimeView;
#if NEW_DESIGN
@property(nonatomic,strong)CItem *itmTemp;
#endif
@end
