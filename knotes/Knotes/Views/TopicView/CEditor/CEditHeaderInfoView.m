//
//  CEditHeaderInfoView.m
//  Knotable
//
//  Created by backup on 11/18/14.
//
//

#import "CUtil.h"
#import "UIImage+Additional.h"
#import "UIImage+Tint.h"
#import "CEditHeaderInfoView.h"

@interface CEditHeaderInfoView()

@property (nonatomic, strong) UILabel   *archivedNum;
@property (nonatomic, strong) UIView    *bgView;
@property (nonatomic, strong) UIButton  *voteBtn;
@property (nonatomic, strong) UIButton  *listBtn;
@property (nonatomic, strong) UIButton  *dateBtn;

@end
@implementation CEditHeaderInfoView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton setImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor grayColor]] forState:UIControlStateNormal];
        [_deleteButton setTitle:@"Show knote marked done" forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(buttonClicked) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_deleteButton];
        [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(2));
            make.bottom.equalTo(@(-2));
            make.left.equalTo(@(16));
            make.width.equalTo(@(30));
        }];
        
        _deleteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        
        // Adjust Edge Insets according to the above measurement. The +2 adds a little space
        _deleteButton.imageEdgeInsets = UIEdgeInsetsMake(0, -10 , 0, 0);
        _deleteButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10);
        

        self.archivedNum = [[UILabel alloc] init];
        _archivedNum.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
        _archivedNum.backgroundColor = [UIColor colorWithWhite:0.9 alpha:0.9];
        _archivedNum.layer.cornerRadius = 3;
        _archivedNum.layer.borderWidth = 2;
        _archivedNum.layer.borderColor = [UIColor clearColor].CGColor;
        _archivedNum.textAlignment = NSTextAlignmentCenter;
        _archivedNum.textColor = [UIColor blueColor];
        _archivedNum.clipsToBounds = YES;
        [self addSubview:_archivedNum];
        self.bgView = [UIView new];
        [self addSubview:_bgView];
        
        [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(4));
            make.bottom.equalTo(@(-4));
            make.left.equalTo(_deleteButton.mas_right).offset(10);
            make.right.equalTo(@(-20));
        }];
        
        self.voteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_voteBtn setTitle:@"Vote" forState:UIControlStateNormal];
        [self.bgView addSubview:_voteBtn];
        self.listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_listBtn setTitle:@"List" forState:UIControlStateNormal];
        [self.bgView addSubview:_listBtn];
        self.dateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_dateBtn setTitle:@"Date" forState:UIControlStateNormal];
        [self.bgView addSubview:_dateBtn];
        [_voteBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]];
        [_listBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]];
        [_dateBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]];
        [_voteBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_listBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [_dateBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];

        [_voteBtn setBackgroundColor:[UIColor colorWithRed:6.0/255.0 green:201.3/255.0 blue:204.3/255.0 alpha:0.3]];
        [_listBtn setBackgroundColor:[UIColor colorWithRed:0. green:249.0/255 blue:0. alpha:0.3]];
        [_dateBtn setBackgroundColor:[UIColor colorWithRed:254.0/255.0 green:243.0/255.0 blue:0. alpha:0.3]];
        
        [_voteBtn addTarget:self action:@selector(segmentedControlSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_listBtn addTarget:self action:@selector(segmentedControlSelected:) forControlEvents:UIControlEventTouchUpInside];
        [_dateBtn addTarget:self action:@selector(segmentedControlSelected:) forControlEvents:UIControlEventTouchUpInside];
        _voteBtn.tag = 0;
        _listBtn.tag = 1;
        _dateBtn.tag = 2;

    }
    return self;
}

-(void)setContentDic:(NSMutableDictionary *)contentDic
{
    _contentDic = contentDic;
    _voteBtn.hidden = YES;
    _listBtn.hidden = YES;
    _dateBtn.hidden = YES;

    [self updateLabel];

    [self updateButton];
}

- (void)buttonClicked
{
    if (_delegate && [_delegate respondsToSelector:@selector(deleteButtonClicked)]) {
        [_delegate deleteButtonClicked];
    }
}

- (void)segmentedControlSelected:(id)sender
{
    UIButton *btn = (UIButton *)sender;
      NSNumber *num = @(-1);
    if (btn.tag == 0) {
        num = _contentDic[@"C_VOTE"];
    }
    if (btn.tag == 1) {
        num = _contentDic[@"C_LIST"];
    }
    if (btn.tag == 2) {
        num = _contentDic[@"C_DATE"];
    }
    [_delegate headerButtonClickedAt:num.integerValue];
}

