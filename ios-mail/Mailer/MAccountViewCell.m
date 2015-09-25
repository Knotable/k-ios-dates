//
//  MAccountViewCell.m
//  Mailer
//
//  Created by backup on 14-4-30.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import "MAccountViewCell.h"
@interface MAccountViewCell()
@end
@implementation MAccountViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_newEmail"]];
        self.imgView.backgroundColor = [UIColor clearColor];
        self.imgView.hidden = YES;
        [self addSubview:self.imgView];
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.imgView setFrame:CGRectMake(CGRectGetWidth(self.bounds)-30, CGRectGetMidY(self.bounds)-8, 17, 16)];
}
- (void)awakeFromNib
{
    // Initialization code
}
-(void)setNewEmailHidden:(BOOL)flag
{
    self.imgView.hidden = flag;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
