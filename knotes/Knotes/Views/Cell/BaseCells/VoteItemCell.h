//
//  VoteItemCell.h
//  Knotable
//
//  Created by wuli on 14-6-30.
//
//

#import <UIKit/UIKit.h>
#import "ThreadCommon.h"

@interface VoteItemCell : UITableViewCell
@property (nonatomic) BOOL editor;
@property (nonatomic, strong) NSTimer *holdTimer;
@property (nonatomic, retain) UITextField* tfVote;
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) NSString *contentText;
@property (nonatomic, copy) NSString *my_account_id;
@property (nonatomic, strong) NSArray *participators;
@property (nonatomic, assign) CItemType type;
@property (nonatomic, retain) UIImage* checkedImage;
@property (nonatomic, retain) UIImage* uncheckedImage;
@property (nonatomic, retain) UIImage* checkedImage1;
@property (nonatomic, retain) UIImage* uncheckedImage1;
@property (nonatomic, retain) UIButton* checkBtn;
- (void)setInfo:(NSDictionary*) info tableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath;
@end
