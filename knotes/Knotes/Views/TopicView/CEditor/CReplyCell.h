//
//  CReplyCell.h
//  Knotable
//
//  Created by Dhruv on 3/23/15.
//
//

#import <UIKit/UIKit.h>
#import "CUtil.h"
#import "HybridDocument.h"
#import "DesignManager.h"
#import "ThreadItemManager.h"
#import "QuadCurveMenu.h"
#import "QuadCurveCustomDirector.h"
#import "UIImage+RoundedCorner.h"
#import "QuadCurveCustomMenuItemFactory.h"
#import "ContactManager.h"
#import "CTitleInfoBar.h"

@interface CReplyCell : UITableViewCell<QuadCurveMenuDelegate,CTitleInfoBarDelegate>
@property(strong,nonatomic)NSDictionary *gotReply;
@property(strong,nonatomic)UILabel *lbl_ReplyText;
@property(strong,nonatomic)UILabel *replyTime;
@property (nonatomic, strong) QuadCurveMenu *menu;
@property(nonatomic,strong)id<CTitleInfoBarDelegate> delegate;

//-(CGFloat)getHeightOfCell:(NSDictionary *)tempReply;
@end
