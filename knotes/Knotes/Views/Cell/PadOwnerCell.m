//
//  WorkoutsCell.m
//  PerfectBody
//
//  Created by JYN on 8/12/13.
//  Copyright (c) 2013 jackiejin. All rights reserved.
//

#import "PadOwnerCell.h"

#import "CUtil.h"
#import "Constant.h"
#import "DesignManager.h"

@interface PadOwnerCell ()

@property (nonatomic, assign) BOOL didSetupConstraints;

@property (nonatomic, strong) UIButton  *btn1;
@property (nonatomic, strong) UIButton  *btn2;
@property (nonatomic, strong) UIButton  *closebutton;
@property (nonatomic, strong) UIView    *shadeView;
@property (nonatomic, strong) UIView    *underLine;
@property (nonatomic, strong) UIActivityIndicatorView *activity;

@end

@implementation PadOwnerCell

@synthesize imgView = _imgView;
@synthesize lbTitle = _lbTitle;
@synthesize lbDescription = _lbDescription;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        self.shadeView = [UIView new];
        self.shadeView.backgroundColor = [UIColor clearColor];
        self.shadeView.opaque = NO;
        
        [self.contentView addSubview:self.shadeView];
        [self.contentView sendSubviewToBack:self.shadeView];
        _imgView = [[GBPathImageView alloc] initWithFrame:CGRectMake(0,0, self.frame.size.height, self.frame.size.height) image:nil pathType:GBPathImageViewTypeCircle pathColor:[UIColor clearColor] borderColor:[UIColor clearColor] pathWidth:.01];
        [self.contentView addSubview:_imgView];

        _lbTitle = [[UILabel alloc] init];
        _lbTitle.backgroundColor = [UIColor clearColor];
        //_lbTitle.font = kCustomLightFont(18);
        _lbTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:USERNAME_FONT_SIZE]/*[UIFont fontWithName:USERNAME_FONT_NAME size:USERNAME_FONT_SIZE]*/;
        _lbTitle.textColor = [DesignManager knoteHeaderTextColor];
        _lbTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_lbTitle];

        _lbDescription = [[UILabel alloc] init];
        _lbDescription.backgroundColor = [UIColor clearColor];
        _lbDescription.font = kCustomLightFont(12);
        _lbDescription.textColor = [UIColor blackColor];
        _lbDescription.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_lbDescription];
        
        self.btn1 =[UIButton buttonWithType:UIButtonTypeCustom];
        [self.btn1 setImage:[UIImage imageNamed:@"icon-profile"] forState:UIControlStateNormal];
        [self.btn1 setBackgroundImage:[UIImage imageNamed:@"lide-left"] forState:UIControlStateNormal];
        [self.btn1 setBackgroundImage:[UIImage imageNamed:@"copy-hover"] forState:UIControlStateHighlighted];
        
        self.btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.btn2 setBackgroundImage:[UIImage imageNamed:@"lide-mid"] forState:UIControlStateNormal];
        [self.btn2 setBackgroundImage:[UIImage imageNamed:@"del-hover"] forState:UIControlStateHighlighted];
        
        
        // Close Button
        
        self.closebutton =[UIButton buttonWithType:UIButtonTypeCustom];
        [self.closebutton setBackgroundImage:[UIImage imageNamed:@"close_padWhite"] forState:UIControlStateNormal];
        [self.closebutton setBackgroundImage:[UIImage imageNamed:@"close_padWhite"] forState:UIControlStateHighlighted];

        self.closebutton.tintColor=[UIColor whiteColor];
        
        [self.closebutton setFrame:CGRectMake(260, 0, 60, 60)];
        
        [self.closebutton addTarget:self action:@selector(onCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.btn1];
        [self.contentView addSubview:self.btn2];
        
        [self.contentView addSubview:self.closebutton];

        self.btn1.tag = btnOperProfile;
        self.btn2.tag = btnOperDelete;
        
        [self.btn1 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.btn2 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        self.btn1.translatesAutoresizingMaskIntoConstraints = NO;

        self.btn2.translatesAutoresizingMaskIntoConstraints = NO;
        self.lbDescription.translatesAutoresizingMaskIntoConstraints = NO;
        self.lbTitle.translatesAutoresizingMaskIntoConstraints = NO;
        self.shadeView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.underLine = [[UIView alloc] init];
        self.underLine.backgroundColor = kSeperatorColorClear;
        
        [self.contentView addSubview:self.underLine];
        [self.contentView sendSubviewToBack:self.underLine];
        
    }
    return self;
}

