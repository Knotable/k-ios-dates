//
//  UITabBarController+HideTabbar.m
//  Knotable
//
//  Created by Lin on 11/8/14.
//
//

#import "UITabBarController+HideTabbar.h"

#define kAnimationDuration .3

@implementation UITabBarController (HideTabbar)

- (void)setHidden:(BOOL)hidden animated:(BOOL)animated
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    float fHeight = screenRect.size.height;
    
    if (UIDeviceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        fHeight = screenRect.size.width;
    }
    
    if (!hidden)
    {
        fHeight -= self.tabBar.frame.size.height;
    }
    
    CGFloat animationDuration = animated ? kAnimationDuration : 0.f;
    
    [UIView animateWithDuration:animationDuration animations:^{
        
        for (UIView *view in self.view.subviews)
        {
            if ([view isKindOfClass:[UITabBar class]])
            {
                [view setFrame:CGRectMake(view.frame.origin.x, fHeight, view.frame.size.width, view.frame.size.height)];
            }
            else
            {
                if (hidden)
                {
                    [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
                }
            }
        }
    } completion:^(BOOL finished){
        
        if (!hidden)
        {
            [UIView animateWithDuration:animationDuration animations:^{
                
                for(UIView *view in self.view.subviews)
                {
                    if (![view isKindOfClass:[UITabBar class]])
                    {
                        [view setFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, fHeight)];
                    }
                }
            }];
        }
    }];
}

@end
