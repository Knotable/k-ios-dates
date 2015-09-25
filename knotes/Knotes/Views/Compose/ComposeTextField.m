//
//  ComposeTextField.m
//  Knotable
//
//  Created by backup on 14-1-3.
//
//

#import "ComposeTextField.h"

@implementation ComposeTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect rect = bounds;
    rect.origin.x+=4;
    rect.origin.y+=4;
    rect.size.width-=8;
    rect.size.height-=8;
    return rect;
}

@end
