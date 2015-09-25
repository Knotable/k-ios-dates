//
//  MDataManager.m
//  Mailer
//
//  Created by Martin Ceperley on 9/30/13.
//  Copyright (c) 2013 Knotable. All rights reserved.
//

#import "MDataManager.h"

@implementation MDataManager


+ (MDataManager *)sharedManager
{
    static MDataManager *dataManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dataManager = [[MDataManager alloc] init];
    });
    return dataManager;
}

- (void)setupStack
{
    [MagicalRecord setShouldDeleteStoreOnModelMismatch:YES];
    [MagicalRecord setupCoreDataStack];
    
    //[MagicalRecord setShouldAutoCreateDefaultPersistentStoreCoordinator:YES];
    
    /*
    NSString *dbName = @"Mailable.sqlite";
    
    [MagicalRecord setShouldDeleteStoreOnModelMismatch:YES];
    NSPersistentStoreCoordinator* coordinator = [NSPersistentStoreCoordinator MR_coordinatorWithSqliteStoreNamed:dbName];
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [context performBlockAndWait:^{
        [context setPersistentStoreCoordinator:coordinator];
        [NSPersistentStoreCoordinator MR_setDefaultStoreCoordinator:coordinator];

    }];
     
     */
}

- (void)saveContextAsyncCompletion:(void (^)(BOOL success, NSError *error))completion
{
    [self.managedObjectContext saveToPersistentStoreWithCompletion:^(BOOL success, NSError *error) {
        if (error) {
//            NSLog(@"ERROR saving core data: %@", error);
        }
        if (completion) {
            
//            NSLog(@"Success saving core data: %hhd", success);
            completion(success, error);
        }
    }];
}

- (void)saveContextAsync
{
    [self saveContextAsyncCompletion:nil];
}

- (void)saveContextAndWait
{
    [self.managedObjectContext saveToPersistentStoreAndWait];
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [NSManagedObjectContext defaultContext];
}

/*
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SampleCoreData.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SampleCoreData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}
*/


@end
