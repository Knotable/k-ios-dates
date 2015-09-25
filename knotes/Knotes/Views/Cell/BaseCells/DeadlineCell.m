//
//  DeadlineCell.m
//  Knotable
//
//  Created by Martin Ceperley on 12/22/13.
//
//

#import "DeadlineCell.h"
#import "MessageEntity.h"
#import "DesignManager.h"
#import "DateTimeView.h"

@interface DeadlineCell ()
@property (nonatomic, strong) DateTimeView *datetimeView;
@end

@implementation DeadlineCell

- (id)init
{
    self = [super init];
    if (self) {
        _datetimeView = [[DateTimeView alloc] init];
        [self.bodyView addSubview:_datetimeView];
    }
    return self;
}


- (void)setMessage:(MessageEntity *)message
{
    [super setMessage:message];
    NSDate *deadline1 = [NSKeyedUnarchiver unarchiveObjectWithData:message.content];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    format.dateFormat =kCtlDateFormat1;
    [format setTimeZone:[NSTimeZone localTimeZone]];
    _datetimeView.dateFormatter = format;
    [_datetimeView setSelectDate:deadline1 withTitle:message.title];
}

- (void)updateConstraints
{

    if (!self.didSetupConstraints){
        [super updateConstraints];
        
        [self.datetimeView mas_makeConstraints:^(MASConstraintMaker *make) {
            [self.datetimeView.subTitle setFrame:CGRectMake(0, 0, 256, 10000000)];
            
            make.height.greaterThanOrEqualTo(@(kWidgetHeight+self.datetimeView.subTitle.optimumSize.height+10));
            make.left.equalTo(self.bodyView);
            make.right.equalTo(self.bodyView);
            make.top.equalTo(self.bodyView).offset(20);
            make.bottom.equalTo(self.bodyView);
        }];
        
    } else {
        [super updateConstraints];
    }
}

- (void)setMaxWidth
{
}


@end
