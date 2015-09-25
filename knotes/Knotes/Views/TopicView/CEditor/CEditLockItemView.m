//
//  CEditLockItemView.m
//  RevealControllerProject
//
//  Created by backup on 13-10-16.
//
//

#import "CEditLockItemView.h"

#import "CUtil.h"
#import "CLockItem.h"
#import "DesignManager.h"

#import "UIImage+Tint.h"
#import "UIImage+ProportionalFill.h"
#import <QuartzCore/QuartzCore.h>

@interface CEditLockItemView ()<UITextViewDelegate>
@property (nonatomic, retain) IBOutlet UITextView* textView;
@property (nonatomic, retain) UIImageView *lockView;
@property (nonatomic, retain) UIImageView *lockIcon;
@property (nonatomic, retain) UILabel *lockTitle;
@end

@implementation CEditLockItemView

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.textView = [[UITextView alloc] init];
        _textView.delegate = self;
        _textView.editable = NO;
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textColor = [DesignManager knoteBodyTextColor];
        _textView.font = [DesignManager knoteBodyFont];
        [self.contentView addSubview:self.textView];
        UIImage *img = [UIImage imageNamed:@"widget-bg"];
        img = [img imageScaledToFitSize:CGSizeMake(kDefaultWidgetW, kDefaultWidgetH)];
        img = [img imageWithTintColor:[UIColor darkGrayColor] withMaskHeight:kWidgetTitleH];
        self.lockView = [[UIImageView alloc] initWithImage:img];
        _lockView.backgroundColor = [UIColor clearColor];
        self.lockIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock-icon"]];
        _lockIcon.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [_lockView addSubview:self.lockIcon];
        [self.contentView addSubview:self.lockView];
        
 
        self.lockTitle = [[UILabel alloc] init];
        _lockTitle.textColor = [UIColor whiteColor];
        _lockTitle.backgroundColor = [UIColor clearColor];
        _lockTitle.textAlignment = NSTextAlignmentCenter;
        _lockTitle.numberOfLines = 0;
        _lockTitle.font = [DesignManager knoteSmallHeaderFont];
        _lockTitle.lineBreakMode = NSLineBreakByWordWrapping;
        _lockTitle.text = @"Locked";
        [self.contentView addSubview:_lockTitle];
    }
    return self;
}

- (void)updateConstraints
{
    [super updateConstraints];
    [self.lockView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self.bgView.mas_left).offset(self.hGap);
        make.width.equalTo(    @(kDefaultWidgetW));
        make.height.equalTo(    @(kDefaultWidgetH));
        
        make.top.equalTo(self.bgView.mas_top).offset(self.vGap + 4.0);
    }];
    [self.lockTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.lockView.mas_width);
        make.height.equalTo(    @(kWidgetTitleH));
        make.top.equalTo(self.lockView.mas_top).offset(0);
        make.centerX.equalTo(self.lockView.mas_centerX);
    }];

    
    [self.lockIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(    @(30));
        make.height.equalTo(    @(40));
        make.bottom.equalTo(self.lockView.mas_bottom).offset(-10);
        make.centerX.equalTo(self.lockView.mas_centerX);
    }];
    
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
#if NEW_DESIGN
        make.top.equalTo(self.bgView.mas_top).offset(100+self.vGap);
#else
        make.top.equalTo(self.bgView.mas_top).offset(self.titleBarHeight+self.vGap);
#endif
        make.bottom.equalTo(self.bgView.mas_bottom).offset(0);
        make.left.equalTo(self.lockView.mas_right).offset(0);
        make.right.equalTo(self.bgView.mas_right).offset(0);
    }];
}

- (BOOL)canDraggable:(CGPoint)point
{
    return NO;
}

- (void)btnClicked:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if (btn.tag==3) {
    } else {
        [_textView resignFirstResponder];
    }
}
-(void) setItemData:(CItem*) itemData
{
    [super setItemData:itemData];
    CLockItem *iData = (CLockItem *)itemData;
    _textView.text = iData.body;
}

-(CItem*) getItemData
{
    return [super getItemData];
}
-(BOOL)isFirstResponder
{
    BOOL flag = [_textView isFirstResponder];
    return flag;
}
-(BOOL)resignFirstResponder
{
    BOOL flag = [_textView resignFirstResponder];
    return flag;
}
@end
