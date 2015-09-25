//
//  PicturesCell.m
//  Knotable
//
//  Created by wuli on 14-7-11.
//
//

#import "PicturesCell.h"
#import "ShowPDFController.h"
#import "CEditInfoItem.h"
#import "ContactsEntity.h"
#import "CUtil.h"
#import "UIImage+RoundedCorner.h"
#import "RFQuiltLayout.h"
#import "FileManager.h"
#import "SDImageCache.h"
#import "CTitleInfoBar.h"

#define kMaxPicsCellNum 4

@interface PicturesCell()<RFQuiltLayoutDelegate>

@property (nonatomic) NSMutableArray* numbers;
@property (nonatomic) NSMutableArray* numberWidths;
@property (nonatomic) NSMutableArray* numberHeights;

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) CGFloat imageSizeFactor;
@property (nonatomic, strong) UIInterpolatingMotionEffect *horMotionEffect;
@property (nonatomic, strong) UIInterpolatingMotionEffect *vertMotionEffect;

@property (nonatomic, strong) UIImageView *bottomShadow;

@end

@implementation PicturesCell

@synthesize processRetainCount,processView,offline=_offline;

- (instancetype)init
{
    self = [super init];

    if (self) {
    
        self.shouldHideHeader = NO;
        self.headerOnTop = NO;
        
        RFQuiltLayout* layout = [[RFQuiltLayout alloc] init];
        layout.direction = UICollectionViewScrollDirectionVertical;
        layout.blockPixels = CGSizeMake(44,30);
        layout.delegate = self;
        self.imageGridView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        self.imageGridView.dataSource = self;
        self.imageGridView.delegate = self;
        self.imageGridView.backgroundColor = [UIColor clearColor];
        self.imageGridView.userInteractionEnabled = YES;
        
        [self.imageGridView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
        
        self.knoteImageView = [UIImageView new];
        self.knoteImageContainer = [UIView new];
        
        _knoteImageContainer.clipsToBounds = YES;
        
        [self.knoteImageContainer addSubview:self.knoteImageView];
        
        [self.bodyView addSubview:self.knoteImageContainer];
        
        // Lin - Marked to check Picture Cell
                
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
        
        self.bottomShadow = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottom-shadow"]];
        [self.bodyView addSubview:self.bottomShadow];
        
        UIColor *textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        
        self.titleInfoBar.pName.textColor = textColor;
        self.titleInfoBar.pTime.textColor = textColor;
        
        self.topicLabel.textColor = textColor;
        
        [self.knoteImageView addMotionEffect:_horMotionEffect];
        [self.knoteImageView addMotionEffect:_vertMotionEffect];
        
        [self.bodyView addSubview:self.imageGridView ];
        [self.bodyView bringSubviewToFront:self.imageGridView];
        
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

- (void)setMessage:(MessageEntity *)message
{
    NSArray *fileIds = [message.file_ids componentsSeparatedByString:@","];
    [self setMessage:message fileId:fileIds.firstObject showHeaders:YES];
}

- (void)setMessage:(MessageEntity *)message imageURL:(NSString *)imageURL showHeaders:(BOOL)showHeaders
{
    self.shouldHideHeader = !showHeaders;
    self.bottomShadow.hidden = !showHeaders;
    
    [super setMessage:message];
    
    self.image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageURL];
    
    if (self.image)
    {
        [self.knoteImageView setImage:self.image];
        [self.contentView bringSubviewToFront:self.header];
    }
}

- (void)setMessage:(MessageEntity *)message fileId:(NSString *)fileId showHeaders:(BOOL)showHeaders
{
    self.shouldHideHeader = !showHeaders;
    self.bottomShadow.hidden = !showHeaders;
    
    [super setMessage:message];
    
    FileEntity *file = [FileEntity MR_findFirstByAttribute:@"file_id" withValue:fileId];
    
    if (file
        && file.isImage.boolValue
        && file.isDownloaded.boolValue)
    {
        NSString *imagePath = [FileManager threadFilePath:file];
        
        self.image = [UIImage imageWithContentsOfFile:imagePath];
        
        if (self.image)
        {
            [self.knoteImageView setImage:self.image];
            [self.contentView bringSubviewToFront:self.header];
            
        }
        else
        {
            NSLog(@"PictureCell image not found");
            
        }
    }
}


- (void)updateConstraints
{
    BOOL didSetupConstraints = self.didSetupConstraints;
    
    
    if (!didSetupConstraints){
        [super updateConstraints];
        
        MASAttachKeys(self.bodyView, _knoteImageView, _knoteImageContainer, self.background, self.header, self.bottomShadow);
        
        [self.bodyView mas_makeConstraints:^(MASConstraintMaker *make)
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
            
            make.top.equalTo(self.background);
            make.left.equalTo(self.background);
            make.right.equalTo(self.background);
            make.height.equalTo(self.background);
            
        }];
        
        [self.imageGridView mas_updateConstraints:^(MASConstraintMaker *make) {
#if NEW_DESIGN
            make.left.equalTo(self);
#else
            make.left.equalTo(self).offset(kTheadLeftGap-10);
#endif
            make.top.equalTo(self);
            make.bottom.equalTo(self);
            make.right.equalTo(self);
            make.height.greaterThanOrEqualTo(@(80));
            
        }];
        
        if(!self.shouldHideHeader){
            [self.header mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.background);
            }];
            [self.bottomShadow mas_makeConstraints:^(MASConstraintMaker *make) {
                make.width.equalTo(self.knoteImageContainer);
                make.bottom.equalTo(self.knoteImageContainer);
                make.left.equalTo(self.knoteImageContainer);
                make.height.equalTo(@(60));
            }];
            
        }
        
        
    } else {
        [super updateConstraints];
    }
}

