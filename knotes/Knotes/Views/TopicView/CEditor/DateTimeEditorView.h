//
//  DateTimeEditorView.h
//  RevealControllerProject
//
//  Created by backup on 13-11-28.
//
//

#import <UIKit/UIKit.h>
#import "CDateItem.h"
#import "CEditDateItemView.h"
@class DateTimeEditorView;
@protocol DateTimeEditorViewDelegate <NSObject>
- (void)DateTimeEditor:(DateTimeEditorView *)dateView didChangeDate:(NSDate *)date;
@end
@interface DateTimeEditorView : UIView
@property (nonatomic, weak) id <DateTimeEditorViewDelegate> delegate;
@property (nonatomic, retain) NSDateFormatter *dateFormatter;
- (void)setDateForCalendar:(NSDate *)deadline;
@end
