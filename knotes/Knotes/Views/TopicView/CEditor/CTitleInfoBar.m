//
//  CTitleInfoBar.m
//  Knotable
//
//  Created by backup on 13-12-27.
//
//

#import "CTitleInfoBar.h"

#import "MessageEntity.h"
#import "ContactsEntity.h"

#import "DesignManager.h"
#import "ContactManager.h"
#import "ThreadItemManager.h"

#import "CUtil.h"
#import "ObjCMongoDB.h"

#import "QuadCurveMenu.h"
#import "QuadCurveLinearDirector.h"
#import "QuadCurveCustomMenuItemFactory.h"
#import "QuadCurveMenuItemFactory.h"
#import "QuadCurveDefaultDataSource.h"
#import "QuadCurveCustomImageMenuItem.h"
#import "QuadCurveRadialDirector.h"
#import "QuadCurveCustomDirector.h"

#import "UIImage+RoundedCorner.h"
#import "UIImage+Knotes.h"

@interface CTitleInfoBar ()<QuadCurveMenuDelegate>
@property (nonatomic, strong) NSMutableArray *editors;
@end
@implementation CTitleInfoBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        // Name
        
        self.pName = [[UILabel alloc] init];
        
        _pName.backgroundColor = [UIColor clearColor];
        _pName.font = [DesignManager knoteRealnameFont];
#if NEW_DESIGN
        _pName.textColor = [UIColor blackColor];
#else
        _pName.textColor = [DesignManager knoteUsernameColor];
#endif
        self.pName.numberOfLines = 2;
        
        [self addSubview:_pName];
        
        // Time
        
        self.pTime = [[UILabel alloc] init];
        
        _pTime.backgroundColor = [UIColor clearColor];
        _pTime.textAlignment = NSTextAlignmentLeft;
        _pTime.font = [DesignManager knoteTimeFont];
        _pTime.textColor = kTextColor;
        
        [self addSubview:_pTime];
        
#if NEW_DESIGN
        self.lbl_Subject=[[UILabel alloc]init];
        _lbl_Subject.backgroundColor=[UIColor clearColor];
        _lbl_Subject.textAlignment=NSTextAlignmentLeft;
        _lbl_Subject.font=[DesignManager knoteSubjectFont];
        _lbl_Subject.textColor=[UIColor blackColor];
        _lbl_Subject.numberOfLines=0;
        [self addSubview:_lbl_Subject];
        
#else
        // Sub Label
        self.subLabel = [[UILabel alloc] init];
        
        _subLabel.backgroundColor = [UIColor clearColor];
        _subLabel.font = [DesignManager knoteUsernameFont];
        _subLabel.textColor = kTextColor;
        
        [self addSubview:_subLabel];
#endif
        
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];

        self.menu = [[QuadCurveMenu alloc] initWithFrame:self.bounds
                                             centerPoint:CGPointMake(27, 20)
                                              dataSource:nil
                                         mainMenuFactory:nil
                                         menuItemFactory:nil];
        
        self.menu.delegate = self;
        
        [self.menu setMenuDirector:[[QuadCurveCustomDirector alloc] initWithAngle:(4 * M_PI/2)
                                                                       andPadding:8.0]];
        
        [self addSubview:self.menu];
        
        [self bringSubviewToFront:self.menu];
    }
    return self;
}

- (UIImage *)getImageByString:(NSString *)str subString:(NSString *)substr
{
    UIImage *img = nil;
    
    if ([str hasPrefix:@"bgcolor"])
    {
        NSString *backgroundName = str;

        if (substr.length > 0)
        {
            img = [CUtil imageText:[[substr substringToIndex: 1] uppercaseString]
                    withBackground: backgroundName
                              size:CGSizeMake(kDefalutTitleIconH, kDefalutTitleIconH)
                              rate:0.6];
        }
    }
    else
    {
        NSString *path  = [kImageCachePath stringByAppendingPathComponent:str];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:path])
        {
            img = [UIImage imageWithContentsOfFile:path];
        }
        
        if (!img)
        {
            img = [UIImage imageNamed:str];
        }
    }
    
    if (img)
    {
        img = [img circlePlainImageSize:kDefalutTitleIconH];
    }
    
    return img;
}

