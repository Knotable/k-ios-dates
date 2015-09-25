//
//  CalendarEventManager.h
//  Knotable
//
//  Created by Agus Guerra on 5/6/15.
//
//

#import <Foundation/Foundation.h>
#import <EventKit/EventKit.h>

@interface CalendarEventManager : NSObject

@property (nonatomic) BOOL eventsAccessGranted;
@property (nonatomic, strong) EKEventStore *eventStore;

- (EKEvent *)getNextEvent;
- (NSString *)getNextEventTitle;
- (void)markEventDiscardedByTitle:(NSString *)eventTitle;

@end
