//
//  SHStripeMenuViewController.h
//  SHStripeMenu
//
//  Created by Narasimharaj on 26/04/13.
//  Copyright (c) 2013 SimHa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SHMenuItem.h"
#import "SHStripeMenuActionDelegate.h"

#define ROW_HEIGHT		56
#define SLIDE_TIMING	.25

@protocol SHStripeMenuDelegate <NSObject>

@required
- (void)itemSelected:(SHMenuItem *)item;
- (void)itemTaped:(SHMenuItem *)item;
- (void)hideMenu;

@end

@interface SHStripeMenuViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *menuItems;
@property (nonatomic, assign) SHStripeMenuType menuType;
@property (nonatomic, assign) CGFloat menuWidth;
@property (nonatomic, assign) id <SHStripeMenuDelegate> delegate;
- (void)setTableView;
- (void)setupMenuItems;
- (CGFloat)getTableHeight;
- (CGFloat)getViewHeight;
@end
