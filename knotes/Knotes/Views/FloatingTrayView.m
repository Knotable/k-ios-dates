//
//  FloatingTrayView.m
//  Knotable
//
//  Created by Martin Ceperley on 1/17/14.
//
//

#import "FloatingTrayView.h"

#import "View+MASAdditions.h"
#import "UIButton+Extensions.h"

static const float WIDTH = 140.0;
static const float HEIGHT = 40.0;

static const float SIDE_PADDING = 20.0;
static const float BOTTOM_PADDING = 20.0;

@interface FloatingTrayView ()

@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) BOOL expanded;

@property (nonatomic, strong) UIView                    *bgView;
@property (nonatomic, strong) UIImageView               *leftArrowImage;
@property (nonatomic, strong) UITapGestureRecognizer    *tapRecognizer;

@property (nonatomic, strong) MASConstraint *widthConstraint;
@property (nonatomic, strong) MASConstraint *leftConstraint;

@end

@implementation FloatingTrayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.expanded = NO;
        self.animating = NO;
        self.bgView = [UIView new];
        [self addSubview:self.bgView];
        [self sendSubviewToBack:self.bgView];
        
        _leftArrowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"left-arrow-white"]];
        [self addSubview:_leftArrowImage];
        
        _tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        [self addGestureRecognizer:_tapRecognizer];
        
        self.reorderButton =[[UIButton alloc] initWithFrame:CGRectZero]; //Darshana
        [self.reorderButton setImage:[UIImage imageNamed:@"Reorder_icon.png"] forState:UIControlStateNormal];
        [self.reorderButton setImage:[UIImage imageNamed:@"Reorder_icon_selected"] forState: UIControlStateSelected];
         [self.reorderButton setImage:[UIImage imageNamed:@"Reorder_icon_selected"] forState: UIControlStateHighlighted];
        self.reorderButton.hidden=YES;
        [self addSubview:self.reorderButton];
        
        UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapOnce:)];
        UITapGestureRecognizer *tapTwice = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapTwice:)];
        
        
        tapOnce.numberOfTapsRequired = 1;
        tapTwice.numberOfTapsRequired = 2;
        
        //stops tapOnce from overriding tapTwice
        [tapOnce requireGestureRecognizerToFail:tapTwice];
        
        //then need to add the gesture recogniser to a view - this will be the view that recognises the gesture
        [self.reorderButton addGestureRecognizer:tapOnce]; //remove the other button action which calls method `button`
        [self.reorderButton addGestureRecognizer:tapTwice];

        _alphabeticalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_alphabeticalButton addTarget:self action:@selector(alphabeticalPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_alphabeticalButton setImage:[UIImage imageNamed:@"alphabetical_sorting-48-gray"] forState:UIControlStateNormal];
        [_alphabeticalButton setImage:[UIImage imageNamed:@"alphabetical_sorting-48-white"] forState:UIControlStateHighlighted];
        [_alphabeticalButton setImage:[UIImage imageNamed:@"alphabetical_sorting-48-white"] forState:UIControlStateSelected];
        _alphabeticalButton.adjustsImageWhenHighlighted = NO;
        [_alphabeticalButton setContentEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        
        _archivedButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_archivedButton addTarget:self action:@selector(archivedPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [_archivedButton setImage:[UIImage imageNamed:@"Archive_icon.png"] forState:UIControlStateNormal];
        [_archivedButton setImage:[UIImage imageNamed:@"Archive_icon_selected.png"] forState:UIControlStateHighlighted];
        [_archivedButton setImage:[UIImage imageNamed:@"Archive_icon_selected.png"] forState:UIControlStateSelected];
        _archivedButton.adjustsImageWhenHighlighted = NO;
        [_archivedButton setContentEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        [_archivedButton setHidden:YES];
        [self addSubview:_archivedButton];
        bShowArchived = YES;
        UITapGestureRecognizer *tapArchive1 = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(tapArchive1:)];
        tapArchive1.numberOfTapsRequired = 1;
        
        //then need to add the gesture recogniser to a view - this will be the view that recognises the gesture
        [self.archivedButton addGestureRecognizer:tapArchive1]; //remove the other button action which calls method `button`
        
        _lockButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lockButton addTarget:self action:@selector(lockPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [_lockButton setImage:[UIImage imageNamed:@"lock-knote-selected"] forState:UIControlStateNormal];
        [_lockButton setImage:[UIImage imageNamed:@"lock-knote"] forState:UIControlStateHighlighted];
        [_lockButton setImage:[UIImage imageNamed:@"lock-knote-selected"] forState:UIControlStateSelected];
        _lockButton.adjustsImageWhenHighlighted = NO;
        [_lockButton setContentEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        
        bShowLock = NO;
        
        
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton addTarget:self action:@selector(sharePressed:) forControlEvents:UIControlEventTouchUpInside];
        
        [_shareButton setImage:[UIImage imageNamed:@"person-icon"] forState:UIControlStateNormal];
        [_shareButton setImage:[UIImage imageNamed:@"person-icon-selected"] forState:UIControlStateHighlighted];
        [_shareButton setImage:[UIImage imageNamed:@"person-icon"] forState:UIControlStateSelected];
        _shareButton.adjustsImageWhenHighlighted = NO;
        [_shareButton setContentEdgeInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
        
        bShowShare = NO;
        
    }
    return self;
}

-(void)tapOnce:(UIGestureRecognizer *)gestureRecognizer
{
    self.reorderButton.selected = !self.reorderButton.selected;
    if(self.delegate && [self.delegate respondsToSelector:@selector(floatingTraysetReorder:)]){
        [self.delegate floatingTraysetOneReorder:self.reorderButton.selected];
    }
    
}

-(void)tapTwice:(UIGestureRecognizer *)gestureRecognizer
{
    self.reorderButton.selected = !self.reorderButton.selected;
    if(self.delegate && [self.delegate respondsToSelector:@selector(floatingTraysetReorder:)]){
        [self.delegate floatingTraysetReorder:self.reorderButton.selected];
    }
    
}

-(void)tapArchive1:(UIGestureRecognizer *)gestureRecognizer
{
    self.archivedButton.selected = !self.archivedButton.selected;
    if(self.delegate && [self.delegate respondsToSelector:@selector(floatingTraySetArchived:)]){
        [self.delegate floatingTraySetArchived:self.archivedButton.selected];
    }
    
}

-(void)showReorder:(BOOL)bShow
{
    
    self.leftArrowImage.hidden =!bShow;
    self.reorderButton.hidden=bShow;
}

-(void)showArchived:(BOOL)bShow
{
    bShowArchived = bShow;
    _archivedButton.hidden = !bShowArchived;
}

-(void)showLock:(BOOL)bShow
{
    bShowLock = bShow;
    _lockButton.hidden = !bShowLock;
}

-(void)showShare:(BOOL)bShow
{
    bShowShare = bShow;
    _shareButton.hidden = !bShowShare;
}

-(void)alphabeticalPressed:(UIButton *)button
{
    button.selected = !button.selected;
    if(self.delegate && [self.delegate respondsToSelector:@selector(floatingTraySetAlphabetical:)]){
        [self.delegate floatingTraySetAlphabetical:button.selected];
    }
}

-(void)archivedPressed:(UIButton *)button
{
    button.selected = !button.selected;
    if(self.delegate && [self.delegate respondsToSelector:@selector(floatingTraySetArchived:)]){
        [self.delegate floatingTraySetArchived:button.selected];
    }
}

-(void)lockPressed:(UIButton *)button
{
    button.selected = !button.selected;
    if(self.delegate && [self.delegate respondsToSelector:@selector(floatingTrayLock)]){
        [self.delegate floatingTrayLock];
    }
}

-(void)sharePressed:(UIButton *)button
{
    button.selected = !button.selected;
    if(self.delegate && [self.delegate respondsToSelector:@selector(floatingTrayShared:)]){
        [self.delegate floatingTrayShared:nil];
    }
}

-(void)installConstraints
{
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(HEIGHT));
        self.widthConstraint = make.width.equalTo(@(WIDTH));
        make.right.equalTo(@(-SIDE_PADDING));
        make.bottom.equalTo(@(-BOTTOM_PADDING));
    }];
    
    [_leftArrowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(@0.0);
        make.right.equalTo(@-8.0);
    }];
    [_reorderButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(@0.0);
        make.right.equalTo(@-8.0);
    }];
    [_archivedButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(@0.0);
        make.right.equalTo(@-56.0);
    }];
    [_bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self).offset(-30);
    }];
}

