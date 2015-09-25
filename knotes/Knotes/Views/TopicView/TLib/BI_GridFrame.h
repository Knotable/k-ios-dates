//
//  BI_GridFrame.h
//  BaiduIMLib
//
//  Created by backup on 11-9-30.
//  Copyright 2011年 backup. All rights reserved.
//

#import <UIKit/UIKit.h>

#pragma mark -
#pragma mark BI_GridInfo

//GridInfo : 请不要生成GridInfo对象，该对象提供Grid信息，由GridFrame管理

@interface BI_GridInfo : NSObject {
    NSUInteger row_;
    NSUInteger col_;
    NSUInteger index_;
    CGRect     frame_;
    CGFloat    width_;
    CGFloat   textWidth_;
    BOOL       empty_;
    UIImage   *icon_;
    id         object_;
}

@property (nonatomic, readonly) NSUInteger row;
@property (nonatomic, readonly) NSUInteger col;
@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, readonly) CGRect     frame;
@property (nonatomic, assign)   CGFloat    width;
@property (nonatomic,assign) CGFloat textWidth;
@property (nonatomic, assign)   BOOL       empty;
@property (nonatomic, retain)   UIImage   *icon;
@property (nonatomic, retain)   id         object;
@end


#pragma mark -
#pragma mark BI_GridFrame

//BI_GridFrame : GridFrame包含一个或多个GridInfo对象，并且GridInfo是水平分布的,高度一致

@interface BI_GridFrame : NSObject {
    id               object_;
    CGRect           frame_;
    NSUInteger       endIndex_;
    NSUInteger       pageIndex_;
    NSUInteger       startIndex_;
    NSInteger        selIndex_;
    NSMutableArray  *grids_;
}

@property (nonatomic, retain)   id         object;
@property (nonatomic, readonly) CGRect     frame;
@property (nonatomic, readonly) NSUInteger endIndex;
@property (nonatomic, readonly) NSUInteger pageIndex;
@property (nonatomic, readonly) NSUInteger startIndex;
@property (nonatomic, readonly) NSInteger  selIndex;
@property (nonatomic, readonly) NSUInteger gridCount;

- (BI_GridInfo *)gridAtPoint:(CGPoint)point;
- (BI_GridInfo *)gridAtIndex:(NSUInteger)index;
- (BI_GridInfo *)gridContainsIndex:(NSUInteger)index;

@end


