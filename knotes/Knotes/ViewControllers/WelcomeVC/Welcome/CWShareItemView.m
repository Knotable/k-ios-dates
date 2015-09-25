//
//  CWShareItemView.m
//  Knotable
//
//  Created by Donald Pae on 2/24/14.
//
//

#import "CWShareItemView.h"
#import "CUtil.h"

#define kAvatarSize     40
#define kSocialSize     30
#define kAvatarOffsetFromCenter     -130
#define kSocialOffsetFromCenter     50

@interface CWShareItemView ()

@property (nonatomic, retain) UILabel *lblTitle;
@property (nonatomic, retain) UIImageView *imgAvatar1;
@property (nonatomic, retain) UIImageView *imgAvatar2;
@property (nonatomic, retain) UIImageView *imgAvatar3;
@property (nonatomic, retain) UIImageView *imgAvatar4;

@property (nonatomic, retain) UIImageView *imgSocialFacebook;
@property (nonatomic, retain) UIImageView *imgSocialGoogleplus;
@property (nonatomic, retain) UIImageView *imgSocialTwitter;

@end

@implementation CWShareItemView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        
        self.lblTitle = [[UILabel alloc] init];
        [self.lblTitle setTextAlignment:NSTextAlignmentCenter];
        [self.lblTitle setBackgroundColor:[UIColor clearColor]];
        [self.lblTitle setTextColor:kWelcomeTitleColor];
        [self.lblTitle setFont:kWelcomeTitleFont];
        [self.lblTitle setText:@"Share Them"];
        
        [self addSubview:self.lblTitle];
        
        self.imgAvatar1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar1"]];
        self.imgAvatar1.frame = CGRectMake(0, 0, kAvatarSize, kAvatarSize);
        [self addSubview:self.imgAvatar1];
        self.imgAvatar2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar2"]];
        self.imgAvatar2.frame = CGRectMake(0, 0, kAvatarSize, kAvatarSize);
        [self addSubview:self.imgAvatar2];
        self.imgAvatar3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar3"]];
        self.imgAvatar3.frame = CGRectMake(0, 0, kAvatarSize, kAvatarSize);
        [self addSubview:self.imgAvatar3];
        self.imgAvatar4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar4"]];
        self.imgAvatar4.frame = CGRectMake(0, 0, kAvatarSize, kAvatarSize);
        [self addSubview:self.imgAvatar4];
        
        self.imgSocialFacebook = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"social-facebook"]];
        self.imgSocialFacebook.frame = CGRectMake(0, 0, kSocialSize, kSocialSize);
        [self addSubview:self.imgSocialFacebook];
        self.imgSocialTwitter = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"social-twitter"]];
        self.imgSocialTwitter.frame = CGRectMake(0, 0, kSocialSize, kSocialSize);
        [self addSubview:self.imgSocialTwitter];
        self.imgSocialGoogleplus = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"social-googleplus"]];
        self.imgSocialGoogleplus.frame = CGRectMake(0, 0, kSocialSize, kSocialSize);
        [self addSubview:self.imgSocialGoogleplus];
        
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.lblTitle)
        [self.lblTitle mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@kTitleTop);
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.height.equalTo(@30);
        }];
    
    
    [self.imgAvatar2 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@kAvatarSize);
        make.height.equalTo(@kAvatarSize);
        make.top.equalTo(self.mas_centerY).offset(kAvatarOffsetFromCenter);
        make.centerX.equalTo(self.mas_centerX).offset(-kAvatarSize/2 - kAvatarSize / 3);
    }];
    
    [self.imgAvatar3 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@kAvatarSize);
        make.height.equalTo(@kAvatarSize);
        make.top.equalTo(self.mas_centerY).offset(kAvatarOffsetFromCenter);
        make.centerX.equalTo(self.mas_centerX).offset(kAvatarSize/2 + kAvatarSize / 3);
    }];
    
    [self.imgAvatar1 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@kAvatarSize);
        make.height.equalTo(@kAvatarSize);
        make.top.equalTo(self.mas_centerY).offset(kAvatarOffsetFromCenter + kAvatarSize * 3 / 4);
        make.left.equalTo(self.imgAvatar2.mas_left).offset(-kAvatarSize - kAvatarSize / 3);
    }];
    
    [self.imgAvatar4 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@kAvatarSize);
        make.height.equalTo(@kAvatarSize);
        make.top.equalTo(self.imgAvatar1.mas_top);
        make.right.equalTo(self.imgAvatar3.mas_right).offset(kAvatarSize + kAvatarSize / 3);
    }];
    
    [self.imgSocialFacebook mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@kSocialSize);
        make.height.equalTo(@kSocialSize);
        make.top.equalTo(self.mas_centerY).offset(kSocialOffsetFromCenter);
        make.centerX.equalTo(self.mas_centerX);
    }];
    
    [self.imgSocialTwitter mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@kSocialSize);
        make.height.equalTo(@kSocialSize);
        make.top.equalTo(self.imgSocialFacebook.mas_top).offset(-kSocialSize * 2 / 3);
        make.left.equalTo(self.imgSocialFacebook.mas_left).offset(-kSocialSize - kSocialSize );
    }];
    
    [self.imgSocialGoogleplus mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@kSocialSize);
        make.height.equalTo(@kSocialSize);
        make.top.equalTo(self.imgSocialTwitter.mas_top);
        make.right.equalTo(self.imgSocialFacebook.mas_right).offset(+kSocialSize + kSocialSize );
    }];
    
    
}

@end
