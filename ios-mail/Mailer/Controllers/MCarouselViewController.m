//
//  MCarouselViewController.m
//  Mailer
//
//  Created by Martin Ceperley on 10/16/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MCarouselViewController.h"
#import "iCarousel.h"
#import "MMessageListController.h"
#import "Message.h"
#import "UIColor+MailExtensions.h"
#import "MDesignManager.h"

@interface MCarouselViewController ()

@end

@implementation MCarouselViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//Modified by 3E ------START------
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];

    [self webViewRelease];
    
}
//Modified by 3E ------END------


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //http://www.colourlovers.com/palette/3121928/mo_colours
    
    _backgroundColors = [[NSArray alloc] initWithObjects:
                       //[UIColor colorWithHexString:@"03738D"],
                       [MDesignManager tintColor],
                       [UIColor colorWithHexString:@"C9C714"],
                       [UIColor colorWithHexString:@"D4095F"],
                       [UIColor colorWithHexString:@"F08708"],
                       [UIColor colorWithHexString:@"130147"],
                       nil];
    
    _backgroundColorIndex = 0;
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"account.status = YES" ];
                             
    _frc = [Message fetchAllSortedBy:@"uid" ascending:NO withPredicate:predicate groupBy:nil delegate:nil];
    _frc.fetchRequest.fetchLimit = 10;
    [Message performFetch:_frc];
    _messages = [_frc.fetchedObjects copy];
    self.view.backgroundColor = [UIColor colorWithWhite:0.8 alpha:1.0];
    
    _master = (MMessageListController *)self.parentViewController;
    
    _carousel = [[iCarousel alloc] initWithFrame:self.view.bounds];
    
    _carousel.type = iCarouselTypeLinear;
    _carousel.delegate = self;
    _carousel.dataSource = self;
    
    [self.view addSubview:_carousel];
    [self.view sendSubviewToBack:_carousel];
    
//    //NSLog(@"_messages= %@",_messages);
    
    if ([_messages count]) {
        _subjectLabel.text = ((Message *)_messages[0]).subject;

    }
//     _subjectLabel.text = ((Message *)_messages[0]).subject;
    
    
    UITapGestureRecognizer *subjectRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(subjectTapped:)];
    [_subjectLabel addGestureRecognizer:subjectRecognizer];
    _subjectLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *backgroundRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
    [backgroundRecognizer requireGestureRecognizerToFail:subjectRecognizer];
    [self.view addGestureRecognizer:backgroundRecognizer];

}

- (void)backgroundTapped:(UITapGestureRecognizer *)recognizer
{
    [self exitGallery:recognizer];
}
- (void)subjectTapped:(UITapGestureRecognizer *)recognizer
{
    [self carousel:_carousel didSelectItemAtIndex:_carousel.currentItemIndex];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

 //Modified by 3E ------START------
#pragma mark - Clear webview

-(void)webViewRelease{
   
    for (Message *message in _messages) {
        if (message.webView != nil) {
            message.webView.delegate=nil;
            message.webView=nil;
        }
    }
    
}

//Modified by 3E ------END------

-(IBAction)exitGallery:(id)sender
{
    //Modified by 3E ------START------
    
    [self webViewRelease];
    
    //Modified by 3E ------END------
    
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

#pragma mark iCarouselDataSource methods

- (NSUInteger)numberOfItemsInCarousel:(iCarousel *)carousel
{
    return _messages.count;
}

- (UIView *)carousel:(iCarousel *)carousel viewForItemAtIndex:(NSUInteger)index reusingView:(UIView *)view
{
    if (view == nil) {
        view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200.0, 320.0)];
        view.backgroundColor = _backgroundColors[_backgroundColorIndex];
        _backgroundColorIndex = (1 + _backgroundColorIndex) % _backgroundColors.count;
        
    } else {
        for (UIView* subview in view.subviews) {
            [subview removeFromSuperview];
        }
    }
    
    Message *message = (Message *)_messages[index];
    
    if (message.image != nil) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:message.image];
        CGFloat scale = view.bounds.size.width / message.image.size.width;
        //imageView.transform = CGAffineTransformMakeScale(scale, scale);
        CGRect imageViewFrame = imageView.frame;
        imageViewFrame.size.height *= scale;
        imageViewFrame.size.width *= scale;
        imageView.frame = imageViewFrame;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [view addSubview:imageView];
    }
    else if (message.webView == nil) {
        
        UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 600, 960)];
        webView.delegate = self;
        webView.scalesPageToFit = NO;
        message.webView = webView;
        [webView loadHTMLString:message.htmlBody baseURL:nil];
    }

    return view;
}

