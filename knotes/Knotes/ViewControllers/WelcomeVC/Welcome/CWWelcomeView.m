//
//  CWWelcomeView.m
//  Knotable
//
//  Created by Donald Pae on 2/24/14.
//
//

#import "CWWelcomeView.h"
#import "CUtil.h"


#define kMarkSize       40

@interface CWWelcomeView ()

@property (nonatomic, retain) UILabel *lblWelcome;
@property (nonatomic, retain) UILabel *lblKnotable;
@property (nonatomic, retain) UIImageView *imgIcon;

@property (nonatomic, retain) UIImageView *bgView;


@end

@implementation CWWelcomeView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        
//        self.lblWelcome = [[UILabel alloc] init];
//        [self.lblWelcome setTextAlignment:NSTextAlignmentCenter];
//        [self.lblWelcome setBackgroundColor:[UIColor clearColor]];
//        [self.lblWelcome setTextColor:[UIColor grayColor]];
//        [self.lblWelcome setFont:kCustomLightFont(kWelcomeTitleFontSize)];
//        [self.lblWelcome setText:@"Welcome to"];
//        
//        [self addSubview:self.lblWelcome];

        /*
        self.lblKnotable = [[UILabel alloc] init];
        [self.lblKnotable setTextAlignment:NSTextAlignmentCenter];
        [self.lblKnotable setBackgroundColor:[UIColor clearColor]];
        [self.lblKnotable setTextColor:[UIColor blackColor]];
        [self.lblKnotable setFont:kCustomBoldFont(34)];
        [self.lblKnotable setText:@"knotable"];
        
        [self addSubview:self.lblKnotable];
         */

        
        NSString *launchImage;
        if  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) &&
             ([UIScreen mainScreen].bounds.size.height > 480.0f)) {
            launchImage = @"Default-568h";
        } else {
            launchImage = @"Default";
        }
        
         
        self.bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:launchImage]];
        
        [self addSubview:self.bgView];
        [self sendSubviewToBack:self.bgView];

        
        /*
        self.imgIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"knotable_logo"]];
        [self addSubview:self.imgIcon];
         */
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];

    
    if (self.lblWelcome)
        [self.lblWelcome mas_updateConstraints:^(MASConstraintMaker *make) {
            
            if([[UIScreen mainScreen] bounds].size.height >= 568)
                make.top.equalTo(@158);
            else
                make.top.equalTo(@114);
            
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.height.equalTo(@30);
        }];
    
    if (self.lblKnotable)
        [self.lblKnotable mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lblWelcome.mas_top).offset(30);
            make.left.equalTo(self.lblWelcome.mas_left).offset(0);
            make.right.equalTo(self.lblWelcome.mas_right).offset(0);
            make.height.equalTo(@30);
        }];
    
    [self.imgIcon mas_updateConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.lblWelcome.mas_top).offset(-kMarkSize-30);
        make.width.equalTo(@(60));
        make.height.equalTo(@(self.imgIcon.image.size.height*(60.0/self.imgIcon.image.size.width)));
    }];
}

@end
