//
//  MMailHeaderIndicateView.m
//  Mailer
//
//  Created by wuli on 14-6-4.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import "MMailHeaderIndicateView.h"

@implementation MMailHeaderIndicateView

-(void)updateConstraints
{
    [super updateConstraints];
    [self.indicateButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo(self.mas_left).offset(40.0);
        make.right.equalTo(self.mas_right).offset(-40);
    }];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.indicateButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.indicateButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self addSubview: self.indicateButton];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
