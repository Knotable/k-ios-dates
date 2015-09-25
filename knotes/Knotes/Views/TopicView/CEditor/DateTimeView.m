//
//  DateTimerView.m
//  RevealControllerProject
//
//  Created by pythonhater on 13-11-22.
//
//

#import "DateTimeView.h"

#import "CUtil.h"
#import "DesignManager.h"
#import "YLMoment.h"

@interface DateTimeView()
{
}

@property (nonatomic, strong) UIView    *widgetView;
@property (nonatomic, strong) UILabel   *mainTitle;
@property (nonatomic, strong) UILabel   *indicateLable;
@property (nonatomic, strong) UILabel   *topLabel;
@property (nonatomic, strong) UILabel   *middleLabel;
@property (nonatomic, strong) UILabel   *bottomLabel;
@property (nonatomic, strong) UIView    *vLineView;

@property (nonatomic, strong) NSTimer   *refreshTimer;
@property (nonatomic, strong) NSDate    *selectDate;

@end
@implementation DateTimeView

-(void)dealloc
{
    [_refreshTimer invalidate];
    _refreshTimer = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        self.widgetView = [[UIView alloc] init];
         self.widgetView.layer.borderColor = [UIColor whiteColor].CGColor;
        //self.widgetView.layer.borderColor = [UIColor lightGrayColor].CGColor;
         self.widgetView.layer.borderWidth = 1;
         self.widgetView.layer.cornerRadius = 6;
        [self addSubview:self.widgetView];
        self.indicateLable = [[UILabel alloc] init];
        _indicateLable.textColor = [UIColor lightGrayColor];
        _indicateLable.textAlignment = NSTextAlignmentCenter;
        _indicateLable.numberOfLines = 0;
        _indicateLable.font =[DesignManager dateWidgetIndicateLabelFont];
        _indicateLable.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:self.indicateLable];
        
        self.mainTitle = [[UILabel alloc] init];
        _mainTitle.textColor = [DesignManager knoteBodyTextColor];
        _mainTitle.textAlignment = NSTextAlignmentCenter;
        _mainTitle.numberOfLines = 0;
        _mainTitle.font = [DesignManager dateWidgetMailLabelFont];
        _mainTitle.lineBreakMode = NSLineBreakByWordWrapping;
        [self addSubview:self.mainTitle];
        
        self.subTitle = [[RTLabel alloc] init];
        _subTitle.textColor =[DesignManager knoteBodyTextColor];
        _subTitle.font = [DesignManager knoteBodyFont];
        _subTitle.lineBreakMode = RTTextLineBreakModeWordWrapping;
        [self addSubview:self.subTitle];
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        self.topLabel = [[UILabel alloc] init];
        _topLabel.textColor = [UIColor blackColor];
        _topLabel.font = [DesignManager dateWidgetTopLabelFont];
        _topLabel.textAlignment = NSTextAlignmentLeft;
        _topLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.topLabel];
        
        self.middleLabel = [[UILabel alloc] init];
        _middleLabel.textColor = [UIColor lightGrayColor];
        _middleLabel.font = [DesignManager dateWidgetMidleLabelFont];
        _middleLabel.textAlignment = NSTextAlignmentLeft;
        _middleLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.middleLabel];
        
        self.bottomLabel = [[UILabel alloc] init];
        _bottomLabel.textColor = [UIColor lightGrayColor];
        _bottomLabel.font = [DesignManager dateWidgetBottomLabelFont];
        _bottomLabel.textAlignment = NSTextAlignmentLeft;
        _bottomLabel.backgroundColor = [UIColor clearColor];
        
        [self addSubview:self.bottomLabel];
        
        self.vLineView = [UIView new];
        self.vLineView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:self.vLineView];
        
        [self setTranslatesAutoresizingMaskIntoConstraints:NO];
        

    }
    return self;
}

