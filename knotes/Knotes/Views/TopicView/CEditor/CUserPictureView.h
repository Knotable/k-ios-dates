//
//  CProfilePictureView.h
//  Knotable
//
//  Created by Agustin Guerra on 8/27/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GBPathImageView.h"

@class MessageEntity;
@class ContactsEntity;
@class QuadCurveMenu;

@protocol CUserPictureDelegate <NSObject>

- (void) titleInfoClickeAtContact:(ContactsEntity *)entity;

@end

@interface CUserPictureView : UIView

@property (nonatomic, strong) MessageEntity *message;
@property (nonatomic, strong) QuadCurveMenu *menu;
//@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, weak) id <CUserPictureDelegate>delegate;

@end
