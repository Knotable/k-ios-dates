//
//  CEditKeynoteItemView.m
//  RevealControllerProject
//
//  Created by backup on 13-10-11.
//
//

#import "CEditKeynoteItemView.h"

#import "CUtil.h"

#import "CEditInfoBar.h"
#import "CKeyNoteItem.h"
#import "DesignManager.h"

#import "LCNoteTextView.h"
#import "ImageCollectionViewCell.h"
#import <QuartzCore/CAAnimation.h>

#define kKeyNoteBtnH 52

@interface CEditKeynoteItemView ()<UITextViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, retain) UITextView* textView;
//@property (nonatomic, strong) CEditInfoBar* infoBar;
//@property (nonatomic, strong) NSMutableArray *rightArray;
@property (nonatomic, strong) UIButton *addBtn;
@property (nonatomic, strong) UIButton *dateBtn;
@property (nonatomic, strong) UIButton *listBtn;
@property (nonatomic, strong) UIButton *lockBtn;
@property (nonatomic, assign) NSUInteger numberOfBlinks;

@end
@implementation CEditKeynoteItemView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
#if NEW_DESIGN
#else
        self.titleBarHeight = 0;
#endif
        self.btnBarHeight = kKeyNoteBtnH;
        self.isLocked = NO;
        
        self.isButtonsHidden = YES;
    }
    return self;
    
}

- (void)updateConstraints
{
    if (self.bounds.size.height<=0.0001f) {
        return [super updateConstraints];
    }
    if (self.infoBarHeight>0) {
        self.infoBar.hidden = NO;
        [self.infoBar mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(       @(self.infoBarHeight));
            if (self.addBtn) {
                if (self.addBtn.hidden == NO) {
                    make.bottom.equalTo(self.bgView.mas_bottom).offset(-self.vGap);
                } else {//self.vGap+kKeyNoteBtnH
                    make.bottom.equalTo(self.bgView.mas_bottom).offset(-self.vGap);
                }
            } else {
                make.bottom.equalTo(self.bgView.mas_bottom).offset(0);
            }
            make.left.equalTo(         @(self.hGap));
            make.right.equalTo(        @(-(self.hGap)));
        }];
    } else {
        self.infoBar.hidden = YES;
    }
	
	// left button
    [self.addBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@33);
		make.width.equalTo(@33);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
		make.right.equalTo(self.dateBtn.mas_left).offset(-20);
    }];
	
	// middle button
	[self.dateBtn mas_updateConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@33);
		make.width.equalTo(@33);
		make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
		make.centerX.equalTo(self.contentView).offset(-26);
	}];
	
	// right button
	[self.listBtn mas_updateConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@33);
		make.width.equalTo(@33);
		make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
		make.left.equalTo(_dateBtn.mas_right).offset(20);
	}];
    
	// right button
	[self.lockBtn mas_makeConstraints:^(MASConstraintMaker *make) {
		make.height.equalTo(@33);
		make.width.equalTo(@33);
		make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
		make.left.equalTo(_listBtn.mas_right).offset(20);
	}];
    
    [super updateConstraints];
    
    [self.bgView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
    }];

    if (self.gridViewHeight>0 ) {
        self.imageGridView.hidden = NO;
        [self.imageGridView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(       @(self.gridViewHeight));
            make.bottom.equalTo(self.bgView.mas_bottom).offset(-(self.infoBarHeight+self.vGap));
            make.left.equalTo(self.bgView.mas_left).offset(10);
            make.right.equalTo(self.bgView.mas_right).offset(-10);
        }];
    } else {
        self.imageGridView.hidden = YES;
    }

}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat h = self.bounds.size.height-self.tGap - 3*self.vGap - self.infoBarHeight -self.btnBarHeight-self.gridViewHeight;
    if (self.showMore) {
        h -= kDefaultMoreBtnH;
    }
	
    [self.textView setFrame:CGRectMake(self.hGap + 4.0, self.tGap+self.vGap, self.bounds.size.width-2*(self.hGap + 4.0), h)];
    [self.addBtn setFrame:CGRectMake(self.hGap, self.bounds.size.height - self.btnBarHeight, self.bounds.size.width-2*self.hGap, 22)];
    [self.dateBtn setFrame:CGRectMake(self.hGap, self.bounds.size.height - self.btnBarHeight, self.bounds.size.width-2*self.hGap, 22)];
    [self.listBtn setFrame:CGRectMake(self.hGap, self.bounds.size.height - self.btnBarHeight, self.bounds.size.width-2*self.hGap, 22)];
    [self.lockBtn setFrame:CGRectMake(self.hGap, self.bounds.size.height - self.btnBarHeight, self.bounds.size.width-2*self.hGap, 22)];

}

