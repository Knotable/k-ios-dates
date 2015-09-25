//
//  CEditBaseItemView.m
//  RevealControllerProject
//
//  Created by backup on 13-10-17.
//
//

#import "CEditBaseItemView.h"

#import "CItem.h"
#import "CEditInfoItem.h"

#import "FileEntity.h"
#import "ContactsEntity.h"

#import "CEditInfoBar.h"
#import "IndicatorView.h"
#import "CellBackgroundView.h"
#import "ShowPDFController.h"

#import "DesignManager.h"
#import "DataManager.h"
#import "ThreadItemManager.h"

#import "AppDelegate.h"
#import "CUtil.h"
#import "ObjCMongoDB.h"
#import "FileInfo.h"

#import "UIImage+Tint.h"
#import "UIImage+RoundedCorner.h"
#import "UIImage+FontAwesome.h"

#define kPinHeight          18.0f
#define kPinWidth           18.0f
#define kMoreButtonWith     0.0f
#define kSpaceFromBottom    10.0f

@interface CEditBaseItemView ()<UIGestureRecognizerDelegate,CEditInfoBarDelegate>

@property (nonatomic, weak)     CItem           *itemData;
@property (nonatomic, strong)   IndicatorView   *offLineBtn;

#if NEW_FEATURE
@property (nonatomic, strong)   COperationBar   *ContactBar;
@property (nonatomic, strong)   COperationBar   *operatorBar;
#endif

@property (nonatomic, strong)   UIButton        *replysBtn;
@property (nonatomic, strong)   UIButton        *recoveyBtn;

@end

@implementation CEditBaseItemView

@synthesize processRetainCount,processView,offline=_offline;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self.operatorBar
                                                    name:kNotificationLikes object:nil];
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        [self setDefaultParam];
        
        // Background View of cell
        self.bgView = [CellBackgroundView new];
        self.bgView.backgroundColor = [[DesignManager knoteBackgroundColor] colorWithAlphaComponent:[DesignManager knoteBackgroundOpacity]];
        
        [self.contentView addSubview:self.bgView];
        [self.contentView sendSubviewToBack:self.bgView];
        
        // Cell underline
        self.underLine = [[UIView alloc] init];
        self.underLine.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        
        [self.contentView addSubview:self.underLine];
        //[self.contentView sendSubviewToBack:self.underLine];
        
        if(![self viewWithTag:200])
        {
            // Pin button
            self.pinButton = [UIButton buttonWithType:UIButtonTypeCustom];
            
            [self.pinButton setBackgroundImage: [UIImage imageNamed:@"new_pin"] forState:UIControlStateNormal];
            [self.pinButton setBackgroundImage: [UIImage imageNamed:@"new_pin_selected"] forState:UIControlStateSelected];
            
            self.pinButton.tag=200;
            
            [self.pinButton addTarget:self action:@selector(MarkedPin:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.contentView addSubview:self.pinButton];
            
            // Comment Button
#if !NEW_DESIGN
            self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.commentButton setBackgroundImage: [UIImage imageNamed:@"new_comment_empty"] forState:UIControlStateNormal];
            [self.commentButton setBackgroundImage: [UIImage imageNamed:@"new_comment_selected"] forState:UIControlStateSelected];
            [self.commentButton setSelected:NO];
            [self.commentButton addTarget:self action:@selector(toggleCommentsList) forControlEvents:UIControlEventTouchUpInside];
            [self setCommentButtonImage];
            
            [self.contentView addSubview:self.commentButton];
#endif
            
#if NEW_DESIGN
#else
            self.padTime = [[UILabel alloc] init];
            _padTime.backgroundColor = [UIColor clearColor];
            _padTime.textAlignment = NSTextAlignmentLeft;
            _padTime.font = [UIFont boldSystemFontOfSize:12];
            _padTime.textColor = [UIColor lightGrayColor];
            [self.contentView addSubview:_padTime];
#endif
            
            
            //comment Label
            self.commentLabel = [[UILabel alloc] init];
            self.commentLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
            self.commentLabel.textColor = [UIColor lightGrayColor];
            [self.contentView addSubview:self.commentLabel];
            self.commentLabel.hidden = YES;
        }
        
        self.offline = NO;
        
        self.backgroundColor = [UIColor clearColor];
        
        self.overlayView =  [[UIView alloc] initWithFrame:self.bounds];
        self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.overlayView.backgroundColor = [DesignManager editingBackgroundColor];
        
        self.overlayView.hidden = NO;
        self.overlayView.alpha = 0.0f;
        self.overlayView.userInteractionEnabled = NO;
        
        [self addSubview:self.overlayView];
        
        //        [[NSNotificationCenter defaultCenter] addObserver:self
        //                                                 selector:@selector(keyboardDidHide:)
        //                                                     name:UIKeyboardDidHideNotification
        //                                                   object:nil];
        [self.commentButton  setHitTestEdgeInsets:UIEdgeInsetsMake(-15, -15, -15, -15)];
        [self.pinButton  setHitTestEdgeInsets:UIEdgeInsetsMake(-15, -15, -15, -15)];
        
    }
    
    CItem *item = (CItem *)[self getItemData];
    
    if (item)
    {
        NSInteger count = [[item files] count];
        
        NSNumber *number = [NSNumber numberWithInteger:count];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLikes
                                                            object:number];
    }
    
    return self;
}

