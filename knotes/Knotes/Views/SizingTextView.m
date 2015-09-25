//
//  SizingTextView.m
//  Knotable
//
//  Created by Martin Ceperley on 12/21/13.
//
//

#import "SizingTextView.h"

@implementation SizingTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    if (!CGSizeEqualToSize(self.bounds.size, [self intrinsicContentSize])) {
        [self invalidateIntrinsicContentSize];
    }
}

- (CGSize)intrinsicContentSize
{
    CGSize intrinsicContentSize = self.contentSize;
    // iOS 7.0+
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) {
        intrinsicContentSize.width += (self.textContainerInset.left + self.textContainerInset.right ) / 2.0f;
        intrinsicContentSize.height += (self.textContainerInset.top + self.textContainerInset.bottom) / 2.0f;
    }
    NSLog(@"SizingTextView intrinsicContentSize %@ for text length: %d", NSStringFromCGSize(intrinsicContentSize), self.text.length);
    return intrinsicContentSize;
}

@end
