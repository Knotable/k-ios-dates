//
//  RichTableView.h
//  Knotable
//
//  Created by backup on 14-3-25.
//
//

#import <UIKit/UIKit.h>
#import "BVReorderTableView.h"

@class RichTableView;

@protocol RichTableViewDelegate <NSObject,UITableViewDelegate>
@required
- (void)swipeNeedShowMenu:(BOOL)show atIndexPath:indexPath cell:(UITableViewCell *)cell;
- (void)doubleTapAtIndexPath:indexPath cell:(UITableViewCell *)cell;
@optional

/**
 * Asks the delegate to return a new index path to retarget a proposed move of a row.
 * @param tableView                    The table-view object requesting this information.
 * @param sourceIndexPath              An index-path object identifying the original location of a row (in its section) that is being dragged.
 * @param proposedDestinationIndexPath An index-path object identifying the currently proposed destination of the row being dragged.
 * @return An index-path object locating the desired row destination for the move operation. Return proposedDestinationIndexPath if that location is suitable.
 */
- (NSIndexPath *)moveTableView:(RichTableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath;

/**
 * Tells the delegate that a specified row is about to be moved.
 * @param tableView A table-view object informing the delegate about the impending move.
 * @param indexPath An index path locating the row in tableView.
 */
- (void)moveTableView:(RichTableView *)tableView willMoveRowAtIndexPath:(NSIndexPath *)indexPath;
@end
/**
 * The FMMoveTableViewDataSource protocol is adopted by an object that mediates the application’s data model for a FMMoveTableView object. The data source provides the table-view object with the information it needs to move cells within a table view.
 */
@protocol RichTableViewDataSource <NSObject, UITableViewDataSource>

/**
 * Tells the data source to move a row at a specific location in the table view to another location.
 * @param tableView     The table-view object requesting this action.
 * @param fromIndexPath An index path locating the row to be moved in tableView.
 * @param toIndexPath   An index path locating the row in tableView that is the destination of the move.
 */
- (void)moveTableView:(RichTableView *)tableView moveRowFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@optional

/**
 * Asks the data source whether a given row can be moved to another location in the table view.
 * @param tableView The table-view object requesting this information.
 * @param indexPath An index path locating a row in tableView.
 * @return YES if the row can be moved; otherwise NO.
 */
- (BOOL)moveTableView:(RichTableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface RichTableView : BVReorderTableView<UIGestureRecognizerDelegate>
/**
 * The object that acts as the data source of the receiving table view.
 */
@property (nonatomic, weak) id <RichTableViewDataSource> richDataSource;

/**
 * The object that acts as the delegate of the receiving table view.
 */
@property (nonatomic, weak) id <RichTableViewDelegate> richDelegate;

/**
 * The current index path of the row that's being moved.
 */
@property (nonatomic, strong) NSIndexPath *movingIndexPath;

/**
 * The initial index path of the row that's being moved.
 */
@property (nonatomic, strong) NSIndexPath *initialIndexPathForMovingRow;

/**
 * Returns a boolean value that indicates whether a given index path is equal to the index path of the row that's being moved.
 * @param indexPath indexPath An index path to compare.
 * @return YES if indexPath is equal; otherwise NO.
 */
- (BOOL)indexPathIsMovingIndexPath:(NSIndexPath *)indexPath;

/**
 * Returns an adapted index path for a given index path to access a data source when a cell is being moved.
 * @param indexPath An index path to compare.
 * @return An adapted index path for indexPath.
 * @discussion The data source is in a dirty state when moving a row and is only being updated after the user releases the moving row.
 */
- (NSIndexPath *)adaptedIndexPathForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)tapped:(UIGestureRecognizer *)gestureRecognizer;

@end
