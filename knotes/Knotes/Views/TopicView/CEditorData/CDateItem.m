//
//  CDateItem.m
//  RevealControllerProject
//
//  Created by backup on 13-10-17.
//
//

#import "CDateItem.h"
#import "DateTimeView.h"
#import "DesignManager.h"
#import "CUtil.h"

@implementation CDateItem

@synthesize height = _height;

-(id)init {
    self = [super init];
    if (self) {
        self.type = C_DATE;
        self.date = [NSDate date];
    }
    return self;
}

-(int) getHeight
{
    return 0;
}
#if !NEW_DESIGN
-(int) getCellHeight
{
    CGRect rect =   [CUtil getTextRect:self.userData.title Font:[DesignManager knoteBodyFont] Width:CGRectGetWidth([UIScreen mainScreen].bounds) * (270.0/320.0)];
    _height = kWidgetHeight +CGRectGetHeight(rect) + 56;
    // Lin - Ended
    
    if (self.userData.replys) {
        _height+=20;
    }
#if NEW_FEATURE
    if (!self.userData.expanded)
    {
        _height-=35;
    }
#endif
    return _height;

}
#else
-(int) getCellHeight
{
   //CGRect rect =   [CUtil getTextRect:self.userData.title Font:[DesignManager knoteBodyFont] Width:CGRectGetWidth([UIScreen mainScreen].bounds) * (270.0/320.0)];
    _height = kWidgetHeight /*+CGRectGetHeight(rect)*/ + 30;
    // Lin - Ended
    
    CreplyUtils *cre=[[CreplyUtils alloc]init];
    _height +=[cre getSizeOfReplyView:self];
    _height+=[cre getHeightOfTitleInfo:self.userData];
     return _height;
    
}
#endif
- (void)setCommonValueByMessage:(MessageEntity *)message
{
    [super setCommonValueByMessage:message];
    self.deadline  = [NSKeyedUnarchiver unarchiveObjectWithData:message.content];
}

- (NSMutableDictionary *)dictionaryValue
{
    NSMutableDictionary *dict = [super dictionaryValue];
    
    dict[@"deadline_subject"] = self.userData.title;
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    format.dateFormat =kCtlDateFormat;
    [format setTimeZone:[NSTimeZone localTimeZone]];
    dict[@"local_deadline"] = [format stringFromDate:self.deadline];
    dict[@"deadline"] = @{@"$date": [NSNumber numberWithLongLong:[NSString stringWithFormat:@"%.0f000",[self.deadline timeIntervalSince1970]].longLongValue]};

    dict[@"type"] = @"deadline";
    dict[@"status"] = @"ready";
    dict[@"cname"] = @"knotes";
    
    return dict;
}

+ (CGFloat)getCustomHeight:(MessageEntity *)message
{
    CGFloat height = kWidgetHeight;

    CGRect rect =   [CUtil getTextRect:message.title Font:[DesignManager knoteBodyFont] Width:CGRectGetWidth([UIScreen mainScreen].bounds) * (270.0/320.0)];
    height = kWidgetHeight +CGRectGetHeight(rect) + 56;
    return height;
}
@end
