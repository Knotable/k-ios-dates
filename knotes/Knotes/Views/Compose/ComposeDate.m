//
//  ComposeDate.m
//  Knotable
//
//  Created by backup on 14-1-3.
//
//

#import "ComposeDate.h"
#import "DateTimeEditorView.h"
#import "LCCalendarView.h"
#import "ComposeTextField.h"
#include <time.h>
#include <xlocale.h>
#import "InputAccessViewManager.h"

#define kVDGap 10
#define kHDGap 10
#define kTitleItemH 22
#define kInputItemH 30
#define kTimeFormat @"hh:mm aa"
#define kComposeDateFormat @"MM/dd/yyyy"
#define kTFormat  "%a %b %d %H:%M:%S %z %Y"
#define kTimeFormat1 @"HH:mm:ss"


@interface ComposeDate ()
<
LCCalendarDelegate,
UITextFieldDelegate
>
@property (nonatomic, retain) LCCalendarView* calendar;
@property (nonatomic, strong) UILabel *dLabel;
@property (nonatomic, strong) UILabel *tLabel;
@property (nonatomic, strong) UIImageView *dateLabelBgView;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) ComposeTextField *inputTime;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) UIDatePicker *datePicker;

//@property (nonatomic, strong) DateTimeEditorView *dateEditor;
@end
@implementation ComposeDate

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.dLabel = [[UILabel alloc] init];
        _dLabel.textColor = [UIColor darkGrayColor];
        _dLabel.text = @"Date:";
        _dLabel.font = kCustomLightFont(kDefaultFontSize);
        [self addSubview:self.dLabel];
        self.tLabel = [[UILabel alloc] init];
        _tLabel.text = @"Time:";
        _tLabel.font = kCustomLightFont(kDefaultFontSize);

        _tLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:self.tLabel];
        
        self.dateLabel = [[UILabel alloc] init];
        _dateLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:self.dateLabel];
        _dateLabel.font = kCustomLightFont(kDefaultFontSize);
        self.dateLabelBgView = [[UIImageView alloc] init];
        [_dateLabelBgView addSubview:self.dateLabel];
        _dateLabelBgView.image = [CUtil imageWithName:@"text-field-bg" type:ImageStretchable];
        [self addSubview:self.dateLabelBgView];

        self.datePicker = [[UIDatePicker alloc]initWithFrame:CGRectZero];
        _datePicker.datePickerMode = UIDatePickerModeTime;
        self.datePicker.minimumDate = [NSDate date];
        [_datePicker addTarget:self action:@selector(changeTextFieldValue:) forControlEvents:UIControlEventValueChanged];
        self.inputTime = [[ComposeTextField alloc] init];
        self.inputTime.inputView = _datePicker;
        _inputTime.background = [UIImage imageNamed:@"text-field-bg"];
        _inputTime.font = kCustomLightFont(kDefaultFontSize);
        _inputTime.delegate = self;
        [self addSubview:self.inputTime];
        self.calendar = [[LCCalendarView alloc] initWithStartDay:startSunday frame:CGRectZero];
        _calendar.backgroundColor = [UIColor clearColor];
        
        [_calendar setTitleColor:[UIColor darkGrayColor]];
        [_calendar setTitleFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:kDefaultFontSize]];
        
        [_calendar setDayOfWeekFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:10.0]];
        [_calendar setDayOfWeekTextColor:[UIColor darkGrayColor]];
        [_calendar setDayOfWeekBottomColor:UIColorFromRGB(0xCCCFD5) topColor:[UIColor whiteColor]];
        
        [_calendar setDateFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0]];
        [_calendar setDateTextColor:UIColorFromRGB(0x393B40)];
        [_calendar setDateBackgroundColor:UIColorFromRGB(0xF2F2F2)];
        [_calendar setDateBorderColor:UIColorFromRGB(0xDAE1E6)];
        
        [_calendar setSelectedDateTextColor:UIColorFromRGB(0xF2F2F2)];
        [_calendar setSelectedDateBackgroundColor:UIColorFromRGB(0x88B6DB)];
        
        [_calendar setCurrentDateTextColor:UIColorFromRGB(0x622202)];
        [_calendar setCurrentDateBackgroundColor:UIColorFromRGB(0xEEEEF3)];
        [_calendar setDelegate:self];
        [self addSubview:_calendar];
        
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [_dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
        
    
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureUpdated:)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.numberOfTouchesRequired = 1;
        tapGesture.cancelsTouchesInView = NO;
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}
- (void)tapGestureUpdated:(UITapGestureRecognizer *)tapGesture
{
    if ([self.inputText isFirstResponder]) {
        [self.inputText resignFirstResponder];
    }
    if ([self.inputTime isFirstResponder]) {
        [self.inputTime resignFirstResponder];
    }
}

