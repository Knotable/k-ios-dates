//
//  BI_GridView.m
//  BaiduIMLib
//
//  Created by backup on 11-9-30.
//  Copyright 2011年 backup. All rights reserved.
//

#import "BI_ViewConst.h"
#import "BI_GridView.h"
#import "BI_GridViewCell.h"
#import "BI_GridFramePrivate.h"

@interface BI_GridView ()
- (void)refreshGridView;
- (BOOL)layoutGridIfNeeded;
- (void)enqueueReusableCell:(BI_GridViewCell *)cell;
- (void)doSelectCellAtIndex:(NSUInteger)index;
- (void)hideInvisibleFramesInRange:(NSRange)range;
- (void)showVisibleFramesInRange:(NSRange)range;
@end

@implementation BI_GridView

@synthesize selectedIndex = selectedIndex_;
@synthesize gridDelegate  = gridDelegate_;

- (id)initWithGridLayout:(BI_GridLayout *)layout
{
    self = [super initWithFrame:CGRectZero];
    if (self) 
    {
        self.delegate      = self;
        self.scrollsToTop  = YES;
        self.scrollEnabled = YES;
        
        layout_            = [layout retain];
        cellQueues_        = [[NSMutableDictionary alloc] init];
        layout_.delegate   = self;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame 
{
	self = [super initWithFrame:frame];
    if (self) 
    {
        self.delegate      = self;
        self.scrollsToTop  = YES;
        self.scrollEnabled = YES;
        
        layout_            = [[BI_GridLayout alloc] init];
        cellQueues_        = [[NSMutableDictionary alloc] init];
        layout_.delegate   = self;
    }
    return self;
}

- (void)dealloc 
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    
    [touchStartTimer_ invalidate];
    touchStartTimer_ = nil;
    
    [layout_     release];
    [cellQueues_ release];
    [super dealloc];
}

- (void)setFrame:(CGRect)frame
{
    frameSize_ = frame.size;
    [super setFrame:frame];
}

- (void)removeCachedCells
{
    [self reuseCells];
    
    for (NSMutableArray *queue in [cellQueues_ allValues])
    {
        for (BI_GridViewCell *cell in queue)
        {
            [cell removeFromSuperview];
        }
    }
    [cellQueues_ removeAllObjects];
}

- (void)hideCachedCells
{
    [self reuseCells];
    
    for (NSMutableArray *queue in [cellQueues_ allValues])
    {
        for (BI_GridViewCell *cell in queue)
        {
            [cell removeFromSuperview];
        }
    }
}

//注意：调用该方法后，layout就重置了，必须在GridView无效后才能调用
- (void)reuseCells
{
    for (NSInteger i = 0; i < displayRange_.length; i++)
    {
        BI_GridFrame *info = [layout_ frameAtIndex:displayRange_.location + i];
        [self enqueueReusableCell:info.object];
    }
    
    [layout_ layoutBegin];
}

- (void)reset
{
    flags_.lockRefreshGridView = 1;
    
    [self reuseCells];
    
    selectedIndex_   = -1;
    touchedIndex_    = -1;
    displayRange_    = NSMakeRange(NSNotFound, 0);
    self.contentSize = CGSizeZero;
    [self setContentOffset:CGPointZero animated:NO];
    
    flags_.lockRefreshGridView = 0;
}

- (void)reloadData
{    
    [self reset];
    
    if (layout_.numOfCell > 0)
    {
        [self refreshGridView];
    }
}

- (BI_GridViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    BI_GridViewCell *cell = nil;
    
    NSMutableArray *queue = [cellQueues_ objectForKey:identifier];
    if (queue) 
    {
        cell = [[[queue lastObject] retain] autorelease];
        if (cell) 
        {
            [queue removeLastObject];
        }
    }
    return cell;
}

- (BI_GridViewCell *)cellAtIndex:(NSUInteger)index;
{
    return ((BI_GridFrame *)[layout_ frameContainsIndex:index]).object;
}

- (void)selectCellAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (index != selectedIndex_)
    {
        [[self cellAtIndex:index] setSelected:YES animated:animated];
    }
    selectedIndex_ = index;
}

- (void)deferDeselectGridCell:(BI_GridViewCell *)cell
{
    cell.frameInfo.selIndex = -1;
    [cell setSelected:NO];
}

