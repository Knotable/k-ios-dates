//
//  CEditHeaderItemView.h
//  RevealControllerProject
//
//  Created by backup on 13-10-11.
//
//

#import "CEditBaseItemView.h"
#import "GBPathImageView.h"
#import "KnotesCellProtocal.h"

#define kDefalutCellSize 48.0f

@class ContactsEntity;
@class CEditHeaderItemView;

@protocol CEditHeaderItemViewDelegate <NSObject>

- (void) titleViewTaped:(CEditHeaderItemView *)view;
- (void) headerViewClickeAtContact:(ContactsEntity *)entity;
- (void) addButtonClicked;
- (void) addButtonClickedWithContactsAlreadyAdded:(NSMutableArray*)itemsArray;

@end

@interface CEditHeaderItemView : UIView<KnotableCellProtocal>

@property (nonatomic, strong) UITextView *titleLabel;
@property (strong, nonatomic) NSMutableArray *itemArray;
@property (strong, nonatomic) UICollectionView *collectionView;
@property (nonatomic, weak) id<CEditHeaderItemViewDelegate>delegate;

@end
