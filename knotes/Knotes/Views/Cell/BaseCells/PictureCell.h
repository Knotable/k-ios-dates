//
//  PictureCell.h
//  Knotable
//
//  Created by Martin Ceperley on 4/1/14.
//
//

#import "BaseKnoteCell.h"

@interface PictureCell : BaseKnoteCell

@property (nonatomic, strong) UIImageView *knoteImageView;
@property (nonatomic, strong) UIView *knoteImageContainer;

- (void)setMessage:(MessageEntity *)message fileId:(NSString *)fileId showHeaders:(BOOL)showHeaders;
- (void)setMessage:(MessageEntity *)message imageURL:(NSString *)imageURL showHeaders:(BOOL)showHeaders;

@end
