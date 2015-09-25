//
//  SHStripeMenuExecuter.h
//  SHStripeMenu
//
//  Created by Narasimharaj on 08/05/13.
//  Copyright (c) 2013 SimHa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SHStripeMenuActionDelegate.h"

@interface SHStripeMenuExecuter : NSObject
@property (nonatomic, assign) SHStripeMenuType menuType;
@property (nonatomic, assign) CGFloat startY;
@property (nonatomic, strong) NSMutableArray *menuItems;
@property (nonatomic, weak) id <SHStripeMenuActionDelegate>delegate;
@property (nonatomic, strong) UIView *lineView;

- (void)setupToParentView:(UIViewController *)rootViewController;
- (void)refreshView;
- (void)hideStripeMenu;
@end