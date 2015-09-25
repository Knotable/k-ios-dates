//
//  KNCustomAlertView.m
//  Knotable
//
//  Created by Emiliano Barcia Lizarazu on 02/10/14.
//
//

#import "KNCustomAlertView.h"

@interface KNCustomAlertView()

@property (nonatomic, strong) UIImageView * alertImageView;
@property (nonatomic, strong) UIImageView * savedImageText;

@end

@implementation KNCustomAlertView

#define ALERT_BACKGROUND_SIZE   210
#define ALERT_SAVED_IMAGE_SIZE  103
#define ALERT_SAVED_TEXT_WIDTH   70
#define ALERT_SAVED_TEXT_HEIGHT  27
#define VERTICAL_PADDING_SAVED_IMAGE 40
#define VERTICAL_PADDING_SAVED_TEXT  30

-(void)setup
{
    self.alpha = 0;
    
    // Alert Background
    self.alertImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.alertImageView.image = [UIImage imageNamed:@"savedTextBackground.png"];
    //self.alertImageView.alpha = 0;
    
    UIImageView * savedImage = [[UIImageView alloc] initWithFrame:CGRectMake( (self.alertImageView.frame.size.width - ALERT_SAVED_IMAGE_SIZE) / 2, (self.alertImageView.frame.size.height - ALERT_SAVED_IMAGE_SIZE - VERTICAL_PADDING_SAVED_IMAGE) / 2, ALERT_SAVED_IMAGE_SIZE, ALERT_SAVED_IMAGE_SIZE)];
    savedImage.image = [UIImage imageNamed:@"checkIcon.png"];
    
    self.savedImageText = [[UIImageView alloc] initWithFrame:CGRectMake( (self.alertImageView.frame.size.width - ALERT_SAVED_TEXT_WIDTH) / 2, (self.alertImageView.frame.size.height - ALERT_SAVED_TEXT_HEIGHT - VERTICAL_PADDING_SAVED_TEXT ), ALERT_SAVED_TEXT_WIDTH, ALERT_SAVED_TEXT_HEIGHT)];
    self.savedImageText.image = [UIImage imageNamed:@"savedText.png"];
    self.savedImageText.alpha = 0;
    
    [self.alertImageView addSubview:self.savedImageText];
    [self.alertImageView addSubview:savedImage];
    [self  addSubview:self.alertImageView];
}

-(void)animate
{
    POPBasicAnimation * fadeIn = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    fadeIn.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    fadeIn.fromValue = @(0);
    fadeIn.toValue = @(1);
    fadeIn.beginTime = CACurrentMediaTime();
    fadeIn.duration = 0.2;
    fadeIn.delegate = self;
    [self.layer pop_addAnimation:fadeIn forKey:@"fadeIn"];
    
    POPBasicAnimation * scaleUP = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleUP.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scaleUP.duration = 0.2;
    scaleUP.beginTime = CACurrentMediaTime();
    scaleUP.fromValue = [NSValue valueWithCGSize:CGSizeMake(0, 0)];
    scaleUP.toValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
    scaleUP.delegate = self;
    [self.layer pop_addAnimation:scaleUP forKey:@"scaleUP"];
    
    POPBasicAnimation * fadeInText = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    fadeInText.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    fadeInText.fromValue = @(0);
    fadeInText.toValue = @(1);
    fadeInText.beginTime = CACurrentMediaTime() + 0.2;
    fadeInText.duration = 0.1;
    fadeInText.delegate = self;
    [self.savedImageText.layer pop_addAnimation:fadeInText forKey:@"fadeInText"];
    
    POPBasicAnimation * scaleUpText = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleUpText.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scaleUpText.duration = 0.1;
    scaleUpText.beginTime = CACurrentMediaTime() + 0.2;
    scaleUpText.fromValue = [NSValue valueWithCGSize:CGSizeMake(0, 0)];
    scaleUpText.toValue  = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
    scaleUpText.delegate = self;
    [self.savedImageText.layer pop_addAnimation:scaleUpText forKey:@"scaleUpText"];
    
    POPBasicAnimation * fadeOut = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    fadeOut.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    fadeOut.fromValue = @(1);
    fadeOut.toValue = @(0);
    fadeOut.beginTime = CACurrentMediaTime() + 0.8;
    fadeOut.duration = 0.1;
    fadeOut.delegate = self;
    [self.layer pop_addAnimation:fadeOut forKey:@"fadeOut"];
    
    POPBasicAnimation * scaleDown = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleXY];
    scaleDown.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    scaleDown.duration = 0.1;
    scaleDown.beginTime = CACurrentMediaTime() + 0.8;
    scaleDown.fromValue = [NSValue valueWithCGSize:CGSizeMake(1.0f, 1.0f)];
    scaleDown.toValue  = [NSValue valueWithCGSize:CGSizeMake(0,0)];
    scaleDown.name = @"scaleDown";
    scaleDown.delegate = self;
    [self.layer pop_addAnimation:scaleDown forKey:@"scaleDown"];
}

- (void)pop_animationDidReachToValue:(POPAnimation *)anim
{
    if ([anim.name isEqualToString:@"scaleDown"])
    {
        [self performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:0.5];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setup];
    }
    return self;
}

-(id)init
{
    CGRect screenR = [UIScreen mainScreen].bounds;
    
    self = [self initWithFrame:CGRectMake( (screenR.size.width - ALERT_BACKGROUND_SIZE) / 2,
                                           (screenR.size.height - ALERT_BACKGROUND_SIZE) / 2, ALERT_BACKGROUND_SIZE, ALERT_BACKGROUND_SIZE)];
    
    return self;
}

@end
