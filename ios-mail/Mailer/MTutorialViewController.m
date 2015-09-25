//
//  MTutorialViewController.m
//  Mailer
//
//  Created by Mac 7 on 07/02/14.
//  Copyright (c) 2014 Knotable. All rights reserved.
//

#import "MTutorialViewController.h"
#import <QuartzCore/QuartzCore.h>

//#import "MDesignManager.h"

CGFloat kScrollObjHeight = 473.0;
CGFloat kScrollObjWidth	= 320.0;
const NSUInteger kNumImages		= 5;


@interface MTutorialViewController ()

@end

@implementation MTutorialViewController

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
    
//    self.navigationController.view.tintColor = [MDesignManager tintColor];
	// Do any additional setup after loading the view.
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"paper_clip.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
//    self.navigationItem.leftBarButtonItem = backButton;
    
//    imageScroll.contentSize = CGSizeMake(2582, 100);
    
    [imageScroll setBackgroundColor:[UIColor blackColor]];
	[imageScroll setCanCancelContentTouches:NO];
	imageScroll.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	imageScroll.clipsToBounds = YES;		// default is NO, we want to restrict drawing within our scrollview
	imageScroll.scrollEnabled = YES;
	
	// pagingEnabled property default is NO, if set the scroller will stop or snap at each photo
	// if you want free-flowing scroll, don't set this property.
	imageScroll.pagingEnabled = YES;
    
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    
    
    
//    if (height == 1024) {
        kScrollObjWidth = width;
        kScrollObjHeight = height;
//    }
    
    
    
    //Modified by 3E ------START------
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        //        NSLog(@"I'm definitely an iPad");
        _imageNameArray = @[@"inbox1_iPad.png",@"inbox2_iPad.png",@"inbox3_iPad.png",@"inbox4_iPad.png",@"inbox5_iPad.png"];
        
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone){
        
        if (self.view.frame.size.height  == 568.0f) {
            //iPhone5
             _imageNameArray = @[@"inbox1_iPhone5.png",@"inbox2_iPhone5.png",@"inbox3_iPhone5.png",@"inbox4_iPhone5.png",@"inbox5_iPhone5.png"];
            
        }
        else{
            //iPhone
             _imageNameArray = @[@"inbox1.png",@"inbox2.png",@"inbox3.png",@"inbox4.png",@"inbox5.png"];
        }
        
    }
    
    
    //Modified by 3E ------END------

    
    
    
//    imageScroll.layer.borderWidth = 10.0;
//    imageScroll.layer.borderColor = (__bridge CGColorRef)([UIColor cyanColor]);
    
//    imageScroll.layer.borderWidth = 2.0f;
//    imageScroll.layer.borderColor = [[UIColor cyanColor] CGColor];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self createDynamicScroll];

//    [self layoutScrollImages];
    
}

-(IBAction)backAction:(id)sender{
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark scroll Delegate

//for page control
- (void)scrollViewDidScroll:(UIScrollView *)sender {
    
    // Update the page when more than 50% of the previous/next page is visible
    int page = 0;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
        page = floor((imageScroll.contentOffset.x - 742 / 2) / 742) + 1;
    }
    else{
        page = floor((imageScroll.contentOffset.x - 294 / 2) / 294) + 1;
    }
    
//    NSLog(@"page =%d",page);
    
    scrollPageControl.currentPage = page;
}


-(void)createDynamicScroll{
    
    for (int i = 1; i <= kNumImages; i++)
	{
        
        UIImageView *imageView = [[UIImageView alloc] init ];//]WithImage:image];
		
		// setup each frame to a default height and width, it will be properly placed when we call "updateScrollList"
        
        imageView.frame = CGRectMake(0, 0, 320, 177);
        
        CGRect rect = imageView.frame;
        rect.size.height = kScrollObjHeight;
        rect.size.width = kScrollObjWidth;
        imageView.frame = rect;
        
        
//        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
		imageView.tag = i;	// tag our images for later use when we place them in serial fashion
         imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@",[_imageNameArray objectAtIndex:i-1]]];
		[imageScroll addSubview:imageView];
        
	}
	
	[self layoutScrollImages];
    
}



- (void)layoutScrollImages
{
	UIImageView *view = nil;
	NSArray *subviews = [imageScroll subviews];
    
	// reposition all image subviews in a horizontal serial fashion
	CGFloat curXLoc = 0;
	for (view in subviews)
	{
		if ([view isKindOfClass:[UIImageView class]])
		{
            
			CGRect frame = view.frame;
			frame.origin = CGPointMake(curXLoc, 0);
			view.frame = frame;
			
			curXLoc += (kScrollObjWidth);
		}
	}
    
	// set the content size so it can be scrollable
	[imageScroll setContentSize:CGSizeMake((kNumImages * kScrollObjWidth), [imageScroll bounds].size.height-100)];
}

@end
