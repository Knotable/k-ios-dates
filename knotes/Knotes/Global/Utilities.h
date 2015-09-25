//
//  Utilities.h
//  Knotable
//
//  Created by Emiliano Barcia on 17/08/14.
//
//

#import <Foundation/Foundation.h>
#import "TopicsEntity.h"

@interface Utilities : NSObject

#define NULL_TO_NIL(obj) ({ __typeof__ (obj) __obj = (obj); __obj == [NSNull null] ? nil : obj; })

+ (UIImage *) imageResize : (UIImage*) img
              andResizeTo : (CGSize) newSize ;

+ (UIImage *) scaleImageProportionally : (UIImage *) image
                                maxSize: (NSInteger) maxSize ;

+ (UIImage *) scaleImage : (UIImage*) image
            toResolution : (NSInteger) resolution ;

+ (UIImage *) takeSnapshotFromWholeView ;
-(NSString *)getTopicURLFrom:(TopicsEntity *)topic;

+ (NSInteger)hoursBetween:(NSDate *)firstDate and:(NSDate *)secondDate;
+ (NSInteger)minutesBetween:(NSDate *)firstDate and:(NSDate *)secondDate;

@end
