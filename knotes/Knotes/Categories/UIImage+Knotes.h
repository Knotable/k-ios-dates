//
//  UIImage+Knotable.h
//  Knotable
//
//  Created by Martin Ceperley on 12/10/13.
//
//

#import <UIKit/UIKit.h>

@interface UIImage (Knotable)

- (UIImage *)fixOrientation;

- (UIImage *)fixOrientation:(UIImageOrientation)orientation;

- (UIImage *)image1:(UIImage *)image1 image2:(UIImage *)image2 image3:(UIImage *)image3 withSize:(CGFloat)with;

- (UIImage *)imageForbiddenScaledToFitSize:(CGSize)fitSize withColor:(UIColor*)color;

@end
