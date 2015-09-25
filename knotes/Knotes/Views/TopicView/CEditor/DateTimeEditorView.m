//
//  DateTimeEditorView.m
//  RevealControllerProject
//
//  Created by backup on 13-11-28.
//
//

#import "DateTimeEditorView.h"

#import "LCCalendarView.h"
#import "DialController.h"
#import "CUtil.h"

#include <time.h>
#include <xlocale.h>

#define DIAL_OFFSET_X               40
#define DIAL_OFFSET_Y               0
#define DIAL_WIDTH                  30
#define DIAL_HEIGHT                 150

//Tue Sep 06 21:37:19 +0800 2011
//"%a %b %d %H:%M:%S %z %Y";
#define kTFormat  "%a %b %d %H:%M:%S %z %Y"
#define kTimeFormat @"HH:mm"

@interface DateTimeEditorView()<LCCalendarDelegate, DialControllerDelegate>

@property (nonatomic, retain) NSDateFormatter *timeFormatter;
@property (nonatomic, retain) LCCalendarView* calendar;
@property (nonatomic, retain) UIImageView *timeOverlayView;
@property (nonatomic, retain) DialController *hourDial;
@property (nonatomic, retain) DialController *MinuteDial;
@end
@implementation DateTimeEditorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        if (!_timeFormatter) {
            _timeFormatter = [[NSDateFormatter alloc] init];
            _timeFormatter.dateFormat =kTimeFormat;
            [_timeFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
            [_timeFormatter setTimeZone:[NSTimeZone localTimeZone]];
        }
        if (!self.hourDial) {
            NSMutableArray *numbers = [[NSMutableArray alloc] initWithCapacity:3];//[NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16", nil];
            for (int i = 0; i<24; i++) {
                NSString *s = nil;
                if (i<10) {
                    s = [NSString stringWithFormat:@"0%d",i];
                } else {
                    s = [NSString stringWithFormat:@"%d",i];
                }
                [numbers addObject:s];
            }
            int dialCount = 0;
            self.hourDial = [[DialController alloc] initWithDialFrame:CGRectMake(DIAL_OFFSET_X + dialCount++ * DIAL_WIDTH, DIAL_OFFSET_Y, DIAL_WIDTH, DIAL_HEIGHT) strings:[numbers copy]] ;
            self.hourDial.delegate = self;
            
            
            [self addSubview:self.hourDial];
        }
        if (!self.MinuteDial) {
            NSMutableArray *numbers = [[NSMutableArray alloc] initWithCapacity:3];
            for (int i = 0; i<60; i++) {
                NSString *s = nil;
                if (i<10) {
                    s = [NSString stringWithFormat:@"0%d",i];
                } else {
                    s = [NSString stringWithFormat:@"%d",i];
                }
                [numbers addObject:s];
            }
            int dialCount = 0;
            
            self.MinuteDial = [[DialController alloc] initWithDialFrame:CGRectMake(DIAL_OFFSET_X + dialCount++ * DIAL_WIDTH, DIAL_OFFSET_Y, DIAL_WIDTH, DIAL_HEIGHT) strings:[numbers copy]] ;
            self.MinuteDial.delegate = self;
            
            [self addSubview:self.MinuteDial];
        }
        if (!_timeOverlayView) {
            _timeOverlayView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"overlay.png"]] ;
            [self addSubview:_timeOverlayView];
        }
    }
    return self;
}

