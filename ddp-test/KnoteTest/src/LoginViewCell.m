//
//  LoginViewCell.m
//  Example
//
//  Created by wuli on 2/4/15.
//  Copyright (c) 2015 smart4c. All rights reserved.
//

#import "LoginViewCell.h"
#import "Masonry.h"

@implementation LoginViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.funName = [[UILabel alloc] initWithFrame:CGRectMake(2, 2, 120, 20)];
        self.funName.textColor = [UIColor purpleColor];
        self.funName.font = [UIFont boldSystemFontOfSize:15];
        [self.contentView addSubview:self.funName];
        self.detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 22, 120, 20)];
        self.detailLabel.numberOfLines = 0;
        self.detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.detailLabel.textColor = [UIColor darkGrayColor];
        self.detailLabel.font = [UIFont boldSystemFontOfSize:12];
        [self.contentView addSubview:self.detailLabel];
        
        self.timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(2, 22, 120, 20)];
        self.timeLabel.numberOfLines = 0;
        self.timeLabel.textAlignment = NSTextAlignmentRight;
        self.timeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.timeLabel.textColor = [UIColor blackColor];
        self.timeLabel.font = [UIFont boldSystemFontOfSize:10];
        [self.contentView addSubview:self.timeLabel];
        [self.funName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(2));
            make.top.equalTo(@(2));
            make.right.equalTo(@(0));
            make.height.equalTo(@(20));
        }];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(2));
            make.height.equalTo(@(16));
            make.right.equalTo(@(0));
            make.bottom.equalTo(@(-2));
        }];
        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(2));
            make.top.equalTo(self.funName.mas_bottom);
            make.right.equalTo(@(0));
            make.bottom.equalTo(self.timeLabel.mas_top);
        }];
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.button setTitle:@"Details" forState:UIControlStateNormal];
        self.button.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.button.backgroundColor = [UIColor purpleColor];
        [self.contentView addSubview:self.button];
        [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@(60));
            make.top.equalTo(@(2));
            make.right.equalTo(@(-2));
            make.height.equalTo(@(36));
        }];
        self.button.hidden = YES;
        [self.button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
#if 0
        self.progressBarRoundedFat = [[YLProgressBar alloc] initWithFrame:CGRectMake(0, 0, 100, 20)];
        NSArray *tintColors = @[[UIColor colorWithRed:33/255.0f green:180/255.0f blue:162/255.0f alpha:1.0f],
                                [UIColor colorWithRed:111/255.0f green:188/255.0f blue:84/255.0f alpha:1.0f]];
        _progressBarRoundedFat.progressTintColors       = tintColors;
        _progressBarRoundedFat.stripesOrientation       = YLProgressBarStripesOrientationLeft;
        _progressBarRoundedFat.trackTintColor = [UIColor colorWithWhite:0.60 alpha:0.99];
        _progressBarRoundedFat.indicatorTextLabel.font  = [UIFont boldSystemFontOfSize:10];
        _progressBarRoundedFat.indicatorTextLabel.textColor = [UIColor whiteColor];
        _progressBarRoundedFat.type               = YLProgressBarTypeFlat;
        _progressBarRoundedFat.indicatorTextDisplayMode = YLProgressBarIndicatorTextDisplayModeProgress;
        _progressBarRoundedFat.behavior = YLProgressBarBehaviorIndeterminate;
//        _progressBarRoundedFat.hideTrack = YES;
        _progressBarRoundedFat.hideGloss = YES;
        
        [self.contentView addSubview:_progressBarRoundedFat];
        [self.progressBarRoundedFat mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(2));
            make.bottom.equalTo(@(-2));
            make.width.equalTo(@(160));
            make.height.equalTo(@(12));
        }];
        self.progressBarRoundedFat.hidden = YES;
#endif
    }
    return self;
}
-(void)buttonClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(detailButtonClicked:)]) {
        [self.delegate detailButtonClicked:self];
    }
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
