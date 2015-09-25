//
//  MControllerManager.h
//  Mailer
//
//  Created by Martin Ceperley on 10/31/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMessageListController;
@class MGalleryViewController;
@class MCyclingAnimator;
@class MPeopleViewController;
@class MFileViewController;

@interface MControllerManager : NSObject <UINavigationControllerDelegate>
{
    @private
    UIStoryboard *storyboard;
    NSMutableArray *controllers;
    MCyclingAnimator *animator;
    UIPercentDrivenInteractiveTransition *interactiveTransition;
    
    UIViewController *fromController;
    UIViewController *toController;
    
    BOOL isStart;
    
    float swipeTransform;;
    
}

@property (nonatomic, readonly) MMessageListController *inbox;
@property (nonatomic, readonly) MMessageListController *allinbox;
@property (nonatomic, readonly) MMessageListController *shortInbox;
@property (nonatomic, readonly) MMessageListController *longInbox;
@property (nonatomic, readonly) MGalleryViewController *picturesInbox;
@property (nonatomic, readonly) MPeopleViewController *peopleInbox;
@property (nonatomic, readonly) MFileViewController *fileInbox;

+ (MControllerManager *)sharedManager;

- (void) goRightFrom:(UIViewController *)viewController recognizer:(UIScreenEdgePanGestureRecognizer *)recognizer;
- (void) goLeftFrom:(UIViewController *)viewController recognizer:(UIScreenEdgePanGestureRecognizer *)recognizer;

- (void) goPanRightFrom:(UIViewController *)viewController recognizer:(UIPanGestureRecognizer *)recognizer;
- (void) goPanLeftFrom:(UIViewController *)viewController recognizer:(UIPanGestureRecognizer *)recognizer;



- (void) showFirstControllerFrom:(UIViewController *)viewController;
- (void) showSecondControllerFrom:(UIViewController *)viewController;
- (void) showThirdControllerFrom:(UIViewController *)viewController;
- (void) showFourthControllerFrom:(UIViewController *)viewController;
- (void) showFifthControllerFrom:(UIViewController *)viewController;
- (void) showSixthControllerFrom:(UIViewController *)viewController;
- (void) showSeventhControllerFrom:(UIViewController *)viewController;
- (MMessageListController *) setupAllInbox;


@end
