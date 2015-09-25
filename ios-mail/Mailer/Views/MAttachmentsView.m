//
//  MAttachmentsView.m
//  Mailer
//
//  Created by Martin Ceperley on 10/24/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MAttachmentsView.h"
#import "Attachment.h"
#import <CoreImage/CoreImage.h>
#import <CoreGraphics/CoreGraphics.h>
#import <ImageIO/ImageIO.h>

const CGFloat imageFitInSize = 150.0;

@implementation MAttachmentsView

@synthesize attachments;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _featureViews = [[NSMutableArray alloc] init];
        _imageViews = [[NSMutableArray alloc] init];
    }
    return self;
}


- (void) setAttachments:(NSArray *)newAttachments{
    
    attachments = [newAttachments copy];
    for(UIView *view in self.subviews){
        [view removeFromSuperview];
    }
    [_imageViews removeAllObjects];
    
//    NSMutableArray *imageAttachments = [[NSMutableArray alloc] init];
    NSMutableArray *allAttachments = [[NSMutableArray alloc] init];
    for(Attachment *attachment in attachments){
        
        [allAttachments addObject:attachment];
        
//        if (attachment.isImage){
//             [imageAttachments addObject:attachment];
//        }
        
    }
    
    attachments = [allAttachments copy];
    
    UILabel *attachmentsLabel;
    attachmentsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    attachmentsLabel.font = [UIFont boldSystemFontOfSize:14.0];
    attachmentsLabel.textColor = [UIColor colorWithWhite:0.4 alpha:1.0];
    attachmentsLabel.text = [NSString stringWithFormat:@"%lu Attachments", (unsigned long)attachments.count];

    [self addSubview:attachmentsLabel];
    [attachmentsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self).with.offset(4.0);
    }];
    
