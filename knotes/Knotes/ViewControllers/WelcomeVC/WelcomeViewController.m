//
//  WelcomeViewController.m

#import "WelcomeViewController.h"
#import "AppDelegate.h"
#import "UIImage+Retina4.h"
#import "DesignManager.h"
#import "Utilities.h"
#import "EAIntroPage.h"

#define kSwipFont               kCustomLightFont(16)
#define kSwipText               @"Swipe to know more"
#define kHaveText               @"Ready to knote?"

#define kIntroBackgroundImg     @"background.png"
#define kTitleFirstTutorial     @"Cleaner Conversations"
#define kDescrFirstTutorial     @"Edit, comment & delete. Don't tangle the thread."
#define kTitleSecondTutorial    @"Use more than words."
#define kDescrSecondTutorial    @"Create votes, tasks, & deadlines. Move forward."
#define kTitleThirdTutorial     @"Get on the same page"
#define kDescrThirdTutorial     @"Add & remove people. Forget 'fwd' and 're'."
#define kTitleFourthTutorial    @"Seamless with email"
#define kDescrFourthTutorial    @"Supercharge conversations with once 'cc'."

#define kImageTitleIconWidth    220.0f
#define kImageTitleIconHeight   380.0f

#define kMakeImgStr             @"tutorial_first.png"
#define kShareImgStr            @"tutorial_second.png"
#define kDiscussImgStr          @"tutorial_third.png"
#define kDecideImgStr           @"tutorial_fourth.png"

#define kPageCtrlHeight         10
#define kPageAnimateDuration    0.3f

@interface WelcomeViewController ()

@end

@implementation WelcomeViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
	if (self) {
		// Custom initialization
	}
	return self;
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self showCustomIntro];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

#define kDefaultTitleFontSize                   18.0f
#define kDefaultDescriptionFontSize             15.0f
#define DEFAULT_TITLE_IMAGE_Y_POSITION          40.0f
#define DEFAULT_TITLE_LABEL_Y_POSITION          130.0f
#define DEFAULT_DESCRIPTION_LABEL_Y_POSITION    104.0f

