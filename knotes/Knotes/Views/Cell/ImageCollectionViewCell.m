//
//  ImageCollectionViewCell.m
//  Knotable
//
//  Created by backup on 14-1-7.
//
//

#import "ImageCollectionViewCell.h"
#import "GMProgressView.h"
#import "ProgressHUD.h"
#import "UIImage+Resize.h"
#import "FileManager.h"
#import "FileEntity.h"
#import "Constant.h"
#import "Utilities.h"

@interface ImageCollectionViewCell()

@property(nonatomic, strong) GMProgressView *progressView;
@property(atomic, strong) UIActivityIndicatorView *actView;
@property (nonatomic, strong) FileEntity *entity;
@property (atomic, assign) NSInteger processRetainCount;
@property (nonatomic, strong) UIImageView *deleImg;

@end

@implementation ImageCollectionViewCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:IMAGE_DOWNLOADED_NOTIFICATION object:nil];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.showBoard = YES;
        self.userInteractionEnabled = YES;
        self.hidden = NO;
        self.userInteractionEnabled = YES;
        
        // Initialization code
    }
    
    return self;
}

-(void)setShowBoard:(BOOL)showBoard
{
    _showBoard = showBoard;
    
    if (showBoard)
    {
        self.layer.borderColor = [UIColor darkGrayColor].CGColor;
        self.layer.borderWidth = 2;
        self.layer.cornerRadius = 4;
        self.clipsToBounds = YES;
    }
    else
    {
        self.layer.borderColor = [UIColor clearColor].CGColor;
        self.layer.borderWidth = 0;
        self.layer.cornerRadius = 0;
        self.clipsToBounds = NO;
    }
}

- (void)updateProgress:(CGFloat)progress
{
    if (progress == 0)
    {
        if (!_progressView)
        {
            self.progressView  = [[GMProgressView alloc] initWithFrame:self.bounds ];
            
            _progressView.backgroundColor = [UIColor colorWithRed:30.0/255 green:40.0/255 blue:50.0/255 alpha:0.6];
            _progressView.lineWidth = 2;
            _progressView.type = GMProgressCircle;//defalut is circle
            _progressView.showProgress = YES;
            _progressView.progressColor = [UIColor colorWithRed:164/255.0 green:231/255.0 blue:134/255.0 alpha:1.0];
            
            _progressView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
            [self addSubview:_progressView];
            [self.progressView setNeedsDisplay];
        }
        
        self.progressView.progress = progress;
        
    }
    else if (progress == -1)
    {
        [self.progressView removeFromSuperview];
        self.progressView = nil;
    }
    else
    {
        if (!_progressView)
        {
            self.progressView  = [[GMProgressView alloc] initWithFrame:self.bounds ];
            
            _progressView.backgroundColor = [UIColor colorWithRed:30.0/255 green:40.0/255 blue:50.0/255 alpha:0.6];
            _progressView.lineWidth = 2;
            _progressView.type = GMProgressCircle;//defalut is circle
            _progressView.showProgress = YES;
            _progressView.progressColor = [UIColor colorWithRed:164/255.0 green:231/255.0 blue:134/255.0 alpha:1.0];
            
            _progressView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
            
            [self addSubview:_progressView];
            [self.progressView setNeedsDisplay];
        }
        self.progressView.progress = progress;
        
        [self.progressView setNeedsDisplay];
    }
    [_progressView setFrame:self.bounds];
}

- (void)setShowImage:(UIImage *)image withContentMode:(UIViewContentMode)mode
{
    if (!_imageView)
    {
        self.imageView = [[UIImageView alloc] init];
        [self addSubview:_imageView];
    }
    
    self.imageView.backgroundColor=[UIColor whiteColor];
    [self.imageView setFrame:self.bounds];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.image = Nil;
    self.imageView.image = image;
    
    self.imageView.contentMode = mode;
}

- (void)setOperatorDelete
{
    if (!_deleImg)
    {
        self.deleImg = [[UIImageView alloc] init];
        self.deleImg.userInteractionEnabled = NO;
        [self.deleImg setFrame:CGRectMake(CGRectGetWidth(self.bounds)-10, 0, 20, 20)];
        self.deleImg.image = [UIImage imageNamed:@"icon_pic_delete"];
        [self addSubview:self.deleImg];
    }
}

- (void) showWaitingView
{
    if (!self.actView)
    {
        self.actView = [[UIActivityIndicatorView alloc] init];
        self.actView.autoresizingMask = UIViewAutoresizingFlexibleMargins;
        
        [_actView setCenter:CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2)];
        
        self.processRetainCount = 0;

    }
    
    [self addSubview:self.actView];
    
    [_actView startAnimating];
    
    self.backgroundColor = [UIColor grayColor];
    
    self.processRetainCount++;
}

- (void) showPlaceholderView
{
    UIImageView *img=[[UIImageView alloc]init];
    
    [img setFrame:self.bounds];
    
    img.autoresizingMask = UIViewAutoresizingFlexibleMargins;
    img.image=[UIImage imageNamed:@"broken"];
    [self addSubview:img];
}

- (void) removeWaitingView
{
    self.processRetainCount--;
    
    if (self.processRetainCount == 0)
    {
        [self.actView stopAnimating];
        [self.actView removeFromSuperview];
        
        self.backgroundColor = [UIColor clearColor];
        
        self.actView = nil;
    }
}

