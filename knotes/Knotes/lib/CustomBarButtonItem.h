//
//  CustomBarButtonItem.h
//  Market
//
//  Created by backup on 13-7-31.
//  Copyright (c) 2013年 liwu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomBarButtonItem : UIBarButtonItem
{
}
@property (nonatomic, strong) UIImage *customImage;
@property (nonatomic, strong) UIImage *customSelectedImage;
@property (nonatomic, assign) SEL customAction;
+ (CustomBarButtonItem *)barItemWithImage:(UIImage*)image
                        selectedImage:(UIImage*)selectedImage
                               target:(id)target
                               action:(SEL)action;

- (void)setCustomImage:(UIImage *)image;
- (void)setCustomSelectedImage:(UIImage *)image;

- (void)setCustomAction:(SEL)action;
@end
