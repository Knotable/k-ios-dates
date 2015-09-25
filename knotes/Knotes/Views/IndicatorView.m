//
//  IndicatorView.m
//  Knotable
//
//  Created by wuli on 14-2-21.
//
//

#import "IndicatorView.h"
#import "FTAnimation+UIView.h"

@interface IndicatorView ()
@property (nonatomic, assign) NSInteger repeatTimes;
@end
@implementation IndicatorView

- (void)flashOut
{
    [self fadeIn:1 delegate:self startSelector:nil stopSelector:@selector(hiddenAtEnd)];

}

- (void)flashIn
{
    self.repeatTimes = 0;
    [self fadeOut:0.5 delegate:self startSelector:nil stopSelector:@selector(showAtEnd)];
}

- (void)showAtEnd
{
    if (self.repeatTimes<2) {
        self.repeatTimes++;
        [self fadeIn:0.5 delegate:self startSelector:nil stopSelector:@selector(showAtEnd)];
    } else {
        [self fadeIn:0.5 delegate:self startSelector:nil stopSelector:@selector(stopFlash)];
    }
}

- (void)stopFlash
{
    [self.layer removeAllAnimations];
}

- (void)hiddenAtEnd
{
    [self fadeOut:1 delegate:self startSelector:nil stopSelector:@selector(stopFlash)];
}

@end
