//
//  MDataManager.h
//  Mailer
//
//  Created by Martin Ceperley on 9/30/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

+ (MDataManager *)sharedManager;

- (void)setupStack;

- (void)saveContextAndWait;
- (void)saveContextAsync;
- (void)saveContextAsyncCompletion:(void (^)(BOOL success, NSError *error))completion;

@end
