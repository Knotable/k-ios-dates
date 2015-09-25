//
//  DateTimerView.h
//  RevealControllerProject
//
//  Created by pythonhater on 13-11-22.
//
//

#import <UIKit/UIKit.h>
#import "CDateItem.h"
#import "RTLabel.h"

#define kWidgetHeight 80
#define kLeftSideWidth 88.0

@interface DateTimeView : UIView
@property (nonatomic, strong) RTLabel *subTitle;
- (void)setSelectDate:(NSDate *)date withTitle:(NSString *)title;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
@end
