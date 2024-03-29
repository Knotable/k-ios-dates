//
//  WorkoutsCell.h
//  PerfectBody
//
//  Created by JYN on 8/12/13.
//  Copyright (c) 2013 jackiejin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GBPathImageView.h"
#import "TopicCell.h"
#import "ThreadCommon.h"
#import "UserEntity.h"
#import "ContactCell.h"



@class ContactsEntity;

@interface SharePeopleCell : UITableViewCell

@property (assign, nonatomic) BOOL editor;

@property(nonatomic, strong) GBPathImageView *imgView;

@property(nonatomic, strong) UILabel *lbTitle;
@property(nonatomic, strong) UILabel *lbDescription;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic, strong) ContactsEntity *contactItem;

@property (readwrite,weak) id<ContactCellDelegate> targetDelegate;

- (void)setEditor:(BOOL)editor animate:(BOOL)animate;
- (void)setArchived:(BOOL)flag;
- (void)showActivity;
- (void)stopActivity;

- (IBAction)onShowProfile:(id)sender;

@end
