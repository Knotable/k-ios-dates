//
//  MStatusView.m
//  Mailer
//
//  Created by Martin Ceperley on 10/2/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MStatusView.h"
#import "MDesignManager.h"

@implementation MStatusView

@synthesize statusLabel;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UILabel* label = [[UILabel alloc] initWithFrame:frame];
        self.statusLabel = label;

        label.text = @"";
        label.font = [UIFont systemFontOfSize:11.5];
        label.textColor = [MDesignManager highlightColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
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
