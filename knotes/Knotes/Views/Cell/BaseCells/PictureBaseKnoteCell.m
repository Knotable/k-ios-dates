//
//  BaseKnoteCell.m
//  
//
//  Created by Martin Ceperley on 12/22/13.
//
//

#import "PictureBaseKnoteCell.h"

#import "CUtil.h"
#import "QuadCurveMenu.h"

#import "MessageEntity.h"
#import "ContactsEntity.h"
#import "TopicsEntity.h"
#import "DesignManager.h"

#import "CircleView.h"
#import "MCSwipeTableViewCell.h"

@interface PictureBaseKnoteCell ()

@property (nonatomic, strong) UIView *headerLine;
@property (nonatomic, strong) CircleView *freshMessageIndicator;
@property (nonatomic, strong) UIView *underLine;

@end
@implementation PictureBaseKnoteCell

- (id)init
{
    NSString *reuseID = NSStringFromClass([self class]);
    
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseID];
    
    if (self)
    {
        self.shouldHideHeader = NO;
        self.headerOnTop = YES;

        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        _background = [[UIView alloc] initWithFrame:CGRectZero];
        _background.backgroundColor = [[DesignManager knoteBackgroundColor] colorWithAlphaComponent:[DesignManager knoteBackgroundOpacity]];
        _background.layer.cornerRadius = [DesignManager knoteCornerRadius];
        
        [self.contentView addSubview:_background];
        
        _header = [[UIView alloc] initWithFrame:CGRectZero];
        _header.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_header];
        
        _headerLine = [UIView new];
        _headerLine.backgroundColor = [UIColor whiteColor];
        
        _topicLabel = [UILabel new];
        _topicLabel.font = [DesignManager knoteSmallHeaderFont];
        _topicLabel.textColor = [DesignManager knoteHeaderTextColor];
        _topicLabel.textAlignment = NSTextAlignmentLeft;
        [self.header addSubview:_topicLabel];
        
        self.titleInfoBar = [[CTitleInfoBar alloc] init];
        [self.header addSubview:self.titleInfoBar];
        
        _bodyView = [UIView new];
        _bodyView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_bodyView];
        
        self.overlay = [UIView new];
        self.overlay.backgroundColor = [DesignManager editingBackgroundColor];
        self.overlay.hidden = NO;
        self.overlay.alpha = 0.0f;
        self.overlay.userInteractionEnabled = NO;
        [self.contentView addSubview:_overlay];
        
        self.underLine = [[UIView alloc] init];
        self.underLine.backgroundColor = kSeperatorColorClear;
        [self.contentView addSubview:self.underLine];
        [self.contentView sendSubviewToBack:self.underLine];

    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.didSetupConstraints) return;

    [self.background mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).with.offset(       0.0);
        make.left.equalTo(self.contentView).with.offset(      8.0);
        make.right.equalTo(self.contentView).with.offset(     -8.0);
        make.bottom.equalTo(self.contentView).with.offset(    -8.0);
    }];
    
    [self.overlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.background);
    }];
    
    [self.bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.headerOnTop) {
            make.top.equalTo(self.header.mas_bottom).with.offset(       8.0);
        } else {
            make.top.equalTo(self.background).with.offset(       8.0);
        }
        make.bottom.equalTo(self.background).with.offset(    -16.0);
        make.left.equalTo(self.background).with.offset(13.0);
        make.right.equalTo(self.background).with.offset(-13.0);
    }];
    
    if (self.shouldHideHeader) {
        [self.header mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.background).with.offset(0.0);
            make.left.equalTo(self.background).with.offset(      0.0);
            make.height.equalTo(@0.0);
            make.width.equalTo(self.contentView);
        }];
        
        self.header.hidden = YES;
        self.headerLine.hidden = YES;
        self.titleInfoBar.hidden = YES;
        self.freshMessageIndicator.hidden = YES;
        
    }
    else
    {
        [self.header mas_makeConstraints:^(MASConstraintMaker *make) {
            if (self.headerOnTop) {
                make.top.equalTo(self.background).with.offset(0.0);
            } else {
                make.bottom.equalTo(self.background).with.offset(0.0);
            }
            
            make.left.equalTo(self.background).with.offset(      0.0);
            make.right.equalTo(self.background).with.offset(     0.0);
        }];
       
        [self.topicLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleInfoBar.mas_bottom).with.offset(4.0);
            make.left.equalTo(self).offset(kTheadLeftGap);
            make.right.equalTo(self.titleInfoBar.mas_right).with.offset(-2.0);

            make.bottom.lessThanOrEqualTo(self.header.mas_bottom).with.offset(.0);
            
        }];
       

        [self.freshMessageIndicator mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.titleInfoBar.menu.mainMenuButton.mas_right).offset(3);
            make.left.equalTo(self.titleInfoBar.menu.mainMenuButton.mas_left).offset(-3);
            make.top.equalTo(self.titleInfoBar.menu.mainMenuButton.mas_top).offset(-3);
            make.bottom.equalTo(self.titleInfoBar.menu.mainMenuButton.mas_bottom).offset(3);
        }];
        
        [self.titleInfoBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.header.mas_top).offset(10.0);