- (void)endEditing{};
- (void)keyboardDidHide:(id)sender{};
- (void)showInfo:(InfoType)type{};

-(void)layoutSubviews
{
    [super layoutSubviews];
#if NEW_FEATURE
    if (self.ContactBar)
    {
        [self.bgView bringSubviewToFront:self.ContactBar];
    }
    else
    {
        [self.bgView bringSubviewToFront:self.operatorBar];
        [self.operatorBar likesVisible];
    }
    
#endif
    //Just made comment button hidden for future aspects
    self.commentButton.hidden = YES;
    
}

- (void)setCommentButtonImage
{
    NSInteger countOfComments = [self.itemData.subReplys count];
    
    if (countOfComments>0) {
        if (countOfComments == 1) {
            self.commentLabel.text = [NSString stringWithFormat:@"%d comment", (int)countOfComments];
        } else {
            self.commentLabel.text = [NSString stringWithFormat:@"%d comments", (int)countOfComments];
        }
        self.commentLabel.hidden = NO;
    } else {
        self.commentLabel.hidden = YES;
    }
    
    for (UIView *v in  [self.commentButton subviews]){
        
        if([v isKindOfClass:[UILabel class]])
        {
            [v removeFromSuperview];
        }
    }
    
    if (countOfComments == 0){
        [self.commentButton setBackgroundImage: [UIImage imageNamed:@"new_comment"] forState:UIControlStateNormal];
        self.numberOfCommentsLabel = [[UILabel alloc] init];
    }
    else{
        
        [self.commentButton setBackgroundImage: [UIImage imageNamed:@"new_comment_empty"] forState:UIControlStateNormal];
        
        self.numberOfCommentsLabel = [[UILabel alloc] init];
        self.numberOfCommentsLabel.textAlignment = NSTextAlignmentCenter;
        [self.numberOfCommentsLabel setText:[NSString stringWithFormat:@"%i",countOfComments]];
        [self.numberOfCommentsLabel setFrame: CGRectMake(1, 2, 16, 12)];
        [self.numberOfCommentsLabel setFont: [self.numberOfCommentsLabel.font fontWithSize:11]];
        [self.numberOfCommentsLabel setTextColor: [UIColor blueColor]];
        [self.commentButton addSubview:self.numberOfCommentsLabel];
        [self.commentButton setSelected:NO];
    }
}

- (void)setFrame:(CGRect)frame {
    frame.origin.x += 4;
    frame.origin.y += 4;
    frame.size.width -= 2 * 4;
    frame.size.height -= 2 * 4;
    [super setFrame:frame];
}

- (void)scrollViewTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.baseItemDelegate && [self.baseItemDelegate respondsToSelector:@selector(tapedCell:)]) {
        [self.baseItemDelegate tapedCell:self];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)tapGesture
{
    if (self.baseItemDelegate
        && [self.baseItemDelegate respondsToSelector:@selector(CEditItemViewCell:changedLike:)]) {
        [self.baseItemDelegate CEditItemViewCell:self changedLike:YES];
    }
}

- (void)setDefaultParam
{
#if NEW_DESIGN
#else
    self.titleBarHeight = kDefalutTitleBarH;
#endif
    self.titleBarWidth = 0;
    self.infoBarHeight = kDefalutInfoBarH;
    self.btnBarHeight = kDefalutBtnBarH;
    self.hGap = 10;
    self.vGap = 4;
    self.tGap = 10;
    self.needsRelayout = NO;
    self.itemArray = [[NSMutableArray alloc] initWithCapacity:3];
    self.likedIds = [[NSMutableArray alloc] initWithCapacity:3];
    self.showMore = NO;
    
}

- (void)recoveyBtnClicked
{
    CItem *item = [self getItemData];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_recoveyBtn setImage:[_recoveyBtn.imageView.image imageTintedWithColor:[UIColor blueColor]] forState:UIControlStateNormal];
        _recoveyBtn.transform = CGAffineTransformMakeScale(0.6, 0.6);
        _recoveyBtn.alpha = 0.2;
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [_recoveyBtn setImage:[_recoveyBtn.imageView.image imageTintedWithColor:[UIColor blueColor]] forState:UIControlStateNormal];
            
            _recoveyBtn.transform = CGAffineTransformMakeScale(1, 1);
            _recoveyBtn.alpha = 1;
        } completion:^(BOOL finished) {
            if (finished) {
                [_recoveyBtn setImage:[_recoveyBtn.imageView.image imageTintedWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
                
                [UIView animateKeyframesWithDuration:.4 delay:0 options:0 animations:^{
                    [UIView addKeyframeWithRelativeStartTime:.2 relativeDuration:.2 animations:^{
                        _recoveyBtn.transform = CGAffineTransformScale(CGAffineTransformMakeScale(1, 1), 1, 1);
                    }];
                } completion:^(BOOL finished){
                    [self setItemData:item];
                }];
            }
        }];
    });
    [item checkToDelete];
    if (self.baseItemDelegate && [self.baseItemDelegate respondsToSelector:@selector(recoveyKnote:)]) {
        [self.baseItemDelegate recoveyKnote:self];
    }
}

