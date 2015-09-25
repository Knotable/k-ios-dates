//
//  CEditHeaderItemView.m
//  RevealControllerProject
//
//  Created by backup on 13-10-11.
//
//

#import "CEditHeaderItemView.h"

#import "Constant.h"
#import "CUtil.h"

#import "GMSolidLayer.h"
#import "DesignManager.h"
#import "ContactsEntity.h"

#import "UIImage+RoundedCorner.h"

@interface CEditHeaderItemView ()<UITextViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UIView *line1;
@property (nonatomic, strong) UIView *line2;

@end

@implementation CEditHeaderItemView

@synthesize processView,processRetainCount,offline;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.line2 = [UIView new];
        self.line2.backgroundColor = [UIColor clearColor];
    
        [self addSubview:self.line2];
        
        [self.line2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.right.equalTo(self);
            make.bottom.equalTo(self).offset(-1);
            make.height.equalTo(@(0.5));
        }];
        
        self.titleLabel = [[UITextView alloc] init];
        
        _titleLabel.backgroundColor = [UIColor clearColor];        
        _titleLabel.textColor = [UIColor darkGrayColor];
        _titleLabel.font =  [UIFont fontWithName:@"HelveticaNeue-Light" size:20.0];

        [self addSubview:_titleLabel];
        
        _titleLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer* doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taped:)];
        doubleTapGesture.numberOfTapsRequired = 1;
        doubleTapGesture.numberOfTouchesRequired = 1;
        doubleTapGesture.cancelsTouchesInView = NO;
        
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        
        flow.minimumLineSpacing = 0;
        flow.minimumInteritemSpacing = 0;
        
        [flow setScrollDirection:UICollectionViewScrollDirectionHorizontal];
        
        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20) collectionViewLayout:flow];
        
        [self addSubview:self.collectionView];
        
        self.collectionView.dataSource = self;
        self.collectionView.delegate = self;
        [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        [self.collectionView setAllowsMultipleSelection:YES];
        self.collectionView.backgroundColor = [DesignManager knoteNavigationBarTintColor];
    }
    
    return self;
    
}

- (void)taped:(UITapGestureRecognizer *)tapGesture
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(titleViewTaped:)]) {
        [self.delegate titleViewTaped:self];
    }
}

- (void)showInfo:(InfoType)type{};
- (void)hiddenInfo{};

-(BOOL)canShowMenu
{
    return NO;
}

-(void)updateConstraints
{
    [super updateConstraints];
    
//    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self).offset(6);
//        make.right.equalTo(self).offset(-6);
//        make.top.equalTo(self).offset(2);
//        CGRect hrect = [CUtil getTextRect:self.titleLabel.text Font:self.titleLabel.font Width:self.bounds.size.width-20];
//        make.height.equalTo(@(hrect.size.height+4));
//    }];
    
    /******************************************************************

    Lin : Will hide title label at this point. Lastly we would decide 
            to use or not continously.
     
    ******************************************************************/
    
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(6);
        make.right.equalTo(self).offset(-6);
        make.top.equalTo(self).offset(0);
        
//        CGRect hrect = [CUtil getTextRect:self.titleLabel.text Font:self.titleLabel.font Width:self.bounds.size.width-20];
        
        // Lin : Set height to 0 to hide title label view.
        
        make.height.equalTo(@(0));
    }];
    
    [self.collectionView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        // Lin - Added to fill User View to Bottome view.   
        
        make.left.equalTo(self).offset(0);
        make.right.equalTo(self).offset(0);
        
        // Lin - Ended
        
        
        make.top.equalTo(self.titleLabel.mas_bottom).offset(1);
        
        make.height.equalTo(@kDefalutCellSize);
        
    }];

}


-(void) setItemData:(CItem*) itemData
{
    self.titleLabel.text = itemData.title;
}

- (void)showProcess
{
    if (!self.processView)
    {
        self.processView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.processRetainCount = 0;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.processView.color = [UIColor whiteColor];
        self.processView.hidesWhenStopped = YES;
        
        [self addSubview:self.processView];
        
        [self.processView setFrame:CGRectMake(self.frame.size.width-self.processView.frame.size.width, 0, self.processView.frame.size.width, self.processView.frame.size.height)];
    });
    
    self.processRetainCount++;
}

