//
//  CEditCandContactItem.m
//  Knotable
//
//  Created by wuli on 11/12/14.
//
//

#import "CEditCandContactItem.h"
#import "UIImage+RoundedCorner.h"

@interface CEditCandContactItem()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) GBPathImageView *imgView;

@end

@implementation CEditCandContactItem

-(id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        self.imgView = [[GBPathImageView alloc] initWithFrame:self.bounds image:nil pathType:GBPathImageViewTypeCircle pathColor:[UIColor clearColor] borderColor:[UIColor clearColor] pathWidth:.01];
        [self addSubview:self.imgView];
        self.label = [[UILabel alloc] init];
        self.label.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0];
        [self addSubview:self.label];
    }
    return self;
}

-(void)setEntity:(ContactsEntity *)entity
{
    if (_entity != entity) {
        _entity = entity;
        if (entity) {
            self.label.text = entity.username;
            [entity getAsyncImageWithBlock:^(id img, BOOL flag) {
                if (img) {
                    if ([self.imgView isKindOfClass:[UIImageView class]]) {
                        img = [img circlePlainImageSize:20];
                        [(UIImageView *)self.imgView setImage:img];
                    }
                }
            }];
        }
    }
}

-(void)updateConstraints
{
    [super updateConstraints];
    [self.imgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(4));
        make.bottom.equalTo(@(-4));
        make.width.equalTo(self.imgView.mas_height);
        make.left.equalTo(@(2));
    }];
    [self.label mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(2));
        make.bottom.equalTo(@(-2));
        make.right.equalTo(@(-2));
        make.left.equalTo(self.imgView.mas_right);
    }];
}

@end
