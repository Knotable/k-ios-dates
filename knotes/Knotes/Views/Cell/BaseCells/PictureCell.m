//
//  PictureCell.m
//  Knotable
//
//  Created by Martin Ceperley on 4/1/14.
//
//

#import "PictureCell.h"
#import "FileManager.h"
#import "FileEntity.h"
#import "MessageEntity.h"
#import "SDImageCache.h"
#import <QuartzCore/QuartzCore.h>

@interface PictureCell ()

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) CGFloat imageSizeFactor;
@property (nonatomic, strong) UIInterpolatingMotionEffect *horMotionEffect;
@property (nonatomic, strong) UIInterpolatingMotionEffect *vertMotionEffect;
@property (nonatomic, strong) UIImageView *bottomShadow;

@end

@implementation PictureCell

- (id)init {
    self = [super init];
    if (self) {
        self.shouldHideHeader = NO;
        self.headerOnTop = YES;
        self.userInformationSemitransparentBackground.hidden = NO;
        
        self.knoteImageView = [UIImageView new];
        
        self.knoteImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.knoteImageContainer = [UIView new];
        
        _knoteImageContainer.clipsToBounds = YES;
        
        [self.knoteImageContainer addSubview:self.knoteImageView];
        [self.bodyView addSubview:self.knoteImageContainer];
        
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
        
        UIColor *textColor = [UIColor colorWithWhite:0.8 alpha:1.0];
        self.titleInfoBar.pName.textColor = textColor;
        self.titleInfoBar.pTime.textColor = textColor;
        self.topicLabel.textColor = textColor;
        
        [self.knoteImageView addMotionEffect:_horMotionEffect];
        [self.knoteImageView addMotionEffect:_vertMotionEffect];

    }
    return self;
}

- (void)setMessage:(MessageEntity *)message {
    NSArray *fileIds = [message.file_ids componentsSeparatedByString:@","];
    if (!fileIds || [fileIds count]<1) {
        fileIds = [message loadedEmbeddedImages];
        [self setMessage:message imageURL:fileIds.firstObject showHeaders:YES];
    } else {
        [self setMessage:message fileId:fileIds.firstObject showHeaders:YES];
    }
}

- (void)setMessage:(MessageEntity *)message imageURL:(NSString *)imageURL showHeaders:(BOOL)showHeaders {
    self.shouldHideHeader = !showHeaders;
    self.bottomShadow.hidden = !showHeaders;
    
    [super setMessage:message];
    
    self.image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:imageURL];
    
    if (self.image) {
        [self.knoteImageView setImage:self.image];
        [self.contentView bringSubviewToFront:self.header];
    }
}

- (void)setMessage:(MessageEntity *)message fileId:(NSString *)fileId showHeaders:(BOOL)showHeaders {
    self.shouldHideHeader = !showHeaders;
    self.bottomShadow.hidden = !showHeaders;

    [super setMessage:message];
    FileEntity *file = [FileEntity MR_findFirstByAttribute:@"file_id" withValue:fileId];
    if (file && file.isImage.boolValue && file.isDownloaded.boolValue) {
        NSString *imagePath = [FileManager threadFilePath:file];
        self.image = [UIImage imageWithContentsOfFile:imagePath];
        if (self.image) {
            [self.knoteImageView setImage:self.image];
            [self.contentView bringSubviewToFront:self.header];

        } else {
            NSLog(@"PictureCell image not found");

        }
    }
}

- (void)updateConstraints {
    BOOL didSetupConstraints = self.didSetupConstraints;

    
    if (!didSetupConstraints){
        [super updateConstraints];

        [self.bodyView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.greaterThanOrEqualTo(@100.0);
        }];
        
        CGFloat ratio;
        if (self.image) {
            ratio = self.image.size.height / self.image.size.width;
        } else {
            ratio = 1.0;
        }
        
        ratio = 0.5;
        
        [self.knoteImageContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
        if(!self.shouldHideHeader){
            [self.header mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.background);
            }];

        }
        

    } else {
        
        [self.knoteImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.knoteImageContainer);
        }];

        [super updateConstraints];
    }
}

@end
