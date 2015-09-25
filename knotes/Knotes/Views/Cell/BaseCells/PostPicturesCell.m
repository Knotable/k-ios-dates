//
//  PostPicturesCell.m
//  Knotable
//
//  Created by Lin
//
//

#import "PostPicturesCell.h"

#import "CUtil.h"
#import "ShowPDFController.h"
#import "CEditInfoItem.h"
#import "ContactsEntity.h"
#import "UIImage+RoundedCorner.h"
#import "RFQuiltLayout.h"
#import "SDImageCache.h"

#import "AFNetworking.h"

#define kMaxPicsCellNum 4

@interface PostPicturesCell()<RFQuiltLayoutDelegate>

@property (nonatomic) NSMutableArray* numbers;
@property (nonatomic) NSMutableArray* numberWidths;
@property (nonatomic) NSMutableArray* numberHeights;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) CGFloat imageSizeFactor;
@property (nonatomic, strong) UIInterpolatingMotionEffect *horMotionEffect;
@property (nonatomic, strong) UIInterpolatingMotionEffect *vertMotionEffect;

@end

@implementation PostPicturesCell

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        RFQuiltLayout* layout = [[RFQuiltLayout alloc] init];
        layout.direction = UICollectionViewScrollDirectionVertical;
        layout.blockPixels = CGSizeMake(44,30);
        layout.delegate = self;
        self.imageGridView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.imageGridView.dataSource = self;
        self.imageGridView.delegate = self;
        self.imageGridView.backgroundColor = [UIColor clearColor];
        self.imageGridView.userInteractionEnabled = YES;
        
        [self.imageGridView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"ImageCollectionViewCell"];
        
        self.knoteImageView = [UIImageView new];
        self.knoteImageContainer = [UIView new];
        
        _knoteImageContainer.clipsToBounds = YES;
        
        [self.knoteImageContainer addSubview:self.knoteImageView];
        
        [self addSubview:self.knoteImageContainer];
        
        // Lin - Marked to check Picture Cell
        
        [self setBackgroundColor:[UIColor clearColor]];
        
        [self.knoteImageContainer setBackgroundColor:[UIColor clearColor]];
        
        
        self.horMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x"
                                                                               type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
        self.vertMotionEffect = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y"
                                                                                type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
        
        CGFloat amplitude = 40.0;
        _horMotionEffect.minimumRelativeValue = @(amplitude);
        _horMotionEffect.maximumRelativeValue = @(-amplitude);
        _vertMotionEffect.minimumRelativeValue = @(amplitude);
        _vertMotionEffect.maximumRelativeValue = @(-amplitude);
        
        self.imageSizeFactor = 1.2;
        
        [self.knoteImageView addMotionEffect:_horMotionEffect];
        [self.knoteImageView addMotionEffect:_vertMotionEffect];
        
        [self addSubview:self.imageGridView ];
        [self bringSubviewToFront:self.imageGridView];
        
        
    }
    return self;
}

-(void)showProcess
{
}

-(void)stopProcess
{
}

- (void)showInfo:(InfoType)type
{
}

-(void)hiddenInfo
{
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    MASAttachKeys(self, _knoteImageView, _knoteImageContainer);
    
    [self mas_makeConstraints:^(MASConstraintMaker *make)
     {
         if (self.isExpand)
         {
             make.height.equalTo(@(84.0*ceil([self.itemData.files count]/2.0)));
         }
         else
         {
             make.height.equalTo(@160.0);
         }
     }];
    
    CGFloat ratio;
    
    if (self.image)
    {
        ratio = self.image.size.height / self.image.size.width;
    }
    else
    {
        ratio = 1.0;
    }
    
    
    [self.knoteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.centerX.equalTo(@0);
        make.centerY.equalTo(@0);
        
        make.width.equalTo(self.knoteImageContainer).multipliedBy(self.imageSizeFactor);
        make.height.equalTo(self.knoteImageView.mas_width).multipliedBy(ratio);
        
    }];
    
    [self.knoteImageContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(self);
        
    }];
    
    [self.imageGridView mas_updateConstraints:^(MASConstraintMaker *make) {
        
        make.left.equalTo(self).offset(kTheadLeftGap-10);
        make.top.equalTo(self);
        make.bottom.equalTo(self);
        make.right.equalTo(self);
        if (CGRectGetHeight(self.bounds)>80) {
            make.height.greaterThanOrEqualTo(@(80));
        }
    }];
}

