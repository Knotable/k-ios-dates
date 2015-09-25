//
//  BI_GridLayout.m
//  BaiduIMLib
//
//  Created by backup on 11-9-30.
//  Copyright 2011年 backup. All rights reserved.
//

#import "BI_GridLayout.h"
#import "BI_GridFramePrivate.h"

@interface BI_GridLayout (PrivateMethod)
- (void)resetPool;
- (BOOL)layoutNextH;
- (BOOL)layoutNextV;
- (void)willLoadItemAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfFrameAtPointH:(CGPoint)point;
- (NSUInteger)indexOfFrameAtPointV:(CGPoint)point;
- (BI_GridInfo *)nextGrid;
- (BI_GridFrame *)nextFrame;
@end

@implementation BI_GridLayout

@synthesize finished      = finished_;
@synthesize delegate      = delegate_;
@synthesize numOfCell     = numOfCell_;
@synthesize verticalGap   = verticalGap_;
@synthesize edgeInsets    = edgeInsets_;
@synthesize horizontalGap = horizontalGap_;
@synthesize contentSize   = sizeOfContent_;

- (id)init
{
    self = [super init];
    if (self) 
    {
        frames_    = [[NSMutableArray alloc] initWithCapacity:64];
        gridPool_  = [[NSMutableArray alloc] initWithCapacity:64];
        framePool_ = [[NSMutableArray alloc] initWithCapacity:64];
    }
    return self;
}

- (void)dealloc
{
    for (BI_GridFrame *item in framePool_)
    {
        item.object = nil;
    }
    
    for (BI_GridInfo *item in gridPool_)
    {
        item.object = nil;
    }
    
    [frames_    release];
    [gridPool_  release];
    [framePool_ release];
    [super dealloc];
}

- (void)layoutBegin
{
    numOfRow_      = [delegate_ numOfRowInPage];
    numOfCol_      = [delegate_ numOfColInPage];
    numOfCell_     = [delegate_ numOfGrid];
    sizeOfPage_    = [delegate_ sizeOfPage];
    sizeOfCell_    = CGSizeZero;
    sizeOfContent_ = CGSizeZero;
     finished_   = (numOfCol_ == 0 || numOfRow_ == 0 || sizeOfPage_.width <= 0 || sizeOfPage_.height <= 0);
    //finished_      = (numOfCol_ == 0 || numOfRow_ == 0 || (sizeOfPage_.width <= 0 && sizeOfPage_.height <= 0));
    if (!finished_)
    {
        sizeOfCell_ = CGSizeMake(sizeOfPage_.width / numOfCol_, sizeOfPage_.height / numOfRow_);
    }
    
    [self    resetPool];
    [frames_ removeAllObjects];
}

- (BOOL)layoutNext
{
    if (numOfCol_ != 1 && numOfRow_ != 1) 
    {
        NSLog(@"Row or Col must == 1  !!");
    }
    
    numOfCell_ = [delegate_ numOfGrid];
    finished_  = [frames_ count] >= numOfCell_;
    if (!finished_)
    {
        BI_GridFrame *info = [frames_ lastObject];
        
        NSInteger start = info ? info.endIndex + 1 : 0;
        [self willLoadItemAtIndex:start];
        
        finished_ = (1 == numOfRow_) ? [self layoutNextH] : [self layoutNextV];
        
        info = [frames_ lastObject];
        [delegate_ didLoadItemAtIndex:info.endIndex];
    }
    
    return finished_;
}

- (void)layoutEnd
{
    
}

- (BOOL)layoutFrameWithPoint:(CGPoint)point;
{
    BOOL doLayout = NO;
    if (NO == finished_)
    {
        BI_GridFrame * item  = [frames_ lastObject];
        NSInteger      start = item ? item.pageIndex : -1;
        NSInteger      end   = MAX(point.x / sizeOfPage_.width, point.y / sizeOfPage_.height);
        while (!finished_ && start < end)
        {
            doLayout = YES;
            [self layoutNext];
            start++;
        }
    }
    return doLayout;
}

