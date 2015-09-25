//
//  MuteTableViewCell.h
//  Knotable
//
//  Created by backup on 8/27/14.
//
//

#import <UIKit/UIKit.h>
#import "MessageEntity.h"
@interface MuteTableViewCell : UITableViewCell
@property (nonatomic, strong) MessageEntity* message;
@property (nonatomic, strong) UIButton *unMuteBtn;
-(void)setMessage:(MessageEntity *)message withAnimate:(BOOL)animal;
@end
