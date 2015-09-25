//
//  CEditInfoItem.m
//  Knotable
//
//  Created by wuli on 14-4-16.
//
//

#import "CEditInfoItem.h"

@implementation CEditInfoItem
-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.imgView = [[GBPathImageView alloc] initWithFrame:self.bounds image:nil pathType:GBPathImageViewTypeCircle pathColor:[UIColor clearColor] borderColor:[UIColor clearColor] pathWidth:.01];
        [self addSubview:self.imgView];
    }
    return self;
}

-(void)updateConstraints
{
    [super updateConstraints];
    [self.imgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
    }];
}
@end
