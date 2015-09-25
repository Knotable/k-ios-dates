//
//  MControllerManager.m
//  Mailer
//
//  Created by Martin Ceperley on 10/31/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MControllerManager.h"
#import "MMessageListController.h"
#import "MGalleryViewController.h"
#import "MCyclingAnimator.h"
#import "MFileViewController.h"
#import "MPeopleViewController.h"
#import "MHomeViewController.h"
@implementation MControllerManager

+ (MControllerManager *)sharedManager {
    static MControllerManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MControllerManager alloc] init];
    });
    return sharedInstance;
}

- (id) init
{
    if (self == [super init]) {
        
        isStart = YES;
        
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        
//        controllers = [[NSMutableArray alloc] initWithObjects:
//                            [self setupInbox],
//                            [self setupShortInbox],
//                            [self setupLongInbox],
//                            [self setupPicturesInbox],
//                            [self setupFiles],
//                            [self setupPeople] , nil];
        
        
        isStart = NO;
        
    }
    return self;
}

- (void) showFirstControllerFrom:(UIViewController *)viewController
{
    viewController.navigationController.delegate = self;
    
    [viewController.navigationController pushViewController:[self setupInbox] animated:YES];
    
//    UIViewController *passVwCntrl = [viewController.navigationController.viewControllers lastObject];
    
    
}

//Modified by 3E ------START------


- (void) showSecondControllerFrom:(UIViewController *)viewController
{
    viewController.navigationController.delegate = self;
    
    [viewController.navigationController pushViewController:[self setupShortInbox] animated:YES];
}

- (void) showThirdControllerFrom:(UIViewController *)viewController
{
    viewController.navigationController.delegate = self;
    
    [viewController.navigationController pushViewController:[self setupLongInbox] animated:YES];
}

- (void) showFourthControllerFrom:(UIViewController *)viewController
{
    viewController.navigationController.delegate = self;
    
    [viewController.navigationController pushViewController:[self setupPicturesInbox] animated:YES];
}

- (void) showFifthControllerFrom:(UIViewController *)viewController
{
    viewController.navigationController.delegate = self;
    
    [viewController.navigationController pushViewController:[self setupFiles] animated:YES];
}


- (void) showSixthControllerFrom:(UIViewController *)viewController
{
    viewController.navigationController.delegate = self;
    
    [viewController.navigationController pushViewController:[self setupPeople] animated:YES];
}

- (void) showSeventhControllerFrom:(UIViewController *)viewController
{
    viewController.navigationController.delegate = self;
    
    [viewController.navigationController pushViewController:[self setupAllInbox] animated:YES];
}


//Modified by 3E ------END------

- (void) goLeftFrom:(UIViewController *)viewController recognizer:(UIScreenEdgePanGestureRecognizer *)recognizer
{
    
//NSLog(@"...............goLeftFrom................");
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        UIViewController *destinationController = nil;
        
        //Modified by 3E ------START------
        
//NSLog(@"viewController Left=%@",viewController);
        
        if (viewController == nil) {
            return;
        }
        if (viewController == _inbox) {
            destinationController = [self setupPeople];
        }
        else if (viewController == _allinbox) {
            destinationController = [self setupInbox];
        }
        
        else if (viewController == _shortInbox) {
            destinationController = [self setupAllInbox];
        }
        
        else if (viewController == _longInbox) {
            destinationController = [self setupShortInbox];
        }
        
        else if (viewController == _picturesInbox) {
            destinationController = [self setupLongInbox];
        }
        
        else if (viewController == _fileInbox) {
            destinationController = [self setupPicturesInbox];
        }
        else if (viewController == _peopleInbox) {
            destinationController = [self setupFiles];
        }
        
//        NSLog(@"destinationController Left=%@",destinationController);

        if (destinationController != nil){
            
            fromController = viewController;
            toController = destinationController;
            
            viewController.navigationController.viewControllers = @[[viewController.navigationController.viewControllers objectAtIndex:0],[viewController.navigationController.viewControllers objectAtIndex:1],destinationController, viewController];
            
            //Modified by 3E ------END------

        [viewController.navigationController popViewControllerAnimated:NO];//debug
            
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self transitionProgressedRight:NO recognizer:recognizer];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self transitionEndedRight:NO recognizer:recognizer];
    }
}

