//
//  MCyclingCollectionViewController.m
//  Mailer
//
//  Created by Martin Ceperley on 10/31/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MCyclingCollectionViewController.h"
#import "MCyclingViewController.h"

@interface MCyclingCollectionViewController ()

@end

@implementation MCyclingCollectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [MCyclingViewController setupCyclingOn:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void) cycleRight:(UIScreenEdgePanGestureRecognizer *)recognizer
{
    [MCyclingViewController cycleRightFrom:self recognizer:recognizer];
}

- (void) cycleLeft:(UIScreenEdgePanGestureRecognizer *)recognizer
{
    [MCyclingViewController cycleLeftFrom:self recognizer:recognizer];
}

- (void)handlePan:(UIPanGestureRecognizer *)recognizer
{
    
    [MCyclingViewController panRightFrom:self recognizer:recognizer];
    
}

@end