- (void)setDateForCalendar:(NSDate *)deadline
{
    if (!_calendar) {
        _calendar = [[LCCalendarView alloc] initWithStartDay:startSunday frame:CGRectMake(20, 30, 250, 100)];
        _calendar.backgroundColor = [UIColor clearColor];
        
        [_calendar setTitleColor:[UIColor darkGrayColor]];
        [_calendar setTitleFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:14.0]];
        
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
        _calendar.cellHeight = 22;
        [_calendar setMonthShowing:deadline];
        [_calendar setSelectedDate:deadline];
        [self addSubview:_calendar];
    }
    [_calendar setMonthShowing:deadline];
    [_calendar setSelectedDate:deadline];

    NSString *timeStr = [_timeFormatter stringFromDate:deadline];
    NSArray *timeArrayy = [timeStr componentsSeparatedByString:@":"];
    NSInteger h = [[timeArrayy objectAtIndex:0] integerValue];
    NSString *hour  = nil;
    if (h<10) {
        hour = [NSString stringWithFormat:@"0%d",h];
    } else {
        hour = [NSString stringWithFormat:@"%d",h];
    }
    [self.hourDial spinToString:hour];
    [self.MinuteDial spinToString:[[[timeArrayy objectAtIndex:1] componentsSeparatedByString:@" "] objectAtIndex:0]];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat startY=0;
    CGFloat startX=0;
    CGFloat ctlHeight = 0;
    _calendar.frame = CGRectMake(startX, startY, self.bounds.size.width-96, ctlHeight);
    startX+=(self.bounds.size.width-96)+10;
    
    _timeOverlayView.frame = CGRectMake(startX, startY, DIAL_WIDTH*2+2, DIAL_HEIGHT);
    self.hourDial.frame = CGRectMake(startX, startY, DIAL_WIDTH, DIAL_HEIGHT);
    startX+=(DIAL_WIDTH+2);
    self.MinuteDial.frame = CGRectMake(startX, startY, DIAL_WIDTH, DIAL_HEIGHT);
}

#pragma mark LCCalendarDelegate methods
- (void)calendar:(LCCalendarView *)calendar didSelectDate:(NSDate *)date
{
    if (_hourDial.selectedString&&_MinuteDial.selectedString) {
        struct tm  sometime = {0};
        NSString *realTime = [NSString stringWithFormat:@"%@:%@:00",_hourDial.selectedString,_MinuteDial.selectedString];
        NSString *time = [_dateFormatter stringFromDate:_calendar.selectedDate];
        NSArray *array = [time componentsSeparatedByString:@" "];
        NSRange range = [time rangeOfString:[array objectAtIndex:3]];
        time = [time stringByReplacingCharactersInRange:range withString:realTime];
        const char *cstr = [time cStringUsingEncoding:NSASCIIStringEncoding];
        (void)strptime_l(cstr, kTFormat, &sometime, NULL);
        NSDate *selectDate = [NSDate dateWithTimeIntervalSince1970: mktime(&sometime)];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(DateTimeEditor:didChangeDate:)]) {
            [self.delegate DateTimeEditor:self didChangeDate:selectDate];
        }
        [_calendar setSelectedDate:selectDate];
        DLog(@"NSDate is %@", selectDate);
    }
}

#pragma mark DialControllerDelegate methods

- (void)dialController:(DialController *)dial didSnapToString:(NSString *)value {
    // Convert string to date object
    if (_hourDial.selectedString&&_MinuteDial.selectedString) {
        struct tm  sometime = {0};
        NSString *realTime = [NSString stringWithFormat:@"%@:%@:00",_hourDial.selectedString,_MinuteDial.selectedString];
        NSString *time = [_dateFormatter stringFromDate:_calendar.selectedDate];
        NSArray *array = [time componentsSeparatedByString:@" "];
        NSRange range = [time rangeOfString:[array objectAtIndex:3]];
        time = [time stringByReplacingCharactersInRange:range withString:realTime];
        const char *cstr = [time cStringUsingEncoding:NSASCIIStringEncoding];
        (void)strptime_l(cstr, kTFormat, &sometime, NULL);
        NSDate *selectDate = [NSDate dateWithTimeIntervalSince1970: mktime(&sometime)];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(DateTimeEditor:didChangeDate:)]) {
            [self.delegate DateTimeEditor:self didChangeDate:selectDate];
        }
        [_calendar setSelectedDate:selectDate];
        DLog(@"NSDate is %@", selectDate);
    }
}



@end
