//
//  MeasureViewManager.h
//  Knotable
//
//  Created by wuli on 14-7-8.
//
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "RTLabel.h"
@interface MeasureViewManager : NSObject
@property(nonatomic, strong) RTLabel *label;
+ (MeasureViewManager *)sharedInstance;

@end
