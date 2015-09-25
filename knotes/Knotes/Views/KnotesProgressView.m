//
//  KnotableProgressView.m
//  Knotable
//
//  Created by Mac on 18/11/14.
//
//

#import "KnotesProgressView.h"
#import "AnimatedGIFImageSerialization.h"
#import "BWStatusBarOverlay.h"

@interface KnotableProgressView ()


@end

@implementation KnotableProgressView

- (id) init
{
    if (self = [super init]) {
        [self defaultSetup];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self defaultSetup];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        [self defaultSetup];
    }
    return self;
}

- (void) dealloc {
    
}

- (void) defaultSetup
{
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    self.isAnimating = NO;
    self.positionFromCentre = 0.0f;
    self.previousProgress = 0.0;
    self.statusBarLoaderView = [BWStatusBarOverlay shared];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
}

- (void) startAnimating
{
    
    
    if (![self viewWithTag:1])
    {
        NSString *progressViewImageName = nil;
        
        switch (_progressViewStyle) {
            case KnotableProgressViewStyleWhite:
                progressViewImageName = @"Loader.gif";
                break;
            case KnotableProgressViewStyleBlue:
            default:
                progressViewImageName = @"Loader-(blue).gif";
                break;
        }
        
        UIActivityIndicatorView * spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2 + _positionFromCentre);
        [spinner startAnimating];
        spinner.tag = 1;
        [self addSubview:spinner];
        
        self.isAnimating = YES;
        
    }
}

- (void) stopAnimating
{
    UIImageView *progressImageView = (UIImageView *)[self viewWithTag:1];
    if (progressImageView) {
        [progressImageView removeFromSuperview];
        self.isAnimating = NO;
        
    }
    
    UIActivityIndicatorView * spinner = (UIActivityIndicatorView *)[self viewWithTag:1];
    
    if (spinner) {
        [spinner stopAnimating];
        [spinner removeFromSuperview];
        self.isAnimating = NO;
        
    }
    
    self.isAnimating = NO;
}

#pragma mark StatusBar Loading View

-(void) startStatusBarLoading
{
    [self.statusBarLoaderView setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    [self.statusBarLoaderView showWithMessage:@"In Progress ..." loading:YES animated:YES];
}

-(void) finishStatusBarLoading
{
    [self.statusBarLoaderView dismissAnimated:YES];
}

- (void) startProgressWithTitle:(NSString*)progressTitle
{
    [self.statusBarLoaderView setStatusBarStyle:UIStatusBarStyleDefault animated:NO];
    
    [self.statusBarLoaderView showWithMessage:progressTitle loading:YES animated:NO];
}

- (void) stopProgressBar
{
    [self.statusBarLoaderView dismissAnimated:YES];
}

#pragma mark

- (void) setAlpha:(CGFloat)alpha
{
    if (alpha > 0.0)
    {
        [self startAnimating];
    }
    else
    {
        [self stopAnimating];
    }
    
    [super setAlpha:alpha];
}

@end