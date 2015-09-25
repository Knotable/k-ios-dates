//
//  TITokenFieldDelegate.h
//  Mailer
//
//  Created by wuli on 14-5-12.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TITokenField;
@protocol TITokenFieldDelegate <UITextFieldDelegate>
@optional
- (void)tokenFieldWillResize:(TITokenField *)tokenField animated:(BOOL)animated;
- (void)tokenFieldDidResize:(TITokenField *)tokenField animated:(BOOL)animated;
@end

