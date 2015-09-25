//
//  MMessageHeaderView.m
//  Mailer
//
//  Created by Martin Ceperley on 10/22/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MMessageHeaderView.h"
#import "Masonry.h"

float topSpace = 10.0;
float leftSpace = 10.0;
float verticalSpace = 26.0;
float horizontalSpace = 5.0;
float bottomSpace = 14.0;
@interface MMessageHeaderView()
@property (nonatomic, strong) UIView * gayLine;

@end
@implementation MMessageHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
//        _toLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
//        _toField = [[UITextField alloc] initWithFrame:CGRectZero];
//        _toField.keyboardType = UIKeyboardTypeEmailAddress;
//        _toField.autocapitalizationType = UITextAutocapitalizationTypeNone;
//        _toField.autocorrectionType = UITextAutocorrectionTypeNo;
//        _toField.returnKeyType = UIReturnKeyNext;
        
        
        
        
        
        
//        _tokenFieldView = [[TITokenFieldView alloc] initWithFrame:CGRectZero];
////        [_tokenFieldView setDelegate:self];
////        [_tokenFieldView setSourceArray:[Names listOfNames]];
//        [_tokenFieldView.tokenField setTokenizingCharacters:[NSCharacterSet characterSetWithCharactersInString:@",;."]]; // Default is a comma
//        _tokenFieldView.backgroundColor = [UIColor redColor];
        
        
        
        _subjectLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _subjectField = [[UITextField alloc] initWithFrame:CGRectZero];
        _subjectField.returnKeyType = UIReturnKeyNext;

//        UIFont *labelFont = [UIFont boldSystemFontOfSize:12.0];
//        _toLabel.font  = _subjectLabel.font = labelFont;
        
        UIFont *contentFont = [UIFont systemFontOfSize:14.0];
         _subjectLabel.font = _subjectField.font = contentFont;
        
//        _toField.font =
//        _toLabel.text = @"To:";
//        _toField.text = @"";
        
        
        _subjectLabel.text = @"Subject:";
        _subjectField.placeholder = @"";
        _subjectField.backgroundColor = [UIColor clearColor];
        _subjectField.textAlignment = NSTextAlignmentLeft;
        _subjectLabel.textColor = [UIColor grayColor];
        
//        _subjectLabel.backgroundColor = [UIColor yellowColor];
//        _subjectField.backgroundColor = [UIColor grayColor];
        
//        [self addSubview:_toLabel];
//        [self addSubview:_toField];
        [self addSubview:_subjectLabel];
        [self addSubview:_subjectField];
        
//        [_toLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(@(topSpace));
//            make.left.equalTo(@(leftSpace));
//        }];
        
//        [_toField mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_toLabel);
//            make.left.equalTo(_toLabel.mas_right).offset(horizontalSpace);
//            make.width.equalTo(self).offset(-2*leftSpace - horizontalSpace - _toLabel.intrinsicContentSize.width);
//        }];
        
        
        
        
        
//        [_subjectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(@(topSpace));
//            make.left.equalTo(@(leftSpace));
//            make.height.equalTo(@(20));
//        }];
//
//        [_subjectField mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(@(topSpace));
//            make.left.equalTo(_subjectLabel.mas_right).offset(horizontalSpace);
//            make.width.equalTo(self).offset(-2*leftSpace - horizontalSpace - _subjectLabel.intrinsicContentSize.width-31);
//            make.height.equalTo(@(20));
//        }];

        
        
       

//        [_subjectLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_toLabel.mas_bottom).offset(verticalSpace);
//            make.left.equalTo(_toLabel);
//
//        }];
//        
//        [_subjectField mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(_subjectLabel);
//            make.left.equalTo(_subjectLabel.mas_right).offset(horizontalSpace);
//            make.width.equalTo(self).offset(-2*leftSpace - horizontalSpace - _subjectLabel.intrinsicContentSize.width - 30);
//        }];
        self.gayLine = [UIView new];
        self.gayLine.backgroundColor = [UIColor colorWithWhite:210.0/255.0 alpha:1.0];
        [self addSubview:self.gayLine];
        
    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect labelRect = [_subjectLabel.text
                        boundingRectWithSize:CGSizeMake(200, 20)
                        options:NSStringDrawingUsesLineFragmentOrigin
                        attributes:@{
                                     NSFontAttributeName : _subjectLabel.font
                                     }
                        context:nil];
    [_subjectLabel setFrame:CGRectMake(leftSpace, topSpace, CGRectGetWidth(labelRect), 20)];
    [_subjectField setFrame:CGRectMake(horizontalSpace+CGRectGetWidth(_subjectLabel.bounds)+_subjectLabel.frame.origin.x, topSpace, CGRectGetWidth(self.bounds)-2*leftSpace - horizontalSpace - _subjectLabel.intrinsicContentSize.width-31, 20)];
    [_gayLine setFrame:CGRectMake(0, CGRectGetHeight(self.bounds)-1, CGRectGetWidth(self.bounds), 1)];


}
- (CGSize) intrinsicContentSize
{
    CGFloat height =
                _subjectLabel.intrinsicContentSize.height +
    topSpace + verticalSpace + bottomSpace;
    
    return CGSizeMake(UIViewNoIntrinsicMetric, height);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//
//- (void)drawRect:(CGRect)rect
//{
//    
////    float startX = _toLabel.frame.origin.x;
////    
////    float endX = self.frame.size.width - startX;
////    float middleY = (_toLabel.frame.origin.y + _toLabel.frame.size.height + _subjectLabel.frame.origin.y) / 2.0;
//    
//    
//    
//    float startX = _subjectLabel.frame.origin.x-10;
//    
////    float endX = self.frame.size.width - startX;
//    
//    float endX = self.frame.size.width;
////    float middleY = (_subjectLabel.frame.origin.y + _subjectLabel.frame.size.height) ;
//    
//    
////    float bottomY = self.frame.size.height - 1.0;
//    
//    float bottomY = 39;
//
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    UIColor *lightGrayColor = [UIColor colorWithWhite:210.0/255.0 alpha:1.0];
//    CGContextSetStrokeColorWithColor(context, lightGrayColor.CGColor);
//    CGContextSetLineWidth(context, 2.0);
//    
//    CGPoint points[] = {
////        CGPointMake(startX, middleY),
////        CGPointMake(endX, middleY),
//        CGPointMake(startX, bottomY),
//        CGPointMake(endX, bottomY)
//    };
//
//    CGContextStrokeLineSegments(context, points, 4);
//}

@end
