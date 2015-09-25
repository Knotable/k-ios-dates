//
//  MMailHeaderIndicateView.h
//  Mailer
//
//  Created by wuli on 14-6-4.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AccountInfo.h"
@interface MMailHeaderIndicateView : UIView
@property (nonatomic, strong) UIButton *indicateButton;
@property (nonatomic, strong)  AccountInfo *actInfo ;
@end
