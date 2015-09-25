//
//  CDateItem.h
//  RevealControllerProject
//
//  Created by backup on 13-10-17.
//
//

#import "CItem.h"
#if NEW_DESIGN
#import "CreplyUtils.h"
#endif

@interface CDateItem : CItem
@property (nonatomic, retain) NSDate* date;
@property (nonatomic, retain) NSDate* deadline;
+ (CGFloat)getCustomHeight:(MessageEntity *)message;
@end
