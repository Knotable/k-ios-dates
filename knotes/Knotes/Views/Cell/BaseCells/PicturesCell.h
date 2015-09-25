//
//  PicturesCell.h
//  Knotable
//
//  Created by wuli on 14-7-11.
//
//

#import "BaseKnoteCell.h"
#import "PictureBaseKnoteCell.h"

@class CTitleInfoBarDelegate;

//CEditBaseItemView

@interface PicturesCell : PictureBaseKnoteCell <KnotableCellProtocal, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
//@interface PicturesCell : BaseKnoteCell <KnotableCellProtocal, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *imageGridView;
@property (nonatomic, weak) CItem* itemData;
@property (weak, nonatomic) id<CEditBaseItemViewDelegate,CTitleInfoBarDelegate> baseItemDelegate;
@property (nonatomic, strong) UIView *overlayView;

@property (nonatomic, strong) UIImageView *knoteImageView;
@property (nonatomic, strong) UIView *knoteImageContainer;
@property (nonatomic, assign) BOOL isExpand;
@property (nonatomic, copy) NSIndexPath *indexPath;

- (void)setMessage:(MessageEntity *)message fileId:(NSString *)fileId showHeaders:(BOOL)showHeaders;
- (void)setMessage:(MessageEntity *)message imageURL:(NSString *)imageURL showHeaders:(BOOL)showHeaders;

@end
