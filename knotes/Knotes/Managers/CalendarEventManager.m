//
//  CalendarEventManager.m
//  Knotable
//
//  Created by Agus Guerra on 5/6/15.
//
//

#import "CalendarEventManager.h"

@interface CalendarEventManager()

@property (nonatomic, strong) NSMutableDictionary * eventsDiscarded;

@end

@implementation CalendarEventManager

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.eventStore = [[EKEventStore alloc] init];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        
        // Check if the access granted value for the events exists in the user defaults dictionary.
        if ([userDefaults valueForKey:@"eventkit_events_access_granted"] != nil) {
            // The value exists, so assign it to the property.
            self.eventsAccessGranted = [[userDefaults valueForKey:@"eventkit_events_access_granted"] intValue];
        }
        else{
            // Set the default value.
            self.eventsAccessGranted = NO;
        }
    }
    
    return self;
}

-(NSMutableDictionary *)eventsDiscarded{
    if(!_eventsDiscarded){
        _eventsDiscarded = [[NSMutableDictionary alloc] initWithCapacity:10]; // any number work
    }
    return _eventsDiscarded;
}

- (void)setEventsAccessGranted:(BOOL)eventsAccessGranted {
    _eventsAccessGranted = eventsAccessGranted;
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:eventsAccessGranted] forKey:@"eventkit_events_access_granted"];
}

- (void)markEventDiscardedByTitle:(NSString *)eventTitle{
    [self.eventsDiscarded setObject:eventTitle forKey:eventTitle];
}

- (EKEvent *)getNextEvent {
    
    EKEventStore *eventStore = [[EKEventStore alloc] init];
    
    NSDate *now = [NSDate date];
    NSTimeInterval fifteenMinutes = 15 * 60;
    NSTimeInterval oneHour = 60 * 60;
    
    NSDate *startDate1 = [NSDate dateWithTimeInterval:-oneHour sinceDate:now];
    NSPredicate *predicate1 = [eventStore predicateForEventsWithStartDate:startDate1 endDate:now calendars:nil];
    NSArray *eventsStartedFiveMinutesAgo = [eventStore eventsMatchingPredicate:predicate1];
    
    NSDate *endDate2 = [NSDate dateWithTimeInterval:fifteenMinutes sinceDate:now];
    NSPredicate *predicate2 = [eventStore predicateForEventsWithStartDate:now endDate:endDate2 calendars:nil];
    NSArray *events2 = [eventStore eventsMatchingPredicate:predicate2];
    
    if (eventsStartedFiveMinutesAgo.count > 0 &&
        !(([self getHoursBetween2Dates:eventsStartedFiveMinutesAgo.lastObject] > 23 || ((EKEvent *)eventsStartedFiveMinutesAgo.lastObject).isAllDay)))
    {
        EKEvent * event;
        for(int i = (eventsStartedFiveMinutesAgo.count - 1); i >= 0; i--){
            EKEvent * possibleEvent = (EKEvent*)[eventsStartedFiveMinutesAgo objectAtIndex:i];
            if(![self.eventsDiscarded objectForKey:possibleEvent.title]){
                if(!event.allDay){
                    event = possibleEvent;
                    break;
                }
            }
        }
        return event;
        //return eventsStartedFiveMinutesAgo.lastObject;
        
    } else{
        
        if (events2.count > 0)
        {
            EKEvent *lastEvent = events2.lastObject;
            
            if (lastEvent.isAllDay || [self getHoursBetween2Dates:lastEvent] > 23)
            {
                return nil;
            }
            else
            {
                EKEvent * event;
                for(int i = (events2.count - 1); i >= 0; i--){
                    EKEvent * possibleEvent = (EKEvent*)[events2 objectAtIndex:i];
                    if(![self.eventsDiscarded objectForKey:possibleEvent.title]){
                        if(!event.allDay){
                            event = possibleEvent;
                            break;
                        }
                    }
                }
                return event;
                //return events2.lastObject;
            }
        } else
        {
            return nil;
        }
    }
}

-(double)getHoursBetween2Dates:(EKEvent*)event
{
    NSTimeInterval distanceBetweenDates = [event.endDate timeIntervalSinceDate:event.startDate];
    double secondsInAnHour = 3600;
    double hoursBetweenDates = distanceBetweenDates / secondsInAnHour;
    
    return hoursBetweenDates;
}

- (NSString *)getNextEventTitle {
    if ([self getNextEvent]) {
        return [self getNextEvent].title;
    } else {
        return @"";
    }
}

@end
