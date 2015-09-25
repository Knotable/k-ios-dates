//
//  BI_GridLayoutManager.m
//  BaiduIMLib
//
//  Created by backup on 11-10-10.
//  Copyright 2011年 backup. All rights reserved.
//

#import "BI_GridLayoutManager.h"
#import "BI_GridFramePrivate.h"

@interface BI_GridLayout ()
- (BOOL)layoutNextH;
- (BOOL)layoutNextV;
- (BI_GridInfo *)nextGrid;
- (BI_GridFrame *)nextFrame;
- (void)willLoadItemAtIndex:(NSUInteger)index;
@end

@implementation BI_GridLayoutManager

+ (BI_GridLayout *)layoutWithStyle:(GridLayoutStyle)style
{
    BI_GridLayout *layout;
    switch (style)
    {
        case kGridLayoutStyleFloating:
        {
            layout = [[BI_CandidateBarLayout alloc] init];
            break;
        }
        
        case kGridLayoutStyleMoreCand:
        {
            layout = [[BI_MoreCandViewLayout alloc] init];
            break;
        }
        
        case kGridLayoutStyleMoreCandSmart:
        {
            layout = [[BI_MoreCandViewSmartLayout alloc] init];
            break;
        }
            
        case kGridLayoutStyleFilter:
        {
            layout = [[BI_FilterViewLayout alloc] init];
            break;
        }
        case kGridLayoutStyleImageLibrary:
        {
        
            layout = [[BI_ImageLibraryViewLayout alloc] init];

            break;
        }
        
        case kGridLayoutStyleToolBar:
        {
            layout = [[BI_CandidateToolBarLayout alloc] init];
            break;
        }
            
        case kGridLayoutStyleDefault:
        default:
        {
            layout = [[BI_GridLayout alloc] init];
            break;
        }
    }
    return [layout autorelease];
}

@end

@implementation BI_FilterViewLayout

- (NSUInteger)indexOfFrameAtPoint:(CGPoint)point
{
    return (numOfRow_ == 1) ? (NSUInteger)(point.x / sizeOfCell_.width) : (NSUInteger)(point.y / sizeOfCell_.height);
}

- (void)layoutBegin
{
    [super layoutBegin];
    
    sizeOfCell_ = [delegate_ sizeOfGridAtIndex:0];
    if (CGSizeEqualToSize(sizeOfCell_, CGSizeZero))
    {
        finished_ = YES;
    }
}

- (BOOL)layoutNextH
{
    BOOL layout = [super layoutNextH];
    if ([frames_ count] >= numOfCell_)
    {
        BI_GridFrame *last = [frames_ lastObject];
        
        NSUInteger index  = last.startIndex + 1;
        CGFloat    startX = last.frame.origin.x + last.frame.size.width;
        CGFloat    endX   = sizeOfPage_.width;
        
        if (startX < endX)
        {
            while (startX < endX)
            {
                CGRect        frame = CGRectMake(startX, 0, sizeOfCell_.width, sizeOfCell_.height);
                BI_GridFrame *item  = [self nextFrame];
                BI_GridInfo  *info  = [self nextGrid];
                
                info.row        = index;
                info.col        = 0;
                info.empty      = YES;
                info.index      = index;
                info.frame      = frame;
                item.frame      = frame;
                item.startIndex = index;
                item.endIndex   = index;
                item.pageIndex  = 0;
                
                [item    addGrid:info];
                [frames_ addObject:item];
                
                index  += 1;
                startX += frame.size.width;
            }
            sizeOfContent_ = CGSizeMake(startX, sizeOfPage_.height);
        }
    }
    return layout;
}

