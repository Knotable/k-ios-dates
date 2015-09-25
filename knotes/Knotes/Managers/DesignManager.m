//
//  DesignManager.m
//  Knotable
//
//  Created by Martin Ceperley on 1/29/14.
//
//

#import "DesignManager.h"

#import "UIButton+Extensions.h"
#import "UIImage+Retina4.h"

@implementation DesignManager

+ (UIColor *) appBackgroundColor
{
    return [UIColor colorWithPatternImage:[UIImage retina4ImageNamed:@"login-background"]];
    return [UIColor colorWithWhite:0.9 alpha:1.0];
}

+ (UIColor *) navBarBackgroundColor
{
    return [UIColor colorWithPatternImage:[UIImage retina4ImageNamed:@"login-background"]];
    return [UIColor colorWithWhite:0.9 alpha:1.0];
}

+ (UIColor *) progressViewBackgroundColor
{
    return [UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5f];
}

+ (UIColor *) editingBackgroundColor
{
    return [UIColor colorWithRed:0.22 green:0.25 blue:0.32 alpha:0.9];
}

+ (UIImage *)appBackgroundImage
{
    return [UIImage retina4ImageNamed:@"people-bg.png"];
}

+ (UIImageView *)appBackgroundView
{
    return [[UIImageView alloc] initWithImage:[self appBackgroundImage]];
}

+ (UIColor *) knoteBackgroundColor
{
    return [UIColor whiteColor];
}

+ (CGFloat) knoteBackgroundOpacity
{
    return 1.0;
}

+ (CGFloat) knoteHighlightedBackgroundOpacity
{
    return 0.6;
}


+ (NSUInteger) knoteCornerRadius
{
    return 0;
}

+ (UIColor *) knoteHeaderTextColor
{
    return [UIColor colorWithWhite:0.22 alpha:1.0];
}

+ (UIColor *) knoteBodyTextColor
{
    return [UIColor colorWithWhite:0.0 alpha:1.0];
}

+ (UIColor *) knoteNavigationBarTintColor
{
    return [UIColor colorWithRed:17/255.0 green:169/255.0 blue:244/255.0 alpha:1.0f];
    
    //[UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0f];
}

+ (UIColor *) knotePostButtonTextColor
{
    return [UIColor colorWithRed:0.0 green:182/255.0 blue:248/255.0 alpha:1.0f];
}


+ (UIColor *) knoteComposeScreenBottomBarTintColor
{
    return [UIColor whiteColor];
}

+ (UIColor *) knoteProgressBarTintColor
{
    return [UIColor colorWithRed:47/255.0 green:189/255.0 blue:244/255.0 alpha:1.0f];
}

+ (UIFont *) knoteRealnameFont
{
#if NEW_DESIGN
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    //return [UIFont fontWithName:@"Roboto-Regular" size:12.0];
#else
    return [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0];
#endif
}

+ (UIFont *) knoteUsernameFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
}

+ (UIFont *) knoteTimeFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
}

+ (UIColor *) knoteUsernameColor
{
    return [UIColor colorWithRed:22.0/255.0 green:73.0/255.0 blue:228.0/255.0 alpha:1.0];
}

+ (UIColor *) mutiUserColor
{
    return [UIColor colorWithRed:58/255.0 green:120/255.0 blue:220.0/255.0 alpha:1.0];
}
+ (UIFont *) knoteTitleFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:19.0];
    //return [UIFont fontWithName:@"HelveticaNeue-Bold" size:19.0];
}
+ (UIFont *) knoteBodyFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
       // return [UIFont systemFontOfSize:14.0];
}

+ (UIFont *) knoteHeaderFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
    //return [UIFont boldSystemFontOfSize:18.0];
}
+ (UIFont *) knoteSmallTitleFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    //return [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0];
}

+ (UIFont *) knoteSmallHeaderFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    //return [UIFont boldSystemFontOfSize:16.0];
}

