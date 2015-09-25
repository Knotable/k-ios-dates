//
//  CUtil.m
//  Market
//
//  Created by backup on 13-8-1.
//  Copyright (c) 2013年 backup. All rights reserved.
//

#import "CUtil.h"
#import "DesignManager.h"

@implementation CUtil
+ (CGSize)getTextSize:(NSString *)string textFont:(UIFont *)font
{
    CGSize textSize = [string sizeWithAttributes:@{NSFontAttributeName:font}];
    return textSize;
}

+ (CGRect) getTextRect:(NSString *)text Font:(UIFont *)font Width:(CGFloat)width
{
    CGRect rect = CGRectZero;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
    CGFloat insets = 8.0;

    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:font,NSParagraphStyleAttributeName: [paragraphStyle copy]};
    NSInteger options = NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin;

    rect = [text boundingRectWithSize:CGSizeMake(width-insets, MAXFLOAT) options:options attributes:attributes context:NULL];


    CGFloat adj = ceilf(font.ascender - font.capHeight);
    rect.size.height += adj + insets;
#else
    CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, MAXFLOAT) lineBreakMode:NSLineBreakByWordWrapping];
    rect.size = size;
#endif
    return rect;
}

+ (UIImage *)imageWithName:(NSString *)name type:(NSInteger)type
{
    UIImage *image = nil;
    if (name != nil&&[name length]>0) {
        image = [UIImage imageNamed:name];
    }
    if (type == ImageStretchable&&image!=nil) {
        image = [image stretchableImageWithLeftCapWidth:image.size.width/2 topCapHeight:image.size.height/2];
    }
    return image;
}

+ (UIImage*)imageWithBackground:(UIColor*)backColor size:(CGSize) size
{
    
    NSInteger scale = [self BISkinIsRetina] ? 2 : 1;
    if (scale > 1)
    {
        size = CGSizeScale(size, scale);
    }
    
    backColor = backColor==nil?[UIColor clearColor]:backColor;

    NSInteger width  = size.width;
	NSInteger height = size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, (4 * width), colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
	CGContextSetFillColorWithColor(context, backColor.CGColor);
	CGContextFillRect(context, CGRectMake(0,0,size.width,size.height));
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage   *imageRet = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
	CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return  imageRet;
}

