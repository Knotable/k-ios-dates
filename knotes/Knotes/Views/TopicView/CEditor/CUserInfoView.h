//
//  CUserInfoView.h
//  Knotable
//
//  Created by Agustin Guerra on 8/27/14.
//
//

#import <Foundation/Foundation.h>
#import "MessageEntity.h"

@interface CUserInfoView : UIView

@property (nonatomic, strong) UILabel *nameTextView;
//@property (nonatomic, strong) UILabel *usernameTextView;
@property (nonatomic, strong) UILabel *dateTextView;

@property (nonatomic, strong) MessageEntity *message;

@end
