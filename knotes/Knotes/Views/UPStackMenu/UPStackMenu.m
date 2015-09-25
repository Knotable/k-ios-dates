//
//  UPStackMenu.m
//  UPStackButtonDemo
//
//  Created by Paul Ulric on 21/01/2015.
//  Copyright (c) 2015 Paul Ulric. All rights reserved.
//

#import "UPStackMenu.h"


const static CGFloat                    kStackMenuDefaultItemsSpacing                   = 15;
const static UPStackMenuStackPosition_e kStackMenuDefaultStackPosition                  = UPStackMenuStackPosition_up;
const static UPStackMenuAnimationType_e kStackMenuDefaultAnimationType                  = UPStackMenuAnimationType_progressive;
const static BOOL                       kStackMenuDefaultBouncingAnimation              = YES;
const static NSTimeInterval             kStackMenuDefaultOpenAnimationDuration          = 0.4;
const static NSTimeInterval             kStackMenuDefaultCloseAnimationDuration         = 0.4;
const static NSTimeInterval             kStackMenuDefaultOpenAnimationDurationOffset    = 0.0;
const static NSTimeInterval             kStackMenuDefaultCloseAnimationDurationOffset   = 0.0;



@interface UPStackMenu() {
    UIButton *_baseButton;
    NSMutableArray *_items;
    
    CGSize _openedSize;
    CGPoint _baseButtonOpenedCenter;
    
    BOOL _isAnimating;
    NSUInteger _animatedItemTag;
}
@end


@implementation UPStackMenu

- (id)initWithImage:(UIImage*)img inSelection:(BOOL)arg
{
    _conView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_conView setBackgroundColor:[UIColor colorWithRed:0.094 green:0.557 blue:0.996 alpha:1.000]/*[DesignManager knoteNavigationBarTintColor]*/];
    [_conView.layer setCornerRadius:20];
    _icon = [[UIImageView alloc] initWithImage:img];
    [_icon setContentMode:UIViewContentModeScaleAspectFit];
    [_icon setFrame:CGRectInset(_conView.frame, 10, 10)];
    [_conView addSubview:_icon];
    [self setClipsToBounds:YES];
    self = [super initWithFrame:_conView.frame];
    if(self) {
        
        CGRect contentFrame = _conView.frame;
        contentFrame.origin = CGPointZero;
        [_conView setFrame:contentFrame];
        self.isSelector=arg;
        _baseButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_baseButton setFrame:contentFrame];
        [_baseButton addTarget:self action:@selector(toggleStack:) forControlEvents:UIControlEventTouchUpInside];
        [_baseButton addSubview:_conView];
        [_conView setUserInteractionEnabled:NO];
        [self addSubview:_baseButton];
        
        [_baseButton addObserver:self forKeyPath:@"center" options:NSKeyValueObservingOptionNew context:nil];
        
        _items = [NSMutableArray new];
        _openedSize = _baseButton.frame.size;
        _conView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:_conView.bounds cornerRadius:20.0f].CGPath;
        _conView.layer.masksToBounds = false;
        _conView.layer.shadowOffset = CGSizeMake(0, 0.5);
        _conView.layer.shadowOpacity = 1;
        _conView.layer.shadowColor = [[UIColor blackColor] CGColor];
        _conView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        _itemsSpacing                  =  kStackMenuDefaultItemsSpacing;
        _stackPosition                 =  kStackMenuDefaultStackPosition;
        _animationType                 =  kStackMenuDefaultAnimationType;
        _bouncingAnimation             =  kStackMenuDefaultBouncingAnimation;
        _openAnimationDuration         =  kStackMenuDefaultOpenAnimationDuration;
        _closeAnimationDuration        =  kStackMenuDefaultCloseAnimationDuration;
        _openAnimationDurationOffset   =  kStackMenuDefaultOpenAnimationDurationOffset;
        _closeAnimationDurationOffset  =  kStackMenuDefaultCloseAnimationDurationOffset;
    }
    return self;
}
- (void) dealloc
{
    [_baseButton removeObserver:self forKeyPath:@"center"];
}


