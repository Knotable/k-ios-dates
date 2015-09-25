//
//  LCTextField.m
//  RevealControllerProject
//
//  Created by Chen on 9/27/13.
//
//

#import "LCTextField.h"

@implementation LCTextField

@synthesize leftPadding = _leftPadding;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        leftPadding = 0;
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

-(void) setValue:(id)value forKey:(NSString *)key
{
    if ([key isEqualToString:@"leftPadding"])
    {
        [self setLeftPadding:(int)[value integerValue]];
    }
}

- (CGRect) textRectForBounds:(CGRect)bounds
{
    return CGRectMake(bounds.origin.x + 8, bounds.origin.y, bounds.size.width - 8, bounds.size.height);
}

- (CGRect) editingRectForBounds:(CGRect)bounds
{
    return [self textRectForBounds:bounds];
}

-(void) awakeFromNib
{
    [self setLeftPadding:0];
}
@end
