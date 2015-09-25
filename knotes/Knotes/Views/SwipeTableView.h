//
//  SwipeTableView.h
//  Knotable
//
//  Created by backup on 13-12-26.
//
//

#import <UIKit/UIKit.h>
@protocol SwipeTableViewDelegate <NSObject>

@required
- (void)setEditing:(BOOL)editing atIndexPath:indexPath cell:(UITableViewCell *)cell;

@end

@interface SwipeTableView : UITableView <UIGestureRecognizerDelegate>

@property (weak, nonatomic) id<SwipeTableViewDelegate> swipeDelegate;
@property (nonatomic)BOOL isReordering;
@property (nonatomic)BOOL isReorderingAll;
@property (nonatomic,assign) BOOL forceUpdateMinHeight;//default is NO
@property (nonatomic,assign) CGFloat offsetHeight; //default is 82.0f
- (void)tapped:(UIGestureRecognizer *)gestureRecognizer;

@end