#pragma mark iCarouselDelegate methods

- (CGFloat)carouselItemWidth:(iCarousel *)carousel
{
    return 230.0;
}

- (void)carouselWillBeginDragging:(iCarousel *)carousel
{
    _subjectLabel.hidden = YES;
}
- (void)carouselDidEndScrollingAnimation:(iCarousel *)carousel;
{
    _subjectLabel.hidden = NO;
}

- (void)carouselCurrentItemIndexDidChange:(iCarousel *)carousel
{
    _subjectLabel.text = ((Message *)_messages[carousel.currentItemIndex]).subject;
}

- (BOOL)carousel:(iCarousel *)carousel shouldSelectItemAtIndex:(NSInteger)index
{
    return YES;
}

- (void)carousel:(iCarousel *)carousel didSelectItemAtIndex:(NSInteger)index
{
    //Modified by 3E ------START------

    [self webViewRelease];
    
    //Modified by 3E ------END------
    
    //If it's not the current item, we just want to scroll to it, not open it
    
    if (index != carousel.currentItemIndex) {
        return;
    }
    
    Message* message = _messages[index];
    
    UIView* messageView = carousel.currentItemView;
    CGRect converted = [self.view convertRect:messageView.frame fromView:messageView];

    [messageView removeFromSuperview];
    
    [self.view addSubview:messageView];
    messageView.frame = converted;

    CGRect finalFrame = self.view.frame;
    finalFrame.size.height = finalFrame.size.width * (messageView.frame.size.height / messageView.frame.size.width);
    
    UINavigationController *navController = (UINavigationController *)self.presentingViewController;
    MMessageListController *messageList = navController.viewControllers.lastObject;
    
    [UIView animateWithDuration:0.5 animations:^{
        messageView.frame = finalFrame;
    } completion:^(BOOL finished) {
        [messageList showMessage:message animated:NO];
        [self dismissViewControllerAnimated:NO completion:^{
        }];
    }];
}

#pragma mark UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    //NSLog(@"webViewDidFinishLoad MCarousView");
    Message* message = nil;
    for (Message* mess in _messages) {
        
        if(webView == mess.webView){
            message = mess;
            break;
        }
    }
    if (message == nil) {
        return;
    }
    
    CGFloat scaleFactor = webView.bounds.size.width / webView.scrollView.contentSize.width;

    //NSLog(@"SNAPSHOT webview finished loading content size: %@ webview frame: %@ scrollview frame: %@ scalefactor: %f",
//          NSStringFromCGSize(webView.scrollView.contentSize),
//          NSStringFromCGRect(webView.frame),
//          NSStringFromCGRect(webView.scrollView.frame),
//          scaleFactor);
    
    //webView.scrollView.transform = CGAffineTransformMakeScale(scaleFactor, scaleFactor);
    
    webView.scrollView.zoomScale = webView.scrollView.minimumZoomScale = webView.scrollView.maximumZoomScale = scaleFactor;
    
    CGFloat scaledContentHeight = scaleFactor * webView.scrollView.contentSize.height;
    CGRect webViewFrame = webView.frame;
    webViewFrame.size.height = scaledContentHeight;
    webView.frame = webViewFrame;
    
    UIGraphicsBeginImageContextWithOptions(webView.frame.size, NO, [UIScreen mainScreen].scale);
    [webView.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    message.image = image;
        
    NSUInteger index = [_messages indexOfObject:message];
    [_carousel reloadItemAtIndex:index animated:YES];
    
}

@end