- (void)showCustomIntro
{
    UIView *rootView = self.view;
    
    EAIntroPage *page1      = [EAIntroPage page];
    page1.title             = kSwipText;
    page1.titleFont         = [UIFont fontWithName:@"HelveticaNeue-Light" size:kDefaultTitleFontSize]/*[UIFont fontWithName:@"HelveticaNeue-Bold" size:kDefaultTitleFontSize]*/;
    page1.bgImage           = [UIImage imageNamed:(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) && ([UIScreen mainScreen].bounds.size.height > 480.0f) ? @"Default-568h" : @"Default"];
    page1.showTitleView     = NO;
    
    EAIntroPage *page2      = [EAIntroPage page];
    page2.title             = kTitleFirstTutorial;
    page2.titleFont         = [UIFont fontWithName:@"HelveticaNeue-Light" size:kDefaultTitleFontSize]/*[UIFont fontWithName:@"HelveticaNeue-Bold" size:kDefaultTitleFontSize]*/;
    page2.titlePositionY    = DEFAULT_TITLE_LABEL_Y_POSITION;
    page2.desc              = kDescrFirstTutorial;
    page2.descWidth         = kImageTitleIconWidth;
    page2.descFont          = [UIFont fontWithName:@"HelveticaNeue-Light" size:kDefaultDescriptionFontSize];
    page2.descPositionY     = DEFAULT_DESCRIPTION_LABEL_Y_POSITION;
    page2.bgImage           = [UIImage imageNamed:kIntroBackgroundImg];
    page2.titleIconView     = [[UIImageView alloc] initWithImage:[Utilities imageResize:[UIImage imageNamed:kMakeImgStr] andResizeTo:CGSizeMake(kImageTitleIconWidth, kImageTitleIconHeight)]];
    page2.titleIconPositionY= DEFAULT_TITLE_IMAGE_Y_POSITION;
    
    EAIntroPage *page3      = [EAIntroPage page];
    page3.title             = kTitleSecondTutorial;
    page3.titleFont         = [UIFont fontWithName:@"HelveticaNeue-Light"/*@"HelveticaNeue-Bold"*/ size:kDefaultTitleFontSize];
    page3.titlePositionY    = DEFAULT_TITLE_LABEL_Y_POSITION;
    page3.desc              = kDescrSecondTutorial;
    page3.descWidth         = kImageTitleIconWidth;
    page3.descFont          = [UIFont fontWithName:@"HelveticaNeue-Light" size:kDefaultDescriptionFontSize];
    page3.descPositionY     = DEFAULT_DESCRIPTION_LABEL_Y_POSITION;
    page3.bgImage           = [UIImage imageNamed:kIntroBackgroundImg];
    page3.titleIconView     = [[UIImageView alloc] initWithImage:[Utilities imageResize:[UIImage imageNamed:kShareImgStr] andResizeTo:CGSizeMake(kImageTitleIconWidth, kImageTitleIconHeight)]];
    page3.titleIconPositionY= DEFAULT_TITLE_IMAGE_Y_POSITION;

    
    EAIntroPage *page4      = [EAIntroPage page];
    page4.title             = kTitleThirdTutorial;
    page4.titleFont         = [UIFont /*fontWithName:@"HelveticaNeue-Bold"*/fontWithName:@"HelveticaNeue-Light" size:kDefaultTitleFontSize];
    page4.titlePositionY    = DEFAULT_TITLE_LABEL_Y_POSITION;
    page4.desc              = kDescrThirdTutorial;
    page4.descFont          = [UIFont fontWithName:@"HelveticaNeue-Light" size:kDefaultDescriptionFontSize];
    page4.descWidth         = kImageTitleIconWidth;
    page4.descPositionY     = DEFAULT_DESCRIPTION_LABEL_Y_POSITION;
    page4.bgImage           = [UIImage imageNamed:kIntroBackgroundImg];
    page4.titleIconView     = [[UIImageView alloc] initWithImage:[Utilities imageResize:[UIImage imageNamed:kDiscussImgStr] andResizeTo:CGSizeMake(kImageTitleIconWidth, kImageTitleIconHeight)]];
    page4.titleIconPositionY= DEFAULT_TITLE_IMAGE_Y_POSITION;
    
    EAIntroPage *page5      = [EAIntroPage page];
    page5.title             = kTitleFourthTutorial;
    page5.titleFont         = [UIFont /*fontWithName:@"HelveticaNeue-Bold"*/fontWithName:@"HelveticaNeue-Light" size:kDefaultTitleFontSize];
    page5.titlePositionY    = DEFAULT_TITLE_LABEL_Y_POSITION;
    page5.desc              = kDescrFourthTutorial;
    page5.descFont          = [UIFont fontWithName:@"HelveticaNeue-Light" size:kDefaultDescriptionFontSize];
    page5.descWidth         = kImageTitleIconWidth;
    page5.descPositionY     = DEFAULT_DESCRIPTION_LABEL_Y_POSITION;
    page5.bgImage           = [UIImage imageNamed:kIntroBackgroundImg];
    page5.titleIconView     = [[UIImageView alloc] initWithImage:[Utilities imageResize:[UIImage imageNamed:kDecideImgStr] andResizeTo:CGSizeMake(kImageTitleIconWidth, kImageTitleIconHeight)]];
    page5.titleIconPositionY= DEFAULT_TITLE_IMAGE_Y_POSITION;
    
    EAIntroView *intro      = [[EAIntroView alloc] initWithFrame:rootView.bounds andPages:@[page1,page2,page3,page4,page5]];
    [intro setDelegate:self];
    [intro showInView:rootView animateDuration:kPageAnimateDuration];
}

- (void) skipclicked : (UIButton *)button
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.0f;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
    transition.type = kCATransitionFromRight;
    [transition setType:kCATransitionPush];
    transition.subtype = kCATransitionFromRight;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:NO];
    
    [AppDelegate setNotFirstUser];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma marks - EAIntroView

- (void)introDidFinish:(EAIntroView *)introView{
    [self skipclicked:nil];
}

- (void)intro:(EAIntroView *)introView pageAppeared:(EAIntroPage *)page withIndex:(NSInteger)pageIndex{

}

- (void)intro:(EAIntroView *)introView pageStartScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex{

}

- (void)intro:(EAIntroView *)introView pageEndScrolling:(EAIntroPage *)page withIndex:(NSInteger)pageIndex{

}

@end
