//
//  LockCell.m
//  Knotable
//
//  Created by Martin Ceperley on 12/23/13.
//
//

#import "LockCell.h"
#import "MessageEntity.h"

@interface LockCell ()

@property (nonatomic, strong) UIView *lockBox;
@property (nonatomic, strong) UIView *lockTopBox;

@property (nonatomic, strong) UILabel *lockedLabel;
@property (nonatomic, strong) UIImageView *lockedIcon;
@property (nonatomic, strong) UILabel *lockTextLabel;

@end


@implementation LockCell

- (id)init
{
    self = [super init];
    if (self) {
        
        _lockBox = [UIView new];
        _lockBox.backgroundColor = [UIColor colorWithRed:0.73 green:0.38 blue:0.50 alpha:1.0];
        [self.bodyView addSubview:_lockBox];
        
        _lockTopBox = [UIView new];
        _lockTopBox.backgroundColor = [UIColor colorWithRed:0.48 green:0.38 blue:0.49 alpha:1.0];
        [_lockBox addSubview:_lockTopBox];
        
        NSLog(@"Font names: %@", [UIFont fontNamesForFamilyName:@"Helvetica Neue"]);
        
        _lockedLabel = [UILabel new];
        _lockedLabel.text = @"Locked";
        _lockedLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15.0];
        _lockedLabel.textColor = [UIColor whiteColor];
        _lockedLabel.backgroundColor = [UIColor clearColor];
        _lockedLabel.textAlignment = NSTextAlignmentCenter;
        [_lockTopBox addSubview:_lockedLabel];
        
        _lockedIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lock_icon"]];
        [_lockBox addSubview:_lockedIcon];

        
        _lockTextLabel = [UILabel new];
        _lockTextLabel.text = @"Well done guys, project is finished, enjoy your weekend.";
        _lockTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0]/*[UIFont fontWithName:@"HelveticaNeue-Bold" size:12.0]*/;
        _lockTextLabel.textColor = [UIColor blackColor];
        _lockTextLabel.backgroundColor = [UIColor clearColor];
        _lockTextLabel.textAlignment = NSTextAlignmentLeft;
        _lockTextLabel.numberOfLines = 0;
        _lockTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        [self.bodyView addSubview:_lockTextLabel];
        
        
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    NSLog(@"deadlinecell layoutsubviews _lockTextLabel width: %f", _lockTextLabel.frame.size.width);
    
    _lockTextLabel.preferredMaxLayoutWidth = _lockTextLabel.frame.size.width;
}

- (void)setMessage:(MessageEntity *)message
{
    [super setMessage:message];
    
    self.lockTextLabel.text = message.body;
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints){
        [super updateConstraints];
        [self.lockBox mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.size.equalTo(@92.0);
            
            make.top.equalTo(@8.0);
            make.bottom.equalTo(@-16.0);
            make.left.equalTo(@0.0);
            
            
        }];
        
        [self.lockTopBox mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self.lockBox);
            make.height.equalTo(@25.0);
            make.top.equalTo(@0.0);
            make.left.equalTo(@0.0);
        }];
        
        [self.lockedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(@0.0);
        }];
        
        [self.lockedIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.lockBox).with.offset(12.0);
            make.centerX.equalTo(self.lockBox);
        }];

        
        [self.lockTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lockBox).with.offset(0.0);
            make.bottom.equalTo(self.bodyView);
            make.left.equalTo(self.lockBox.mas_right).with.offset(8.0);
            make.right.lessThanOrEqualTo(@8.0);
        }];
        
    } else {
        [super updateConstraints];
    }
}

@end
