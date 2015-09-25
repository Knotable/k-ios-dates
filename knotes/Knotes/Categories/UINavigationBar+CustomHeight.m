//
//  UINavigationBar+CustomHeight.m
//  Knotable
//
//  Created by Dhruv on 24/06/15.
//
//

#import "UINavigationBar+CustomHeight.h"

@implementation UINavigationBar (CustomHeight)
- (CGSize)sizeThatFits:(CGSize)size {
    
    CGSize newSize;
    if ([UIApplication sharedApplication].isStatusBarHidden)
    {
         newSize = CGSizeMake(self.frame.size.width,64);
    }
    else
    {
        newSize = CGSizeMake(self.frame.size.width,44);
    }
    return newSize;
}
@end
