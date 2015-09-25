//
//  BI_GridFramePrivate.h
//  BaiduIMLib
//
//  Created by backup on 11-9-30.
//  Copyright 2011年 backup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BI_GridFrame.h"

#pragma mark -
#pragma mark BI_GridInfo

@interface BI_GridInfo ()
@property (nonatomic, assign) NSUInteger row;
@property (nonatomic, assign) NSUInteger col;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) CGRect     frame;
- (void)reset;
@end

#pragma mark -
#pragma mark BI_GridFrame

@interface BI_GridFrame ()
@property (nonatomic, assign) NSUInteger startIndex;
@property (nonatomic, assign) NSUInteger endIndex;
@property (nonatomic, assign) NSUInteger pageIndex;
@property (nonatomic, assign) NSInteger  selIndex;
@property (nonatomic, assign) CGRect     frame;

- (void)reset;
- (void)addGrid:(BI_GridInfo *)info;
@end