#pragma mark - Items management

- (void)addItem:(UPStackMenuItem*)item computeSize:(BOOL)compute
{
    if(_isOpen || _isAnimating)
        return;
    
    [item setDelegate:self];
    [item reduceAnimated:NO withDuration:0];
    [_items addObject:item];
    
//    [item setAlpha:0.];
    
    CGPoint convertedCenter = [item centerForItemCenter:_baseButton.center];
    [item setCenter:convertedCenter];
    [self insertSubview:item atIndex:0];
    
    if(compute)
        [self computeOpenedSize];
}

- (void)addItem:(UPStackMenuItem*)item
{
    [self addItem:item computeSize:YES];
}

- (void)addItems:(NSArray*)items
{
    [items enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addItem:obj computeSize:NO];
    }];
    
    [self computeOpenedSize];
}

- (void)removeItem:(UPStackMenuItem*)item computeSize:(BOOL)compute
{
    if(![_items containsObject:item])
        return;
    
    [item removeFromSuperview];
    [_items removeObject:item];
    
    if(compute)
        [self computeOpenedSize];
}

- (void)removeItem:(UPStackMenuItem*)item
{
    [self removeItem:item computeSize:YES];
}

- (void)removeItemAtIndex:(NSUInteger)index
{
    if(index >= [_items count])
        return;
    
    UPStackMenuItem *item = [_items objectAtIndex:index];
    [self removeItem:item computeSize:YES];
}

- (void)removeAllItems
{
    [_items enumerateObjectsUsingBlock:^(UPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
        [self removeItem:item computeSize:NO];
    }];
    
    [self computeOpenedSize];
}

- (NSArray*)items
{
    return [NSArray arrayWithArray:_items];
}


#pragma mark - Helpers

- (void)computeOpenedSize
{
    CGPoint center = CGPointMake(_baseButton.frame.size.width/2, _baseButton.frame.size.height/2);
    
    __block CGFloat height = _baseButton.frame.size.height;
    __block CGFloat leftOffset = 0;
    __block CGFloat rightOffset = 0;
    
    [_items enumerateObjectsUsingBlock:^(UPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
        height += item.frame.size.height + _itemsSpacing;
        
        if([item labelPosition] == UPStackMenuItemLabelPosition_left) {
            CGFloat itemLeftOffset = fabsf(center.x - item.itemCenter.x);
            if(itemLeftOffset > leftOffset)
                leftOffset = itemLeftOffset;
        }
        else if([item labelPosition] == UPStackMenuItemLabelPosition_right) {
            CGFloat itemRightOffset = fabsf(item.frame.size.width - item.itemCenter.x - center.x);
            if(itemRightOffset > rightOffset)
                rightOffset = itemRightOffset;
        }
    }];
    
    if([_items count] > 0)
        height += _itemsSpacing;
    
    CGFloat width = leftOffset + _baseButton.frame.size.width + rightOffset;
    
    _openedSize = CGSizeMake(width, height);
    
    CGFloat baseButtonCenterY = _baseButton.frame.size.height/2;
    if(_stackPosition == UPStackMenuStackPosition_up)
        baseButtonCenterY = _openedSize.height - _baseButton.frame.size.height/2;
    _baseButtonOpenedCenter = CGPointMake(leftOffset + _baseButton.frame.size.width/2, baseButtonCenterY);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([object isEqual:_baseButton]) {
        if([keyPath isEqualToString:@"center"]) {
            [_items enumerateObjectsUsingBlock:^(UPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
                CGPoint convertedCenter = [item centerForItemCenter:_baseButton.center];
                [item setCenter:convertedCenter];
            }];
        }
    }
}


#pragma mark - Customization

