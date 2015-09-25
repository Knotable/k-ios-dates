//
//  RichTableView.m
//  Knotable
//
//  Created by backup on 14-3-25.
//
//

#import "RichTableView.h"
#import "CEditBaseItemView.h"
/**
 * We need a little helper to cancel the current touch of the long press gesture recognizer
 * in the case the user does not tap on a row but on a section or table header
 */
@interface UIGestureRecognizer (FMUtilities)

- (void)cancelTouch;

@end


@implementation UIGestureRecognizer (FMUtilities)

- (void)cancelTouch
{
    self.enabled = NO;
    self.enabled = YES;
}

@end

@interface RichTableView() {
    UISwipeGestureRecognizer * _leftGestureRecognizer;
    UISwipeGestureRecognizer * _rightGestureRecognizer;
    UITapGestureRecognizer * _tapGestureRecognizer;
    UITapGestureRecognizer * _doubleTapGestureRecognizer;

    NSIndexPath * _showingIndexPath;
}
@property (nonatomic, assign) CGPoint touchOffset;
@property (nonatomic, strong) UIView *snapShotOfMovingCell;
@property (nonatomic, strong) UILongPressGestureRecognizer *movingGestureRecognizer;

@property (nonatomic, strong) NSTimer *autoscrollTimer;
@property (nonatomic, assign) NSInteger autoscrollDistance;
@property (nonatomic, assign) NSInteger autoscrollThreshold;
@end
@implementation RichTableView
@dynamic dataSource;
@synthesize richDelegate;

#pragma mark - View life cycle

- (void)prepareGestureRecognizer
{
    NSLog(@".");
    self.movingGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    self.movingGestureRecognizer.numberOfTouchesRequired = 2;
    self.movingGestureRecognizer.delegate = self;
    [self addGestureRecognizer:self.movingGestureRecognizer];
}


- (void)awakeFromNib
{
	[super awakeFromNib];
	
	[self prepareGestureRecognizer];
}


- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self) {
        _leftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
        _leftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
        _leftGestureRecognizer.delegate = self;
        [self addGestureRecognizer:_leftGestureRecognizer];
        
        _rightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swiped:)];
        _rightGestureRecognizer.delegate = self;
        _rightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:_rightGestureRecognizer];
        
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapped:)];
        _tapGestureRecognizer.delegate = self;
        // Don't add this yet
        
        _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
        _doubleTapGestureRecognizer.numberOfTouchesRequired = 1;
        _doubleTapGestureRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:_doubleTapGestureRecognizer];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
        [self prepareGestureRecognizer];

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame style:UITableViewStylePlain];
}

- (void)swiped:(UISwipeGestureRecognizer *)gestureRecognizer {
    NSIndexPath * indexPath = [self cellIndexPathForGestureRecognizer:gestureRecognizer];
    if(indexPath == nil)
        return;
    
    if(![self.dataSource tableView:self canEditRowAtIndexPath:indexPath]) {
        return;
    }
    if (gestureRecognizer == _leftGestureRecognizer && ![_showingIndexPath isEqual:indexPath]){
        UITableViewCell * cell = [self cellForRowAtIndexPath:indexPath];
        [self setMenuShow:YES atIndexPath:indexPath cell:cell];
    } else if (gestureRecognizer == _rightGestureRecognizer && [_showingIndexPath isEqual:indexPath]){
        UITableViewCell * cell = [self cellForRowAtIndexPath:indexPath];
        [self setMenuShow:NO atIndexPath:indexPath cell:cell];
    } else {
        UITableViewCell * cell = [self cellForRowAtIndexPath:_showingIndexPath];
        [self setMenuShow:NO atIndexPath:_showingIndexPath cell:cell];
    }
}

- (void)tapped:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@".");
    if(_showingIndexPath) {
        UITableViewCell * cell = [self cellForRowAtIndexPath:_showingIndexPath];
        [self setMenuShow:NO atIndexPath:_showingIndexPath cell:cell];
    }
}
- (void)doubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@".");
    if(_showingIndexPath) {
        UITableViewCell * cell = [self cellForRowAtIndexPath:_showingIndexPath];
        [self setMenuShow:NO atIndexPath:_showingIndexPath cell:cell];
    }
    NSIndexPath * indexPath = [self cellIndexPathForGestureRecognizer:gestureRecognizer];
    if(indexPath == nil)
        return;
    if (self.richDelegate && [self.richDelegate respondsToSelector:@selector(doubleTapAtIndexPath:cell:)]) {
        UITableViewCell * tapCell = [self cellForRowAtIndexPath:indexPath];
        [self.richDelegate doubleTapAtIndexPath:indexPath cell:tapCell];
    }
}