- (void)deselectCellAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    if (index == selectedIndex_)
    {
        BI_GridFrame    *info = [layout_ frameContainsIndex:index];
        BI_GridViewCell *cell = info.object;
        if (selectedIndex_ == touchedIndex_)  
        {
            //如果在点击的过程中，马上取消选中，为了显示高亮，要延迟反选的操作
            [self performSelector:@selector(deferDeselectGridCell:) withObject:cell afterDelay:0.1f];
        }
        else
        {
            info.selIndex = -1;
            [cell setSelected:NO animated:animated];
        }
        touchedIndex_  = -1;
        selectedIndex_ = -1;
    }
}

- (void)setGridDelegate:(id<BI_GridViewDelegate>)newDelegate 
{	
    gridDelegate_                      = newDelegate;
    flags_.delegateWillLoadItemAtIndex = [newDelegate respondsToSelector:@selector(gridView:willLoadItemAtIndex:)];
    flags_.delegateDidLoadItemAtIndex  = [newDelegate respondsToSelector:@selector(gridView:didLoadItemAtIndex:)];
    flags_.delegateWillSelectCell      = [newDelegate respondsToSelector:@selector(gridView:willSelectCellAtIndex:)];
    flags_.delegateWillDeselectCell    = [newDelegate respondsToSelector:@selector(gridView:willDeselectCellAtIndex:)];
    flags_.delegateDidSelectCell       = [newDelegate respondsToSelector:@selector(gridView:didSelectCellAtIndex:)];
    flags_.delegateDidDeselectCell     = [newDelegate respondsToSelector:@selector(gridView:didDeselectCellAtIndex:)];
    flags_.delegatewillLongPressCell   = [newDelegate respondsToSelector:@selector(gridView:willLongPressCellAtIndex:)];
    flags_.delegateDidLongPressCell    = [newDelegate respondsToSelector:@selector(gridView:didLongPressCellAtIndex:)];
}

- (void)enqueueReusableCell:(BI_GridViewCell *)cell 
{
    if (cell)
    {
        cell.hidden = YES;
        [cell reset];

        NSMutableArray *queue = [cellQueues_ objectForKey:cell.reuseIdentifier];
        if (nil == queue) 
        {
            queue = [NSMutableArray array];
            [cellQueues_ setObject:queue forKey:cell.reuseIdentifier];
        }
        [queue addObject:cell]; 
    }
}

- (NSInteger)indexOfStartFrame
{
    return [layout_ indexOfFrameAtPoint:self.contentOffset];
}

- (NSInteger)indexOfEndFrame
{
    CGPoint point  = self.contentOffset;
    CGSize  size   = self.contentSize;
    point.x += frameSize_.width  - 1;
    point.y += frameSize_.height - 1;
    if (point.x >= size.width)
    {
        point.x = size.width - 1;
    }
    if (point.y >= size.height)
    {
        point.y = size.height - 1;
    }
    
    return [layout_ indexOfFrameAtPoint:point];
}

- (void)refreshGridView 
{
    [self layoutGridIfNeeded];
    
    // There's something going on that affects frame size and it's preventing the correct loading of the "Likes" imageview
    NSUInteger index1 = [self indexOfStartFrame];
    NSUInteger index2 = [self indexOfEndFrame];
    NSUInteger index3 = displayRange_.location;
    NSUInteger index4 = displayRange_.location + displayRange_.length - 1;
    if ((index1 >= index3 && index2 <= index4) || NSNotFound == index1 || NSNotFound == index2)
    {
        //已经全部显示，立即返回
        return;
    }
    
    NSRange range1  = displayRange_;
    NSRange range2  = {index1, index2 - index1 + 1};
    displayRange_   = range2;
    if (NSNotFound != index3)
    {
        //判断是否Intersection(以下2个分支都是相交的情况)
        if (index1 > index3 && index1 < index4)
        {
            range1 = NSMakeRange(index3, index1 - index3);
            range2 = NSMakeRange(index4 + 1, index2 - index4);
        }
        else if (index3 > index1 && index3 < index2)
        {
            range1 = NSMakeRange(index2 + 1, index4 - index2);
            range2 = NSMakeRange(index1, index3 - index1);
        }
    }
    [self hideInvisibleFramesInRange:range1];
    [self showVisibleFramesInRange:range2];
}

- (void)hideInvisibleFramesInRange:(NSRange)range
{
    for (NSInteger i = 0; i < range.length; i++)
    {
        BI_GridFrame    *item = [layout_ frameAtIndex:(range.location + i)];
        BI_GridViewCell *cell = (BI_GridViewCell *)item.object;
        [self enqueueReusableCell:cell];
        item.object = nil;
    }
}

