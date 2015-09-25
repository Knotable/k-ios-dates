//
//  CWDiscussDecideView.m
//  Knotable
//
//  Created by Donald Pae on 2/24/14.
//
//

#import "CWDiscussDecideView.h"
#import "CUtil.h"

#define kDiscussOffsetFromTop   110
#define kTitleInterval          90
#define kTitleHeight            30
#define kAvatarSize             30

@interface CWDiscussDecideView ()

@property (nonatomic, retain) UILabel *lblTitle1;
@property (nonatomic, retain) UILabel *lblTitle2;
@property (nonatomic, retain) UILabel *lblTitle3;
@property (nonatomic, retain) UIImageView *avatar1;
@property (nonatomic, retain) UIImageView *avatar2;
@property (nonatomic, retain) UIImageView *avatar3;

@end

@implementation CWDiscussDecideView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        
        self.lblTitle1 = [[UILabel alloc] init];
        [self.lblTitle1 setTextAlignment:NSTextAlignmentCenter];
        [self.lblTitle1 setBackgroundColor:[UIColor clearColor]];
        [self.lblTitle1 setTextColor:kWelcomeTitleColor];
        [self.lblTitle1 setFont:kWelcomeTitleFont];
        [self.lblTitle1 setText:@"Discuss"];
        
        [self addSubview:self.lblTitle1];
        
        self.lblTitle2 = [[UILabel alloc] init];
        [self.lblTitle2 setTextAlignment:NSTextAlignmentCenter];
        [self.lblTitle2 setBackgroundColor:[UIColor clearColor]];
        [self.lblTitle2 setTextColor:kWelcomeTitleColor];
        [self.lblTitle2 setFont:kWelcomeTitleFont];
        [self.lblTitle2 setText:@"&"];
        
        [self addSubview:self.lblTitle2];
        
        self.lblTitle3 = [[UILabel alloc] init];
        [self.lblTitle3 setTextAlignment:NSTextAlignmentCenter];
        [self.lblTitle3 setBackgroundColor:[UIColor clearColor]];
        [self.lblTitle3 setTextColor:kWelcomeTitleColor];
        [self.lblTitle3 setFont:kWelcomeTitleFont];
        [self.lblTitle3 setText:@"Decide"];
        
        [self addSubview:self.lblTitle3];
        
        self.avatar1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar1"]];
        [self addSubview:self.avatar1];
        
        self.avatar2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar2"]];
        [self addSubview:self.avatar2];
        
        self.avatar3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar3"]];
        [self addSubview:self.avatar3];
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.lblTitle1)
        [self.lblTitle1 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@kDiscussOffsetFromTop);
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.height.equalTo(@kTitleHeight);
        }];
    
    [self.lblTitle2 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lblTitle1.mas_top).offset(kTitleInterval);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@kTitleHeight);
    }];
    
    [self.lblTitle3 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lblTitle2).offset(kTitleInterval);
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.height.equalTo(@kTitleHeight);
    }];
    
    [self.avatar1 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lblTitle1.mas_top).offset(-50);
        make.right.equalTo(self.mas_right).offset(-100);
        make.width.equalTo(@kAvatarSize);
        make.height.equalTo(@kAvatarSize);
    }];
    [self.avatar2 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lblTitle2.mas_top);
        make.left.equalTo(self.mas_left).offset(50);
        make.width.equalTo(@kAvatarSize);
        make.height.equalTo(@kAvatarSize);
    }];
    [self.avatar3 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lblTitle3.mas_top).offset(50);
        make.left.equalTo(self.mas_left).offset(80);
        make.width.equalTo(@kAvatarSize);
        make.height.equalTo(@kAvatarSize);
    }];
   
}

@end
