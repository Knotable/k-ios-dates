//
//  ImageCollectionViewCell.h
//  Knotable
//
//  Created by backup on 14-1-7.
//
//

#import <UIKit/UIKit.h>
#import "FileInfo.h"
@interface ImageCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, weak) FileInfo *info;
@property (nonatomic, assign) BOOL showBoard;
@property (nonatomic, assign) BOOL downloadSucces;

- (void) updateProgress:(CGFloat)progress;
- (void) setShowImage:(UIImage *)image withContentMode:(UIViewContentMode)mode;
- (void) showWaitingView;
- (void) removeWaitingView;
- (void) setShowEntity:(FileEntity *)entity;
- (void) setOperatorDelete;

// Lin - Added to check URL validation

- (BOOL) isValidURL:(NSString *)checkURL;

// Lin - Ended

@end