+ (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)maskImage normalMethod:(BOOL)isNormalMethod
{
    CGImageRef imageRef = image.CGImage;
    CGImageRef maskRef = maskImage.CGImage;
    
    //tmp debug for new cloud iocn
    int bpx = (int)CGImageGetBitsPerPixel(maskRef);
    
	if (!isNormalMethod)
	{
		if (bpx > 24) {  //has alpha channle
			maskRef =  [self grayImage:maskImage].CGImage;
		}
	}
    
    CGContextRef mainViewContentContext;
    CGColorSpaceRef colorSpace;
    NSInteger width = CGImageGetWidth(imageRef);
    NSInteger height = CGImageGetHeight(imageRef);
    colorSpace = CGColorSpaceCreateDeviceRGB();
    mainViewContentContext = CGBitmapContextCreate (NULL, width, height , 8, width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    if (mainViewContentContext==NULL)
        return NULL;
    
    CGContextClipToMask(mainViewContentContext, CGRectMake(0, 0, width, height), maskRef);
    
    CGContextDrawImage(mainViewContentContext, CGRectMake(0, 0, width, height), imageRef);
    
    CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    UIImage *theImage = [UIImage imageWithCGImage:mainViewContentBitmapContext scale: ([self BISkinIsRetina] ? 2 : 1) orientation:UIImageOrientationUp];
    CGImageRelease(mainViewContentBitmapContext);
    return theImage;
}

+ (UIImage *)grayImage:(UIImage *)source
{
    
    NSInteger scale = [self BISkinIsRetina] ? 2 : 1;
    CGSize size  = source.size;
    
    if (scale > 1)
    {
        size = CGSizeScale(size, scale);
    }
    
    int width = size.width;
    int height = size.height;
    
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  8,      // bits per component
                                                  0,
                                                  colorSpace,
                                                  (CGBitmapInfo)kCGImageAlphaNone);
    CGColorSpaceRelease(colorSpace);
    if (context == NULL)
    {
        return nil;
    }
    CGContextDrawImage(context,
                       CGRectMake(0, 0, width, height), source.CGImage);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage *grayImage = [UIImage imageWithCGImage: imageRef scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    return grayImage;
}

+ (UIImage *)stretchImage:(UIImage *)image leftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight destSize:(CGSize)size
{
	NSInteger scale = [self BISkinIsRetina] ? 2 : 1;
	CGSize imageSize = [image size];
    CGFloat offsetX   = leftCapWidth;
    CGFloat offsetY   = topCapHeight;
    CGRect  outerRect = CGRectMake(0, 0, imageSize.width, imageSize.height);
    CGRect  innerRect = CGRectMake(offsetX, offsetY, imageSize.width-offsetX*2, imageSize.height-offsetY*2);
    
    if (scale > 1)
    {
        outerRect = CGRectScale(outerRect, scale);
        innerRect = CGRectScale(innerRect, scale);
        size      = CGSizeScale(size, scale);
    }
    
    NSInteger width  = size.width;
    NSInteger height = size.height;
    
	if (imageSize.width<leftCapWidth*2||imageSize.height<topCapHeight*2||size.height==0)
	{
		return nil;
	}
    else if (imageSize.width == leftCapWidth*2){
        CGRect  srcRect[3];
        CGFloat srcH1 = innerRect.origin.y; CGFloat srcH2 = innerRect.size.height; CGFloat srcH3 = outerRect.size.height - srcH1 - srcH2;
        CGFloat srcY1 = 0; CGFloat srcY2 = srcH1; CGFloat srcY3 = srcH1 + srcH2;
        CGFloat srcX  = 0; CGFloat srcW = outerRect.size.width;
        srcRect[2] = CGRectMake(srcX, srcY1, srcW, srcH1);
        srcRect[1] = CGRectMake(srcX, srcY2, srcW, srcH2);
        srcRect[0] = CGRectMake(srcX, srcY3, srcW, srcH3);
        
        CGRect  dstRect[3];
        CGFloat dstH1 = srcH3; CGFloat dstH2 = height - srcH1 - srcH3; CGFloat dstH3 = srcH1;
        CGFloat dstY1 = 0; CGFloat dstY2 = dstH1; CGFloat dstY3 = dstH1 + dstH2;
        dstRect[0] = CGRectMake(srcX, dstY1, srcW, dstH1);
        dstRect[1] = CGRectMake(srcX, dstY2, srcW, dstH2);
        dstRect[2] = CGRectMake(srcX, dstY3, srcW, dstH3);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate (NULL, width, height, 8, width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
        for (int i = 0; i < 3; i++)
        {
            CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], srcRect[i]);
            CGContextDrawImage(context, dstRect[i], imageRef);
            CGImageRelease(imageRef);
        }
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        UIImage   *imageRet = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
        CGImageRelease(imageRef);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        return imageRet;
    }
    else if (imageSize.height == topCapHeight*2){
        CGRect  srcRect[3];
        CGFloat srcW1 = innerRect.origin.x; CGFloat srcW2 = innerRect.size.width; CGFloat srcW3 = outerRect.size.width  - srcW1 - srcW2;
        CGFloat srcX1 = 0; CGFloat srcX2 = srcW1; CGFloat srcX3 = srcW1 + srcW2;
        CGFloat srcY  = 0; CGFloat srcH  = outerRect.size.height;
        srcRect[0] = CGRectMake(srcX1, srcY, srcW1, srcH);
        srcRect[1] = CGRectMake(srcX2, srcY, srcW2, srcH);
        srcRect[2] = CGRectMake(srcX3, srcY, srcW3, srcH);
        
        CGRect  dstRect[3];
        CGFloat dstW1 = srcW1; CGFloat dstW2 = width  - srcW1 - srcW3; CGFloat dstW3 = srcW3;
        CGFloat dstX1 = 0; CGFloat dstX2 = dstW1; CGFloat dstX3 = dstW1 + dstW2;
        dstRect[0] = CGRectMake(dstX1, srcY, dstW1, srcH);
        dstRect[1] = CGRectMake(dstX2, srcY, dstW2, srcH);
        dstRect[2] = CGRectMake(dstX3, srcY, dstW3, srcH);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate (NULL, width, height, 8, width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
        for (int i = 0; i < 3; i++)
        {
            CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], srcRect[i]);
            CGContextDrawImage(context, dstRect[i], imageRef);
            CGImageRelease(imageRef);
            
        }
        
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        UIImage   *imageRet = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
        CGImageRelease(imageRef);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        return imageRet;
    }
    else{
        CGRect  srcRect[9];
        CGFloat srcW1 = innerRect.origin.x; CGFloat srcW2 = innerRect.size.width;  CGFloat srcW3 = outerRect.size.width  - srcW1 - srcW2;
        CGFloat srcH1 = innerRect.origin.y; CGFloat srcH2 = innerRect.size.height; CGFloat srcH3 = outerRect.size.height - srcH1 - srcH2;
        CGFloat srcX1 = 0; CGFloat srcX2 = srcW1; CGFloat srcX3 = srcW1 + srcW2;
        CGFloat srcY1 = 0; CGFloat srcY2 = srcH1; CGFloat srcY3 = srcH1 + srcH2;
        srcRect[6] = CGRectMake(srcX1, srcY1, srcW1, srcH1);
        srcRect[7] = CGRectMake(srcX2, srcY1, srcW2, srcH1);
        srcRect[8] = CGRectMake(srcX3, srcY1, srcW3, srcH1);
        srcRect[3] = CGRectMake(srcX1, srcY2, srcW1, srcH2);
        srcRect[4] = CGRectMake(srcX2, srcY2, srcW2, srcH2);
        srcRect[5] = CGRectMake(srcX3, srcY2, srcW3, srcH2);
        srcRect[0] = CGRectMake(srcX1, srcY3, srcW1, srcH3);
        srcRect[1] = CGRectMake(srcX2, srcY3, srcW2, srcH3);
        srcRect[2] = CGRectMake(srcX3, srcY3, srcW3, srcH3);
        
        CGRect  dstRect[9];
        CGFloat dstW1 = srcW1; CGFloat dstW2 = width  - srcW1 - srcW3; CGFloat dstW3 = srcW3;
        CGFloat dstH1 = srcH3; CGFloat dstH2 = height - srcH1 - srcH3; CGFloat dstH3 = srcH1;
        CGFloat dstX1 = 0; CGFloat dstX2 = dstW1; CGFloat dstX3 = dstW1 + dstW2;
        CGFloat dstY1 = 0; CGFloat dstY2 = dstH1; CGFloat dstY3 = dstH1 + dstH2;
        dstRect[0] = CGRectMake(dstX1, dstY1, dstW1, dstH1);
        dstRect[1] = CGRectMake(dstX2, dstY1, dstW2, dstH1);
        dstRect[2] = CGRectMake(dstX3, dstY1, dstW3, dstH1);
        dstRect[3] = CGRectMake(dstX1, dstY2, dstW1, dstH2);
        dstRect[4] = CGRectMake(dstX2, dstY2, dstW2, dstH2);
        dstRect[5] = CGRectMake(dstX3, dstY2, dstW3, dstH2);
        dstRect[6] = CGRectMake(dstX1, dstY3, dstW1, dstH3);
        dstRect[7] = CGRectMake(dstX2, dstY3, dstW2, dstH3);
        dstRect[8] = CGRectMake(dstX3, dstY3, dstW3, dstH3);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate (NULL, width, height, 8, width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
        for (int i = 0; i < 9; i++)
        {
            if (!CGRectIsEmpty(srcRect[i]))
            {
                CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], srcRect[i]);
                CGContextDrawImage(context, dstRect[i], imageRef);
                CGImageRelease(imageRef);
            }
            
        }
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        UIImage   *imageRet = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
        CGImageRelease(imageRef);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        return imageRet;
    }
}

