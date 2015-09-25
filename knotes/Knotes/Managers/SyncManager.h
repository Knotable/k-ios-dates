//
//  SyncManager.h
//  Knotable
//
//  Created by Dhruv on 5/8/15.
//
//

#import <Foundation/Foundation.h>
#import "CItem.h"

@interface SyncManager : NSObject
@property (nonatomic, strong) NSTimer *checkTimer;

+ (instancetype)sharedInstance;
@end
