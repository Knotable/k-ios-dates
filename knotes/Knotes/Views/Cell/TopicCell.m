//
//  TopicCell.m
//  Knotable
//
//  Created by Martin Ceperley on 12/16/13.
//
//

#import "TopicCell.h"
#import "TopicInfo.h"
#import "TopicsEntity.h"
#import "DesignManager.h"
#import "UIImage+FontAwesome.h"
#import "UIImage+Tint.h"
#import <Masonry/Masonry.h>

@interface TopicCell ()

@property (nonatomic, strong) UIView *shadeView;

@property (nonatomic, strong) UIButton *action_button;
@property (nonatomic, strong) UIButton *bookMark_button;
@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) CircleView *bookMarkCircle;
@property (nonatomic, strong) UIButton *bookMarkImageForStatusHighlight;
@property (nonatomic, strong) MASConstraint *titleRightContraint;
@property (nonatomic, strong) UIView *underLine;

@end

@implementation TopicCell
@synthesize processRetainCount,processView,offline;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17]/*[UIFont systemFontOfSize:17.0]*/;
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.titleLabel.numberOfLines = 2;
        
        [self.contentView addSubview:self.titleLabel];
        
        self.shadeView = [UIView new];
        self.shadeView.backgroundColor = [DesignManager knoteBackgroundColor];
        self.shadeView.opaque = YES;
        [self.contentView addSubview:self.shadeView];
        [self.contentView sendSubviewToBack:self.shadeView];
        
        self.action_button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self.action_button setImage:[UIImage imageWithIcon:@"fa-check" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] fontSize:14]forState:UIControlStateNormal];
        [self.action_button setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"lide-mid"]]];

        [self.contentView addSubview:self.action_button];
        
        self.bookMark_button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self.bookMark_button setImage:[UIImage imageWithIcon:@"fa-bookmark" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] fontSize:18]forState:UIControlStateNormal];
        [self.bookMark_button setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"lide-mid"]]];
        [self.bookMark_button addTarget:self
                                 action:@selector(bookMarkButtonAction:)
                       forControlEvents:UIControlEventTouchUpInside];
        
        [self.contentView addSubview:self.bookMark_button];
        self.action_button.tag = btnOperDelete;
        [self.action_button addTarget:self
                               action:@selector(buttonClicked:)
                     forControlEvents:UIControlEventTouchUpInside];
        
        self.activityCircle = [[CircleView alloc] initWithFrame:CGRectZero];
        self.activityCircle.hidden = YES;
        self.activityCircle.tintColor = [UIColor colorWithRed:0.094 green:0.557 blue:0.996 alpha:1.000]/*[DesignManager knoteUsernameColor]*/;

        self.bookMarkImageForStatusHighlight = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        
        [self.bookMarkImageForStatusHighlight setImage:[UIImage imageWithIcon:@"fa-bookmark" backgroundColor:[UIColor clearColor] iconColor:[UIColor redColor] fontSize:14]forState:UIControlStateNormal];
        self.bookMarkImageForStatusHighlight.hidden = YES;
        
        [self.contentView addSubview:self.bookMarkImageForStatusHighlight];
        [self.contentView addSubview:self.activityCircle];
        
        self.underLine = [[UIView alloc] init];
        self.underLine.backgroundColor = kSeperatorColorClear;
        
        [self.contentView addSubview:self.underLine];
        [self.contentView sendSubviewToBack:self.underLine];
        
    }
    return self;
}

-(void)buttonClicked:(UIButton *)btn
{
    [_tInfo processOperator:(btnOperatorTag)btn.tag];
}

-(void)bookMarkButtonAction:(UIButton *)btn
{
    if (self.tInfo.entity.isBookMarked.boolValue)
    {
        [self.bookMark_button setImage:[UIImage imageWithIcon:@"fa-bookmark" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] fontSize:18]forState:UIControlStateNormal];
    }
    else
    {
        [self.bookMark_button setImage:[UIImage imageWithIcon:@"fa-bookmark" backgroundColor:[UIColor clearColor] iconColor:[UIColor redColor] fontSize:18]forState:UIControlStateNormal];
    }
    
    self.entity.isBookMarked = [NSNumber numberWithBool:!_tInfo.entity.isBookMarked.boolValue];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:Pad_BookMarked_Notification object:nil];
    
    [_tInfo bookMarkTopicOnline:!_tInfo.entity.isBookMarked.boolValue TopicEntity:_tInfo.entity];
}

- (void)showProcess
{
    if (!self.processView)
    {
        self.processView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.processRetainCount = 0;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.processView.color = [UIColor whiteColor];
        self.processView.hidesWhenStopped = YES;
        [self.contentView addSubview:self.processView];
        
        [self.processView setFrame:CGRectMake(self.frame.size.width-self.processView.frame.size.width, 0, self.processView.frame.size.width, self.processView.frame.size.height)];
    });
    self.processRetainCount++;
}

- (void)stopProcess
{
    self.processRetainCount--;
    if (self.processRetainCount <= 0) {
        self.processRetainCount = 0;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.processView stopAnimating];
            [self.processView setHidden:YES];
            [self.processView removeFromSuperview];
            self.processView = nil;
            
        });
    }
}

- (void)showInfo:(InfoType)type
{
}

- (void)hiddenInfo
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
        make.top.equalTo(       @2.0);
        make.bottom.equalTo(    @-2.0);
        make.left.equalTo(      @8.0);
        make.right.equalTo(     @-6.0);
        
    }];
        
    CGFloat padding = 0;