-(void)tapped:(UITapGestureRecognizer *)recognizer
{
    if(self.leftArrowImage.hidden)
        return;
    if(!_expanded){
        [self.widthConstraint uninstall];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            self.leftConstraint = make.left.equalTo(@(SIDE_PADDING));
        }];
        
        _archivedButton.alpha = 0.0;
        _alphabeticalButton.alpha = 0.0;
        _lockButton.alpha = 0.0;
        _shareButton.alpha = 0.0;
        
        [self addSubview:_archivedButton];
        [self addSubview:_alphabeticalButton];
        [self addSubview:_lockButton];
        [self addSubview:_shareButton];
        [_alphabeticalButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(@0.0);
            make.left.equalTo(@30.0);
        }];
        [_archivedButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(@0.0);
            make.left.equalTo(_alphabeticalButton.mas_right).with.offset(15.0);
        }];
        [_lockButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(@0.0);
            make.left.equalTo(_archivedButton.mas_right).with.offset(15.0);
        }];
        [_shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(@0.0);
            make.left.equalTo(_lockButton.mas_right).with.offset(15.0);
        }];
        
        [_archivedButton setHidden:!bShowArchived];
        [_lockButton setHidden:!bShowLock];
        [_shareButton setHidden:!bShowShare];

        self.bgView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
        self.bgView.layer.cornerRadius = 6.0;
        self.bgView.clipsToBounds = NO;
        
    } else {
        self.bgView.backgroundColor = [UIColor clearColor];
        self.bgView.layer.cornerRadius = 0.0;
        self.bgView.clipsToBounds = NO;
        
        [self.leftConstraint uninstall];
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            self.widthConstraint = make.width.equalTo(@(WIDTH));
        }];
    }
    
    self.animating = YES;
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.7
          initialSpringVelocity:0.2
                        options:0
                     animations:^{
                         
                         if(!_expanded){
                             _archivedButton.alpha = 1.0;
                             _alphabeticalButton.alpha = 1.0;
                             _lockButton  .alpha = 1.0;
                             _shareButton.alpha = 1.0;
                             
                             _leftArrowImage.transform = CGAffineTransformMakeRotation(M_PI);
                         } else {
                             _archivedButton.alpha = 0.0;
                             _alphabeticalButton.alpha = 0.0;
                             _lockButton.alpha = 0.0;
                             _shareButton.alpha = 0.0;
                             
                             _leftArrowImage.transform = CGAffineTransformMakeRotation(0.0);
                             
                         }
                         
                         [self layoutIfNeeded];
                     }
                     completion:^(BOOL finished) {
                         self.expanded = !self.expanded;
                         self.animating = NO;
                         self.userInteractionEnabled = YES;
                         
                         
                         if(!self.expanded){
                             [_archivedButton removeFromSuperview];
                             [_alphabeticalButton removeFromSuperview];
                             [_lockButton removeFromSuperview];
                             [_shareButton removeFromSuperview];
                         }
                         
                     }];
}

@end