- (BOOL)layoutNextV
{
    BOOL layout = [super layoutNextV];
    if ([frames_ count] >= numOfCell_)
    {
        BI_GridFrame *last = [frames_ lastObject];
        
        NSUInteger index  = last.startIndex + 1;
        CGFloat    startY = last.frame.origin.y + last.frame.size.height;
        CGFloat    endY   = sizeOfPage_.height;
        
        if (startY < endY)
        {
            while (startY < endY)
            {
                CGRect        frame = CGRectMake(0, startY, sizeOfCell_.width, sizeOfCell_.height);
                BI_GridFrame *item  = [self nextFrame];
                BI_GridInfo  *info  = [self nextGrid];
                
                info.row        = index;
                info.col        = 0;
                info.empty      = YES;
                info.index      = index;
                info.frame      = frame;
                item.frame      = frame;
                item.startIndex = index;
                item.endIndex   = index;
                item.pageIndex  = 0;
                
                [item    addGrid:info];
                [frames_ addObject:item];
                
                index  += 1;
                startY += frame.size.height;
            }
            sizeOfContent_ = CGSizeMake(sizeOfPage_.width, startY);
        }
    }
    return layout;
}

@end

@implementation BI_CandidateBarLayout

- (NSUInteger)indexOfFrameAtPoint:(CGPoint)point
{
    return (NSUInteger)(point.x / sizeOfPage_.width);
}

- (BOOL)layoutNext
{
    BI_GridFrame *item   = [frames_ lastObject];
    NSInteger startIndex = item ? item.endIndex + 1 : 0;
    
    numOfCell_ = [delegate_ numOfGrid];
    finished_  = startIndex >= numOfCell_;
    if (!finished_)
    {
        [self willLoadItemAtIndex:startIndex];
        
        CGFloat   startY     = 0;
        CGFloat   startX     = item ? item.frame.origin.x + item.frame.size.width : 0;
        CGFloat   pageWidth  = sizeOfPage_.width;
        NSInteger pageIndex  = [frames_ count];
        NSInteger index      = startIndex;
        NSInteger count      = 0;
        CGFloat   total      = 0.0f;
        CGSize    buffer[32] = {{0,0},};
        while (index < numOfCell_)
        {
            CGSize size   = [delegate_ sizeOfGridAtIndex:index];
            buffer[count] = size;
            total        += size.width;
            if (total > pageWidth && count > 0)
            {
                total -= size.width;
                break;
            }
            
            count++;
            index++;
        }
        
        //如果只有一个Cell，把它的宽度设置为一页的宽度
        if (1 == count && (total > pageWidth || index < numOfCell_))
        {
            total           = pageWidth;
            buffer[0].width = pageWidth;
        }
        
        //把剩余的空间平分给每个Cell
        if (index < numOfCell_ && total < pageWidth && count > 1)
        {
            CGFloat delta = roundf((pageWidth - total) / count);
            for (NSInteger i = 0; i < count - 1; i++)
            {
                buffer[i].width += delta;
            }
            buffer[count - 1].width += (pageWidth - total) - delta * (count - 1);
            total = pageWidth;
        }
        
        BI_GridFrame *info = [self nextFrame];
        info.frame      = CGRectMake(startX, startY, total, buffer[0].height);
        info.startIndex = startIndex;
        info.endIndex   = startIndex + count - 1;
        info.pageIndex  = pageIndex;
        for (NSInteger i = 0; i < count; i++) 
        {
            BI_GridInfo *grid = [self nextGrid];
            grid.row   = 0;
            grid.col   = startIndex + i;
            grid.index = startIndex + i;
            grid.frame = CGRectMake(startX, startY, buffer[i].width, buffer[i].height);
            startX    += buffer[i].width;
            [info addGrid:grid];
        }
        [frames_ addObject:info];
        
        CGFloat  totalWidth   = (info.frame.origin.x + info.frame.size.width) * numOfCell_ / index;
        CGFloat  totalPages   = floorf((totalWidth + sizeOfPage_.width - 1) / sizeOfPage_.width);
        sizeOfContent_.width  = sizeOfPage_.width * totalPages;
        sizeOfContent_.height = sizeOfPage_.height;
        finished_ = index >= numOfCell_;
        
        [delegate_ didLoadItemAtIndex:info.endIndex];
    }
    return finished_;
}

