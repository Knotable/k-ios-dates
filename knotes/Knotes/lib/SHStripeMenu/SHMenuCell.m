//
//  SHMenuCell.m
//  Knotable
//
//  Created by backup on 14-1-17.
//
//

#import "SHMenuCell.h"

@implementation SHMenuCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.bg_btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self addSubview:self.bg_btn];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
