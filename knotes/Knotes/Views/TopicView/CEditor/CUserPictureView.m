//
//  CProfilePictureView.m
//  Knotable
//
//  Created by Agustin Guerra on 8/27/14.
//
//

#import "CUserPictureView.h"

#import "CUtil.h"
#import "ContactsEntity.h"
#import "ObjCMongoDB.h"
#import "ContactManager.h"
#import "ThreadItemManager.h"

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

@interface CUserPictureView()<QuadCurveMenuDelegate>

@property (nonatomic, assign) BOOL didSetupConstraints;
@property (nonatomic, strong) NSMutableArray *editors;

@end

@implementation CUserPictureView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        self.menu = [[QuadCurveMenu alloc] initWithFrame:self.bounds centerPoint:CGPointMake(kDefaultUserPictureSizeInRecent / 2, kDefaultUserPictureSizeInRecent / 2) dataSource:nil mainMenuFactory:nil menuItemFactory:nil];
        self.menu.delegate = self;
        [self.menu setMenuDirector:[[QuadCurveCustomDirector alloc] initWithAngle:(4 * M_PI/2) andPadding:0]];
        [self addSubview:self.menu];
    }
    return self;
}

- (UIImage *)getImageByString:(NSString *)str subString:(NSString *)substr {
    UIImage *img = nil;
    if ([str hasPrefix:@"bgcolor"]) {
        NSString *str = substr;
        if (str && [str length]>0) {
            img = [CUtil imageText:[[str substringWithRange:NSMakeRange(0,1)] uppercaseString] withBackground:str size:CGSizeMake(kDefaultUserPictureSizeInRecent, kDefaultUserPictureSizeInRecent) rate:0.6];
        }
    } else {
        NSString *path  = [kImageCachePath stringByAppendingPathComponent:str];
        if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            img = [UIImage imageWithContentsOfFile:path];
        }
        if (!img) {
            img = [UIImage imageNamed:str];
        }
    }
    if (img) {
        img = [img circlePlainImageSize:kDefaultUserPictureSizeInRecent];
    }
    return img;
}

- (QuadCurveMenuItem *) generaterItem:(ContactsEntity *)contact {
    NSString *realName = @"bgcolor0";
    if (contact) {
        realName = [contact userImageName];
    }
    UIImage *img = [self getImageByString:realName subString:contact.name];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
    [imgView setFrame:CGRectMake(0, 0, kDefaultUserPictureSizeInRecent, kDefaultUserPictureSizeInRecent)];
    QuadCurveMenuItem *imgMenuItem = [[QuadCurveMenuItem alloc] initWithView:imgView];
    imgMenuItem.dataObject = contact;
    return imgMenuItem;
}