#if 0
    [self.btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shadeView.mas_top).offset(padding);
        make.left.equalTo(self.mas_left).offset(8.0);
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
    
#else
    
    [self.bookMark_button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shadeView.mas_top).offset(padding);
        make.left.equalTo(self.action_button.mas_right).offset(2.0);
        make.bottom.equalTo(self.shadeView.mas_bottom).offset(-padding);
        make.right.equalTo(self.shadeView.mas_left).offset(-padding);
    }];
    
    [self.action_button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.shadeView.mas_top).offset(padding);
        make.left.equalTo(self.mas_left).offset(8.0);
        make.bottom.equalTo(self.shadeView.mas_bottom).offset(-padding);
        make.right.equalTo(self.shadeView.mas_left).offset(-35);
    }];
    
#endif
    
    [self makeConstraints_For_BooMarkStatusSymbol_NewActivity];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self.shadeView).with.offset(       4.0);
        make.bottom.equalTo(self.shadeView).with.offset(    -4.0);
        make.left.equalTo(self.shadeView).with.offset(      22.0);
        make.right.equalTo(self.shadeView).with.offset(     -22.0);
    }];
    
    self.didSetupConstraints = YES;
}

-(void)makeConstraints_For_BooMarkStatusSymbol_NewActivity
{
    [self.activityCircle mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(@10);
        make.centerY.equalTo(@0);
        make.left.equalTo(self.shadeView).with.offset(4.0);
    }];
    
    [self.bookMarkImageForStatusHighlight mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.size.equalTo(@15);
        make.centerY.equalTo(@0);
        make.right.equalTo(self.shadeView).with.offset(-3.0);
    }];
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
        
        if (self.editor)
        {
            offset = 70;
        }
        
        [self.shadeView mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(@(8.0+ offset));
            
        }];
        
        [self layoutIfNeeded];
    };
    
    if (animate)
    {
        [UIView animateWithDuration:.2f animations:updateConstraintsForEditing];
    }
    else
    {
        updateConstraintsForEditing();
    }
}

-(void)setTInfo:(TopicInfo *)tInfo
{
    //Reset editing if it's a new topic and already setup
    
    if ( self.didSetupConstraints
        && _tInfo.entity
        && tInfo.entity
        && ![_tInfo.entity.objectID isEqual:tInfo.entity.objectID] )
    {
        [self setEditor:NO animate:NO];
    }
    
    self.titleLabel.text = tInfo.entity ? tInfo.entity.topic : @"";
    
    _tInfo = tInfo;
    
    if (tInfo.archived)
    {
        [self.action_button setImage:[UIImage imageNamed:@"icon_act"]
                            forState:UIControlStateNormal];
    }
    else
    {
        [self.action_button setImage:[UIImage imageWithIcon:@"fa-check" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] fontSize:14]forState:UIControlStateNormal];
    }
    
    self.activityCircle.hidden = !tInfo.entity.hasNewActivity.boolValue;
    
    self.bookMarkImageForStatusHighlight.hidden = !tInfo.entity.isBookMarked.boolValue;
    
    if (self.tInfo.entity.isBookMarked.boolValue)
    {
        [self.bookMark_button setImage:[UIImage imageWithIcon:@"fa-bookmark" backgroundColor:[UIColor clearColor] iconColor:[UIColor redColor] fontSize:18]forState:UIControlStateNormal];
    }
    else
    {
        [self.bookMark_button setImage:[UIImage imageWithIcon:@"fa-bookmark" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] fontSize:18]forState:UIControlStateNormal];
    }
    
    [self layoutIfNeeded];
    [self setNeedsUpdateConstraints];
    
    if (self.activityCircle.hidden) {
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17]/*[UIFont systemFontOfSize:17.0]*/;
        self.titleLabel.textColor = [DesignManager knoteBodyTextColor];
        self.titleLabel.numberOfLines = 2;
    }
    else
    {
        self.titleLabel.textColor = [UIColor colorWithRed:0.094 green:0.557 blue:0.996 alpha:1.000]/*[DesignManager knoteUsernameColor]*/;
        self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17]/*[UIFont boldSystemFontOfSize:17.0]*/;
    }
    
    //updateConstraintsForBookMarkAndCircle();
}

-(void)setEntity:(TopicsEntity *)entity
{
    if (_entity != entity)
    {
        if (self.didSetupConstraints
            && entity
            && ![entity.objectID isEqual:entity.objectID])
        {
            [self setEditor:NO animate:NO];
        }
        
        self.titleLabel.text = entity ? entity.topic : @"";
        
        _entity = entity;
        
        if (entity.archived)
        {
            [self.action_button setImage:[UIImage imageNamed:@"icon_act"]
                                forState:UIControlStateNormal];
        }
        else
        {
            [self.action_button setImage:[UIImage imageNamed:@"icon_done"]
                                forState:UIControlStateNormal];
        }
        
        self.activityCircle.hidden = !entity.hasNewActivity.boolValue;
        
        if (self.activityCircle.hidden)
        {
            self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17]/*[UIFont systemFontOfSize:17.0]*/;
            self.titleLabel.textColor = [DesignManager knoteBodyTextColor];
            self.titleLabel.numberOfLines = 2;
        }
        else
        {
            self.titleLabel.textColor = [DesignManager knoteUsernameColor];
            self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17]/*[UIFont boldSystemFontOfSize:17.0]*/;
        }
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
}

@end