-(void)setCurrentDate:(NSDate *)date
{
    NSString *dateStr = [_dateFormatter stringFromDate:date];
    
    NSArray *dateArray = [dateStr componentsSeparatedByString:@" "];
    if ([dateArray count]>4) {
        NSString *week = [dateArray objectAtIndex:0];
        NSString *month = [dateArray objectAtIndex:1];
        NSString *year = [dateArray lastObject];
        NSString *day = [dateArray objectAtIndex:2];
        NSString *time = [NSString stringWithFormat:@"%@ %@",[dateArray objectAtIndex:4],[dateArray objectAtIndex:5]];
        [self setMonth:[NSString stringWithFormat:@"%@ %@, %@",month,day,year] Day:week Time:time];
    }
}

-(void)setMonth:(NSString *)month Day:(NSString *)day Time:(NSString *)time
{
    _topLabel.text = month;
    _middleLabel.text = day;
    _bottomLabel.text = time;
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints
{
    [super updateConstraints];

    [self.widgetView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).offset(0);
        make.left.equalTo(self.mas_left).offset(0);
        make.height.equalTo(@(kWidgetHeight));
        make.bottom.equalTo(self.mas_bottom).offset(0);
    }];
    [self.mainTitle mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.widgetView.mas_top).offset(kVGap);
        make.height.equalTo(@(50));//todo
        make.left.equalTo(self.widgetView.mas_left);
        make.width.equalTo(@(kLeftSideWidth));
    }];
    [self.indicateLable mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mainTitle.mas_bottom).offset(-kVGap);
        make.height.equalTo(@(16));//todo
        make.left.equalTo(self.widgetView.mas_left).offset(-5);
        make.width.equalTo(@(kLeftSideWidth+10));
    }];
    [self.subTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).offset(kVGap);
        make.bottom.equalTo(self.widgetView.mas_top);
        make.left.equalTo(self.mas_left);
        make.right.equalTo(self.mas_right);
    }];
    
    [self.vLineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.widgetView.mas_top);
        make.bottom.equalTo(self.mas_bottom);
        make.width.equalTo(@(1));
        make.right.equalTo(self.mas_left).offset(kLeftSideWidth);
    }];
    [self.topLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.widgetView.mas_top).offset(10);
        make.height.equalTo(@(kWidgetTitleH));
        make.left.equalTo(self.mas_left).offset(kLeftSideWidth+10);
        make.right.equalTo(@0);
    }];
    
    [self.middleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.mas_left).offset(kLeftSideWidth+10);
        make.centerY.equalTo(self.widgetView.mas_centerY);
    }];
    
    [self.bottomLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.equalTo(@(kWidgetTitleH));
        make.bottom.equalTo(@(-10));
        make.left.equalTo(self.mas_left).offset(kLeftSideWidth+10);
        make.right.equalTo(@0);
    }];
}

#pragma mark * Private method
- (void)onTimer:(NSTimer*)timer
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:_selectDate];
    
    if (abs(timeInterval) < KDefaultCheckTime)
    {
        if (abs(timeInterval)<60*60)
        {
            self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                 target:self
                                                               selector:@selector(onTimer:)
                                                               userInfo:nil
                                                                repeats:NO];
        }
        else
        {
            self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kDefaultRefreshInterval
                                                                 target:self
                                                               selector:@selector(onTimer:)
                                                               userInfo:nil
                                                                repeats:NO];
        }
    }
    else
    {
        [self.refreshTimer invalidate];
        self.refreshTimer = nil;
    }
    
    [self setMainTitleByTimeInterval:timeInterval];
}

- (void)setSelectDate:(NSDate *)date withTitle:(NSString *)title {
    self.selectDate = date;
    [self setCurrentDate:self.selectDate];
    self.subTitle.text = title;
    
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:_selectDate];
    if (abs(timeInterval) < KDefaultCheckTime) {
        if (abs(timeInterval)<60*60) {
            self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(onTimer:) userInfo:nil repeats:NO];
        } else {
            self.refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kDefaultRefreshInterval target:self selector:@selector(onTimer:) userInfo:nil repeats:NO];
        }
    }
    [self setMainTitleByTimeInterval:timeInterval];
}