-(void) setItemData:(CItem*) itemData
{
    _itemData = itemData;
    
    itemData.cell = self;
    
    if (!itemData.userData)
    {
        self.bgView.backgroundColor = [UIColor clearColor];
    }
    
    else if (itemData.archived)
    {
        if (!_recoveyBtn) {
            _recoveyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            [_recoveyBtn setImage:[[UIImage imageNamed:@"recover"] imageTintedWithColor:[UIColor lightGrayColor]] forState:UIControlStateNormal];
            [_recoveyBtn setImage:[[UIImage imageNamed:@"recover"] imageTintedWithColor:[UIColor blueColor]] forState:UIControlStateHighlighted];
            [_recoveyBtn setImage:[[UIImage imageNamed:@"recover"] imageTintedWithColor:[UIColor blueColor]] forState:UIControlStateSelected];
            
            [_recoveyBtn  setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
            [_recoveyBtn addTarget:self action:@selector(recoveyBtnClicked) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_recoveyBtn];
        }
        _recoveyBtn.hidden = NO;
        self.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.99];
        self.bgView.backgroundColor = [UIColor clearColor];
    }
    else
    {
        _recoveyBtn.hidden = YES;
        self.backgroundColor = [UIColor clearColor];
        self.bgView.backgroundColor = [DesignManager knoteBackgroundColor];
    }
    
    if (!self.titleInfoBar)
    {
        self.titleInfoBar = [[CTitleInfoBar alloc] init];
        [self.contentView addSubview:self.titleInfoBar];
        self.titleInfoBar.userInteractionEnabled = YES;
    }
    
#if NEW_DESIGN
    
    if (!self.settingsButton) {
        self.settingsButton = [[UIButton alloc] initWithFrame:CGRectMake(280, 5, 30, 30)];
        [self.settingsButton setImage:[UIImage imageWithIcon:@"fa-ellipsis-h" backgroundColor:[UIColor clearColor] iconColor:[UIColor grayColor] fontSize:22] forState:UIControlStateNormal];
        
        //[self.settingsButton setImage:[UIImage imageWithIcon:@"fa-ellipsis-v" backgroundColor:[UIColor clearColor] iconColor:[UIColor grayColor] andSize:CGSizeMake(22, 22)] forState:UIControlStateNormal];
        
        
        UITapGestureRecognizer *setTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideSettingsView)];
        [setTap setNumberOfTapsRequired:1];
        self.settingsButton.userInteractionEnabled = YES;
        [self.settingsButton addGestureRecognizer:setTap];
        [self.contentView addSubview:self.settingsButton];
        
        [self.settingsButton mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(self).offset(-4);
            
        }];
        
        self.settingsView = [[UIView alloc] initWithFrame:CGRectMake(250, self.settingsButton.frame.origin.y + self.settingsButton.frame.size.height, 60, 70)];
        [self.settingsView setBackgroundColor:[UIColor whiteColor]];
        [self.settingsView.layer setMasksToBounds:YES];
        self.settingsView.layer.cornerRadius = 5;
        [self.settingsView setHidden:YES];        
        
        CGRect frame = CGRectMake(0, 0, self.settingsView.frame.size.width, 30);
        self.editButton = [[UIButton alloc] initWithFrame:frame];
        [self.editButton setImage:[UIImage imageWithIcon:@"fa-pencil" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] fontSize:18]forState:UIControlStateNormal];
        [self.editButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.editButton setBackgroundColor:[UIColor grayColor]];
        
        
        frame.origin.y += frame.size.height +1;
        self.doneButton = [[UIButton alloc] initWithFrame:frame];
        
        [self.doneButton setImage:[UIImage imageWithIcon:@"fa-check" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] fontSize:18]forState:UIControlStateNormal];
        
        [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.doneButton setBackgroundColor:[UIColor grayColor]];
        
        [self.settingsView addSubview:self.editButton];
        [self.settingsView addSubview:self.doneButton];
        [self.contentView addSubview:self.settingsView];
    }
    
    if (!self.replyView)
    {
        self.replyView=[[CLatestReplyView alloc]init];
        self.replyView.commentDelegate=self.baseItemDelegate;
        [self.contentView addSubview:self.replyView];
        self.replyView.userInteractionEnabled=YES;
    }
#endif
    MessageEntity *message = itemData.userData;
    
    ContactsEntity *contact = message.contact;
    
    NSString *imageName = @"bgcolor0";
    
    NSString *subName = nil;
    
    if (contact)
    {
        imageName = [contact userImageName];
        
        if (contact.username)
        {
            subName = [NSString stringWithFormat:@"%@",contact.username];
        }
        else
        {
            subName = [NSString stringWithFormat:@"%@",itemData.name];
        }
    }
    else
    {
        if (itemData.name)
        {
            subName = [NSString stringWithFormat:@"%@",itemData.name];
        }
        else
        {
            if (message.name) {
                subName = [NSString stringWithFormat:@"%@",message.name];
            }
        }
    }
    
    self.titleInfoBar.message = message;
    
