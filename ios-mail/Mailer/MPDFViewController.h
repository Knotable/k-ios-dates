//
//  MPDFViewController.h
//  Mailer
//
//  Created by Mac 7 on 12/03/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPDFViewController : UIViewController{
    IBOutlet UIWebView *webVw;
}

@property(nonatomic,strong)NSURL  *urlStr;

-(IBAction)back:(id)sender;

@end