-(void)setMainTitleByTimeInterval:(NSTimeInterval)timeInterval {
    if(timeInterval < 0) {
        self.mainTitle.textColor = [DesignManager knoteBodyTextColor];
    } else {
        self.mainTitle.textColor = kCustomDarkRed;
    }
    self.mainTitle.text = [[[self getFormatOfIndicate:timeInterval] componentsSeparatedByString:@"|"] firstObject];
    CGFloat maxFontSize = 50;
    if ([self.mainTitle.text length]>3) {
        self.mainTitle.textColor = kCustomDarkRed;
        maxFontSize = 30;
        self.mainTitle.font = [[DesignManager dateWidgetMailLabelFont] fontWithSize:maxFontSize];
    }
    self.indicateLable.text = [[[self getFormatOfIndicate:timeInterval] componentsSeparatedByString:@"|"] lastObject];
    [self.mainTitle setNeedsDisplay];
    
    [self setNeedsUpdateConstraints];
}

#define kFlowYear 345 //day
#define kFlowMon 25 //day
#define kFlowHour 22 //hour

- (NSString *)getFormatOfIndicate:(NSTimeInterval)timeInterval {
#if 1
    YLMoment *moment = [[YLMoment alloc] initWithDate:_selectDate];
    NSString *passedMessage = [moment fromNowWithSuffix:NO];
    if (timeInterval > 0)
    {
        passedMessage = [passedMessage stringByAppendingString:@" passed"];
        return passedMessage;
    }
    else
    {
        NSTimeInterval year = timeInterval/(60*60*24*365);
        NSTimeInterval month = timeInterval/(60*60*24*30);
        NSTimeInterval day = timeInterval/(60*60*24);
        NSTimeInterval hour = timeInterval/(60*60);
        NSTimeInterval minute = timeInterval/60;
        timeInterval = -timeInterval;
        year = -year;
        month = -month;
        day = -day;
        hour = -hour;
        minute = -minute;
        
        if(minute>=1 && minute<60)
        {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            unsigned int unitFlags = NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *d = [calendar components:unitFlags fromDate:[NSDate date] toDate:_selectDate options:0];//计算时间差
            passedMessage = [NSString stringWithFormat:@"%.2d:%.2d|minutes remaining",(int)[d minute],(int)[d second]];
        }
        else
        {
            passedMessage = [passedMessage stringByAppendingString:@" remaining"];
        }
        return passedMessage;

    }
#else
    NSString *passedMessage = [[NSString alloc] init];
    NSTimeInterval year = timeInterval/(60*60*24*365);
    NSTimeInterval month = timeInterval/(60*60*24*30);
    NSTimeInterval day = timeInterval/(60*60*24);
    NSTimeInterval hour = timeInterval/(60*60);
    NSTimeInterval minute = timeInterval/60;
    if(timeInterval > 0)
    {
        if (day>=kFlowYear && day <= 366)
        {
            year = 1;
        }
        if(year>=1)
        {
            NSInteger iDay = (NSInteger)round(day)/365;
            if (iDay>=kFlowYear)
            {
                year += 1;
            }
            if(year>=2)
            {
                passedMessage = [NSString stringWithFormat:@"%ld|years passed",(long)year];
            }
            else
            {
                passedMessage = [NSString stringWithFormat:@"%ld|year passed",(long)year];
            }
        }
        else if(month>=1 && month<12)
        {
            NSInteger iDay = ((NSInteger)round(day))%31;
            if (iDay>=kFlowMon)
            {
                month += 1;
            }
            
            if(month>=2)
            {
                passedMessage = [NSString stringWithFormat:@"%ld|months passed",(long)month];
            }
            else
            {
                passedMessage = [NSString stringWithFormat:@"%ld|month passed",(long)month];
            }
        }
        else if(day>=1 && day<31)
        {
            NSInteger iHour = ((NSInteger)round(hour))%24;
            if (iHour >= kFlowHour)
            {
                day += 1;
            }
            if(day>=2)
            {
                passedMessage = [NSString stringWithFormat:@"%ld|days passed",(long)day];
            }
            else
            {
                passedMessage = [NSString stringWithFormat:@"%ld|day passed",(long)day];
            }
        }
        else if(hour>=1 && hour<24)
        {
            if (hour >= kFlowHour && hour <= 24)
            {
                passedMessage = [NSString stringWithFormat:@"1|day passed"];
            }
            else
            {
                if(hour>=2)
                {
                    passedMessage = [NSString stringWithFormat:@"%ld|hours passed",(long)hour];
                }
                else
                {
                    passedMessage = [NSString stringWithFormat:@"%ld|hour passed",(long)hour];
                }
            }
    
        }
        else if(minute>=1 && minute<60)
        {
            if(minute>=2)
            {
                passedMessage = [NSString stringWithFormat:@"%ld|minutes passed",(long)minute];
            }
            else
            {
                passedMessage = [NSString stringWithFormat:@"%ld|minute passed",(long)minute];
            }
        }
        else
        {
            passedMessage = [NSString stringWithFormat:@"0|minutes passed"];
        }
    }
    else
    {
        timeInterval = -timeInterval;
        year = -year;
        month = -month;
        day = -day;
        hour = -hour;
        minute = -minute;
        if (day>=345 && day <= 365)
        {
            year = 1;
        }
        if(year>=1)
        {
            NSInteger iDay = (NSInteger)round(day)/365;
            if (iDay>=kFlowYear)
            {
                year += 1;
            }
            if(year>=2)
            {
                passedMessage = [NSString stringWithFormat:@"%ld|years remaining",(long)year];
            }
            else
            {
                passedMessage = [NSString stringWithFormat:@"%ld|year remaining",(long)year];
            }
        }
        else if(month>=1 && month<12)
        {
            NSInteger iDay = ((NSInteger)round(day))%31;
            if (iDay>=kFlowMon)
            {
                month += 1;
            }
            
            if(month>=2)
            {
                passedMessage = [NSString stringWithFormat:@"%ld|months remaining",(long)month];
            }
            else
            {
                passedMessage = [NSString stringWithFormat:@"%ld|month remaining",(long)month];
            }
        }
        else if(day>=1 && day<31)
        {
            NSInteger iHour = ((NSInteger)round(hour))%24;
            if (iHour >= kFlowHour)
            {
                day += 1;
            }
            if(day>=2)
            {
                passedMessage = [NSString stringWithFormat:@"%ld|days remaining",(long)day];
            }
            else
            {
                passedMessage = [NSString stringWithFormat:@"%ld|day remaining",(long)day];
            }
        }
        else if(hour>=1 && hour<24)
        {
            if (hour >= kFlowHour)
            {
                passedMessage = [NSString stringWithFormat:@"1|day remaining"];
            }
            else
            {
                NSCalendar *calendar = [NSCalendar currentCalendar];
                unsigned int unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
                NSDateComponents *d = [calendar components:unitFlags fromDate:[NSDate date] toDate:_selectDate options:0];//计算时间差
                passedMessage = [NSString stringWithFormat:@"%.2d:%.2d|hours remaining",(int)[d hour],(int)[d minute]];
            }
        }
        else if(minute>=1 && minute<60)
        {
            NSCalendar *calendar = [NSCalendar currentCalendar];
            unsigned int unitFlags = NSMinuteCalendarUnit | NSSecondCalendarUnit;
            NSDateComponents *d = [calendar components:unitFlags fromDate:[NSDate date] toDate:_selectDate options:0];//计算时间差
            passedMessage = [NSString stringWithFormat:@"%.2d:%.2d|minutes remaining",(int)[d minute],(int)[d second]];
        }
        else
        {
            passedMessage = [NSString stringWithFormat:@"0|minutes passed"];
        }
    }
    
    return passedMessage;
#endif
}
@end
