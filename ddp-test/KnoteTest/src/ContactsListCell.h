//
//  ContactsListCell.h
//  Example
//
//  Created by wuli on 2/9/15.
//  Copyright (c) 2015 smart4c. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"
@interface ContactsListCell : UITableViewCell
@property (nonatomic, strong) UIImageView *imageView0;
@property (nonatomic, strong) UIImageView *imageView1;
@property (nonatomic, strong) UIImageView *imageView2;
@property (nonatomic, strong) UIImageView *imageView3;
@property (nonatomic, strong) UIImageView *imageView4;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *fullNameLabel;
@property (nonatomic, strong) UILabel *emailLabel;
@property (nonatomic, strong) NSDictionary *contentDic;
@end
