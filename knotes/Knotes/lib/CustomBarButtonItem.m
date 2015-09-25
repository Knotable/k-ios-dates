//
//  CustomBarButtonItem.m
//  Market
//
//  Created by backup on 13-7-31.
//  Copyright (c) 2013年 liwu. All rights reserved.
//

#import "CustomBarButtonItem.h"
@interface CustomBarButtonItem() {
}
@property (nonatomic, weak) id customTarget;
@property (nonatomic, strong) UIButton *customButton;
@end
@implementation CustomBarButtonItem
- (id)initWithImage:(UIImage *)image
      selectedImage:(UIImage *)selectedImage
             target:(id)target action:(SEL)action
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0.0f, 0.0f, image.size.width, image.size.height)];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [btn setImage:image forState:UIControlStateNormal];
    [btn setImage:selectedImage forState:UIControlStateHighlighted];
    
    /* Init method inherited from UIBarButtonItem */
    self = [[CustomBarButtonItem alloc] initWithCustomView:btn];
    
    if (self)
    {
        /* Assign ivars */
        _customButton = btn;
        _customImage = image;
        _customSelectedImage = selectedImage;
        _customTarget = target;
        _customAction = action;
    }
    
    return self;
}

+ (CustomBarButtonItem *)barItemWithImage:(UIImage*)image
                            selectedImage:(UIImage*)selectedImage
                                   target:(id)target
                                   action:(SEL)action
{
    return [[CustomBarButtonItem alloc] initWithImage:image
                                        selectedImage:selectedImage
                                               target:target
                                               action:action] ;
}

- (void)setCustomImage:(UIImage *)image
{
    _customImage = image;
    [_customButton setImage:image forState:UIControlStateNormal];
}

- (void)setCustomSelectedImage:(UIImage *)image
{
    _customSelectedImage = image;
    [_customButton setImage:image forState:UIControlStateHighlighted];
}

- (void)setCustomAction:(SEL)action
{
    _customAction = action;
    
    [_customButton removeTarget:nil
                        action:NULL
              forControlEvents:UIControlEventAllEvents];
    
    [_customButton addTarget:_customTarget
                     action:action
           forControlEvents:UIControlEventTouchUpInside];
}

@end