- (BOOL)canDraggable:(CGPoint)point
{
    return NO;
}

- (void)startFlashEffect{};

- (void)flashingBorderWithTarget:(UIView *)target
{
	CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"shadowOpacity"];
	anim.duration = 0.5f;
	anim.fromValue = @0.0f;
	anim.toValue = @1.0f;
	anim.autoreverses = YES;
	anim.repeatCount = 3;
	[target.layer addAnimation:anim forKey:@"shadowOpacity"];
}

-(void) setItemData:(CItem*) itemData
{
    [super setItemData:itemData];
    CKeyNoteItem *iData = (CKeyNoteItem *)itemData;
    self.isLocked = iData.isLocked;
    if (!self.isLocked) {
        if (!self.isButtonsHidden)
        {
            if (!_addBtn) {
                _addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                _addBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
                [_addBtn setImage:[UIImage imageNamed:@"regular-knote"] forState:UIControlStateNormal];
                [_addBtn addTarget:self action:@selector(addBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:self.addBtn];
            }
            
            if (!_dateBtn)
            {
                _dateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                _dateBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
                [_dateBtn setImage:[UIImage imageNamed:@"deadline-knote"] forState:UIControlStateNormal];
                [_dateBtn addTarget:self action:@selector(dateBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:self.dateBtn];
            }
            
            if (!_listBtn)
            {
                _listBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                _listBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
                [_listBtn setImage:[UIImage imageNamed:@"poll-knote"] forState:UIControlStateNormal];
                [_listBtn addTarget:self action:@selector(listBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:self.listBtn];
            }
            
            if (!_lockBtn)
            {
                _lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                _lockBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
                [_lockBtn setImage:[UIImage imageNamed:@"lock-knote"] forState:UIControlStateNormal];
                [_lockBtn addTarget:self action:@selector(lockBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:self.lockBtn];
            }
            
            if (_addBtn || _dateBtn || _listBtn || _lockBtn)
            {

            }
            
            self.addBtn.hidden = NO;
            self.dateBtn.hidden = NO;
            self.listBtn.hidden = NO;
            self.lockBtn.hidden = NO;
            self.btnBarHeight = kKeyNoteBtnH;
        }
        else
        {
            self.addBtn.hidden = YES;
            self.dateBtn.hidden = YES;
            self.listBtn.hidden = YES;
            self.lockBtn.hidden = YES;
            self.btnBarHeight = 0;
        }
    } else {
        self.addBtn.hidden = YES;
		self.dateBtn.hidden = YES;
		self.listBtn.hidden = YES;
        self.lockBtn.hidden = YES;
        self.btnBarHeight = 0;
    }

    if (!itemData.body || [itemData.body length]==0)
    {
        self.textView.hidden = YES;
        self.textView = nil;
#if NEW_DESIGN
#else
        self.titleBarHeight = 0;
#endif    
    }
    else
    {
        self.bgView.hidden = NO;
        
#if NEW_DESIGN
#else
        self.titleBarHeight = kDefalutTitleBarH;
#endif
        if (!_textView) {
            self.textView = [[UITextView alloc]init];
            _textView.textColor = [DesignManager knoteBodyTextColor];
            _textView.font =  [DesignManager knoteBodyFont];
            _textView.delegate = self;
            _textView.backgroundColor = [UIColor clearColor];
            _textView.editable = NO;
            _textView.userInteractionEnabled = NO;
            [self.contentView addSubview:_textView];
        }
        [_textView setText:itemData.body];
        self.textView.hidden = NO;
    }
    if (iData.files && iData.files.count > 0) {
        NSInteger num = ceilf(([itemData.files count]+1)/5.0);
        self.gridViewHeight = num*kGridViewH;
        if (!self.imageGridView) {
            UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
            flow.minimumLineSpacing = 2;
            flow.minimumInteritemSpacing = 2;
            [flow setScrollDirection:UICollectionViewScrollDirectionVertical];
            self.imageGridView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
            self.imageGridView.dataSource = self;
            self.imageGridView.delegate = self;
            self.imageGridView.backgroundColor = [UIColor clearColor];
            self.imageGridView.userInteractionEnabled = YES;
            [self.contentView addSubview:self.imageGridView ];
            [self.contentView bringSubviewToFront:self.imageGridView];
            [self.imageGridView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        }
        [self.imageGridView reloadData];
    } else {
        self.gridViewHeight = 0;
    }
    self.showMore = itemData.needShowMoreButton;
    if (self.showMore) {
        if (!self.showMoreButton) {
            self.showMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [DesignManager configureMoreButton:self.showMoreButton];

            [self.showMoreButton addTarget:self action:@selector(moreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:self.showMoreButton];
            [self.contentView bringSubviewToFront:self.showMoreButton];
            [self.showMoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(@(60));
                make.height.equalTo(@(kDefaultMoreBtnH));
                make.top.equalTo(self.textView.mas_bottom).offset(0);
                make.right.equalTo(self.textView.mas_right).offset(0);
            }];
        }
    } else {
        if (self.showMoreButton && [self.showMoreButton superview]) {
            [self.showMoreButton removeFromSuperview];
            self.showMoreButton = nil;
        }
    }

}

-(CItem*) getItemData
{
    return [super getItemData];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    CItem *item = [self getItemData];
    item.body = textView.text;
}

- (BOOL)becomeFirstResponder
{
    return [_textView becomeFirstResponder];
}

-(BOOL)isFirstResponder
{
    BOOL flag = [_textView isFirstResponder];
    return flag;
}
-(BOOL)resignFirstResponder
{
    BOOL flag = [_textView resignFirstResponder];
    return flag;
}

#pragma mark - Button methods

-(void)addBtnClicked:(id)sender
{
	NSLog( @"%s [Line %d]" , __FUNCTION__ , __LINE__ );
    if (self.baseItemDelegate && [self.baseItemDelegate respondsToSelector:@selector(addNewItem:)]) {
        [self.baseItemDelegate addNewItem:C_KNOTE];
    }
}

- (void)dateBtnClicked:(id)sender
{
    if (self.baseItemDelegate && [self.baseItemDelegate respondsToSelector:@selector(addNewItem:)]) {
        [self.baseItemDelegate addNewItem:C_DATE];
    }
}

- (void)listBtnClicked:(id)sender
{
    if (self.baseItemDelegate && [self.baseItemDelegate respondsToSelector:@selector(addNewItem:)]) {
        [self.baseItemDelegate addNewItem:C_LIST];
    }
}

- (void)lockBtnClicked:(id)sender
{
    if (self.baseItemDelegate && [self.baseItemDelegate respondsToSelector:@selector(addNewItem:)]) {
        [self.baseItemDelegate addNewItem:C_LOCK];
    }

}

#pragma mark -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
}

#pragma mark -
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    CGPoint tapPoint = [gestureRecognizer locationInView:self.addBtn];
    NSLog(@"%@",NSStringFromCGPoint(tapPoint));
    if (!CGRectContainsPoint(self.addBtn.bounds, tapPoint)) {
        return NO;
    } else {
        tapPoint = [gestureRecognizer locationInView:self.imageGridView];
        if (!CGRectContainsPoint(self.imageGridView.bounds, tapPoint)) {
            return NO;
        } else {
            return YES;
        };
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    CGPoint tapPoint = [touch locationInView:self.addBtn];
    NSLog(@"%@",NSStringFromCGPoint(tapPoint));
    if (CGRectContainsPoint(self.addBtn.bounds, tapPoint)) {
        return NO;
    } else {
        tapPoint = [touch locationInView:self.imageGridView];
        if (CGRectContainsPoint(self.imageGridView.bounds, tapPoint)) {
            return NO;
        } else {
            return YES;
        }
    }
    return YES;
}


@end
