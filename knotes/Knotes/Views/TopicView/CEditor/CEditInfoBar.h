//
//  CEditInfoBar.h
//  RevealControllerProject
//
//  Created by backup on 13-10-11.
//
//

#import <UIKit/UIKit.h>
#import "BI_GridFrame.h"
#import "BI_GridViewCell.h"
#import "BI_GridView.h"
#define kInfoType @"InfoType"
#define KInfo @"Info"
#define kBgcolor @"bgcolor"
#define kContactId @"contact_id"
typedef enum _infoType
{
    kInfoString,
    kInfoIcon,
    kInfoIconUsername,
}infoType;
@class CEditInfoBar;
@protocol CEditInfoBarDelegate <NSObject>

- (NSUInteger)numOfCellsInCandidateBar:(CEditInfoBar *)candBar;
- (CGSize)candidateBar:(CEditInfoBar *)candBar sizeOfCellAtIndex:(NSUInteger)index;
- (BI_GridViewCell *)candidateBar:(CEditInfoBar *)candBar cellForFrame:(BI_GridFrame *)frame;
@optional
- (void)candidateBar:(CEditInfoBar *)candBar willLoadItemAtIndex:(NSUInteger)index;
- (void)candidateBar:(CEditInfoBar *)candBar didLoadItemAtIndex:(NSUInteger)index;
- (void)candidateBar:(CEditInfoBar *)candBar didSelectCellAtIndex:(NSUInteger)index;
- (BOOL)candidateBar:(CEditInfoBar *)candBar willLongPressCellAtIndex:(NSUInteger)index;
- (void)candidateBar:(CEditInfoBar *)candBar didLongPressCellAtIndex:(NSUInteger)index;


@end
@interface CEditInfoBar : UIView{
    struct
	{
        unsigned touchBegan:1;
        unsigned delegateWillLoadItemAtIndex:1;
        unsigned delegateDidLoadItemAtIndex:1;
		unsigned delegateDidSelectCell:1;
		unsigned delegateWillLongPressCell:1;
        unsigned delegateDidLongPressCell:1;
		unsigned __RESERVERED__:23;
	}flags_;
    
    
    CGFloat                     minY_;
    CGFloat                     maxY_;
    CGPoint                     startPoint_; //开始移动的点击点
    


}
@property (nonatomic, strong) UIScrollView *contentView;

@property (nonatomic, strong) id <CEditInfoBarDelegate>delegate;


@property (nonatomic, readonly) CGFloat minY;
@property (nonatomic, readonly) CGFloat maxY;
@property (nonatomic, readonly) CGRect  inputRect;
@property (nonatomic, readonly) CGRect  barRect;
@property (nonatomic, strong) UIView            *backView;   //候选条背景
@property (nonatomic, strong) BI_GridView         *candView;   //候选条内容
@property (nonatomic, strong) UIButton                   *prePage;
@property (nonatomic, strong) UIButton                   *nextPage;
@property (nonatomic, assign) BOOL showMore;
@property (nonatomic, strong) UILabel *indicateLabel;
@property (nonatomic, assign) NSInteger style;//default 0;
- (void)initView;

- (void)reloadData;
- (void)removeCachedCells;
- (void)deselectCellAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (BI_GridViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (BI_GridViewCell *)cellAtIndex:(NSUInteger)index;
- (BI_GridFrame *)currentFrame;

- (BOOL)showPrePage;
- (BOOL)showNextPage;
@end
