//
//  QuadCurveCustomImageMenuItem.h
//  Knotable
//
//  Created by wuli on 14-7-14.
//
//

#import <Foundation/Foundation.h>
#import "QuadCurveMenu.h"

@interface QuadCurveCustomImageMenuItem : NSObject<QuadCurveMenuItemFactory>
@property (nonatomic, strong) id userData;
@property (nonatomic, strong) QuadCurveMenuItem *item;
//@property (nonatomic, strong) QuadCurveMenuItem *item;
//- (id)initWithImage:(UIImage *)image
//     highlightImage:(UIImage *)highlightImage;
@end
