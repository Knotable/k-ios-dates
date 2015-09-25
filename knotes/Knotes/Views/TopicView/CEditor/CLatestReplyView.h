//
//  CLatestReplyView.h
//  Knotable
//
//  Created by Dhruv on 3/23/15.
//
//

#import <UIKit/UIKit.h>
#import "CItem.h"
#import "DesignManager.h"
#import "HybridDocument.h"
#import "CReplyCell.h"
#import "CReplyTextFieldCell.h"
#import "CreplyUtils.h"
#import "HIstoryCommentsCell.h"
@protocol CReplyViewDelegate <NSObject>
- (void) replyClickedOnItem:(CItem *)ReplyItem;
- (void) ShowAllReplies:(CItem *)ReplyItem;
@end
@interface CLatestReplyView : UIView<UITableViewDataSource,UITableViewDelegate,CReplyFieldDelegate>
@property(nonatomic,strong)UIButton *btn_Reply;
@property (nonatomic, strong) CItem *itemData;
@property(nonatomic,strong)UITableView *tblOfComments;
@property(nonatomic,strong)NSMutableArray *arrOfComments;
@property(nonatomic,strong)UITextField *instance;
@property(nonatomic,strong)id<CReplyViewDelegate,CReplyFieldDelegate,CTitleInfoBarDelegate>commentDelegate;
@end
