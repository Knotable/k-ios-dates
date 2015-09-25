//
//  QuadCurveCustomMenuItemFactory.h
//  Knotable
//
//  Created by wuli on 14-7-15.
//
//

#import "QuadCurveMenu.h"

@interface QuadCurveCustomMenuItemFactory : NSObject <QuadCurveMenuItemFactory>

- (id)initWithImage:(UIImage *)image
     highlightImage:(UIImage *)highlightImage;

+ (id)defaultMenuItemFactory;
+ (id)defaultMainMenuItemFactory;

@end
