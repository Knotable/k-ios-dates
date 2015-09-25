//
//  KeyKnoteCell.m
//  Knotable
//
//  Created by Martin Ceperley on 12/23/13.
//
//

#import "KeyKnoteCell.h"
#import "MessageEntity.h"
#import "DesignManager.h"

@interface KeyKnoteCell ()

@property (nonatomic, strong) UIImageView *pinIcon;

@end


@implementation KeyKnoteCell

- (id)init
{
    self = [super init];
    if (self) {
        _bodyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _bodyLabel.textColor = [DesignManager knoteBodyTextColor];
        //_bodyLabel.font = [UIFont systemFontOfSize:16.0];
        _bodyLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
        _bodyLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _bodyLabel.numberOfLines = 0;
        _bodyLabel.backgroundColor = [UIColor yellowColor];
        [self.bodyView addSubview:_bodyLabel];

        _pinIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin"]];
        [self.bodyView addSubview:_pinIcon];
        
        self.shouldHideHeader = YES;
        
    }
    return self;
}

- (void)setMessage:(MessageEntity *)message
{
    [super setMessage:message];
    self.bodyLabel.text = message.body;
}

- (void)updateConstraints
{
    if (!self.didSetupConstraints){
        [super updateConstraints];
        [self.bodyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.edges.equalTo(@0.0);
        }];
        
        [self.pinIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@4.0);
            make.right.equalTo(@4.0);
        }];
        
    } else {
        [super updateConstraints];
    }
}

@end
