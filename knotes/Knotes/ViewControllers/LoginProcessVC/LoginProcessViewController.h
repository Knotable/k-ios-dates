//
//  LoginProcessViewController.h
//  Knotable
//
//  Created by wuli on 8/29/14.
//
//

#import <UIKit/UIKit.h>

@interface LoginProcessViewController : UIViewController

@property (nonatomic, readonly) BOOL isAnimating;

- (void)stopAnimation;
- (void)dismiss;

@property (assign, atomic) NSInteger        vcTag;

@end
