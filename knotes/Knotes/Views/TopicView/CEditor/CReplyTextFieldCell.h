//
//  CReplyTextFieldCell.h
//  Knotable
//
//  Created by Dhruv on 3/23/15.
//
//

#import <UIKit/UIKit.h>
#import "CItem.h"
#import "ThreadItemManager.h"
#import "DesignManager.h"
@protocol CReplyFieldDelegate <NSObject>
-(void)ChangeOffsetAccordingToEdting:(CItem *)itm forTextField:(UITextField *)tefl;
-(void)ChangeOffsetAccordingToEndEdting:(CItem *)itm;
@end
@interface CReplyTextFieldCell : UITableViewCell<UITextFieldDelegate>
@property(strong,nonatomic)UITextField *txtPost;
@property(strong,nonatomic)UIButton *btn_Post;
@property(strong,nonatomic)CItem *itempost;
@property (nonatomic, strong) UIView *underLine;
@property(strong,nonatomic)id<CReplyFieldDelegate>deleGate;
@end