//    self.backgroundColor = [UIColor redColor];

    UIView *aboveView = attachmentsLabel;
    
    int i=0;
    
    for(Attachment *attachment in attachments){
        
        
        NSLog(@"attachment = %@",attachment);
         NSLog(@"attachment.isImage = %d",attachment.isImage);
         NSLog(@"attachment.mimeType = %@",attachment.mimeType);
         NSLog(@"attachment.path = %@",attachment.path);
        
        if (attachment.isImage) {
            
            UIImage *image = attachment.image;
            
            //Reducing image size
            
            float actualHeight = image.size.height;
            float actualWidth = image.size.width;
            float imgRatio = actualWidth/actualHeight;
            float maxRatio = 320.0/480.0;
            
            if(imgRatio!= maxRatio){
                if(imgRatio < maxRatio){
                    imgRatio = 480.0 / actualHeight;
                    actualWidth = imgRatio * actualWidth;
                    actualHeight = 480.0;
                }
                else{
                    imgRatio = 320.0 / actualWidth;
                    if (imgRatio<1) {
                        actualHeight = imgRatio * actualHeight;
                        actualWidth = 320.0;
                    }
                }
            }
            
            CGRect rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight);
            UIGraphicsBeginImageContext(rect.size);
            [image drawInRect:rect];
            UIImage *finalImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            
            CGFloat imageRatio = finalImage.size.height / finalImage.size.width;
            if (image != nil) {
                UIImageView *imageView = [[UIImageView alloc] initWithImage:finalImage];
                [self addSubview:imageView];
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                [_imageViews addObject:imageView];
                
                //Disabling face detection for now. Should be done in background.
                //[self detectFacesForAttachment:attachment];

                UILabel *filenameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                filenameLabel.font = sizeLabel.font = [UIFont boldSystemFontOfSize:9.0];
                filenameLabel.textColor = sizeLabel.textColor = self.tintColor;
                filenameLabel.textAlignment = NSTextAlignmentLeft;
                sizeLabel.textAlignment = NSTextAlignmentRight;
                
                filenameLabel.text = attachment.filename;

                double ONE_KB = 1024.0;
                double ONE_MB = pow(1024.0, 2.0);
                double sizeDouble = (double)attachment.size;

                if(sizeDouble < ONE_MB){
                    sizeLabel.text = [NSString stringWithFormat:@"%d KB",(int)(sizeDouble / ONE_KB)];
                } else {
                    sizeLabel.text = [NSString stringWithFormat:@"%d MB",(int)(sizeDouble / ONE_MB)];
                }
                
                [self addSubview:filenameLabel];
                [self addSubview:sizeLabel];

                
                [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(self);
                    make.centerX.equalTo(self);
                    
                    if (aboveView == nil) {
                        make.top.equalTo(self);
                    } else {
                        make.top.equalTo(aboveView.mas_bottom).with.offset(36.0);
                    }
                    if (imageRatio<=1) {
                        make.height.equalTo(@(imageView.image.size.height));
                    } else {
                        make.height.equalTo(imageView.mas_width).multipliedBy(imageRatio);
                    }
                }];
                
                [filenameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(imageView.mas_bottom).with.offset(4.0);
                    make.left.equalTo(imageView).with.offset(4.0);
                }];
                
                [sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(filenameLabel);
                    make.right.equalTo(imageView).with.offset(-4.0);
                }];

                aboveView = filenameLabel;
            }
        }
        
        else{
            
//            NSLog(@"attachment.mimeType === %@",attachment.mimeType);
//            NSLog(@"attachment.filename === %@",attachment.filename);
//            NSLog(@"attachment.path === %@",attachment.path);
            
            
            _mimeTypeStr = attachment.mimeType;
            
            
            UIButton *fileBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            UIImage *videImage = nil;
            
            
            NSArray *typeArray = [_mimeTypeStr componentsSeparatedByString:@"/"];
            
            NSString *fileTypeStr = [typeArray objectAtIndex:0];
            
            
            if ([fileTypeStr isEqualToString:@"video"]) {
                
                [fileBtn setImage:[UIImage imageNamed:@"videoIcon.png"] forState:UIControlStateNormal];
                videImage = [UIImage imageNamed:@"videoIcon.png"];
            }
            else if ([fileTypeStr isEqualToString:@"audio"]){
                
                [fileBtn setImage:[UIImage imageNamed:@"audioIcon.png"] forState:UIControlStateNormal];
                videImage = [UIImage imageNamed:@"audioIcon.png"];
                
            }
            else if ([fileTypeStr isEqualToString:@"application"]){
                
                if ([[NSString stringWithFormat:@"%@",[typeArray objectAtIndex:1]] isEqualToString:@"pdf"]) {
                    
                    [fileBtn setImage:[UIImage imageNamed:@"pdfIcon.png"] forState:UIControlStateNormal];
                    videImage = [UIImage imageNamed:@"pdfIcon.png"];
                }
                else{
                    
                    [fileBtn setImage:[UIImage imageNamed:@"fileIcon.png"] forState:UIControlStateNormal];
                    videImage = [UIImage imageNamed:@"fileIcon.png"];

                }
                
                
            }
            else{
                
                [fileBtn setImage:[UIImage imageNamed:@"fileIcon.png"] forState:UIControlStateNormal];
                videImage = [UIImage imageNamed:@"fileIcon.png"];
            }
            
            
                [fileBtn addTarget:self
                            action:@selector(fileClick:)
                  forControlEvents:UIControlEventTouchUpInside];
                
                [fileBtn setFrame:CGRectZero];
                fileBtn.tag = i;
                [self addSubview:fileBtn];
                
                
                CGFloat imageRatio = videImage.size.height / videImage.size.width;
                
                [fileBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(self);
                    make.centerX.equalTo(self);
                    
                    if (aboveView == nil) {
                        make.top.equalTo(self);
                    }
                    else {
                        make.top.equalTo(aboveView.mas_bottom).with.offset(10.0);
                    }
                    
                    make.height.equalTo(fileBtn.mas_width).multipliedBy(imageRatio);
                    
                }];
            
            
            UILabel *filenameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            filenameLabel.font = sizeLabel.font = [UIFont boldSystemFontOfSize:9.0];
            filenameLabel.textColor = sizeLabel.textColor = self.tintColor;
            filenameLabel.textAlignment = NSTextAlignmentLeft;
            sizeLabel.textAlignment = NSTextAlignmentRight;
            
            filenameLabel.text = attachment.filename;
            
            double ONE_KB = 1024.0;
            double ONE_MB = pow(1024.0, 2.0);
            double sizeDouble = (double)attachment.size;
            
            if(sizeDouble < ONE_MB){
                sizeLabel.text = [NSString stringWithFormat:@"%d KB",(int)(sizeDouble / ONE_KB)];
            } else {
                sizeLabel.text = [NSString stringWithFormat:@"%d MB",(int)(sizeDouble / ONE_MB)];
            }
            
            [self addSubview:filenameLabel];
            [self addSubview:sizeLabel];
            
            
            [filenameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(fileBtn.mas_bottom).with.offset(4.0);
                make.left.equalTo(fileBtn).with.offset(4.0);
            }];
            
            [sizeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(filenameLabel);
                make.right.equalTo(fileBtn).with.offset(-4.0);
            }];
            
            
            
                aboveView = filenameLabel;
            
        }
        
        i++;
    }
    
    [aboveView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
    }];
    
}

