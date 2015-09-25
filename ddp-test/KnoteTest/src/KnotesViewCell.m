//
//  KnotesViewCell.m
//  Example
//
//  Created by wuli on 3/27/15.
//  Copyright (c) 2015 smart4c. All rights reserved.
//

#import "KnotesViewCell.h"
#import "Masonry.h"

@implementation KnotesViewCell

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

        [self.funName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(2));
            make.top.equalTo(@(2));
            make.right.equalTo(@(0));
            make.height.equalTo(@(20));
        }];

        [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(2));
            make.top.equalTo(self.funName.mas_bottom);
            make.right.equalTo(@(0));
            make.bottom.equalTo(@(-2));
        }];
    }
    return self;
}
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end
