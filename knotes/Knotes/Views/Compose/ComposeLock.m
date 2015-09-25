//
//  ComposeLock.m
//  Knotable
//
//  Created by backup on 14-1-3.
//
//

#import "ComposeLock.h"
@interface ComposeLock ()
<
UITextViewDelegate
>
@property (nonatomic, strong) UITextView *textView;
@end
@implementation ComposeLock

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textView = [[UITextView alloc] init];
        _textView.delegate = self;
        [_textView setFrame:CGRectMake(kHGap, kVGap, self.frame.size.width - 2*kHGap, self.frame.size.height - 2*kVGap)];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.layer.cornerRadius=2.0f;
        _textView.layer.masksToBounds=YES;
        _textView.textColor = kInputTextColor;
        _textView.font = kCustomLightFont(kDefaultFontSize);
        [self addSubview:self.textView];    }
    return self;
}

-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self.textView becomeFirstResponder];
}

- (void)updateConstraints
{
    [super updateConstraints];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(kVGap);
        make.bottom.equalTo(self.mas_bottom).offset(-kHGap);
        make.left.equalTo(self.mas_left).offset(kHGap);
        make.right.equalTo(self.mas_right).offset(-kHGap);
    }];
}
#pragma mark ComposeProtocol
- (void)setTitlePlaceHold:(NSString *)str
{
}
- (void)setTitleContent:(NSString *)str
{
    if (str && [str length]>0) {
        self.textView.text = str;
    }
}
- (void)setCotent:(id)content
{
}
- (id)getCotent
{
    return nil;
}
- (NSString *)getTitle
{
    [self.textView endEditing:YES];
    return self.textView.text;
}
@end
