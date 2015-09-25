//
// Created by Martin Ceperley on 3/3/14.
//

#import "AnimatedTransitioning.h"
#import "GGFullScreenImageViewController.h"

@implementation AnimatedTransitioning {

}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {

    UIView *inView = [transitionContext containerView];
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];

    [inView addSubview:toVC.view];

    [toVC.view setFrame:CGRectMake(0, 0, fromVC.view.frame.size.width, fromVC.view.frame.size.height)];
    [transitionContext completeTransition:YES];
}



@end
