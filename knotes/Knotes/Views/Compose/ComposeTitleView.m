//
//  ComposeTitleView.m
//  Knotable
//
//  Created by backup on 14-1-3.
//
//

#import "ComposeTitleView.h"
@interface ComposeTitleView()<UITextFieldDelegate>
@property (nonatomic, strong) UIImageView *imgLine;
@end
@implementation ComposeTitleView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.inputText = [[UITextField alloc] init];
        _inputText.backgroundColor = [UIColor clearColor];
        _inputText.borderStyle = UITextBorderStyleNone;
        _inputText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _inputText.delegate = self;
        _inputText.textColor = kInputTextColor;
        _inputText.font = kCustomBoldFont(kDefaultFontSize);
        [self addSubview: self.inputText];
        
        self.imgLine = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"upload-devider"]];
        
        [self addSubview:self.imgLine];
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    [self.inputText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(       @(kVGap));
        make.left.equalTo(      @(kHGap+2));
        make.right.equalTo(     @(-(kHGap+2)));
        make.height.equalTo(    @(kDefaultInputFieldH));
    }];
    [self.imgLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(       @(kVGap+kDefaultInputFieldH-4));
        make.left.equalTo(self.mas_left).offset(kHGap);
        make.right.equalTo(self.mas_right).offset(-kHGap);
        make.height.equalTo(@(1));
    }];
}
@end