-(void)setItemData:(CItem *)itemData
{
    _itemData = itemData;
    
    NSInteger count = [itemData.files count];
    NSInteger embeddedCount = [[itemData.userData loadedEmbeddedImages] count];
    
    if (embeddedCount > 0)
    {
        count += embeddedCount;
    }
    
    switch (count)
    {
        case 1:
        {
            self.numberHeights = [@[@(6)]mutableCopy];
            self.numberWidths = [@[@(6)] mutableCopy];
        }
            break;
        case 2:
        {
            self.numberHeights = [@[@(6),@(6)]mutableCopy];
            self.numberWidths = [@[@(3),@(3)] mutableCopy];
        }
            break;
        case 3:
        {
            self.numberHeights = [@[@(6),@(3),@(3)]mutableCopy];
            self.numberWidths = [@[@(3),@(3),@(3)] mutableCopy];
        }
            break;
        case 4:
        {
            self.numberHeights = [@[@(3),@(3),@(3),@(3)]mutableCopy];
            self.numberWidths = [@[@(3),@(3),@(3),@(3)] mutableCopy];
        }
            break;
        default:
        {
            if (self.isExpand) {
                self.numberHeights = [NSMutableArray new];
                self.numberWidths = [NSMutableArray new];
                for (int i = 0; i<count; i++) {
                    [self.numberHeights addObject:@(3)];
                    [self.numberWidths addObject:@(3)];
                }
            } else {
                self.numberHeights = [@[@(3),@(3),@(3),@(3)]mutableCopy];
                self.numberWidths = [@[@(3),@(3),@(3),@(3)] mutableCopy];
            }
            
        }
            break;
    }
}
#pragma mark – RFQuiltLayoutDelegate

- (CGSize) blockSizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat width = 0,height = 0;
    if (indexPath.row < self.numberWidths.count)
    {
        width = [[self.numberWidths objectAtIndex:indexPath.row] floatValue];
    }
    if (indexPath.row < self.numberHeights.count)
    {
        height = [[self.numberHeights objectAtIndex:indexPath.row] floatValue];
    }
    return CGSizeMake(width, height);
}

- (UIEdgeInsets)insetsForItemAtIndexPath:(NSIndexPath *)indexPath {
    return UIEdgeInsetsMake(2, 2, 2, 2);
}

