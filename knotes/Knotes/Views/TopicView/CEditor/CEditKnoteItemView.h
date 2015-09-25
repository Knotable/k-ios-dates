//
//  CEditKnoteItemView.h
//  RevealControllerProject
//
//  Created by backup on 13-10-16.
//
//

#import "CEditBaseItemView.h"
#import "GBPathImageView.h"
#import "FileEntity.h"
#if NEW_DESIGN
#import "CreplyUtils.h"
#endif

@interface CEditKnoteItemView : CEditBaseItemView

@property (weak, nonatomic) id<CEditBaseItemViewDelegate,CTitleInfoBarDelegate> baseItemDelegate;
@property (nonatomic, retain) PostPicturesCell* pictureCellView;
@property(nonatomic,retain)UIImageView *HTMLimgView;
#if NEW_DESIGN
@property(nonatomic,strong)CItem *itmTemp;
#endif
@end
