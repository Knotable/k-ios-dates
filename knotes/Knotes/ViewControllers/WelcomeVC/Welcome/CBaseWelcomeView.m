//
//  CBaseWelcomeView.m
//  Knotable
//
//  Created by Donald Pae on 2/24/14.
//
//

#import "CBaseWelcomeView.h"

@interface CBaseWelcomeView ()

@property (nonatomic, retain) UIImageView *bgView;

@end

@implementation CBaseWelcomeView

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        
        self.backgroundColor = [UIColor whiteColor];
        
        /*
        self.bgView = [UIImageView new];
        [self.bgView setImage:[UIImage imageNamed:@"topic-bg.png"]];
        [self.bgView setImage:[UIImage imageNamed:@"LaunchImage"]];

        [self addSubview:self.bgView];
        [self sendSubviewToBack:self.bgView];
         */
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    /*
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
     */
}

@end
