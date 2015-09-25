//
//  LoginViewCell.h
//  Example
//
//  Created by wuli on 2/4/15.
//  Copyright (c) 2015 smart4c. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "YLProgressBar.h"
@class LoginViewCell;
@protocol LoginViewCellDelegate <NSObject>

- (void)detailButtonClicked:(LoginViewCell *)cell;

@end
@interface LoginViewCell : UITableViewCell
@property (nonatomic, strong) UILabel *funName;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIButton *button;
//@property (nonatomic, strong) IBOutlet YLProgressBar      *progressBarRoundedFat;

@property (nonatomic, weak) id <LoginViewCellDelegate> delegate;
@end
