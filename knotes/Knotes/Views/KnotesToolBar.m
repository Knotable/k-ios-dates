//
//  KnotableToolBar.m
//  Knotable
//
//  Created by Mac on 27/11/14.
//
//

#import "KnotesToolBar.h"
#import "DesignManager.h"

@implementation KnotableToolBar

- (id) init
{
    if (self = [super init]) {
        [self setUpDefault];
    }
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setUpDefault];
    }
    return self;
}

- (void) setUpDefault
{
    if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_6_1)
    {
        /*for iOS 7 and newer*/
        [self setBarTintColor:[DesignManager knoteNavigationBarTintColor]];
    }
    else
    {
        /*for older versions than iOS 7*/
        [self setTintColor:[DesignManager knoteNavigationBarTintColor]];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
