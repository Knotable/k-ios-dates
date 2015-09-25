//
//  UIView+MailExtensions.h
//  Mailer
//
//  Created by Martin Ceperley on 10/22/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MailExtensions)

- (void) addVerticalFillContraint:(UIView *)constrainedView;
- (void) addHorizontalFillContraint:(UIView *)constrainedView;
- (void) addBothFillContraints:(UIView *)constrainedView;

- (void) attachToTop:(UIView *)constrainedView;
- (void) setHeight:(UIView *)constrainedView height:(CGFloat)height;

- (void) attachToLeft:(UIView *)constrainedView;
- (void) attachToRight:(UIView *)constrainedView;
- (void) setWidth:(UIView *)constrainedView width:(CGFloat)width;

- (void) makeWidthEqual:(UIView *)constrainedView;


@end
