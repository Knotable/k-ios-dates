//
//  CEditDateItemView.m
//  RevealControllerProject
//
//  Created by backup on 13-10-16.
//
//

#import "CEditDateItemView.h"

#import "DatetimeView.h"
#import "DateTimeEditorView.h"

#import "CUtil.h"
#import "CDateItem.h"

@interface CEditDateItemView ()<UITextFieldDelegate,DateTimeEditorViewDelegate>
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@end

@implementation CEditDateItemView

@synthesize datetimeView = _datetimeView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.needsRelayout = YES;
        self.infoBarHeight = 0;
        if (!_dateFormatter) {
            _dateFormatter = [[NSDateFormatter alloc] init];
            [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
            _dateFormatter.dateFormat =kCtlDateFormat1;
            [_dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        }

        if (!_datetimeView) {
            _datetimeView = [[DateTimeView alloc] init];
            _datetimeView.dateFormatter = self.dateFormatter;
            [self.contentView addSubview:_datetimeView];
        }
    }
    return self;
}


- (void)updateConstraints
{
    [super updateConstraints];

    [self.datetimeView mas_remakeConstraints:^(MASConstraintMaker *make) {
        
#if NEW_DESIGN
        CreplyUtils *cre=[[CreplyUtils alloc]init];
        CGFloat newheight=[cre getHeightOfTitleInfo:_itmTemp.userData];
        make.top.equalTo(self.mas_top).offset(newheight);
#else
        make.top.equalTo(self.mas_top).offset(10);
#endif
        make.height.equalTo(@(kWidgetHeight+self.datetimeView.subTitle.optimumSize.height+10));
#if NEW_FEATURE
        
#else
        
        make.height.equalTo(@(kWidgetHeight+self.datetimeView.subTitle.optimumSize.height+10));
        
        if (self.pinButton && !self.pinButton.hidden)
        {
            make.bottom.equalTo(self.pinButton.mas_top).offset(-10);
        }
        else
        {
            make.bottom.equalTo(self.bgView);
        }
#endif
#if NEW_DESIGN
        make.left.equalTo(self.mas_left).offset(4);
        
        make.right.equalTo(self.mas_right).offset(-4);
#else
        make.left.equalTo(self.mas_left).offset(kTheadLeftGap);
        
        make.right.equalTo(self.mas_right).offset(-12);
#endif
    }];
}

#pragma mark DateTimeEditorViewDelegate methods
- (void)DateTimeEditor:(DateTimeEditorView *)dateView didChangeDate:(NSDate *)date
{
    CDateItem* itemData = (CDateItem*) [self getItemData];
    itemData.deadline = date;
}

-(int) getHeight
{
    return 300;
}

-(int) getCellHeight
{
    return [self getHeight];
}

-(void) setItemData:(CItem*) itemData
{
    [super setItemData:itemData];
#if NEW_DESIGN
    _itmTemp=itemData;
#endif
    CDateItem *iData = (CDateItem *)itemData;
#if NEW_DESIGN
    [_datetimeView setSelectDate:iData.deadline withTitle:@""];
#else
    [_datetimeView setSelectDate:iData.deadline withTitle:iData.title];
#endif
    [self setNeedsUpdateConstraints];
}

-(CItem*) getItemData
{
    return [super getItemData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
	return [textField resignFirstResponder];
}
- (BOOL)becomeFirstResponder
{
    return NO;
}
-(BOOL)isFirstResponder
{
    BOOL flag = NO;
    return flag;
}
-(BOOL)resignFirstResponder
{
    BOOL flag = NO;
    return flag;
}
@end
