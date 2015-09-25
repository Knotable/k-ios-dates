//
//  CEditBaseItemView.h
//  RevealControllerProject
//
//  Created by backup on 13-10-17.
//
//

#import "CItem.h"
#import "CEditInfoBar.h"
#import "COperationBar.h"
#import "GMSolidLayer.h"
#import "GBPathImageView.h"
#import "ThreadConst.h"
#import "CTitleInfoBar.h"
#import "Masonry.h"
#import "UIButton+Extensions.h"
#import "ImageCollectionViewCell.h"
#import "KnotesCellProtocal.h"
#import "SWTableViewCell.h"
#import "MCSwipeTableViewCell.h"
#import "SDImageCache.h"
#if NEW_DESIGN
#import "CLatestReplyView.h"
#endif

#define kTheadLeftGap  52

@class CEditBaseItemView;
@class PicturesCell;

// Lin - Added to implement EnterpriseCell

@class PostPicturesCell;

// Lin - Ended

@protocol CEditBaseItemViewDelegate <NSObject>

@optional

- (void) startedEditingWith:(CEditBaseItemView *)view;
- (void) finishedEditingWith:(CEditBaseItemView *)view;
- (void) wantFullLayout:(UIImageView *)view;
- (void) wantControllerPresented:(UIViewController *)controller;
- (void) wantDocumentControllerPresented:(UIDocumentInteractionController *)documentController;
- (void) wantExpandPicCell:(NSIndexPath *)indexPath;
- (void) addNewItem : (int) type;
- (void) addNewItemFromString:(NSString *)subject;
- (void) addNewItemWithPhoto:(id)object;
- (void) showMoreButtonClicked:(CEditBaseItemView *)view atIndex:(NSUInteger)index;
- (void) listItemModify:(CEditBaseItemView *)view withOptionArray:(NSArray *)array atIndex:(NSUInteger)index withModificationType: (VoteModificationType ) modificationType isRight:(BOOL)isRight;
- (void) CEditItemViewCell:(UITableViewCell *)cell changedLike:(BOOL)edit;
- (void) contextMenuDidShowInCell:(UITableViewCell *)cell;
- (void) expandReplyInCell:(CEditBaseItemView *)cell withContet:(CItem *)item;
- (void) addNewComment:(CEditBaseItemView *)cell withContet:(CItem *)item;
- (void) toggleCommentsListInCell:(CEditBaseItemView *)cell withContent:(CItem *)item;
- (void) hideCommentsListInCell:(CEditBaseItemView *)cell withContent:(CItem *)item;
- (void) MarkedPin:(BOOL)pinned withContet:(CItem *)item forIndexpath:(NSIndexPath*)indexpath;
- (void) tapedCell:(CEditBaseItemView *)cell;
- (void) recoveyKnote:(CEditBaseItemView *)cell;
@end

//@interface CEditBaseItemView : SWTableViewCell<
@interface CEditBaseItemView : MCSwipeTableViewCell<
    KnotableCellProtocal,
    COperationBarDelegate,
    UICollectionViewDataSource,
    UICollectionViewDelegate,
    UICollectionViewDelegateFlowLayout>
{
}
@property (nonatomic, assign) CGFloat hGap;//heng
@property (nonatomic, assign) CGFloat vGap;//shu
@property (nonatomic, assign) CGFloat tGap;//top gap
#if NEW_DESIGN
#else
@property (atomic, assign) CGFloat titleBarHeight;
#endif
@property (atomic, assign) CGFloat titleBarWidth;
#if NEW_DESIGN
@property (nonatomic,strong)CLatestReplyView *replyView;
@property (nonatomic, strong)UIButton        *settingsButton;
@property (nonatomic, strong)UIView          *settingsView;
@property (nonatomic, strong)UIButton        *editButton;
@property (nonatomic, strong)UIButton        *doneButton;
@property (nonatomic, strong)UIButton        *bookMarkButon;
#endif
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, assign) CGFloat btnBarHeight;
@property (nonatomic, assign) CGFloat infoBarHeight;
@property (nonatomic, assign) BOOL needsRelayout;
@property (nonatomic, assign) BOOL showMore;
@property (nonatomic) NSUInteger index;
//@property (weak, nonatomic) id<CEditBaseItemViewDelegate,CTitleInfoBarDelegate,SWTableViewCellDelegate> baseItemDelegate;

#if NEW_DESIGN
@property (weak, nonatomic) id<CEditBaseItemViewDelegate,CTitleInfoBarDelegate,MCSwipeTableViewCellDelegate,CReplyViewDelegate,CReplyFieldDelegate> baseItemDelegate;
#else
@property (weak, nonatomic) id<CEditBaseItemViewDelegate,CTitleInfoBarDelegate,MCSwipeTableViewCellDelegate> baseItemDelegate;
#endif
@property (nonatomic, strong) CTitleInfoBar *titleInfoBar;
@property (nonatomic, strong) UILabel *titleName;
@property (nonatomic, strong) CEditInfoBar *infoBar;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) NSMutableArray *rightArray;
@property (strong, nonatomic) NSMutableArray *likedIds;
@property (nonatomic, strong) UIButton *showMoreButton;
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, strong) UIView *realBackgroundView;
@property (nonatomic, assign) BOOL offline;
//@property (nonatomic, strong) GBPathImageView *userImageView;

// grid view properties
@property (nonatomic, assign) CGFloat gridViewHeight;
@property (nonatomic, retain) UICollectionView *imageGridView;

// thread image view properties
@property (nonatomic, assign) CGFloat threadImageViewHeight;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIButton *pinButton;
@property (nonatomic, strong) UIButton *commentButton;

#if NEW_DESIGN
#else
@property (nonatomic, strong) UILabel   *padTime;
#endif
@property (nonatomic,strong) NSIndexPath *indexpath;

@property (nonatomic,strong) UILabel *numberOfCommentsLabel;

@property (nonatomic, strong) UIView *underLine;
@property (nonatomic, strong) UILabel *commentLabel;

-(void)setCommentButtonImage;
-(void) setItemData:(CItem*) itemData;
-(CItem*) getItemData;
-(void) endEditing;
- (void)showHideSettingsView;

-(void)setOverLay:(BOOL)hidden animate:(BOOL)animate;
- (void)prepareForMove;
- (void)updateViewMode:(BOOL)isExpanded;

@end
