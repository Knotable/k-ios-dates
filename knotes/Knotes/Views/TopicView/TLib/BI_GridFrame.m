//
//  BI_GridFrame.m
//  BaiduIMLib
//
//  Created by backup on 11-9-30.
//  Copyright 2011年 backup. All rights reserved.
//

#import "BI_GridFrame.h"
#import "BI_GridFramePrivate.h"

#pragma mark -
#pragma mark BI_GridInfo

@implementation BI_GridInfo

@synthesize row     = row_;
@synthesize col     = col_;
@synthesize index   = index_;
@synthesize frame   = frame_;
@synthesize width   = width_;
@synthesize textWidth = textWidth_;
@synthesize object  = object_;
@synthesize empty   = empty_;
@synthesize icon = icon_;

- (id)init
{
    self = [super init];
    if (self)
    {
        empty_   = NO;
    }
    return self;
}

- (void)dealloc
{
    [object_ release];
    [icon_   release];
    [super   dealloc];
}

#pragma mark -
#pragma mark BI_GridInfo Private Message

- (void)reset
{
    row_     = 0;
    col_     = 0;
    index_   = 0;
    frame_   = CGRectZero;
    width_   = 0;
    textWidth_ = 0;
    empty_   = NO;
    [icon_ release];
    icon_ = nil;

    [object_ release];
    object_ = nil;
}

@end

#pragma mark -
#pragma mark BI_GridFrame

static const NSUInteger kDefaultGridsCapacity = 5;

@implementation BI_GridFrame

@synthesize frame      = frame_;
@synthesize object     = object_;
@synthesize endIndex   = endIndex_;
@synthesize startIndex = startIndex_;
@synthesize pageIndex  = pageIndex_;
@synthesize selIndex   = selIndex_;

- (id)init
{
    self = [super init];
    if (self)
    {
        selIndex_ = -1;
        grids_    = [[NSMutableArray alloc] initWithCapacity:kDefaultGridsCapacity];
    }
    return self;
}

- (void)dealloc
{
    [grids_  release];
    [object_ release];
    [super   dealloc];
}

- (BI_GridInfo *)gridAtPoint:(CGPoint)point
{
    BI_GridInfo *info = nil;
    
    NSInteger start  = 0;
    NSInteger middle = 0;
    NSInteger end    = [grids_ count] - 1;
    while (start <= end)
    {
        middle = (start + end) / 2;
        
        BI_GridInfo *grid = [grids_ objectAtIndex:middle];
        
        CGRect rect = grid.frame; 
        if (rect.origin.x > point.x) 
        {
            end = middle - 1;
        }
        else if (rect.origin.x + rect.size.width < point.x)
        {
            start = middle + 1;
        }
        else
        {
            info = grid;
            break;
        }
    }
    
    return info;
}

- (BI_GridInfo *)gridAtIndex:(NSUInteger)index
{
    BI_GridInfo *info = nil;
    if (index < [grids_ count])
    {
        info = [grids_ objectAtIndex:index];
    }
    return info;
}

- (BI_GridInfo *)gridContainsIndex:(NSUInteger)index
{
    BI_GridInfo *info = nil;
    
    NSInteger start  = 0;
    NSInteger middle = 0;
    NSInteger end    = [grids_ count] - 1;
    while (start <= end)
    {
        middle = (start + end) / 2;
        
        BI_GridInfo *grid = [grids_ objectAtIndex:middle];
        if (grid.index > index) 
        {
            end = middle - 1;
        }
        else if (grid.index < index)
        {
            start = middle + 1;
        }
        else
        {
            info = grid;
            break;
        }
    }
    
    return info;
}

#pragma mark -
#pragma mark BI_GridFrame Private Message

- (NSUInteger)gridCount
{
    return [grids_ count];
}

- (void)reset;
{
    [object_ release];
    [grids_  removeAllObjects];
    
    object_     = nil;
    frame_      = CGRectZero;
    endIndex_   = 0;
    startIndex_ = 0;
    pageIndex_  = 0;
    selIndex_   = -1;
}

- (void)addGrid:(BI_GridInfo *)info
{
    [grids_ addObject:info];
}

@end