#pragma mark - Collection view delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    CItem *item = (CItem *)[self itemData];
    
    NSInteger count = [[item files] count];
    NSInteger embeddedCount = [[item.userData loadedEmbeddedImages] count];
    
    if (embeddedCount > 0)
    {
        count += embeddedCount;
    }
    
    if (count<=kMaxPicsCellNum)
    {
        NSLog(@"Size---->%@",NSStringFromCGSize(collectionView.contentSize));
        return count;
    }
    
    if (self.isExpand)
    {
        return count;
    }
    else
    {
        return kMaxPicsCellNum;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ImageCollectionViewCell";
    
    CItem *item = (CItem *)[self itemData];
    
    
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.tag = indexPath.item;
    
    cell.imageView.image = Nil;
    
    if (self.isExpand
        || indexPath.item < kMaxPicsCellNum-1
        || [item.files count] == kMaxPicsCellNum)
    {
        if (indexPath.item < [[item files] count])
        {
            FileInfo *fInfo = [[item files] objectAtIndex:indexPath.item];
            
            cell.info = fInfo;
            fInfo.cell = cell;
            fInfo.parentItem = item;
            [cell setShowBoard:NO];
            cell.layer.borderColor = [UIColor clearColor].CGColor;
            cell.layer.borderWidth = 2;
            cell.layer.cornerRadius = 8;
            cell.clipsToBounds = YES;

            if (fInfo.file
                && [fInfo.file.sendFlag charValue] != SendSuc)
            {
                UIImage *img = fInfo.image;
                UIViewContentMode mode = UIViewContentModeScaleAspectFill;
                
                if (img.size.width > cell.bounds.size.width
                    ||img.size.height>cell.bounds.size.height)
                {
                    mode = UIViewContentModeScaleAspectFill;
                }
                [cell setShowImage:img withContentMode:mode];

                
                [cell setShowEntity:fInfo.file];
                
                [fInfo recordSelfToServer];
                
            }
            else
            {
                if (fInfo.file)
                {
                    [cell setShowEntity:fInfo.file];
                }
                else
                {
                    [cell showWaitingView];
                    [fInfo fetchSelfFromServer:item.userData];
                }
            }
        }
        else
        {
            // Loading embeded images
            
            cell.layer.borderColor = [UIColor clearColor].CGColor;
            cell.layer.borderWidth = 2;
            cell.layer.cornerRadius = 8;
            cell.clipsToBounds = YES;
            
            NSInteger index = indexPath.row - [[item files] count];
            
            NSArray *array = [item.userData loadedEmbeddedImages];
            
            UIImage *img = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey: array[index]];
            UIViewContentMode mode = UIViewContentModeScaleAspectFill;
            
            if (img.size.width > cell.bounds.size.width
                ||img.size.height>cell.bounds.size.height)
            {
                mode = UIViewContentModeScaleAspectFill;
            }
            [cell setShowImage:img withContentMode:mode];
        }
        
    }
    else
    {
        [cell setShowBoard:NO];
        
        if (!cell.imageView)
        {
            cell.imageView = [[UIImageView alloc] init];
            [cell.imageView setFrame:cell.bounds];
            cell.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            cell.imageView.contentMode = UIViewContentModeScaleToFill;
            [cell addSubview:cell.imageView];
        }
        
        if (!cell.infoLabel)
        {
            cell.infoLabel = [[UILabel alloc] initWithFrame:cell.bounds];
            cell.infoLabel.textColor = [UIColor whiteColor];
            cell.infoLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16]/*[UIFont fontWithName:@"HelveticaNeue" size:16.0]*/;
            cell.infoLabel.textAlignment = NSTextAlignmentCenter;
            cell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [cell addSubview:cell.infoLabel];
        }
        cell.imageView.image = [UIImage imageNamed:@"icon_more"];
        cell.infoLabel.text = [NSString stringWithFormat:@"more %d+",(int)([item.files count]-kMaxPicsCellNum+1)];
        cell.infoLabel.backgroundColor = [UIColor clearColor];
    }
    
    
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    CItem *item = (CItem *)[self itemData];
    
    NSInteger   postImageCount = [[item files] count];
    NSInteger   embedImageCount = [[item.userData loadedEmbeddedImages] count];
    
    NSInteger   totalImageCount = postImageCount + embedImageCount;
    
    NSLog(@"File Count : %d", totalImageCount);
    NSLog(@"IndexPath.row : %d", indexPath.row);
    NSLog(@"IndexPath.item : %d", indexPath.item);
    NSLog(@"Cell.Tag : %d", cell.tag);
    
    if (indexPath.item < totalImageCount)
    {
        if (self.isExpand || indexPath.item < kMaxPicsCellNum-1)
        {
            if (!cell.downloadSucces)
            {
                FileInfo *fInfo =  [[item files] objectAtIndex:indexPath.item];
                
                if (fInfo)
                {
                    if (!fInfo.file )
                    {
                        fInfo.file = [FileEntity MR_findFirstByAttribute:@"file_id" withValue:fInfo.imageId];
                    }
                    
                    if (fInfo.file)
                    {
                        [cell setShowEntity:fInfo.file];
                    }
                    else
                    {
                        [fInfo fetchSelfFromServer:item.userData];
                    }
                }
                else
                {
                    if (self.baseItemDelegate && [self.baseItemDelegate respondsToSelector:@selector(wantFullLayout:)])
                    {
                        [self.baseItemDelegate wantFullLayout:(UIImageView *)cell.imageView];
                    }
                }
                
            }
            else
            {
                FileEntity *f = cell.info.file;
                
                if(f
                   && f.isPDF != nil
                   && f.isPDF.boolValue)
                {
                    if (self.baseItemDelegate
                        && [self.baseItemDelegate respondsToSelector:@selector(wantControllerPresented:)])
                    {
                        ShowPDFController *pdfController = [[ShowPDFController alloc] initWithFile:f];
                        
                        pdfController.delegate = self.baseItemDelegate;
                        
                        [self.baseItemDelegate wantControllerPresented:pdfController];
                    }
                }
                else if (f &&
                         f.isImage != nil &&
                         f.isImage.boolValue &&
                         [self.baseItemDelegate respondsToSelector:@selector(wantFullLayout:)]){
                    [self.baseItemDelegate wantFullLayout:(UIImageView *)cell.imageView];
                }
                else if (self.baseItemDelegate
                         && [self.baseItemDelegate respondsToSelector:@selector(wantFullLayout:)])
                {
                    
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:f.full_url]];
                    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
                    
                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@%@", @"temp.", f.ext]];
                    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
                    
                    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                        NSLog(@"Successfully downloaded file to %@", path);
                        UIDocumentInteractionController * documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:path]];
                        
                        [self performSelectorOnMainThread:@selector(documentOnMainThread:) withObject:documentInteractionController waitUntilDone:YES];
                    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                        NSLog(@"Error: %@", error);
                    }];
                    
                    [operation start];
                }
            }
        }
    }
}

