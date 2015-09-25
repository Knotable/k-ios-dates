//
//  MModePickerViewController.m
//  Mailer
//
//  Created by Martin Ceperley on 10/17/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MModePickerViewController.h"
#import "MMessageListController.h"

@interface MModePickerViewController ()

@end

@implementation MModePickerViewController

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
	// Do any additional setup after loading the view.
    self.navigationItem.hidesBackButton = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@"prepareForSegue: %@", segue.identifier);
    
    if ([[segue identifier] isEqualToString:@"shortMode"]) {
        [(MMessageListController *)[segue destinationViewController] setShortMode:YES];
    }
}

@end