- (void)showVisibleFramesInRange:(NSRange)range
{
    for (NSInteger i = 0; i < range.length; i++)
    {
        NSInteger    index = range.location + i;
        BI_GridFrame *item = [layout_ frameAtIndex:index];
        if (!item)
        {
            continue;
        }
        
        BI_GridViewCell *cell = [gridDelegate_ gridView:self cellForFrame:item];
        item.object    = cell;
        cell.frame     = item.frame;
        cell.hidden    = NO;
        cell.frameInfo = item;
        if (nil == cell.superview)
        {
			if (cell.tag== 3)//3==kListItemTypeEdit
			{
				[self insertSubview:cell atIndex:0];
			}
			else
			{
				[self addSubview:cell];
			}
        }
        
        if (cell.selected != (index == selectedIndex_)) 
        {
            cell.selected = (index == selectedIndex_);
        }
    }
}

- (void)doSelectCellAtIndex:(NSUInteger)index
{
    if (index == selectedIndex_ && flags_.delegateDidSelectCell)
    {
        [gridDelegate_ gridView:self didSelectCellAtIndex:selectedIndex_];
        return;
    }
    
    if (flags_.delegateWillSelectCell) 
    {
        if (![gridDelegate_ gridView:self willSelectCellAtIndex:index])
        {
            return;
        }
    }
    
    if (flags_.delegateWillDeselectCell) 
    {
        if (![gridDelegate_ gridView:self willDeselectCellAtIndex:selectedIndex_]) 
        {
            return;
        }
    }
    
    if (selectedIndex_ >= 0) 
    {
        [self deselectCellAtIndex:selectedIndex_ animated:NO];
        if (flags_.delegateDidDeselectCell) 
        {
            [gridDelegate_ gridView:self didDeselectCellAtIndex:selectedIndex_];
        }
    }
    
    [self selectCellAtIndex:index animated:NO];
    
    if (flags_.delegateDidSelectCell)
    {
        [gridDelegate_ gridView:self didSelectCellAtIndex:selectedIndex_];
    }
}

- (BOOL)layoutGridIfNeeded
{
    CGPoint point = self.contentOffset;
    point.x += frameSize_.width  - 1;
    point.y += frameSize_.height - 1;
    
    BOOL doLayout = [layout_ layoutFrameWithPoint:point];
    if (doLayout)
    {
        self.contentSize = layout_.contentSize;
    }
    return doLayout;
}

- (void)scrollToCellAtIndex:(NSInteger)index
{
    BI_GridFrame *info = [layout_ lastFrame];
    while (info && info.endIndex < index) 
    {
        if ([layout_ layoutNext])
        {
            break;
        }
        info = [layout_ lastFrame];
    }
    
    info = [layout_ frameContainsIndex:index];
    if (info && info.pageIndex > 0 && info.endIndex >= index)
    {
        BI_GridInfo *item = [info gridContainsIndex:index];
        
        BOOL horz = self.contentSize.width > frameSize_.width;
        CGFloat x = horz ? (item.frame.origin.x + item.frame.size.width  - frameSize_.width) : 0;
        CGFloat y = horz ? 0 : item.frame.origin.y + item.frame.size.height - frameSize_.height;
        [self setContentOffset:CGPointMake(x, y) animated:YES];
    }
}
- (BI_GridFrame *)currentFrame{
    return [layout_ frameAtPoint:self.contentOffset];
}
#pragma mark -
#pragma mark - BI_GridLayoutDelegate

- (CGSize)sizeOfPage
{
    return frameSize_;
}

- (CGSize)sizeOfGridAtIndex:(NSUInteger)index
{
    return [gridDelegate_ gridView:self sizeOfCellAtIndex:index];
}

- (NSUInteger)numOfRowInPage
{
    return [gridDelegate_ numOfRowInGridView:self];
}

- (NSUInteger)numOfColInPage
{
    return [gridDelegate_ numOfColInGridView:self];
}

- (NSUInteger)numOfGrid
{
    return [gridDelegate_ numOfCellInGridView:self];
}

- (void)willLoadItemAtIndex:(NSUInteger)index
{
    if (flags_.delegateWillLoadItemAtIndex)
    {
        [gridDelegate_ gridView:self willLoadItemAtIndex:index];
    }
}