-(IBAction)fileClick:(id)sender{
    
    UIButton *btn = (UIButton *)sender;
    NSInteger tag = btn.tag;
    
    
//    NSLog(@"[attachments objectAtIndex:tag ]%@",[attachments objectAtIndex:tag ]);
    
    Attachment *attachment = [attachments objectAtIndex:tag ];
    
//    NSLog(@"attachment%@",attachment);
    
    NSString *type = attachment.mimeType;
    NSArray *typeArray = [type componentsSeparatedByString:@"/"];
    
    NSString *fileTypeStr = [typeArray objectAtIndex:0];
    
    
    if ([fileTypeStr isEqualToString:@"video"]) {
        
        NSString *path = attachment.path;
        
        NSURL *videoURL = [NSURL fileURLWithPath:path];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Video" object:videoURL];
        
    }
    else if ([fileTypeStr isEqualToString:@"audio"]){
        
        NSString *path = attachment.path;
        
        NSURL *audioURL = [NSURL fileURLWithPath:path];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Audio" object:audioURL];
        
    }
    else if ([fileTypeStr isEqualToString:@"application"]){
        
        if ([[NSString stringWithFormat:@"%@",[typeArray objectAtIndex:1]] isEqualToString:@"pdf"]) {
            
            NSString *path = attachment.path;
//            NSLog(@"path = %@",path);
            
            NSURL *audioURL = [NSURL fileURLWithPath:path];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PDF" object:audioURL];
        }
        else{
             [[NSNotificationCenter defaultCenter] postNotificationName:@"Alert" object:nil];
        }
       
    }
    else{
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"Alert" object:nil];
    }
    
}

- (CGSize) intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
}

- (void) detectFacesForAttachment:(Attachment *)attachment
{
    UIImage *image = attachment.image;
    CIContext *context = [CIContext contextWithOptions:nil];
    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh, CIDetectorSmile : @YES };
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:context
                                              options:opts];
    
    CIImage *ciimage = [[CIImage alloc] initWithImage:image];
    NSNumber *orientation = [[ciimage properties] valueForKey:(NSString *)kCGImagePropertyOrientation];
    NSDictionary *orientationTranslation = @{@(UIImageOrientationUp): @(1),
                                             @(UIImageOrientationDown): @(3),
                                             @(UIImageOrientationLeft): @(8),
                                             @(UIImageOrientationRight): @(6),
                                             @(UIImageOrientationUpMirrored): @(2),
                                             @(UIImageOrientationDownMirrored): @(4),
                                             @(UIImageOrientationLeftMirrored): @(5),
                                             @(UIImageOrientationRightMirrored): @(7)
                                             };
    if (orientation == nil) {
        orientation = orientationTranslation[@(image.imageOrientation)];
    }
    opts = @{ CIDetectorImageOrientation :  orientation};
    NSArray *features = [detector featuresInImage:ciimage options:opts];
    
    attachment.features = features;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

//    for (UIView *fv in _featureViews){
//        [fv removeFromSuperview];
//    }
//    [_featureViews removeAllObjects];
//    
//    for (int i=0;i < attachments.count;i++){
//        
//        Attachment *attachment = attachments[i];
//        if (attachment.isImage) {
//            
//        
//        UIImageView *imageView = _imageViews[i];
//        
//        NSArray *features = attachment.features;
//        if (features == nil) {
//            continue;
//        }
//        
//        float scale = imageView.frame.size.width / (imageView.image.size.width * imageView.image.scale);
//
//        for (CIFaceFeature *f in features) {
//            CGRect scaledFrame = CGRectApplyAffineTransform(f.bounds, CGAffineTransformMakeScale(scale, scale));
//            UIView *outlineView = [[UIView alloc] initWithFrame:scaledFrame];
//            outlineView.layer.borderColor = self.tintColor.CGColor;
//            outlineView.layer.borderWidth = 1.0;
//            outlineView.layer.cornerRadius = 10.0;
//            [imageView addSubview:outlineView];
//            [_featureViews addObject:outlineView];
//        }
//        
//    }
//    }
}


@end
