//
//  BI_GridView.h
//  BaiduIMLib
//
//  Created by backup on 11-9-30.
//  Copyright 2011年 backup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BI_GridLayout.h"

@class BI_GridView;
@class BI_GridViewCell;

@protocol BI_GridViewDelegate <NSObject>
- (NSUInteger)numOfRowInGridView:(BI_GridView *)gridView;
- (NSUInteger)numOfColInGridView:(BI_GridView *)gridView;
- (NSUInteger)numOfCellInGridView:(BI_GridView *)gridView;
- (CGSize)gridView:(BI_GridView *)gridView sizeOfCellAtIndex:(NSUInteger)index;
- (BI_GridViewCell *)gridView:(BI_GridView *)gridView cellForFrame:(BI_GridFrame *)frame;
@optional
- (void)gridView:(BI_GridView *)gridView willLoadItemAtIndex:(NSUInteger)index;
- (void)gridView:(BI_GridView *)gridView didLoadItemAtIndex:(NSUInteger)index;
- (BOOL)gridView:(BI_GridView *)gridView willSelectCellAtIndex:(NSUInteger)index;
- (void)gridView:(BI_GridView *)gridView didSelectCellAtIndex:(NSUInteger)index;
- (BOOL)gridView:(BI_GridView *)gridView willDeselectCellAtIndex:(NSUInteger)index;
- (void)gridView:(BI_GridView *)gridView didDeselectCellAtIndex:(NSUInteger)index;
- (BOOL)gridView:(BI_GridView *)gridView willLongPressCellAtIndex:(NSUInteger)index;
- (void)gridView:(BI_GridView *)gridView didLongPressCellAtIndex:(NSUInteger)index;
- (void)gridView:(BI_GridView *)gridView willBeginDecelerating:(UIScrollView *)scrollView;
- (void)gridView:(BI_GridView *)gridView didEndDecelerating:(UIScrollView *)scrollView;
@end

@interface BI_GridView : UIScrollView <BI_GridLayoutDelegate, UIScrollViewDelegate> {
    struct
	{
        //disableFlashScrollIndicator:floatView无须闪ScrollBar，优化掉
        unsigned touchBegan:1;
        unsigned disableFlashScrollIndicator:1;
        unsigned longPressHandled:1;
        unsigned lockRefreshGridView:1;
        unsigned delegateWillLoadItemAtIndex:1;
        unsigned delegateDidLoadItemAtIndex:1;
		unsigned delegateWillSelectCell:1;
		unsigned delegateDidSelectCell:1;
		unsigned delegateWillDeselectCell:1;
		unsigned delegateDidDeselectCell:1;
        unsigned delegatewillLongPressCell:1;
        unsigned delegateDidLongPressCell:1;
		unsigned __RESERVERED__:20;
	}flags_;
    
    CGPoint                   markPoint_;
    CGSize   frameSize_;
    NSRange                   displayRange_;
    NSInteger                 selectedIndex_;
    NSInteger                 touchedIndex_;
    NSTimer		             *touchStartTimer_;
	NSMutableDictionary      *cellQueues_;
    BI_GridLayout            *layout_;
	id<BI_GridViewDelegate>   gridDelegate_;
}

@property (nonatomic, readonly) NSInteger selectedIndex;
@property (nonatomic, assign)   id<BI_GridViewDelegate> gridDelegate;

- (void)reset;
- (void)reloadData;
- (void)reuseCells;
- (void)hideCachedCells; //只从GridView上Hide缓存中的Cell，不清缓存
- (void)removeCachedCells;
- (BOOL)layoutGridIfNeeded;
- (void)selectCellAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)deselectCellAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (BI_GridViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (BI_GridViewCell *)cellAtIndex:(NSUInteger)index;

- (id)initWithGridLayout:(BI_GridLayout *)layout;

//打补丁用，尚不完善，用于第一次进页面时，滚动到指定位置（目前只有FilterList用到）
- (void)scrollToCellAtIndex:(NSInteger)index;
- (BI_GridFrame *)currentFrame;
@end
