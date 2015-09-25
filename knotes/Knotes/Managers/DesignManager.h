//
//  DesignManager.h
//  Knotable
//
//  Created by Martin Ceperley on 1/29/14.
//
//



@interface DesignManager : NSObject

// Colors

+ (UIColor *)appBackgroundColor;
+ (UIColor *)navBarBackgroundColor;
+ (UIColor *)editingBackgroundColor;
+ (UIColor *)knoteBackgroundColor;

+ (UIColor *) KnoteSelectedColor;
+ (UIColor *) KnoteNormalColor;
+ (UIColor *) KnoteBMBBackgroundColor;
+ (UIColor *) KnoteSearchGrayBackgroudColor;
+ (UIColor *) KnoteReleaseBackgroudColor;

+ (UIColor *) knoteNavigationBarTintColor;
+ (UIColor *) knoteComposeScreenBottomBarTintColor;
+ (UIColor *) knoteProgressBarTintColor;
+ (UIColor *) progressViewBackgroundColor;

+ (UIColor *) knotePostButtonTextColor;


// Numbers

+ (CGFloat)knoteBackgroundOpacity;
+ (CGFloat)knoteHighlightedBackgroundOpacity;

+ (NSUInteger)knoteCornerRadius;


// Text Colors

+ (UIColor *)knoteHeaderTextColor;
+ (UIColor *)knoteBodyTextColor;
+ (UIColor *)knoteUsernameColor;
+ (UIColor *)mutiUserColor;
+ (UIColor *)KnoteCommentsTimeLabelColor;
+ (UIColor *) knoteBookMarkColor;

// Images

+ (UIImage *)appBackgroundImage;
+ (UIImageView *)appBackgroundView;


// Fonts
+ (UIFont *) knoteRealnameFont;
+ (UIFont *) knoteUsernameFont;
+ (UIFont *) knoteTimeFont;
+ (UIFont *) knoteTitleFont;
+ (UIFont *)knoteBodyFont;
+ (UIFont *)knoteHeaderFont;
+ (UIFont *) knoteSmallTitleFont;
+ (UIFont *)knoteSmallHeaderFont;
+ (UIFont *)smallButtonFont;
+ (UIFont *) knoteSubjectFont;

+ (UIFont *)dateWidgetTopLabelFont;
+ (UIFont *)dateWidgetMidleLabelFont;
+ (UIFont *)dateWidgetBottomLabelFont;
+ (UIFont *)dateWidgetMailLabelFont;
+ (UIFont *)dateWidgetIndicateLabelFont;
// Attributes

+ (UIFont *) knoteLoginFieldsFont;
+ (UIFont *) knoteLoginButtonFonts;
+ (UIFont *) knoteWelcomeFontWithSize:(float)size;
+ (UIFont *) knoteWelcomeBoldFontWithSize:(float)size;
+ (UIFont *) knoteWelcomeFontRobotoLightWithSize:(float)size;

+ (NSDictionary *)linkTextAttributes;

+ (void)configureMoreButton:(UIButton *)moreButton;


@end