#if NEW_DESIGN
    self.replyView.itemData=itemData;
#else
    self.padTime.text = self.titleInfoBar.pTime.text;
#endif
    
    CGSize timeSize = [CUtil getTextSize:self.titleInfoBar.pTime.text textFont:self.titleInfoBar.pTime.font];
    
    CGRect rect = [CUtil getTextRect:self.titleInfoBar.pName.text Font:self.titleInfoBar.pName.font Width:(280-timeSize.width)];
    
    if (rect.size.height>60)
    {
        NSMutableString *contactsStr = nil;
        
        NSArray *editors = nil;
        
        if (message.editors)
        {
            editors = [NSKeyedUnarchiver unarchiveObjectWithData:message.editors];
            
            if([editors count]>1)
            {
                NSDictionary *dic = [editors firstObject];
                
                ContactsEntity *contact = [ContactsEntity MR_findFirstByAttribute:@"email" withValue:dic[@"email"]];
                contactsStr = [contact.name mutableCopy];
                [contactsStr appendFormat:@" and %d others", (int)([editors count]-1)];
                
                self.titleInfoBar.pName.text = contactsStr;
            }
        }
    }
    
    self.overlayView.alpha = 0.0f;
    [self.contentView addSubview:self.titleName];
    
    // make sure to only display the username if there's no photo
    
    if([itemData shouldShowHeader]){
        self.titleName.text = itemData.name;
        self.titleName.hidden = NO;
    } else {
        self.titleName.hidden = YES;
    }
    
    if (itemData.likesId && [itemData.likesId count]>0)
    {
        self.infoBarHeight = kDefalutInfoBarH;
        
        if (self.infoBar)
        {
            [self.infoBar removeFromSuperview];
            self.infoBar.delegate = nil;
            self.infoBar = nil;
        }
        if (!self.infoBar)
        {
            self.infoBar = [[CEditInfoBar alloc] initWithFrame:CGRectMake(0, 0, 320, self.infoBarHeight)];
            self.infoBar.delegate = self;
            self.infoBar.candView.scrollEnabled = NO;
            [self addSubview:self.infoBar];
        }
        
        if ([itemData.likesId count]>7)
        {
            self.infoBar.showMore = YES;
        }
        
        [self.infoBar reloadData];
        
        [self.itemArray removeAllObjects];
        
        // Currently we're looking to have this bar hidden all the time.
        self.infoBar.hidden = YES;
    }
    else
    {
        self.infoBarHeight = 0;
        self.infoBar.hidden = YES;
    }
    
    if (self.itemData.needSend)
    {
        if (self.itemData.offline == NO)
        {
            
        }
        
        self.offline = self.itemData.offline;
    }
    /*#if NEW_DESIGN
     if (itemData.notShowUnderLine)
     #else
     if (itemData.isReplysExpand
     || itemData.notShowUnderLine)
     #endif
     {
     self.underLine.hidden = YES;
     }
     else
     {
     self.underLine.hidden = NO;
     }*/
    
#if NEW_FEATURE
    
    CItem *item = (CItem *)[self getItemData];
    
    
    if (item.userData.currently_contact_edit.length>0 && !self.ContactBar)
    {
        self.ContactBar  = [[COperationBar alloc] initWithFrame:CGRectMake(0, 0, 40, 30)];
        
        ContactsEntity *currentEditcontact = [ContactsEntity MR_findFirstByAttribute:@"account_id" withValue:item.userData.currently_contact_edit];
        
        if (!currentEditcontact)
        {
            [self.ContactBar setImageWithContact:[[AppDelegate sharedDelegate] sendRequestContactByContactID:item.userData.currently_contact_edit]];
        }
        else
        {
            [self.ContactBar setImageWithContact:currentEditcontact];
        }
        [self.bgView addSubview:self.ContactBar];
        self.ContactBar.backgroundColor = [UIColor clearColor];
        [self.ContactBar mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(self.mas_right).offset(15);
            make.top.equalTo(self.mas_top).offset(13);
            make.width.equalTo(@(40));
            make.height.equalTo(@(30));
            
        }];
        self.ContactBar.hidden = NO;
    }
    if (!self.operatorBar)
    {
        self.operatorBar  = [[COperationBar alloc] initWithFrame:CGRectMake(0, 0, 120, 20)];
        //NSDictionary *dic0 = [NSDictionary dictionaryWithObjectsAndKeys:@"",kBtnTitle,@"delete_icon",kBtnBG,[NSNumber numberWithInt:0],kBtnTag, nil];
        //NSDictionary *dic1 = [NSDictionary dictionaryWithObjectsAndKeys:@"",kBtnTitle,@"pencil_icon",kBtnBG,[NSNumber numberWithInt:1],kBtnTag, nil];
        
        //NSArray *array = [[NSArray alloc] initWithObjects:dic0,dic1, nil];
        NSArray * array  =  [[NSArray alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self.operatorBar
                                                 selector:@selector(updateLikesNow:)
                                                     name:kNotificationLikes
                                                   object:nil];
        
        [self.operatorBar setButtonsArray:array];
        self.operatorBar.delegate = self;
        [self.bgView addSubview:self.operatorBar];
        self.operatorBar.backgroundColor = [UIColor clearColor];
        [self.operatorBar mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.contentView.mas_left).offset(45);
            make.bottom.equalTo(self.mas_bottom).offset(-kSpaceFromBottom - self.infoBarHeight);
            make.width.equalTo(@(120));
            make.height.equalTo(@(20));
            
        }];
        
        self.operatorBar.hidden = NO;
        
        NSInteger count = [[item files] count];
        
        NSNumber *number = [NSNumber numberWithInteger:count];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLikes
                                                            object:number];
    }
    
    if (itemData.userData.expanded)
    {
#endif
        
        if (itemData.type == C_KNOTE)
        {
            if (!(itemData.userData.replys))
            {
                if (self.replysBtn)
                {
                    self.replysBtn.hidden = YES;
                }
            }
        }
        
        if (itemData.type == C_NEW_COMMENT)
        {
            self.pinButton.hidden = YES;
            self.commentButton.hidden = YES;
        }
        else
        {
            if (itemData.userData == nil)
            {
                self.pinButton.hidden = YES;
                self.commentButton.hidden = YES;
            }
            else
            {
                //Just made pin button hidden for future aspects
                self.pinButton.hidden = YES;
                
                //self.pinButton.hidden = NO;
                self.commentButton.hidden = NO;
            }
            
            if (itemData.userData.pinned)
            {
                self.pinButton.selected = YES;
            }
            else
            {
                self.pinButton.selected = NO;
            }
        }
#if !NEW_DESIGN
        [self updateViewMode:((CItem*)self.itemData).isReplysExpand];
#endif
#if NEW_FEATURE
    }
