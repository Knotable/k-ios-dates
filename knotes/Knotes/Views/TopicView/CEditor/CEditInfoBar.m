//
//  CEditInfoBar.m
//  RevealControllerProject
//
//  Created by backup on 13-10-11.
//
//

#import "CEditInfoBar.h"

#import "CUtil.h"
#import "UIButton+Extensions.h"
#import <objc/runtime.h>

@interface CEditInfoBar()<BI_GridViewDelegate>

@end
@implementation CEditInfoBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.style = 0;
        [self initView];
    }
    return self;
}

- (void)initView
{
    self.backView   = [[UIView alloc] initWithFrame:CGRectZero];
    self.candView   = [[BI_GridView alloc] initWithFrame:CGRectZero];
    
    self.nextPage = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.nextPage addTarget:self action:@selector(nextPageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.nextPage];
    
    self.prePage = [[UIButton alloc] initWithFrame:CGRectZero];
    [self.prePage addTarget:self action:@selector(prePageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.prePage];
    
    [self.candView  setGridDelegate:self];
    [self.candView  setPagingEnabled:YES];
    
    self.candView.canCancelContentTouches = YES;
    self.candView.delaysContentTouches = NO;
    [self addSubview:self.candView];
    [self.prePage setImage:[UIImage imageNamed:@"arrow-left"] forState:UIControlStateNormal];
    [self.nextPage setImage:[UIImage imageNamed:@"arrow-right"] forState:UIControlStateNormal];
    [self.prePage  setHitTestEdgeInsets:UIEdgeInsetsMake(-2, -10, -5, -2)];
    [self.nextPage  setHitTestEdgeInsets:UIEdgeInsetsMake(-2, -10, -5, -2)];

    CGRect rect = self.bounds;
    if (_style == 0) {
        rect.origin.x+=10;
        rect.size.width-=20;
    } else if (_style == 1) {
        rect.origin.x+=72;
        rect.size.width-=(66+20);
    }
    [self.candView setFrame:rect];
    
    self.indicateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.indicateLabel.numberOfLines = 0;
    self.indicateLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.indicateLabel.textAlignment = NSTextAlignmentCenter;
    self.indicateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.0];
    self.indicateLabel.textColor = [UIColor lightGrayColor];
    self.indicateLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.indicateLabel];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLikes
                                                        object:[NSNumber numberWithInteger:[self.delegate numOfCellsInCandidateBar:self]]];
}

- (void)setAlpha:(CGFloat)alpha
{
	if (alpha >= 0 && alpha <= 1)
	{
		self.backView.alpha  = alpha;
    }
}

- (void)setDelegate:(id<CEditInfoBarDelegate>)newDelegate
{
    _delegate                          = newDelegate;
    flags_.delegateWillLoadItemAtIndex = [newDelegate respondsToSelector:@selector(candidateBar:willLoadItemAtIndex:)];
    flags_.delegateDidLoadItemAtIndex  = [newDelegate respondsToSelector:@selector(candidateBar:didLoadItemAtIndex:)];
    flags_.delegateDidSelectCell       = [newDelegate respondsToSelector:@selector(candidateBar:didSelectCellAtIndex:)];
    flags_.delegateWillLongPressCell   = [newDelegate respondsToSelector:@selector(candidateBar:willLongPressCellAtIndex:)];
    flags_.delegateDidLongPressCell    = [newDelegate respondsToSelector:@selector(candidateBar:didLongPressCellAtIndex:)];
}

- (void)removeCachedCells
{
    [self.candView removeCachedCells];
}

- (void)reloadData
{
    CGRect rect = self.bounds;
    if (_style == 0) {
        rect.origin.x+=10;
        rect.size.width-=20;
    } else if (_style == 1) {
        rect.origin.x+=72;
        rect.size.width-=(66+20);
    }
    [self.candView setFrame:rect];

    [self.candView reloadData];
    [self updateNextPageBtnStatus];
    [self updatePrePageBtnStatus];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLikes
                                                        object:[NSNumber numberWithInteger:[self.delegate numOfCellsInCandidateBar:self]]];
}

- (BI_GridFrame *)currentFrame{
    return [self.candView currentFrame];
}

- (BI_GridViewCell *)cellAtIndex:(NSUInteger)index
{
    return [self.candView cellAtIndex:index];
}

- (BI_GridViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    return [self.candView dequeueReusableCellWithIdentifier:identifier];
}

- (void)deselectCellAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    [self.candView deselectCellAtIndex:index animated:animated];
}

- (void)prePageButtonClicked:(id)sender
{
    [self showPrePage];
}

- (void)nextPageButtonClicked:(id)sender
{
    [self showNextPage];
}

- (void)updatePrePageBtnStatus
{
    CGPoint offsetPt = self.candView.contentOffset;
    NSUInteger minOffset = 0;
    if (offsetPt.x<=minOffset) {
        self.prePage.hidden = YES;
    }else {
        self.prePage.hidden = NO;
    }
    [self.prePage setNeedsDisplay];
}

- (void)updateNextPageBtnStatus
{
    CGPoint offsetPt = self.candView.contentOffset;
    NSInteger maxOffset = self.candView.contentSize.width - self.candView.frame.size.width;

    if (maxOffset<0 || offsetPt.x >= maxOffset) {
        self.nextPage.hidden = YES;
    }else  {
        self.nextPage.hidden = NO;
    }
    [self.nextPage setNeedsDisplay];
}

#pragma mark -
#pragma mark BI_GridViewDelegate

- (NSUInteger)numOfRowInGridView:(BI_GridView *)gridView
{
    return 1;
}

- (NSUInteger)numOfColInGridView:(BI_GridView *)gridView
{
    return 1;
}