- (void)setMessage:(MessageEntity *)message {
    if (message == nil) {
        return;
    }
    _message = message;
    
    ContactsEntity *contact = message.contact;
    
    NSString *realName = @"bgcolor0";
    NSString *userName = @"";
    
    NSArray *editors = nil;
    if (!contact) {//find in local
        if (message.account_id) {
            contact = [ContactsEntity MR_findFirstByAttribute:@"account_id" withValue:message.account_id];
        }
    }
    if (!contact) {//find in server
        __weak __typeof(&*self)weakSelf = self;
        [ContactManager findContactFromServerByAccountId:message.account_id withNofication:nil withCompleteBlock:^(WM_NetworkStatus success, NSError *error, id userData) {
            if (weakSelf != nil) {
                [weakSelf setMessage:message];
            }
        }];
    }
    
    if (message.editors) {
        editors = [NSKeyedUnarchiver unarchiveObjectWithData:message.editors];
    }
    
    if (editors && [editors count]>1) {
        self.editors = [NSMutableArray new];
        NSMutableArray *imageArray = [NSMutableArray new];
        NSMutableArray *contacts = [NSMutableArray new];
        for (NSDictionary *dic in editors) {
            ContactsEntity *editors_contact = [ContactsEntity MR_findFirstByAttribute:@"mainEmail" withValue:dic[@"email"]];
            if (!editors_contact) {
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"email like[cd] %@",[NSString stringWithFormat:@"*%@*",dic[@"email"]]];//查询条件
                editors_contact = [ContactsEntity MR_findFirstWithPredicate:predicate];
            }
            
            if (editors_contact) {
                if ([editors_contact isFault]) {
                    [editors_contact MR_refresh];
                }
                [contacts addObject:editors_contact.name];
                [self.editors addObject:editors_contact];
                QuadCurveMenuItem *imgMenuItem = [self generaterItem:editors_contact];
                [imageArray addObject:imgMenuItem];
            } else {
                if ([dic objectForKey:@"email"]) {
                    [ContactManager findContactFromServerByEmail:dic[@"email"]];
                    [contacts addObject:[[dic[@"email"] componentsSeparatedByString:@"@"] firstObject]];
                }
            }
        }
        
        realName = [contacts componentsJoinedByString:@", "];
        UIImage *img = [CUtil imageText:[NSString stringWithFormat:@"%d",(int)[editors count]] withSubText:@"authors" size:CGSizeMake(kDefaultUserPictureSizeInRecent, kDefaultUserPictureSizeInRecent) rate:0.6];
        img = [img circlePlainImageSize:kDefaultUserPictureSizeInRecent];
        NSInteger count = [imageArray count];
        CGFloat expandW = 4;
        switch (count) {
            case 1:
            {
                UIImageView *im1 = (UIImageView *)[(QuadCurveMenuItem *)[imageArray firstObject] contentView];
                UIImage *img1 = [im1.image copy];
                img = [img image1:img1 image2:nil image3:nil withSize:kDefaultUserPictureSizeInRecent + expandW];
            }
                break;
            case 2:
            {
                UIImageView *im1 = (UIImageView *)[(QuadCurveMenuItem *)[imageArray firstObject] contentView];
                UIImage *img1 = [im1.image copy];
                UIImageView *im2 = (UIImageView *)[(QuadCurveMenuItem *)[imageArray lastObject] contentView];
                UIImage *img2 = [im2.image copy];
                img = [img image1:img1 image2:img2 image3:nil withSize:kDefaultUserPictureSizeInRecent + expandW];
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
                img = [img image1:img1 image2:img2 image3:img3 withSize:kDefaultUserPictureSizeInRecent + expandW];
            }
                break;
            default:
            {
                if (count>3) {
                    UIImageView *im1 = (UIImageView *)[(QuadCurveMenuItem *)[imageArray objectAtIndex:count-3] contentView];
                    UIImage *img1 = [im1.image copy];
                    UIImageView *im2 = (UIImageView *)[(QuadCurveMenuItem *)[imageArray objectAtIndex:count-2] contentView];
                    UIImage *img2 = [im2.image copy];
                    UIImageView *im3 = (UIImageView *)[(QuadCurveMenuItem *)[imageArray objectAtIndex:count-1] contentView];
                    UIImage *img3 = [im3.image copy];
                    img = [img image1:img1 image2:img2 image3:img3 withSize:kDefaultUserPictureSizeInRecent + expandW];
                }
            }
                break;
        }
        if (img) {
            QuadCurveCustomMenuItemFactory *imgMenuItem = [[QuadCurveCustomMenuItemFactory alloc] initWithImage:img highlightImage:img];
            self.menu.mainMenuItemFactory = imgMenuItem;
            self.menu.dataSource =  [[QuadCurveDefaultDataSource alloc] initWithArray:imageArray];
            self.menu.menuItemFactory = [[QuadCurveCustomImageMenuItem alloc] init];
        } else {
            [self createUserImageWithMessage:message userName:userName andRealName:realName];
        }
    } else {
        //__block UIImage *img = nil;
        if (contact) {
            if ([contact isFault]) {
                [contact MR_refresh];
            }
            [ContactsEntity getAsyncImage:contact WithBlock:^(id img, BOOL flag) {
                if(flag){
                    img = [img circlePlainImageSize:kDefaultUserPictureSizeInRecent];
                    QuadCurveCustomMenuItemFactory *imgMenuItem = [[QuadCurveCustomMenuItemFactory alloc] initWithImage:img highlightImage:img];
                    self.menu.mainMenuItemFactory = imgMenuItem;
                    self.menu.mainMenuButton.dataObject = contact;
                }else{
                    [self createUserImageWithMessage:message userName:userName andRealName:realName];
                }
            }];
            realName = contact.username;
            userName = [NSString stringWithFormat:@"%@",contact.name];
        } else {
            [self createUserImageWithMessage:message userName:userName andRealName:realName];
        }
        
    }
    
    [self setNeedsUpdateConstraints];
}

