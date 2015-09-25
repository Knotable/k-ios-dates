//
//  MSwipedButtonManager.h
//  Mailer
//
//  Created by wuli on 14-5-23.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MSwipedButtonManagerDelegate <NSObject>

- (void)swipedButtonPanChanged:(UIPanGestureRecognizer*)recognizer;
- (void)swipedButtonLongChanged:(UILongPressGestureRecognizer*)recognizer;

@end

@interface MSwipedButtonManager : NSObject
@property (nonatomic, weak) id <MSwipedButtonManagerDelegate> delegate;
@property (nonatomic, strong) UIImageView *swipeBut;

+ (MSwipedButtonManager *)sharedManager;
-(void)setHidden:(BOOL)flag;
-(void)setEnable:(BOOL)flag;

@end
