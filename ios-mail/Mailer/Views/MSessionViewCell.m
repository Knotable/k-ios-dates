//
//  MSessionViewCell.m
//  Mailer
//
//  Created by wuli on 14-6-13.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import "MSessionViewCell.h"

@implementation MSessionViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)layoutSubviews
{
    [super layoutSubviews];

    self.bgView.layer.borderWidth =2;
    self.bgView.layer.borderColor = [UIColor colorWithWhite:0.99 alpha:0.99].CGColor;
    [self.bgView setFrame:CGRectMake(4, 6, CGRectGetWidth(self.bounds)-8, CGRectGetHeight(self.bounds)-12)];
}
@end
