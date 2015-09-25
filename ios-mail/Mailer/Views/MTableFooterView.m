//
//  MTableFooterView.m
//  Mailer
//
//  Created by Martin Ceperley on 10/3/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MTableFooterView.h"

@implementation MTableFooterView

@synthesize label = _label;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //self.backgroundColor = [UIColor blueColor];
        _label = [[UILabel alloc] initWithFrame:self.bounds];
        _label.text = @"";
        _label.font = [UIFont boldSystemFontOfSize:12.0];
        _label.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        
        
        _loader = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _loader.center = CGPointMake(40, 25);
        [self addSubview:_loader];
        
        
//        _loader = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(5, 5, 20, 20)];
        
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
