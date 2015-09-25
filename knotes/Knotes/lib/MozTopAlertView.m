//
//  MozTopAlertView.m
//  MoeLove
//
//  Created by LuLucius on 14/12/7.
//  Copyright (c) 2014年 MOZ. All rights reserved.
//

#import "MozTopAlertView.h"

#define MOZ_TEXTSIZE(text, font) [text length] > 0 ? [text \
sizeWithAttributes:@{NSFontAttributeName:font}] : CGSizeZero;

#define hsb(h,s,b) [UIColor colorWithHue:h/360.0f saturation:s/100.0f brightness:b/100.0f alpha:1.0]

#define FlatSkyBlue hsb(204, 76, 86)
#define FlatGreen hsb(145, 77, 80)
#define FlatOrange hsb(28, 85, 90)
#define FlatRed hsb(6, 74, 91)
#define FlatSkyBlueDark hsb(204, 78, 73)
#define FlatGreenDark hsb(145, 78, 68)
#define FlatOrangeDark hsb(24, 100, 83)
#define FlatRedDark hsb(6, 78, 75)

@interface MozTopAlertView (){
    //UILabel *leftIcon;
}

@property (nonatomic, copy) dispatch_block_t nextTopAlertBlock;

@end

@implementation MozTopAlertView

- (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (BOOL)hasViewWithParentView:(UIView*)parentView{
    if ([self viewWithParentView:parentView]) {
        return YES;
    }
    return NO;
}

+ (MozTopAlertView*)viewWithParentView:(UIView*)parentView{
    NSArray *array = [parentView subviews];
    for (UIView *view in array) {
        if ([view isKindOfClass:[MozTopAlertView class]]) {
            return (MozTopAlertView *)view;
        }
    }
    return nil;
}

+ (MozTopAlertView*)viewWithParentView:(UIView*)parentView cur:(UIView*)cur{
    NSArray *array = [parentView subviews];
    for (UIView *view in array) {
        if ([view isKindOfClass:[MozTopAlertView class]] && view!=cur) {
            return (MozTopAlertView *)view;
        }
    }
    return nil;
}

+ (void)hideViewWithParentView:(UIView*)parentView{
    NSArray *array = [parentView subviews];
    for (UIView *view in array) {
        if ([view isKindOfClass:[MozTopAlertView class]]) {
            MozTopAlertView *alert = (MozTopAlertView *)view;
            [alert hide];
        }
    }
}

+ (MozTopAlertView*)showWithType:(MozAlertType)type text:(NSString*)text parentView:(UIView*)parentView{
    MozTopAlertView *alertView = [[MozTopAlertView alloc]initWithType:type text:text doText:nil  withDelegate:nil];
    [parentView addSubview:alertView];
    [alertView show];
    return alertView;
}

+ (MozTopAlertView*)showWithType:(MozAlertType)type text:(NSString*)text doText:(NSString*)doText andDelegate:(id)delegate doBlock:(dispatch_block_t)doBlock parentView:(UIView*)parentView{
    MozTopAlertView *alertView = [[MozTopAlertView alloc]initWithType:type text:text doText:doText  withDelegate:delegate];
    alertView.doBlock = doBlock;
    [parentView addSubview:alertView];
    [alertView show];
    return alertView;
}
- (instancetype)initWithType:(MozAlertType)type text:(NSString*)text doText:(NSString*)doText withDelegate:(id)delegate// parentView:(UIView*)parentView
{
    self = [super init];
    if (self) {
        [self setType:type text:text doText:doText];
        _targetDelegate=delegate;
    }
    return self;
}

- (void)setType:(MozAlertType)type text:(NSString*)text{
    [self setType:type text:text doText:nil];
}

- (void)setType:(MozAlertType)type text:(NSString*)text doText:(NSString*)doText{
    _autoHide = YES;
    _duration = 8;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    self.backgroundColor=[UIColor colorWithWhite:0.141 alpha:1.000];
    [self setFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height+133, width, 40)];
    /*self.layer.masksToBounds = YES;
    self.layer.cornerRadius = 2;*/
    CGFloat textLabelWidth = width*0.9;
    UILabel *textLabel = [[UILabel alloc]initWithFrame:CGRectMake((width - textLabelWidth)*0.5, 0, textLabelWidth, CGRectGetHeight(self.frame))];
    textLabel.backgroundColor = [UIColor clearColor];
    [textLabel setTextColor:[UIColor colorWithWhite:1.000 alpha:1.000]];
    textLabel.textAlignment = NSTextAlignmentLeft;
    textLabel.font = [DesignManager knoteLoginFieldsFont];
    textLabel.text = text;
    [self addSubview:textLabel];
    
    if (doText) {
        _duration = 10;
        UIButton * rightBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetWidth(self.frame) - 50, 0, 50, CGRectGetHeight(self.frame))];
        
        [rightBtn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0]/*[UIFont boldSystemFontOfSize:16]*/];
        
       
        [rightBtn setTitle:doText forState:UIControlStateNormal];

        [rightBtn setBackgroundImage:[self createImageWithColor:self.backgroundColor] forState:UIControlStateNormal];
        [rightBtn setTitleColor:[UIColor colorWithRed:0.563 green:0.693 blue:0.960 alpha:1.000] forState:UIControlStateNormal];
        
        CGSize size = MOZ_TEXTSIZE(doText, rightBtn.titleLabel.font);
        
        CGFloat rightBtnWidth = size.width + 14;
        rightBtn.frame = CGRectMake(CGRectGetWidth(self.frame) - rightBtnWidth, 0, rightBtnWidth, CGRectGetHeight(self.frame));
        
        textLabel.frame = CGRectMake((width - textLabelWidth)*0.5, 0, textLabelWidth + 30 - rightBtnWidth, CGRectGetHeight(self.frame));
        
        [rightBtn addTarget:self action:@selector(rightBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:rightBtn];
        
    }
  
}