#endif

    [self setNeedsUpdateConstraints];
}

- (void)showHideSettingsView{
    
    CItem *item = (CItem *)[self getItemData];
    
    if (item.topic.isBookMarked.boolValue)
    {
        [self.bookMarkButon setImage:[UIImage imageWithIcon:@"fa-bookmark" backgroundColor:[UIColor clearColor] iconColor:[UIColor redColor] fontSize:18]forState:UIControlStateNormal];
    }
    else
    {
        [self.bookMarkButon setImage:[UIImage imageWithIcon:@"fa-bookmark" backgroundColor:[UIColor clearColor] iconColor:[UIColor whiteColor] fontSize:18]forState:UIControlStateNormal];
    }
    [self.contentView insertSubview:self.settingsView atIndex:self.contentView.subviews.count-1];
    
    if ([self.settingsView isHidden]) {
        [self.settingsView setHidden:NO];
    }else{
        [self.settingsView setHidden:YES];
    }
}


- (void)toggleCommentsList {
    
    if (self.baseItemDelegate && [self.baseItemDelegate respondsToSelector:@selector(toggleCommentsListInCell:withContent:)]) {
        NSInteger countOfComments = [self.itemData.subReplys count];
        if ([self.itemData.subReplys count] == 0){
            if (!self.commentButton.isSelected ){
                [self.commentButton setSelected:YES];
            }
            else{
                [self.commentButton setSelected:NO];
            }
        }
        else{
            [self.commentButton setSelected:NO];
        }
        
        [self.baseItemDelegate toggleCommentsListInCell:self withContent:self.itemData];
    }
}

- (void)showNewCommentTextView {
    
}

- (void)MarkedPin:(UIButton*)pinbtn
{
    pinbtn.selected=!pinbtn.selected;
    
    if (self.baseItemDelegate &&
        [self.baseItemDelegate respondsToSelector:@selector(MarkedPin:withContet: forIndexpath:)])
    {
        BOOL bSelected =pinbtn.selected;
        [self.baseItemDelegate MarkedPin:bSelected withContet:self.itemData forIndexpath:self.indexpath];
    }
}

- (void)commentButtonTapped:(UIButton*)commentButton
{
    commentButton.selected=!commentButton.selected;
    
    if (self.baseItemDelegate && [self.baseItemDelegate respondsToSelector:@selector(addNewComment:withContet:)])
    {
        [self.baseItemDelegate addNewComment:self withContet:self.itemData];
    }
}

-(void)setOffline:(BOOL)offline
{
    _offline = offline;
    
    if (offline)
    {
        [self showInfo:InfoOffline];
    }
    else
    {
        [self hiddenInfo];
    }
}

-(CItem*) getItemData
{
    return _itemData;
}

- (BOOL)canDraggable:(CGPoint)point
{
    return YES;
}