+ (UIFont *) knoteLoginButtonFonts
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    //return [UIFont fontWithName:@"Roboto-Bold" size:16.0];
}
+ (UIFont *) knoteLoginFieldsFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
    //return [UIFont fontWithName:@"Roboto-Regular" size:16.0];
}
+ (UIFont *) knoteSubjectFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0];
    //return [UIFont fontWithName:@"Roboto-Regular" size:16.0];
}
+ (UIFont *) knoteWelcomeFontWithSize:(float)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
    //return [UIFont fontWithName:@"Roboto-Regular" size:size];
}

+ (UIFont *) knoteWelcomeFontRobotoLightWithSize:(float)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
    //return [UIFont fontWithName:@"Roboto-Light" size:size];
}
+ (UIFont *) knoteWelcomeBoldFontWithSize:(float)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:size];
    //return [UIFont fontWithName:@"Roboto-Bold" size:size];
}

+ (UIFont *)dateWidgetTopLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0];
   // return [UIFont boldSystemFontOfSize:14.0];
}

+ (UIFont *)dateWidgetMidleLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:13.0];
    //return [UIFont fontWithName:@"HelveticaNeue" size:13];
}

+ (UIFont *)dateWidgetBottomLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
    //return [UIFont fontWithName:@"HelveticaNeue-Medium" size:15.0];
}

+ (UIFont *)dateWidgetMailLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:50.0];
    //return [UIFont fontWithName:@"HelveticaNeue-Thin" size:50.0];
}

+ (UIFont *)dateWidgetIndicateLabelFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:10.0];
    //return [UIFont boldSystemFontOfSize:10.0];
}

+ (UIFont *)smallButtonFont
{
    return [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
    //return [UIFont boldSystemFontOfSize:12.0];
}

+ (void)configureMoreButton:(UIButton *)moreButton
{
    [moreButton setTitle:@"More" forState:UIControlStateNormal];

    moreButton.backgroundColor = [UIColor clearColor];
    moreButton.titleLabel.font = [DesignManager smallButtonFont];

    [moreButton setTitleColor:[DesignManager knoteBodyTextColor] forState:UIControlStateNormal];
    [moreButton setTitleColor:[DesignManager knoteHeaderTextColor] forState:UIControlStateHighlighted];

    [moreButton setHitTestEdgeInsets:UIEdgeInsetsMake(-10, -10, -10, -10)];
}

+ (NSDictionary *)linkTextAttributes
{
    UIColor *linkColor = [DesignManager knoteUsernameColor];
    return @{
            NSForegroundColorAttributeName:linkColor,
            NSUnderlineColorAttributeName:linkColor,
            NSUnderlineStyleAttributeName:@(NSUnderlineStyleSingle)
    };
}

+ (UIColor *) KnoteSelectedColor
{
    return [UIColor colorWithRed:13.0f/255.0f green:107.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
}

+ (UIColor *) KnoteNormalColor
{
    return [UIColor colorWithRed:146.0f/255.0f green:146.0f/255.0f blue:146.0f/255.0f alpha:1.0f];
}

+ (UIColor *) KnoteBMBBackgroundColor
{
    return [UIColor colorWithRed:248.0f/255.0f green:248.0f/255.0f blue:248.0f/255.0f alpha:1.0f];
}

+ (UIColor *) KnoteSearchGrayBackgroudColor
{
    return [UIColor colorWithRed:234.0f/255.0f green:235.0f/255.0f blue:237.0f/255.0f alpha:1.0f];
}

+ (UIColor *) KnoteReleaseBackgroudColor
{
    return [UIColor colorWithRed:156.0f/255.0f green:224.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
}

+ (UIColor *) KnoteCommentsTimeLabelColor
{
    return [UIColor lightGrayColor];
}

+ (UIColor *) knoteBookMarkColor
{
    return [UIColor redColor];
}

@end