#if NEW_DESIGN
#else
- (QuadCurveMenuItem *) generaterItem:(ContactsEntity *)contact
{
    NSString *realName = @"bgcolor0";
    
    if (contact)
    {
        realName = [contact userImageName];
    }
    
    UIImage *img = [self getImageByString:realName subString:contact.name];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    
    [imgView setFrame:CGRectMake(0, 0, kDefalutTitleIconH, kDefalutTitleIconH)];
    
    QuadCurveMenuItem *imgMenuItem = [[QuadCurveMenuItem alloc] initWithView:imgView];
    
    imgMenuItem.dataObject = contact;
    
    return imgMenuItem;
}
#endif
- (void)setMessage:(MessageEntity *)message
{
    if (message == nil)
    {
        return;
    }
    
    _message = message;

    ContactsEntity *contact = message.contact;

    NSString *realName = @"bgcolorGray";//@"bgcolor0";
    
    NSString *userName = @"";
    
    NSArray *editors = nil;
    
    if (!contact)
    {
        //find in local
        
        if (message.account_id)
        {
            contact = [ContactsEntity MR_findFirstByAttribute:@"account_id" withValue:message.account_id];
        }
    }
    
    if (!contact)
    {
        //find in server
        
        __weak __typeof(&*self)weakSelf = self;
        
        [ContactManager findContactFromServerByAccountId:message.account_id
                                          withNofication:nil withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData)
        {
            if (weakSelf != nil)
            {
                [weakSelf setMessage:message];
            }
        }];
    }
    
    if (message.editors)
    {
        editors = [NSKeyedUnarchiver unarchiveObjectWithData:message.editors];
    }
    /**********Commented for removing contributors from knotes***********/
    /*if (editors && [editors count]>1)
    {
        self.editors = [NSMutableArray new];
        
        NSMutableArray *imageArray = [NSMutableArray new];
        NSMutableArray *contacts = [NSMutableArray new];
        
        for (NSDictionary *dic in editors)
        {
            ContactsEntity *editors_contact = [ContactsEntity MR_findFirstByAttribute:@"mainEmail"
                                                                            withValue:dic[@"email"]];
            
            NSString *email = dic[@"email"];

            if (!editors_contact
                && email
                && [email isKindOfClass:[NSString class]])
            {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email like[cd] %@",[NSString stringWithFormat:@"*%@*",email]];//查询条件
                
                editors_contact = [ContactsEntity MR_findFirstWithPredicate:predicate];
            }
            
            if (editors_contact)
            {
                if ([editors_contact isFault])
                {
                    [editors_contact MR_refresh];
                }
                
                if (editors_contact.name)
                {
                    [contacts addObject:editors_contact.name];
                }
                
                if (editors_contact)
                {
                    [self.editors addObject:editors_contact];
                }
                
                QuadCurveMenuItem *imgMenuItem = [self generaterItem:editors_contact];
                
                [imageArray addObject:imgMenuItem];
                
            }
            else
            {
                if (email && [email isKindOfClass:[NSString class]])
                {
                    [ContactManager findContactFromServerByEmail:email];
                    
                    [contacts addObject:[[email componentsSeparatedByString:@"@"] firstObject]];
                }
            }
        }
        
        realName = [contacts componentsJoinedByString:@", "];
        
        UIImage *img = [CUtil imageText:[NSString stringWithFormat:@"%d",(int)[editors count]]
                            withSubText:@"authors"
                                   size:CGSizeMake(kDefalutTitleIconH, kDefalutTitleIconH)
                                   rate:0.6];
        
        img = [img circlePlainImageSize:kDefalutTitleIconH];
        
        NSInteger count = [imageArray count];
        
        CGFloat expandW = 4;
        
        switch (count)
        {
            case 1:
            {
                UIImageView *im1 = (UIImageView *)[(QuadCurveMenuItem *)[imageArray firstObject] contentView];
                UIImage *img1 = [im1.image copy];
                img = [img image1:img1 image2:nil image3:nil withSize:kDefalutTitleIconH+expandW];
            }
                break;
                
            case 2:
            {
                UIImageView *im1 = (UIImageView *)[(QuadCurveMenuItem *)[imageArray firstObject] contentView];
                UIImage *img1 = [im1.image copy];
                UIImageView *im2 = (UIImageView *)[(QuadCurveMenuItem *)[imageArray lastObject] contentView];
                UIImage *img2 = [im2.image copy];
                img = [img image1:img1 image2:img2 image3:nil withSize:kDefalutTitleIconH+expandW];
            }
                break;
                
            case 3:
            {
                UIImageView *im1 = (UIImageView *)[(QuadCurveMenuItem *)[imageArray objectAtIndex:0] contentView];
                UIImage *img1 = [im1.image copy];
                UIImageView *im2 = (UIImageView *)[(QuadCurveMenuItem *)[imageArray objectAtIndex:1] contentView];
                UIImage *img2 = [im2.image copy];
                UIImageView *im3 = (UIImageView *)[(QuadCurveMenuItem *)[imageArray objectAtIndex:2] contentView];
                UIImage *img3 = [im3.image copy];
                img = [img image1:img1 image2:img2 image3:img3 withSize:kDefalutTitleIconH+expandW];
            }
                break;
                
            default:
            {
                if (count>3)
                {
                    UIImageView *im1 = (UIImageView *)[(QuadCurveMenuItem *)[imageArray objectAtIndex:count-3] contentView];
                    UIImage *img1 = [im1.image copy];
                    UIImageView *im2 = (UIImageView *)[(QuadCurveMenuItem *)[imageArray objectAtIndex:count-2] contentView];
                    UIImage *img2 = [im2.image copy];
                    UIImageView *im3 = (UIImageView *)[(QuadCurveMenuItem *)[imageArray objectAtIndex:count-1] contentView];
                    UIImage *img3 = [im3.image copy];
                    
                    img = [img image1:img1 image2:img2 image3:img3 withSize:kDefalutTitleIconH+expandW];
                }
            }
                break;
        }

        if (img)
        {
            QuadCurveCustomMenuItemFactory *imgMenuItem = [[QuadCurveCustomMenuItemFactory alloc] initWithImage:img
                                                                                                 highlightImage:img];
            
            self.menu.mainMenuItemFactory = imgMenuItem;
            
            self.menu.dataSource =  [[QuadCurveDefaultDataSource alloc] initWithArray:imageArray];
            
            self.menu.menuItemFactory = [[QuadCurveCustomImageMenuItem alloc] init];
            
        }
        else
        {
            NSLog(@"check!!!%@",message);
        }
    }
    else
    */{
        __block UIImage *image = nil;
        
        if (contact)
        {
            if ([contact isFault])
            {
                [contact MR_refresh];
            }
            
            // Set text profile image while the other is created
            [self createProfileImageMenuFromName:contact.username];
            
            [contact getAsyncImageWithBlock:^(id img, BOOL flag)
            {
                if (img)
                {
                    image = [img circlePlainImageSize:kDefalutTitleIconH];
                    
                    QuadCurveCustomMenuItemFactory *imgMenuItem = [[QuadCurveCustomMenuItemFactory alloc] initWithImage:image
                                                                                                         highlightImage:image];
                    
                    self.menu.mainMenuItemFactory = imgMenuItem;
                    
                    self.menu.mainMenuButton.dataObject = contact;
                }
            }];
            
            realName = contact.username;
            userName = contact.name;
            
        }
        else
        {
            [self createProfileImageMenuFromName:realName];
            userName = self.message.name;
        }
    }
