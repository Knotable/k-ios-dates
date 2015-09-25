//
//  LCCalendarView.h
//  RevealControllerProject
//
//  Created by Chen on 9/28/13.
//
//

@protocol LCCalendarDelegate;

@interface LCCalendarView : UIView

enum {
    startSunday = 1,
    startMonday = 2,
};
typedef int startDay;

@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, weak) id<LCCalendarDelegate> delegate;
@property(nonatomic, assign) CGFloat cellHeight;
- (id)initWithStartDay:(startDay)firstDay;
- (id)initWithStartDay:(startDay)firstDay frame:(CGRect)frame;

// Theming
- (void)setTitleFont:(UIFont *)font;
- (UIFont *)titleFont;

- (void)setTitleColor:(UIColor *)color;
- (UIColor *)titleColor;

- (void)setButtonColor:(UIColor *)color;

- (void)setInnerBorderColor:(UIColor *)color;

- (void)setDayOfWeekFont:(UIFont *)font;
- (UIFont *)dayOfWeekFont;

- (void)setDayOfWeekTextColor:(UIColor *)color;
- (UIColor *)dayOfWeekTextColor;

- (void)setDayOfWeekBottomColor:(UIColor *)bottomColor topColor:(UIColor *)topColor;

- (void)setDateFont:(UIFont *)font;
- (UIFont *)dateFont;

- (void)setDateTextColor:(UIColor *)color;
- (UIColor *)dateTextColor;

- (void)setDateBackgroundColor:(UIColor *)color;
- (UIColor *)dateBackgroundColor;

- (void)setDateBorderColor:(UIColor *)color;
- (UIColor *)dateBorderColor;

- (void)setMonthShowing:(NSDate *)aMonthShowing;
- (void)moveCalendarToNextMonth;
- (void)moveCalendarToPreviousMonth;

@property (nonatomic, strong) UIColor *selectedDateTextColor;
@property (nonatomic, strong) UIColor *selectedDateBackgroundColor;
@property (nonatomic, strong) UIColor *currentDateTextColor;
@property (nonatomic, strong) UIColor *currentDateBackgroundColor;

@end

@protocol LCCalendarDelegate <NSObject>

- (void)calendar:(LCCalendarView *)calendar didSelectDate:(NSDate *)date;

@end
