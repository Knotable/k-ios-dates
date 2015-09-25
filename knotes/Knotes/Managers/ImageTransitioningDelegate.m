//
// Created by Martin Ceperley on 3/3/14.
//

#import "ImageTransitioningDelegate.h"
#import "AnimatedTransitioning.h"

@implementation ImageTransitioningDelegate {

}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    AnimatedTransitioning *controller = [[AnimatedTransitioning alloc] init];
    controller.isPresenting = YES;
    return controller;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    AnimatedTransitioning *controller = [[AnimatedTransitioning alloc]init];
    controller.isPresenting = NO;
    return controller;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}

- (id <UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id <UIViewControllerAnimatedTransitioning>)animator {
    return nil;
}


@end