- (NSUInteger)numOfFrame
{
    return [frames_ count];
}

- (BI_GridFrame *)lastFrame
{
    return [frames_ lastObject];
}

- (BI_GridInfo  *)gridAtPoint:(CGPoint)point
{
    return [[self frameAtPoint:point] gridAtPoint:point];
}

- (BI_GridFrame *)frameAtPoint:(CGPoint)point
{
    NSUInteger index = [self indexOfFrameAtPoint:point];
    return [self frameAtIndex:index];
}

- (BI_GridFrame *)frameAtIndex:(NSUInteger)index
{
    BI_GridFrame *frame = nil;
    if (index < [frames_ count])
    {
        frame = [frames_ objectAtIndex:index];
    }
    return frame;
}

- (NSUInteger)indexOfFrameAtPoint:(CGPoint)point
{
    return (1 == numOfRow_) ? [self indexOfFrameAtPointH:point] : [self indexOfFrameAtPointV:point];
}

- (BI_GridFrame *)frameContainsIndex:(NSUInteger)index
{
    BI_GridFrame *frame = nil;
    
    NSInteger  start  = 0;
    NSInteger  middle = 0;
    NSInteger  end    = [frames_ count] - 1;
    while (start <= end)
    {
        middle = (start + end) / 2;
        
        BI_GridFrame *grid = [frames_ objectAtIndex:middle];
        
        if (grid.startIndex > index) 
        {
            end = middle - 1;
        }
        else if (grid.endIndex < index)
        {
            start = middle + 1;
        }
        else
        {
            frame = grid;
            break;
        }
    }
    
    return frame;
}

#pragma mark -
#pragma mark Private Method

- (NSUInteger)indexOfFrameAtPointH:(CGPoint)point
{
    NSUInteger index  = NSNotFound;
    NSInteger  start  = 0;
    NSInteger  middle = 0;
    NSInteger  end    = [frames_ count] - 1;
    while (start <= end)
    {
        middle = (start + end) / 2;
        
        BI_GridFrame *grid = [frames_ objectAtIndex:middle];
        
        CGFloat min = CGRectGetMinX(grid.frame);
        CGFloat max = CGRectGetMaxX(grid.frame);
        if (min > point.x) 
        {
            end = middle - 1;
        }
        else if (max < point.x)
        {
            start = middle + 1;
        }
        else
        {
            index = middle;
            break;
        }
    }
    return index;
}

- (NSUInteger)indexOfFrameAtPointV:(CGPoint)point
{
    NSUInteger index  = NSNotFound;
    NSInteger  start  = 0;
    NSInteger  middle = 0;
    NSInteger  end    = [frames_ count] - 1;
    while (start <= end)
    {
        middle = (start + end) / 2;
        
        BI_GridFrame *grid = [frames_ objectAtIndex:middle];
        
        CGFloat min = CGRectGetMinY(grid.frame);
        CGFloat max = CGRectGetMaxY(grid.frame);
        if (min > point.y) 
        {
            end = middle - 1;
        }
        else if (max < point.y)
        {
            start = middle + 1;
        }
        else
        {
            index = middle;
            break;
        }
    }
    return index;
}

- (BOOL)layoutNextH
{
    BI_GridFrame *item  = [frames_ lastObject];
    
    CGFloat   startX    = item ? item.frame.origin.x + item.frame.size.width : 0;
    CGFloat   startY    = 0;
    CGFloat   endX      = startX + sizeOfPage_.width; 
    NSInteger pageIndex = startX / sizeOfPage_.width;
    NSInteger index     = [frames_ count];
    while (index < numOfCell_)
    {
        CGSize        size  = [delegate_ sizeOfGridAtIndex:index];
        CGRect        frame = CGRectMake(startX, startY, size.width, size.height);
        BI_GridFrame *item  = [self nextFrame];
        BI_GridInfo  *info  = [self nextGrid];
        
        info.row        = 0;
        info.col        = index;
        info.index      = index;
        info.frame      = frame;
        item.frame      = frame;
        item.startIndex = index;
        item.endIndex   = index;
        item.pageIndex  = pageIndex;

        [item    addGrid:info];
        [frames_ addObject:item];
        
        index  += 1;
        startX += size.width;
        if (startX >= endX)
        {
            break;
        }
    }
    
    BI_GridFrame *info  = [frames_ lastObject];
    sizeOfContent_.width  = (info.frame.origin.x + info.frame.size.width) * numOfCell_ / [frames_ count];
    sizeOfContent_.height = sizeOfPage_.height;
    return index >= numOfCell_;
}

