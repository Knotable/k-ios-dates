//
//  Test.h
//  Mailer
//
//  Created by Martin Ceperley on 10/17/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message;

@interface Test : NSManagedObject

@property (nonatomic, retain) NSString * attribute;
@property (nonatomic, retain) NSOrderedSet *messages;
@end

@interface Test (CoreDataGeneratedAccessors)

- (void)insertObject:(Message *)value inMessagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMessagesAtIndex:(NSUInteger)idx;
- (void)insertMessages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMessagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMessagesAtIndex:(NSUInteger)idx withObject:(Message *)value;
- (void)replaceMessagesAtIndexes:(NSIndexSet *)indexes withMessages:(NSArray *)values;
- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSOrderedSet *)values;
- (void)removeMessages:(NSOrderedSet *)values;
@end
