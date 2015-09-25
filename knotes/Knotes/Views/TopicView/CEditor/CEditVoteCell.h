//
//  CEditVoteCell.h
//  RevealControllerProject
//
//  Created by backup on 13-11-8.
//
//

#import <UIKit/UIKit.h>
#import "CEditVoteInfo.h"
@class CEditVoteCell;
@protocol CEditVoteCellDelegate <NSObject>
- (void)checkSelected:(BOOL)flag withItem:(CEditVoteCell *)item;
- (void)addNewItemAtIndex:(NSInteger)index withContent:(NSString *)text;
- (void)removeVoteCellAtIndex:(NSInteger)index;
- (void)needShowMenu:(BOOL)flag;
@required
- (BOOL)canAddItem:(NSString *)text;
@end

@interface CEditVoteCell : UITableViewCell
@property (nonatomic) BOOL editor;
@property (nonatomic, assign) id<CEditVoteCellDelegate> voteDelegate;
@property (nonatomic, strong) NSTimer *holdTimer;
@property (nonatomic, retain) UITextField* tfVote;
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) NSString *contentText;
@property (nonatomic, copy) NSString *my_account_id;
@property (nonatomic, strong) NSArray *participators;
@property (nonatomic, retain) UIImage* checkedImage;
@property (nonatomic, retain) UIImage* uncheckedImage;
@property (nonatomic, retain) UIImage* checkedImage1;
@property (nonatomic, retain) UIImage* uncheckedImage1;
@property (nonatomic, retain) UIButton* checkBtn;
@property (nonatomic, retain) UIButton* addButton;
- (void)setInfo:(CEditVoteInfo*) info tableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)setAddable;
- (void)endEditText;
@end
