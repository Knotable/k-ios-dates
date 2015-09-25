//
//  CTitleInfoBar.h
//  Knotable
//
//  Created by backup on 13-12-27.
//
//

#import <UIKit/UIKit.h>
#import "GBPathImageView.h"
@class MessageEntity;
@class ContactsEntity;
@class QuadCurveMenu;

@protocol CTitleInfoBarDelegate <NSObject>

- (void) titleInfoClickeAtContact:(ContactsEntity *)entity;


@end

@interface CTitleInfoBar : UIView

@property (nonatomic, strong) MessageEntity* message;
@property (nonatomic, strong) QuadCurveMenu *menu;
@property (nonatomic, strong) UILabel* pName;
#if NEW_DESIGN
@property(nonatomic,strong)UILabel *lbl_Subject;
#else
@property (nonatomic, strong) UILabel* subLabel;
#endif
@property (nonatomic, strong) UILabel* pTime;
@property (nonatomic, strong) UIButton *pinButton;

@property (nonatomic, weak) id<CTitleInfoBarDelegate>delegate;

@end
