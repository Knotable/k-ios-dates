//
//  MCyclingAnimator.m
//  Mailer
//
//  Created by Martin Ceperley on 11/11/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MCyclingAnimator.h"

const CGFloat PARALLAX_RATIO = 0.4;
const CGFloat GRADIENT_WIDTH = 20.0;

@implementation MCyclingAnimator

- (id)initWithParent:(UIViewController *)parent operation:(UINavigationControllerOperation)operation
{
    if (self = [super init]) {
        isPush = (operation == UINavigationControllerOperationPush);
        _parentViewController = parent;
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

// This method can only  be a nop if the transition is interactive and not a percentDriven interactive transition.
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    //NSLog(@"animateTransition");
    return;
/*
    UIViewController *toController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    CGRect startFromFrame = [transitionContext initialFrameForViewController:fromController];
    CGRect finalToFrame = [transitionContext finalFrameForViewController:toController];

    fromController.view.userInteractionEnabled = NO;
    
    [transitionContext.containerView addSubview:fromController.view];
    [transitionContext.containerView addSubview:toController.view];
    
    CGFloat offset = startFromFrame.size.width;
    if (!isPush) {
        offset *= -1.0;
    }
    startFromFrame.origin.x += offset;
    
    toController.view.frame = startFromFrame;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        fromController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        toController.view.frame = finalToFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        toController.view.userInteractionEnabled = YES;
    }];

    */
}


- (void)startInteractiveTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    //NSLog(@"startInteractiveTransition context: %@", transitionContext);
    //[super startInteractiveTransition:transitionContext];
    
    transitioningContext = transitionContext;
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    CGRect startFrame = transitionContext.containerView.bounds;
    
    if (dimmingView && dimmingView.superview) {
        [dimmingView removeFromSuperview];
    }
    
    dimmingView = [[UIView alloc] initWithFrame:transitionContext.containerView.bounds];
    dimmingView.backgroundColor = [UIColor whiteColor];
    dimmingView.opaque = NO;
    dimmingView.alpha = 0.0;
    

    [transitionContext.containerView addSubview:toViewController.view];
    //[fromViewController.view addSubview:dimmingView];
    [transitionContext.containerView addSubview:fromViewController.view];
    
    
    CGFloat factor = isPush ? 1.0 : -1.0;
    startFrame.origin.x += PARALLAX_RATIO * factor * startFrame.size.width;
    toViewController.view.frame = startFrame;
    
    CGRect gradientFrame = [transitionContext.containerView convertRect:transitionContext.containerView.bounds toView:fromViewController.view];;
    gradientFrame.size.width = GRADIENT_WIDTH;
    
    if (isPush) {
        gradientFrame.origin.x = fromViewController.view.frame.size.width;
    }
    else {
        gradientFrame.origin.x = -GRADIENT_WIDTH;
    }
    
    gradientView = [[UIView alloc] initWithFrame:gradientFrame];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = gradientView.bounds;
    gradient.colors = @[
                            (id)[[UIColor colorWithWhite:0.0 alpha:0.0] CGColor],
                            (id)[[UIColor colorWithWhite:0.0 alpha:0.1] CGColor],
                            (id)[[UIColor colorWithWhite:0.0 alpha:0.4] CGColor]
                       ];
    
    gradient.locations = @[@0.0, @0.6, @1.0];
    if (isPush) {
        gradient.startPoint = CGPointMake(1, 0.5);
        gradient.endPoint = CGPointMake(0, 0.5);
    }
    else {
        gradient.startPoint = CGPointMake(0, 0.5);
        gradient.endPoint = CGPointMake(1, 0.5);
    }

    //gradient.startPoint = CGPointMake(0, gradient.frame.origin.y + (gradient.frame.size.height / 2.0));
    //gradient.endPoint = CGPointMake(gradient.frame.size.width, gradient.startPoint.y);
    //NSLog(@"startPoint: %@ endPoint: %@", NSStringFromCGPoint(gradient.startPoint), NSStringFromCGPoint(gradient.endPoint));
    //NSLog(@"layer frame: %@ bounds: %@", NSStringFromCGRect(gradient.frame), NSStringFromCGRect(gradient.bounds));
    //NSLog(@"gradientView frame: %@ bounds: %@", NSStringFromCGRect(gradientView.frame), NSStringFromCGRect(gradientView.bounds));
    
    [gradientView.layer insertSublayer:gradient atIndex:0];
    
    [fromViewController.view addSubview:gradientView];
    fromViewController.view.clipsToBounds = NO;

}

- (void)updateInteractiveTransition:(CGFloat)percentComplete
{
    //NSLog(@"updateInteractiveTransition %f", percentComplete);
    
    //[super updateInteractiveTransition:percentComplete];

    
    
    UIViewController *fromViewController = [transitioningContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitioningContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGFloat factor = isPush ? -1.0 : 1.0;
    CGRect fromFrame = CGRectOffset(transitioningContext.containerView.bounds,
                                factor * transitioningContext.containerView.bounds.size.width * percentComplete, 0);
    
    //NSLog(@"progress: %f x: %f", percentComplete, frame.origin.x);
    fromViewController.view.frame = fromFrame;
    //dimmingView.alpha = percentComplete;
    
    //FOR PUSH (right edge) toFrame origin needs to be 320 * 0.5 at 0 progress, 0 at 100 progress
    // (1 - x) * PARALLAX * WIDTH
    //FOR left edge
    // (1 - x) * PARALLAX * WIDTH * -1.0
    CGRect toFrame = transitioningContext.containerView.bounds;
    toFrame.origin.x = (1.0 - percentComplete) * PARALLAX_RATIO * toFrame.size.width * factor * -1.0;
    toViewController.view.frame = toFrame;
    
}

- (void)finishInteractiveTransition {
    
    //NSLog(@"finishInteractiveTransition");
    UIViewController *toViewController = [transitioningContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitioningContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    CGFloat factor = isPush ? -1.0 : 1.0;
    CGRect endToFrame = transitioningContext.containerView.bounds;
    CGRect endFromFrame = endToFrame;
    endFromFrame.origin.x = factor * endFromFrame.size.width;
    [UIView animateWithDuration:0.3 animations:^{
        fromViewController.view.frame = endFromFrame;
        toViewController.view.frame = endToFrame;
        //dimmingView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitioningContext completeTransition:YES];
        [gradientView removeFromSuperview];
    }];

    [super finishInteractiveTransition];

}

- (void)cancelInteractiveTransition {
    
    //NSLog(@"cancelInteractiveTransition");
    UIViewController *fromViewController = [transitioningContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitioningContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    CGFloat factor = isPush ? 1.0 : -1.0;

    //CGRect endFrame = CGRectOffset(transitioningContext.containerView.bounds, factor * CGRectGetWidth(transitioningContext.containerView.bounds), 0);
    CGRect endToFrame = transitioningContext.containerView.bounds;
    endToFrame.origin.x = factor * endToFrame.size.width * PARALLAX_RATIO;
    
    [UIView animateWithDuration:0.3f animations:^{
        fromViewController.view.frame = transitioningContext.containerView.bounds;
        toViewController.view.frame = endToFrame;
        //dimmingView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitioningContext completeTransition:NO];
        [gradientView removeFromSuperview];
    }];

    
    [super cancelInteractiveTransition];

}

/*
- (CGFloat)completionSpeed;
- (UIViewAnimationCurve)completionCurve;
*/


@end
