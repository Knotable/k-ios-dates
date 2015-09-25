//
//  MCircleView.m
//  Mailer
//
//  Created by Martin Ceperley on 10/2/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "CircleView.h"

@interface CircleView()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation CircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];

    }
    return self;
}

- (id)initWithImage:(UIImage *)image
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithImage:image];
        [self.imageView setFrame:self.bounds];
        [self addSubview:self.imageView];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    [self.imageView setFrame:self.bounds];
}

- (void)drawRect:(CGRect)rect
{
    if(self.frame.size.width<3.0 || self.frame.size.height<3.0){
        return;
    }
    if (self.imageView) {
        return;
    }
    UIColor* circleColor = self.tintColor;
    CGContextRef context= UIGraphicsGetCurrentContext();

    CGContextSetFillColorWithColor(context, circleColor.CGColor);
    CGContextSetAlpha(context, 1.0);
    CGContextFillEllipseInRect(context, CGRectMake(1,1,self.frame.size.width-2,self.frame.size.height-2));

}


@end
