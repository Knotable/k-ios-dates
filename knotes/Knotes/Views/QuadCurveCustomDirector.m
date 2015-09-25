//
//  QuadCurveCustomDirector.m
//  Knotable
//
//  Created by wuli on 14-7-15.
//
//

#import "QuadCurveCustomDirector.h"


@implementation QuadCurveCustomDirector

@synthesize angle = angle_;
@synthesize padding = padding_;

#pragma mark - Initialization

- (id)initWithAngle:(CGFloat)angle
         andPadding:(CGFloat)padding {
    
    self = [super init];
    if (self) {
        
        self.angle = angle;
        self.padding = padding;
        self.maxLineItem = 6;
        
    }
    return self;
}


- (id)init {
    return [self initWithAngle:0 andPadding:10];
}

#pragma mark - QuadCurveDirector Adherence

- (void)positionMenuItem:(QuadCurveMenuItem *)item
                 atIndex:(int)index
                 ofCount:(int)count
                fromMenu:(QuadCurveMenuItem *)mainMenuItem {
    
    CGPoint startPoint = mainMenuItem.center;
    item.startPoint = startPoint;
    CGSize itemSize = item.frame.size;
    
    startPoint.y+=(itemSize.width + self.padding/2)*(index/self.maxLineItem);
    index = index%self.maxLineItem;
    
    float xCoefficient = cosf(self.angle);
    float yCoefficient = sinf(self.angle);
    
    float endRadiusX = (itemSize.width + self.padding) * (index + 1);
    float endRadiusY = (itemSize.width + self.padding) * (index + 1);
    
    
    CGPoint endPoint = CGPointMake(startPoint.x + endRadiusX * xCoefficient, startPoint.y - endRadiusY * yCoefficient);
    
    item.endPoint = endPoint;
    
    CGPoint nearPoint = CGPointMake(startPoint.x + (endRadiusX - 10) * xCoefficient, startPoint.y - (endRadiusY - 10) * yCoefficient);
    
    item.nearPoint = nearPoint;
    
    CGPoint farPoint = CGPointMake(startPoint.x + (endRadiusX + 10) * xCoefficient, startPoint.y - (endRadiusY + 10) * yCoefficient);
    
    item.farPoint = farPoint;
    
}

@end
