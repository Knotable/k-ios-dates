//
//  MInboxDetailViewController.m
//  Mailer
//
//  Created by Mac 7 on 28/03/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import "MInboxDetailViewController.h"

@interface MInboxDetailViewController ()

@end

@implementation MInboxDetailViewController

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
    
    self.navigationItem.title =  _titleStr;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
