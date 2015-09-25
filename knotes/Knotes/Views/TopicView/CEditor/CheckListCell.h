//
//  CheckListCell.h
//  RevealControllerProject
//
//  Created by backup on 13-12-3.
//
//

#import <UIKit/UIKit.h>
#import "CEditVoteInfo.h"

@class CheckListCell;

@protocol CheckListCellDelegate <NSObject>

- (void)checkSelected:(BOOL)flag withItem:(CheckListCell *)item;
- (BOOL)addNewItemAtIndex:(NSInteger)index withContent:(NSString *)text;
- (void)removeVoteCellAtIndex:(NSInteger)index;
- (void)itemBeginEditing:(CheckListCell *)obj;

@required

- (BOOL)canAddItem:(NSString *)text;

@end

@interface CheckListCell : UITableViewCell
@property (nonatomic) BOOL editor;
@property (nonatomic, assign) id<CheckListCellDelegate> delegate;
@property (nonatomic, strong) UITextField *inputText;
@property (nonatomic, strong) CEditVoteInfo *info;
@property (nonatomic) NSInteger index;

- (void)setAddable:(BOOL)flag;
- (void)endEditText;
@end
