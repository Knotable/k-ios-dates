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

@protocol PadOwnerCellDelegate <NSObject>

-(void) CloseContactOwner;

@end

@class ContactsEntity;

//typedef void (^CommonCellBlock)(UITableViewCell*,btnOperatorTag);

@interface PadOwnerCell : UITableViewCell

@property (assign, nonatomic) BOOL editor;

@property(nonatomic, strong) GBPathImageView *imgView;

@property(nonatomic, strong) UILabel *lbTitle;
@property(nonatomic, strong) UILabel *lbDescription;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) ContactsEntity *contact;

@property (readwrite,weak) id<PadOwnerCellDelegate> targetDelegate;

- (void)setEditor:(BOOL)editor animate:(BOOL)animate;
- (void)setArchived:(BOOL)flag;
- (void)showActivity;
- (void)stopActivity;

- (IBAction)onCloseButton:(id)sender;

@end
