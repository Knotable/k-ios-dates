//
//  UIButton+Extensions.m
//  RevealControllerProject
//
//  Created by backup on 13-12-5.
//
//

#import "UIButton+Extensions.h"
#import <objc/runtime.h>

@implementation UIButton (Extensions)

@dynamic hitTestEdgeInsets;

static const NSString *KEY_HIT_TEST_EDGE_INSETS = @"HitTestEdgeInsets";

-(void)setHitTestEdgeInsets:(UIEdgeInsets)hitTestEdgeInsets {
    NSValue *value = [NSValue value:&hitTestEdgeInsets withObjCType:@encode(UIEdgeInsets)];
    objc_setAssociatedObject(self, &KEY_HIT_TEST_EDGE_INSETS, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(UIEdgeInsets)hitTestEdgeInsets {
    NSValue *value = objc_getAssociatedObject(self, &KEY_HIT_TEST_EDGE_INSETS);
    if(value) {
        UIEdgeInsets edgeInsets; [value getValue:&edgeInsets]; return edgeInsets;
    }else {
        return UIEdgeInsetsZero;
    }
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if(UIEdgeInsetsEqualToEdgeInsets(self.hitTestEdgeInsets, UIEdgeInsetsZero) ||       !self.enabled || self.hidden) {
        return [super pointInside:point withEvent:event];
    }
    
    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, self.hitTestEdgeInsets);
    
    return CGRectContainsPoint(hitFrame, point);
}
- (void)centerImageAndTitle:(float)spacing
{
    // get the size of the elements here for readability
    CGSize imageSize = self.imageView.frame.size;
    CGSize titleSize = self.titleLabel.frame.size;
    
    // get the height they will take up as a unit
    CGFloat totalHeight = (imageSize.height + titleSize.height + spacing);
    
    // raise the image and push it right to center it
    self.imageEdgeInsets = UIEdgeInsetsMake(- (totalHeight - imageSize.height), 0.0, 0.0, - titleSize.width);
    
    // lower the text and push it left to center it
    self.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (totalHeight - titleSize.height),0.0);
}

- (void)centerImageAndTitle
{
    const int DEFAULT_SPACING = 6.0f;
    [self centerImageAndTitle:DEFAULT_SPACING];
}  
-(void)animated
{
    CGAffineTransform initialTransform = self.transform;
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateKeyframesWithDuration:.4 delay:0 options:0 animations:^{
                [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.2 animations:^{
                    self.transform = CGAffineTransformScale(initialTransform, 1.4, 1.4);
                }];
                [UIView addKeyframeWithRelativeStartTime:.2 relativeDuration:.2 animations:^{
                    self.transform = CGAffineTransformScale(initialTransform, 1, 1);
                }];
            } completion:^(BOOL finished){
                self.transform = initialTransform;
            }];
        }
    }];
}

-(void)animated1
{
    CGAffineTransform initialTransform = self.transform;
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateKeyframesWithDuration:.4 delay:0 options:0 animations:^{
                [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.2 animations:^{
                    self.transform = CGAffineTransformScale(initialTransform, 1.4, 1.4);
                }];
                [UIView addKeyframeWithRelativeStartTime:.2 relativeDuration:.2 animations:^{
                    self.transform = CGAffineTransformScale(initialTransform, 1, 1);
                }];
            } completion:^(BOOL finished){
                [UIView animateKeyframesWithDuration:.4 delay:0 options:0 animations:^{
                    [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.2 animations:^{
                        self.transform = CGAffineTransformScale(initialTransform, 1.4, 1.4);
                    }];
                    [UIView addKeyframeWithRelativeStartTime:.2 relativeDuration:.2 animations:^{
                        self.transform = CGAffineTransformScale(initialTransform, 1, 1);
                    }];
                } completion:^(BOOL finished){
                    self.transform = initialTransform;
                }];
            }];
        }
    }];
}

-(void)animatedDismiss
{
    CGAffineTransform initialTransform = self.transform;
    [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.transform = CGAffineTransformMakeScale(0.8, 0.8);
    } completion:^(BOOL finished) {
        if (finished) {
            [UIView animateKeyframesWithDuration:.4 delay:0 options:0 animations:^{
                [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:.2 animations:^{
                    self.transform = CGAffineTransformScale(initialTransform, 0.4, 0.4);
                }];
                [UIView addKeyframeWithRelativeStartTime:.2 relativeDuration:.2 animations:^{
                    self.transform = CGAffineTransformScale(initialTransform, 0.2, 0.2);
                }];
            } completion:^(BOOL finished){
                self.transform = CGAffineTransformMakeScale(0.1, 0.1);
                self.hidden = YES;
            }];
        }
    }];
}

@end