@end


@implementation BI_MoreCandViewLayout

- (NSUInteger)indexOfFrameAtPoint:(CGPoint)point
{
    return (NSUInteger)(point.y / sizeOfCell_.height);
}

- (BOOL)layoutNext
{
    BI_GridFrame *item  = [frames_ lastObject];
    NSInteger     index = item ? item.endIndex + 1 : 0;
    
    numOfCell_ = [delegate_ numOfGrid];
    finished_  = index >= numOfCell_;
    if (!finished_)
    {
        [self willLoadItemAtIndex:index];
        
        CGFloat   pageWidth  = sizeOfPage_.width;
        CGFloat   pageHeight = sizeOfPage_.height;
        CGFloat   rowHeight  = sizeOfCell_.height;
        NSInteger pageIndex  = item ? item.pageIndex + 1 : 0;
        CGFloat   startX     = 0;
        CGFloat   startY     = pageHeight * pageIndex;
        for (NSInteger row = 0; row < numOfRow_ && index < numOfCell_; row++)
        {
            NSUInteger count = 0;
            NSUInteger iter  = index;
            for (NSUInteger col = 0; col < numOfCol_ && iter < numOfCell_; col++) 
            {
                CGSize size = [delegate_ sizeOfGridAtIndex:iter];
                if (size.width > sizeOfCell_.width)
                {
                    break;
                }
                iter++;
                count++;
            }
            
            if (count > 0)
            {
                CGFloat cellY = startY + rowHeight * row;
                
                BI_GridFrame *info  = [self nextFrame];
                info.frame      = CGRectMake(startX, cellY, pageWidth, rowHeight);
                info.startIndex = index;
                info.endIndex   = index + count - 1;
                info.pageIndex  = pageIndex;
                //最后一行的逻辑与其它行不一致，最后一行有可能不填满整行
                count = iter >= numOfCell_ ? numOfCol_ : count;
                CGFloat width = roundf(pageWidth / count);
                for (NSInteger i = 0; i < count; i++)
                {
                    CGFloat roundX = roundf(startX + width * i);
                    CGFloat roundW = roundf(startX + width * (i + 1)) - roundX;
                    
                    BI_GridInfo *grid = [self nextGrid];
                    grid.row   = row;
                    grid.col   = i;
                    grid.index = index++;
                    grid.frame = CGRectMake(roundX, cellY, roundW, rowHeight);
                    grid.empty = grid.index >= numOfCell_;
                    [info addGrid:grid];
                }
                [frames_ addObject:info];
            }
            
            if (count < numOfCol_) 
            {
                if (count > 0)
                {
                    row++;
                }
                
                if (iter < numOfCell_ && row < numOfRow_)
                {
                    BI_GridFrame *info = [self nextFrame];
                    BI_GridInfo  *grid = [self nextGrid];
                    grid.row        = row;
                    grid.col        = 0;
                    grid.index      = index++;
                    grid.frame      = CGRectMake(startX, startY + rowHeight * row, pageWidth, rowHeight);
                    info.frame      = grid.frame;
                    info.startIndex = grid.index;
                    info.endIndex   = grid.index;
                    info.pageIndex  = pageIndex;
                    [info    addGrid:grid];
                    [frames_ addObject:info];
                }
            }
            
            //如果第一页没有填满，需要填满
            if (0 == pageIndex && index >= numOfCell_ && row + 1 < numOfRow_)
            {
                CGFloat width = roundf(pageWidth / numOfCol_);
                for (NSInteger i = row + 1; i < numOfRow_; i++)
                {
                    CGFloat cellY = startY + rowHeight * i;
                    
                    BI_GridFrame *info = [self nextFrame];
                    info.frame         = CGRectMake(startX, cellY, pageWidth, rowHeight);
                    info.startIndex    = index;
                    info.pageIndex     = pageIndex;
                    for (NSInteger j = 0; j < numOfCol_; j++)
                    {
                        CGFloat roundX = roundf(startX + width * j);
                        CGFloat roundW = roundf(startX + width * (j + 1)) - roundX;
                        
                        BI_GridInfo *grid = [self nextGrid];
                        grid.row   = i;
                        grid.col   = j;
                        grid.index = index++;
                        grid.frame = CGRectMake(roundX, cellY, roundW, rowHeight);
                        grid.empty = YES;
                        [info addGrid:grid];
                    }
                    info.endIndex = index - 1;
                    [frames_ addObject:info];
                }
            }
        }
        
        BI_GridFrame *info  = [frames_ lastObject];
        sizeOfContent_.width  = pageWidth;
        if (index >= numOfCell_)
        {
            finished_ = YES;
            sizeOfContent_.height = info.frame.origin.y + info.frame.size.height;
        }
        else
        {
            finished_ = NO;
            sizeOfContent_.height = (info.frame.origin.y + info.frame.size.height) * numOfCell_ / index;
        }
        
        [delegate_ didLoadItemAtIndex:info.endIndex];
    }
    return finished_;
}