- (void)didLoadItemAtIndex:(NSUInteger)index
{
    if (flags_.delegateDidLoadItemAtIndex)
    {
        [gridDelegate_ gridView:self didLoadItemAtIndex:index];
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView 
{
    if (0 == flags_.lockRefreshGridView)
    {
        [self refreshGridView];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if ([gridDelegate_ respondsToSelector:@selector(gridView:willBeginDecelerating:)]) {
        [gridDelegate_ gridView:self willBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([gridDelegate_ respondsToSelector:@selector(gridView:didEndDecelerating:)]) {
        [gridDelegate_ gridView:self didEndDecelerating:scrollView];
    }
}
#pragma mark -
#pragma mark Touch Events

- (void)onTouchStartTimer:(NSTimer*)timer 
{
    [touchStartTimer_ invalidate];
    touchStartTimer_ = nil;
    
    if (flags_.delegatewillLongPressCell && touchedIndex_ >= 0) 
    {
        if ([gridDelegate_ gridView:self willLongPressCellAtIndex:touchedIndex_])
        {
            flags_.longPressHandled = 1;
            [gridDelegate_ gridView:self didLongPressCellAtIndex:touchedIndex_];
        }
    }
}

- (void)gridViewTouchesBegan
{
	if (!self.dragging && touchedIndex_ >= 0) 
    {
        BI_GridFrame    *info = [layout_ frameContainsIndex:touchedIndex_];
        BI_GridViewCell *cell = info.object;
        info.selIndex = touchedIndex_;
        [cell twinkle];
    }
}

- (void)gridViewUndoTouchesBegan
{
	if (touchedIndex_ >= 0) 
    {
        if (touchedIndex_ != selectedIndex_)
        {
            BI_GridFrame    *info = [layout_ frameContainsIndex:touchedIndex_];
            BI_GridViewCell *cell = info.object;
            info.selIndex = -1;
            if (cell.highlighted) 
            {
                [cell setHighlighted:NO animated:NO];
            }
        }
        touchedIndex_ = -1;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
//    if([[event allTouches] count] >= 2)
//    {
//        return;
//    }
//    
//    flags_.touchBegan       = 1;
    flags_.longPressHandled = 0;
    
    if (!self.dragging)
    {
        markPoint_ = [[touches anyObject] locationInView:self];
        
        if (-1 == touchedIndex_)
        {
            BI_GridInfo *info  = [layout_ gridAtPoint:markPoint_];
            if (info && NO == info.empty)
            {
                touchedIndex_ = info.index;
                [self gridViewTouchesBegan];
            }
        }
        
        [touchStartTimer_ invalidate];
        touchStartTimer_ = [NSTimer scheduledTimerWithTimeInterval:kDefaultLongPressInterval target:self selector:@selector(onTouchStartTimer:) userInfo:nil repeats:NO];
    }
    
	[super touchesBegan: touches withEvent: event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
//    if([[event allTouches] count] >=2 && 0 == flags_.touchBegan)
//    {
//        return;
//    }
//    
    
    if (!CGPointEqualToPoint(markPoint_, CGPointZero))
    {
        CGPoint point = [[touches anyObject] locationInView:self];
        if (fabsf(point.x - markPoint_.x) > 8 || fabsf(point.y - markPoint_.y) > 8)
        {
            [touchStartTimer_ invalidate];
            touchStartTimer_ = nil;
            
            [self  gridViewUndoTouchesBegan];
            
            markPoint_ = CGPointZero;
        }
    }
    
	[super touchesMoved: touches withEvent: event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
//    if([[event allTouches] count] >=2 && 0 == flags_.touchBegan)
//    {
//        return;
//    }
//    
//    flags_.touchBegan = 0;
    
    [touchStartTimer_ invalidate];
    touchStartTimer_ = nil;
    
    if (0 == flags_.longPressHandled && NO == self.dragging)
    {
        CGPoint      point = [[touches anyObject] locationInView:self];
        BI_GridInfo *info  = [layout_ gridAtPoint:point];
        if (info && NO == info.empty && info.index == touchedIndex_) 
        {
            [self doSelectCellAtIndex:touchedIndex_];
        }
    }
    
	[self  gridViewUndoTouchesBegan];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
//    flags_.touchBegan = 0;
    
    [touchStartTimer_ invalidate];
    touchStartTimer_ = nil;
    
    [self  gridViewUndoTouchesBegan];
    [super touchesCancelled:touches withEvent:event];
}
@end
