//
//  UIView+TIToken.m
//  Mailer
//
//  Created by wuli on 14-5-12.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import "UIView+TIToken.h"


@implementation UIView (Private)

- (void)ti_setHeight:(CGFloat)height {
	
	CGRect newFrame = self.frame;
	newFrame.size.height = height;
	[self setFrame:newFrame];
}

- (void)ti_setWidth:(CGFloat)width {
	
	CGRect newFrame = self.frame;
	newFrame.size.width = width;
	[self setFrame:newFrame];
}

- (void)ti_setOriginY:(CGFloat)originY {
	
	CGRect newFrame = self.frame;
	newFrame.origin.y = originY;
	[self setFrame:newFrame];
}

@end