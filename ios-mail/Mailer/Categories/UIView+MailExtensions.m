//
//  UIView+MailExtensions.m
//  Mailer
//
//  Created by Martin Ceperley on 10/22/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "UIView+MailExtensions.h"

@implementation UIView (MailExtensions)

- (void) addFillConstraints:(UIView *)constrainedView horizontal:(BOOL)horizontal vertical:(BOOL)vertical
{
    NSMutableArray* constraints = [[NSMutableArray alloc] init];
    NSMutableArray* aspects = [[NSMutableArray alloc] init];
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(constrainedView);
    if (horizontal) [aspects addObject:@"H"];
    if (vertical) [aspects addObject:@"V"];
    
    for (NSString* aspect in aspects) {
        NSString* format = [NSString stringWithFormat:@"%@:|-0-[constrainedView]-0-|", aspect];
        [constraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:format
                                                                       options:0
                                                                       metrics:0
                                                                         views:viewsDictionary]];
    }
    [self addConstraints:constraints];
}
- (void) addVerticalFillContraint:(UIView *)constrainedView
{
    [self addFillConstraints:constrainedView horizontal:NO vertical:YES];
}
- (void) addHorizontalFillContraint:(UIView *)constrainedView
{
    [self addFillConstraints:constrainedView horizontal:YES vertical:NO];
}
- (void) addBothFillContraints:(UIView *)constrainedView
{
    [self addFillConstraints:constrainedView horizontal:YES vertical:YES];
}

- (void) attachToTop:(UIView *)constrainedView
{
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(constrainedView);
    NSString* format = [NSString stringWithFormat:@"V:|-0-[constrainedView]"];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:0 views:viewsDictionary]];

}
- (void) setHeight:(UIView *)constrainedView height:(CGFloat)height
{
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(constrainedView);
    NSString* format = [NSString stringWithFormat:@"V:[constrainedView(==%f)]", height];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:0 views:viewsDictionary]];
}

- (void) attachToLeft:(UIView *)constrainedView
{
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(constrainedView);
    NSString* format = [NSString stringWithFormat:@"H:|-0-[constrainedView]"];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:0 views:viewsDictionary]];
    
}
- (void) attachToRight:(UIView *)constrainedView
{
    NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(constrainedView);
    NSString* format = [NSString stringWithFormat:@"H:[constrainedView]-0-|"];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:0 views:viewsDictionary]];
    
}

- (void) setWidth:(UIView *)constrainedView width:(CGFloat)width
{
    //NSDictionary* viewsDictionary = NSDictionaryOfVariableBindings(constrainedView);
    //NSString* format = [NSString stringWithFormat:@"H:[constrainedView(==%f)]", width];
    //[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:0 views:viewsDictionary]];
    [self addConstraint:[NSLayoutConstraint constraintWithItem:constrainedView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:nil
                                                     attribute:0
                                                    multiplier:1.0
                                                      constant:0]];

}

- (void) makeWidthEqual:(UIView *)constrainedView
{
    [self addConstraint:[NSLayoutConstraint constraintWithItem:constrainedView
                                                            attribute:NSLayoutAttributeWidth
                                                            relatedBy:NSLayoutRelationEqual
                                                               toItem:self
                                                            attribute:NSLayoutAttributeWidth
                                                           multiplier:1.0
                                                             constant:0]];

}


@end