- (BOOL)layoutNextV
{
    BI_GridFrame *item  = [frames_ lastObject];
    
    CGFloat   startX    = 0;
    CGFloat   startY    = item ? item.frame.origin.y + item.frame.size.height : 0;
    CGFloat   endY      = startY + sizeOfPage_.height; 
    NSInteger pageIndex = startY / sizeOfPage_.height;
    NSInteger index     = [frames_ count];
    
    while (index < numOfCell_)
    {
        CGSize        size  = [delegate_ sizeOfGridAtIndex:index];
        CGRect        frame = CGRectMake(startX, startY, size.width, size.height);
        BI_GridFrame *item  = [self nextFrame];
        BI_GridInfo  *info  = [self nextGrid];
        
        info.row        = index;
        info.col        = 0;
        info.index      = index;
        info.frame      = frame;
        item.frame      = frame;
        item.startIndex = index;
        item.endIndex   = index;
        item.pageIndex  = pageIndex;
        
        [item    addGrid:info];
        [frames_ addObject:item];
        
        index  += 1;
        startY += size.height;
        if (startY >= endY)
        {
            break;
        }
    }

    BI_GridFrame *info  = [frames_ lastObject];
    sizeOfContent_.width  = sizeOfPage_.width;
    sizeOfContent_.height = (info.frame.origin.y + info.frame.size.height) * numOfCell_ / [frames_ count];
    return index >= numOfCell_;
}

- (void)willLoadItemAtIndex:(NSUInteger)index
{
    [delegate_ willLoadItemAtIndex:index];
    numOfCell_ = [delegate_ numOfGrid];
}


#pragma mark -
#pragma mark Grid and Frame Cache

- (void)resetPool
{
    gridIndex_  = 0;
    frameIndex_ = 0;
    
    NSInteger frameCount = [framePool_ count];
    if (frameCount > 32)
    {
        for (NSInteger i = 32; i < frameCount; i++)
        {
            ((BI_GridFrame *)[framePool_ objectAtIndex:i]).object = nil;
        }
        
        [framePool_ removeObjectsInRange:NSMakeRange(32, frameCount - 32)];
    }
    
    NSInteger gridCount = [gridPool_ count];
    if (gridCount > 128)
    {
        for (NSInteger i = 128; i < gridCount; i++)
        {
            ((BI_GridInfo *)[gridPool_ objectAtIndex:i]).object = nil;
        }
        
        [gridPool_ removeObjectsInRange:NSMakeRange(128, gridCount - 128)];
    }
}

- (BI_GridInfo *)nextGrid
{
    BI_GridInfo *info = nil;
    if (gridIndex_ >= [gridPool_ count])
    {
        info = [[BI_GridInfo alloc] init];
        [gridPool_ addObject:info];
        [info release];
    }
    else
    {
        info = [gridPool_ objectAtIndex:gridIndex_];
        [info reset];
    }
    gridIndex_++;
    return info;
}

- (BI_GridFrame *)nextFrame
{
    BI_GridFrame *info = nil;
    if (frameIndex_ >= [framePool_ count])
    {
        info = [[BI_GridFrame alloc] init];
        [framePool_ addObject:info];
        [info release];
    }
    else
    {
        info = [framePool_ objectAtIndex:frameIndex_];
        [info reset];
    }
    frameIndex_++;
    return info;
}

@end