- (void) transitionProgressedRight:(BOOL)isRight recognizer:(UIScreenEdgePanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:recognizer.view.window];
    if (animator == nil) {
//        NSLog(@"Uh Oh animator is nil in Changed state");
    } else {
        CGFloat ratio;
        if(isRight){
            ratio = 1.0 - (location.x / fromController.view.bounds.size.width);
        } else {
            ratio = location.x / fromController.view.bounds.size.width;
        }
        [animator updateInteractiveTransition:ratio];
    }

}

- (void) transitionEndedRight:(BOOL)isRight recognizer:(UIScreenEdgePanGestureRecognizer *)recognizer
{
    CGPoint location = [recognizer locationInView:recognizer.view.window];
//    CGPoint velocity = [recognizer velocityInView:fromController.view];

    CGFloat ratio;
    if(isRight){
        ratio = 1.0 - (location.x / fromController.view.bounds.size.width);
    } else {
        ratio = location.x / fromController.view.bounds.size.width;
    }
//    NSLog(@"transitionEnded velocity x: %f location x: %f", velocity.x, location.x);
    
    if (ratio > 0.5) {
        [animator finishInteractiveTransition];
    }
    else {
        [animator cancelInteractiveTransition];
    }
}

- (void) goRightFrom:(UIViewController *)viewController recognizer:(UIScreenEdgePanGestureRecognizer *)recognizer
{
//   NSLog(@"...............goRightFrom................");
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        UIViewController *destinationController = nil;
        
//    NSLog(@"viewController Right=%@",viewController);
        
        if (viewController == nil) {
            return;
        }
        if (viewController == _inbox) {
            destinationController = [self setupAllInbox];
        }else if (viewController == _allinbox) {
            destinationController = [self setupShortInbox];
        }else if (viewController == _shortInbox) {
            destinationController = [self setupLongInbox];
        } else if (viewController == _longInbox) {
            destinationController = [self setupPicturesInbox];
        } else if (viewController == _picturesInbox) {
            destinationController = [self setupFiles];
        }
        else if (viewController == _fileInbox) {
            destinationController = [self setupPeople];
        }
        else if (viewController == _peopleInbox) {
            destinationController = [self setupInbox];
        }
        
//       NSLog(@"destinationController Right=%@",destinationController);
        
        if (destinationController != nil){
            
            //Modified by 3E ------START------
           
            if ([viewController.navigationController.viewControllers count] > 4) {
                
                NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray: viewController.navigationController.viewControllers];
                
                [allViewControllers removeObjectAtIndex:2];
                viewController.navigationController.viewControllers = allViewControllers;
                
            }
            
             //Modified by 3E ------END------
            
            fromController = viewController;
            toController = destinationController;
            NSMutableArray *viewControllers = [viewController.navigationController.viewControllers mutableCopy];
            [viewControllers addObject:destinationController];
            viewController.navigationController.viewControllers = [viewControllers copy];
            
//            [viewController.navigationController pushViewController:destinationController animated:YES];//debug
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        [self transitionProgressedRight:YES recognizer:recognizer];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self transitionEndedRight:YES recognizer:recognizer];
    }
}

//PanGesture