- (void)setStackPosition:(UPStackMenuStackPosition_e)stackPosition
{
    if(_isOpen) {
        NSLog(@"[UPStackMenu] Warning: trying to modify the stackPosition while the stack is open. No effect.");
        return;
    }
    
    _stackPosition = stackPosition;
    [self computeOpenedSize];
}

- (void)setItemsSpacing:(CGFloat)itemsSpacing
{
    _itemsSpacing = itemsSpacing;
    [self computeOpenedSize];
}


#pragma mark - Interactions

- (void)toggleStack:(id)sender
{
    if (self.isSelector)
    {
        if ([self.delegate respondsToSelector:@selector(openStackwithSelector)])
        {
            [self.delegate openStackwithSelector];
        }
    }
    else
    {
    if(!_isOpen)
        [self openStack];
    else
        [self closeStack];
    }
}

- (void)openStack
{
    if(_isAnimating || _isOpen)
        return;
    
    _isAnimating = YES;
    _animatedItemTag = 0;
    
    if(_delegate && [_delegate respondsToSelector:@selector(stackMenuWillOpen:)])
        [_delegate stackMenuWillOpen:self];
    
    CGRect frame = self.frame;
    frame.size = _openedSize;
    frame.origin.x -= _baseButtonOpenedCenter.x - _baseButton.frame.size.width/2;
    CGFloat yOffset = _baseButtonOpenedCenter.y - _baseButton.frame.size.height/2;
    frame.origin.y -= (_stackPosition == UPStackMenuStackPosition_up) ? yOffset : yOffset*(-1);
    [self setFrame:frame];
    
    [_baseButton setCenter:_baseButtonOpenedCenter];
    
    NSUInteger itemsCount = [_items count];
    
    NSInteger way = (_stackPosition == UPStackMenuStackPosition_up) ? -1 : 1;
    __block CGFloat y = _baseButton.frame.origin.y - _itemsSpacing;
    if(_stackPosition == UPStackMenuStackPosition_down)
        y = _baseButton.frame.origin.y + _baseButton.frame.size.height + _itemsSpacing;
    
    [_items enumerateObjectsUsingBlock:^(UPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
        NSTimeInterval duration = _openAnimationDuration;
        if(_animationType == UPStackMenuAnimationType_progressive)
            duration = ((idx + 1) * _openAnimationDuration) / itemsCount;
        else if(_animationType == UPStackMenuAnimationType_progressiveInverse)
        duration = ((itemsCount - idx) * _openAnimationDuration) / itemsCount;
        
        CGPoint center = CGPointMake(_baseButton.center.x, y + (item.frame.size.height/2 * way));
        CGPoint translatedCenter = [item centerForItemCenter:center];
        
        int64_t delay = idx * (_openAnimationDurationOffset*1000);
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (delay * NSEC_PER_MSEC));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [self moveItem:item toCenter:translatedCenter withDuration:duration opening:YES bouncing:_bouncingAnimation];
        });
        
        y += (item.frame.size.height + _itemsSpacing) * way;
    }];
    _shadowView=[[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    _shadowView.backgroundColor=[UIColor colorWithWhite:0.963 alpha:0.620];
    UITapGestureRecognizer *tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapOnblank)];
    [_shadowView addGestureRecognizer:tap];
    _shadowView.userInteractionEnabled=YES;
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    NSLog(@"%@",appDelegate.window);
    [appDelegate.window addSubview:_shadowView];
    [appDelegate.window bringSubviewToFront:self];
    _isOpen = YES;
}
-(void)tapOnblank
{
    [self toggleStack:nil];
}
- (void)closeStack
{
    if(_isAnimating || !_isOpen)
        return;
    
    _isAnimating = YES;
    _animatedItemTag = 0;
    
    if(_delegate && [_delegate respondsToSelector:@selector(stackMenuWillClose:)])
        [_delegate stackMenuWillClose:self];
    
    NSUInteger itemsCount = [_items count];
    
    [_items enumerateObjectsUsingBlock:^(UPStackMenuItem *item, NSUInteger idx, BOOL *stop) {
        NSTimeInterval duration = _closeAnimationDuration;
        if(_animationType == UPStackMenuAnimationType_progressive)
            duration = ((idx + 1) * _closeAnimationDuration) / itemsCount;
        else if(_animationType == UPStackMenuAnimationType_progressiveInverse)
        duration = ((itemsCount - idx) * _closeAnimationDuration) / itemsCount;
        
        CGPoint translatedCenter = [item centerForItemCenter:_baseButton.center];
        
        int64_t delay = idx * (_closeAnimationDurationOffset*1000);
        dispatch_time_t time = dispatch_time(DISPATCH_TIME_NOW, (delay * NSEC_PER_MSEC));
        dispatch_after(time, dispatch_get_main_queue(), ^{
            [self moveItem:item toCenter:translatedCenter withDuration:duration opening:NO bouncing:_bouncingAnimation];
        });
    }];
    if (_shadowView)
    {
        [_shadowView removeFromSuperview];
        _shadowView=nil;
    }
    _isOpen = NO;
}