- (NSIndexPath *)cellIndexPathForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    UIView * view = gestureRecognizer.view;
    if(![view isKindOfClass:[UITableView class]]) {
        return nil;
    }
    
    CGPoint point = [gestureRecognizer locationInView:view];
    NSIndexPath * indexPath = [self indexPathForRowAtPoint:point];
    return indexPath;
}

- (void)setMenuShow:(BOOL)show atIndexPath:indexPath cell:(UITableViewCell *)cell {
    
    if(show) {
        if(_showingIndexPath) {
            UITableViewCell * editingCell = [self cellForRowAtIndexPath:_showingIndexPath];
            [self setMenuShow:NO atIndexPath:_showingIndexPath cell:editingCell];
        }
        [self addGestureRecognizer:_tapGestureRecognizer];
    } else {
        [self removeGestureRecognizer:_tapGestureRecognizer];
    }
    
    if(show) {
        _showingIndexPath = indexPath;
    } else {
        _showingIndexPath = nil;
    }
    
    if (self.richDelegate && [self.richDelegate respondsToSelector:@selector(swipeNeedShowMenu:atIndexPath:cell:)]) {
        [self.richDelegate swipeNeedShowMenu:show atIndexPath:indexPath cell:cell];
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO; // Recognizers of this class are the first priority
}

///moving>>>>

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	BOOL shouldBegin = YES;
	
	if ([gestureRecognizer isEqual:self.movingGestureRecognizer])
	{
        CGPoint touchPoint = [gestureRecognizer locationInView:self];
        NSIndexPath *touchedIndexPath = [self indexPathForRowAtPoint:touchPoint];
        shouldBegin = [self isValidIndexPath:touchedIndexPath];
        
		if (shouldBegin && [self.richDataSource respondsToSelector:@selector(moveTableView:canMoveRowAtIndexPath:)]) {
			shouldBegin = [self.richDataSource moveTableView:self canMoveRowAtIndexPath:touchedIndexPath];
		}
	}
	
	return shouldBegin;
}


- (void)handleLongPress:(UILongPressGestureRecognizer *)gestureRecognizer
{
    NSLog(@".");
	switch (gestureRecognizer.state)
	{
		case UIGestureRecognizerStateBegan:
		{
			CGPoint touchPoint = [gestureRecognizer locationInView:self];
            [self prepareForMovingRowAtTouchPoint:touchPoint];
			
			break;
		}
			
		case UIGestureRecognizerStateChanged:
		{
			CGPoint touchPoint = [gestureRecognizer locationInView:self];
            [self moveSnapShotToLocation:touchPoint];
			[self maybeAutoscroll];
			
			if (![self isAutoscrolling]) {
				[self moveRowToLocation:touchPoint];
			}
			
			break;
		}
			
		case UIGestureRecognizerStateEnded:
		{
            [self finishMovingRow];
			break;
		}
			
		default:
		{
            [self cancelMovingRowIfNeeded];
			break;
		}
	}
}


- (void)prepareForMovingRowAtTouchPoint:(CGPoint)touchPoint
{
    NSIndexPath *touchedIndexPath = [self indexPathForRowAtPoint:touchPoint];
    self.initialIndexPathForMovingRow = touchedIndexPath;
    self.movingIndexPath = touchedIndexPath;
    
    self.snapShotOfMovingCell = [self snapShotFromRowAtMovingIndexPath];
    [self addSubview:self.snapShotOfMovingCell];
    
    self.touchOffset = CGPointMake(self.snapShotOfMovingCell.center.x - touchPoint.x, self.snapShotOfMovingCell.center.y - touchPoint.y);
    [self prepareAutoscrollForSnapShot];
    
    if ([self.richDelegate respondsToSelector:@selector(moveTableView:willMoveRowAtIndexPath:)]) {
        [self.richDelegate moveTableView:self willMoveRowAtIndexPath:self.movingIndexPath];
    }
}


- (void)finishMovingRow
{
    [self stopAutoscrolling];
    
    CGRect finalFrame = [self rectForRowAtIndexPath:self.movingIndexPath];
    if (CGRectEqualToRect(finalFrame, CGRectZero)) {
        return;
    }
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         
                         self.snapShotOfMovingCell.frame = finalFrame;
                         self.snapShotOfMovingCell.alpha = 1.0;
                         
                     }
                     completion:^(BOOL finished) {
                         
                         if (finished)
                         {
                             [self resetSnapShot];
                             
                             if ([self.initialIndexPathForMovingRow compare:self.movingIndexPath] != NSOrderedSame) {
                                 [self.richDataSource moveTableView:self moveRowFromIndexPath:self.initialIndexPathForMovingRow toIndexPath:self.movingIndexPath];
                             }
                             
                             [self resetMovingRow];
                         }
                         
                     }];
}