- (void)setArchived:(BOOL)flag
{
    if (flag)
    {
        [self.btn2 setImage:[UIImage imageNamed:@"icon_act"]
                   forState:UIControlStateNormal];
    }
    else
    {
        [self.btn2 setImage:[UIImage imageNamed:@"icon_done"]
                   forState:UIControlStateNormal];
    }
}

-(void)buttonClicked:(UIButton *)btn
{
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    if (self.didSetupConstraints) return;
    [self.underLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(1));
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
    [self.shadeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.left.equalTo( self.mas_left);
        make.right.equalTo(self.mas_right);
        
    }];
    [_imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(IMAGE_SIZE));
        make.width.equalTo(@(IMAGE_SIZE));
        make.top.equalTo(self.shadeView).with.offset(       8.0);
        make.right.equalTo(self.shadeView).with.offset(-60.0);
        //make.left.equalTo(self.shadeView).with.offset(      16.0);
    }];
    
    [_lbDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shadeView).with.offset(       54.0);
        //make.bottom.equalTo(self.shadeView).with.offset(    -8.0);
        //make.left.equalTo(self.shadeView).with.offset(      8.0);
        make.centerX.equalTo(_imgView).with.offset(0.0);
    }];
    
    [_lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shadeView).with.offset(       8.0);
        make.bottom.equalTo(self.shadeView).with.offset(    -8.0);
        make.left.equalTo(self.shadeView).with.offset(      8.0);
        make.right.equalTo(self.shadeView).with.offset(     -18.0);
    }];
    
    CGFloat padding = 0;
    [self.btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shadeView.mas_top).offset(padding);
        make.left.equalTo(self.lbTitle).offset(padding);
        make.bottom.equalTo(self.shadeView.mas_bottom).offset(-padding);
        make.right.equalTo(self.btn2.mas_left).offset(-padding);
        make.width.equalTo(self.btn2.mas_width);
        make.height.equalTo(self.btn2.mas_height);
    }];
    
    [self.btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shadeView.mas_top).offset(padding);
        make.left.equalTo(self.btn1.mas_right).offset(padding);
        make.bottom.equalTo(self.shadeView.mas_bottom).offset(-padding);
        make.right.equalTo(self.shadeView.mas_left).offset(-padding);
        make.width.equalTo(self.btn1.mas_width);
        make.height.equalTo(self.btn1.mas_height);
    }];
    
    self.didSetupConstraints = YES;
}

-(void)setEditor:(BOOL)editor
{
    [self setEditor:editor animate:YES];
}

-(void)setEditor:(BOOL)editor animate:(BOOL)animate
{
    if (editor == _editor)
        return;
    
    _editor = editor;
    
    void (^updateConstraintsForEditing)(void) = ^void {
        __block CGFloat offset = 0;
        if (self.editor) {
            offset = 120;
        }
        [self.shadeView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo( self.mas_left).offset(offset);
        }];
        [self layoutIfNeeded];
    };
    
    if (animate) {
        [UIView animateWithDuration:.2f animations:updateConstraintsForEditing];
    } else {
        updateConstraintsForEditing();
    }
}

- (void)showActivity
{
    if (!_activity) {
        self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self addSubview:self.activity];
        [self.activity setFrame:CGRectMake(self.frame.size.width-_activity.frame.size.width, 0, _activity.frame.size.width, _activity.frame.size.height)];
    }
    [self.activity startAnimating];
}

- (void)stopActivity
{
    if (_activity) {
        [self.activity stopAnimating];
        [self.activity removeFromSuperview];
        self.activity = nil;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}


- (IBAction)onCloseButton:(id)sender
{
    if ([[self targetDelegate]respondsToSelector:@selector(CloseContactOwner)])
    {
        [[self targetDelegate] CloseContactOwner];
    }
}

@end
