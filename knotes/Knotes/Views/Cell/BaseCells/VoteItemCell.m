//
//  VoteItemCell.m
//  Knotable
//
//  Created by wuli on 14-6-30.
//
//

#import "VoteItemCell.h"
#import "DesignManager.h"

@interface VoteItemCell()<UITextFieldDelegate>

@property (nonatomic)           BOOL  isAddable;
@property (nonatomic, assign)   BOOL  isChecked;
@property (nonatomic, strong)   UIView *grayView;
@property (nonatomic, strong)   UILabel *progressLabel;
@property (nonatomic, strong)   NSDictionary *info;
@end

@implementation VoteItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.checkedImage = [UIImage imageNamed: @"check_btn"];
        self.uncheckedImage = [UIImage imageNamed: @"uncheck_btn"];
        self.checkedImage1 = [UIImage imageNamed: @"icon_check"];
        self.uncheckedImage1 = [UIImage imageNamed: @"icon_uncheck"];
        self.tfVote = [[UITextField alloc] initWithFrame:CGRectZero];
        _tfVote.delegate = self;
        _tfVote.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _tfVote.textColor = [DesignManager knoteBodyTextColor];
        _tfVote.font = [DesignManager knoteBodyFont];
        _tfVote.borderStyle = UITextBorderStyleNone;
        _tfVote.adjustsFontSizeToFitWidth = YES;
        _tfVote.textAlignment = NSTextAlignmentLeft;
        _tfVote.clearButtonMode = UITextFieldViewModeNever;
        _tfVote.clearsOnBeginEditing = YES;
        _tfVote.keyboardType = UIKeyboardTypeASCIICapable;
        _tfVote.enabled = NO;
        self.checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_checkBtn addTarget:self action:@selector(onCheckChanged:) forControlEvents:UIControlEventTouchUpInside];
       [self addSubview:_tfVote];
        [self addSubview:_checkBtn];
        self.progressLabel = [[UILabel alloc] init];
        self.progressLabel.textAlignment = NSTextAlignmentRight;
        self.progressLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16]/*[UIFont systemFontOfSize:16]*/;
        [self addSubview:self.progressLabel];
    }
    return self;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat ctlWidth = self.bounds.size.width;
    CGFloat ctlHeight = self.bounds.size.height;
    CGFloat itemH = 30;
    [_checkBtn setFrame:CGRectMake(6, (ctlHeight-itemH)/2, itemH, itemH)];
    [_tfVote setFrame:CGRectMake(40, (ctlHeight-itemH)/2, ctlWidth-60, itemH)];
    self.progressLabel.frame = CGRectInset(self.bounds, 10, 0);
    
}

- (void)setInfo:(NSDictionary*) info tableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.info = info;
    UIImage* img = nil;

    if (self.type == C_LIST) {
        if (![info[@"checked"] isKindOfClass:[NSNull class]]) {
            self.isChecked = [info[@"checked"] boolValue];
        }
        img = self.isChecked? self.checkedImage1 : self.uncheckedImage1;
        if (_grayView) {
            [self.grayView removeFromSuperview];
            self.grayView = nil;
        }
    } else {
        BOOL checked = NO;
        for (NSString *vote in info[@"voters"]) {
            if ([vote isKindOfClass:[NSString class]]) {
                if ([vote isEqualToString:self.my_account_id]) {
                    checked = YES;
                    break;
                }
            }
        }
        self.isChecked = checked;
        img = self.isChecked? self.checkedImage : self.uncheckedImage;
        if (!self.grayView) {
            self.grayView = [[UIView alloc] initWithFrame:CGRectZero];
            self.grayView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
            self.grayView.backgroundColor = [UIColor colorWithWhite:0.92 alpha:0.7];
            [self addSubview:self.grayView];
            [self sendSubviewToBack:self.grayView];
        }
        CGFloat process = 0.0f;
        if (info[@"voters"] && [info[@"voters"] count]>0  && self.participators && [self.participators count]>0) {
            process = ((CGFloat)[info[@"voters"] count]*1.0)/(CGFloat)[self.participators count];
        }
        self.progressLabel.text = [NSString stringWithFormat:@"%d%%",(int)(process*100)];
        
        
        UIBezierPath *maskPath = nil;
        CGRect bounds = self.bounds;
        bounds.origin.x+=2;
        bounds.size.width-=8;
        bounds.size.width = process*bounds.size.width;
        self.grayView.frame = bounds;
        CGFloat cornerRadius = 6.f;
        if (indexPath.row == 0 && indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                             byRoundingCorners:(UIRectCornerAllCorners)
                                                   cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        } else if (indexPath.row == 0) {
            maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                             byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                   cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        } else if (indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
            maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                             byRoundingCorners:(UIRectCornerBottomRight | UIRectCornerBottomLeft)
                                                   cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
        } else {
            maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                             byRoundingCorners:(UIRectCornerAllCorners)
                                                   cornerRadii:CGSizeMake(0, 0)];
        }
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = bounds;
        maskLayer.path = maskPath.CGPath;
        self.grayView.layer.mask = maskLayer;
    }
    self.contentText = info[@"name"];
    if (self.contentText == (id)[NSNull null]) {
        self.contentText = @"";
    }
    UIColor *color = self.isChecked?[DesignManager knoteUsernameColor]:[UIColor blackColor];
    if (self.type == C_LIST) {
        if (_isChecked) {
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.contentText];
            [attributeString addAttribute:NSStrikethroughStyleAttributeName
                                    value:@2
                                    range:NSMakeRange(0, [attributeString length])];
            
            _tfVote.attributedText = attributeString;
            UIColor *color = self.isChecked?[UIColor grayColor]:[UIColor blackColor];
            [_tfVote setTextColor:color];
        } else {
            [_tfVote setText:self.contentText];
            _tfVote.font = [DesignManager knoteBodyFont];
        }
    } else {
        [_tfVote setText:self.contentText];
    }
    [_progressLabel setTextColor:color];
    
    [_checkBtn setImage:img forState:UIControlStateNormal];
    _isAddable = NO;
}


- (void)onCheckChanged:(id)sender
{
    _isChecked = !_isChecked;
    UIImage* img = nil;
    if (self.type == C_LIST) {
        img = _isChecked? self.checkedImage1 : self.uncheckedImage1;
    } else {
        img = _isChecked? self.checkedImage : self.uncheckedImage;
    }
    [_checkBtn setImage:img forState:UIControlStateNormal];
}

@end
