//
//  SwipeTableView.m
//  Knotable
//
//  Created by backup on 13-12-26.
//
//

#import "SwipeTableView.h"

#import <objc/runtime.h>

const static CGFloat kDeleteButtonWidth = 80.f;
const static CGFloat kDeleteButtonHeight = 44.f;

#define screenWidth() (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) ? [[UIScreen mainScreen] bounds].size.width : [[UIScreen mainScreen] bounds].size.height)


const static char * kYFJLeftSwipeDeleteTableViewCellIndexPathKey = "YFJLeftSwipeDeleteTableViewCellIndexPathKey";

@interface UIButton (NSIndexPath)

- (void)setIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPath;

@end

@implementation UIButton (NSIndexPath)

- (void)setIndexPath:(NSIndexPath *)indexPath {
    objc_setAssociatedObject(self, kYFJLeftSwipeDeleteTableViewCellIndexPathKey, indexPath, OBJC_ASSOCIATION_RETAIN);
}

- (NSIndexPath *)indexPath {
    id obj = objc_getAssociatedObject(self, kYFJLeftSwipeDeleteTableViewCellIndexPathKey);
    if([obj isKindOfClass:[NSIndexPath class]]) {
        return (NSIndexPath *)obj;
    }
    return nil;
}

@end

@interface SwipeTableView() {
    
    UISwipeGestureRecognizer * _leftGestureRecognizer;
    UISwipeGestureRecognizer * _rightGestureRecognizer;
    UITapGestureRecognizer * _tapGestureRecognizer;
    
    UIButton * _deleteButton;
    
    NSIndexPath * _editingIndexPath;
}

@end

@implementation SwipeTableView

-(void)setContentSize:(CGSize)contentSize
{
    CGSize size = contentSize;
    if (self.forceUpdateMinHeight)
    {
        if (contentSize.height<(CGRectGetHeight(self.bounds)+_offsetHeight))
        {
            size.height = (CGRectGetHeight(self.bounds)+_offsetHeight);
        }
    }

    [super setContentSize:size];
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    
    if (self)
    {
        _forceUpdateMinHeight = NO;
        _offsetHeight = 82.0f;
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
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.frame = CGRectMake(screenWidth(), 0, kDeleteButtonWidth, kDeleteButtonHeight);
        _deleteButton.backgroundColor = [UIColor redColor];
        _deleteButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [_deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteItem:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:_deleteButton];
        
        [self setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame style:UITableViewStylePlain];
}

- (void)swiped:(UISwipeGestureRecognizer *)gestureRecognizer
{
    NSIndexPath * indexPath = [self cellIndexPathForGestureRecognizer:gestureRecognizer];
    
    if(indexPath == nil)
        return;
    
    if(![self.dataSource tableView:self canEditRowAtIndexPath:indexPath]) {
        return;
    }
    
    if(gestureRecognizer == _rightGestureRecognizer && ![_editingIndexPath isEqual:indexPath]) {
        UITableViewCell * cell = [self cellForRowAtIndexPath:indexPath];
        [self setEditing:YES atIndexPath:indexPath cell:cell];
    } else if (gestureRecognizer == _leftGestureRecognizer && [_editingIndexPath isEqual:indexPath]){
        UITableViewCell * cell = [self cellForRowAtIndexPath:indexPath];
        [self setEditing:NO atIndexPath:indexPath cell:cell];
    }
}

- (void)tapped:(UIGestureRecognizer *)gestureRecognizer
{
    if(_editingIndexPath) {
        UITableViewCell * cell = [self cellForRowAtIndexPath:_editingIndexPath];
        [self setEditing:NO atIndexPath:_editingIndexPath cell:cell];
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

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)setEditing:(BOOL)editing atIndexPath:indexPath cell:(UITableViewCell *)cell {
    
    if(editing) {
        if(_editingIndexPath) {
            UITableViewCell * editingCell = [self cellForRowAtIndexPath:_editingIndexPath];
            [self setEditing:NO atIndexPath:_editingIndexPath cell:editingCell];
        }
        [self addGestureRecognizer:_tapGestureRecognizer];
    } else {
        [self removeGestureRecognizer:_tapGestureRecognizer];
    }
    
    if(editing) {
        _editingIndexPath = indexPath;
    } else {
        _editingIndexPath = nil;
    }
    
    if (self.swipeDelegate && [self.swipeDelegate respondsToSelector:@selector(setEditing:atIndexPath:cell:)]) {
        [self.swipeDelegate setEditing:editing atIndexPath:indexPath cell:cell];
    }
}

#pragma mark - Interaciton
- (void)deleteItem:(id)sender {
    UIButton * deleteButton = (UIButton *)sender;
    NSIndexPath * indexPath = deleteButton.indexPath;
    
    [self.dataSource tableView:self commitEditingStyle:UITableViewCellEditingStyleDelete forRowAtIndexPath:indexPath];
    
    _editingIndexPath = nil;
    
    [UIView animateWithDuration:0.2f animations:^{
        CGRect frame = _deleteButton.frame;
        _deleteButton.frame = (CGRect){frame.origin, frame.size.width, 0};
    } completion:^(BOOL finished) {
        CGRect frame = _deleteButton.frame;
        _deleteButton.frame = (CGRect){screenWidth(), frame.origin.y, frame.size.width, kDeleteButtonHeight};
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO; // Recognizers of this class are the first priority
}

@end