- (void)cancelMovingRowIfNeeded
{
    if (self.movingIndexPath != nil)
    {
        [self stopAutoscrolling];
        [self resetSnapShot];
        [self resetMovingRow];
    }
}


- (void)resetMovingRow
{
    NSIndexPath *movingIndexPath = [self.movingIndexPath copy];
    self.movingIndexPath = nil;
    self.initialIndexPathForMovingRow = nil;
    [self reloadRowsAtIndexPaths:@[movingIndexPath] withRowAnimation:UITableViewRowAnimationNone];
}


- (void)moveRowToLocation:(CGPoint)location
{
	NSIndexPath *newIndexPath = [self indexPathForRowAtPoint:location];
    if (![self canMoveToIndexPath:newIndexPath]) {
        return;
    }
    
    [self beginUpdates];
    [self deleteRowsAtIndexPaths:@[self.movingIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    self.movingIndexPath = newIndexPath;
    [self endUpdates];
}


- (BOOL)canMoveToIndexPath:(NSIndexPath *)indexPath
{
    if (![self isValidIndexPath:indexPath]) {
        return NO;
    }
    
    if ([indexPath compare:self.movingIndexPath] == NSOrderedSame) {
        return NO;
    }
    
    if ([self.richDelegate respondsToSelector:@selector(moveTableView:targetIndexPathForMoveFromRowAtIndexPath:toProposedIndexPath:)])
    {
        NSIndexPath *proposedDestinationIndexPath = [self.richDelegate moveTableView:self targetIndexPathForMoveFromRowAtIndexPath:self.movingIndexPath toProposedIndexPath:indexPath];
        return ([indexPath compare:proposedDestinationIndexPath] == NSOrderedSame);
    }
    
    return YES;
}



#pragma mark - Index path utilities

- (BOOL)indexPathIsMovingIndexPath:(NSIndexPath *)indexPath
{
	return ([indexPath compare:self.movingIndexPath] == NSOrderedSame);
}


- (BOOL)isValidIndexPath:(NSIndexPath *)indexPath
{
    return (indexPath != nil && indexPath.section != NSNotFound && indexPath.row != NSNotFound);
}


- (NSIndexPath *)adaptedIndexPathForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.movingIndexPath == nil) {
        return indexPath;
    }
    
    CGFloat adaptedRow = NSNotFound;
    NSInteger movingRowOffset = 1;
    
    // It's the moving row so return the initial index path
    if ([indexPath compare:self.movingIndexPath] == NSOrderedSame)
    {
        indexPath = self.initialIndexPathForMovingRow;
    }
    // Moving row is still in it's inital section
    else if (self.movingIndexPath.section == self.initialIndexPathForMovingRow.section)
    {
        // 1. Index path comes after initial row or is at initial row
        // 2. Index path comes before moving row
        if (indexPath.row >= self.initialIndexPathForMovingRow.row && indexPath.row < self.movingIndexPath.row)
        {
            adaptedRow = indexPath.row + movingRowOffset;
        }
        // 1. Index path comes before initial row or is at initial row
        // 2. Index path comes after moving row
        else if (indexPath.row <= self.initialIndexPathForMovingRow.row && indexPath.row > self.movingIndexPath.row)
        {
            adaptedRow = indexPath.row - movingRowOffset;
        }
    }
    // Moving row is no longer in it's inital section
    else if (self.movingIndexPath.section != self.initialIndexPathForMovingRow.section)
    {
        // 1. Index path is in the moving rows initial section
        // 2. Index path comes after initial row or is at initial row
        if (indexPath.section == self.initialIndexPathForMovingRow.section && indexPath.row >= self.initialIndexPathForMovingRow.row)
        {
            adaptedRow = indexPath.row + movingRowOffset;
        }
        // 1. Index path is in the moving rows current section
        // 2. Index path comes before moving row
        else if (indexPath.section == self.movingIndexPath.section && indexPath.row > self.movingIndexPath.row)
        {
            adaptedRow = indexPath.row - movingRowOffset;
        }
    }
    
    // We finally need to create an adapted index path
    if (adaptedRow != NSNotFound) {
        indexPath = [NSIndexPath indexPathForRow:adaptedRow inSection:indexPath.section];
    }
    
	return indexPath;
}



#pragma mark - Snap shot