- (void) goPanRightFrom:(UIViewController *)viewController recognizer:(UIPanGestureRecognizer *)recognizer{
    
    
//    CGPoint translation = [recognizer translationInView:viewController.view];
//    
////    
////    [UIView animateWithDuration:0.5 delay:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:^{[recognizer.view setCenter:(CGPointMake(recognizer.view.center.x+translation.x ,recognizer.view.center.y))];} completion:nil];
//    
//    
//
//    
//    [UIView beginAnimations:nil context:NULL];
//    
//    // Animation settings.
//    [UIView setAnimationDuration:0.0];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//    
//    //  Transformations. Translate by 200 pixels on the x axis and -300 pixels
//    //  on the y axis, and scale down from twice its original size. Note that
//    //  because these are matrix transformations, order matters here.
//    //
//    [viewController.view setTransform:CGAffineTransformMakeTranslation(translation.x, 0.0)];
//    
//    // End animation block.
//    [UIView commitAnimations];
//     NSLog(@"viewController = %@",viewController);
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    
        UIViewController *destinationController = nil;
        
//            NSLog(@"viewController Right=%@",viewController);
    
        if (viewController == nil) {
            return;
        }
        if (viewController == _inbox) {
            destinationController = [self setupShortInbox];
        }
    
        else if (viewController == _allinbox) {
            destinationController = [self setupShortInbox];
        }

    
        else if (viewController == _shortInbox) {
            destinationController = [self setupLongInbox];
        } else if (viewController == _longInbox) {
            destinationController = [self setupPicturesInbox];
        } else if (viewController == _picturesInbox) {
            destinationController = [self setupFiles];
        }
        else if (viewController == _fileInbox) {
            destinationController = [self setupPeople];
        }
        else if (viewController == _peopleInbox) {
            
            switch ([defaults integerForKey:@"selectedIndex"]) {
                case kAllAccountIndex:
                     destinationController = [self setupAllInbox];
                    break;
                    
                default:
                     destinationController = [self setupInbox];
                    break;
            }
            
        }
        
//               NSLog(@"destinationController Right=%@",destinationController);
    
        if (destinationController != nil){
            
            //Modified by 3E ------START------
            
            if ([viewController.navigationController.viewControllers count] > 4) {
                
                NSMutableArray *allViewControllers = [NSMutableArray arrayWithArray: viewController.navigationController.viewControllers];
                
                [allViewControllers removeObjectAtIndex:2];
                
                
                viewController.navigationController.viewControllers = allViewControllers;
                
            }
            
            //Modified by 3E ------END------
            
            fromController = viewController;
            toController = destinationController;
            
//            NSLog(@"fromController = %@",fromController);
//            NSLog(@"toController = %@",toController);

            NSMutableArray *viewControllers = [viewController.navigationController.viewControllers mutableCopy];
            [viewControllers addObject:destinationController];
            viewController.navigationController.viewControllers = [viewControllers copy];
//            [viewController.navigationController pushViewController:destinationController animated:YES];//debug
        }
    
//    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
//        [self transitionProgressedRight:YES recognizer:recognizer];
//        
//    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
//        [self transitionEndedRight:YES recognizer:recognizer];
//    }

}

- (void) goPanLeftFrom:(UIViewController *)viewController recognizer:(UIPanGestureRecognizer *)recognizer{
    
    //NSLog(@"...............goLeftFrom................");
//    if (recognizer.state == UIGestureRecognizerStateBegan) {
        UIViewController *destinationController = nil;
    
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        //Modified by 3E ------START------
        //NSLog(@"viewController Left=%@",viewController);
        
        if (viewController == nil) {
            return;
        }
        if (viewController == _inbox) {
            destinationController = [self setupPeople];
        }
    
        if (viewController == _allinbox) {
            destinationController = [self setupPeople];
        }
        else if (viewController == _shortInbox) {
            
            switch ([defaults integerForKey:@"selectedIndex"]) {
                case kAllAccountIndex:
                    destinationController = [self setupAllInbox];
                    break;
                    
                    
                default:
                    destinationController = [self setupInbox];
                    break;
            }
            
//            destinationController = [self setupInbox];
        }
        
        else if (viewController == _longInbox) {
            destinationController = [self setupShortInbox];
        }
        
        else if (viewController == _picturesInbox) {
            destinationController = [self setupLongInbox];
        }
        
        else if (viewController == _fileInbox) {
            destinationController = [self setupPicturesInbox];
        }
        else if (viewController == _peopleInbox) {
            destinationController = [self setupFiles];
        }
        
        //        NSLog(@"destinationController Left=%@",destinationController);
        
        if (destinationController != nil){
            
            fromController = viewController;
            toController = destinationController;
            //debug
            if ([viewController.navigationController.viewControllers count]>=2) {
                viewController.navigationController.viewControllers = @[[viewController.navigationController.viewControllers objectAtIndex:0],[viewController.navigationController.viewControllers objectAtIndex:1],destinationController, viewController];
            } else if ([viewController.navigationController.viewControllers count]==1) {
                viewController.navigationController.viewControllers = @[[viewController.navigationController.viewControllers objectAtIndex:0],destinationController, viewController];
            } else {
                viewController.navigationController.viewControllers = @[destinationController, viewController];
            }
//            viewController.navigationController.viewControllers = @[[viewController.navigationController.viewControllers objectAtIndex:0],[viewController.navigationController.viewControllers objectAtIndex:1],destinationController, viewController];
            
//            NSLog(@"viewController = %@",viewController);
            
            //Modified by 3E ------END------
            
            [viewController.navigationController popViewControllerAnimated:NO];//debug
            
        }
    
//    }
//    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
//        [self transitionProgressedRight:NO recognizer:recognizer];
//        
//    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
//        [self transitionEndedRight:NO recognizer:recognizer];
//    }
    
}