@end


@implementation BI_MoreCandViewSmartLayout

- (NSUInteger)indexOfFrameAtPoint:(CGPoint)point
{
    return (NSUInteger)(point.y / sizeOfCell_.height);
}

//对称排版，同一行的格子的大小都是一样的
- (BOOL)layoutNextSymmetry
{
    BI_GridFrame *item  = [frames_ lastObject];
    NSInteger     index = item ? item.endIndex + 1 : 0;
    
    numOfCell_ = [delegate_ numOfGrid];
    finished_  = index >= numOfCell_;
    if (!finished_)
    {
        [self willLoadItemAtIndex:index];
        
        CGFloat   pageWidth  = sizeOfPage_.width;
        CGFloat   pageHeight = sizeOfPage_.height;
        CGFloat   colWidth   = sizeOfCell_.width;
        CGFloat   rowHeight  = sizeOfCell_.height;
        NSInteger pageIndex  = item ? item.pageIndex + 1 : 0;
        CGFloat   startY     = pageHeight * pageIndex;
        for (NSInteger row = 0; row < numOfRow_ && index < numOfCell_; row++)
        {
            NSUInteger count      = 0;
            NSUInteger current    = index;
            NSUInteger maxGrids   = 0;
            NSUInteger cells[32]  = {0,};
            for (NSUInteger col = 0; col < numOfCol_ && current < numOfCell_; col++)
            {
                CGSize size = [delegate_ sizeOfGridAtIndex:current];
                
                //计算每个Cell占据的Grid数目，必须被总列数整除
                NSUInteger grids = (NSUInteger)((size.width + colWidth - 1) / colWidth);
                if (grids == 0)
                {
                    grids = 1;
                }
                if (grids >= numOfCol_) 
                {
                    grids = numOfCol_;
                }
                
                while (0 != (numOfCol_ % grids)) 
                {
                    grids++;
                }
                
                //判断是否可以放置在空余的格子中
                if (count > 0 && grids > maxGrids && (grids * (count + 1) > numOfCol_))
                {
                    break;
                }
                
                current++;
                count++;
                
                //更新maxGrids
                if (grids > maxGrids) 
                {
                    maxGrids = grids;
                }
                
                if (maxGrids * count >= numOfCol_)
                {
                    break;
                }
            }
            
            //如果只有一个Cell，把它的宽度设置为一页的宽度
            if (1 == count && (maxGrids > numOfCol_ || current < numOfCell_))
            {
                maxGrids  = numOfCol_;
            }
            
            //如果不是最后一行，对未填满的行重新布局，使每个格子的大小一样
            if (current < numOfCell_)
            {
                while ((0 != (numOfCol_ % maxGrids)) || ((numOfCol_ / maxGrids) > count))
                {
                    maxGrids++;
                }
                
                NSUInteger prevCount = count;
                count    = numOfCol_ / maxGrids;
                current -= (prevCount - count);
            }
            
            for (NSInteger i = 0; i < count; i++)
            {
                cells[i] = maxGrids;
            }
            
            if (count > 0)
            {
                CGFloat cellY = startY + rowHeight * row;
                
                BI_GridFrame *info  = [self nextFrame];
                info.frame      = CGRectMake(0, cellY, pageWidth, rowHeight);
                info.startIndex = index;
                info.endIndex   = index + count - 1;
                info.pageIndex  = pageIndex;
                
                //最后一行的逻辑与其它行不一致，最后一行有可能不填满整行
                if (current >= numOfCell_)
                {
                    for (NSInteger i = 0; i < (numOfCol_ - count); i++)
                    {
                        cells[count + i] = 1;
                    }
                    
                    count += numOfCol_ - count;
                }
                
                CGFloat startX = 0.0f;
                for (NSInteger i = 0; i < count; i++)
                {
                    CGFloat width = cells[i] * colWidth;
                    
                    BI_GridInfo *grid = [self nextGrid];
                    grid.row   = row;
                    grid.col   = i;
                    grid.index = index++;
                    grid.frame = CGRectMake(startX, cellY, width, rowHeight);
                    grid.empty = grid.index >= numOfCell_;
                    [info addGrid:grid];
                    
                    startX += width;
                }
                [frames_ addObject:info];
            }
            
            //如果第一页没有填满，需要填满
            if (0 == pageIndex && index >= numOfCell_ && row + 1 < numOfRow_)
            {
                for (NSInteger i = row + 1; i < numOfRow_; i++)
                {
                    CGFloat cellY = startY + rowHeight * i;
                    
                    BI_GridFrame *info = [self nextFrame];
                    info.frame         = CGRectMake(0, cellY, pageWidth, rowHeight);
                    info.startIndex    = index;
                    info.pageIndex     = pageIndex;
                    
                    CGFloat startX = 0.0f;
                    for (NSInteger j = 0; j < numOfCol_; j++)
                    {
                        BI_GridInfo *grid = [self nextGrid];
                        grid.row   = i;
                        grid.col   = j;
                        grid.index = index++;
                        grid.frame = CGRectMake(startX, cellY, colWidth, rowHeight);
                        grid.empty = YES;
                        [info addGrid:grid];
                        
                        startX += colWidth;
                    }
                    info.endIndex = index - 1;
                    [frames_ addObject:info];
                }
            }
        }
        
        BI_GridFrame *info    = [frames_ lastObject];
        sizeOfContent_.width  = pageWidth;
        if (index >= numOfCell_)
        {
            finished_ = YES;
            sizeOfContent_.height = info.frame.origin.y + info.frame.size.height;
        }
        else
        {
            sizeOfContent_.height = (info.frame.origin.y + info.frame.size.height) * numOfCell_ / index;
            finished_ = NO;
            CGFloat curHeight = (info.frame.origin.y + info.frame.size.height) * numOfCell_ / index;
            CGFloat minHeight = info.frame.origin.y + info.frame.size.height + rowHeight;
            if (curHeight < minHeight)
            {
                curHeight = minHeight;
            }
            sizeOfContent_.height = curHeight;
        }
        
        [delegate_ didLoadItemAtIndex:info.endIndex];
    }
    return finished_;
}