-(void)updateButton
{
    if (!_showArchived)
    {
        if (_num>0)
        {
            [_deleteButton setImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor blueColor]] forState:UIControlStateNormal];
            [_deleteButton setTitle:@"Show knote marked done" forState:UIControlStateNormal];
            [_deleteButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        else
        {
            [_deleteButton setTitle:@"Show knote marked done" forState:UIControlStateNormal];
            [_deleteButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            [_deleteButton setImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor grayColor]] forState:UIControlStateNormal];
        }
    }
    else
    {
        //[_deleteButton setImage:[[UIImage imageNamed:@"delete_icon"] imageTintedWithColor:[UIColor greenColor]] forState:UIControlStateNormal];
        [_deleteButton setTitle:@"Hide knote marked done" forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [_deleteButton setImage:[[UIImage imageNamed:@"recover"] imageTintedWithColor:[UIColor grayColor]] forState:UIControlStateNormal];
    }
    [self setNeedsUpdateConstraints];

}

-(void)updateLabel
{
    NSInteger numberOfSegments = 0;
    if (_contentDic[@"C_VOTE"]) {
        _voteBtn.hidden = NO;
        numberOfSegments++;
    }
    if (_contentDic[@"C_LIST"]) {
        _listBtn.hidden = NO;
        numberOfSegments++;
    }
    if (_contentDic[@"C_DATE"]) {
        _dateBtn.hidden = NO;
        numberOfSegments++;
    }
    _num = [_contentDic[@"C_NUM"] integerValue];
    _archivedNum.text = [NSString stringWithFormat:@"%d",(int)_num];
    if (_num>0)
    {
        _archivedNum.hidden = NO;
    }
    else
    {
        _archivedNum.hidden = YES;
    }
    if (numberOfSegments>0)
    {
        [_deleteButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(2));
            make.bottom.equalTo(@(-2));
            make.left.equalTo(@(16));
            make.width.equalTo(@(30));
        }];
        [_archivedNum mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_deleteButton.mas_top);
            make.height.equalTo(@(12));
            make.left.equalTo(_deleteButton.mas_right).offset(-10);
            CGSize size = [CUtil getTextSize:_archivedNum.text textFont:_archivedNum.font];
            make.width.equalTo(@(size.width+6));
        }];
    }
    else
    {
        [_deleteButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(2));
            make.bottom.equalTo(@(-2));
            make.left.equalTo(@(16));
            make.right.equalTo(@(-16));
        }];
        
        [_archivedNum mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_deleteButton.mas_top);
            make.height.equalTo(@(12));
            make.centerX.equalTo(_deleteButton.mas_centerX).offset(16);
            CGSize size = [CUtil getTextSize:_archivedNum.text textFont:_archivedNum.font];
            make.width.equalTo(@(size.width+6));
        }];
    }
}

-(void)setShowArchived:(BOOL)showArchived
{
    _showArchived = showArchived;
    [self updateButton];
}

- (void) flashButton
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_deleteButton setImage:[_deleteButton.imageView.image imageTintedWithColor:[UIColor blueColor]] forState:UIControlStateNormal];
        _deleteButton.transform = CGAffineTransformMakeScale(0.6, 0.6);
        _deleteButton.alpha = 0.2;
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [_deleteButton setImage:[_deleteButton.imageView.image imageTintedWithColor:[UIColor blueColor]] forState:UIControlStateNormal];

            _deleteButton.transform = CGAffineTransformMakeScale(1, 1);
            _deleteButton.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                [_deleteButton setImage:[_deleteButton.imageView.image imageTintedWithColor:[UIColor grayColor]] forState:UIControlStateNormal];

                [UIView animateKeyframesWithDuration:.4 delay:0 options:0 animations:^{
                    [UIView addKeyframeWithRelativeStartTime:.2 relativeDuration:.2 animations:^{
                        _deleteButton.transform = CGAffineTransformScale(CGAffineTransformMakeScale(1, 1), 1, 1);
                    }];
                } completion:^(BOOL finished){
                    [self updateLabel];
                }];
            }
        }];
    });
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    NSInteger n = 0;
    CGFloat w = 0;
    if (!_voteBtn.hidden)
    {
        n++;
    }
    if (!_listBtn.hidden)
    {
        n++;
    }
    if (!_dateBtn.hidden)
    {
        n++;
    }
    if (n)
    {
        w = CGRectGetWidth(self.bgView.bounds)/n;
        CGFloat startX = 0;
        if (!_voteBtn.hidden)
        {
            [_voteBtn setFrame:CGRectMake(startX, 0, w, CGRectGetHeight(self.bgView.bounds))];
            startX+=w;
        }
        if (!_listBtn.hidden)
        {
            [_listBtn setFrame:CGRectMake(startX, 0, w, CGRectGetHeight(self.bgView.bounds))];
            startX+=w;
        }
        if (!_dateBtn.hidden)
        {
            [_dateBtn setFrame:CGRectMake(startX, 0, w, CGRectGetHeight(self.bgView.bounds))];
            startX+=w;
        }
    }
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bgView.bounds, 0, 3)
                                                   byRoundingCorners:UIRectCornerAllCorners
                                                         cornerRadii:CGSizeMake(3.0, 3.0)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame         = self.bounds;
    maskLayer.path          = maskPath.CGPath;
    self.bgView.layer.mask         = maskLayer;
}

@end