#if NEW_DESIGN
    NSString* timeText = [[ThreadItemManager sharedInstance] getDateTimeIndicate:message.time];
    if (userName.length == 0)
    {
        userName = @"   ";
        timeText = @"   ";
    }
    self.pName.text = userName;
    self.pTime.text = timeText;
    
    /// Chunji added 20150916
    NSArray* titleAndContent = [message.title knotableTitleAndContent];
    NSString* title = titleAndContent[0];
    self.lbl_Subject.text= title;
    [self.pTime sizeToFit];
#else
    self.pName.text = realName;
    self.subLabel.text = userName;
    self.pTime.text = [[ThreadItemManager sharedInstance] getDateTimeIndicate:message.time];
    [self.pTime sizeToFit];
    // Lin - Marked to disable User name and sub name
    [self.pName setHidden:YES];
    [self.subLabel setHidden:YES];
    [self.pTime setHidden:YES];
#endif
    [self setNeedsUpdateConstraints];
}

-(void)createProfileImageMenuFromName:(NSString *)realName
{
    NSString *subStr = self.message.name;
    
    if (!subStr || [subStr length]<=1)
    {
        subStr = self.message.email;
    }
    
    if (subStr || [subStr length]<1)
    {
        subStr = @"X";//check....
    }
    
    UIImage * image = [self getImageByString:realName subString:subStr];
    
    realName = self.message.name;
    
    if (image)
    {
        QuadCurveCustomMenuItemFactory *imgMenuItem = [[QuadCurveCustomMenuItemFactory alloc] initWithImage:image
                                                                                             highlightImage:image];
        
        self.menu.mainMenuItemFactory = imgMenuItem;
    }
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.greaterThanOrEqualTo(@(kDefalutBtnBarH));
    }];
