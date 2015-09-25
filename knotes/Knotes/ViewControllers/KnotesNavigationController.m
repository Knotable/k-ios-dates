//
//  KnotableNavigationController.m
//  Knotable
//
//  Created by Mac on 17/11/14.
//
//

#import "KnotesNavigationController.h"
#import "DesignManager.h"
#import "CUtil.h"

@interface KnotableNavigationController ()
{
    BOOL shouldIgnorePushingViewControllers;
}
@end

@implementation KnotableNavigationController

-(instancetype)init {
    
    self = [super init];
    self.delegate=self;
    
    return self;
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
//    if (!shouldIgnorePushingViewControllers)
    {
        [super pushViewController:viewController animated:animated];
    }
    
    shouldIgnorePushingViewControllers = YES;
}

- (void)didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    shouldIgnorePushingViewControllers = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navBorder = [[UIView alloc] initWithFrame:CGRectMake(0,self.navigationBar.frame.size.height-1,self.navigationBar.frame.size.width, 0.5)];
    
    // Change the frame size to suit yours //
    
    [self.navBorder setBackgroundColor:[UIColor colorWithWhite:0.000 alpha:0.800]];
    [self.navBorder setOpaque:YES];
    [self.navigationBar addSubview:self.navBorder];
    /*NSDictionary *navBarTitleAttr =[NSDictionary dictionaryWithObjectsAndKeys:
                              [DesignManager knoteTitleFont],NSFontAttributeName,
                              [UIColor whiteColor], NSForegroundColorAttributeName, nil];

    [[UINavigationBar appearance] setTitleTextAttributes: navBarTitleAttr];
    
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
    {
        for iOS 7 and newer
        [[UINavigationBar appearance] setBarTintColor:[DesignManager knoteNavigationBarTintColor]];
    }
    else
    {    
        for older versions than iOS 7
        [[UINavigationBar appearance] setTintColor:[DesignManager knoteNavigationBarTintColor]];
    }*/
    
    // Remove the navigation bar shadows in iOS7
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    //[[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
