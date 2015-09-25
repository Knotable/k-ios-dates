//
//  BaseKnoteCell.m
//  
//
//  Created by Martin Ceperley on 12/22/13.
//
//

#import "BaseKnoteCell.h"

#import "MessageEntity.h"
#import "ContactsEntity.h"
#import "TopicsEntity.h"

#import "DataManager.h"
#import "DesignManager.h"

#import "CUtil.h"
#import "QuadCurveMenu.h"

#import "GBPathImageView.h"
#import "CircleView.h"
#import "MCSwipeTableViewCell.h"

@interface BaseKnoteCell ()

@property (nonatomic, strong) UIView *headerLine;
@property (nonatomic, strong) CircleView *freshMessageIndicator;

@end

@implementation BaseKnoteCell

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
        
        _bodyView = [UIView new];
        [self.contentView addSubview:_bodyView];
        
        self.userInformationSemitransparentBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top-white-shadow"]];
        self.userInformationSemitransparentBackground.hidden = YES;
        [self.contentView addSubview:self.userInformationSemitransparentBackground];
        
        self.userInfoView = [[CUserInfoView alloc] init];
        [self.contentView addSubview:self.userInfoView];
        
        self.userPictureView = [[CUserPictureView alloc] init];
        [self.contentView addSubview:self.userPictureView];
        
        self.overlay = [UIView new];
        self.overlay.backgroundColor = [DesignManager editingBackgroundColor];
        self.overlay.hidden = NO;
        self.overlay.alpha = 0.0f;
        self.overlay.userInteractionEnabled = NO;
        [self.contentView addSubview:_overlay];
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.didSetupConstraints) return;
    
    [self.background mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView);
        make.left.equalTo(self.contentView).with.offset(5);
        make.right.equalTo(self.contentView).with.offset(-5);
    }];
    
    [self.userInformationSemitransparentBackground mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView);
        make.bottom.equalTo(self.userPictureView);
        make.left.and.right.equalTo(self.contentView);
    }];
    
    [self.overlay mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.background);
    }];
    
    if (self.headerOnTop) {
        [self.userPictureView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.background).offset(5);
            make.left.equalTo(self.background);
            make.width.equalTo(@69);
            make.height.equalTo(@69);
        }];
        
        [self.userInfoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.background).offset(5);
            make.left.equalTo(self.userPictureView.mas_right).offset(13);
            make.right.equalTo(self.background);
        }];
    } else {
        [self.userPictureView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.background);
            make.left.equalTo(self.background);
            make.width.equalTo(@69);
            make.height.equalTo(@69);
        }];
        
        [self.userInfoView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.userPictureView).offset(5);
            make.left.equalTo(self.userPictureView.mas_right).offset(13);
            make.right.equalTo(self.background);
        }];
    }
    
    [self.bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.headerOnTop) {
            make.top.equalTo(self.userInfoView.mas_bottom).offset(5);
        } else {
            make.top.equalTo(self.background).with.offset(       8.0);
        }
        make.bottom.equalTo(self.background).offset(-5);
        make.left.equalTo(self.userPictureView.mas_right).offset(13);
        make.right.equalTo(self.background);
    }];
    
    if (self.shouldHideHeader) {
        [self.header mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.background).with.offset(0.0);
            make.left.equalTo(self.background).with.offset(      0.0);
            make.height.equalTo(@0.0);
            make.width.equalTo(self.contentView);
        }];
        
        self.header.hidden = YES;
        
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
        
        [self.titleInfoBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.header.mas_top).offset(10.0);
#if NEW_DESIGN
            if ([self.titleInfoBar.pTime.text length]>0) {
                make.height.greaterThanOrEqualTo(@(90 + 100));
            } else {
                make.height.greaterThanOrEqualTo(@(90+13));
            }
            
            make.left.equalTo(self);
            make.right.equalTo(self);
#else
            [self.titleInfoBar mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.header.mas_top).offset(10.0);
                if ([self.titleInfoBar.subLabel.text length]>0) {
                    make.height.greaterThanOrEqualTo(@(kDefalutTitleBarH + 100));
                } else {
                    make.height.greaterThanOrEqualTo(@(kDefalutTitleBarH+13));
                }
                
                make.left.equalTo(self);
                make.right.equalTo(self);
            }];
            
#endif
        }];
    }
    self.didSetupConstraints = YES;
}

-(void)didDissapear
{
}

- (void)setMessage:(MessageEntity *)message
{
    _message = message;
    
    self.titleInfoBar.message = message;
    
    self.userPictureView.message = message;
    
    self.userInfoView.message = message;
    
    [glbAppdel.managedObjectContext lock];
    
    TopicsEntity *topic = [TopicsEntity MR_findFirstByAttribute:@"topic_id"
                                                      withValue:message.topic_id
                                                      inContext:glbAppdel.managedObjectContext];
    
    [glbAppdel.managedObjectContext unlock];
    
    if (topic)
    {
        self.topicLabel.text = topic.topic;
        self.topicLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
        
        if ([topic.isMute boolValue])
        {
            if (!message.muted)
            {
                message.muted = YES;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:HOT_KNOTES_DOWNLOADED_NOTIFICATION
                                                                    object:nil];
            }
        }
    }
}

- (void)setMaxWidth
{
    //No-op, should be overrideen by subclasses to set preferredMaxLayoutWidth of multi-line label
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
            
            for (UIView *subview in v.subviews)
            {
                if ([subview isKindOfClass:[UIImageView class]])
                {
                    //UIImageView *imgView = (UIImageView *)subview;
                }
            }
        }

        if (r >= 1 && view.subviews.count > 0) {
            [self examineSubviews:v recursions:r-1];
        }
        
    }

}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing: editing animated: YES];
    /*
    if (editing) {
        NSLog(@"Looking for reorder control");
        [self examineSubviews:self recursions:1];
    }
     */
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
    CGRect rect = [CUtil getTextRect:self.userInfoView.nameTextView.text Font:self.userInfoView.nameTextView.font Width:self.userInfoView.nameTextView.bounds.size.width];
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
                self.userInfoView.nameTextView.text = contactsStr;
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
