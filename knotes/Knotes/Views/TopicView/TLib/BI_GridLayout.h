//
//  BI_GridLayout.h
//  BaiduIMLib
//
//  Created by backup on 11-9-30.
//  Copyright 2011年 backup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BI_GridFrame.h"

@protocol BI_GridLayoutDelegate <NSObject>      //注意：请保证Grid的高度是PageSize/numOfRow的倍数
- (CGSize)sizeOfPage;                           //页的大小，LayoutManager是基于页的，每次计算的最小单位为一页
- (CGSize)sizeOfGridAtIndex:(NSUInteger)index;  //实际每个Grid的大小（与PageSize/numOfCol和PageSize/numOfRow的结果可能不一致）
- (NSUInteger)numOfGrid;                        //每次调用layoutNext（）都需要调用该方法，因为外面的Grid总数的初始值是不准确的（比如Candidate的总数）
- (NSUInteger)numOfRowInPage;                   //不考虑合并的情况下，每页可放的行
- (NSUInteger)numOfColInPage;                   //不考虑合并的情况下，每页可放的列
- (void)willLoadItemAtIndex:(NSUInteger)index;
- (void)didLoadItemAtIndex:(NSUInteger)index;
@end


//BI_GridLayout:默认布局器，派生类可以重载layoutNext，frameAtPoint实现不同的布局。
//默认布局实现1行或者1列的排版，1个frame对应一个grid
@interface BI_GridLayout : NSObject {
    BOOL                      finished_;
    NSUInteger                numOfRow_;
    NSUInteger                numOfCol_;
    NSUInteger                numOfCell_;
    CGSize                    sizeOfCell_;
    CGSize                    sizeOfPage_;
    CGSize                    sizeOfContent_;   //所有frame所占的区域，每次调用layoutNext（）请重置该值(需要估计)   
    NSMutableArray*           frames_;
    id<BI_GridLayoutDelegate> delegate_;
    
    //用作缓存，由每个GridLayout自己管理
    NSMutableArray*           gridPool_;
    NSMutableArray*           framePool_;
    NSUInteger                gridIndex_;
    NSUInteger                frameIndex_;
    //注意：以下字段在CandidateToolBar中引入，以前的Layout不支持，如需支持，请自行添加
    CGFloat                   verticalGap_;    //Cell竖直方向间隔，目前只有CandidateToolBar使用
    CGFloat                   horizontalGap_;  //Cell水平方向间隔，目前只有CandidateToolBar使用
    UIEdgeInsets              edgeInsets_;     //GridView与边界的距离，只适用于整数页的情况，目前只有CandidateToolBar使用
}

@property (nonatomic, readonly) BOOL       finished;
@property (nonatomic, readonly) CGSize     contentSize;
@property (nonatomic, readonly) NSUInteger numOfCell;
@property (nonatomic, readonly) NSUInteger numOfFrame;
@property (nonatomic, assign) CGFloat      verticalGap;
@property (nonatomic, assign) CGFloat      horizontalGap;
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@property (nonatomic, assign) id<BI_GridLayoutDelegate> delegate;

- (void)layoutBegin;
- (BOOL)layoutNext;
- (void)layoutEnd;       //暂时没用
- (BOOL)layoutFrameWithPoint:(CGPoint)point;

- (BI_GridFrame *)lastFrame;
- (BI_GridInfo  *)gridAtPoint:(CGPoint)point;
- (BI_GridFrame *)frameAtPoint:(CGPoint)point;
- (BI_GridFrame *)frameAtIndex:(NSUInteger)index;
- (BI_GridFrame *)frameContainsIndex:(NSUInteger)index;
- (NSUInteger)indexOfFrameAtPoint:(CGPoint)point;  //无法找到，返回NSNotFound

@end
