//
//  UIImage+Knotable.m
//  Knotable
//
//  Created by Martin Ceperley on 12/10/13.
//
//

#import "UIImage+Knotes.h"
#import "CUtil.h"
@implementation UIImage (Knotable)

- (UIImage *)fixOrientation {
    return [self fixOrientation:99];
}
- (UIImage *)fixOrientation:(UIImageOrientation)orientation
{
    if ((int)orientation == 99) {
        orientation = self.imageOrientation;
    }

//    NSLog(@"fixOrientation: %d, %@", (int)orientation, NSStringFromCGSize(self.size));
    
    // No-op if the orientation is already correct
    if (orientation == UIImageOrientationUp) return self;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (orientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
- (UIImage *)image1:(UIImage *)image1 image2:(UIImage *)image2 image3:(UIImage *)image3 withSize:(CGFloat)with
{
    NSInteger scare =  ([CUtil BISkinIsRetina] ? 2 : 1);
    CGContextRef mainViewContentContext;
    CGColorSpaceRef colorSpace;
    NSInteger width = with*scare;
    NSInteger height = with*scare;
    colorSpace = CGColorSpaceCreateDeviceRGB();
    mainViewContentContext = CGBitmapContextCreate (NULL, width, height , 8, width * 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    
    if (mainViewContentContext==NULL)
        return NULL;
    if (image1) {
        CGContextDrawImage(mainViewContentContext, CGRectMake(4, 15, width-6, height-6), image1.CGImage);
    }
    if (image2) {
        CGContextDrawImage(mainViewContentContext, CGRectMake(18, -3, width-6, height-6), image2.CGImage);
    }
    if (image3) {
        CGContextDrawImage(mainViewContentContext, CGRectMake(-6, -8, width-6, height-6), image3.CGImage);
    }
    
    CGImageRef mainViewContentBitmapContext = CGBitmapContextCreateImage(mainViewContentContext);
    CGContextRelease(mainViewContentContext);
    UIImage *theImage = [UIImage imageWithCGImage:mainViewContentBitmapContext scale:scare orientation:UIImageOrientationUp];
    CGImageRelease(mainViewContentBitmapContext);
    return theImage;
    
}

- (UIImage *)imageForbiddenScaledToFitSize:(CGSize)fitSize withColor:(UIColor*)color
{
    float imageScaleFactor = 1.0;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	if ([self respondsToSelector:@selector(scale)]) {
		imageScaleFactor = [self scale];
	}
#endif
	
	float sourceWidth = [self size].width * imageScaleFactor;
	float sourceHeight = [self size].height * imageScaleFactor;
	float targetWidth = fitSize.width;
	float targetHeight = fitSize.height;
	BOOL cropping = NO;
	
	// Calculate aspect ratios
	float sourceRatio = sourceWidth / sourceHeight;
	float targetRatio = targetWidth / targetHeight;
	
	// Determine what side of the source image to use for proportional scaling
	BOOL scaleWidth = (sourceRatio <= targetRatio);
	// Deal with the case of just scaling proportionally to fit, without cropping
	scaleWidth = (cropping) ? scaleWidth : !scaleWidth;
	
	// Proportionally scale source image
	float scalingFactor, scaledWidth, scaledHeight;
	if (scaleWidth) {
		scalingFactor = 1.0 / sourceRatio;
		scaledWidth = targetWidth;
		scaledHeight = round(targetWidth * scalingFactor);
	} else {
		scalingFactor = sourceRatio;
		scaledWidth = round(targetHeight * scalingFactor);
		scaledHeight = targetHeight;
	}
	
	// Calculate compositing rectangles
	CGRect sourceRect, destRect;
    sourceRect = CGRectMake(0, 0, sourceWidth, sourceHeight);
    destRect = CGRectMake(0, 0, scaledWidth, scaledHeight);
	
	// Create appropriately modified image.
	UIImage *image = nil;
	
    

    
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
	CGImageRef sourceImg = nil;
	if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
		UIGraphicsBeginImageContextWithOptions(destRect.size, NO, 0.f); // 0.f for scale means "scale for device's main screen".
		sourceImg = CGImageCreateWithImageInRect([self CGImage], sourceRect); // cropping happens here.
		image = [UIImage imageWithCGImage:sourceImg scale:0.0 orientation:self.imageOrientation]; // create cropped UIImage.
		
	} else {
		UIGraphicsBeginImageContext(destRect.size);
		sourceImg = CGImageCreateWithImageInRect([self CGImage], sourceRect); // cropping happens here.
		image = [UIImage imageWithCGImage:sourceImg]; // create cropped UIImage.
	}
	
	CGImageRelease(sourceImg);
	[image drawInRect:destRect]; // the actual scaling happens here, and orientation is taken care of automatically.
    
    // Pass 2: Draw the line above of original image
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2.0);
    CGContextMoveToPoint(context, destRect.size.width, 0);
    CGContextAddLineToPoint(context, 0, destRect.size.height);
    if (color) {
        CGContextSetStrokeColorWithColor(context, [color CGColor]);
    } else {
        CGContextSetStrokeColorWithColor(context, [[UIColor colorWithWhite:0.82 alpha:1] CGColor]);
    }
    CGContextStrokePath(context);
    
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
#endif
	
	if (!image) {
		// Try older method.
		CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
		CGContextRef context = CGBitmapContextCreate(NULL, scaledWidth, scaledHeight, 8, (scaledWidth * 4),
													 colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
		CGImageRef sourceImg = CGImageCreateWithImageInRect([self CGImage], sourceRect);
		CGContextDrawImage(context, destRect, sourceImg);
		CGImageRelease(sourceImg);
		CGImageRef finalImage = CGBitmapContextCreateImage(context);
		CGContextRelease(context);
		CGColorSpaceRelease(colorSpace);
		image = [UIImage imageWithCGImage:finalImage];
		CGImageRelease(finalImage);
	}
	
	return image;
}
@end