-(BOOL)canShowMenu
{
    BOOL ret = NO;
    return ret;
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    CItem *itemData = [self getItemData];
    if (itemData.archived)
    {
        [self.contentView bringSubviewToFront:_recoveyBtn];
        
        [_recoveyBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-10));
            make.top.equalTo(@(5));
            make.width.equalTo(@(16));
            make.height.equalTo(@(12));
        }];
    }
    
    if (itemData.userData.currently_contact_edit.length>0 && ![itemData.userData.currently_contact_edit isEqualToString:@"(null)"] && self.ContactBar)
    {
        self.ContactBar.hidden=NO;
    }
    else
    {
        self.ContactBar.hidden=YES;
    }
    
    if (itemData.userData.expanded) {
        
        self.operatorBar.hidden = NO;
        [self.operatorBar mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.left.equalTo(self.contentView.mas_left).offset(45);
            make.bottom.equalTo(self.mas_bottom).offset(-kSpaceFromBottom - self.infoBarHeight);
            make.width.equalTo(@(120));
            make.height.equalTo(@(20));
        }];
        
        self.commentButton.hidden = NO;
        //Just made pin button hidden for future aspects
        
#if NEW_DESIGN
#else
        self.padTime.hidden = NO;
#endif
        self.commentLabel.hidden = YES;
    } else {
        
        self.operatorBar.hidden = YES;
        
        self.commentButton.hidden = YES;
        self.pinButton.hidden = YES;
#if NEW_DESIGN
#else
        self.padTime.hidden = YES;
#endif
        //self.underLine.backgroundColor = [UIColor clearColor];
    }
    
    if (self.bounds.size.height<=0.0001f)
    {
        [self.pinButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@50);
            make.height.equalTo(@(0));
            make.width.equalTo(@(0));
            make.left.equalTo(self.contentView.mas_left).offset(17);
        }];
        
        [self.commentButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(25));
            make.height.equalTo(@(0));
            make.width.equalTo(@(0));
            make.right.equalTo(self.bgView.mas_right).offset(-self.hGap);
        }];
        
        return;
    }
    
#if NEW_DESIGN
#else
    if (self.titleBarHeight>0)
    {
        [self.titleName mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.bgView.mas_top).offset(4.0);
            make.height.equalTo(    @(self.titleBarHeight));
            make.left.equalTo(self.bgView.mas_left).offset(self.hGap);
            make.right.equalTo(self.bgView.mas_right).offset(-self.hGap);
        }];
        
        [self.titleInfoBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).offset(10.0);
            make.height.equalTo(@(self.titleBarHeight));
            
            make.left.equalTo(self);
            make.right.equalTo(self);
        }];
    }
#endif
    
#if 0
    [self.userAvatar mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(       @(kAvatarH));
        make.width.equalTo(       @(kAvatarH));
        make.top.equalTo(self.top).offset(kVGap);
        if (item.convType == ConvLeft) {
            make.left.equalTo(self.left).offset(kHGap);
        } else {
            make.left.equalTo(self.left).offset(self.bounds.size.width - kHGap - kAvatarH);
        }
    }];
    
#endif
    if (self.frame.size.height>10)
    {
    }
    else
    {
        [self.pinButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@50);
            make.height.equalTo(@(0));
            make.width.equalTo(@(0));
            make.left.equalTo(self.contentView.mas_left).offset(17);
        }];
        
        [self.commentButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@(25));
            make.height.equalTo(@(0));
            make.width.equalTo(@(0));
            make.right.equalTo(self.bgView.mas_right).offset(-self.hGap - 25);
        }];
        
    }
    
    //tmd
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
#if NEW_DESIGN
        //make.top.equalTo(@(self.tGap)).offset(100);
        make.top.equalTo(self.mas_bottom).offset(-6);

#else
        make.top.equalTo(@(self.tGap)).offset(self.titleBarHeight);
#endif
        //make.bottom.equalTo(    @(-(self.vGap+self.btnBarHeight)));
        make.bottom.equalTo(self.mas_bottom).offset(-6);

        make.left.equalTo(      @(self.hGap));
        make.right.equalTo(     @(-(self.hGap)));
    }];
    
    if (self.infoBarHeight>0)
    {
        [self.infoBar mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(       @(self.infoBarHeight));
            make.left.equalTo(@(kTheadLeftGap-28));
            make.right.equalTo(self.mas_right).offset(-self.hGap);
            if (self.replysBtn && self.replysBtn.hidden == NO && [self.replysBtn superview])
            {
                make.top.equalTo(self.replysBtn.mas_bottom).offset(10);
            }
            else
            {
                make.bottom.equalTo(self.mas_bottom).offset(-4.0);
            }
        }];
        
        [self bringSubviewToFront:self.infoBar];
        
        [self.infoBar setBackgroundColor:[UIColor grayColor]];
        
    }
    
    if (self.replysBtn && [self.replysBtn superview])
    {
        [self.replysBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(@(5));
            make.width.equalTo(@(kMoreButtonWith));
            make.left.equalTo(self.bgView.mas_left).offset(self.hGap + 30);
            make.bottom.equalTo(self.mas_bottom).offset(-kSpaceFromBottom - self.infoBarHeight);
        }];
    }
    
    // Comment Button
    
    [self.commentButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(kPinHeight));
        make.width.equalTo(@(kPinWidth));
        make.left.equalTo(self.mas_left).offset(kMoreButtonWith + 50);
        make.bottom.equalTo(self.mas_bottom).offset(-kSpaceFromBottom - self.infoBarHeight);
    }];
    
