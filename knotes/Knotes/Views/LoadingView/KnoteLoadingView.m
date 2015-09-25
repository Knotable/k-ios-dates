//
//  KnoteBMBV.m
//  Knotable
//
//  Created by Lin on 31/7/14.
//
//

#import "KnoteLoadingView.h"
#import "DesignManager.h"

@implementation KnoteLoadingView

-(id)init
{
    self =[super init];
    
    if (self) {
        // Initialization code
        
        NSArray *arrayOfViews = [[NSBundle mainBundle] loadNibNamed:@"KnoteLoadingView" owner:self options:nil];
        
        if ([arrayOfViews count] < 1) {
            return nil;
        }
        
        if (![[arrayOfViews objectAtIndex:0] isKindOfClass:[KnoteLoadingView class]]) {
            return nil;
        }
        
        self = [arrayOfViews objectAtIndex:0];
    }

    CGFloat notify_xPos = 0.0f;
    CGFloat notify_yPos = 0.0f;
    
    notify_xPos = (320 - self.superview.frame.size.width) / 2;
    notify_yPos = (self.superview.frame.size.height - 64 - self.frame.size.height) / 2;
    
    [self setFrame:CGRectMake(notify_xPos, notify_yPos, self.frame.size.width, self.frame.size.height)];
    
    [self startAnimation];
    
    return self;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)setNeedsLayout
{
    [super setNeedsLayout];
    
    [self startAnimation];    
}

- (void)setNeedsDisplay
{
    [super setNeedsDisplay];
    
    [self startAnimation];
}


- (void)drawPathAnimation:(NSTimer *)timer
{
    self.anglePer += 0.03f;
    
    if (self.anglePer >= 1)
    {
        self.anglePer = 1;
        [timer invalidate];
        self.timer = nil;
        [self startRotateAnimation];
    }
}

- (void)startAnimation
{
    if (self.isAnimating)
    {
        [self stopAnimation];
        [self.loadingImageView.layer removeAllAnimations];
    }
    
    _isAnimating = YES;
    
    self.anglePer = 0;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.02f target:self selector:@selector(drawPathAnimation:) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)startRotateAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    animation.fromValue = @(0);
    animation.toValue = @(2*M_PI);
    animation.duration = 1.f;
    animation.repeatCount = INT_MAX;
    [self.loadingImageView.layer addAnimation:animation forKey:@"keyFrameAnimation"];
}

- (void)stopAnimation
{
    _isAnimating = NO;
    
    if ([self.timer isValid]) {
        [self.timer invalidate];
        self.timer = nil;
    }
    
    [self stopRotateAnimation];
}

- (void)stopRotateAnimation
{
    [UIView animateWithDuration:0.3f animations:^{
        self.loadingImageView.alpha = 0;
    } completion:^(BOOL finished) {
        self.anglePer = 0;
        [self.loadingImageView.layer removeAllAnimations];
        self.loadingImageView.alpha = 1;
    }];
}

-(void)dismiss
{
    [self stopAnimation];
}

@end