-(void)documentOnMainThread:(UIDocumentInteractionController *)documentInteractionController{
    [self.baseItemDelegate wantDocumentControllerPresented:documentInteractionController];
}

-(void)setOverLay:(BOOL)editor animate:(BOOL)animate
{
    [UIView animateWithDuration:(animate) ? 0.6 : 0.
                          delay:0.
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:^
     {
         CGRect frame =CGRectMake(0,
                                  0,
                                  self.bounds.size.width,
                                  self.bounds.size.height);
         if (editor) {
             self.overlayView.alpha = 1.f;
         } else {
             frame = CGRectMake(self.bounds.size.width,
                                0,
                                self.bounds.size.width,
                                self.bounds.size.height);
             self.overlayView.alpha = 0.f;
         }
         
         self.overlayView.frame = frame;
     } completion:^(BOOL finished) {}];
}

- (void)prepareForMove
{
    self.hidden = YES;
}

- (NSUInteger)numOfCellsInCandidateBar:(CEditInfoBar *)candBar
{
    return [self.itemData.likesId count];
}

- (CGSize)candidateBar:(CEditInfoBar *)candBar sizeOfCellAtIndex:(NSUInteger)index
{
    return CGSizeMake(30, 30);
}

- (BI_GridViewCell *)candidateBar:(CEditInfoBar *)candBar cellForFrame:(BI_GridFrame *)frame
{
    static NSString *kCandBarCell  = @"CandidateBarCell";
    
    CEditInfoItem *cell = (CEditInfoItem *)[candBar dequeueReusableCellWithIdentifier:kCandBarCell];
    
    if (nil == cell)
    {
        cell = [[CEditInfoItem alloc] initWithReuseIdentifier:kCandBarCell];
    }
    
    NSString *cid =  [self.itemData.likesId objectAtIndex:frame.startIndex];
    
    ContactsEntity *entity = [ContactsEntity MR_findFirstByAttribute:@"me_id" withValue:cid];
    
    if (!entity)
    {
        entity = [ContactsEntity MR_findFirstByAttribute:@"contact_id" withValue:cid];
    }
    
    if (entity)
    {
        [entity getAsyncImageWithBlock:^(id img, BOOL flag)
        {
            if (img)
            {
                if ([cell.imgView isKindOfClass:[UIImageView class]])
                {
                    cell.imgView.image = [img circlePlainImageSize:kDefalutLikeIconH];
                }
            }
        }];
    }
    
    [cell setNeedsUpdateConstraints];
    
    return cell;
}

- (void)candidateBar:(CEditInfoBar *)candBar didSelectCellAtIndex:(NSUInteger)index
{
    NSString *cid =  [self.itemData.likesId objectAtIndex:index];
    
    ContactsEntity *entity = [ContactsEntity MR_findFirstByAttribute:@"me_id" withValue:cid];
    
    if (!entity)
    {
        entity = [ContactsEntity MR_findFirstByAttribute:@"contact_id" withValue:cid];
    }
    
    if (entity)
    {
        if (self.baseItemDelegate
            && [self.baseItemDelegate respondsToSelector:@selector(titleInfoClickeAtContact:)])
        {
            [self.baseItemDelegate titleInfoClickeAtContact:entity];
        }
    }
}


@end
