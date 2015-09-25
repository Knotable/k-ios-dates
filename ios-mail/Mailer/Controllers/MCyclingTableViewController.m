//
//  MCyclingTableViewController.m
//  Mailer
//
//  Created by Martin Ceperley on 10/31/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MCyclingTableViewController.h"
#import "MCyclingViewController.h"

@interface MCyclingTableViewController ()

@end

@implementation MCyclingTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
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