- (void)stopProcess
{
    self.processRetainCount--;
    
    if (self.processRetainCount <= 0)
    {
        self.processRetainCount = 0;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.processView stopAnimating];
            [self.processView setHidden:YES];
            [self.processView removeFromSuperview];
            self.processView = nil;
            
        });
    }
}

#pragma mark -
#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger   retCount = -1;
    
    retCount = [self.itemArray count] + 1;
    
    /********************************************************
     retCount = 1 , 2 => There is not any shared participators
     So we need to show Share pad UI
     
     retCount > 2 we would keep original working mode
     ********************************************************/
    
    return retCount;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionReusableView *reusableview = nil;
    
    return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

    cell.backgroundView = [[UIImageView alloc] init];
    
    if (indexPath.row < [self.itemArray count])
    {
        ContactsEntity *entity = self.itemArray[indexPath.row];
        UIImage *image = [entity getImageByUserName];
        image = [image circlePlainImageSize:kDefalutTitleIconH];
        [(UIImageView *)cell.backgroundView setImage:image];
        
        [ContactsEntity getAsyncImage:entity WithBlock:^(id img, BOOL flag) {
            
            if (img)
            {
                if ([cell.backgroundView isKindOfClass:[UIImageView class]])
                {
                    img = [img circlePlainImageSize:kDefalutTitleIconH];
                
                    [(UIImageView *)cell.backgroundView setImage:img];
                }
                else
                {
                    cell.backgroundView = [[UIImageView alloc] init];
                    img = [img circlePlainImageSize:kDefalutTitleIconH];
                    [(UIImageView *)cell.backgroundView setImage:img];
                }
            }
        }];
        cell.backgroundView.layer.borderColor = [UIColor clearColor].CGColor;
        cell.backgroundView.layer.borderWidth = 2;
        cell.backgroundView.layer.cornerRadius = kDefalutCellSize/2;
        cell.backgroundView.clipsToBounds = YES;
    }
    else
    {
        UIImage *addImg = [UIImage imageNamed:@"ios7-plus"];
        [(UIImageView *)cell.backgroundView setImage:addImg];
        [cell.backgroundView setFrame:CGRectMake(8, 8, 30, 30)];
    }
    
    return cell;
}
                          
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kDefalutCellSize, kDefalutCellSize);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    
    [self setCellSelection:cell selected:YES];
    
    if (indexPath.row < [self.itemArray count])
    {
        ContactsEntity *entity = self.itemArray[indexPath.row];
        
        if ([self.delegate respondsToSelector:@selector(headerViewClickeAtContact:)])
        {
            [self.delegate headerViewClickeAtContact:entity];
        }
    }
    else
    {
        if (self.delegate && [self.delegate respondsToSelector:@selector(addButtonClickedWithContactsAlreadyAdded:)])
        {
            [self.delegate addButtonClickedWithContactsAlreadyAdded:self.itemArray];
        }
        else if (self.delegate && [self.delegate respondsToSelector:@selector(addButtonClicked)])
        {
            [self.delegate addButtonClicked];
        }
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    [self setCellSelection:cell selected:NO];
}

- (void) setCellSelection:(UICollectionViewCell *)cell selected:(bool)selected
{
}

- (void) resetSelectedCells
{
    for (UICollectionViewCell *cell in self.collectionView.visibleCells) {
        [self deselectCellForCollectionView:self.collectionView atIndexPath:[self.collectionView indexPathForCell:cell]];
    }
}

- (void) selectCellForCollectionView:(UICollectionView *)collection atIndexPath:(NSIndexPath *)indexPath
{
    [collection selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    [self collectionView:collection didSelectItemAtIndexPath:indexPath];
}

- (void) deselectCellForCollectionView:(UICollectionView *)collection atIndexPath:(NSIndexPath *)indexPath
{
    [collection deselectItemAtIndexPath:indexPath animated:YES];
    [self collectionView:collection didDeselectItemAtIndexPath:indexPath];
}


@end