//不对称排版，尽可能多地加入Cell，如果有剩余地空间，将其分配给最长地Cell
- (BOOL)layoutNextAsymmetry
{
    BI_GridFrame *item  = [frames_ lastObject];
    NSInteger     index = item ? item.endIndex + 1 : 0;
    
    numOfCell_ = [delegate_ numOfGrid];
    finished_  = index >= numOfCell_;
    if (!finished_)
    {
        [self willLoadItemAtIndex:index];
        
        CGFloat   pageWidth  = sizeOfPage_.width;
        CGFloat   pageHeight = sizeOfPage_.height;
        CGFloat   colWidth   = sizeOfCell_.width;
        CGFloat   rowHeight  = sizeOfCell_.height;
        NSInteger pageIndex  = item ? item.pageIndex + 1 : 0;
        CGFloat   startY     = pageHeight * pageIndex;
        for (NSInteger row = 0; row < numOfRow_ && index < numOfCell_; row++)
        {
            NSUInteger count      = 0;
            NSUInteger current    = index;
            NSUInteger total      = 0;
            NSUInteger cells[32]  = {0,};
            CGFloat    buffer[32] = {0,};
            for (NSUInteger col = 0; col < numOfCol_ && current < numOfCell_; col++)
            {
                CGSize size   = [delegate_ sizeOfGridAtIndex:current];
                buffer[count] = size.width;
                cells[count]  = (NSUInteger)((size.width + colWidth - 1) / colWidth);
                total        += cells[count];
                if (total > numOfCol_ && count > 0)
                {
                    total -= cells[count];
                    break;
                }
                current++;
                count++;
            }
            
            //如果只有一个Cell，把它的宽度设置为一页的宽度
            if (1 == count && (total > numOfCol_ || current < numOfCell_))
            {
                total     = numOfCol_;
                cells[0]  = numOfCol_;
                buffer[0] = pageWidth;
            }
            
            //如果不是最后一行，将剩余的空间分配给其它的格子
            if (current < numOfCell_)
            {
                //把剩余空间分配到最长的Cell上
                for (NSInteger i = 0; i < (numOfCol_ - total); i++)
                {
                    NSInteger maxIndex = 0;
                    CGFloat   maxValue = 0;
                    for (NSInteger j = 0; j < count ; j++)
                    {
                        CGFloat value = buffer[j] / cells[j];
                        if (value > maxValue)
                        {
                            maxValue = value;
                            maxIndex = j;
                        }
                    }
                    cells[maxIndex]++;
                }
            }
            
            if (count > 0)
            {
                CGFloat cellY = startY + rowHeight * row;
                
                BI_GridFrame *info  = [self nextFrame];
                info.frame      = CGRectMake(0, cellY, pageWidth, rowHeight);
                info.startIndex = index;
                info.endIndex   = index + count - 1;
                info.pageIndex  = pageIndex;
                
                //最后一行的逻辑与其它行不一致，最后一行有可能不填满整行
                if (current >= numOfCell_)
                {
                    for (NSInteger i = 0; i < (numOfCol_ - total); i++)
                    {
                        cells[count + i] = 1;
                    }
                    count += numOfCol_ - total;
                }
                
                CGFloat startX = 0.0f;
                for (NSInteger i = 0; i < count; i++)
                {
                    CGFloat width = cells[i] * colWidth;
                    
                    BI_GridInfo *grid = [self nextGrid];
                    grid.row   = row;
                    grid.col   = i;
                    grid.index = index++;
                    grid.frame = CGRectMake(startX, cellY, width, rowHeight);
                    grid.empty = grid.index >= numOfCell_;
                    [info addGrid:grid];
                    
                    startX += width;
                }
                [frames_ addObject:info];
            }
            
            //如果第一页没有填满，需要填满
            if (0 == pageIndex && index >= numOfCell_ && row + 1 < numOfRow_)
            {
                for (NSInteger i = row + 1; i < numOfRow_; i++)
                {
                    CGFloat cellY = startY + rowHeight * i;
                    
                    BI_GridFrame *info = [self nextFrame];
                    info.frame         = CGRectMake(0, cellY, pageWidth, rowHeight);
                    info.startIndex    = index;
                    info.pageIndex     = pageIndex;
                    
                    CGFloat startX = 0.0f;
                    for (NSInteger j = 0; j < numOfCol_; j++)
                    {
                        BI_GridInfo *grid = [self nextGrid];
                        grid.row   = i;
                        grid.col   = j;
                        grid.index = index++;
                        grid.frame = CGRectMake(startX, cellY, colWidth, rowHeight);
                        grid.empty = YES;
                        [info addGrid:grid];
                        
                        startX += colWidth;
                    }
                    info.endIndex = index - 1;
                    [frames_ addObject:info];
                }
            }
        }
        
        BI_GridFrame *info    = [frames_ lastObject];
        sizeOfContent_.width  = pageWidth;
        if (index >= numOfCell_)
        {
            finished_ = YES;
            sizeOfContent_.height = info.frame.origin.y + info.frame.size.height;
        }
        else
        {
            finished_ = NO;            
            CGFloat curHeight = (info.frame.origin.y + info.frame.size.height) * numOfCell_ / index;
            CGFloat minHeight = info.frame.origin.y + info.frame.size.height + rowHeight;
            if (curHeight < minHeight)
            {
                curHeight = minHeight;
            }
            sizeOfContent_.height = curHeight;
        }
        
        [delegate_ didLoadItemAtIndex:info.endIndex];
    }
    return finished_;
}

