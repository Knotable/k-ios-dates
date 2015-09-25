//
//  MeasureViewManager.m
//  Knotable
//
//  Created by wuli on 14-7-8.
//
//

#import "MeasureViewManager.h"
#import "DesignManager.h"
@interface MeasureViewManager()
@end
@implementation MeasureViewManager
SYNTHESIZE_SINGLETON_FOR_CLASS(MeasureViewManager);
- (id)init
{
    self = [super init];
    if (self) {
        if (!self.label) {
            self.label =[[RTLabel alloc] initWithFrame:CGRectMake(0, 0, 260, 10000)];
            [self.label sizeToFit];
            self.label.textColor =[DesignManager knoteBodyTextColor];
            self.label.font = [DesignManager knoteBodyFont];
            self.label.lineBreakMode = RTTextLineBreakModeWordWrapping;
        }
    }
    return self;
}
@end
