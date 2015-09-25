//
//  NSMutableArray+KnotableArray.m
//  Knotable
//
//  Created by Lin on 23/12/14.
//
//

#import "NSMutableArray+KnotesArray.h"
#import "CItem.h"

@implementation NSMutableArray (KnotableArray)

-(NSMutableArray*)ReorganizedArrayWithNewDatasource:(NSArray*)theEarlierEntities
{
#if 1
    theEarlierEntities = [[theEarlierEntities reverseObjectEnumerator] allObjects];
    
    for(int i = 0; i < [theEarlierEntities count]; i++)
    {
        [self insertObject:[theEarlierEntities objectAtIndex:i] atIndex:0];
    }
    
    return self;
#else
    NSMutableIndexSet* indexSet = [NSMutableIndexSet indexSet];
    
    NSUInteger i = 0;
    
    // self items have itemId "temp.*" format text
    for (i = 0; i < self.count; i++) {
        CItem* otherItem = [self objectAtIndex: i];
        for (CItem* item in theEarlierEntities)
        {
            NSRange range = [otherItem.itemId rangeOfString: item.itemId];
            if (range.location != NSNotFound)
            {
                [indexSet addIndex: i];
                break;
            }
        }
    }
    [self removeObjectsAtIndexes: indexSet];

   
    [self addObjectsFromArray: theEarlierEntities];
    [self sortUsingSelector: @selector(compare:)];
    
    return self;
#endif
}

@end