#if NEW_DESIGN
            if ([self.titleInfoBar.pTime.text length]>0) {
                make.height.greaterThanOrEqualTo(@(90));
            } else {
                make.height.greaterThanOrEqualTo(@(90+13));
            }
#else
            if ([self.titleInfoBar.subLabel.text length]>0) {
                make.height.greaterThanOrEqualTo(@(kDefalutTitleBarH));
            } else {
                make.height.greaterThanOrEqualTo(@(kDefalutTitleBarH+13));
            }
#endif
            
            make.left.equalTo(self);
            make.right.equalTo(self);
        }];
        
    }
    self.didSetupConstraints = YES;
}

- (void)setMessage:(MessageEntity *)message
{
    _message = message;
    
    self.titleInfoBar.message = message;
    
    TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id" withValue:message.topic_id];
    
    if (topic)
    {
        self.topicLabel.text = topic.topic;
        if (message.has_viewed == kViewedNO) {
            self.topicLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16]/*[UIFont boldSystemFontOfSize:16]*/;
        } else {
            self.topicLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16]/*[UIFont systemFontOfSize:16]*/;
        }
    }
}

- (void)setMaxWidth
{
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)beganEditing
{
    //No-op, override in subclass
}

- (void)wasEdited
{
    //No-op, override in subclass
}

- (void)finishedEditing
{
    //No-op, override in subclass
}

-(void)examineSubviews:(UIView *)view recursions:(int)r
{
    for (UIView * v in view.subviews)
    {
        NSString *classname = NSStringFromClass([v class]);

        if ([classname rangeOfString: @"Reorder"].location != NSNotFound)
        {
            NSLog(@"FOUND REORDER!!: %@", v);
            NSLog(@"Is ImageView?: %d", [v isKindOfClass: [UIImageView class]]);
            NSLog(@"Is UIControl?: %d", [v isKindOfClass: [UIControl class]]);
            NSLog(@"Is UIButton?: %d", [v isKindOfClass: [UIButton class]]);
            
            NSLog(@"Parent: %@", v.superview);
            NSLog(@"Grandparent: %@", v.superview.superview);
            NSLog(@"Subviews: %@", v.subviews);
            
            NSLog(@"Constraints: %@", v.constraints);
            NSLog(@"Parent Constraints: %@", v.superview.constraints);

        }

        if (r >= 1 && view.subviews.count > 0) {
            [self examineSubviews:v recursions:r-1];
        }
        
    }

}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing: editing animated: YES];
}


- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    //NSLog(@"setHighlighted: %d animated %d", highlighted, animated);
    if (highlighted) {
        self.background.backgroundColor = [[DesignManager knoteBackgroundColor] colorWithAlphaComponent:[DesignManager knoteHighlightedBackgroundOpacity]];
    } else {
        self.background.backgroundColor = [[DesignManager knoteBackgroundColor] colorWithAlphaComponent:[DesignManager knoteBackgroundOpacity]];
    }
    
}

- (void)willAppear
{
    CGRect rect = [CUtil getTextRect:self.titleInfoBar.pName.text Font:self.titleInfoBar.pName.font Width:self.titleInfoBar.bounds.size.width];
    if (rect.size.height>self.titleInfoBar.bounds.size.height) {
        NSMutableString *contactsStr = nil;
        NSArray *editors = nil;
        if (self.message.editors) {
            editors = [NSKeyedUnarchiver unarchiveObjectWithData:self.message.editors];
            if ([editors count]>1) {
                NSDictionary *dic = [editors firstObject];
                ContactsEntity *contact = [ContactsEntity MR_findFirstByAttribute:@"email" withValue:dic[@"email"]];
                contactsStr = [contact.name mutableCopy];
                [contactsStr appendFormat:@" and %d others", (int)([editors count]-1)];
                self.titleInfoBar.pName.text = contactsStr;
            }
        }
    }
}

- (void)showOverlay:(BOOL)showing animate:(BOOL)animate
{
    [UIView animateWithDuration:(animate) ? 0.6 : 0.
                          delay:0.
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         CGRect frame =CGRectMake(0,
                                  0,
                                  self.bounds.size.width,
                                  self.bounds.size.height);
         if (showing) {
             self.overlay.alpha = 1.f;
         } else {
             frame = CGRectMake(self.bounds.size.width,
                                0,
                                self.bounds.size.width,
                                self.bounds.size.height);
             self.overlay.alpha = 0.f;
         }
         
         self.overlay.frame = frame;
     } completion:^(BOOL finished) {
         self.overlay.userInteractionEnabled = showing;
     }];

}

@end