- (BOOL)layoutNext
{
    if (0 == (numOfCol_ & 1)) 
    {
        return [self layoutNextSymmetry];
    }
    else
    {
        return [self layoutNextAsymmetry];
    }
}

@end


@implementation BI_ImageLibraryViewLayout



- (NSUInteger)indexOfFrameAtPoint:(CGPoint)point
{
    return (NSUInteger)(point.y / sizeOfCell_.height);
}

- (BOOL)layoutNext
{
    BI_GridFrame *item  = [frames_ lastObject];
    NSInteger     index = item ? item.endIndex + 1 : 0;
    
    numOfCell_ = [delegate_ numOfGrid];
    finished_  = index >= numOfCell_;
    if (!finished_)
    {
        [self willLoadItemAtIndex:index];
        
        CGFloat   pageWidth  = sizeOfPage_.width;
        CGFloat   pageHeight = sizeOfPage_.height;
        CGFloat   rowHeight  = sizeOfCell_.height;
        NSInteger pageIndex  = item ? item.pageIndex + 1 : 0;
        CGFloat   startX     = 0;
        CGFloat   startY     = pageHeight * pageIndex;
        for (NSInteger row = 0; row < numOfRow_ && index < numOfCell_; row++)
        {
            NSUInteger count = 0;
            NSUInteger iter  = index;
            for (NSUInteger col = 0; col < numOfCol_ && iter < numOfCell_; col++) 
            {
                CGSize size = [delegate_ sizeOfGridAtIndex:iter];
                if (size.width > sizeOfCell_.width)
                {
                    break;
                }
                iter++;
                count++;
            }
            
            if (count > 0)
            {
                CGFloat cellY = startY + rowHeight * row;
                
                BI_GridFrame *info  = [self nextFrame];
                info.frame      = CGRectMake(startX, cellY, pageWidth, rowHeight);
                info.startIndex = index;
                info.endIndex   = index + count - 1;
                info.pageIndex  = pageIndex;
                //最后一行的逻辑与其它行不一致，最后一行有可能不填满整行
                count = iter >= numOfCell_ ? numOfCol_ : count;
                CGFloat width = roundf(pageWidth / count);
                for (NSInteger i = 0; i < count; i++)
                {
                    CGFloat roundX = roundf(startX + width * i);
                    CGFloat roundW = roundf(startX + width * (i + 1)) - roundX;
                    
                    BI_GridInfo *grid = [self nextGrid];
                    grid.row   = row;
                    grid.col   = i;
                    grid.index = index++;
                    grid.frame = CGRectMake(roundX, cellY, roundW, rowHeight);
                    grid.empty = grid.index >= numOfCell_;
                    [info addGrid:grid];
                }
                [frames_ addObject:info];
            }
            
            if (count < numOfCol_) 
            {
                if (count > 0)
                {
                    row++;
                }
                
                if (iter < numOfCell_ && row < numOfRow_)
                {
                    BI_GridFrame *info = [self nextFrame];
                    BI_GridInfo  *grid = [self nextGrid];
                    grid.row        = row;
                    grid.col        = 0;
                    grid.index      = index++;
                    grid.frame      = CGRectMake(startX, startY + rowHeight * row, pageWidth, rowHeight);
                    info.frame      = grid.frame;
                    info.startIndex = grid.index;
                    info.endIndex   = grid.index;
                    info.pageIndex  = pageIndex;
                    [info    addGrid:grid];
                    [frames_ addObject:info];
                }
            }
            
        }
        
        BI_GridFrame *info  = [frames_ lastObject];
        sizeOfContent_.width  = pageWidth;
        if (index >= numOfCell_)
        {
            finished_ = YES;
            sizeOfContent_.height = info.frame.origin.y + info.frame.size.height;
        }
        else
        {
            finished_ = NO;
            sizeOfContent_.height = (info.frame.origin.y + info.frame.size.height) * numOfCell_ / index;
        }
        
        [delegate_ didLoadItemAtIndex:info.endIndex];
    }
    
    
//    NSLog(@"layout next, frame count = %d",[frames_ count]);
    return finished_;
}

