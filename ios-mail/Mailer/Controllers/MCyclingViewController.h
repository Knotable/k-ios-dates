//
//  MCyclingViewController.h
//  Mailer
//
//  Created by Martin Ceperley on 10/31/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MCyclingViewController : UIViewController{
    
}

+ (void)setupCyclingOn:(UIViewController *)viewController;

+ (void)cycleRightFrom:(UIViewController *)viewController recognizer:(UIScreenEdgePanGestureRecognizer *)recognizer;
+ (void)cycleLeftFrom:(UIViewController *)viewController recognizer:(UIScreenEdgePanGestureRecognizer *)recognizer;

+ (void)panRightFrom:(UIViewController *)viewController recognizer:(UIPanGestureRecognizer *)recognizer;
+ (void)panLeftFrom:(UIViewController *)viewController recognizer:(UIPanGestureRecognizer *)recognizer;



@end
