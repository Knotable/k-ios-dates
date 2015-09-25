//
//  WorkoutsCell.m
//  PerfectBody
//
//  Created by JYN on 8/12/13.
//  Copyright (c) 2013 jackiejin. All rights reserved.
//

#import "ContactCell.h"
#import "CUtil.h"
#import "Masonry.h"
#import "DesignManager.h"
#import "Constant.h"


@interface ContactCell ()

@property (nonatomic, strong) UIView *shadeView;

@property (nonatomic, assign) BOOL didSetupConstraints;

@property (nonatomic, strong) UIActivityIndicatorView *activity;
@property (nonatomic, strong) UIView    *underLine;
@property (nonatomic, strong) UIView    *grayRect;

@property (nonatomic, strong) UIButton  *btn_showProfile;

@end

@implementation ContactCell

@synthesize imgView = _imgView;
@synthesize lbTitle = _lbTitle;
@synthesize lbDescription = _lbDescription;
@synthesize contactItem = _contactItem;

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
        
        _imgView = [[GBPathImageView alloc] initWithFrame:CGRectMake(0,0, self.frame.size.height, self.frame.size.height)
                                                    image:nil
                                                 pathType:GBPathImageViewTypeCircle
                                                pathColor:[UIColor clearColor]
                                              borderColor:[UIColor clearColor] pathWidth:.01];
        
        [self.contentView addSubview:_imgView];

        _lbTitle = [[UILabel alloc] init];
        _lbTitle.backgroundColor = [UIColor clearColor];
        _lbTitle.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:USERNAME_FONT_SIZE];
        _lbTitle.textColor = [DesignManager knoteHeaderTextColor];
        _lbTitle.lineBreakMode = NSLineBreakByTruncatingTail;
        
        // Lin - Added for Multiline of Contact Name
        
        _lbTitle.numberOfLines = 0;
        
        // Lin - Ended
        
        [self.contentView addSubview:_lbTitle];

        _lbDescription = [[UILabel alloc] init];
        _lbDescription.backgroundColor = [UIColor clearColor];
        _lbDescription.font = kCustomLightFont(12);
        _lbDescription.textColor = [UIColor whiteColor];
        
        [self.contentView addSubview:_lbDescription];
        
        // Close Button
        
        self.btn_showProfile =[UIButton buttonWithType:UIButtonTypeCustom];
        
        [self.btn_showProfile setBackgroundColor:[UIColor clearColor]];
        
        [self.btn_showProfile setBackgroundImage:Nil forState:UIControlStateNormal];
        
        [self.btn_showProfile setFrame:CGRectMake(0, 0, 75, 60)];
        [self.btn_showProfile addTarget:self action:@selector(onShowProfile:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.btn_showProfile];

        self.lbDescription.translatesAutoresizingMaskIntoConstraints = NO;
        self.lbTitle.translatesAutoresizingMaskIntoConstraints = NO;
        self.shadeView.translatesAutoresizingMaskIntoConstraints = NO;
        
        self.underLine = [[UIView alloc] init];
        self.underLine.backgroundColor = kSeperatorColorClear;
        
        [self.contentView addSubview:self.underLine];
        [self.contentView sendSubviewToBack:self.underLine];
        
        [self.contentView sendSubviewToBack:self.underLine];
        
        self.grayRect = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 75, 59)];
        self.grayRect.backgroundColor = [UIColor whiteColor];
        
        [self.shadeView addSubview:self.grayRect];
        [self.shadeView sendSubviewToBack:self.grayRect];
        
        [self.shadeView bringSubviewToFront:self.btn_showProfile];
    
    }
    
    return self;
}

- (void)setArchived:(BOOL)flag
{
    if (flag)
    {
        
    }
    else
    {
        
    }
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
        make.left.equalTo(self.shadeView).with.offset(      16.0);
    }];
    
    [_lbTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shadeView).with.offset(       8.0);
        make.bottom.equalTo(self.shadeView).with.offset(    -8.0);
        make.left.equalTo(self.shadeView).with.offset(      91.0);
        make.right.equalTo(self.shadeView).with.offset(     -35.0);
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
}

- (void)showActivity
{
    if (!_activity)
    {
        self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        
        [self addSubview:self.activity];
        
        [self.activity setFrame:CGRectMake(self.frame.size.width-_activity.frame.size.width, 0, _activity.frame.size.width, _activity.frame.size.height)];
    }
    
    [self.activity startAnimating];
}

- (void)stopActivity
{
    if (_activity)
    {
        [self.activity stopAnimating];
        [self.activity removeFromSuperview];
        
        self.activity = nil;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (IBAction)onShowProfile:(id)sender
{
    if ([[self targetDelegate]respondsToSelector:@selector(ShowProfile:)])
    {
        if (self.contactItem)
        {
            [[self targetDelegate] ShowProfile:self.contactItem];
        }
        else
        {
            [[AppDelegate sharedDelegate] AutoHiddenAlert:@"Error Occured" messageContent:Nil];
        }
    }
}

@end