-(void)setShowEntity:(FileEntity *)entity
{
    NSLog(@"setShowEntity");
    
    self.entity = entity;

    if (entity.full_url)
    {

        UIImage *img = [entity loadThreadImage];
        
        if (img)
        {
            self.downloadSucces = YES;
            
            UIViewContentMode mode = UIViewContentModeScaleAspectFill;

            if (img.size.width > self.bounds.size.width
                ||img.size.height > self.bounds.size.height)
            {
                mode = UIViewContentModeScaleAspectFill;
            }
            [self setShowImage:img withContentMode:mode];
        }
        else if (entity.downloading)
        {
            [self.imageView setImage:nil];
            
            [self showWaitingView];

            NSLog(@"Image alreadying downloading, registering observer for file: %@", _entity.full_url);
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(anotherCellDownloadedImage:)
                                                         name:IMAGE_DOWNLOADED_NOTIFICATION
                                                       object:entity];
        }
        else
        {
            self.downloadSucces = YES;
            
            if (!_imageView)
            {
                self.imageView = [UIImageView new];
                [self addSubview:_imageView];
            }
            
            self.imageView.backgroundColor = [UIColor whiteColor];
            [self.imageView setFrame:self.bounds];
            
            self.imageView.image = Nil;
            
            self.imageView.image = [Utilities scaleImageProportionally:[UIImage imageNamed:[self getFileAttachmentImageWithFileType:[@"." stringByAppendingString:entity.ext]]] maxSize:self.bounds.size.height - 10];
            
            self.imageView.contentMode = UIViewContentModeCenter;

            [self.imageView setNeedsDisplay];
        }
    }
    else
    {
        [self setShowImage:HUD_IMAGE_ERROR withContentMode:UIViewContentModeCenter];
    }
    
}

- (void)anotherCellDownloadedImage:(NSNotification *)note
{
    [self removeWaitingView];

    FileEntity *file = note.object;
    
    if (file && ![file isFault] && self.entity && ![self.entity isFault] && [self.entity isEqual:file])
    {
        UIImage *img = note.userInfo[@"image"];
        
        NSLog(@"anotherCellDownloadedImage for image URL: %@", file.full_url);
        
        self.downloadSucces = YES;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:IMAGE_DOWNLOADED_NOTIFICATION object:file];
        
        UIViewContentMode mode = UIViewContentModeScaleAspectFill;
        
        if (img.size.width > self.bounds.size.width
            ||img.size.height > self.bounds.size.height)
        {
            mode = UIViewContentModeScaleAspectFill;
        }
        
        [self setShowImage:img withContentMode:mode];
    }

}

- (void)showImageData:(NSData *)data
{
    NSLog(@"showImageData");
    if (![_entity isFault]) {

    self.processRetainCount = 1;
    
    [self removeWaitingView];
    
    UIImage *img = nil;
    
    BOOL isDocument = NO;
    
    if (data)
    {
        img = [UIImage imageWithData:data];
    }
    else
    {
        img = HUD_IMAGE_ERROR;
    }
    
    if (!img)
    {
        NSLog(@"Didnts make UIImage, maybe it's a document?");
        
        isDocument = [[self.entity.ext lowercaseString] isEqualToString:@"pdf"];
        
        if(isDocument)
        {
            NSLog(@"Its a PDF!");
            self.entity.isPDF = @(YES);
            [AppDelegate saveContext];
        }
    }
    
    if (img)
    {
        self.downloadSucces = YES;
        _entity.downloading = NO;
        
        NSLog(@"Posting image downloaded notification for entity: %@", _entity.full_url);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_DOWNLOADED_NOTIFICATION
                                                            object:_entity
                                                          userInfo:@{@"image":img}];
    }
    else
    {
        if(isDocument)
        {
            self.downloadSucces = YES;
            _entity.downloading = NO;

            img = [UIImage imageNamed:[self getFileAttachmentImageWithFileType:[@"." stringByAppendingString:self.entity.ext]]];
        }
        else
        {
            self.downloadSucces = NO;
            _entity.downloading = NO;

            img = HUD_IMAGE_ERROR;

        }
    }
    UIViewContentMode mode = UIViewContentModeCenter;
    
    if (img.size.width > self.bounds.size.width
        || img.size.height>self.bounds.size.height)
    {
        mode = UIViewContentModeScaleAspectFill;
    }
    
    [self setShowImage:img withContentMode:mode];
    }
}

// Lin - Added to check URL Validation

- (BOOL) isValidURL:(NSString *)checkURL
{
    NSUInteger length = [checkURL length];
    
    // Empty strings should return NO
    
    if (length > 0)
    {
        NSError *error = nil;
        
        NSDataDetector *dataDetector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:&error];
        
        if (dataDetector && !error)
        {
            NSRange range = NSMakeRange(0, length);
            NSRange notFoundRange = (NSRange){NSNotFound, 0};
            NSRange linkRange = [dataDetector rangeOfFirstMatchInString:checkURL options:0 range:range];
            
            if (!NSEqualRanges(notFoundRange, linkRange) && NSEqualRanges(range, linkRange))
            {
                return YES;
            }
        }
        else
        {
            NSLog(@"Could not create link data detector: %@ %@", [error localizedDescription], [error userInfo]);
        }
    }
    
    return NO;
}

// Lin - Ended

#pragma mark - FileType methods

- (NSString *) getFileAttachmentImageWithFileType : (NSString *) extention
{
    NSArray *fileAttachmentImageArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"FileTypeImages" ofType:@"plist"]];
    
    for (NSDictionary *fileAttachmentImageDict in fileAttachmentImageArray)
    {
        if ([[fileAttachmentImageDict objectForKey:@"FileType"] isEqualToString:extention])
        {
            return [fileAttachmentImageDict objectForKey:@"FileTypeImage"];
        }
    }
    
    return @"txt.png";
}

@end