#if NEW_DESIGN
    [self.replyView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        CreplyUtils *cre=[[CreplyUtils alloc]init];
        make.top.equalTo(self.mas_bottom).offset(-[cre getSizeOfReplyView:itemData]);
        make.height.equalTo(@([cre getSizeOfReplyView:itemData]));
        make.left.equalTo(self.mas_left);
        //make.width.equalTo(@(320));
        
        //tmd
        make.right.equalTo(self);
    }];
#else
    // Pin Button
    
    [self.pinButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@50);
        make.height.equalTo(@(kPinHeight));
        make.width.equalTo(@(kPinWidth));
        make.left.equalTo(self.contentView.mas_left).offset(17);
    }];
    [self.commentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(kPinHeight));
        make.width.equalTo(@(200));
        make.left.equalTo(self.mas_left).offset(50);
        make.bottom.equalTo(self.mas_bottom).offset( - self.infoBarHeight);
    }];
    [self.padTime mas_updateConstraints:^(MASConstraintMaker *make) {
        CGSize size = [CUtil getTextSize:self.padTime.text textFont:self.padTime.font];
        make.width.equalTo(@(size.width+4));
        make.right.equalTo(self.mas_right).offset(-6);
        make.bottom.equalTo(self.mas_bottom).offset(-kSpaceFromBottom - self.infoBarHeight);
    }];
#endif
    
    [self.underLine mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(1));
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.bottom.equalTo(self);
    }];
    if (!self.ContactBar.hidden)
    {
        [self.ContactBar mas_updateConstraints:^(MASConstraintMaker *make) {
            
            make.right.equalTo(self.mas_right).offset(15);
            make.top.equalTo(self.mas_top).offset(5);
            make.width.equalTo(@(40));
            make.height.equalTo(@(30));
            //            make.bottom.equalTo(self.pinButton.mas_bottom);
            
            //            make.right.equalTo(self.padTime.mas_left);
            
        }];
        
    }
}

- (void)showProcess
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"showProcess");
        
        if (!self.processView) {
            self.processView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.processRetainCount = 0;
        }
        
        self.processView.color = [UIColor grayColor];
        self.processView.hidesWhenStopped = YES;
        //[self.processView startAnimating];
        [self.contentView addSubview:self.processView];
        [self.processView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.equalTo(@15.0);
            make.centerY.equalTo(@4.0);
            make.right.equalTo(@-20.0);
        }];
        
        self.processRetainCount++;
    });
}

- (void)stopProcess
{
    NSLog(@"stopProcess");
    
    self.processRetainCount--;
    if (self.processRetainCount == 0) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.processView stopAnimating];
            [self.processView setHidden:YES];
            [self.processView removeFromSuperview];
            self.processView = nil;
        });
    }
}

- (void)hiddenInfo
{
    [self.offLineBtn setHidden:YES];
    [self.offLineBtn removeFromSuperview];
    self.offLineBtn = nil;
}

#pragma mark - Collection view delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    CItem *item = (CItem *)[self getItemData];
    return [[item files] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@". indexPath: %@", indexPath);
    
    static NSString *identifier = @"Cell";
    CItem *item = (CItem *)[self getItemData];
    
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.tag = indexPath.row;
    
    FileInfo *fInfo = [[item files] objectAtIndex:indexPath.row];
    
    cell.info = fInfo;
    fInfo.cell = cell;
    fInfo.parentCell = self;
    fInfo.parentItem = item;
    
    NSLog(@"fInfo.file == %@", fInfo.file);
    
    if (!self.offline)
    {
        if (fInfo.file && [fInfo.file.sendFlag charValue] != SendSuc)
        {
            UIImage *img = fInfo.image;
            
            NSLog(@"Image Size : %@", NSStringFromCGSize(img.size));
            NSLog(@"Cell Size : %@", NSStringFromCGSize(cell.bounds.size));
            
            if (img.size.width>cell.bounds.size.width||img.size.height>cell.bounds.size.height)
            {
                [cell setShowImage:img withContentMode:UIViewContentModeScaleAspectFit];
            }
            else
            {
                [cell setShowImage:img withContentMode:UIViewContentModeScaleToFill];
            }
            
            [fInfo recordSelfToServer];
        }
        else
        {
            if (fInfo.file)
            {
                [cell setShowEntity:fInfo.file];
            }
            else
            {
                [fInfo fetchSelfFromServer:item.userData];
            }
        }
    }
    else
    {
        if (fInfo.file)
        {
            [cell setShowEntity:fInfo.file];
        }
    }
    
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
    
}

