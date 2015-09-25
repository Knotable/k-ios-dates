//
//  MMessageCell.h
//  Mailer
//
//  Created by Martin Ceperley on 10/1/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JZSwipeCell.h"
@class MCircleView, Message;

@interface MMessageCell : JZSwipeCell

@property (nonatomic, strong) IBOutlet UILabel* fromLabel;
@property (nonatomic, strong) IBOutlet UILabel* subjectLabel;
@property (nonatomic, strong) IBOutlet UILabel* dateLabel;
@property (nonatomic, strong) IBOutlet UILabel* textLabel;
@property (nonatomic, strong) IBOutlet MCircleView* unreadCircle;
@property (strong, nonatomic) IBOutlet UILabel *threadCount;

@property (nonatomic, strong) IBOutlet UILabel* characterCountLabel;
@property (nonatomic, strong) IBOutlet UIProgressView* progressView;

@property (nonatomic, strong) Message* message;


@end
