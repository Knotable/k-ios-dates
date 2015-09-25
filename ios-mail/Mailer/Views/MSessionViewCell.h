//
//  MSessionViewCell.h
//  Mailer
//
//  Created by wuli on 14-6-13.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JZSwipeCell.h"
@class MCircleView,Message;
@interface MSessionViewCell : JZSwipeCell

@property (nonatomic, strong) IBOutlet UILabel* fromLabel;
@property (nonatomic, strong) IBOutlet UILabel* subjectLabel;
@property (nonatomic, strong) IBOutlet UILabel* dateLabel;
@property (nonatomic, strong) IBOutlet UILabel* sumaryLabel;
@property (nonatomic, strong) IBOutlet MCircleView* unreadCircle;

@property (nonatomic, strong) IBOutlet UILabel* characterCountLabel;
@property (nonatomic, strong) IBOutlet UIProgressView* progressView;
@property (strong, nonatomic) IBOutlet UIView *bgView;


@property (nonatomic, retain) Message *message;

@end
