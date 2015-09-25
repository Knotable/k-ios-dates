//
//  CWMakeKnotesView.m
//  Knotable
//
//  Created by Donald Pae on 2/24/14.
//
//

#import "CWMakeKnotesView.h"
#import "CUtil.h"
#import "UIImage+Retina4.h"
#import "DesignManager.h"
#import "AppDelegate.h"

#define kExplainWidth   200
#define kMakeKnotesExplain "explain1 \nexplain2 \nexplainexplain3 \nYou can create knotes using this app"

#define kTitleFontSize          25
#define kDescriptionFontSize    18


@interface CWMakeKnotesView ()

@property (nonatomic, retain) UILabel *lblTitle;
@property (nonatomic, retain) UIView *backExplain;
@property (nonatomic, retain) UILabel *lblExplain;
@property (nonatomic, retain) NSString *strExplain;
@property (nonatomic, retain) UIImageView *image;
@property (nonatomic, retain) UIImageView *bgView;
@property (nonatomic, retain) UIImageView *bottomView;
@property (nonatomic, retain) UIView *imageContainerView;

@end

@implementation CWMakeKnotesView

- (id)initWithTitle:(NSString *)title description:(NSString*)description imageNamed:(NSString *)imageName
{
    self = [super init];
    if (self) {
        // Initialization code
        
        self.lblTitle = [[UILabel alloc] init];
        [self.lblTitle setTextAlignment:NSTextAlignmentCenter];
        [self.lblTitle setLineBreakMode:NSLineBreakByWordWrapping];
        [self.lblTitle setNumberOfLines:0];
        [self.lblTitle setBackgroundColor:[UIColor clearColor]];
        [self.lblTitle setTextColor:kWelcomeTitleColor];
        [self.lblTitle setFont:[DesignManager knoteWelcomeFontRobotoLightWithSize:kTitleFontSize]];
        [self.lblTitle setText:title];
        
        self.lblExplain = [[UILabel alloc] init];
        [self.lblExplain setTextAlignment:NSTextAlignmentCenter];
        [self.lblExplain setLineBreakMode:NSLineBreakByWordWrapping];
        [self.lblExplain setNumberOfLines:2];
        [self.lblExplain setBackgroundColor:[UIColor clearColor]];
        [self.lblExplain setTextColor:kWelcomeTitleColor];
        [self.lblExplain setFont:[DesignManager knoteWelcomeFontWithSize:kDescriptionFontSize]];
        [self.lblExplain setText:description];
        
        NSString *launchImage;
        
        if  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) &&
             ([UIScreen mainScreen].bounds.size.height > 480.0f)) {
            launchImage = @"Default-568h";
        }
        else
        {
            launchImage = @"Default";
        }
        
        self.bgView = [[UIImageView alloc] initWithImage:[UIImage retina4ImageNamed:@"background.png"]];
        
        [self addSubview:self.bgView];
        self.imageContainerView = [[UIView alloc]init];
        [self.imageContainerView setBackgroundColor:[UIColor clearColor]];
        [self.imageContainerView setClipsToBounds:YES];
        [self addSubview:self.imageContainerView];
        
        self.image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        [self.image setContentMode:UIViewContentModeScaleAspectFit];
        [self.imageContainerView addSubview:self.image];
        
        self.bottomView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"walkthrough_bottom.png"]];
        [self addSubview:self.bottomView];
        
        [self addSubview:self.lblTitle];
        [self addSubview:self.lblExplain];
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    CGFloat titleHeight = 0.0f;
    CGFloat descriptionHeight = 0.0f;
    CGFloat pageCtrlHeight = 10;
    CGFloat totalOffset = 0.0f;
    CGFloat walkThroghHeight = 0.0f;
    CGFloat finalOffset = 0.0f;
    
    titleHeight = [[AppDelegate sharedDelegate] heightOfTextForString:self.lblTitle.text
                                                              andFont:[DesignManager knoteWelcomeFontRobotoLightWithSize:kTitleFontSize]
                                                              maxSize:CGSizeMake(280.0f, 40.0f)];
    
    descriptionHeight = [[AppDelegate sharedDelegate] heightOfTextForString:self.lblExplain.text
                                                                    andFont:[DesignManager knoteWelcomeFontRobotoLightWithSize:kDescriptionFontSize]
                                                                    maxSize:CGSizeMake(280.0f, 100.0f)];
    
    totalOffset = descriptionHeight + titleHeight + pageCtrlHeight;
    
    if (gDeviceType == DEVICE_IPHONE_35INCH)
    {
        walkThroghHeight = 480.0f * 0.3;
    }
    else
    {
        walkThroghHeight = 568.0f * 0.3;
    }
    
    finalOffset = (walkThroghHeight - totalOffset) / 4;
    
    [self.imageContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.top.equalTo(self.mas_top);
        make.width.equalTo(self).multipliedBy(0.88);
        make.height.equalTo(self).multipliedBy(0.7);

    }];
    
    [self.image mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.imageContainerView);
        make.top.equalTo(self.imageContainerView.mas_top);
        make.width.equalTo(self.imageContainerView);
        
        if (gDeviceType == DEVICE_IPHONE_35INCH)
        {
            make.height.equalTo(self.imageContainerView).multipliedBy(1.7);
        }
        else
        {
            make.height.equalTo(self.imageContainerView).multipliedBy(1.43);
        }
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self.mas_bottom);
        make.width.equalTo(self.mas_width);
        make.height.equalTo(self).multipliedBy(0.3);
        
    }];
    
    if (self.lblTitle)
    {
        [self.lblTitle mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.imageContainerView.mas_bottom).offset(finalOffset-2);
            make.left.equalTo(self.imageContainerView.mas_left).offset(2);
            make.right.equalTo(self.imageContainerView.mas_right).offset(-2);
            make.height.equalTo(@(titleHeight));
        }];
    }
    
    [self.lblExplain mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lblTitle.mas_bottom).offset(finalOffset-5);
//        make.left.equalTo(self).offset(5);
//        make.right.equalTo(self).offset(-5);
        make.left.equalTo(self.imageContainerView.mas_left).offset(2);
        make.right.equalTo(self.imageContainerView.mas_right).offset(-2);
        make.height.equalTo(@(descriptionHeight));
    }];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.centerY.equalTo(self);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.width.equalTo(self);
        make.height.equalTo(self);
        
    }];}

@end