- (void)moveItem:(UPStackMenuItem*)item toCenter:(CGPoint)center withDuration:(NSTimeInterval)duration opening:(BOOL)opening bouncing:(BOOL)bouncing
{
    CGPoint farCenter;
    CGPoint nearCenter;
    
    NSInteger way = (_stackPosition == UPStackMenuStackPosition_up) ? -1 : 1;
    if(bouncing) {
        CGFloat bouncingOffset = _itemsSpacing * way;
        if(opening) {
            farCenter = CGPointMake(center.x, center.y + bouncingOffset);
            nearCenter = CGPointMake(center.x, center.y + (bouncingOffset/2)*-1);
        } else
            farCenter = CGPointMake(item.center.x, item.center.y + bouncingOffset);
    }
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.center.x, item.center.y);
    if(bouncing) {
        CGPathAddLineToPoint(path, NULL, farCenter.x, farCenter.y);
        if(opening)
            CGPathAddLineToPoint(path, NULL, nearCenter.x, nearCenter.y);
    }
    CGPathAddLineToPoint(path, NULL, center.x, center.y);
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = @[positionAnimation];
    animationgroup.duration = duration;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationgroup.delegate = self;
    [item.layer addAnimation:animationgroup forKey:@"move"];
    
    item.center = center;
    
    if(opening)
        [item expandAnimated:YES withDuration:duration];
    else
        [item reduceAnimated:YES withDuration:duration];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{    
    _animatedItemTag++;
    if(_animatedItemTag < [_items count])
        return;
        
    if(_isOpen) {
        if(_delegate && [_delegate respondsToSelector:@selector(stackMenuDidOpen:)])
            [_delegate stackMenuDidOpen:self];
    }
    else {
        CGRect frame = self.frame;
        frame.size = _baseButton.frame.size;
        frame.origin.x += _baseButton.frame.origin.x;
        if(_stackPosition == UPStackMenuStackPosition_up)
            frame.origin.y += _baseButton.frame.origin.y;
        [self setFrame:frame];
        
        [_baseButton setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
        
        if(_delegate && [_delegate respondsToSelector:@selector(stackMenuDidClose:)])
            [_delegate stackMenuDidClose:self];
    }
    _isAnimating = NO;
}


#pragma mark - UPStackMenuItemDelegate

- (void)didTouchStackMenuItem:(UPStackMenuItem *)item
{
    [self toggleStack:nil];
    if(_delegate && [_delegate respondsToSelector:@selector(stackMenu:didTouchItem:atIndex:)]) {
        NSUInteger index = [_items indexOfObject:item];
        if(index != NSNotFound)
            [_delegate stackMenu:self didTouchItem:item atIndex:index];
    }
}

@end
// Copyright belongs to original author
// http://code4app.net (en) http://code4app.com (cn)
// From the most professional code share website: Code4App.net