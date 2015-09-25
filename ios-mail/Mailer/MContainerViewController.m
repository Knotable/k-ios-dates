//
//  MContainerViewController.m
//  Mailer
//
//  Created by Mac 7 on 24/02/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import "MContainerViewController.h"

@interface MContainerViewController ()

@end

@implementation MContainerViewController

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
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
   
    if (height == 1024) {
        
         NSLog(@"width = %f",width);
        
        imgVw1.image = [UIImage imageNamed:@"inbox1_iPad.png"];
        imgVw2.image = [UIImage imageNamed:@"inbox2_iPad.png"];
        imgVw3.image = [UIImage imageNamed:@"inbox3_iPad.png"];
        imgVw4.image = [UIImage imageNamed:@"inbox4_iPad.png"];
        imgVw5.image = [UIImage imageNamed:@"inbox5_iPad.png"];
        
    }
    else if (height == 568){
        
//         NSLog(@"height iPhone5= %f",height);
        
        imgVw1.image = [UIImage imageNamed:@"inbox1_iPhone5.png"];
        imgVw2.image = [UIImage imageNamed:@"inbox2_iPhone5.png"];
        imgVw3.image = [UIImage imageNamed:@"inbox3_iPhone5.png"];
        imgVw4.image = [UIImage imageNamed:@"inbox4_iPhone5.png"];
        imgVw5.image = [UIImage imageNamed:@"inbox5_iPhone5.png"];
        
    }
    else{
        
//         NSLog(@"height iPhone= %f",height);
        
        imgVw1.image = [UIImage imageNamed:@"inbox1.png"];
        imgVw2.image = [UIImage imageNamed:@"inbox2.png"];
        imgVw3.image = [UIImage imageNamed:@"inbox3.png"];
        imgVw4.image = [UIImage imageNamed:@"inbox4.png"];
        imgVw5.image = [UIImage imageNamed:@"inbox5.png"];
        
    }
    
//    imgVw1,*imgVw2,*imgVw3,*imgVw4,*imgVw5
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
