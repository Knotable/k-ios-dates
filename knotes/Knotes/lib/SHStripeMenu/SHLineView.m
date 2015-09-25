//
//  SHLineView.m
//  SHStripeMenu
//
//  Created by Narasimharaj on 06/05/13.
//  Copyright (c) 2013 SimHa. All rights reserved.
//

#import "SHLineView.h"
@interface SHLineView ()
@property (nonatomic, strong) UIImageView *imgV;
@end
@implementation SHLineView

- (id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];

	if (self)
	{
        UIImage *img = [UIImage imageNamed:@"person-outline"];
        _imgV = [[UIImageView alloc] initWithImage:img];
        _imgV.frame = CGRectMake(0, 0, 40, 40);
        _imgV.contentMode = UIViewContentModeScaleToFill;
        
        [self addSubview:_imgV];
		// Initialization code
	}
	return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect rect = _imgV.frame;
    rect.origin.x = (self.frame.size.width - rect.size.width)/2;
    rect.origin.y = (self.frame.size.height - rect.size.height)/2;
    _imgV.frame = rect;
}
@end