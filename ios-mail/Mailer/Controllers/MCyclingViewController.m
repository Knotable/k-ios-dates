//
//  MCyclingViewController.m
//  Mailer
//
//  Created by Martin Ceperley on 10/31/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MCyclingViewController.h"
#import "MControllerManager.h"

@interface MCyclingViewController ()

@end

@implementation MCyclingViewController

+ (void)setupCyclingOn:(UIViewController *)viewController
{
    
//    NSLog(@"setupCyclingOn: %@", viewController);
    viewController.navigationItem.hidesBackButton = YES;
//    NSLog(@"interactivePopGestureRecognizer %@", viewController.navigationController.interactivePopGestureRecognizer);
    
//    UIScreenEdgePanGestureRecognizer *changeRightRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:viewController action:@selector(cycleRight:)];
//    changeRightRecognizer.edges = UIRectEdgeRight;
//    [viewController.view addGestureRecognizer:changeRightRecognizer];
//    
//    UIScreenEdgePanGestureRecognizer *changeLeftRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:viewController action:@selector(cycleLeft:)];
//    changeLeftRecognizer.edges = UIRectEdgeLeft;
//    [viewController.view addGestureRecognizer:changeLeftRecognizer];
    
    
    
//    UIPanGestureRecognizer *panGesture;
//    panGesture = [[UIPanGestureRecognizer alloc]
//           initWithTarget:viewController action:@selector(handlePan:)];
////    panGesture.delegate = viewController;
//    [view addGestureRecognizer:panGesture];
    
}

+ (void)panRightFrom:(UIViewController *)viewController recognizer:(UIPanGestureRecognizer *)recognizer
{
    [[MControllerManager sharedManager] goPanRightFrom:viewController recognizer:recognizer];
}

+ (void)panLeftFrom:(UIViewController *)viewController recognizer:(UIPanGestureRecognizer *)recognizer
{
    [[MControllerManager sharedManager] goPanLeftFrom:viewController recognizer:recognizer];
}

+ (void)cycleRightFrom:(UIViewController *)viewController recognizer:(UIScreenEdgePanGestureRecognizer *)recognizer
{
    /*
    //NSLog(@"cycleRight state: %d", (int)recognizer.state);
    //NSLog(@"cycleRight location: %@", NSStringFromCGPoint([recognizer locationInView:viewController.view]));
    //NSLog(@"cycleRight velocity: %@", NSStringFromCGPoint([recognizer velocityInView:viewController.view]));

     */
    
    [[MControllerManager sharedManager] goRightFrom:viewController recognizer:recognizer];
}

+ (void)cycleLeftFrom:(UIViewController *)viewController recognizer:(UIScreenEdgePanGestureRecognizer *)recognizer
{
    [[MControllerManager sharedManager] goLeftFrom:viewController recognizer:recognizer];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [MCyclingViewController setupCyclingOn:self];
}

- (void) cycleRight:(UIScreenEdgePanGestureRecognizer *)recognizer
{
    [MCyclingViewController cycleRightFrom:self recognizer:recognizer];
}

- (void) cycleLeft:(UIScreenEdgePanGestureRecognizer *)recognizer
{
    [MCyclingViewController cycleLeftFrom:self recognizer:recognizer];
}

- (void) handlePan:(UIPanGestureRecognizer *)recognizer
{
    [MCyclingViewController panRightFrom:self recognizer:recognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
