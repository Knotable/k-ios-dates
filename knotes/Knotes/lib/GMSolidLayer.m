//
//  GMSolidLayer.m
//  Market
//
//  Created by backup on 13-10-31.
//  Copyright (c) 2013年 backup. All rights reserved.
//

#import "GMSolidLayer.h"
#import <QuartzCore/QuartzCore.h>
@interface GMSolidLayer ()
{
    CALayer *downLayer_;
}

@end
@implementation GMSolidLayer
@synthesize downLayer = downLayer_;
-(void)dealloc
{
    downLayer_ = nil;
}
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    if (!downLayer_)
    {
        downLayer_ = [CALayer layer];
        downLayer_.backgroundColor = [UIColor clearColor].CGColor;
        [self addSublayer:downLayer_];
    }
    downLayer_.frame = CGRectMake(0, 1, self.frame.size.width, 1);
}
@end