- (NSUInteger)numOfCellInGridView:(BI_GridView *)gridView
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLikes
                                                        object:[NSNumber numberWithInteger:[self.delegate numOfCellsInCandidateBar:self]]];
    
    return [self.delegate numOfCellsInCandidateBar:self];
}

- (CGSize)gridView:(BI_GridView *)gridView sizeOfCellAtIndex:(NSUInteger)index
{
    return [self.delegate candidateBar:self sizeOfCellAtIndex:index];
}

- (BI_GridViewCell *)gridView:(BI_GridView *)gridView cellForFrame:(BI_GridFrame *)frame
{
    return [self.delegate candidateBar:self cellForFrame:frame];
}

- (void)gridView:(BI_GridView *)gridView willLoadItemAtIndex:(NSUInteger)index
{
    if (flags_.delegateWillLoadItemAtIndex)
    {
        [self.delegate candidateBar:self willLoadItemAtIndex:index];
    }
}

- (void)gridView:(BI_GridView *)gridView didLoadItemAtIndex:(NSUInteger)index
{
    if (flags_.delegateDidLoadItemAtIndex)
    {
        [self.delegate candidateBar:self didLoadItemAtIndex:index];
    }
}

- (void)gridView:(BI_GridView *)gridView didSelectCellAtIndex:(NSUInteger)index
{
    if (flags_.delegateDidSelectCell)
    {
        [self.delegate candidateBar:self didSelectCellAtIndex:index];
    }
}

- (BOOL)gridView:(BI_GridView *)gridView willLongPressCellAtIndex:(NSUInteger)index
{
    return flags_.delegateWillLongPressCell ? [self.delegate candidateBar:self willLongPressCellAtIndex:index] : NO;
}

- (void)gridView:(BI_GridView *)gridView didLongPressCellAtIndex:(NSUInteger)index
{
    if (flags_.delegateDidLongPressCell)
    {
        [self.delegate candidateBar:self didLongPressCellAtIndex:index];
    }
}

#pragma mark -
#pragma mark Touch Events


- (BOOL)showPrePage
{
    BOOL preExist = YES;
    
    CGPoint offsetPt =  self.candView.contentOffset;
    offsetPt.x -= self.candView.frame.size.width;
    
    NSUInteger minOffset = 0;
    if(offsetPt.x <= minOffset)
    {
        preExist = NO;
        offsetPt.x = minOffset;
    }
    
    [self.candView setContentOffset:offsetPt animated:NO];
    [self updatePrePageBtnStatus];
    [self updateNextPageBtnStatus];
    
    return preExist;
}

- (BOOL)showNextPage
{
    BOOL nextExist = YES;
    
    CGPoint offsetPt =  self.candView.contentOffset;
    offsetPt.x += self.candView.frame.size.width;
    
    NSUInteger maxOffset = self.candView.contentSize.width - self.candView.frame.size.width;
    if(offsetPt.x >= maxOffset)
    {
        nextExist = NO;
        offsetPt.x = maxOffset;
    }
    
    [self.candView setContentOffset:offsetPt animated:NO];
    [self updateNextPageBtnStatus];
    [self updatePrePageBtnStatus];
    
    return nextExist;
}

-(void)updateConstraints
{
    [super updateConstraints];
    [self.nextPage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right);
        make.centerY.equalTo(self.mas_centerY);
        make.width.equalTo(@12);
        make.height.equalTo(@12);
    }];
    [self.prePage mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left);
        make.centerY.equalTo(self.mas_centerY);
        make.width.equalTo(@12);
        make.height.equalTo(@12);
    }];

    [self bringSubviewToFront:self.prePage];
    [self bringSubviewToFront:self.nextPage];
}
-(void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    CGRect rect = self.bounds;
    if (_style == 0) {
        rect.origin.x+=10;
        rect.size.width-=20;
    } else if (_style == 1) {
        rect.origin.x+=72;
        rect.size.width-=(66+20);
    }
    [self.candView setFrame:rect];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    if (_style == 0) {
        self.nextPage.hidden = YES;
        self.prePage.hidden = YES;
        
        CGRect rect = self.bounds;
        
        rect.origin.x+=10;
        
        rect.size.width-=20;
        
        NSString *str = @"";
        
        if (self.showMore)
        {
            rect.size.width -= 73;
            
            [self.indicateLabel setFrame:CGRectMake(rect.origin.x+rect.size.width, 0, 80, CGRectGetHeight(self.bounds))];
            
            str = [NSString stringWithFormat: @"and %d other liked this",(int)([self.delegate numOfCellsInCandidateBar:self]-6)];
            
        }
        else
        {
            rect.size.width-=(50+30*(7-[self.delegate numOfCellsInCandidateBar:self]));
            
            [self.indicateLabel setFrame:CGRectMake(rect.origin.x+rect.size.width, 0, 60, CGRectGetHeight(self.bounds))];
            
            str = @"liked this";
        }
        
        self.indicateLabel.text = str;
        
        [self.candView setFrame:rect];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationLikes
                                                            object:[NSNumber numberWithInteger:[self.delegate numOfCellsInCandidateBar:self]]];
        
    } else if (_style == 1) {
        
        self.nextPage.hidden = YES;
        self.prePage.hidden = YES;
        
        CGRect rect = self.bounds;
        
        rect.origin.x+=72;
        
        rect.size.width-=(66+20);
        
        NSString *str = @"";
        self.indicateLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        self.indicateLabel.textColor = [UIColor blackColor];
        [self.indicateLabel setFrame:CGRectMake(0, 0, 66, CGRectGetHeight(self.bounds))];
        
        str = @"Mention:";
        
        self.indicateLabel.text = str;
        [self.candView setFrame:rect];
        
    }
  
}
@end
