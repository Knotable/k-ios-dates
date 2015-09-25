//
//  MSwipedButtonManager.m
//  Mailer
//
//  Created by wuli on 14-5-23.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import "MSwipedButtonManager.h"

@implementation MSwipedButtonManager

+ (MSwipedButtonManager *)sharedManager {
    static MSwipedButtonManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MSwipedButtonManager alloc] init];
    });
    return sharedInstance;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.swipeBut = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pen-icon.png"]];
        
        self.swipeBut.frame = CGRectMake(([[UIApplication sharedApplication] keyWindow].frame.size.width/2)-35, [[UIApplication sharedApplication] keyWindow].frame.size.height-100, 70, 70);
        self.swipeBut.userInteractionEnabled  = YES;
        //    swipeBut.layer.cornerRadius = 35.0f;
        //    swipeBut.layer.borderWidth = 1.0f;
        //    swipeBut.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:_swipeBut];
        
        UIPanGestureRecognizer *panGesture;
        panGesture = [[UIPanGestureRecognizer alloc]
                      initWithTarget:self action:@selector(handlePan:)];
        //    panGesture.delegate = viewController;
        [self.swipeBut addGestureRecognizer:panGesture];
        
        
        UILongPressGestureRecognizer *btn_LongPress_gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleBtnLongPressgesture:)];
        [btn_LongPress_gesture setMinimumPressDuration:.15];
        [self.swipeBut addGestureRecognizer:btn_LongPress_gesture];
    }
    return self;
}
#pragma mark - UIPanGesture

- (void) handlePan:(UIPanGestureRecognizer *)recognizer
{
    self.swipeBut.center = [recognizer locationInView:self.swipeBut.superview];
    if (self.delegate && [self.delegate respondsToSelector:@selector(swipedButtonPanChanged:)]) {
        [self.delegate swipedButtonPanChanged:recognizer];
    }
    switch (recognizer.state) {
        case UIGestureRecognizerStateChanged:
        {
        }
            break;
        case UIGestureRecognizerStateCancelled:
        {
            NSLog(@"may error?????????????????????");
        }
        case UIGestureRecognizerStateFailed:
        {
            NSLog(@"may error1?????????????????????");
        }
        case UIGestureRecognizerStateEnded:
        {
            [UIView beginAnimations:@"presentWithSuperview" context:nil];
            [UIView setAnimationDuration:0.3];
            
            self.swipeBut.frame = CGRectMake(([[UIApplication sharedApplication] keyWindow].frame.size.width/2)-35, [[UIApplication sharedApplication] keyWindow].frame.size.height-100, 70, 70);
            
            [UIView commitAnimations];
        }
        default:
            break;
    }
}
- (void)handleBtnLongPressgesture:(UILongPressGestureRecognizer *)recognizer{
    if (self.delegate && [self.delegate respondsToSelector:@selector(swipedButtonLongChanged:)]) {
        [self.delegate swipedButtonLongChanged:recognizer];
    }
#if 0
    if (!_isIndicating) {
        
        
        if (recognizer.state == UIGestureRecognizerStateBegan) {
            
            [self composeNewMessage];
            
            
        }
        
    }
#endif
}
-(void)setDelegate:(id<MSwipedButtonManagerDelegate>)delegate
{
    if (_delegate!= delegate) {
        _delegate = delegate;
    }
    if (delegate==nil) {
        [self setEnable:NO];
    } else {
        [self setEnable:YES];
    }
    
}
-(void)setHidden:(BOOL)flag
{
    self.swipeBut.hidden = flag;
    if (!flag && !self.swipeBut.superview) {
        [[[UIApplication sharedApplication] keyWindow] addSubview:_swipeBut];
    }
    self.swipeBut.frame = CGRectMake(([[UIApplication sharedApplication] keyWindow].frame.size.width/2)-35, [[UIApplication sharedApplication] keyWindow].frame.size.height-100, 70, 70);

}
-(void)setEnable:(BOOL)flag;
{
    self.swipeBut.userInteractionEnabled = flag;

}
@end
