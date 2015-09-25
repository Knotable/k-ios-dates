//
//  MCircleView.m
//  Mailer
//
//  Created by Martin Ceperley on 10/2/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MCircleView.h"
#import "MDesignManager.h"

@implementation MCircleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    UIColor* circleColor = [MDesignManager tintColor];
    CGContextRef context= UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, circleColor.CGColor);
    CGContextSetAlpha(context, 1.0);
    CGContextFillEllipseInRect(context, CGRectMake(1,1,self.frame.size.width-2,self.frame.size.height-2));
    
    //CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    //CGContextStrokeEllipseInRect(context, CGRectMake(0,0,self.frame.size.width,self.frame.size.height));

}


@end
