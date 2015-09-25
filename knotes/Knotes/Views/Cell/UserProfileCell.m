//
//  UserProfileCell.m
//  Knotable
//
//  Created by liwu on 14-1-1.
//
//

#import "UserProfileCell.h"
#import "Masonry.h"
#import "CUtil.h"
@implementation UserProfileCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.infoLabel = [[UILabel alloc] init];
        _infoLabel.backgroundColor = [UIColor clearColor];
        //_lbTitle.font = kCustomLightFont(18);
        _infoLabel.font = kCustomBoldFont(14);
        _infoLabel.textColor = [UIColor blackColor];
        _infoLabel.textAlignment = NSTextAlignmentRight;
        [self.contentView addSubview:_infoLabel];

        self.contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.textAlignment = NSTextAlignmentLeft;
        //_lbTitle.font = kCustomLightFont(18);
        _contentLabel.font = kCustomLightFont(14);
        _contentLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:_contentLabel];
    }
    return self;
}
- (void)updateConstraints
{
    [super updateConstraints];
    [self.infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(       8.0);
        make.bottom.equalTo(self).with.offset(    -8.0);
        make.left.equalTo(self).with.offset(      0.0);
        make.width.equalTo(@80);
    }];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).with.offset(       8.0);
        make.bottom.equalTo(self).with.offset(    -8.0);
        make.left.equalTo(self.infoLabel.mas_right).with.offset(8.0);
        make.right.equalTo(self).with.offset(     -8.0);
    }];
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