+ (UIImage *)imageWithBack:(UIImage *)back fore:(UIImage *)fore size:(CGSize)size
{
	if (CGSizeEqualToSize(size, CGSizeZero))
	{
		return nil;
	}
	CGFloat originX = roundf((size.width - back.size.width) / 2);
	CGFloat originY = roundf((size.height - back.size.height) / 2);
	CGFloat width = MIN(size.width,back.size.width);
	CGFloat height= MIN(size.height,back.size.height);
	originX = originX<0?0:originX;
	originY = originY<0?0:originY;
    CGRect rect1 = CGRectMake(originX,originY,width, height);
	originX = roundf((size.width - fore.size.width) / 2);
	originY = roundf((size.height - fore.size.height) / 2);
	width = MIN(size.width,fore.size.width);
	height= MIN(size.height,fore.size.height);
	originX = originX<0?0:originX;
	originY = originY<0?0:originY;
    CGRect rect2 = CGRectMake(originX,originY,width,height);
    if (size.width<=fore.size.width+2)
	{
		rect2 = CGRectInset(rect2, 1, 0);
	}
	if (size.height<fore.size.height)
	{
		rect2 = CGRectInset(rect2, 0, 1);
	}
    NSInteger scale = [self BISkinIsRetina] ? 2 : 1;
    if (scale > 1)
    {
        rect1 = CGRectScale(rect1, scale);
        rect2 = CGRectScale(rect2, scale);
        size  = CGSizeScale(size,  scale);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate (NULL, size.width, size.height, 8, size.width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGContextDrawImage(context, rect1, back.CGImage);
    CGContextDrawImage(context, rect2, fore.CGImage);
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage   *imageRet = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return imageRet;
}


+ (UIImage *)buttonImage:(UIImage *)image width:(CGFloat)width
{
	NSInteger scale = [self BISkinIsRetina] ? 2 : 1;
	CGSize imageSize = [image size];
    width = 2*width;
    NSInteger height = imageSize.height;
    
	if (width<0)
	{
		return nil;
	}
    else
    {
        CGRect  srcRect[3];
        CGFloat srcX1 = 0;
        CGFloat srcW1 = floorf((imageSize.width)/2);
        CGFloat srcX2 = srcW1;
        CGFloat srcX3 = imageSize.width - srcW1 ;
        CGFloat srcY3 = 0;
        CGFloat srcH3 = imageSize.height;
        srcRect[0] = CGRectMake(srcX1, srcY3, srcW1, srcH3);
        srcRect[1] = CGRectMake(srcX2, srcY3, 1, srcH3);
        srcRect[2] = CGRectMake(srcX3, srcY3, srcW1, srcH3);
        
        CGRect  dstRect[3];
        CGFloat dstW1 = srcW1;
        CGFloat dstW2 = width  - srcW1*2;
        CGFloat dstH1 = srcH3;
        CGFloat dstX1 = 0;
        CGFloat dstX2 = srcW1;
        CGFloat dstX3 = dstW1 + dstW2;
        CGFloat dstY1 = 0;
        dstRect[0] = CGRectMake(dstX1, dstY1, dstW1, dstH1);
        dstRect[1] = CGRectMake(dstX2, dstY1, dstW2, dstH1);
        dstRect[2] = CGRectMake(dstX3, dstY1, dstW1, dstH1);
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate (NULL, width, height, 8, width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
        for (int i = 0; i < 3; i++)
        {
            CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], srcRect[i]);
            CGContextDrawImage(context, dstRect[i], imageRef);
            CGImageRelease(imageRef);
        }
        CGImageRef imageRef = CGBitmapContextCreateImage(context);
        UIImage   *imageRet = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
        CGImageRelease(imageRef);
        CGContextRelease(context);
        CGColorSpaceRelease(colorSpace);
        return imageRet;
    }
}

+ (BOOL)is24HourFormat
{
    NSString *formatStringForHours = [NSDateFormatter dateFormatFromTemplate:@"j" options:0 locale:[NSLocale currentLocale]];
    NSRange containsA = [formatStringForHours rangeOfString:@"a"];
    BOOL hasAMPM = containsA.location != NSNotFound;
    return !hasAMPM;
}

+ (NSInteger)integerForARGBString:(NSString *)value
{
    NSInteger ret = (0xFFFFFFFF);
    if (8== [value length])
    {
        unsigned a, r, g, b;
        NSScanner* scannerA = [NSScanner scannerWithString:[value substringWithRange:NSMakeRange(0, 2)]];
        NSScanner* scannerR = [NSScanner scannerWithString:[value substringWithRange:NSMakeRange(2, 2)]];
        NSScanner* scannerG = [NSScanner scannerWithString:[value substringWithRange:NSMakeRange(4, 2)]];
        NSScanner* scannerB = [NSScanner scannerWithString:[value substringWithRange:NSMakeRange(6, 2)]];
        [scannerA scanHexInt:&a];
        [scannerR scanHexInt:&r];
        [scannerG scanHexInt:&g];
        [scannerB scanHexInt:&b];
        ret = (a << 24) + (r << 16) + (g << 8) + b;
    }
    else if (6==[value length])
    {
        unsigned a = 0xFF, r, g, b;
        NSScanner* scannerR = [NSScanner scannerWithString:[value substringWithRange:NSMakeRange(0, 2)]];
        NSScanner* scannerG = [NSScanner scannerWithString:[value substringWithRange:NSMakeRange(2, 2)]];
        NSScanner* scannerB = [NSScanner scannerWithString:[value substringWithRange:NSMakeRange(4, 2)]];
        [scannerR scanHexInt:&r];
        [scannerG scanHexInt:&g];
        [scannerB scanHexInt:&b];
        ret = (a << 24) + (r << 16) + (g << 8) + b;
    }
    return ret;
}

+ (UIColor *)colorWithARGBValue:(NSUInteger)value
{
    NSUInteger a = (value >> 24) & 0xFF;
    NSUInteger r = (value >> 16) & 0xFF;
    NSUInteger g = (value >> 8 ) & 0xFF;
    NSUInteger b = value & 0xFF;
    return [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:a / 255.0f];
}

+ (UIImage*)imageText:(NSString *)text withBackground:(NSString *)backColor size:(CGSize) size rate:(CGFloat)rate
{
    NSString *color = nil;
    if ([backColor isEqualToString:@"bgcolor1"]) {
        color = @"EBE18C";
    } else if ([backColor isEqualToString:@"bgcolor2"]) {
        color = @"DC3F1C";
    } else if ([backColor isEqualToString:@"bgcolor3"]) {
        color = @"448D7A";
    } else if ([backColor isEqualToString:@"bgcolor4"]) {
        color = @"D8A027";
    } else if ([backColor isEqualToString:@"bgcolor5"]) {
        color = @"88A764";
    } else if ([backColor isEqualToString:@"bgcolorGray"]) {
        color = @"C1C1C1";
    } else {
        color = @"88A764";//to unkown color
    }


    UIColor *bgColor = [self colorWithARGBValue:[self integerForARGBString:color]];
    NSInteger scale = [self BISkinIsRetina] ? 2 : 1;
    if (scale > 1)
    {
        size = CGSizeScale(size, scale);
    }
    
    bgColor = bgColor==nil?[UIColor clearColor]:bgColor;
    
    NSInteger width  = size.width;
	NSInteger height = size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, (4 * width), colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    
    //修正坐标系
    CGAffineTransform textTran = CGAffineTransformIdentity;
    textTran = CGAffineTransformMakeTranslation(0.0, height);
    textTran = CGAffineTransformScale(textTran, 1.0, -1.0);
    CGContextConcatCTM(context, textTran);
    

    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
	CGContextFillRect(context, rect);

    CGFloat textHeight = size.height;
    if(rate != 0) {
            textHeight = size.height*rate;
    } else {
        textHeight = size.height*0.6;
    }

    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.font = kCustomBoldFont(textHeight);
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.transform = CGAffineTransformMakeRotation(  -M_PI/4 );

    [label.layer renderInContext:context];
    
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage   *imageRet = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
	CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return  imageRet;
}

+ (UIImage*)imageText:(NSString *)text withSubText:(NSString *)subtext size:(CGSize) size rate:(CGFloat)rate
{
    NSString *color = @"88A764";;

    UIColor *bgColor = [self colorWithARGBValue:[self integerForARGBString:color]];
    NSInteger scale = [self BISkinIsRetina] ? 2 : 1;
    if (scale > 1)
    {
        size = CGSizeScale(size, scale);
    }
    
    bgColor = bgColor==nil?[UIColor clearColor]:bgColor;
    
    NSInteger width  = size.width;
	NSInteger height = size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, (4 * width), colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    
    //修正坐标系
    CGAffineTransform textTran = CGAffineTransformIdentity;
    textTran = CGAffineTransformMakeTranslation(0.0, height);
    textTran = CGAffineTransformScale(textTran, 1.0, -1.0);
    CGContextConcatCTM(context, textTran);
    
    
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextSetFillColorWithColor(context, bgColor.CGColor);
	CGContextFillRect(context, rect);
    
    CGFloat textHeight = size.height;
    if(rate != 0) {
        textHeight = size.height*rate;
    } else {
        textHeight = size.height*0.6;
    }
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.textColor = [UIColor whiteColor];
    label.text = text;
    label.font = kCustomBoldFont(textHeight);
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.transform = CGAffineTransformMakeRotation(  -M_PI/4 );
    
    [label.layer renderInContext:context];
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage   *imageRet = [UIImage imageWithCGImage:imageRef scale:scale orientation:UIImageOrientationUp];
	CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return  imageRet;
}

+ (NSString *) md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *) hashForEmail:(NSString *)emailInput
{

    NSArray *emails = [emailInput componentsSeparatedByString:@","];
    NSString *email;
    if (emails.count == 1) {
        email = emailInput;
    } else if (emails.count > 1) {
        email = emails.firstObject;
    } else {
        return nil;
    }
    return [CUtil md5:email];
}

+ (NSString *)pathForCachedImage:(NSString *)email
{
    return [kImageCachePath stringByAppendingPathComponent:[CUtil hashForEmail:email]];
}

+ (BOOL)imageInfileCache:(NSString *)email
{
    return [[NSFileManager defaultManager] fileExistsAtPath:[CUtil pathForCachedImage:email]];
}

+ (BOOL)BISkinIsRetina
{
    return [UIScreen mainScreen].scale > 1.0 ? 1 : 0;
}

@end

void bd_show_view_hierarchy(UIView *view, NSInteger level)
{
    NSMutableString *indent = [NSMutableString string];
    for (NSInteger i = 0; i < level; i++)
    {
        [indent appendString:@"    "];
    }
    
    NSLog(@"%@%@", indent, [view description]);
    
    for (UIView *item in view.subviews)
    {
        bd_show_view_hierarchy(item, level + 1);
    }
}

