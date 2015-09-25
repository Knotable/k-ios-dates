//
//  MTutorialViewController.h
//  Mailer
//
//  Created by Mac 7 on 07/02/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTutorialViewController : UIViewController{
    
    IBOutlet UIScrollView *imageScroll;
    IBOutlet UIPageControl *scrollPageControl;
    IBOutlet UIView *backView;
    
}

@property (nonatomic,strong) NSArray *imageNameArray;

-(IBAction)backAction:(id)sender;

@end
