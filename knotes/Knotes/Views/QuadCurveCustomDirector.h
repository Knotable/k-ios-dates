//
//  QuadCurveCustomDirector.h
//  Knotable
//
//  Created by wuli on 14-7-15.
//
//

#import "QuadCurveMotionDirector.h"

@interface QuadCurveCustomDirector : NSObject <QuadCurveMotionDirector>

- (id)initWithAngle:(CGFloat)angle andPadding:(CGFloat)padding;

@property (nonatomic,assign) CGFloat angle;
@property (nonatomic,assign) CGFloat padding;
@property (nonatomic,assign) NSInteger maxLineItem;

@end