#if NEW_DESIGN
    [self.pName mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(5));
        make.left.equalTo(self.mas_left).offset(2*kHGap+44);
       // make.right.equalTo(self.mas_right).offset(-kHGap);
        make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)-8-2*kHGap+44));
        CGSize size = [CUtil getTextSize:self.pName.text textFont:self.pName.font];
        make.height.greaterThanOrEqualTo(@(size.height));
        
    }];
    [self.pTime mas_updateConstraints:^(MASConstraintMaker *make) {
        if ([self.pTime.text length]>0)
        {
            make.top.equalTo(self.pName.mas_bottom).offset(0);
        }
        else
        {
            CGSize size = [CUtil getTextSize:self.pTime.text textFont:self.pTime.font];
            make.height.lessThanOrEqualTo(@(size.height));
        }
         make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)-8-2*kHGap+44));
        make.left.equalTo(self.mas_left).offset(2*kHGap+44);
        make.right.equalTo(self.mas_right).offset(-20.0);
        make.bottom.lessThanOrEqualTo(self);
    }];
    
    [self.lbl_Subject mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.pTime.mas_bottom).offset(5);
        make.left.equalTo(@(12));
        //make.right.equalTo(@(8));
        CGRect heightlbl;
        if (_lbl_Subject.text.length>0)
        {
            heightlbl=[CUtil getTextRect:_lbl_Subject.text Font:_lbl_Subject.font Width:CGRectGetWidth([UIScreen mainScreen].bounds)-12];
            make.width.equalTo(@(CGRectGetWidth([UIScreen mainScreen].bounds)-12));
            make.height.equalTo(@(heightlbl.size.height));
        }
        else
        {
            make.width.equalTo(@(0));
            make.height.equalTo(@(0));
        }
    }];
    [self.menu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.left.equalTo(self);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
#else
    [self.pTime mas_updateConstraints:^(MASConstraintMaker *make) {
        CGSize size = [CUtil getTextSize:self.pTime.text textFont:self.pTime.font];
        make.width.equalTo(@(size.width+4));
        make.top.equalTo(self).offset(0);
        make.right.equalTo(self.mas_right).offset(-12);
    }];
    
    [self.menu mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.left.equalTo(self);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
    }];
    
    [self.pName mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(0));
        make.left.equalTo(self.mas_left).offset(2*kHGap+44);
        make.right.equalTo(self.pTime.mas_left);
        CGSize size = [CUtil getTextSize:self.pName.text textFont:self.pName.font];
        make.height.greaterThanOrEqualTo(@(size.height));
        
    }];
    
    [self.subLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        
        if ([self.subLabel.text length]>0)
        {
            make.top.equalTo(self.pName.mas_bottom).offset(0);
        }
        else
        {
            CGSize size = [CUtil getTextSize:self.subLabel.text textFont:self.subLabel.font];
            make.height.lessThanOrEqualTo(@(size.height));
        }
        
        make.left.equalTo(self.mas_left).offset(2*kHGap+44);
        make.right.equalTo(self.mas_right).offset(-kHGap);
        make.bottom.lessThanOrEqualTo(self);
    }];
    
    self.subLabel.backgroundColor = [UIColor clearColor];
#endif
}


#pragma mark - QuadCurveMenuDelegate Adherence
- (void)quadCurveMenu:(QuadCurveMenu *)menu didTapMenu:(QuadCurveMenuItem *)mainMenuItem
{
    if (mainMenuItem.dataObject)
    {
        if (self.delegate
            && [self.delegate respondsToSelector:@selector(titleInfoClickeAtContact:)])
        {
            [self.delegate titleInfoClickeAtContact:(ContactsEntity *)mainMenuItem.dataObject];
        }
        
        [menu closeMenu];
    }
}

- (void)quadCurveMenu:(QuadCurveMenu *)menu didTapMenuItem:(QuadCurveMenuItem *)menuItem
{
    if (menuItem.dataObject)
    {
        if (self.delegate
            && [self.delegate respondsToSelector:@selector(titleInfoClickeAtContact:)])
        {
            [self.delegate titleInfoClickeAtContact:(ContactsEntity *)menuItem.dataObject];
        }
    }
}

- (void)quadCurveMenuDidExpand:(QuadCurveMenu *)menu
{
    if (menu.mainMenuButton.dataObject)
    {
        [menu closeMenu];
    }
}

@end