- (void)rightBtnAction{
    if (_doBlock) {
        _doBlock();
        _doBlock = nil;
    }
}

- (void)show{
    dispatch_block_t showBlock = ^{
        [UIView animateWithDuration:0.3 animations:^{
            if ([_targetDelegate respondsToSelector:@selector(mozAlertViewWillDisplay)])
            {
                [_targetDelegate mozAlertViewWillDisplay];
            }
            self.layer.position = CGPointMake(self.layer.position.x, self.window.frame.size.height-84);
        } completion:^(BOOL finished) {
        }];
        [self performSelector:@selector(hide) withObject:nil afterDelay:_duration];
    };
    
    MozTopAlertView *lastAlert = [MozTopAlertView viewWithParentView:self.superview cur:self];
    if (lastAlert) {
        lastAlert.nextTopAlertBlock = ^{
            showBlock();
        };
        [lastAlert hide];
    }else{
        showBlock();
    }
}

- (void)hide{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [UIView animateWithDuration:0.3 animations:^{
        if ([self.targetDelegate respondsToSelector:@selector(mozAlertViewWillhide)])
        {
            [self.targetDelegate mozAlertViewWillhide];
        }
        self.layer.position = CGPointMake(self.layer.position.x, self.layer.position.y + 130);
    } completion:^(BOOL finished) {
        if (_nextTopAlertBlock) {
            _nextTopAlertBlock();
            _nextTopAlertBlock = nil;
        }
        [self removeFromSuperview];
    }];

    if (_dismissBlock) {
        _dismissBlock();
        _dismissBlock = nil;
    }
}

-(void)setDuration:(NSInteger)duration{
    _duration = duration;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    [self performSelector:@selector(hide) withObject:nil afterDelay:_duration];
}

-(void)setAutoHide:(BOOL)autoHide{
    if (autoHide && !_autoHide) {
        [self performSelector:@selector(hide) withObject:nil afterDelay:_duration];
    }else{
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
    }
    _autoHide = autoHide;
}

-(void)dealloc{
    _doBlock = nil;
    _dismissBlock = nil;
    _nextTopAlertBlock = nil;
}

@end
// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net