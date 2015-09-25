//
//  SHMenuItem.h
//  SHStripeMenu
//
//  Created by Narasimharaj on 26/04/13.
//  Copyright (c) 2013 SimHa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SHMenuItem : NSObject

@property (nonatomic, copy) NSString	*name;
@property (nonatomic, copy) NSString	*email;
@property (nonatomic, copy) UIImage		*image;

+ (SHMenuItem *)initWithName:(NSString *)name Email:(NSString *)email andImage:(UIImage *)image;
- (SHMenuItem *)initWithName:(NSString *)name Email:(NSString *)email andImage:(UIImage *)image;
@end