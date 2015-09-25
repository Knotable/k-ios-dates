//
//  Utilities.m
//  Knotable
//
//  Created by Emiliano Barcia on 17/08/14.
//
//

#import "Utilities.h"

@implementation Utilities

+(UIImage *) takeSnapshotFromWholeView
{
    CGRect fullScreen = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(fullScreen.size);
    [[[UIApplication sharedApplication] keyWindow].layer  renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGImageRef imageRef = CGImageCreateWithImageInRect([viewImage CGImage], fullScreen);
    UIImage *img = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return img;
}

+ (UIImage *) imageResize : (UIImage*) img
              andResizeTo : (CGSize) newSize
{
    CGFloat scale = [[UIScreen mainScreen]scale];
    UIGraphicsBeginImageContextWithOptions(newSize, NO, scale);
    [img drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+ (UIImage *) scaleImageProportionally : (UIImage *) image
                                maxSize: (NSInteger) maxSize
{
    if (MAX(image.size.height, image.size.width) <= maxSize) {
        return image;
    }
    else {
        CGFloat targetWidth = 0;
        CGFloat targetHeight = 0;
        if (image.size.height > image.size.width) {
            CGFloat ratio = image.size.height / image.size.width;
            targetHeight = maxSize;
            targetWidth = roundf(maxSize/ ratio);
        }
        else {
            CGFloat ratio = image.size.width / image.size.height;
            targetWidth = maxSize;
            targetHeight = roundf(maxSize/ ratio);
        }
        
        CGSize targetSize = CGSizeMake(targetWidth, targetHeight);
        
        UIImage *sourceImage = image;
        UIImage *newImage = nil;
        
        CGSize imageSize = sourceImage.size;
        CGFloat width = imageSize.width;
        CGFloat height = imageSize.height;
        
        targetWidth = targetSize.width;
        targetHeight = targetSize.height;
        
        CGFloat scaleFactor = 0.0;
        CGFloat scaledWidth = targetWidth;
        CGFloat scaledHeight = targetHeight;
        
        CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
        
        if (!CGSizeEqualToSize(imageSize, targetSize)) {
            
            CGFloat widthFactor = targetWidth / width;
            CGFloat heightFactor = targetHeight / height;
            
            if (widthFactor < heightFactor)
                scaleFactor = widthFactor;
            else
                scaleFactor = heightFactor;
            
            scaledWidth = roundf(width * scaleFactor);
            scaledHeight = roundf(height * scaleFactor);
            
            // center the image
            if (widthFactor < heightFactor) {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
            } else if (widthFactor > heightFactor) {
                thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
            }
        }
        
        UIGraphicsBeginImageContext(targetSize);
        
        CGRect thumbnailRect = CGRectZero;
        thumbnailRect.origin = thumbnailPoint;
        thumbnailRect.size.width = scaledWidth;
        thumbnailRect.size.height = scaledHeight;
        
        [sourceImage drawInRect:thumbnailRect];
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        if (newImage == nil) NSLog(@"could not scale image");
        
        return newImage;
    }
}

+ (UIImage *) scaleImage : (UIImage*) image
            toResolution : (NSInteger) resolution
{
    CGImageRef imgRef = [image CGImage];
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    //if already at the minimum resolution, return the orginal image, otherwise scale
    if (width <= resolution && height <= resolution) {
        return image;
        
    } else {
        CGFloat ratio = width/height;
        
        if (ratio > 1) {
            bounds.size.width = resolution;
            bounds.size.height = bounds.size.width / ratio;
        } else {
            bounds.size.height = resolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    [image drawInRect:CGRectMake(0.0, 0.0, bounds.size.width, bounds.size.height)];
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}
-(NSString *)getTopicURLFrom:(TopicsEntity *)topic
{
    NSString *strTopicURL=[NSString stringWithFormat:@"%@/p/%@%@/%@",[self getKnotableUrl],[topic.topic_id substringWithRange:NSMakeRange(0, 2)],[self getHashUniqueFromUniqueNumber:topic.uniqueNumber],[self encodeStringFromSubject:topic.topic]];
    
    return strTopicURL;
}
-(NSString *)encodeStringFromSubject:(NSString *)strSub
{
    strSub=[strSub stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    strSub=[strSub stringByReplacingOccurrencesOfString:@"*" withString:@"-"];
    if (strSub.length>30)
    {
        strSub=[strSub substringWithRange:NSMakeRange(0, 30)];
    }
    
    return strSub;
}
-(NSString *)getHashUniqueFromUniqueNumber:(NSString *)strUniqueNumber
{
    int uniqueNumber=[strUniqueNumber intValue];
    NSString *ALPHABET=@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSString *ret = @"";
    if (uniqueNumber == 0) {
        return [ALPHABET substringWithRange:NSMakeRange(0, 1)];
    }
    while (uniqueNumber > 0) {
        int k = uniqueNumber % ALPHABET.length;
        ret = [NSString stringWithFormat:@"%@%@",[ALPHABET substringWithRange:NSMakeRange(k,  1)] , ret];
        uniqueNumber = uniqueNumber / ALPHABET.length;
    }
    return ret;
}

+ (NSInteger)hoursBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
    NSUInteger unitFlags = NSCalendarUnitHour;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:firstDate toDate:secondDate options:0];
    return [components hour]+1;
}

+ (NSInteger)minutesBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
    return [firstDate timeIntervalSinceDate:secondDate] / 60;
}

-(NSString *)getKnotableUrl {
    /*
     
     Production version : ios.lb.beta.knotable.com
     
     PreBeta1 version   :  com.knotable.knotealpha2
     PreBeta2 version   :  com.knotable.knotealpha3
     
     PreBeta version    :   com.knotable.knoteprebeta
     
     Staging version    :   com.knotable.knotestaging
     
     Dev version        :   com.knotable.knotedev
     
     */
    
    NSString *packageName=[[NSBundle mainBundle]bundleIdentifier];
    
    if ([@"com.knotable.knotable" isEqualToString:packageName])
    {
        return @"ios.lb.beta.knotable.com";
    }
    else if ([@"com.knotable.knotestaging" isEqualToString:packageName] || [@"com.knotable.knotestaging2" isEqualToString:packageName]) {
        
        return @"http://staging.knotable.com";
    }
    else if ([@"com.knotable.knotedev" isEqualToString:packageName]) {
        
        return @"http://dev.knotable.com";
        
    }else if ([@"com.knotable.knoteprebeta" isEqualToString:packageName]){
        
        return @"http://beta.knotable.com";
    }
    else
    {
        return @"";
    }
}

@end