- (UIView *)snapShotFromRowAtMovingIndexPath
{
    CEditBaseItemView *touchedCell = (CEditBaseItemView *)[self cellForRowAtIndexPath:self.movingIndexPath];
    touchedCell.selected = NO;
    touchedCell.highlighted = NO;
    
    UIView *snapShot = [touchedCell snapshotViewAfterScreenUpdates:YES];
    snapShot.frame = touchedCell.frame;
    snapShot.alpha = 0.95;
    snapShot.layer.shadowOpacity = 0.7;
    snapShot.layer.shadowRadius = 3.0;
    snapShot.layer.shadowOffset = CGSizeZero;
    snapShot.layer.shadowPath = [[UIBezierPath bezierPathWithRect:snapShot.layer.bounds] CGPath];
    
    [touchedCell prepareForMove];
    
    return snapShot;
}


- (void)moveSnapShotToLocation:(CGPoint)touchPoint
{
    CGPoint currentCenter = self.snapShotOfMovingCell.center;
    self.snapShotOfMovingCell.center = CGPointMake(currentCenter.x, touchPoint.y + self.touchOffset.y);
}


- (void)resetSnapShot
{
    [self.snapShotOfMovingCell removeFromSuperview];
    self.snapShotOfMovingCell = nil;
}



#pragma mark - Autoscrolling

- (void)prepareAutoscrollForSnapShot
{
    self.autoscrollThreshold = CGRectGetHeight(self.snapShotOfMovingCell.frame) * 0.6;
    self.autoscrollDistance = 0;
}


- (void)maybeAutoscroll
{
    [self determineAutoscrollDistanceForSnapShot];
    
    if (self.autoscrollDistance == 0)
	{
        [self.autoscrollTimer invalidate];
        self.autoscrollTimer = nil;
    }
    else if (self.autoscrollTimer == nil)
	{
        self.autoscrollTimer = [NSTimer scheduledTimerWithTimeInterval:(1.0 / 60.0) target:self selector:@selector(autoscrollTimerFired:) userInfo:nil repeats:YES];
    }
}


- (void)determineAutoscrollDistanceForSnapShot
{
    self.autoscrollDistance = 0;
    
	// Check for autoscrolling
	// 1. The content size is bigger than the frame's
	// 2. The snap shot is still inside the table view's bounds
    if ([self canScroll] && CGRectIntersectsRect(self.snapShotOfMovingCell.frame, self.bounds))
	{
		CGPoint touchLocation = [self.movingGestureRecognizer locationInView:self];
		touchLocation.y += self.touchOffset.y;
        
        CGFloat distanceToTopEdge = touchLocation.y - CGRectGetMinY(self.bounds);
        CGFloat distanceToBottomEdge = CGRectGetMaxY(self.bounds) - touchLocation.y;
        
        if (distanceToTopEdge < self.autoscrollThreshold)
		{
            self.autoscrollDistance = [self autoscrollDistanceForProximityToEdge:distanceToTopEdge] * -1;
        }
		else if (distanceToBottomEdge < self.autoscrollThreshold)
		{
            self.autoscrollDistance = [self autoscrollDistanceForProximityToEdge:distanceToBottomEdge];
        }
    }
}


- (CGFloat)autoscrollDistanceForProximityToEdge:(CGFloat)proximity
{
    return ceilf((self.autoscrollThreshold - proximity) / 5.0);
}


- (void)autoscrollTimerFired:(NSTimer *)timer
{
    [self legalizeAutoscrollDistance];
    
    CGPoint contentOffset = self.contentOffset;
    contentOffset.y += self.autoscrollDistance;
    self.contentOffset = contentOffset;
    
    CGRect frame = self.snapShotOfMovingCell.frame;
    frame.origin.y += self.autoscrollDistance;
    self.snapShotOfMovingCell.frame = frame;
	
	CGPoint touchLocation = [self.movingGestureRecognizer locationInView:self];
	[self moveRowToLocation:touchLocation];
}


- (void)legalizeAutoscrollDistance
{
    CGFloat minimumLegalDistance = self.contentOffset.y * -1.0;
    CGFloat maximumLegalDistance = self.contentSize.height - (CGRectGetHeight(self.frame) + self.contentOffset.y);
    self.autoscrollDistance = MAX(self.autoscrollDistance, minimumLegalDistance);
    self.autoscrollDistance = MIN(self.autoscrollDistance, maximumLegalDistance);
}


- (void)stopAutoscrolling
{
    self.autoscrollDistance = 0.0;
	[self.autoscrollTimer invalidate];
	self.autoscrollTimer = nil;
}


- (BOOL)isAutoscrolling
{
    return (self.autoscrollDistance != 0);
}


- (BOOL)canScroll
{
    return (CGRectGetHeight(self.frame) < self.contentSize.height);
}

@end
