//
//  InputAccessViewManager.m
//  Knotable
//
//  Created by backup on 14-7-3.
//
//

#import "InputAccessViewManager.h"
#import "DesignManager.h"
#import "CustomBarButtonItem.h"
#import "UIImage+Tint.h"

@interface InputAccessViewManager()
@property (nonatomic, strong) UIToolbar *toolbar;
@end
@implementation InputAccessViewManager

SYNTHESIZE_SINGLETON_FOR_CLASS(InputAccessViewManager);

- (id)init
{
    self = [super init];
    if (self) {
        if (!self.toolbar) {
            self.toolbar =[[UIToolbar alloc] init];
            [self.toolbar setBarStyle:UIBarStyleDefault];
            [self.toolbar sizeToFit];
        }
    }
    return self;
}

- (UIBarButtonItem *)spaceButtonItem
{
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

#define FIXED_SIDE_PADDING 10
- (UIBarButtonItem *)spaceFixedButtonItem
{
    UIBarButtonItem * fixedSpaceB = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpaceB.width = FIXED_SIDE_PADDING;
    return fixedSpaceB;
}

- (UIToolbar *)inputAccessViewWithCameraDup {
    UIToolbar *toolbar =[[UIToolbar alloc] init];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
    {
        /*for iOS 7 and newer*/
        [toolbar setBarTintColor:[DesignManager knoteComposeScreenBottomBarTintColor]];
    }
    else
    {
        /*for older versions than iOS 7*/
        [toolbar setTintColor:[DesignManager knoteComposeScreenBottomBarTintColor]];
    }
    
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar sizeToFit];
    UIImage *cameraImage = [UIImage imageNamed:@"icon_camera_blue"];
    UIButton *cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cameraButton setImage:cameraImage forState:UIControlStateNormal];
    [cameraButton setFrame:CGRectMake(0, 0, cameraImage.size.width, cameraImage.size.height)];
    [cameraButton addTarget:self
                   action:@selector(cameraClicked)
         forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *cameraButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cameraButton];
    CustomBarButtonItem *shareItem = [CustomBarButtonItem barItemWithImage:[UIImage imageNamed:@"icon_people_shared"] selectedImage:[[UIImage imageNamed:@"icon_people_shared"] imageTintedWithColor:[UIColor lightGrayColor]] target:self action:@selector(sharedClicked)];
    shareItem.tag = 1;
    UIButton *rightBarBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    rightBarBtn.frame = CGRectMake(0,0,50,25);
    [rightBarBtn setTitleColor:[DesignManager knotePostButtonTextColor] forState:UIControlStateNormal];
    [rightBarBtn setTitle:@"Post" forState:UIControlStateNormal];
    [rightBarBtn addTarget:self action:@selector(postClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];
    toolbar.items = @[self.spaceFixedButtonItem, cameraButtonItem,self.spaceButtonItem,self.spaceButtonItem,rightBtn, self.spaceFixedButtonItem];
    return toolbar;
}

- (UIToolbar *)inputAccessViewWithCamera {

    UIBarButtonItem *imageInput = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_camera"] landscapeImagePhone:[UIImage imageNamed:@"camera-icon"] style:UIBarButtonItemStylePlain target:self action:@selector(cameraClicked)];
    [imageInput setTintColor:[UIColor grayColor]];
    CustomBarButtonItem *shareItem = [CustomBarButtonItem barItemWithImage:[UIImage imageNamed:@"icon_people_shared"] selectedImage:[[UIImage imageNamed:@"icon_people_shared"] imageTintedWithColor:[UIColor lightGrayColor]] target:self action:@selector(sharedClicked)];
    shareItem.tag = 1;
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(postClicked)];

    self.toolbar.items = @[self.spaceFixedButtonItem, imageInput,self.spaceButtonItem,self.spaceButtonItem,rightBtn, self.spaceFixedButtonItem];
    return self.toolbar;
}

- (UIToolbar *)inputAccessViewWithOutCameraDup
{
    UIToolbar *toolbar =[[UIToolbar alloc] init];
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
    {
        /*for iOS 7 and newer*/
        [toolbar setBarTintColor:[DesignManager knoteComposeScreenBottomBarTintColor]];
    }
    else
    {
        /*for older versions than iOS 7*/
        [toolbar setTintColor:[DesignManager knoteComposeScreenBottomBarTintColor]];
    }
    toolbar.backgroundColor = [DesignManager knoteComposeScreenBottomBarTintColor];
    [toolbar setBarStyle:UIBarStyleDefault];
    [toolbar sizeToFit];
    CustomBarButtonItem *shareItem = [CustomBarButtonItem barItemWithImage:[UIImage imageNamed:@"icon_people_shared"] selectedImage:[[UIImage imageNamed:@"icon_people_shared"] imageTintedWithColor:[UIColor lightGrayColor]] target:self action:@selector(sharedClicked)];
    shareItem.tag = 1;
    [shareItem setTintColor:[UIColor redColor]];
    
    UIButton *rightBarBtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    rightBarBtn.frame = CGRectMake(0,0,50,25);
    [rightBarBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightBarBtn setTitle:@"Post" forState:UIControlStateNormal];
    [rightBarBtn addTarget:self action:@selector(postClicked) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithCustomView:rightBarBtn];

    
    toolbar.items = @[self.spaceButtonItem,self.spaceButtonItem,rightBtn];
    return toolbar;
}

- (UIToolbar *)inputAccessViewWithOutCamera {
    
    CustomBarButtonItem *shareItem = [CustomBarButtonItem barItemWithImage:[UIImage imageNamed:@"icon_people_shared"] selectedImage:[[UIImage imageNamed:@"icon_people_shared"] imageTintedWithColor:[UIColor lightGrayColor]] target:self action:@selector(sharedClicked)];
    shareItem.tag = 1;
    [shareItem setTintColor:[UIColor redColor]];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStylePlain target:self action:@selector(postClicked)];

    self.toolbar.items = @[self.spaceButtonItem,self.spaceButtonItem,rightBtn];
    return self.toolbar;
}

- (void)cameraClicked
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(cameraButtonClicked)]) {
        [self.delegate cameraButtonClicked];
    }
}

- (void)sharedClicked
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(sharedButtonClicked)]) {
        [self.delegate sharedButtonClicked];
    }
}

- (void)postClicked
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(postButtonClicked)]) {
        [self.delegate postButtonClicked];
    }
}

@end
