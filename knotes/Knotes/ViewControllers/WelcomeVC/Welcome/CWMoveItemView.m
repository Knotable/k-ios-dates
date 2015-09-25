//
//  CWMoveItemView.m
//  Knotable
//
//  Created by Donald Pae on 2/24/14.
//
//

#import "CWMoveItemView.h"
#import "CUtil.h"

#define kTitleOffsetFromBottom      -200

@interface CWMoveItemView ()

@property (nonatomic, retain) UILabel *lblTitle;

@end

@implementation CWMoveItemView

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
        [self.lblTitle setText:@"Move them"];
        
        [self addSubview:self.lblTitle];
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.lblTitle)
        [self.lblTitle mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_bottom).offset(kTitleOffsetFromBottom);
            make.left.equalTo(@0);
            make.right.equalTo(@0);
            make.height.equalTo(@30);
        }];
}

@end