- (MMessageListController *) setupInbox
{
    _inbox = [storyboard instantiateViewControllerWithIdentifier:@"MessageListController"];
    
//    [_inbox fetchedResultsController];
    
    return _inbox;
}

- (MMessageListController *) setupAllInbox
{
    _allinbox = [storyboard instantiateViewControllerWithIdentifier:@"MessageListController"];
    _allinbox.isAllInbox = YES;
    
    //    [_inbox fetchedResultsController];
    
    return _allinbox;
}


- (MMessageListController *) setupShortInbox
{
    _shortInbox = [storyboard instantiateViewControllerWithIdentifier:@"MessageListController"];
    _shortInbox.shortMode = YES;
//    [_shortInbox fetchedResultsController];
    
    return _shortInbox;
}

- (MMessageListController *) setupLongInbox
{
    
    _longInbox = [storyboard instantiateViewControllerWithIdentifier:@"MessageListController"];
    _longInbox.longMode = YES;
//    [_longInbox fetchedResultsController];
    
    return _longInbox;
}

- (MGalleryViewController *) setupPicturesInbox
{
    _picturesInbox = [storyboard instantiateViewControllerWithIdentifier:@"GalleryViewController"];

    return _picturesInbox;
}

- (MFileViewController *) setupFiles
{
    
//    if (isStart) {
//        if (_fileInbox == nil) {
//            _fileInbox = [storyboard instantiateViewControllerWithIdentifier:@"FileViewController"];
//        }
//    }
//    else{
    
        _fileInbox = [storyboard instantiateViewControllerWithIdentifier:@"FileViewController"];

//    }
    
    return _fileInbox;
}

- (MPeopleViewController *) setupPeople
{
    
//    if (isStart) {
//        if (_peopleInbox == nil) {
//            _peopleInbox = [storyboard instantiateViewControllerWithIdentifier:@"PeopleViewController"];
//        }
//
//    }
//    else{
    
        _peopleInbox = [storyboard instantiateViewControllerWithIdentifier:@"PeopleViewController"];
    
//    }
       return _peopleInbox;
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                          interactionControllerForAnimationController:(id <UIViewControllerAnimatedTransitioning>) animationController
{
    
//    NSLog(@"interactionControllerForAnimationController: %@", animationController);
    return (id <UIViewControllerInteractiveTransitioning>)animationController;
    
    //return nil;
    //interactiveTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
    //return interactiveTransition;
}

- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                   animationControllerForOperation:(UINavigationControllerOperation)operation
                                                fromViewController:(UIViewController *)fromVC
                                                  toViewController:(UIViewController *)toVC
{

    if ([controllers containsObject:toVC] && [controllers containsObject:fromVC]) {
        
        animator = [[MCyclingAnimator alloc] initWithParent:fromVC operation:operation];
        return animator;
        
    }
    else {
        
        return nil;
    }
}


@end