// called when the user taps on an already-selected item in multi-select mode
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kGridViewH, kGridViewH);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"collectionView didSelectItemAtIndexPath: %d", (int)indexPath.row);
    
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (!cell.downloadSucces)
    {
        CItem *item = (CItem *)[self getItemData];
        FileInfo *fInfo =  [[item files] objectAtIndex:indexPath.row];
        
        if (!fInfo.file )
        {
            fInfo.file = [FileEntity MR_findFirstByAttribute:@"file_id" withValue:fInfo.imageId];
        }
        
        if (fInfo.file)
        {
            [cell setShowEntity:fInfo.file];
        }
        else
        {
            [fInfo fetchSelfFromServer:item.userData];
        }
    }
    else
    {
        FileEntity *f = cell.info.file;
        NSLog(@"have downloaded, fileentity: %@ isPDF: %@", f, f.isPDF);
        
        if(f && f.isPDF != nil && f.isPDF.boolValue)
        {
            NSLog(@"Show PDF here!");
            
            if (self.baseItemDelegate && [self.baseItemDelegate respondsToSelector:@selector(wantControllerPresented:)])
            {
                ShowPDFController *pdfController = [[ShowPDFController alloc] initWithFile:f];
                pdfController.delegate = self.baseItemDelegate;
                [self.baseItemDelegate wantControllerPresented:pdfController];
            }
            
        }
        else if (self.baseItemDelegate && [self.baseItemDelegate respondsToSelector:@selector(wantFullLayout:)]) {
            [self.baseItemDelegate wantFullLayout:(UIImageView *)cell.imageView];
        }
    }
}

-(void)setOverLay:(BOOL)editor animate:(BOOL)animate
{
    NSLog(@"editor: %d animate: %d", editor, animate);
    [UIView animateWithDuration:(animate) ? 0.6 : 0.
                          delay:0.
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         CGRect frame =CGRectMake(0,
                                  0,
                                  self.bounds.size.width,
                                  self.bounds.size.height);
         
         if (editor)
         {
             self.overlayView.alpha = 1.f;
         }
         else
         {
             frame = CGRectMake(self.bounds.size.width,
                                0,
                                self.bounds.size.width,
                                self.bounds.size.height);
             
             self.overlayView.alpha = 0.f;
         }
         
         self.overlayView.frame = frame;
         
     } completion:^(BOOL finished) {
         
         self.overlayView.userInteractionEnabled = editor;
         
         if (editor)
         {
             [self.baseItemDelegate contextMenuDidShowInCell:self];
         }
         
         if (!editor)
         {
         }
         else
         {
         }
     }];
}

- (void)prepareForMove
{
    self.hidden = YES;
}

- (NSUInteger)numOfCellsInCandidateBar:(CEditInfoBar *)candBar
{
    return [self.itemData.likesId count];
}

- (CGSize)candidateBar:(CEditInfoBar *)candBar sizeOfCellAtIndex:(NSUInteger)index
{
    return CGSizeMake(30, 30);
}

- (BI_GridViewCell *)candidateBar:(CEditInfoBar *)candBar cellForFrame:(BI_GridFrame *)frame
{
    static NSString *kCandBarCell  = @"CandidateBarCell";
    
    CEditInfoItem *cell = (CEditInfoItem *)[candBar dequeueReusableCellWithIdentifier:kCandBarCell];
    
    if (nil == cell)
    {
        cell = [[CEditInfoItem alloc] initWithReuseIdentifier:kCandBarCell];
    }
    
    NSString *cid =  [self.itemData.likesId objectAtIndex:frame.startIndex];
    
    ContactsEntity *entity = [ContactsEntity MR_findFirstByAttribute:@"me_id" withValue:cid];
    
    if (!entity)
    {
        entity = [ContactsEntity MR_findFirstByAttribute:@"contact_id" withValue:cid];
    }
    
    if (entity)
    {
        [entity getAsyncImageWithBlock:^(id img, BOOL flag) {
            if (img)
            {
                if ([cell.imgView isKindOfClass:[UIImageView class]])
                {
                    cell.imgView.image = [img circlePlainImageSize:kDefalutLikeIconH];
                    
                }
            }
        }];
    }
    
    [cell setNeedsUpdateConstraints];
    
    return cell;
}

- (void)candidateBar:(CEditInfoBar *)candBar didSelectCellAtIndex:(NSUInteger)index
{
    NSString *cid =  [self.itemData.likesId objectAtIndex:index];
    
    ContactsEntity *entity = [ContactsEntity MR_findFirstByAttribute:@"me_id" withValue:cid];
    
    if (!entity)
    {
        entity = [ContactsEntity MR_findFirstByAttribute:@"contact_id" withValue:cid];
    }
    
    if (entity)
    {
        if (self.baseItemDelegate && [self.baseItemDelegate respondsToSelector:@selector(titleInfoClickeAtContact:)])
        {
            [self.baseItemDelegate titleInfoClickeAtContact:entity];
        }
    }
}

- (void)updateViewMode:(BOOL)isExpanded
{
    if (isExpanded)
    {
        [self.replysBtn setTitle:@"Less  " forState:UIControlStateNormal];
    }
    else
    {
        [self.replysBtn setTitle:@"More" forState:UIControlStateNormal];
    }
}

- (NSInteger) numberOfLikes
{
    NSInteger ret = 0;
    
    if ([self.baseItemDelegate respondsToSelector:@selector(numberOfLikesWithViewCell:)])
    {
        ret = [self.baseItemDelegate numberOfLikesWithViewCell:self];
    }
    
    return ret;
}
@end
