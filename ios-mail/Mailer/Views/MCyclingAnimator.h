//
//  MCyclingAnimator.h
//  Mailer
//
//  Created by Martin Ceperley on 11/11/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCyclingAnimator : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning> {
    BOOL isPush;
    id <UIViewControllerContextTransitioning> transitioningContext;
    UIView *dimmingView;
    UIView *gradientView;
}

- (id)initWithParent:(UIViewController *)parent operation:(UINavigationControllerOperation)operation;

@property (nonatomic, readonly) UIViewController *parentViewController;

@end
