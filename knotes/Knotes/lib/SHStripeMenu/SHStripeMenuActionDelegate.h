//
//  SHStripeMenuActionDelegate.h
//  SHStripeMenu
//
//  Created by Narasimharaj on 08/05/13.
//  Copyright (c) 2013 SimHa. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef enum {
	SHStripeMenuLeft = 1,
	SHStripeMenuRight = 2,
} SHStripeMenuType;

@protocol SHStripeMenuActionDelegate <NSObject>

@required
- (void)stripeMenuItemSelected:(NSString *)menuName;
- (void)stripeMenuItemTaped:(NSString *)menuName;


@end