-(void)createUserImageWithMessage:(MessageEntity*)message userName:(NSString*) userName andRealName:(NSString*) realName{
    
    UIImage *img;
    NSString *subStr = message.name;
    if (!subStr || [subStr length]<=1) {
        subStr = message.email;
    }
    if (subStr || [subStr length]<1) {
        subStr = @"X";//check....
    }
    img = [self getImageByString:realName subString:subStr];
    realName = message.name;
    userName = [NSString stringWithFormat:@"%@",message.name];
    if (img) {
        QuadCurveCustomMenuItemFactory *imgMenuItem = [[QuadCurveCustomMenuItemFactory alloc] initWithImage:img highlightImage:img];
        self.menu.mainMenuItemFactory = imgMenuItem;
    } else {
        NSLog(@"check!!!%@",message);
    }
    
}

- (void)updateConstraints {
    if (!self.didSetupConstraints) {
        
        [self.menu mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.didSetupConstraints = YES;
    }
    
    [super updateConstraints];
}

#pragma mark - QuadCurveMenuDelegate Adherence
- (void)quadCurveMenu:(QuadCurveMenu *)menu didTapMenu:(QuadCurveMenuItem *)mainMenuItem {
    if (mainMenuItem.dataObject) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(titleInfoClickeAtContact:)]) {
            [self.delegate titleInfoClickeAtContact:(ContactsEntity *)mainMenuItem.dataObject];
        }
        [menu closeMenu];
    }
}

- (void)quadCurveMenu:(QuadCurveMenu *)menu didTapMenuItem:(QuadCurveMenuItem *)menuItem {
    if (menuItem.dataObject) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(titleInfoClickeAtContact:)]) {
            [self.delegate titleInfoClickeAtContact:(ContactsEntity *)menuItem.dataObject];
        }
    }
}

- (void)quadCurveMenuDidExpand:(QuadCurveMenu *)menu {
    if (menu.mainMenuButton.dataObject) {
        [menu closeMenu];
    }
}

#if 0
- (void)quadCurveMenu:(QuadCurveMenu *)menu didLongPressMenu:(QuadCurveMenuItem *)mainMenuItem {
    NSLog(@"Menu - Long Pressed");
}

- (void)quadCurveMenu:(QuadCurveMenu *)menu didLongPressMenuItem:(QuadCurveMenuItem *)menuItem {
    NSLog(@"Menu Item (%@) - Long Pressed",menuItem.dataObject);
}

- (void)quadCurveMenuWillExpand:(QuadCurveMenu *)menu {
    NSLog(@"Menu - Will Expand");
}

- (void)quadCurveMenuWillClose:(QuadCurveMenu *)menu {
    NSLog(@"Menu - Will Close");
}

- (void)quadCurveMenuDidClose:(QuadCurveMenu *)menu {
    NSLog(@"Menu - Did Close");
}

- (BOOL)quadCurveMenuShouldClose:(QuadCurveMenu *)menu {
    return YES;
}

- (BOOL)quadCurveMenuShouldExpand:(QuadCurveMenu *)menu {
    return YES;
}
#endif

@end