@end


@implementation BI_CandidateToolBarLayout

- (BI_GridFrame *)frameAtPoint:(CGPoint)point
{
    return [self frameAtIndex:[super indexOfFrameAtPoint:point]];
}

- (NSUInteger)indexOfFrameAtPoint:(CGPoint)point
{
    CGFloat offsetX = point.x;
    if (offsetX <= edgeInsets_.left)
    {
        return 0;
    }
    
    NSInteger pageIndex = offsetX / sizeOfPage_.width;
    offsetX -= sizeOfPage_.width * pageIndex;
    offsetX -= edgeInsets_.left;
    NSInteger cellIndex  = offsetX / (sizeOfCell_.width + horizontalGap_);
    NSInteger frameIndex = pageIndex * numOfCol_ + cellIndex;
    return frameIndex < numOfCell_ ? frameIndex : numOfCell_ - 1;
}

- (void)layoutBegin
{
    [super layoutBegin];
    
    if (!finished_)
    {
        CGFloat width  = sizeOfPage_.width  - edgeInsets_.left - edgeInsets_.right - horizontalGap_ * (numOfCol_ - 1);
        CGFloat height = sizeOfPage_.height - edgeInsets_.top  - edgeInsets_.bottom;
        sizeOfCell_ = CGSizeMake(width / numOfCol_, height / numOfRow_);
    }
}

