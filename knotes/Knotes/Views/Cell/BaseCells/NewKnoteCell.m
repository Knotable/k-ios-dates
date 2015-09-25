//
//  NewKnoteCell.m
//  Knotable
//
//  Created by Martin Ceperley on 3/31/14.
//
//

#import "NewKnoteCell.h"

@interface NewKnoteCell ()
@property(nonatomic , retain) UILabel *plusLabel;
@end

@implementation NewKnoteCell

- (id)init
{
    self = [super init];
    if (self) {

        _plusLabel = [[UILabel alloc] init];
        _plusLabel.text = @"+";
        _plusLabel.textAlignment = NSTextAlignmentCenter;
        _plusLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:100.0]/*[UIFont boldSystemFontOfSize:100.0]*/;
        _plusLabel.textColor = [UIColor grayColor];
        [self.bodyView addSubview:_plusLabel];
    
    }
    return self;
}


- (void)updateConstraints
{
    if (!self.didSetupConstraints){
        [_plusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(@0);
            make.centerY.equalTo(@-12);
        }];

    }
    [super updateConstraints];
}

@end
