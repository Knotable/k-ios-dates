//
//  MAccountViewCell.h
//  Mailer
//
//  Created by backup on 14-4-30.
//  Copyright (c) 2014年 Knotable. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCircleView.h"
@interface MAccountViewCell : UITableViewCell
@property (nonatomic, strong) UIImageView* imgView;

-(void)setNewEmailHidden:(BOOL)flag;
@end
