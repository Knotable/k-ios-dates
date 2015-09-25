//
//  PostPicturesCell.h
//  Knotable
//
//  Created by Lin
//
//

#import "BaseKnoteCell.h"
#import "PictureBaseKnoteCell.h"

@class CTitleInfoBarDelegate;

@interface PostPicturesCell : UIView <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *imageGridView;
@property (nonatomic, weak) CItem* itemData;
@property (weak, nonatomic) id<CEditBaseItemViewDelegate,CTitleInfoBarDelegate> baseItemDelegate;
@property (nonatomic, strong) UIView *overlayView;

@property (nonatomic, strong) UIImageView *knoteImageView;

@property (nonatomic, strong) UIImageView *selectedImageView;

@property (nonatomic, strong) UIView *knoteImageContainer;
@property (nonatomic, assign) BOOL isExpand;

@end