-(void)setItemData:(CItem *)itemData
{
    _itemData = itemData;
    
    self.header.hidden = YES;
    
    [super setMessage:itemData.userData];
    
    self.shouldHideHeader = YES;
    
    self.bottomShadow.hidden = YES;
    
    NSInteger count = [itemData.files count];
    
    NSInteger embeddedCount = [[itemData.userData loadedEmbeddedImages] count];
    
    if (embeddedCount > 0)
    {
        count += embeddedCount;
    }
    
    switch (count) {
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
                for (int i = 0; i<[itemData.files count]; i++) {
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
    CGFloat width = [[self.numberWidths objectAtIndex:indexPath.row] floatValue];
    CGFloat height = [[self.numberHeights objectAtIndex:indexPath.row] floatValue];
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
    if (embeddedCount > 0) {
        count += embeddedCount;
    }
    if (count<=kMaxPicsCellNum) {
        return count;
    }
    if (self.isExpand) {
        return count;
    } else {
        return kMaxPicsCellNum;
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    CItem *item = (CItem *)[self itemData];
    
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.tag = indexPath.row;
    if (self.isExpand || indexPath.row<kMaxPicsCellNum-1 || [item.files count]==kMaxPicsCellNum) {
        if (indexPath.row<[[item files] count]) {
            FileInfo *fInfo = [[item files] objectAtIndex:indexPath.row];
            cell.info = fInfo;
            fInfo.cell = cell;
            fInfo.parentCell = self;
            fInfo.parentItem = item;
            [cell setShowBoard:NO];
            cell.layer.borderColor = [UIColor clearColor].CGColor;
            cell.layer.borderWidth = 2;
            cell.layer.cornerRadius = 8;
            cell.clipsToBounds = YES;
            
            if (!self.offline)
            {
                if (fInfo.file && [fInfo.file.sendFlag charValue] != SendSuc)
                {
                    UIImage *img = fInfo.image;
                    
                    NSLog(@"Image Size : %@", NSStringFromCGSize(img.size));
                    NSLog(@"Cell Size : %@", NSStringFromCGSize(cell.bounds.size));
                    
                    if (img.size.width>cell.bounds.size.width||img.size.height>cell.bounds.size.height)
                    {
                        [cell setShowImage:img withContentMode:UIViewContentModeScaleAspectFit];
                    }
                    else
                    {
                        [cell setShowImage:img withContentMode:UIViewContentModeScaleToFill];
                    }
                    
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
                        [fInfo fetchSelfFromServer:item.userData];
                    }
                }
            }
            else
            {
                if (fInfo.file)
                {
                    [cell setShowEntity:fInfo.file];
                }
            }
        }
        else
        {
            cell.layer.borderColor = [UIColor clearColor].CGColor;
            cell.layer.borderWidth = 2;
            cell.layer.cornerRadius = 8;
            cell.clipsToBounds = YES;
            
            NSInteger index = indexPath.row-[[item files] count];
            NSArray *array = [item.userData loadedEmbeddedImages];
            UIImage *image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey: array[index]];
            
            [cell setShowImage:image withContentMode:UIViewContentModeScaleAspectFill];
        }

    }
    else
    {
        [cell setShowBoard:NO];
        if (!cell.imageView) {
            cell.imageView = [[UIImageView alloc] init];
            [cell.imageView setFrame:cell.bounds];
            cell.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            cell.imageView.contentMode = UIViewContentModeScaleToFill;
            [cell addSubview:cell.imageView];
        }
        if (!cell.infoLabel) {
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
// called when the user taps on an already-selected item in multi-select mode

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    ImageCollectionViewCell *cell = (ImageCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    
    if (self.isExpand || indexPath.row<kMaxPicsCellNum-1)
    {
        if (!cell.downloadSucces)
        {
            CItem *item = (CItem *)[self itemData];
            
            FileInfo *fInfo =  [[item files] objectAtIndex:indexPath.row];
            
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

        } else {
            FileEntity *f = cell.info.file;
            if(f && f.isPDF != nil && f.isPDF.boolValue){
                if (self.baseItemDelegate && [self.baseItemDelegate respondsToSelector:@selector(wantControllerPresented:)])
                {
                    ShowPDFController *pdfController = [[ShowPDFController alloc] initWithFile:f];
                    pdfController.delegate = self.baseItemDelegate;
                    [self.baseItemDelegate wantControllerPresented:pdfController];
                }
                
            }
            else if (self.baseItemDelegate && [self.baseItemDelegate respondsToSelector:@selector(wantFullLayout:)]) {
                [self.baseItemDelegate wantFullLayout:(UIImageView *)cell.imageView];
            }
        }
    } else {
        if (self.baseItemDelegate && [self.baseItemDelegate respondsToSelector:@selector(wantExpandPicCell:)]) {
            [self.baseItemDelegate wantExpandPicCell:self.indexPath];
        }
    }
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
     } completion:^(BOOL finished) {
         self.overlayView.userInteractionEnabled = editor;
         if (editor) {
             [self.baseItemDelegate contextMenuDidShowInCell:self];
         }
     }];
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
    if (!entity) {
        entity = [ContactsEntity MR_findFirstByAttribute:@"contact_id" withValue:cid];
    }
    if (entity) {
        [entity getAsyncImageWithBlock:^(id img, BOOL flag) {
            if (img) {
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
    if (!entity) {
        entity = [ContactsEntity MR_findFirstByAttribute:@"contact_id" withValue:cid];
    }
    if (entity) {
        if (self.baseItemDelegate && [self.baseItemDelegate respondsToSelector:@selector(titleInfoClickeAtContact:)]) {
            [self.baseItemDelegate titleInfoClickeAtContact:entity];
        }
    }
}


@end
