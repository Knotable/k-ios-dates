//
//  CUtil.h
//  Market
//
//  Created by backup on 13-8-1.
//  Copyright (c) 2013年 backup. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CommonCrypto/CommonDigest.h>
#import "ThreadConst.h"


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
//#define kCustomBoldFont(x)  [UIFont boldSystemFontOfSize:(x)]
//#define kCustomLightFont(x)  [UIFont systemFontOfSize:(x)]
#define kCustomBoldFont(x)  [UIFont fontWithName:@"HelveticaNeueLTPro-Bd" size:(x)]
#define kCustomLightFont(x)  [UIFont fontWithName:@"HelveticaNeueLTPro-Lt" size:(x)]

#define kTextColor [UIColor darkGrayColor]
#define kUserNameColor [UIColor colorWithRed:0.0/255 green:162.0/255 blue:232.0/255 alpha:1]
#define kInputTextColor [UIColor blackColor]

#define KTableBGColor [UIColor colorWithPatternImage:[UIImage imageNamed:@"tablebg"]]
//[UIColor lightGrayColor]
//[UIColor colorWithRed:39.0/255 green:45.0/255 blue:53.0/255 alpha:1]
#define kTextBGColor [UIColor whiteColor]
//#define kTextBGColor [UIColor colorWithRed:0.1 green:0.1 blue:0.1 alpha:0.6]
#define kCustomColorBlue  [UIColor colorWithRed:0.47f green:0.77f blue:0.9 alpha:1.0f]
#define kCustomColorGray [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1]
#define kSolidColorUp  [UIColor colorWithRed:232.0/255 green:209.0/255.0 blue:166.0/255.0 alpha:1]
#define kSolidColorDown  [UIColor colorWithRed:240.0/255 green:225.0/255.0 blue:195.0/255.0 alpha:1]
#define kCustomDarkRed [UIColor colorWithRed:212.0/255 green:61.0/255.0 blue:51.0/255.0 alpha:1]

#define kSeperatorColor [UIColor colorWithWhite:0.9 alpha:0.6]
#define kSeperatorColorClear [UIColor clearColor]
#define kRecentCellsUnderline [UIColor colorWithRed:0.8f green:0.8f blue:0.82f alpha:1.0f];
#define kImageCachePath [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

//#define kSolidColorUp [UIColor colorWithWhite:0.37 alpha:0.8]
//#define kSolidColorDown [UIColor colorWithWhite:0.17 alpha:1]
enum {
    ImageDefault = 0,
    ImageStretchable,
    
};
#define CGSizeScale(size, scale) CGSizeMake(size.width * scale, size.height * scale)
#define CGRectScale(rect, scale) CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale)
#define NSColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface CUtil : NSObject
+ (CGSize)getTextSize:(NSString *)string textFont:(UIFont *)font;
+ (CGRect) getTextRect:(NSString *)text Font:(UIFont *)font Width:(CGFloat)width;
+ (UIImage *)imageWithName:(NSString *)name type:(NSInteger)type;
+ (UIImage *)imageWithBackground:(UIColor*)backColor size:(CGSize) size;
+ (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)maskImage normalMethod:(BOOL)isNormalMethod;
+ (UIImage *)grayImage:(UIImage *)source;
+ (UIImage *)stretchImage:(UIImage *)image leftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight destSize:(CGSize)size;
+ (UIImage *)buttonImage:(UIImage *)image width:(CGFloat)width;
+ (UIImage *)imageWithBack:(UIImage *)back fore:(UIImage *)fore size:(CGSize)size;
+ (BOOL)is24HourFormat;
+ (UIColor *)colorWithARGBValue:(NSUInteger)value;
+ (UIImage *)imageText:(NSString *)text withBackground:(NSString *)backColor size:(CGSize) size rate:(CGFloat)rate;
+ (UIImage*)imageText:(NSString *)text withSubText:(NSString *)subtext size:(CGSize) size rate:(CGFloat)rate;
+ (NSString *)md5:(NSString *)str;
+ (NSString *)hashForEmail:(NSString *)emailInput;
+ (NSString *)pathForCachedImage:(NSString *)email;


+ (BOOL)imageInfileCache:(NSString *)email;

+ (BOOL)BISkinIsRetina;
@end
void bd_show_view_hierarchy(UIView *view, NSInteger level);
#define BD_SHOW_VIEW(x) bd_show_view_hierarchy((x), 0)
