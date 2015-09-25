//
//  LoginProcessViewController.m
//  Knotable
//
//  Created by wuli on 8/29/14.
//
//

#import "LoginProcessViewController.h"
#import <Masonry/Masonry.h>
#import "CBaseWelcomeView.h"
#import "CUtil.h"
#import "KnotesProgressView.h"
#import "Constant.h"

#define kProcessView    0

@interface LoginProcessViewController ()

@property (nonatomic, assign) CGFloat anglePer;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UIImageView *bgView;
@property (nonatomic, retain) UILabel *lblWelcome;
@property (nonatomic , strong) KnotableProgressView *knotProgressView;

@end

@implementation LoginProcessViewController

@synthesize vcTag = _vcTag;

-(void)viewDidLoad
{
    [super viewDidLoad];

    self.vcTag = LOGIN_PROCESS_VC;
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;

//    NSString *launchImage = nil;
//    
//    if  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) &&
//         ([UIScreen mainScreen].bounds.size.height > 480.0f))
//    {
//        launchImage = @"background-568h";
//    }
//    else
//    {
//        launchImage = @"background";
//    }
    
//    launchImage = @"ComposeScreen";
//
//    self.bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:launchImage]];
//    
//    CGRect frame = self.view.bounds;
//    frame.origin.y += 20;    // status bar
//    frame.size.height -= 20; // status bar
//    self.bgView.frame = frame;
//    self.bgView.alpha = 0.7;
//    
//    [self.view addSubview:self.bgView];
//    [self.view sendSubviewToBack:self.bgView];
//    
//    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.view.mas_centerX);
//        make.centerY.equalTo(self.view.mas_centerY).offset(-40);
//        make.bottom.equalTo(self.view.mas_bottom);
//    }];
    
//    UIImageView *knotable_icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"knotable_icon.png"]];
//    
//    [self.view addSubview:knotable_icon];
//    
//    [knotable_icon setCenter:self.view.center];

    self.knotProgressView = [[KnotableProgressView alloc]initWithFrame:self.view.bounds];
    self.knotProgressView.positionFromCentre = 130.0f;
    self.knotProgressView.progressViewStyle = KnotableProgressViewStyleWhite;
    
    [self.view addSubview:_knotProgressView];
}

- (void)startAnimation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)stopAnimation
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

-(void)dismiss
{
    [self stopAnimation];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.navigationController popViewControllerAnimated:NO];
        
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    [self startAnimation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopAnimation];
}

@end
