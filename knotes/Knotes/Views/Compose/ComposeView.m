
//
//  ComposeView.m
//  Knotable
//
//  Created by backup on 14-1-3.
//
//

#import "ComposeView.h"
#import "FileInfo.h"
#import "ImageCollectionViewCell.h"

#define kComposeGridViewH 48

@interface ComposeView ()<
UICollectionViewDataSource,
UICollectionViewDelegate,
UICollectionViewDelegateFlowLayout
>

@end
@implementation ComposeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.bgView = [UIView new];
        
        //self.bgView.backgroundColor = [UIColor lightGrayColor];
        
       // self.backgroundColor = [UIColor purpleColor];
        
        self.bgView.opaque = NO;
        self.titleHeight = 0;
        
        [self addSubview:self.bgView];
        [self sendSubviewToBack:self.bgView];
        
        self.showingKeyboard = NO;
        self.showsImageUploadButton = YES;
        self.showsContactAvatars = NO;

        // Initialization code
    }
    return self;
}
- (void)updateConstraints
{
    [super updateConstraints];
    
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(       @(kVGap+self.titleHeight));
        make.bottom.equalTo(    @(-kVGap));
        make.left.equalTo(      @(kHGap));
        make.right.equalTo(     @(-kHGap));
    }];
}

#pragma mark ComposeProtocol

- (void)setTitlePlaceHold:(NSString *)str
{
}

- (void)setTitleContent:(NSString *)str
{
}

- (void)setCotent:(id)content
{
    NSLog(@"%@", content);
}

- (id)getCotent
{
    return nil;
}

- (NSString *)getTitle
{
    return nil;
}

- (void)addImageInfos:(NSArray *)imageInfoArray
{
    if (!_imageArray)
    {
        self.imageArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    [self.imageArray addObjectsFromArray: imageInfoArray];
    
    NSInteger num = ceilf(([self.imageArray count]+1)/5.0);
    
    self.gridViewHeight = num*kComposeGridViewH+16;
    
    [self.imageGridView reloadData];
    
    [self updateConstraints];
}

- (void)addImageInfo:(id)imageInfo
{
    if (!_imageArray)
    {
        self.imageArray = [[NSMutableArray alloc] initWithCapacity:3];
    }
    
    [self.imageArray addObject:imageInfo];
    
    NSInteger num = ceilf(([self.imageArray count]+1)/5.0);
    
    self.gridViewHeight = num*kComposeGridViewH+16;
    
    [self.imageGridView reloadData];
    [self updateConstraints];
}

- (void)onAddImage:(id)sender
{
}

- (void)setUpCollectionView
{
    UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
    [flow setScrollDirection:UICollectionViewScrollDirectionVertical];
    self.imageGridView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
    self.imageGridView.dataSource = self;
    self.imageGridView.delegate = self;
    self.imageGridView.backgroundColor = [UIColor clearColor];
    self.imageGridView.userInteractionEnabled = YES;
    [self addSubview:self.imageGridView ];
    [self bringSubviewToFront:self.imageGridView];
    
    self.gridViewHeight = kComposeGridViewH+10;
    [self.imageGridView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(self.showsImageUploadButton){
        return [self.imageArray count]+1;
    } else {
        return [self.imageArray count];
    }
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    
    UICollectionReusableView *reusableview = nil;
    
    return reusableview;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.userInteractionEnabled = YES;
    cell.hidden = NO;
    cell.tag = indexPath.row;
    
    UIImage *img = nil;
    
    if ([indexPath row]<[self.imageArray count])
    {
        FileInfo *fInfo = (FileInfo *)[self.imageArray objectAtIndex:[indexPath row]];
        
        img = fInfo.image;
        
        NSLog(@"Image Size : %@", NSStringFromCGSize(img.size));
        NSLog(@"Cell Size : %@", NSStringFromCGSize(cell.bounds.size));
        
        if (img.size.width > cell.bounds.size.width
            || img.size.height > cell.bounds.size.height)
        {
            [cell setShowImage:img withContentMode:UIViewContentModeScaleAspectFit];
        }
        else
        {
            [cell setShowImage:img withContentMode:UIViewContentModeScaleToFill];
        }
        
        cell.info = fInfo;
        fInfo.cell = cell;
        cell.showBoard = YES;
    }
    else
    {
        img = [UIImage imageNamed:@"camera-icon-selected"];
        cell.showBoard = NO;
        [cell setShowImage:img withContentMode:UIViewContentModeCenter];
        cell.info = nil;
    }
    cell.selected = YES;
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
    
}

// called when the user taps on an already-selected item in multi-select mode
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(kComposeGridViewH, kComposeGridViewH);
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
}

- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    if ([indexPath row]>=[self.imageArray count]) {
        [self onAddImage:cell];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
}

- (void)endEditor
{
    
}
@end