- (BOOL)layoutNext
{
    BI_GridFrame *item   = [frames_ lastObject];
    NSInteger index = item ? item.endIndex + 1 : 0;
    
    numOfCell_ = [delegate_ numOfGrid];
    finished_  = index >= numOfCell_;
    if (!finished_)
    {
        NSInteger pageIndex  = 0 == [frames_ count] ? 0 : item.pageIndex + 1;
        
        CGRect rect = CGRectZero;
        rect.origin.x = sizeOfPage_.width * pageIndex + edgeInsets_.left;
        rect.origin.y = edgeInsets_.top;
        rect.size = sizeOfCell_;
        for (NSInteger i = 0; i < numOfCol_; i++)
        {
            
            
            BI_GridInfo  *grid = [self nextGrid];
            BI_GridFrame *info = [self nextFrame];
            grid.row        = index;
            grid.col        = 0;
            grid.empty      = NO;
            grid.index      = index;
            grid.frame      = rect;
            info.frame      = rect;
            info.startIndex = index;
            info.endIndex   = index;
            info.pageIndex  = pageIndex;
            [info addGrid:grid];
            [frames_ addObject:info];
            
            index ++;
            rect.origin.x += horizontalGap_ + sizeOfCell_.width;
        }
        
        sizeOfContent_.width  = sizeOfPage_.width * (pageIndex + 1);
        sizeOfContent_.height = sizeOfPage_.height;
        finished_ = index >= numOfCell_;
    }
    return finished_;
}

@end