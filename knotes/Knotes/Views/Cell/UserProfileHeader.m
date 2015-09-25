//
//  UserProfileHeader.m
//  Knotable
//
//  Created by backup on 14-1-2.
//
//

#import "UserProfileHeader.h"
#import "Masonry.h"

@interface UserProfileHeader()
@property (nonatomic, strong) UIImageView *imgv;
@end
@implementation UserProfileHeader
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        self.imgv.contentMode = UIViewContentModeScaleAspectFit;
        self.imgv.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.imgv.layer.borderWidth = 2;
        self.imgv.layer.cornerRadius = 4;
        self.imgv.clipsToBounds = YES;

        [self addSubview:self.imgv];
    }
    return self;
}
- (void)setImage:(UIImage *)image
{
    self.imgv.image = image;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.imgv.center = self.center;
}
@end