#pragma mark LCCalendarDelegate methods
- (void)calendar:(LCCalendarView *)calendar didSelectDate:(NSDate *)date
{
    struct tm  sometime = {0};
    [self.dateFormatter setDateFormat:kTimeFormat1];
    
    NSString *realTime = [self.dateFormatter stringFromDate:self.datePicker.date];
    //        NSString *realTime = [NSString stringWithFormat:@"%@:%@:00",_hourDial.selectedString,_MinuteDial.selectedString];
    [self.dateFormatter setDateFormat:kCtlDateFormat];
    NSString *time = [_dateFormatter stringFromDate:_calendar.selectedDate];
    NSArray *array = [time componentsSeparatedByString:@" "];
    NSRange range = [time rangeOfString:[array objectAtIndex:3]];
    time = [time stringByReplacingCharactersInRange:range withString:realTime];
    const char *cstr = [time cStringUsingEncoding:NSASCIIStringEncoding];
    (void)strptime_l(cstr, kTFormat, &sometime, NULL);
    NSDate *selectDate = [NSDate dateWithTimeIntervalSince1970: mktime(&sometime)];
    
    if ([selectDate compare:[NSDate date]] == NSOrderedAscending) {
        [self.calendar setSelectedDate:[NSDate date]];
        return;
    }
    
    [self.calendar setSelectedDate:selectDate];
    self.datePicker.date = selectDate;
    
    [self.dateFormatter setDateFormat:kComposeDateFormat];
    self.dateLabel.text = [self.dateFormatter stringFromDate:date];
}

- (void)updateConstraints
{
    [super updateConstraints];
    [self.dLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.inputText.mas_bottom).offset(kVGap);
        make.left.equalTo(self.bgView.mas_left).offset(kHDGap);
        make.right.equalTo(self.tLabel.mas_left).offset(-2*kHDGap);
        make.height.equalTo(@(kTitleItemH));
        make.width.equalTo(self.tLabel.mas_width);
    }];
    [self.tLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.inputText.mas_bottom).offset(kVGap);
        make.right.equalTo(self.bgView.mas_right).offset(-kHDGap);
        make.height.equalTo(@(kTitleItemH));
        make.width.equalTo(self.dLabel.mas_width);

    }];
    [self.dateLabelBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dLabel.mas_bottom).offset(kVGap);
        make.left.equalTo(self.dLabel.mas_left).offset(0);
        make.right.equalTo(self.dLabel.mas_right).offset(0);
        make.height.equalTo(@(kInputItemH));
        make.width.equalTo(self.tLabel.mas_width);
    }];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dateLabelBgView.mas_top).offset(2);
        make.left.equalTo(self.dateLabelBgView.mas_left).offset(4);
        make.right.equalTo(self.dateLabelBgView.mas_right).offset(4);
        make.bottom.equalTo(self.dateLabelBgView.mas_bottom).offset(2);
    }];
    [self.inputTime mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.dLabel.mas_bottom).offset(kVGap);
        make.left.equalTo(self.tLabel.mas_left).offset(0);
        make.right.equalTo(self.tLabel.mas_right).offset(0);
        make.height.equalTo(@(kInputItemH));
        make.width.equalTo(self.tLabel.mas_width);
    }];
    
    [self.calendar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.inputTime.mas_bottom).offset(kVGap);
        make.left.equalTo(self.bgView.mas_left).offset(kHDGap);
        make.right.equalTo(self.bgView.mas_right).offset(-kHDGap);
        make.height.equalTo(@300);
    }];
}

-(void)changeTextFieldValue:(id)sender
{
    UIDatePicker *datePicker = (UIDatePicker *)sender;
    NSDate *date = [datePicker date];
    [self.dateFormatter setDateFormat:kTimeFormat];
    NSString *dateString = [self.dateFormatter stringFromDate:date];
    self.inputTime.text = dateString;
    [_calendar setSelectedDate:date];
}
#pragma mark ComposeProtocol
- (void)setTitlePlaceHold:(NSString *)str
{
    self.inputText.placeholder = str;
}
- (void)setTitleContent:(NSString *)str
{
    if (str && [str length]>0) {
        self.inputText.text = str;
    }
}
- (void)setCotent:(id)content
{
    NSDate *date = (NSDate *)content;
    [_calendar setMonthShowing:date];
    [_calendar setSelectedDate:date];
    self.datePicker.date = date;
    
    [self.dateFormatter setDateFormat:kComposeDateFormat];
    self.dateLabel.text = [self.dateFormatter stringFromDate:date];
    [self.dateFormatter setDateFormat:kTimeFormat];
    self.inputTime.text = [self.dateFormatter stringFromDate:date];
}
- (id)getCotent
{
    return self.datePicker.date;
}
- (NSString *)getTitle
{
    [self.inputText endEditing:YES];
    return self.inputText.text;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [textField resignFirstResponder];
}
-(BOOL)becomeFirstResponder
{
    self.inputText.inputAccessoryView =[[InputAccessViewManager sharedInstance] inputAccessViewWithOutCamera];
    self.inputTime.inputAccessoryView = [[InputAccessViewManager sharedInstance] inputAccessViewWithOutCamera];
    return [self.inputText becomeFirstResponder];
}
@end
