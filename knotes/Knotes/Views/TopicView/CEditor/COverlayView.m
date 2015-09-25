//
//  COverlayView.m
//  DAContextMenuTableViewControllerDemo
//
//  Created by Daria Kopaliani on 7/25/13.
//  Copyright (c) 2013 Daria Kopaliani. All rights reserved.
//

#import "COverlayView.h"
@interface COverlayView ()

@property (strong, nonatomic) UIButton *editButton;
@property (strong, nonatomic) UIButton *deleteButton;
@property (strong, nonatomic) UIButton *likeButton;
@property (nonatomic) bool isEdit;

@end

@implementation COverlayView

#if 0 //Can we remove all this?
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    self.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
    _editable = YES;
    self.editButtonTitle = @"Edit";
    self.deleteButtonTitle = @"Delete";
    self.likeButtonTitle = @"Like";
    self.userInteractionEnabled = YES;
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat height = CGRectGetHeight(self.bounds)/3;
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat menuOptionButtonWidth = [self menuOptionButtonWidth];
    CGFloat startY = 0;

    self.deleteButton.frame = CGRectMake(width - menuOptionButtonWidth, startY, menuOptionButtonWidth, height);
    startY+=height;
    self.editButton.frame = CGRectMake(width - menuOptionButtonWidth, startY, menuOptionButtonWidth, height);
    startY+=height;
    self.likeButton.frame = CGRectMake(width - menuOptionButtonWidth, startY, menuOptionButtonWidth, height);
}

- (CGFloat)menuOptionButtonWidth
{
    return 100;
}

- (void)setDeleteButtonTitle:(NSString *)deleteButtonTitle
{
    _deleteButtonTitle = deleteButtonTitle;
    [self.deleteButton setTitle:deleteButtonTitle forState:UIControlStateNormal];
    [self setNeedsLayout];
}

- (void)setLikeButtonTitle:(NSString *)likeButtonTitle
{
    _likeButtonTitle = likeButtonTitle;
    [self.likeButton setTitle:likeButtonTitle forState:UIControlStateNormal];
    [self setNeedsLayout];
}

-(void)setEditButtonTitle:(NSString *)editButtonTitle
{
    _editButtonTitle = editButtonTitle;
    [self.editButton setTitle:editButtonTitle forState:UIControlStateNormal];
    [self setNeedsLayout];
}

#pragma mark * Lazy getters

- (UIButton *)editButton
{
    if (self.editable) {
        if (!_editButton) {
            _editButton = [[UIButton alloc] initWithFrame:CGRectZero];
            _editButton.tag = editTag;
            _editButton.backgroundColor = [UIColor colorWithRed:106./255. green:162./255. blue:187./255. alpha:1.];
            [self addSubview:_editButton];
            [_editButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        return _editButton;
    }
    return nil;
    
}

- (UIButton *)deleteButton
{
    if (self.editable) {
        if (!_deleteButton) {
            _deleteButton = [[UIButton alloc] initWithFrame:CGRectZero];
            _deleteButton.tag = deleteTag;
            _deleteButton.backgroundColor = [UIColor colorWithRed:146./255. green:72./255. blue:78./255. alpha:1.];
            [self addSubview:_deleteButton];
            [_deleteButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        return _deleteButton;
    }
    return nil;
}

- (UIButton *)likeButton
{
    if (self.editable) {
        if (!_likeButton) {
            _likeButton = [[UIButton alloc] initWithFrame:CGRectZero];
            _likeButton.tag = likeTag;
            _likeButton.backgroundColor = [UIColor colorWithRed:60.0/255. green:86./255. blue:177./255. alpha:1.];
            [self addSubview:_likeButton];
            [_likeButton addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        }
        return _likeButton;
    }
    return nil;
}

-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    NSLog(@"%d",self.userInteractionEnabled);
}

- (void)buttonTapped:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    NSLog(@"%@",btn);
}

#endif

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    return [self.delegate overlayView:self didHitTest:point withEvent:event];
}
@end
