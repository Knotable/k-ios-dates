//
//  MPDFViewController.m
//  Mailer
//
//  Created by Mac 7 on 12/03/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import "MPDFViewController.h"

@interface MPDFViewController ()

@end

@implementation MPDFViewController

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
    
    
    webVw.scalesPageToFit = YES;

    NSURLRequest *request = [NSURLRequest requestWithURL:_urlStr];
    [webVw loadRequest:request];

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(IBAction)back:(id)sender{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

@end
